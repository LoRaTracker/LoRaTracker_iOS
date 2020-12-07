//
//  MKTrackerInterface.m
//  MKContactTracker
//
//  Created by aa on 2020/4/27.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKTrackerInterface.h"
#import "MKTrackerCentralManager.h"

#import "MKTrackerOperation.h"
#import "MKTrackerAdopter.h"
#import "CBPeripheral+MKTracker.h"
#import "MKTrackerOperationID.h"

#define centralManager [MKTrackerCentralManager shared]

@implementation MKTrackerInterface

+ (void)readBatteryPowerWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                         failedBlock:(nonnull void (^)(NSError *error))failedBlock {
    [centralManager addReadTaskWithTaskID:mk_taskReadBatteryPowerOperation
                           characteristic:centralManager.peripheral.batteryPower
                             successBlock:sucBlock
                             failureBlock:failedBlock];
}

+ (void)readManufacturerWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                         failedBlock:(nonnull void (^)(NSError *error))failedBlock {
    [centralManager addReadTaskWithTaskID:mk_taskReadManufacturerOperation
                           characteristic:centralManager.peripheral.manufacturer
                             successBlock:sucBlock
                             failureBlock:failedBlock];
}

+ (void)readDeviceModelWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                        failedBlock:(nonnull void (^)(NSError *error))failedBlock {
    [centralManager addReadTaskWithTaskID:mk_taskReadDeviceModelOperation
                           characteristic:centralManager.peripheral.deviceModel
                             successBlock:sucBlock
                             failureBlock:failedBlock];
}

+ (void)readHardwareWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                     failedBlock:(nonnull void (^)(NSError *error))failedBlock {
    [centralManager addReadTaskWithTaskID:mk_taskReadHardwareOperation
                           characteristic:centralManager.peripheral.hardware
                             successBlock:sucBlock
                             failureBlock:failedBlock];
}

+ (void)readSoftwareWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                     failedBlock:(nonnull void (^)(NSError *error))failedBlock {
    [centralManager addReadTaskWithTaskID:mk_taskReadSoftwareOperation
                           characteristic:centralManager.peripheral.sofeware
                             successBlock:sucBlock
                             failureBlock:failedBlock];
}

+ (void)readFirmwareWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                     failedBlock:(nonnull void (^)(NSError *error))failedBlock {
    [centralManager addReadTaskWithTaskID:mk_taskReadFirmwareOperation
                           characteristic:centralManager.peripheral.firmware
                             successBlock:sucBlock
                             failureBlock:failedBlock];
}

+ (void)readProximityUUIDWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                          failedBlock:(nonnull void (^)(NSError *error))failedBlock {
    [self addTaskWithID:mk_taskReadProximityUUIDOperation
            commandData:@"ed01ed"
               sucBlock:sucBlock
            failedBlock:failedBlock];
}

+ (void)readMajorWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                  failedBlock:(nonnull void (^)(NSError *error))failedBlock {
    [self addTaskWithID:mk_taskReadMajorOperation
            commandData:@"ed02ed"
               sucBlock:sucBlock
            failedBlock:failedBlock];
}

+ (void)readMinorWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                  failedBlock:(nonnull void (^)(NSError *error))failedBlock {
    [self addTaskWithID:mk_taskReadMinorOperation
            commandData:@"ed03ed"
               sucBlock:sucBlock
            failedBlock:failedBlock];
}

+ (void)readMeasurePowerWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                         failedBlock:(nonnull void (^)(NSError *error))failedBlock {
    [self addTaskWithID:mk_taskReadMeasuredPowerOperation
            commandData:@"ed04ed"
               sucBlock:sucBlock
            failedBlock:failedBlock];
}

+ (void)readTxPowerWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                    failedBlock:(nonnull void (^)(NSError *error))failedBlock {
    [self addTaskWithID:mk_taskReadTxPowerOperation
            commandData:@"ed05ed"
               sucBlock:sucBlock
            failedBlock:failedBlock];
}

