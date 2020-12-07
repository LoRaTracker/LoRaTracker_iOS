//
//  MKTrackerInterface+MKConfig.m
//  MKContactTracker
//
//  Created by aa on 2020/4/27.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKTrackerInterface+MKConfig.h"
#import "MKBLEBaseSDKAdopter.h"
#import "MKTrackerCentralManager.h"

#import "MKTrackerOperation.h"
#import "MKTrackerAdopter.h"
#import "CBPeripheral+MKTracker.h"
#import "MKTrackerOperationID.h"

#define centralManager [MKTrackerCentralManager shared]

@implementation MKTrackerInterface (MKConfig)

+ (void)configProximityUUID:(NSString *)uuid
                   sucBlock:(void (^)(void))sucBlock
                failedBlock:(void (^)(NSError *error))failedBlock {
    if (![MKBLEBaseSDKAdopter isUUIDString:uuid]) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    uuid = [uuid stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSString *commandString = [NSString stringWithFormat:@"%@%@%@",@"ef01",@"10",uuid];
    [self addTaskWithOperationID:mk_taskConfigProximityUUIDOperation
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configMajor:(NSInteger)major
           sucBlock:(void (^)(void))sucBlock
        failedBlock:(void (^)(NSError *error))failedBlock {
    if (major < 0 || major > 65535) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *majorHex = [NSString stringWithFormat:@"%1lx",(unsigned long)major];
    if (majorHex.length == 1) {
        majorHex = [@"000" stringByAppendingString:majorHex];
    }else if (majorHex.length == 2){
        majorHex = [@"00" stringByAppendingString:majorHex];
    }else if (majorHex.length == 3){
        majorHex = [@"0" stringByAppendingString:majorHex];
    }
    NSString *commandString = [@"ef0202" stringByAppendingString:majorHex];
    [self addTaskWithOperationID:mk_taskConfigMajorOperation
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configMinor:(NSInteger)minor
           sucBlock:(void (^)(void))sucBlock
        failedBlock:(void (^)(NSError *error))failedBlock {
    if (minor < 0 || minor > 65535) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *minorHex = [NSString stringWithFormat:@"%1lx",(unsigned long)minor];
    if (minorHex.length == 1) {
        minorHex = [@"000" stringByAppendingString:minorHex];
    }else if (minorHex.length == 2){
        minorHex = [@"00" stringByAppendingString:minorHex];
    }else if (minorHex.length == 3){
        minorHex = [@"0" stringByAppendingString:minorHex];
    }
    NSString *commandString = [@"ef0302" stringByAppendingString:minorHex];
    [self addTaskWithOperationID:mk_taskConfigMinorOperation
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configMeasuredPower:(NSInteger)measuredPower
                   sucBlock:(void (^)(void))sucBlock
                failedBlock:(void (^)(NSError *error))failedBlock {
    if (measuredPower > 0 || measuredPower < -127) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *power = [MKBLEBaseSDKAdopter hexStringFromSignedNumber:measuredPower];
    NSString *commandString = [@"ef0401" stringByAppendingString:power];
    [self addTaskWithOperationID:mk_taskConfigMeasuredPowerOperation
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configTxPower:(mk_trackerTxPower)txPower
             sucBlock:(void (^)(void))sucBlock
          failedBlock:(void (^)(NSError *error))failedBlock {
    NSString *power = [self fetchTxPower:txPower];
    NSString *commandString = [@"ef0501" stringByAppendingString:power];
    [self addTaskWithOperationID:mk_taskConfigTxPowerOperation
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configAdvInterval:(NSInteger)interval
                 sucBlock:(void (^)(void))sucBlock
              failedBlock:(void (^)(NSError *error))failedBlock {
    if (interval < 1 || interval > 100) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *advInterval = [NSString stringWithFormat:@"%1lx",(unsigned long)interval];
    if (advInterval.length == 1) {
        advInterval = [@"0" stringByAppendingString:advInterval];
    }
    NSString *commandString = [@"ef0601" stringByAppendingString:advInterval];
    [self addTaskWithOperationID:mk_taskConfigAdvIntervalOperation
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configDeviceName:(NSString *)deviceName
                sucBlock:(void (^)(void))sucBlock
             failedBlock:(void (^)(NSError *error))failedBlock {
    if (!MKValidStr(deviceName) || deviceName.length < 1 || deviceName.length > 10
        || ![MKBLEBaseSDKAdopter asciiString:deviceName]) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *tempString = @"";
    for (NSInteger i = 0; i < deviceName.length; i ++) {
        int asciiCode = [deviceName characterAtIndex:i];
        tempString = [tempString stringByAppendingString:[NSString stringWithFormat:@"%1lx",(unsigned long)asciiCode]];
    }
    NSString *lenString = [NSString stringWithFormat:@"%1lx",(long)deviceName.length];
    if (lenString.length == 1) {
        lenString = [@"0" stringByAppendingString:lenString];
    }
    NSString *commandString = [NSString stringWithFormat:@"%@%@%@",@"ef07",lenString,tempString];
    [self addTaskWithOperationID:mk_taskConfigDeviceNameOperation
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configPassword:(NSString *)password
              sucBlock:(void (^)(void))sucBlock
           failedBlock:(void (^)(NSError *error))failedBlock {
    if (!MKValidStr(password) || password.length != 8) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *commandData = @"";
    for (NSInteger i = 0; i < password.length; i ++) {
        int asciiCode = [password characterAtIndex:i];
        commandData = [commandData stringByAppendingString:[NSString stringWithFormat:@"%1lx",(unsigned long)asciiCode]];
    }
    NSString *commandString = [@"ef0808" stringByAppendingString:commandData];
    [self addTaskWithOperationID:mk_taskConfigPasswordOperation
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)factoryDataResetWithSucBlock:(void (^)(void))sucBlock
                         failedBlock:(void (^)(NSError *error))failedBlock {
    [self addTaskWithOperationID:mk_taskConfigFactoryDataResetOperation
                     commandData:@"ef090101"
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configValidBLEDataFilterInterval:(NSInteger)interval
                                sucBlock:(void (^)(void))sucBlock
                             failedBlock:(void (^)(NSError *error))failedBlock {
    if (interval < 1 || interval > 600) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *intervalHex = [NSString stringWithFormat:@"%1lx",(unsigned long)interval];
    if (intervalHex.length == 1) {
        intervalHex = [@"000" stringByAppendingString:intervalHex];
    }else if (intervalHex.length == 2){
        intervalHex = [@"00" stringByAppendingString:intervalHex];
    }else if (intervalHex.length == 3){
        intervalHex = [@"0" stringByAppendingString:intervalHex];
    }
    NSString *commandString = [@"ef0a02" stringByAppendingString:intervalHex];
    [self addTaskWithOperationID:mk_taskConfigValidBLEDataFilterIntervalOperation
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configScannWindow:(mk_scannWindowType)type
                 sucBlock:(void (^)(void))sucBlock
              failedBlock:(void (^)(NSError *error))failedBlock {
    NSString *commandString = @"ef0b020001";
    if (type != mk_scannWindowTypeClose) {
        if (type == mk_scannWindowTypeOpen) {
            commandString = @"ef0b020101";
        }else if (type == mk_scannWindowTypeHalfOpen) {
            commandString = @"ef0b020102";
        }else if (type == mk_scannWindowTypeQuarterOpen) {
            commandString = @"ef0b020103";
        }else if (type == mk_scannWindowTypeOneEighthOpen) {
            commandString = @"ef0b020104";
        }
    }
    [self addTaskWithOperationID:mk_taskConfigScannWindowOperation
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configConnectableStatus:(BOOL)isOn
                       sucBlock:(void (^)(void))sucBlock
                    failedBlock:(void (^)(NSError *error))failedBlock {
    NSString *commandString = (isOn ? @"ef0c0101" : @"ef0c0100");
    [self addTaskWithOperationID:mk_taskConfigConnectableStatusOperation
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configMacFilterStatus:(BOOL)isOn
                          mac:(NSString *)mac
                     sucBlock:(void (^)(void))sucBlock
                  failedBlock:(void (^)(NSError *error))failedBlock {
    if (!isOn) {
        //关闭mac地址过滤
        [self addTaskWithOperationID:mk_taskConfigMacFilterStatusOperation
                         commandData:@"ef0d00"
                            sucBlock:sucBlock
                         failedBlock:failedBlock];
        return;
    }
    //需要校验macAddress
    mac = [mac stringByReplacingOccurrencesOfString:@" " withString:@""];
    mac = [mac stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mac = [mac stringByReplacingOccurrencesOfString:@":" withString:@""];
    if (mac.length % 2 != 0 || mac.length == 0 || mac.length > 12 || ![MKBLEBaseSDKAdopter checkHexCharacter:mac]) {
        //不是偶数报错
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSInteger len = (mac.length / 2);
    NSString *lenString = [NSString stringWithFormat:@"%1lx",(unsigned long)len];
    if (lenString.length == 1) {
        lenString = [@"0" stringByAppendingString:lenString];
    }
    NSString *commandString = [NSString stringWithFormat:@"%@%@%@",@"ef0d",lenString,mac];
    [self addTaskWithOperationID:mk_taskConfigMacFilterStatusOperation
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configFilterRssiValue:(NSInteger)rssi
                     sucBlock:(void (^)(void))sucBlock
                  failedBlock:(void (^)(NSError *error))failedBlock {
    if (rssi < -127 || rssi > 0) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *rssiValue = [MKBLEBaseSDKAdopter hexStringFromSignedNumber:rssi];
    NSString *commandString = [@"ef0e01" stringByAppendingString:rssiValue];
    [self addTaskWithOperationID:mk_taskConfigFilterRssiValueOperation
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configAdvNameFilterStatus:(BOOL)isOn
                              advName:(NSString *)advName
                         sucBlock:(void (^)(void))sucBlock
                      failedBlock:(void (^)(NSError *error))failedBlock {
    if (!isOn) {
        //关闭设备名称过滤
        [self addTaskWithOperationID:mk_taskConfigAdvNameFilterStatusOperation
                         commandData:@"ef0f00"
                            sucBlock:sucBlock
                         failedBlock:failedBlock];
        return;
    }
    if (!MKValidStr(advName) || advName.length > 10) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *tempString = @"";
    for (NSInteger i = 0; i < advName.length; i ++) {
        int asciiCode = [advName characterAtIndex:i];
        tempString = [tempString stringByAppendingString:[NSString stringWithFormat:@"%1lx",(unsigned long)asciiCode]];
    }
    NSInteger len = advName.length;
    NSString *lenString = [NSString stringWithFormat:@"%1lx",(unsigned long)len];
    if (lenString.length == 1) {
        lenString = [@"0" stringByAppendingString:lenString];
    }
    NSString *commandString = [NSString stringWithFormat:@"%@%@%@",@"ef0f",lenString,tempString];
    [self addTaskWithOperationID:mk_taskConfigAdvNameFilterStatusOperation
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configMajorFilterStatus:(BOOL)isOn
                  majorMinValue:(NSInteger)majorMinValue
                  majorMaxValue:(NSInteger)majorMaxValue
                       sucBlock:(void (^)(void))sucBlock
                    failedBlock:(void (^)(NSError *error))failedBlock {
    if (!isOn) {
        [self addTaskWithOperationID:mk_taskConfigMajorFilterStateOperation
                         commandData:@"ef1000"
                            sucBlock:sucBlock
                         failedBlock:failedBlock];
        return;
    }
    if (majorMinValue < 0 || majorMinValue > 65535
        || majorMaxValue < 0 || majorMaxValue > 65535
        || majorMinValue > majorMaxValue) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *majorMinHex = [NSString stringWithFormat:@"%1lx",(unsigned long)majorMinValue];
    if (majorMinHex.length == 1) {
        majorMinHex = [@"000" stringByAppendingString:majorMinHex];
    }else if (majorMinHex.length == 2){
        majorMinHex = [@"00" stringByAppendingString:majorMinHex];
    }else if (majorMinHex.length == 3){
        majorMinHex = [@"0" stringByAppendingString:majorMinHex];
    }
    NSString *majorMaxHex = [NSString stringWithFormat:@"%1lx",(unsigned long)majorMaxValue];
    if (majorMaxHex.length == 1) {
        majorMaxHex = [@"000" stringByAppendingString:majorMaxHex];
    }else if (majorMaxHex.length == 2){
        majorMaxHex = [@"00" stringByAppendingString:majorMaxHex];
    }else if (majorMaxHex.length == 3){
        majorMaxHex = [@"0" stringByAppendingString:majorMaxHex];
    }
    NSString *commandString = [NSString stringWithFormat:@"%@%@%@",@"ef1004",majorMinHex,majorMaxHex];
    [self addTaskWithOperationID:mk_taskConfigMajorFilterStateOperation
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configMinorFilterStatus:(BOOL)isOn
                  minorMinValue:(NSInteger)minorMinValue
                  minorMaxValue:(NSInteger)minorMaxValue
                       sucBlock:(void (^)(void))sucBlock
                    failedBlock:(void (^)(NSError *error))failedBlock {
    if (!isOn) {
        [self addTaskWithOperationID:mk_taskConfigMinorFilterStateOperation
                         commandData:@"ef1100"
                            sucBlock:sucBlock
                         failedBlock:failedBlock];
        return;
    }
    if (minorMinValue < 0 || minorMinValue > 65535
        || minorMaxValue < 0 || minorMaxValue > 65535
        || minorMinValue > minorMaxValue) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *minorMinHex = [NSString stringWithFormat:@"%1lx",(unsigned long)minorMinValue];
    if (minorMinHex.length == 1) {
        minorMinHex = [@"000" stringByAppendingString:minorMinHex];
    }else if (minorMinHex.length == 2){
        minorMinHex = [@"00" stringByAppendingString:minorMinHex];
    }else if (minorMinHex.length == 3){
        minorMinHex = [@"0" stringByAppendingString:minorMinHex];
    }
    NSString *minorMaxHex = [NSString stringWithFormat:@"%1lx",(unsigned long)minorMaxValue];
    if (minorMaxHex.length == 1) {
        minorMaxHex = [@"000" stringByAppendingString:minorMaxHex];
    }else if (minorMaxHex.length == 2){
        minorMaxHex = [@"00" stringByAppendingString:minorMaxHex];
    }else if (minorMaxHex.length == 3){
        minorMaxHex = [@"0" stringByAppendingString:minorMaxHex];
    }
    NSString *commandString = [NSString stringWithFormat:@"%@%@%@",@"ef1104",minorMinHex,minorMaxHex];
    [self addTaskWithOperationID:mk_taskConfigMinorFilterStateOperation
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configAlarmTriggerRssi:(NSInteger)rssi
                      sucBlock:(void (^)(void))sucBlock
                   failedBlock:(void (^)(NSError *error))failedBlock {
    if (rssi < -127 || rssi > 0) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *rssiValue = [MKBLEBaseSDKAdopter hexStringFromSignedNumber:rssi];
    NSString *commandString = [@"ef1201" stringByAppendingString:rssiValue];
    [self addTaskWithOperationID:mk_taskConfigAlarmTriggerRssiOperation
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configLoRaReportingInterval:(NSInteger)interval
                           sucBlock:(void (^)(void))sucBlock
                        failedBlock:(void (^)(NSError *error))failedBlock {
    if (interval < 1 || interval > 60) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *intervalHex = [NSString stringWithFormat:@"%1lx",(unsigned long)interval];
    if (intervalHex.length == 1) {
        intervalHex = [@"0" stringByAppendingString:intervalHex];
    }
    NSString *commandString = [@"ef1301" stringByAppendingString:intervalHex];
    [self addTaskWithOperationID:mk_configLoRaReportingIntervalOperation
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configAlarmNotification:(mk_alarmNotification)note
                       sucBlock:(void (^)(void))sucBlock
                    failedBlock:(void (^)(NSError *error))failedBlock {
    NSString *type = [self fetchAlarmNotification:note];
    NSString *commandString = [@"ef1401" stringByAppendingString:type];
    [self addTaskWithOperationID:mk_taskConfigAlarmNotificationOperation
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configLoraWANModem:(mk_loraWANModem)modem
                  sucBlock:(void (^)(void))sucBlock
               failedBlock:(void (^)(NSError *error))failedBlock {
    NSString *type = (modem == mk_loraWANModemABP ? @"01" : @"02");
    NSString *commandString = [@"ef1501" stringByAppendingString:type];
    [self addTaskWithOperationID:mk_configLoraWANModemOperation
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configDevEUI:(NSString *)devEUI
            sucBlock:(void (^)(void))sucBlock
         failedBlock:(void (^)(NSError *error))failedBlock {
    if (!MKValidStr(devEUI) || devEUI.length != 16 || ![MKBLEBaseSDKAdopter checkHexCharacter:devEUI]) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *commandString = [@"ef1608" stringByAppendingString:devEUI];
    [self addTaskWithOperationID:mk_configDevEUIOperation
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configAppEUI:(NSString *)appEUI
            sucBlock:(void (^)(void))sucBlock
         failedBlock:(void (^)(NSError *error))failedBlock {
    if (!MKValidStr(appEUI) || appEUI.length != 16 || ![MKBLEBaseSDKAdopter checkHexCharacter:appEUI]) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *commandString = [@"ef1708" stringByAppendingString:appEUI];
    [self addTaskWithOperationID:mk_configAppEUIOperation
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configAppKey:(NSString *)appKey
            sucBlock:(void (^)(void))sucBlock
         failedBlock:(void (^)(NSError *error))failedBlock {
    if (!MKValidStr(appKey) || appKey.length != 32 || ![MKBLEBaseSDKAdopter checkHexCharacter:appKey]) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *commandString = [@"ef1810" stringByAppendingString:appKey];
    [self addTaskWithOperationID:mk_configAppKeyOperation
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configDevAddr:(NSString *)devAddr
             sucBlock:(void (^)(void))sucBlock
          failedBlock:(void (^)(NSError *error))failedBlock {
    if (!MKValidStr(devAddr) || devAddr.length != 8 || ![MKBLEBaseSDKAdopter checkHexCharacter:devAddr]) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *commandString = [@"ef1904" stringByAppendingString:devAddr];
    [self addTaskWithOperationID:mk_configDevAddrOperation
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configAppSKey:(NSString *)appSKey
             sucBlock:(void (^)(void))sucBlock
          failedBlock:(void (^)(NSError *error))failedBlock {
    if (!MKValidStr(appSKey) || appSKey.length != 32 || ![MKBLEBaseSDKAdopter checkHexCharacter:appSKey]) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *commandString = [@"ef1a10" stringByAppendingString:appSKey];
    [self addTaskWithOperationID:mk_configAppSKeyOperation
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configNwkSKey:(NSString *)nwkSKey
             sucBlock:(void (^)(void))sucBlock
          failedBlock:(void (^)(NSError *error))failedBlock {
    if (!MKValidStr(nwkSKey) || nwkSKey.length != 32 || ![MKBLEBaseSDKAdopter checkHexCharacter:nwkSKey]) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *commandString = [@"ef1b10" stringByAppendingString:nwkSKey];
    [self addTaskWithOperationID:mk_configNwkSKeyOperation
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configRegion:(mk_loraWanRegion)region
            sucBlock:(void (^)(void))sucBlock
         failedBlock:(void (^)(NSError *error))failedBlock {
    NSString *regionValue = [self regionValue:region];
    NSString *commandString = [@"ef1c01" stringByAppendingString:regionValue];
    [self addTaskWithOperationID:mk_configRegionOperation
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configDeviceMessageType:(NSInteger)messageType
                       sucBlock:(void (^)(void))sucBlock
                    failedBlock:(void (^)(NSError *error))failedBlock {
    NSString *type = ((messageType == 1) ? @"01" : @"00");
    NSString *commandString = [@"ef1d01" stringByAppendingString:type];
    [self addTaskWithOperationID:mk_configMessageTypeOperation
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configCHValue:(NSInteger)CHLValue
             CHHValue:(NSInteger)CHHValue
             sucBlock:(void (^)(void))sucBlock
          failedBlock:(void (^)(NSError *error))failedBlock {
    if (CHHValue < 0 || CHHValue > 95 || CHLValue < 0 || CHLValue > 95 || CHHValue < CHLValue) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *lowValue = [NSString stringWithFormat:@"%1lx",(unsigned long)CHLValue];
    if (lowValue.length == 1) {
        lowValue = [@"0" stringByAppendingString:lowValue];
    }
    NSString *highValue = [NSString stringWithFormat:@"%1lx",(unsigned long)CHHValue];
    if (highValue.length == 1) {
        highValue = [@"0" stringByAppendingString:highValue];
    }
    NSString *commandString = [NSString stringWithFormat:@"%@%@%@",@"ef1e02",lowValue,highValue];
    [self addTaskWithOperationID:mk_configCHDataOperation
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configDRValue:(NSInteger)DRValue
             sucBlock:(void (^)(void))sucBlock
          failedBlock:(void (^)(NSError *error))failedBlock {
    if (DRValue < 0 || DRValue > 15) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *valueString = [NSString stringWithFormat:@"%1lx",(unsigned long)DRValue];
    if (valueString.length == 1) {
        valueString = [@"0" stringByAppendingString:valueString];
    }
    NSString *commandString = [NSString stringWithFormat:@"%@%@",@"ef1f01",valueString];
    [self addTaskWithOperationID:mk_configDRDataOperation
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configADRStatus:(BOOL)isOpen
               sucBlock:(void (^)(void))sucBlock
            failedBlock:(void (^)(NSError *error))failedBlock {
    NSString *commandString = (isOpen ? @"ef200101" : @"ef200100");
    [self addTaskWithOperationID:mk_configADRDataOperation
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configDeviceTime:(id <MKDeviceTimeProtocol>)protocol
                sucBlock:(void (^)(void))sucBlock
             failedBlock:(void (^)(NSError *error))failedBlock {
    if (![self validTimeProtocol:protocol]) {
        [MKBLEBaseSDKAdopter operationProtocolErrorBlock:failedBlock];
        return;
    }
    NSString *dateString = [self getTimeString:protocol];
    NSString *commandString = [@"ef2107" stringByAppendingString:dateString];
    [self addTaskWithOperationID:mk_taskConfigDateOperation
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configLoRaWANConnectNetWorkWithSucBlock:(void (^)(void))sucBlock
                                    failedBlock:(void (^)(NSError *error))failedBlock {
    [self addTaskWithOperationID:mk_configLoRaWANConnectNetWorkOperation
                     commandData:@"ef230101"
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)powerOffDeviceWithSucBlock:(void (^)(void))sucBlock
                       failedBlock:(void (^)(NSError *error))failedBlock {
    [self addTaskWithOperationID:mk_taskConfigPowerOffOperation
                     commandData:@"ef240101"
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configRawFilterConditions:(NSArray <id <MKRawFilterProtocol>>*)conditions
                         sucBlock:(void (^)(void))sucBlock
                      failedBlock:(void (^)(NSError *error))failedBlock {
    if (conditions.count > 5) {
        [self operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *contentData = @"";
    for (id <MKRawFilterProtocol>protocol in conditions) {
        if (![self isConfirmRawFilterProtocol:protocol]) {
            [self operationParamsErrorBlock:failedBlock];
            return;
        }
        NSString *minIndex = [NSString stringWithFormat:@"%1lx",(unsigned long)protocol.minIndex];
        if (minIndex.length == 1) {
            minIndex = [@"0" stringByAppendingString:minIndex];
        }
        NSString *maxIndex = [NSString stringWithFormat:@"%1lx",(unsigned long)protocol.maxIndex];
        if (maxIndex.length == 1) {
            maxIndex = [@"0" stringByAppendingString:maxIndex];
        }
        NSString *lenString = [NSString stringWithFormat:@"%1lx",(unsigned long)(protocol.rawData.length / 2 + 3)];
        if (lenString.length == 1) {
            lenString = [@"0" stringByAppendingString:lenString];
        }
        NSString *conditionString = [NSString stringWithFormat:@"%@%@%@%@%@",lenString,protocol.dataType,minIndex,maxIndex,protocol.rawData];
        contentData = [contentData stringByAppendingString:conditionString];
    }
    if (contentData.length == 0) {
        //关闭过滤条件
        [self addTaskWithOperationID:mk_taskConfigRawFilterOperation
                         commandData:@"ef25020100"
                            sucBlock:sucBlock
                         failedBlock:failedBlock];
        return;
    }
    //分条发送
    NSInteger totalNumber = (contentData.length / 2) / 15;
    if ((contentData.length / 2) % 15) {
        totalNumber ++;
    }
    dispatch_queue_t rawConditionsQueue = dispatch_queue_create("rawConditionsQueue", 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_async(rawConditionsQueue, ^{
        for (NSInteger i = 0; i < totalNumber; i ++) {
            BOOL first = (i == 0);
            NSInteger remainPacket = (totalNumber - 1 - i);
            NSInteger len = 30;
            if (remainPacket == 0) {
                //最后一帧数据
                len = contentData.length - i * 30;
            }
            NSString *content = [contentData substringWithRange:NSMakeRange(i * 2 * 15, len)];
            NSString *commandString = [self rawDataFirst:first remainPacket:remainPacket content:content];
            if (![self sendRawData:commandString semaphore:semaphore]) {
                [self operationSetParamsErrorBlock:failedBlock];
                return ;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (sucBlock) {
                sucBlock();
            }
        });
    });
}

+ (void)configPWM:(NSInteger)value
         sucBlock:(void (^)(void))sucBlock
      failedBlock:(void (^)(NSError *error))failedBlock {
    if (value < 0 || value > 100) {
        [MKBLEBaseSDKAdopter operationProtocolErrorBlock:failedBlock];
        return;
    }
    NSString *valueString = [NSString stringWithFormat:@"%1lx",(unsigned long)value];
    if (valueString.length == 1) {
        valueString = [@"0" stringByAppendingString:valueString];
    }
    NSString *commandString = [@"ef2701" stringByAppendingString:valueString];
    [self addTaskWithOperationID:mk_taskConfigPWMDataOperation
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configDurationOfVibration:(NSInteger)duration
                         sucBlock:(void (^)(void))sucBlock
                      failedBlock:(void (^)(NSError *error))failedBlock {
    if (duration < 0 || duration > 255) {
        [MKBLEBaseSDKAdopter operationProtocolErrorBlock:failedBlock];
        return;
    }
    NSString *valueString = [NSString stringWithFormat:@"%1lx",(unsigned long)duration];
    if (valueString.length == 1) {
        valueString = [@"0" stringByAppendingString:valueString];
    }
    NSString *commandString = [@"ef2801" stringByAppendingString:valueString];
    [self addTaskWithOperationID:mk_taskConfigDurationOfVibrationOperation
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

+ (void)configVibrationCycle:(NSInteger)cycle
                    sucBlock:(void (^)(void))sucBlock
                 failedBlock:(void (^)(NSError *error))failedBlock {
    if (cycle < 1 || cycle > 600) {
        [MKBLEBaseSDKAdopter operationProtocolErrorBlock:failedBlock];
        return;
    }
    NSString *valueString = [NSString stringWithFormat:@"%1lx",(unsigned long)cycle];
    if (valueString.length == 1) {
        valueString = [@"000" stringByAppendingString:valueString];
    }else if (valueString.length == 2) {
        valueString = [@"00" stringByAppendingString:valueString];
    }else if (valueString.length == 3) {
        valueString = [@"0" stringByAppendingString:valueString];
    }
    NSString *commandString = [@"ef2902" stringByAppendingString:valueString];
    [self addTaskWithOperationID:mk_taskConfigVibrationCycleOperation
                     commandData:commandString
                        sucBlock:sucBlock
                     failedBlock:failedBlock];
}

#pragma mark - task method
+ (void)addTaskWithOperationID:(mk_taskOperationID)operationID
                   commandData:(NSString *)commandData
                      sucBlock:(void (^)(void))sucBlock
                   failedBlock:(void (^)(NSError *error))failedBlock {
    [centralManager addTaskWithTaskID:operationID
                       characteristic:centralManager.peripheral.custom
                             resetNum:NO
                          commandData:commandData
                         successBlock:^(id  _Nonnull returnData) {
        BOOL success = [returnData[@"result"][@"result"] boolValue];
        if (!success) {
            [self operationSetParamsErrorBlock:failedBlock];
            return ;
        }
        if (sucBlock) {
            sucBlock();
        }
    }
                         failureBlock:failedBlock];
}

#pragma mark - private method
+ (BOOL)validTimeProtocol:(id <MKDeviceTimeProtocol>)protocol{
    if (![protocol conformsToProtocol:@protocol(MKDeviceTimeProtocol)]) {
        return NO;
    }
    if (protocol.year < 2000 || protocol.year > 2099) {
        return NO;
    }
    if (protocol.month < 1 || protocol.month > 12) {
        return NO;
    }
    if (protocol.day < 1 || protocol.day > 31) {
        return NO;
    }
    if (protocol.hour < 0 || protocol.hour > 23) {
        return NO;
    }
    if (protocol.minutes < 0 || protocol.minutes > 59) {
        return NO;
    }
    return YES;
}

+ (NSString *)getTimeString:(id <MKDeviceTimeProtocol>)protocol{
    
    NSString *yearString = [NSString stringWithFormat:@"%1lx",(long)protocol.year];
    if (yearString.length == 1) {
        yearString = [@"000" stringByAppendingString:yearString];
    }else if (yearString.length == 2) {
        yearString = [@"00" stringByAppendingString:yearString];
    }else if (yearString.length == 3) {
        yearString = [@"0" stringByAppendingString:yearString];
    }
    NSString *monthString = [NSString stringWithFormat:@"%1lx",(long)protocol.month];
    if (monthString.length == 1) {
        monthString = [@"0" stringByAppendingString:monthString];
    }
    NSString *dayString = [NSString stringWithFormat:@"%1lx",(long)protocol.day];
    if (dayString.length == 1) {
        dayString = [@"0" stringByAppendingString:dayString];
    }
    NSString *hourString = [NSString stringWithFormat:@"%1lx",(long)protocol.hour];
    if (hourString.length == 1) {
        hourString = [@"0" stringByAppendingString:hourString];
    }
    NSString *minString = [NSString stringWithFormat:@"%1lx",(long)protocol.minutes];
    if (minString.length == 1) {
        minString = [@"0" stringByAppendingString:minString];
    }
    NSString *secString = [NSString stringWithFormat:@"%1lx",(long)protocol.second];
    if (secString.length == 1) {
        secString = [@"0" stringByAppendingString:secString];
    }
    return [NSString stringWithFormat:@"%@%@%@%@%@%@",yearString,monthString,dayString,hourString,minString,secString];
}

+ (NSString *)fetchTxPower:(mk_trackerTxPower)txPower{
    switch (txPower) {
        case mk_trackerTxPower4dBm:
            return @"04";
            
        case mk_trackerTxPower3dBm:
            return @"03";
            
        case mk_trackerTxPower0dBm:
            return @"00";
            
        case mk_trackerTxPowerNeg4dBm:
            return @"fc";
            
        case mk_trackerTxPowerNeg8dBm:
            return @"f8";
            
        case mk_trackerTxPowerNeg12dBm:
            return @"f4";
            
        case mk_trackerTxPowerNeg16dBm:
            return @"f0";
            
        case mk_trackerTxPowerNeg20dBm:
            return @"ec";
            
        case mk_trackerTxPowerNeg40dBm:
            return @"d8";
    }
}

+ (NSString *)fetchAlarmNotification:(mk_alarmNotification)note {
    switch (note) {
        case mk_closeAlarmNotification:
            return @"00";
        case mk_ledAlarmNotification:
            return @"01";
        case mk_motorAlarmNotification:
            return @"02";
        case mk_ledMotorAlarmNotification:
            return @"03";
    }
}

+ (NSString *)regionValue:(mk_loraWanRegion)region {
    switch (region) {
        case mk_loraWanRegionEU868:
            return @"00";
        case mk_loraWanRegionUS915:
            return @"01";
        case mk_loraWanRegionUS915HYBRID:
            return @"02";
        case mk_loraWanRegionCN779:
            return @"03";
        case mk_loraWanRegionEU433:
            return @"04";
        case mk_loraWanRegionAU915:
            return @"05";
        case mk_loraWanRegionAU915OLD:
            return @"06";
        case mk_loraWanRegionCN470:
            return @"07";
        case mk_loraWanRegionAS923:
            return @"08";
        case mk_loraWanRegionKR920:
            return @"09";
        case mk_loraWanRegionIN865:
            return @"0a";
        case mk_loraWanRegionCN470PREQUEL:
            return @"0b";
        case mk_loraWanRegionSTE920:
            return @"0c";
    }
}

+ (BOOL)isConfirmRawFilterProtocol:(id <MKRawFilterProtocol>)protocol {
    if (![protocol conformsToProtocol:@protocol(MKRawFilterProtocol)]) {
        return NO;
    }
    if (!ValidStr(protocol.dataType) || protocol.dataType.length != 2 || ![protocol.dataType regularExpressions:isHexadecimal]) {
        return NO;
    }
    NSArray *typeList = [self rawDataTypeList];
    if (![typeList containsObject:[protocol.dataType uppercaseString]]) {
        return NO;
    }
    if (protocol.minIndex == 0 && protocol.maxIndex == 0) {
        if (!ValidStr(protocol.rawData) || protocol.rawData.length > 58 || ![protocol.rawData regularExpressions:isHexadecimal] || (protocol.rawData.length % 2 != 0)) {
            return NO;
        }
        return YES;
    }
    if (protocol.minIndex < 0 || protocol.minIndex > 29 || protocol.maxIndex < 0 || protocol.maxIndex > 29) {
        return NO;
    }
    
    if (protocol.maxIndex < protocol.minIndex) {
        return NO;
    }
    if (!ValidStr(protocol.rawData) || protocol.rawData.length > 58 || ![protocol.rawData regularExpressions:isHexadecimal]) {
        return NO;
    }
    NSInteger totalLen = (protocol.maxIndex - protocol.minIndex + 1) * 2;
    if (protocol.rawData.length != totalLen) {
        return NO;
    }
    return YES;
}

+ (NSArray *)rawDataTypeList {
    return @[@"01",@"02",@"03",@"04",@"05",
             @"06",@"07",@"08",@"09",@"0A",
             @"0D",@"0E",@"0F",@"10",@"11",
             @"12",@"14",@"15",@"16",@"17",
             @"18",@"19",@"1A",@"1B",@"1C",
             @"1D",@"1E",@"1F",@"20",@"21",
             @"22",@"23",@"24",@"25",@"26",
             @"27",@"28",@"29",@"2A",@"2B",
             @"2C",@"2D",@"3D",@"FF"];
}

+ (NSString *)rawDataFirst:(BOOL)first
              remainPacket:(NSInteger)remainPacket
                   content:(NSString *)content {
    NSString *lenString = [NSString stringWithFormat:@"%1lx",(unsigned long)((content.length / 2) + 2)];
    if (lenString.length == 1) {
        lenString = [@"0" stringByAppendingString:lenString];
    }
    NSString *remain = [NSString stringWithFormat:@"%1lx",(unsigned long)remainPacket];
    if (remain.length == 1) {
        remain = [@"0" stringByAppendingString:remain];
    }
    NSString *commandString = [NSString stringWithFormat:@"ef25%@%@%@%@",lenString,(first ? @"01" : @"00"),remain,content];
    return commandString;
}

+ (BOOL)sendRawData:(NSString *)commandString semaphore:(dispatch_semaphore_t)semaphore {
    __block BOOL success = NO;
    [self addTaskWithOperationID:mk_taskConfigRawFilterOperation commandData:commandString sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(semaphore);
    } failedBlock:^(NSError *error) {
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

+ (void)operationParamsErrorBlock:(void (^)(NSError *error))block {
    MKBLEBase_main_safe(^{
        if (block) {
            NSError *error = [MKBLEBaseSDKAdopter getErrorWithCode:-999 message:@"Params error"];
            block(error);
        }
    });
}

+ (void)operationSetParamsErrorBlock:(void (^)(NSError *error))block{
    MKBLEBase_main_safe(^{
        if (block) {
            NSError *error = [MKBLEBaseSDKAdopter getErrorWithCode:-10001 message:@"Set parameter error"];
            block(error);
        }
    });
}

@end
