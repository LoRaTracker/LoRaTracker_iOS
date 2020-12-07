//
//  MKFilterOptionsModel.m
//  MKContactTracker
//
//  Created by aa on 2020/4/24.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKFilterOptionsModel.h"
#import "MKFilterRawDataCellModel.h"

@interface MKRawFilterProtocolModel : NSObject<MKRawFilterProtocol>

@property (nonatomic, copy)NSString *dataType;

@property (nonatomic, assign)NSInteger minIndex;

@property (nonatomic, assign)NSInteger maxIndex;

@property (nonatomic, copy)NSString *rawData;

@end

@implementation MKRawFilterProtocolModel

@end

@interface MKFilterOptionsModel ()

@property (nonatomic, strong)dispatch_queue_t configQueue;

@property (nonatomic, strong)dispatch_semaphore_t semaphore;

@property (nonatomic, strong)NSMutableArray <MKFilterRawDataCellModel *>*filterRawDataList;

@end

@implementation MKFilterOptionsModel

- (void)startReadDataWithSucBlock:(void (^)(void))sucBlock
                      failedBlock:(void (^)(NSError *error))failedBlock {
    dispatch_async(self.configQueue, ^{
        if (![self readFilterRssi]) {
            [self operationFailedBlockWithMsg:@"Read rssi error" block:failedBlock];
            return ;
        }
        if (![self readMacAddressFilterStatus]) {
            [self operationFailedBlockWithMsg:@"Read mac filter error" block:failedBlock];
            return ;
        }
        if (![self readAdvNameFilterStatus]) {
            [self operationFailedBlockWithMsg:@"Read adv name filter error" block:failedBlock];
            return ;
        }
        if (![self readMajorMinMaxValue]) {
            [self operationFailedBlockWithMsg:@"Read major filter error" block:failedBlock];
            return ;
        }
        if (![self readMinorMinMaxValue]) {
            [self operationFailedBlockWithMsg:@"Read minor filter error" block:failedBlock];
            return ;
        }
        if (![self readRawDatas]) {
            [self operationFailedBlockWithMsg:@"Read raw filter error" block:failedBlock];
            return ;
        }
        moko_dispatch_main_safe(^{
            sucBlock();
        });
    });
}

- (void)startConfigData:(NSArray <MKFilterRawDataCellModel *>*)conditions
               sucBlock:(void (^)(void))sucBlock
            failedBlock:(void (^)(NSError *error))failedBlock {
    dispatch_async(self.configQueue, ^{
        if (![self validParams] || ![self validConditionsParams:conditions]) {
            [self operationFailedBlockWithMsg:@"Opps！Save failed. Please check the input characters and try again." block:failedBlock];
            return ;
        }
        if (![self configFilterRssi]) {
            [self operationFailedBlockWithMsg:@"Config filter rssi error" block:failedBlock];
            return;
        }
        if (![self configMacFilter]) {
            [self operationFailedBlockWithMsg:@"Config mac filter error" block:failedBlock];
            return;
        }
        if (![self configAdvNameFilterStatus]) {
            [self operationFailedBlockWithMsg:@"Config adv name filter error" block:failedBlock];
            return;
        }
        if (![self configMajorMaxMinValue]) {
            [self operationFailedBlockWithMsg:@"Config major filter error" block:failedBlock];
            return;
        }
        if (![self configMinorMinMaxValue]) {
            [self operationFailedBlockWithMsg:@"Config minor filter error" block:failedBlock];
            return;
        }
        if (![self configRawDatas:conditions]) {
            [self operationFailedBlockWithMsg:@"Config raw filter error" block:failedBlock];
            return;
        }
        moko_dispatch_main_safe(^{
            sucBlock();
        });
    });
}

