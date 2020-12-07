//
//  MKDeviceSettingModel.m
//  MKLorawanGpsTracker
//
//  Created by aa on 2019/4/30.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKDeviceSettingModel.h"

@interface MKDeviceSettingModel ()

@property (nonatomic, copy)void (^readCompleteBlock)(NSError *error, BOOL complete);

@property (nonatomic, copy)void (^configCompleteBlock)(NSError *error, BOOL complete);

@property (nonatomic, strong)dispatch_semaphore_t semaphore;

@property (nonatomic, strong)dispatch_queue_t readQueue;

@end

@implementation MKDeviceSettingModel

#pragma mark - Public method

- (void)startReadDatas:(BOOL)isDebugMode block:(void (^) (NSError *error, BOOL complete))block {
    self.readCompleteBlock = nil;
    self.readCompleteBlock = block;
    dispatch_async(self.readQueue, ^{
        if (![self readModem]) {
            [self readDataError:@"Error reading modem"];
            return ;
        }
        if (![self readDevAddr]) {
            [self readDataError:@"Error reading DevAddr"];
            return;
        }
        if (![self readNwkSKey]) {
            [self readDataError:@"Error reading NwmSKey"];
            return;
        }
        if (![self readAppSKey]) {
            [self readDataError:@"Error reading AppSKey"];
            return;
        }
        if (![self readDevEUI]) {
            [self readDataError:@"Error reading DevEUI"];
            return;
        }
        if (![self readAppEUI]) {
            [self readDataError:@"Error reading AppEUI"];
            return;
        }
        if (![self readAppKey]) {
            [self readDataError:@"Error reading AppKey"];
            return;
        }
        if (![self readRegion]) {
            [self readDataError:@"Error reading Region"];
            return;
        }
        if (![self readInterval]) {
            [self readDataError:@"Error reading report interval"];
            return;
        }
        if (![self readMessageType]) {
            [self readDataError:@"Error reading message type"];
            return;
        }
        if (isDebugMode) {
            if (![self readCHValue]) {
                [self readDataError:@"Error reading CH Data"];
                return;
            }
            if (![self readDRValue]) {
                [self readDataError:@"Error reading DR Data"];
                return;
            }
            if (![self readADRConnectStatus]) {
                [self readDataError:@"Error reading ADR Status"];
                return;
            }
        }
        moko_dispatch_main_safe(^{
            if (self.readCompleteBlock) {
                self.readCompleteBlock(nil, YES);
            }
        });
    });
}

- (void)configDatas:(BOOL)isDebugMode block:(void (^) (NSError *error, BOOL complete))block {
    self.configCompleteBlock = nil;
    self.configCompleteBlock = block;
    dispatch_async(self.readQueue, ^{
        if (![self checkParams]) {
            return ;
        }
        if (![self configModem]) {
            [self readDataError:@"Configuration modem error"];
            return;
        }
        if (![self configDevEUI]) {
            [self readDataError:@"Configuration DevEUI error"];
            return;
        }
        if (![self configAppEUI]) {
            [self readDataError:@"Configuration AppEUI error"];
            return;
        }
        if (self.modem == 1) {
            //ABP
            if (![self configDevAddr]) {
                [self readDataError:@"Configuration DevAddr error"];
                return;
            }
            if (![self configAppSKey]) {
                [self readDataError:@"Configuration AppSKey error"];
                return;
            }
            if (![self configNwkSKey]) {
                [self readDataError:@"Configuration NwkSKey error"];
                return;
            }
        }else {
            //OTAA
            if (![self configAppKey]) {
                [self readDataError:@"Configuration AppKey error"];
                return;
            }
        }
        if (![self configRegion]) {
            [self readDataError:@"Configuration Region error"];
            return;
        }
        if (![self configMessageType]) {
            [self readDataError:@"Configuration message type error"];
            return;
        }
        if (![self configInterval]) {
            [self readDataError:@"Configuration report interval error"];
            return;
        }
        if (isDebugMode) {
            if (![self configCHValue]) {
                [self readDataError:@"Configuration CH Data error"];
                return;
            }
            if (![self configDRValue]) {
                [self readDataError:@"Configuration DR Data error"];
                return;
            }
            if (![self configADRConnectStatus]) {
                [self readDataError:@"Configuration ADR Status error"];
                return;
            }
        }
        moko_dispatch_main_safe(^{
            if (self.configCompleteBlock) {
                self.configCompleteBlock(nil, YES);
            }
        });
    });
}

