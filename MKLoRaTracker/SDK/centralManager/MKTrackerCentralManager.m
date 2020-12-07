//
//  MKTrackerCentralManager.m
//  MKContactTracker
//
//  Created by aa on 2020/4/22.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKTrackerCentralManager.h"
#import "MKBLEBaseSDKAdopter.h"

#import "MKTrackerModel.h"
#import "MKTrackerPeripheral.h"
#import "MKTrackerOperation.h"
#import "MKTrackerAdopter.h"
#import "CBPeripheral+MKTracker.h"

#import "MKTrackerSDKDefines.h"

NSString *const mk_peripheralConnectStateChangedNotification = @"mk_peripheralConnectStateChangedNotification";
NSString *const mk_centralManagerStateChangedNotification = @"mk_centralManagerStateChangedNotification";

NSString *const mk_receiveScannerTrackedDataNotification = @"mk_receiveScannerTrackedDataNotification";
NSString *const mk_deviceDisconnectTypeNotification = @"mk_deviceDisconnectTypeNotification";

static MKTrackerCentralManager *manager = nil;
static dispatch_once_t onceToken;

@interface MKTrackerCentralManager ()

@property (nonatomic, copy)NSString *password;

@property (nonatomic, copy)void (^sucBlock)(CBPeripheral *peripheral);

@property (nonatomic, copy)void (^failedBlock)(NSError *error);

@property (nonatomic, assign)mk_bleCentralConnectStatus connectStatus;

@end

@implementation MKTrackerCentralManager

- (instancetype)init {
    if (self = [super init]) {
        [[MKBLEBaseCentralManager shared] loadDataManager:self];
    }
    return self;
}

+ (MKTrackerCentralManager *)shared {
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [MKTrackerCentralManager new];
        }
    });
    return manager;
}

+ (void)sharedDealloc {
    [MKBLEBaseCentralManager singleDealloc];
    manager = nil;
    onceToken = 0;
}

#pragma mark - MKBLEBaseScanProtocol
- (void)MKBLEBaseCentralManagerDiscoverPeripheral:(CBPeripheral *)peripheral
                                advertisementData:(NSDictionary<NSString *,id> *)advertisementData
                                             RSSI:(NSNumber *)RSSI {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        MKTrackerModel *dataModel = [self parseModelWith:RSSI advDic:advertisementData peripheral:peripheral];
        if (!dataModel) {
            return ;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(mk_trackerReceiveDevice:)]) {
                [self.delegate mk_trackerReceiveDevice:dataModel];
            }
        });
    });
}

- (void)MKBLEBaseCentralManagerStartScan {
    if ([self.delegate respondsToSelector:@selector(mk_trackerStartScan)]) {
        [self.delegate mk_trackerStartScan];
    }
}

- (void)MKBLEBaseCentralManagerStopScan {
    if ([self.delegate respondsToSelector:@selector(mk_trackerStopScan)]) {
        [self.delegate mk_trackerStopScan];
    }
}

#pragma mark - MKBLEBaseCentralManagerStateProtocol
- (void)MKBLEBaseCentralManagerStateChanged:(MKCentralManagerState)centralManagerState {
    NSLog(@"蓝牙中心改变");
    [[NSNotificationCenter defaultCenter] postNotificationName:mk_centralManagerStateChangedNotification object:nil];
}

- (void)MKBLEBasePeripheralConnectStateChanged:(MKPeripheralConnectState)connectState {
    //连接成功的判断必须是发送密码成功之后
    if (connectState == MKPeripheralConnectStateUnknow) {
        self.connectStatus = mk_bleCentralConnectStatusUnknow;
    }else if (connectState == MKPeripheralConnectStateConnecting) {
        self.connectStatus = mk_bleCentralConnectStatusConnecting;
    }else if (connectState == MKPeripheralConnectStateConnectedFailed) {
        self.connectStatus = mk_bleCentralConnectStatusConnectedFailed;
    }else if (connectState == MKPeripheralConnectStateDisconnect) {
        self.connectStatus = mk_bleCentralConnectStatusDisconnect;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:mk_peripheralConnectStateChangedNotification object:nil];
}