+ (void)readAdvIntervalWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                        failedBlock:(nonnull void (^)(NSError *error))failedBlock {
    [self addTaskWithID:mk_taskReadBroadcastIntervalOperation
            commandData:@"ed06ed"
               sucBlock:sucBlock
            failedBlock:failedBlock];
}

+ (void)readAdvNameWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                    failedBlock:(nonnull void (^)(NSError *error))failedBlock {
    [self addTaskWithID:mk_taskReadDeviceNameOperation
            commandData:@"ed07ed"
               sucBlock:sucBlock
            failedBlock:failedBlock];
}

+ (void)readValidBLEDataFilterIntervalWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                                       failedBlock:(nonnull void (^)(NSError *error))failedBlock {
    [self addTaskWithID:mk_taskReadValidBLEDataFilterIntervalOperation
            commandData:@"ed0aed"
               sucBlock:sucBlock
            failedBlock:failedBlock];
}

+ (void)readScanWindowDataWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                           failedBlock:(nonnull void (^)(NSError *error))failedBlock {
    [self addTaskWithID:mk_taskReadScanWindowDataOperation
            commandData:@"ed0bed"
               sucBlock:sucBlock
            failedBlock:failedBlock];
}


+ (void)readConnectableWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                        failedBlock:(nonnull void (^)(NSError *error))failedBlock {
    [self addTaskWithID:mk_taskReadConnectableStatusOperation
            commandData:@"ed0ced"
               sucBlock:sucBlock
            failedBlock:failedBlock];
}

+ (void)readMacAddressFilterStatusWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                                   failedBlock:(nonnull void (^)(NSError *error))failedBlock {
    [self addTaskWithID:mk_taskReadMacFilterStatusOperation
            commandData:@"ed0ded"
               sucBlock:sucBlock
            failedBlock:failedBlock];
}

+ (void)readFilterRssiValueWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                            failedBlock:(nonnull void (^)(NSError *error))failedBlock {
    [self addTaskWithID:mk_taskReadFilterRssiValueOperation
            commandData:@"ed0eed"
               sucBlock:sucBlock
            failedBlock:failedBlock];
}

+ (void)readAdvNameFilterStatusWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                                failedBlock:(nonnull void (^)(NSError *error))failedBlock {
    [self addTaskWithID:mk_taskReadAdvNameFilterStatusOperation
            commandData:@"ed0fed"
               sucBlock:sucBlock
            failedBlock:failedBlock];
}

+ (void)readMajorFilterStateWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                             failedBlock:(nonnull void (^)(NSError *error))failedBlock {
    [self addTaskWithID:mk_taskReadMajorFilterStateOperation
            commandData:@"ed10ed"
               sucBlock:sucBlock
            failedBlock:failedBlock];
}

+ (void)readMinorFilterStateWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                             failedBlock:(nonnull void (^)(NSError *error))failedBlock {
    [self addTaskWithID:mk_taskReadMinorFilterStateOperation
            commandData:@"ed11ed"
               sucBlock:sucBlock
            failedBlock:failedBlock];
}

+ (void)readAlarmTriggerRssiWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                             failedBlock:(nonnull void (^)(NSError *error))failedBlock {
    [self addTaskWithID:mk_taskReadAlarmTriggerRssiOperation
            commandData:@"ed12ed"
               sucBlock:sucBlock
            failedBlock:failedBlock];
}

+ (void)readLoRaReportingIntervalWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                                  failedBlock:(nonnull void (^)(NSError *error))failedBlock {
    [self addTaskWithID:mk_taskReadLoRaReportingIntervalOperation
            commandData:@"ed13ed"
               sucBlock:sucBlock
            failedBlock:failedBlock];
}

+ (void)readAlarmNotificationWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                              failedBlock:(nonnull void (^)(NSError *error))failedBlock {
    [self addTaskWithID:mk_taskReadAlarmNotificationOperation
            commandData:@"ed14ed"
               sucBlock:sucBlock
            failedBlock:failedBlock];
}

