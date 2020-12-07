//
//  MKScannerDataModel.m
//  MKContactTracker
//
//  Created by aa on 2020/4/29.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKScannerDataModel.h"

@interface MKScannerDataModel ()

@property (nonatomic, strong)dispatch_queue_t configQueue;

@property (nonatomic, strong)dispatch_semaphore_t semaphore;

@end

@implementation MKScannerDataModel

- (void)updateWithDataModel:(MKScannerDataModel *)model {
    self.interval = model.interval;
    self.alarmNote = model.alarmNote;
    self.triggerRssi = model.triggerRssi;
    self.intenSity = model.intenSity;
    self.vibCycle = model.vibCycle;
    self.duration = model.duration;
}

- (void)startReadDatasWithSucBlock:(void (^)(void))sucBlock
                       failedBlock:(void (^)(NSError * _Nonnull))failedBlock {
    dispatch_async(self.configQueue, ^{
        if (![self readValidBLEDataFilterInterval]) {
            [self operationFailedBlockWithMsg:@"Read Valid BLE Data Filter Interval error" block:failedBlock];
            return ;
        }
        if (![self readAlarmNote]) {
            [self operationFailedBlockWithMsg:@"Read alarm notification error" block:failedBlock];
            return;
        }
        if (![self readAlarmRssi]) {
            [self operationFailedBlockWithMsg:@"Read alarm trigger rssi error" block:failedBlock];
            return;
        }
        if (![self readPWMData]) {
            [self operationFailedBlockWithMsg:@"Read Vibration Intensity error" block:failedBlock];
            return;
        }
        if (![self readVibrationCycle]) {
            [self operationFailedBlockWithMsg:@"Read Vibration Cycle error" block:failedBlock];
            return;
        }
        if (![self readDurationOfVibration]) {
            [self operationFailedBlockWithMsg:@"Read Duration Of Vibration error" block:failedBlock];
            return;
        }
        moko_dispatch_main_safe(^{
            if (sucBlock) {
                sucBlock();
            }
        });
    });
}

- (void)startConfigDatas:(MKScannerDataModel *)dataModel
                sucBlock:(void (^)(void))sucBlock
             failedBlock:(void (^)(NSError * _Nonnull))failedBlock {
    dispatch_async(self.configQueue, ^{
        if (![self configValidBLEDataFilterInterval:[dataModel.interval integerValue]]) {
            [self operationFailedBlockWithMsg:@"Config Valid BLE Data Filter Interval error" block:failedBlock];
            return;
        }
        if (![self configAlarmNotification:dataModel.alarmNote]) {
            [self operationFailedBlockWithMsg:@"Config alarm note error" block:failedBlock];
            return;
        }
        if (![self configAlarmRssi:[dataModel.triggerRssi integerValue]]) {
            [self operationFailedBlockWithMsg:@"Config alarm trigger rssi error" block:failedBlock];
            return;
        }
        if (![self configPWM:dataModel.intenSity]) {
            [self operationFailedBlockWithMsg:@"Config Vibration Intensity error" block:failedBlock];
            return;
        }
        if (![self configVibrationCycle:[dataModel.vibCycle integerValue]]) {
            [self operationFailedBlockWithMsg:@"Config Vibration Cycle error" block:failedBlock];
            return;
        }
        if (![self configDurationOfVibration:[dataModel.duration integerValue]]) {
            [self operationFailedBlockWithMsg:@"Config Duration Of Vibration error" block:failedBlock];
            return;
        }
        moko_dispatch_main_safe(^{
            sucBlock();
        });
    });
}

#pragma mark - interface
- (BOOL)readValidBLEDataFilterInterval {
    __block BOOL success = NO;
    [MKTrackerInterface readValidBLEDataFilterIntervalWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.interval = returnData[@"result"][@"interval"];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configValidBLEDataFilterInterval:(NSInteger)interval {
    __block BOOL success = NO;
    [MKTrackerInterface configValidBLEDataFilterInterval:interval sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readAlarmNote {
    __block BOOL success = NO;
    [MKTrackerInterface readAlarmNotificationWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.alarmNote = [returnData[@"result"][@"noteType"] integerValue];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configAlarmNotification:(mk_alarmNotification)note {
    __block BOOL success = NO;
    [MKTrackerInterface configAlarmNotification:note sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readAlarmRssi {
    __block BOOL success = NO;
    [MKTrackerInterface readAlarmTriggerRssiWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.triggerRssi = [NSString stringWithFormat:@"%ld",(long)[returnData[@"result"][@"rssi"] integerValue]];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configAlarmRssi:(NSInteger)rssi {
    __block BOOL success = NO;
    [MKTrackerInterface configAlarmTriggerRssi:rssi sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readPWMData {
    __block BOOL success = NO;
    [MKTrackerInterface readPWMDatasWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        NSInteger value = [returnData[@"result"][@"pwm_value"] integerValue];
        if (value <= 10) {
            self.intenSity = 0;
        }else if (value > 10 && value <= 50) {
            self.intenSity = 1;
        }else if (value > 50 && value <= 100) {
            self.intenSity = 2;
        }
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configPWM:(NSInteger)value {
    NSInteger tempValue = 10;
    if (value == 1) {
        tempValue = 50;
    }else if (value == 2) {
        tempValue = 100;
    }
    __block BOOL success = NO;
    [MKTrackerInterface configPWM:tempValue sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readVibrationCycle {
    __block BOOL success = NO;
    [MKTrackerInterface readVibrationCycleWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.vibCycle = returnData[@"result"][@"cycle"];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configVibrationCycle:(NSInteger)cycle {
    __block BOOL success = NO;
    [MKTrackerInterface configVibrationCycle:cycle sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readDurationOfVibration {
    __block BOOL success = NO;
    [MKTrackerInterface readDurationOfVibrationWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.duration = returnData[@"result"][@"duration"];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configDurationOfVibration:(NSInteger)duration {
    __block BOOL success = NO;
    [MKTrackerInterface configDurationOfVibration:duration sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

#pragma mark - private method
- (void)operationFailedBlockWithMsg:(NSString *)msg block:(void (^)(NSError *error))block {
    moko_dispatch_main_safe(^{
        NSError *error = [[NSError alloc] initWithDomain:@"scanningParams"
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
        _configQueue = dispatch_queue_create("deviceInfoReadParamsQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _configQueue;
}

@end