#pragma mark - 数据接口
- (BOOL)checkParams {
    //0:ABP,1:OTAA
    if (self.modem != 1 && self.modem != 2) {
        [self configParamsError:@"Modem error"];
        return NO;
    }
    if (self.modem == 1) {
        //ABP
        if (!ValidStr(self.devAddr) || self.devAddr.length != 8) {
            [self configParamsError:@"devAddr must be 8 bits long"];
            return NO;
        }
        if (!ValidStr(self.nwkSKey) || self.nwkSKey.length != 32) {
            [self configParamsError:@"nwkSKey must be 32 bits long"];
            return NO;
        }
        if (!ValidStr(self.appSKey) || self.appSKey.length != 32) {
            [self configParamsError:@"appSKey must be 32 bits long"];
            return NO;
        }
    }else {
        //OTAA
        if (!ValidStr(self.devEUI) || self.devEUI.length != 16) {
            [self configParamsError:@"devEUI must be 16 bits long"];
            return NO;
        }
        if (!ValidStr(self.appEUI) || self.appEUI.length != 16) {
            [self configParamsError:@"appEUI must be 16 bits long"];
            return NO;
        }
        if (!ValidStr(self.appKey) || self.appKey.length != 32) {
            [self configParamsError:@"appKey must be 32 bits long"];
            return NO;
        }
    }
    if (self.region < 0 || self.region > 12) {
        [self configParamsError:@"Region error"];
        return NO;
    }
    if (self.reportingInterval < 1 || self.reportingInterval > 60) {
        [self configParamsError:@"Reporting Interval error"];
        return NO;
    }
    return YES;
}