#pragma mark - MKBLEBaseCentralManagerProtocol
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"+++++++++++++++++接收数据出错");
        return;
    }
    if ([characteristic.UUID isEqual:MKUUID(@"FF01")]) {
        //引起设备断开连接的类型
        NSString *content = [MKBLEBaseSDKAdopter hexStringFromData:characteristic.value];
        [[NSNotificationCenter defaultCenter] postNotificationName:mk_deviceDisconnectTypeNotification
                                                            object:nil
                                                          userInfo:@{@"type":[content substringWithRange:NSMakeRange(2, 2)]}];
        return;
    }
    if ([characteristic.UUID isEqual:MKUUID(@"FF0E")]) {
        //广播的数据
        NSString *content = [MKBLEBaseSDKAdopter hexStringFromData:characteristic.value];
        if (content.length < 26) {
            return;
        }
        NSDictionary *dic = [MKTrackerAdopter parseScannerTrackedData:content];
        [[NSNotificationCenter defaultCenter] postNotificationName:mk_receiveScannerTrackedDataNotification
                                                            object:nil
                                                          userInfo:dic];
        return;
    }
}
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    if (error) {
        NSLog(@"+++++++++++++++++发送数据出错");
        return;
    }
    
}

#pragma mark - public method
- (CBCentralManager *)centralManager {
    return [MKBLEBaseCentralManager shared].centralManager;
}

- (CBPeripheral *)peripheral {
    return [MKBLEBaseCentralManager shared].peripheral;
}

- (MKCentralManagerState )centralStatus {
    return [MKBLEBaseCentralManager shared].centralStatus;
}

- (void)startScan {
    [[MKBLEBaseCentralManager shared] scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"FF03"]] options:nil];
}

- (void)stopScan {
    [[MKBLEBaseCentralManager shared] stopScan];
}

- (void)connectDevice:(nonnull MKTrackerModel *)trackerModel
             password:(NSString *)password
             sucBlock:(void (^)(CBPeripheral *peripheral))sucBlock
          failedBlock:(void (^)(NSError *error))failedBlock {
    if (!trackerModel.connectable || !trackerModel.peripheral) {
        [MKBLEBaseSDKAdopter operationConnectFailedBlock:failedBlock];
        return;
    }
    if (password.length != 8 || ![MKBLEBaseSDKAdopter asciiString:password]) {
        [self operationFailedBlockWithMsg:@"Password Error" failedBlock:failedBlock];
        return;
    }
    self.password = nil;
    self.password = password;
    __weak typeof(self) weakSelf = self;
    [self connectPeripheral:trackerModel successBlock:^(CBPeripheral *peripheral) {
        __strong typeof(self) sself = weakSelf;
        if (sucBlock) {
            sucBlock(peripheral);
        }
        sself.sucBlock = nil;
        sself.failedBlock = nil;
    } failedBlock:^(NSError *error) {
        __strong typeof(self) sself = weakSelf;
        sself.sucBlock = nil;
        sself.failedBlock = nil;
        if (failedBlock) {
            failedBlock(error);
        }
    }];
}

- (void)disconnect {
    [[MKBLEBaseCentralManager shared] disconnect];
}

- (BOOL)notifyDisconnectType:(BOOL)notify {
    if (self.connectStatus != mk_bleCentralConnectStatusConnected || [MKBLEBaseCentralManager shared].peripheral == nil || [MKBLEBaseCentralManager shared].peripheral.disconnectType == nil) {
        return NO;
    }
    [[MKBLEBaseCentralManager shared].peripheral setNotifyValue:notify
                                              forCharacteristic:[MKBLEBaseCentralManager shared].peripheral.disconnectType];
    return YES;
}

- (void)addTaskWithTaskID:(mk_taskOperationID)operationID
           characteristic:(CBCharacteristic *)characteristic
                 resetNum:(BOOL)resetNum
              commandData:(NSString *)commandData
             successBlock:(void (^)(id returnData))successBlock
             failureBlock:(void (^)(NSError *error))failureBlock {
    MKTrackerOperation <MKBLEBaseOperationProtocol>*operation = [self generateOperationWithOperationID:operationID
                                                                                        characteristic:characteristic
                                                                                              resetNum:resetNum
                                                                                           commandData:commandData
                                                                                          successBlock:successBlock
                                                                                          failureBlock:failureBlock];
    if (!operation) {
        return;
    }
    [[MKBLEBaseCentralManager shared] addOperation:operation];
}