+ (void)readLoraWANModemWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                         failedBlock:(nonnull void (^)(NSError *error))failedBlock {
    [self addTaskWithID:mk_taskReadLoraWANModemOperation
            commandData:@"ed15ed"
               sucBlock:sucBlock
            failedBlock:failedBlock];
}

+ (void)readDevEUIWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                   failedBlock:(nonnull void (^)(NSError *error))failedBlock {
    [self addTaskWithID:mk_taskReadDevEUIOperation
            commandData:@"ed16ed"
               sucBlock:sucBlock
            failedBlock:failedBlock];
}

+ (void)readAPPEUIWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                   failedBlock:(nonnull void (^)(NSError *error))failedBlock {
    [self addTaskWithID:mk_taskReadAPPEUIOperation
            commandData:@"ed17ed"
               sucBlock:sucBlock
            failedBlock:failedBlock];
}

+ (void)readAppKeyWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                   failedBlock:(nonnull void (^)(NSError *error))failedBlock {
    [self addTaskWithID:mk_taskReadAPPKeyOperation
            commandData:@"ed18ed"
               sucBlock:sucBlock
            failedBlock:failedBlock];
}

+ (void)readDevAddrWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                    failedBlock:(nonnull void (^)(NSError *error))failedBlock {
    [self addTaskWithID:mk_taskReadDevAddrOperation
            commandData:@"ed19ed"
               sucBlock:sucBlock
            failedBlock:failedBlock];
}

+ (void)readAPPSKeyWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                    failedBlock:(nonnull void (^)(NSError *error))failedBlock {
    [self addTaskWithID:mk_taskReadAPPSKeyOperation
            commandData:@"ed1aed"
               sucBlock:sucBlock
            failedBlock:failedBlock];
}

+ (void)readNwkSKeyWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                    failedBlock:(nonnull void (^)(NSError *error))failedBlock {
    [self addTaskWithID:mk_taskReadNwkSKeyOperation
            commandData:@"ed1bed"
               sucBlock:sucBlock
            failedBlock:failedBlock];
}

+ (void)readRegionWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                   failedBlock:(nonnull void (^)(NSError *error))failedBlock {
    [self addTaskWithID:mk_taskReadRegionOperation
            commandData:@"ed1ced"
               sucBlock:sucBlock
            failedBlock:failedBlock];
}

+ (void)readMessageTypeWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                        failedBlock:(nonnull void (^)(NSError *error))failedBlock {
    [self addTaskWithID:mk_taskReadLoRaMessageTypeOperation
            commandData:@"ed1ded"
               sucBlock:sucBlock
            failedBlock:failedBlock];
}

+ (void)readCHDataWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                   failedBlock:(nonnull void (^)(NSError *error))failedBlock {
    [self addTaskWithID:mk_taskReadCHDataOperation
            commandData:@"ed1eed"
               sucBlock:sucBlock
            failedBlock:failedBlock];
}

+ (void)readDRDataWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                   failedBlock:(nonnull void (^)(NSError *error))failedBlock {
    [self addTaskWithID:mk_taskReadDRDataOperation
            commandData:@"ed1fed"
               sucBlock:sucBlock
            failedBlock:failedBlock];
}

+ (void)readADRStatusWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                      failedBlock:(nonnull void (^)(NSError *error))failedBlock {
    [self addTaskWithID:mk_taskReadADRDataOperation
            commandData:@"ed20ed"
               sucBlock:sucBlock
            failedBlock:failedBlock];
}

+ (void)readLoRaNetworkStatusWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                              failedBlock:(nonnull void (^)(NSError *error))failedBlock {
    [self addTaskWithID:mk_taskReadLoRaNetworkStatusOperation
            commandData:@"ed22ed"
               sucBlock:sucBlock
            failedBlock:failedBlock];
}

