//
//  MKDeviceTypeManager.m
//  MKContactTracker
//
//  Created by aa on 2020/6/30.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKDeviceTypeManager.h"

#import "MKConfigDateModel.h"

static MKDeviceTypeManager *manager = nil;

@interface MKDeviceTypeManager ()

@property (nonatomic, strong)dispatch_queue_t connectQueue;

@property (nonatomic, strong)dispatch_semaphore_t connectSemaphore;

@property (nonatomic, copy)NSString *password;

@end

@implementation MKDeviceTypeManager

+ (MKDeviceTypeManager *)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [MKDeviceTypeManager new];
        }
    });
    return manager;
}

- (void)connectTracker:(MKTrackerModel *)trackerModel
              password:(NSString *)password
              sucBlock:(void (^)(void))sucBlock
           failedBlock:(void (^)(NSError *error))failedBlock {
    dispatch_async(self.connectQueue, ^{
        NSDictionary *connectResult = [self connectDevice:trackerModel password:password];
        if (![connectResult[@"success"] boolValue]) {
            moko_dispatch_main_safe(^{
                if (failedBlock) {
                    failedBlock(connectResult[@"error"]);
                }
            });
            return ;
        }
        if (![self configDate]) {
            [self operationFailedMsg:@"Config Date Error" failedBlock:failedBlock];
            return ;
        }
        self.password = password;
        moko_dispatch_main_safe(^{
            if (sucBlock) {
                sucBlock();
            }
        });
    });
}

#pragma mark - interface
- (NSDictionary *)connectDevice:(MKTrackerModel *)trackerModel password:(NSString *)password {
    __block NSDictionary *resultDic = @{};
    [[MKTrackerCentralManager shared] connectDevice:trackerModel password:password sucBlock:^(CBPeripheral * _Nonnull peripheral) {
        resultDic = @{
            @"success":@(YES)
        };
        dispatch_semaphore_signal(self.connectSemaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        resultDic = @{
            @"success":@(NO),
            @"error":error,
        };
        dispatch_semaphore_signal(self.connectSemaphore);
    }];
    dispatch_semaphore_wait(self.connectSemaphore, DISPATCH_TIME_FOREVER);
    return resultDic;
}

- (BOOL)configDate {
    __block BOOL success = NO;
    MKConfigDateModel *dateModel = [MKConfigDateModel fetchCurrentTime];
    [MKTrackerInterface configDeviceTime:dateModel sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.connectSemaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.connectSemaphore);
    }];
    dispatch_semaphore_wait(self.connectSemaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (NSString *)readFirmwareVersion {
    __block NSString *firmware = @"";
    [MKTrackerInterface readFirmwareWithSucBlock:^(id  _Nonnull returnData) {
        firmware = returnData[@"result"][@"firmware"];
        dispatch_semaphore_signal(self.connectSemaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.connectSemaphore);
    }];
    dispatch_semaphore_wait(self.connectSemaphore, DISPATCH_TIME_FOREVER);
    return firmware;
}

#pragma mark - private method

- (NSError *)fetchErrorWithMsg:(NSString *)msg {
    NSError *error = [[NSError alloc] initWithDomain:@"connectDevice"
                                                code:-999
                                            userInfo:@{@"errorInfo":SafeStr(msg)}];
    return error;
}

- (void)operationFailedMsg:(NSString *)msg failedBlock:(void (^)(NSError *error))failedBlock {
    moko_dispatch_main_safe(^{
        [[MKTrackerCentralManager shared] disconnect];
        if (failedBlock) {
            failedBlock([self fetchErrorWithMsg:msg]);
        }
    });
}

#pragma mark - getter
- (dispatch_queue_t)connectQueue {
    if (!_connectQueue) {
        _connectQueue = dispatch_queue_create("com.moko.connectQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _connectQueue;
}

- (dispatch_semaphore_t)connectSemaphore {
    if (!_connectSemaphore) {
        _connectSemaphore = dispatch_semaphore_create(0);
    }
    return _connectSemaphore;
}

@end