- (void)addReadTaskWithTaskID:(mk_taskOperationID)operationID
               characteristic:(CBCharacteristic *)characteristic
                 successBlock:(void (^)(id returnData))successBlock
                 failureBlock:(void (^)(NSError *error))failureBlock {
    MKTrackerOperation <MKBLEBaseOperationProtocol>*operation = [self generateReadOperationWithOperationID:operationID
                                                                                            characteristic:characteristic
                                                                                              successBlock:successBlock
                                                                                              failureBlock:failureBlock];
    if (!operation) {
        return;
    }
    [[MKBLEBaseCentralManager shared] addOperation:operation];
}

#pragma mark - password method
- (void)connectPeripheral:(MKTrackerModel *)trackerModel
             successBlock:(void (^)(CBPeripheral *peripheral))sucBlock
              failedBlock:(void (^)(NSError *error))failedBlock {
    self.sucBlock = nil;
    self.sucBlock = sucBlock;
    self.failedBlock = nil;
    self.failedBlock = failedBlock;
    MKTrackerPeripheral *trackerPeripheral = [[MKTrackerPeripheral alloc] init];
    trackerPeripheral.peripheral = trackerModel.peripheral;
    [[MKBLEBaseCentralManager shared] connectDevice:trackerPeripheral sucBlock:^(CBPeripheral * _Nonnull peripheral) {
        [self sendPasswordToDevice];
    } failedBlock:failedBlock];
}

- (void)sendPasswordToDevice {
    NSString *commandData = @"ed";
    for (NSInteger i = 0; i < self.password.length; i ++) {
        int asciiCode = [self.password characterAtIndex:i];
        commandData = [commandData stringByAppendingString:[NSString stringWithFormat:@"%1lx",(unsigned long)asciiCode]];
    }
    MKTrackerOperation *operation = [[MKTrackerOperation alloc] initOperationWithID:mk_taskConfigPasswordOperation resetNum:NO commandBlock:^{
        [[MKBLEBaseCentralManager shared] sendDataToPeripheral:commandData characteristic:[MKBLEBaseCentralManager shared].peripheral.password type:CBCharacteristicWriteWithResponse];
    } completeBlock:^(NSError * _Nonnull error, mk_taskOperationID operationID, id  _Nonnull returnData) {
        if (error) {
            MKBLEBase_main_safe(^{
                if (self.failedBlock) {
                    self.failedBlock(error);
                }
            });
            return ;
        }
        NSDictionary *dataDic = ((NSArray *)returnData[mk_dataInformation])[0];
        if ([dataDic[@"state"] isEqualToString:@"ed01"]) {
            //密码正确
            MKBLEBase_main_safe(^{
                self.connectStatus = mk_bleCentralConnectStatusConnected;
                [[NSNotificationCenter defaultCenter] postNotificationName:mk_peripheralConnectStateChangedNotification object:nil];
                if (self.sucBlock) {
                    self.sucBlock([MKBLEBaseCentralManager shared].peripheral);
                }
            });
        }
        if ([dataDic[@"state"] isEqualToString:@"ed00"]) {
            //密码错误
            [self operationFailedBlockWithMsg:@"Password Error" failedBlock:self.failedBlock];
            return ;
        }
    }];
    [[MKBLEBaseCentralManager shared] addOperation:operation];
}