+ (void)readMacaddressWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                       failedBlock:(nonnull void (^)(NSError *error))failedBlock {
    [self addTaskWithID:mk_taskReadMacAddressOperation
            commandData:@"ed23ed"
               sucBlock:sucBlock
            failedBlock:failedBlock];
}

+ (void)readFilterRawDatasWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                           failedBlock:(nonnull void (^)(NSError *error))failedBlock {
    [centralManager addTaskWithTaskID:mk_taskReadFilterRawDatasOperation
                       characteristic:centralManager.peripheral.custom
                             resetNum:YES
                          commandData:@"ed25ed"
                         successBlock:^(id  _Nonnull returnData) {
        if (sucBlock) {
            sucBlock([self parseFilterRawDatas:returnData[@"result"]]);
        }
    } failureBlock:failedBlock];
}

+ (void)readPWMDatasWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                     failedBlock:(nonnull void (^)(NSError *error))failedBlock {
    [self addTaskWithID:mk_taskReadPWMDataOperation
            commandData:@"ed27ed"
               sucBlock:sucBlock
            failedBlock:failedBlock];
}

+ (void)readDurationOfVibrationWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                                failedBlock:(nonnull void (^)(NSError *error))failedBlock {
    [self addTaskWithID:mk_taskReadDurationOfVibrationOperation
            commandData:@"ed28ed"
               sucBlock:sucBlock
            failedBlock:failedBlock];
}

+ (void)readVibrationCycleWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                           failedBlock:(nonnull void (^)(NSError *error))failedBlock {
    [self addTaskWithID:mk_taskReadVibrationCycleOperation
            commandData:@"ed29ed"
               sucBlock:sucBlock
            failedBlock:failedBlock];
}

#pragma mark - Private method
+ (void)addTaskWithID:(mk_taskOperationID)taskID
          commandData:(NSString *)commandData
             sucBlock:(void (^)(id returnData))sucBlock
          failedBlock:(void (^)(NSError *error))failedBlock {
    [centralManager addTaskWithTaskID:taskID
                       characteristic:centralManager.peripheral.custom
                             resetNum:NO
                          commandData:commandData
                         successBlock:sucBlock
                         failureBlock:failedBlock];
}

+ (NSDictionary *)parseFilterRawDatas:(NSArray <NSDictionary *>*)dataList {
    if (!MKValidArray(dataList)) {
        return @{
            @"code":@"1",
            @"msg":@"success",
            @"result":@{
                    @"filterList":@[],
            },
        };
    }
    NSString *content = @"";
    for (NSDictionary *dic in dataList) {
        if (MKValidStr(dic[@"rawData"])) {
            content = [content stringByAppendingString:dic[@"rawData"]];
        }
    }
    NSInteger subIndex = 0;
    NSMutableArray *filterList = [NSMutableArray array];
    //最多五条过滤数据
    for (NSInteger i = 0; i < 5; i ++) {
        NSInteger index0Len = [MKBLEBaseSDKAdopter getDecimalWithHex:content range:NSMakeRange(subIndex, 2)];
        NSString *index0Data = [content substringWithRange:NSMakeRange(subIndex + 2, index0Len * 2)];
        
        NSDictionary *index0Dic = @{
            @"dataType":[index0Data substringWithRange:NSMakeRange(0, 2)],
            @"minIndex":[MKBLEBaseSDKAdopter getDecimalStringWithHex:index0Data range:NSMakeRange(2, 2)],
            @"maxIndex":[MKBLEBaseSDKAdopter getDecimalStringWithHex:index0Data range:NSMakeRange(4, 2)],
            @"rawData":[index0Data substringFromIndex:6],
            @"index":@(i),
        };
        [filterList addObject:index0Dic];
        subIndex += (index0Data.length + 2);
        if (subIndex >= content.length) {
            break;
        }
    }
    return @{
        @"code":@"1",
        @"msg":@"success",
        @"result":@{
                @"filterList":filterList,
        },
    };
}

@end