- (BOOL)readModem {
    __block BOOL success = NO;
    [MKTrackerInterface readLoraWANModemWithSucBlock:^(id returnData) {
        NSInteger tempModem = [returnData[@"result"][@"modem"] integerValue];
        if (tempModem == 1) {
            self.modem = 1;
        }else {
            self.modem = 2;
        }
        NSLog(@"================>model:%@",returnData[@"result"][@"modem"]);
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError *error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configModem {
    __block BOOL success = NO;
    [MKTrackerInterface configLoraWANModem:(self.modem - 1) sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readDevEUI {
    __block BOOL success = NO;
    [MKTrackerInterface readDevEUIWithSucBlock:^(id returnData) {
        self.devEUI = returnData[@"result"][@"devEUI"];
        NSLog(@"================>devEUI:%@",returnData[@"result"][@"devEUI"]);
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError *error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configDevEUI {
    __block BOOL success = NO;
    [MKTrackerInterface configDevEUI:self.devEUI sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readAppEUI {
    __block BOOL success = NO;
    [MKTrackerInterface readAPPEUIWithSucBlock:^(id returnData) {
        self.appEUI = returnData[@"result"][@"appEUI"];
        NSLog(@"================>appEUI:%@",returnData[@"result"][@"appEUI"]);
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError *error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configAppEUI {
    __block BOOL success = NO;
    [MKTrackerInterface configAppEUI:self.appEUI sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readAppKey {
    __block BOOL success = NO;
    [MKTrackerInterface readAppKeyWithSucBlock:^(id returnData) {
        self.appKey = returnData[@"result"][@"appKey"];
        NSLog(@"================>appKey:%@",returnData[@"result"][@"appKey"]);
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError *error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configAppKey {
    __block BOOL success = NO;
    [MKTrackerInterface configAppKey:self.appKey sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readDevAddr {
    __block BOOL success = NO;
    [MKTrackerInterface readDevAddrWithSucBlock:^(id returnData) {
        self.devAddr = returnData[@"result"][@"devAddr"];
        NSLog(@"================>devAddr:%@",returnData[@"result"][@"devAddr"]);
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError *error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configDevAddr {
    __block BOOL success = NO;
    [MKTrackerInterface configDevAddr:self.devAddr sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readNwkSKey {
    __block BOOL success = NO;
    [MKTrackerInterface readNwkSKeyWithSucBlock:^(id returnData) {
        self.nwkSKey = returnData[@"result"][@"nwkSKey"];
        NSLog(@"================>nwkSKey:%@",returnData[@"result"][@"nwkSKey"]);
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError *error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configNwkSKey {
    __block BOOL success = NO;
    [MKTrackerInterface configNwkSKey:self.nwkSKey sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readAppSKey {
    __block BOOL success = NO;
    [MKTrackerInterface readAPPSKeyWithSucBlock:^(id returnData) {
        self.appSKey = returnData[@"result"][@"appSKey"];
        NSLog(@"================>appSKey:%@",returnData[@"result"][@"appSKey"]);
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError *error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configAppSKey {
    __block BOOL success = NO;
    [MKTrackerInterface configAppSKey:self.appSKey sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readRegion {
    __block BOOL success = NO;
    [MKTrackerInterface readRegionWithSucBlock:^(id returnData) {
        self.region = [returnData[@"result"][@"region"] integerValue];
        NSLog(@"================>region:%@",returnData[@"result"][@"region"]);
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError *error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configRegion {
    __block BOOL success = NO;
    [MKTrackerInterface configRegion:self.region sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readInterval {
    __block BOOL success = NO;
    [MKTrackerInterface readLoRaReportingIntervalWithSucBlock:^(id returnData) {
        self.reportingInterval = [returnData[@"result"][@"interval"] integerValue];
        NSLog(@"================>interval:%@",returnData[@"result"][@"interval"]);
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError *error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configInterval {
    __block BOOL success = NO;
    [MKTrackerInterface configLoRaReportingInterval:self.reportingInterval sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}
                   
- (BOOL)readMessageType {
    __block BOOL success = NO;
    [MKTrackerInterface readMessageTypeWithSucBlock:^(id returnData) {
        success = YES;
        self.messageType = [returnData[@"result"][@"messageType"] integerValue];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError *error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configMessageType {
    __block BOOL success = NO;
    [MKTrackerInterface configDeviceMessageType:self.messageType sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readCHValue {
    __block BOOL success = NO;
    [MKTrackerInterface readCHDataWithSucBlock:^(id returnData) {
        self.CHLValue = [returnData[@"result"][@"CHL"] integerValue];
        self.CHHValue = [returnData[@"result"][@"CHH"] integerValue];
        NSLog(@"================>CH:%@",returnData[@"result"]);
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError *error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configCHValue {
    __block BOOL success = NO;
    [MKTrackerInterface configCHValue:self.CHLValue CHHValue:self.CHHValue sucBlock:^{
        NSLog(@"++++++++++++++++++>CH:%@",@{
                                            @"CHH":@(self.CHHValue),
                                            @"CHL":@(self.CHLValue),
                                            });
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError *error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readDRValue {
    __block BOOL success = NO;
    [MKTrackerInterface readDRDataWithSucBlock:^(id returnData) {
        self.DRValue = [returnData[@"result"][@"DR"] integerValue];
        NSLog(@"================>DR:%@",returnData[@"result"]);
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError *error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configDRValue {
    __block BOOL success = NO;
    [MKTrackerInterface configDRValue:self.DRValue sucBlock:^{
        NSLog(@"++++++++++++++++>DR:%@",@{
                                          @"DR":@(self.DRValue),
                                          });
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readADRConnectStatus {
    __block BOOL success = NO;
    [MKTrackerInterface readADRStatusWithSucBlock:^(id returnData) {
        self.adrIsOn = [returnData[@"result"][@"adrOpen"] boolValue];
        NSLog(@"================>adrOpen:%@",returnData[@"result"][@"adrOpen"]);
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError *error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configADRConnectStatus {
    __block BOOL success = NO;
    [MKTrackerInterface configADRStatus:self.adrIsOn sucBlock:^{
        NSLog(@"+++++++++++++++++>adrStatus:%@",@(self.adrIsOn));
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError *error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

#pragma mark - Private method

- (void)readDataError:(NSString *)message {
    NSError *error = [[NSError alloc] initWithDomain:@"com.moko.deviceSettingRead"
                                                code:-999
                                            userInfo:@{@"errorInfo":message}];
    moko_dispatch_main_safe(^{
        if (self.readCompleteBlock) {
            self.readCompleteBlock(error, NO);
        }
    });
}

- (void)configParamsError:(NSString *)message {
    NSError *error = [[NSError alloc] initWithDomain:@"com.moko.deviceSettingConfig"
                                                code:-999
                                            userInfo:@{@"errorInfo":message}];
    moko_dispatch_main_safe(^{
        if (self.configCompleteBlock) {
            self.configCompleteBlock(error, NO);
        }
    });
}

#pragma mark - getter
- (dispatch_queue_t)readQueue {
    if (!_readQueue) {
        _readQueue = dispatch_queue_create("com.moko.readDeviceSettingQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _readQueue;
}

- (dispatch_semaphore_t)semaphore {
    if (!_semaphore) {
        _semaphore = dispatch_semaphore_create(0);
    }
    return _semaphore;
}

@end