#pragma mark - task method
- (MKTrackerOperation <MKBLEBaseOperationProtocol>*)generateOperationWithOperationID:(mk_taskOperationID)operationID
                                                                      characteristic:(CBCharacteristic *)characteristic
                                                                            resetNum:(BOOL)resetNum
                                                                         commandData:(NSString *)commandData
                                                                        successBlock:(void (^)(id returnData))successBlock
                                                                        failureBlock:(void (^)(NSError *error))failureBlock{
    if (![[MKBLEBaseCentralManager shared] readyToCommunication]) {
        [self operationFailedBlockWithMsg:@"The current connection device is in disconnect" failedBlock:failureBlock];
        return nil;
    }
    if (!MKValidStr(commandData)) {
        [self operationFailedBlockWithMsg:@"The data sent to the device cannot be empty" failedBlock:failureBlock];
        return nil;
    }
    if (!characteristic) {
        [self operationFailedBlockWithMsg:@"Characteristic error" failedBlock:failureBlock];
        return nil;
    }
    __weak typeof(self) weakSelf = self;
    MKTrackerOperation <MKBLEBaseOperationProtocol>*operation = [[MKTrackerOperation alloc] initOperationWithID:operationID resetNum:resetNum commandBlock:^{
        [[MKBLEBaseCentralManager shared] sendDataToPeripheral:commandData characteristic:characteristic type:CBCharacteristicWriteWithResponse];
    } completeBlock:^(NSError * _Nonnull error, mk_taskOperationID operationID, id  _Nonnull returnData) {
        __strong typeof(self) sself = weakSelf;
        if (error) {
            MKBLEBase_main_safe(^{
                if (failureBlock) {
                    failureBlock(error);
                }
            });
            return ;
        }
        if (!returnData) {
            [sself operationFailedBlockWithMsg:@"Request data error" failedBlock:failureBlock];
            return ;
        }
        NSString *lev = returnData[mk_dataStatusLev];
        if ([lev isEqualToString:@"1"]) {
            //通用无附加信息的
            NSArray *dataList = (NSArray *)returnData[mk_dataInformation];
            if (!dataList) {
                [sself operationFailedBlockWithMsg:@"Request data error" failedBlock:failureBlock];
                return;
            }
            NSDictionary *resultDic = @{@"msg":@"success",
                                        @"code":@"1",
                                        @"result":(dataList.count == 1 ? dataList[0] : dataList),
                                        };
            MKBLEBase_main_safe(^{
                if (successBlock) {
                    successBlock(resultDic);
                }
            });
            return;
        }
        //对于有附加信息的
        NSDictionary *resultDic = @{@"msg":@"success",
                                    @"code":@"1",
                                    @"result":returnData[mk_dataInformation],
                                    };
        MKBLEBase_main_safe(^{
            if (successBlock) {
                successBlock(resultDic);
            }
        });
    }];
    return operation;
}

- (MKTrackerOperation <MKBLEBaseOperationProtocol>*)generateReadOperationWithOperationID:(mk_taskOperationID)operationID
                                                                          characteristic:(CBCharacteristic *)characteristic
                                                                            successBlock:(void (^)(id returnData))successBlock
                                                                            failureBlock:(void (^)(NSError *error))failureBlock{
    if (![[MKBLEBaseCentralManager shared] readyToCommunication]) {
        [self operationFailedBlockWithMsg:@"The current connection device is in disconnect" failedBlock:failureBlock];
        return nil;
    }
    if (!characteristic) {
        [self operationFailedBlockWithMsg:@"Characteristic error" failedBlock:failureBlock];
        return nil;
    }
    __weak typeof(self) weakSelf = self;
    MKTrackerOperation <MKBLEBaseOperationProtocol>*operation = [[MKTrackerOperation alloc] initOperationWithID:operationID resetNum:NO commandBlock:^{
        [[MKBLEBaseCentralManager shared].peripheral readValueForCharacteristic:characteristic];
    } completeBlock:^(NSError * _Nonnull error, mk_taskOperationID operationID, id  _Nonnull returnData) {
        __strong typeof(self) sself = weakSelf;
        if (error) {
            MKBLEBase_main_safe(^{
                if (failureBlock) {
                    failureBlock(error);
                }
            });
            return ;
        }
        if (!returnData) {
            [sself operationFailedBlockWithMsg:@"Request data error" failedBlock:failureBlock];
            return ;
        }
        NSString *lev = returnData[mk_dataStatusLev];
        if ([lev isEqualToString:@"1"]) {
            //通用无附加信息的
            NSArray *dataList = (NSArray *)returnData[mk_dataInformation];
            if (!dataList) {
                [sself operationFailedBlockWithMsg:@"Request data error" failedBlock:failureBlock];
                return;
            }
            NSDictionary *resultDic = @{@"msg":@"success",
                                        @"code":@"1",
                                        @"result":(dataList.count == 1 ? dataList[0] : dataList),
                                        };
            MKBLEBase_main_safe(^{
                if (successBlock) {
                    successBlock(resultDic);
                }
            });
            return;
        }
        //对于有附加信息的
        NSDictionary *resultDic = @{@"msg":@"success",
                                    @"code":@"1",
                                    @"result":returnData[mk_dataInformation],
                                    };
        MKBLEBase_main_safe(^{
            if (successBlock) {
                successBlock(resultDic);
            }
        });
    }];
    return operation;
}