#pragma mark - interface
- (BOOL)readFilterRssi {
    __block BOOL success = NO;
    [MKTrackerInterface readFilterRssiValueWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.rssiValue = [returnData[@"result"][@"rssi"] integerValue];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configFilterRssi {
    __block BOOL success = NO;
    [MKTrackerInterface configFilterRssiValue:self.rssiValue sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readMacAddressFilterStatus {
    __block BOOL success = NO;
    [MKTrackerInterface readMacAddressFilterStatusWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.macIson = [returnData[@"result"][@"isOn"] boolValue];
        self.macValue = returnData[@"result"][@"filterMac"];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configMacFilter {
    __block BOOL success = NO;
    [MKTrackerInterface configMacFilterStatus:self.macIson mac:self.macValue sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readAdvNameFilterStatus {
    __block BOOL success = NO;
    [MKTrackerInterface readAdvNameFilterStatusWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.advNameIson = [returnData[@"result"][@"isOn"] boolValue];
        self.advNameValue = returnData[@"result"][@"advName"];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configAdvNameFilterStatus {
    __block BOOL success = NO;
    [MKTrackerInterface configAdvNameFilterStatus:self.advNameIson advName:self.advNameValue sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readMajorMinMaxValue {
    __block BOOL success = NO;
    [MKTrackerInterface readMajorFilterStateWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.majorIson = [returnData[@"result"][@"isOn"] boolValue];
        self.majorMinValue = returnData[@"result"][@"majorMinValue"];
        self.majorMaxValue = returnData[@"result"][@"majorMaxValue"];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configMajorMaxMinValue {
    __block BOOL success = NO;
    [MKTrackerInterface configMajorFilterStatus:self.majorIson majorMinValue:[self.majorMinValue integerValue] majorMaxValue:[self.majorMaxValue integerValue] sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readMinorMinMaxValue {
    __block BOOL success = NO;
    [MKTrackerInterface readMinorFilterStateWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.minorIson = [returnData[@"result"][@"isOn"] boolValue];
        self.minorMinValue = returnData[@"result"][@"minorMinValue"];
        self.minorMaxValue = returnData[@"result"][@"minorMaxValue"];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configMinorMinMaxValue {
    __block BOOL success = NO;
    [MKTrackerInterface configMinorFilterStatus:self.minorIson minorMinValue:[self.minorMinValue integerValue] minorMaxValue:[self.minorMaxValue integerValue] sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readRawDatas {
    __block BOOL success = NO;
    [MKTrackerInterface readFilterRawDatasWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        NSArray *list = returnData[@"result"][@"filterList"];
        self.filterRawDataIsOn = (list.count > 0);
        for (NSInteger i = 0; i < list.count; i ++) {
            NSDictionary *dic = list[i];
            MKFilterRawDataCellModel *model = [[MKFilterRawDataCellModel alloc] init];
            [model modelSetWithJSON:dic];
            [self.filterRawDataList addObject:model];
        }
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configRawDatas:(NSArray <MKFilterRawDataCellModel *>*)conditions {
    NSMutableArray *list = [NSMutableArray arrayWithCapacity:conditions.count];
    for (NSInteger i = 0 ; i < conditions.count; i ++) {
        MKFilterRawDataCellModel *tempModel = conditions[i];
        MKRawFilterProtocolModel *protocolModel = [[MKRawFilterProtocolModel alloc] init];
        protocolModel.dataType = tempModel.dataType;
        protocolModel.minIndex = (ValidStr(tempModel.minIndex) ? [tempModel.minIndex integerValue] : 0);
        protocolModel.maxIndex = (ValidStr(tempModel.maxIndex) ? [tempModel.maxIndex integerValue] : 0);
        protocolModel.rawData = tempModel.rawData;
        [list addObject:protocolModel];
    }
    __block BOOL success = NO;
    [MKTrackerInterface configRawFilterConditions:list sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

#pragma mark - params valid
- (BOOL)validParams {
    if (self.macIson) {
        if (self.macValue.length % 2 != 0 || self.macValue.length == 0 || self.macValue.length > 12) {
            return NO;
        }
    }
    if (self.advNameIson) {
        if (!ValidStr(self.advNameValue) || self.advNameValue.length > 10) {
            return NO;
        }
    }
    if (self.majorIson) {
        if (!ValidStr(self.majorMaxValue) || [self.majorMaxValue integerValue] < 0 || [self.majorMaxValue integerValue] > 65535) {
            return NO;
        }
        if (!ValidStr(self.majorMinValue) || [self.majorMinValue integerValue] < 0 || [self.majorMinValue integerValue] > 65535) {
            return NO;
        }
        if ([self.majorMaxValue integerValue] < [self.majorMinValue integerValue]) {
            return NO;
        }
    }
    if (self.minorIson) {
        if (!ValidStr(self.minorMaxValue) || [self.minorMaxValue integerValue] < 0 || [self.minorMaxValue integerValue] > 65535) {
            return NO;
        }
        if (!ValidStr(self.minorMinValue) || [self.minorMinValue integerValue] < 0 || [self.minorMinValue integerValue] > 65535) {
            return NO;
        }
        if ([self.minorMaxValue integerValue] < [self.minorMinValue integerValue]) {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)validConditionsParams:(NSArray<MKFilterRawDataCellModel *> *)conditions {
    if (!self.filterRawDataIsOn) {
        return YES;
    }
    if (conditions.count == 0) {
        return NO;
    }
    for (MKFilterRawDataCellModel *model in conditions) {
        if (![model validParamsSuccess]) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - private method
- (void)operationFailedBlockWithMsg:(NSString *)msg block:(void (^)(NSError *error))block {
    moko_dispatch_main_safe(^{
        NSError *error = [[NSError alloc] initWithDomain:@"advFilterParams"
                                                    code:-999
                                                userInfo:@{@"errorInfo":SafeStr(msg)}];
        block(error);
    })
}

#pragma mark - getter
- (dispatch_semaphore_t)semaphore {
    if (!_semaphore) {
        _semaphore = dispatch_semaphore_create(0);
    }
    return _semaphore;
}

- (dispatch_queue_t)configQueue {
    if (!_configQueue) {
        _configQueue = dispatch_queue_create("filterParamsQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _configQueue;
}

- (NSMutableArray<MKFilterRawDataCellModel *> *)filterRawDataList {
    if (!_filterRawDataList) {
        _filterRawDataList = [NSMutableArray array];
    }
    return _filterRawDataList;
}

@end