#pragma mark - private method
- (nonnull MKTrackerModel *)parseModelWith:(NSNumber *)rssi advDic:(NSDictionary *)advDic peripheral:(CBPeripheral *)peripheral {
    if ([rssi integerValue] == 127 || !ValidDict(advDic) || !peripheral) {
        return nil;
    }
    NSData *data = advDic[@"kCBAdvDataServiceData"][[CBUUID UUIDWithString:@"FF03"]];
    if (data.length != 15) {
        return nil;
    }
    NSString *dataString = [MKBLEBaseSDKAdopter hexStringFromData:data];
    if (dataString.length != 30) {
        return nil;
    }
    MKTrackerModel *dataModel = [[MKTrackerModel alloc] init];
    dataModel.rssi = [rssi integerValue];
    dataModel.peripheral = peripheral;
    dataModel.deviceName = advDic[CBAdvertisementDataLocalNameKey];
    dataModel.deviceType = [dataString substringWithRange:NSMakeRange(0, 2)];
    dataModel.major = [MKBLEBaseSDKAdopter getDecimalWithHex:dataString range:NSMakeRange(2, 4)];
    dataModel.minor = [MKBLEBaseSDKAdopter getDecimalWithHex:dataString range:NSMakeRange(6, 4)];
    dataModel.rssi1m = [[MKBLEBaseSDKAdopter signedHexTurnString:[dataString substringWithRange:NSMakeRange(10, 2)]] integerValue];
    dataModel.txPower = [[MKBLEBaseSDKAdopter signedHexTurnString:[dataString substringWithRange:NSMakeRange(12, 2)]] integerValue];
    NSString *distance = [self calcDistByRSSI:[rssi intValue] measurePower:labs(dataModel.rssi1m)];
    dataModel.proximity = @"Unknown";
    if ([distance doubleValue] <= 0.1) {
        dataModel.proximity = @"Immediate";
    }else if ([distance doubleValue] > 0.1 && [distance doubleValue] <= 1.f){
        dataModel.proximity = @"Near";
    }else if ([distance doubleValue] > 1.f){
        dataModel.proximity = @"Far";
    }
    NSString *state = [MKBLEBaseSDKAdopter binaryByhex:[dataString substringWithRange:NSMakeRange(14, 2)]];
    dataModel.connectable = [[state substringWithRange:NSMakeRange(4, 1)] isEqualToString:@"1"];
    dataModel.track = [[state substringWithRange:NSMakeRange(5, 1)] isEqualToString:@"1"];
    dataModel.battery = [MKBLEBaseSDKAdopter getDecimalWithHex:dataString range:NSMakeRange(16, 2)];
    NSString *tempMac = [[dataString substringWithRange:NSMakeRange(18, 12)] uppercaseString];
    dataModel.macAddress = [NSString stringWithFormat:@"%@:%@:%@:%@:%@:%@",
    [tempMac substringWithRange:NSMakeRange(0, 2)],
    [tempMac substringWithRange:NSMakeRange(2, 2)],
    [tempMac substringWithRange:NSMakeRange(4, 2)],
    [tempMac substringWithRange:NSMakeRange(6, 2)],
    [tempMac substringWithRange:NSMakeRange(8, 2)],
    [tempMac substringWithRange:NSMakeRange(10, 2)]];
    return dataModel;
}

- (NSString *)calcDistByRSSI:(int)rssi measurePower:(NSInteger)measurePower{
    int iRssi = abs(rssi);
    float power = (iRssi - measurePower) / (10 * 2.0);
    return [NSString stringWithFormat:@"%.2fm",pow(10, power)];
}

- (void)operationFailedBlockWithMsg:(NSString *)message failedBlock:(void (^)(NSError *error))failedBlock {
    NSError *error = [[NSError alloc] initWithDomain:@"com.moko.trackerCentralManager"
                                                code:-999
                                            userInfo:@{@"errorInfo":message}];
    MKBLEBase_main_safe(^{
        if (failedBlock) {
            failedBlock(error);
        }
    });
}

@end
