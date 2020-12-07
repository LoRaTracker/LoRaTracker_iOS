//
//  MKTrackerOperationDataAdopter.m
//  MKBLEBaseModule_Example
//
//  Created by aa on 2019/11/19.
//  Copyright © 2019 aadyx2007@163.com. All rights reserved.
//

#import "MKTrackerOperationDataAdopter.h"
#import <CoreBluetooth/CoreBluetooth.h>

#import "MKBLEBaseSDKAdopter.h"
#import "MKBLEBaseSDKDefines.h"
#import "MKTrackerSDKDefines.h"

#import "MKTrackerOperationID.h"

NSString *const mk_communicationDataNum = @"mk_communicationDataNum";

@implementation MKTrackerOperationDataAdopter

+ (NSDictionary *)parseReadDataWithCharacteristic:(CBCharacteristic *)characteristic {
    NSData *readData = characteristic.value;
    NSLog(@"+++++%@-----%@",characteristic.UUID.UUIDString,readData);
    if ([characteristic.UUID isEqual:MKUUID(@"2A00")]) {
        //设备名称
        NSString *tempString = [[NSString alloc] initWithData:readData encoding:NSUTF8StringEncoding];
        return [self dataParserGetDataSuccess:@{@"deviceName":tempString} operationID:mk_taskReadDeviceNameOperation];
    }
    if ([characteristic.UUID isEqual:MKUUID(@"2A19")]) {
        //电池电量
        NSString *content = [MKBLEBaseSDKAdopter hexStringFromData:readData];
        NSString *battery = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(0, content.length)];
        return [self dataParserGetDataSuccess:@{@"batteryPower":battery} operationID:mk_taskReadBatteryPowerOperation];
    }
    if ([characteristic.UUID isEqual:MKUUID(@"2A24")]) {
        //产品型号
        NSString *tempString = [[NSString alloc] initWithData:readData encoding:NSUTF8StringEncoding];
        return [self dataParserGetDataSuccess:@{@"modeID":tempString} operationID:mk_taskReadDeviceModelOperation];
    }
    if ([characteristic.UUID isEqual:MKUUID(@"2A26")]) {
        //firmware
        NSString *tempString = [[NSString alloc] initWithData:readData encoding:NSUTF8StringEncoding];
        return [self dataParserGetDataSuccess:@{@"firmware":tempString} operationID:mk_taskReadFirmwareOperation];
    }
    if ([characteristic.UUID isEqual:MKUUID(@"2A27")]) {
        //hardware
        NSString *tempString = [[NSString alloc] initWithData:readData encoding:NSUTF8StringEncoding];
        return [self dataParserGetDataSuccess:@{@"hardware":tempString} operationID:mk_taskReadHardwareOperation];
    }
    if ([characteristic.UUID isEqual:MKUUID(@"2A28")]) {
        //soft ware
        NSString *tempString = [[NSString alloc] initWithData:readData encoding:NSUTF8StringEncoding];
        return [self dataParserGetDataSuccess:@{@"software":tempString} operationID:mk_taskReadSoftwareOperation];
    }
    if ([characteristic.UUID isEqual:MKUUID(@"2A29")]) {
        //manufacturerKey
        NSString *tempString = [[NSString alloc] initWithData:readData encoding:NSUTF8StringEncoding];
        return [self dataParserGetDataSuccess:@{@"manufacturer":tempString} operationID:mk_taskReadManufacturerOperation];
    }
    if ([characteristic.UUID isEqual:MKUUID(@"FF00")]) {
        //密码验证
        NSString *content = [MKBLEBaseSDKAdopter hexStringFromData:readData];
        return [self dataParserGetDataSuccess:@{@"state":content} operationID:mk_taskConfigPasswordOperation];
    }
    if ([characteristic.UUID isEqual:MKUUID(@"FF02")]) {
        //custom
        return [self parseFF02Data:readData];
    }
    if ([characteristic.UUID isEqual:MKUUID(@"FF08")]) {
        //当前设备状态，解锁或者修改密码或者锁定状态
        NSString *content = [MKBLEBaseSDKAdopter hexStringFromData:readData];
        return [self dataParserGetDataSuccess:@{@"state":content} operationID:mk_taskConfigPasswordOperation];
    }
    return @{};
}

+ (NSDictionary *)parseWriteDataWithCharacteristic:(CBCharacteristic *)characteristic {
    return @{};
}

#pragma mark -
+ (NSDictionary *)parseFF02Data:(NSData *)characteristicData {
    NSString *content = [MKBLEBaseSDKAdopter hexStringFromData:characteristicData];
    if (content.length < 6) {
        return @{};
    }
    NSInteger len = [MKBLEBaseSDKAdopter getDecimalWithHex:content range:NSMakeRange(4, 2)];
    if (content.length != 2 * len + 6) {
        return @{};
    }
    NSString *header = [content substringWithRange:NSMakeRange(0, 2)];
    if (![header isEqualToString:@"ed"] && ![header isEqualToString:@"ef"]) {
        return @{};
    }
    
    NSString *function = [content substringWithRange:NSMakeRange(2, 2)];
    if ([header isEqualToString:@"ed"]) {
        //读取数据
        return [self parserEDDatas:characteristicData dataLen:len function:function];
    }
    //设置数据
    BOOL result = [[content substringWithRange:NSMakeRange(6, 2)] isEqualToString:@"01"];
    return [self parseEFDatas:result function:function];
}

+ (NSDictionary *)parseEFDatas:(BOOL)success function:(NSString *)function {
    mk_taskOperationID operationID = mk_defaultTaskOperationID;
    if ([function isEqualToString:@"01"]) {
        //设置UUID
        operationID = mk_taskConfigProximityUUIDOperation;
    }else if ([function isEqualToString:@"02"]) {
        //设置Major
        operationID = mk_taskConfigMajorOperation;
    }else if ([function isEqualToString:@"03"]) {
        //设置Minor
        operationID = mk_taskConfigMinorOperation;
    }else if ([function isEqualToString:@"04"]) {
        //设置Measured Power(RSSI@1M)
        operationID = mk_taskConfigMeasuredPowerOperation;
    }else if ([function isEqualToString:@"05"]) {
        //设置Tx Power
        operationID = mk_taskConfigTxPowerOperation;
    }else if ([function isEqualToString:@"06"]) {
        //设置广播间隔
        operationID = mk_taskConfigAdvIntervalOperation;
    }else if ([function isEqualToString:@"07"]) {
        //设置设备名称
        operationID = mk_taskConfigDeviceNameOperation;
    }else if ([function isEqualToString:@"08"]) {
        //设置密码
        operationID = mk_taskConfigPasswordOperation;
    }else if ([function isEqualToString:@"09"]) {
        //恢复出厂设置
        operationID = mk_taskConfigFactoryDataResetOperation;
    }else if ([function isEqualToString:@"0a"]) {
        //设置扫描有效数据筛选间隔
        operationID = mk_taskConfigValidBLEDataFilterIntervalOperation;
    }else if ([function isEqualToString:@"0b"]) {
        //设置扫描开关与扫描窗口
        operationID = mk_taskConfigScannWindowOperation;
    }else if ([function isEqualToString:@"0c"]) {
        //设置设备蓝牙可连接状态
        operationID = mk_taskConfigConnectableStatusOperation;
    }else if ([function isEqualToString:@"0d"]) {
        //设置设备过滤Mac地址
        operationID = mk_taskConfigMacFilterStatusOperation;
    }else if ([function isEqualToString:@"0e"]) {
        //设置设备过滤Rssi
        operationID = mk_taskConfigFilterRssiValueOperation;
    }else if ([function isEqualToString:@"0f"]) {
        //设置设备过滤设备名称
        operationID = mk_taskConfigAdvNameFilterStatusOperation;
    }else if ([function isEqualToString:@"10"]) {
        //设置设备过滤Major范围
        operationID = mk_taskConfigMajorFilterStateOperation;
    }else if ([function isEqualToString:@"11"]) {
        //设置设备过滤Minor范围
        operationID = mk_taskConfigMinorFilterStateOperation;
    }else if ([function isEqualToString:@"12"]) {
        //设置报警RSSI值
        operationID = mk_taskConfigAlarmTriggerRssiOperation;
    }else if ([function isEqualToString:@"13"]) {
        //设置LoRa上报数据间隔
        operationID = mk_configLoRaReportingIntervalOperation;
    }else if ([function isEqualToString:@"14"]) {
        //设置报警提醒功能
        operationID = mk_taskConfigAlarmNotificationOperation;
    }else if ([function isEqualToString:@"15"]) {
        //设置lora入网类型modem
        operationID = mk_configLoraWANModemOperation;
    }else if ([function isEqualToString:@"16"]) {
        //设置lora的DevEUI
        operationID = mk_configDevEUIOperation;
    }else if ([function isEqualToString:@"17"]) {
        //设置lora的AppEUI
        operationID = mk_configAppEUIOperation;
    }else if ([function isEqualToString:@"18"]) {
        //设置lora的AppKey
        operationID = mk_configAppKeyOperation;
    }else if ([function isEqualToString:@"19"]) {
        //设置lora的DevAddr
        operationID = mk_configDevAddrOperation;
    }else if ([function isEqualToString:@"1a"]) {
        //设置lora的AppSKey
        operationID = mk_configAppSKeyOperation;
    }else if ([function isEqualToString:@"1b"]) {
        //设置lora的AppSKey
        operationID = mk_configNwkSKeyOperation;
    }else if ([function isEqualToString:@"1c"]) {
        //设置lora的Region
        operationID = mk_configRegionOperation;
    }else if ([function isEqualToString:@"1d"]) {
        //设置lora的Message Type
        operationID = mk_configMessageTypeOperation;
    }else if ([function isEqualToString:@"1e"]) {
        //设置lora的CH
        operationID = mk_configCHDataOperation;
    }else if ([function isEqualToString:@"1f"]) {
        //设置lora的DR
        operationID = mk_configDRDataOperation;
    }else if ([function isEqualToString:@"20"]) {
        //设置lora的ADR
        operationID = mk_configADRDataOperation;
    }else if ([function isEqualToString:@"21"]) {
        //设置时间
        operationID = mk_taskConfigDateOperation;
    }else if ([function isEqualToString:@"23"]) {
        //入网请求
        operationID = mk_configLoRaWANConnectNetWorkOperation;
    }else if ([function isEqualToString:@"24"]) {
        //设备关机
        operationID = mk_taskConfigPowerOffOperation;
    }else if ([function isEqualToString:@"25"]) {
        //设备过滤的RawData
        operationID = mk_taskConfigRawFilterOperation;
    }else if ([function isEqualToString:@"27"]) {
        //设备PWM占空比
        operationID = mk_taskConfigPWMDataOperation;
    }else if ([function isEqualToString:@"28"]) {
        //设备马达震动时长
        operationID = mk_taskConfigDurationOfVibrationOperation;
    }else if ([function isEqualToString:@"29"]) {
        //设备马达周期时长
        operationID = mk_taskConfigVibrationCycleOperation;
    }
    return [self dataParserGetDataSuccess:@{@"result":@(success)} operationID:operationID];
}

+ (NSDictionary *)parserEDDatas:(NSData *)characteristicData dataLen:(NSInteger)len function:(NSString *)function {
    NSString *content = [MKBLEBaseSDKAdopter hexStringFromData:characteristicData];
    NSDictionary *returnDic = @{};
    mk_taskOperationID operationID = mk_defaultTaskOperationID;
    if ([function isEqualToString:@"01"]) {
        //uuid
        NSMutableArray *array = [NSMutableArray arrayWithObjects:[content substringWithRange:NSMakeRange(6, 8)],
                                 [content substringWithRange:NSMakeRange(14, 4)],
                                 [content substringWithRange:NSMakeRange(18, 4)],
                                 [content substringWithRange:NSMakeRange(22,4)],
                                 [content substringWithRange:NSMakeRange(26, 12)], nil];
        [array insertObject:@"-" atIndex:1];
        [array insertObject:@"-" atIndex:3];
        [array insertObject:@"-" atIndex:5];
        [array insertObject:@"-" atIndex:7];
        NSString *uuid = @"";
        for (NSString *string in array) {
            uuid = [uuid stringByAppendingString:string];
        }
        returnDic = @{@"uuid":[uuid uppercaseString]};
        operationID = mk_taskReadProximityUUIDOperation;
    }else if ([function isEqualToString:@"02"]) {
        //Major
        NSString *major = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(6, 4)];
        returnDic = @{@"major":major};
        operationID = mk_taskReadMajorOperation;
    }else if ([function isEqualToString:@"03"]) {
        //Minor
        NSString *minor = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(6, 4)];
        returnDic = @{@"minor":minor};
        operationID = mk_taskReadMinorOperation;
    }else if ([function isEqualToString:@"04"]) {
        //RSSI@1M
        NSString *measuredPower = [NSString stringWithFormat:@"%ld",(long)[[MKBLEBaseSDKAdopter signedHexTurnString:[content substringWithRange:NSMakeRange(6, 2)]] integerValue]];
        returnDic = @{@"measuredPower":measuredPower};
        operationID = mk_taskReadMeasuredPowerOperation;
    }else if ([function isEqualToString:@"05"]) {
        //txPower
        returnDic = @{@"txPower":[self fetchTxPower:[content substringWithRange:NSMakeRange(6, 2)]]};
        operationID = mk_taskReadTxPowerOperation;
    }else if ([function isEqualToString:@"06"]) {
        //adv interval
        NSString *interval = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(6, 2)];
        returnDic = @{@"interval":interval};
        operationID = mk_taskReadBroadcastIntervalOperation;
    }else if ([function isEqualToString:@"07"]) {
        NSString *tempString = [[NSString alloc] initWithData:[characteristicData subdataWithRange:NSMakeRange(3, len)]
                                                     encoding:NSUTF8StringEncoding];
        returnDic = @{@"deviceName":tempString};
        operationID = mk_taskReadDeviceNameOperation;
    }else if ([function isEqualToString:@"0a"]) {
        //扫描有效数据筛选间隔
        NSString *interval = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(6, 4)];
        returnDic = @{@"interval":interval};
        operationID = mk_taskReadValidBLEDataFilterIntervalOperation;
    }else if ([function isEqualToString:@"0b"]) {
        //读取开关与扫描窗口
        BOOL isOn = [[content substringWithRange:NSMakeRange(6, 2)] isEqualToString:@"01"];
        NSString *value = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(8, 2)];
        returnDic = @{
            @"isOn":@(isOn),
            @"value":value,
        };
        operationID = mk_taskReadScanWindowDataOperation;
    }else if ([function isEqualToString:@"0c"]) {
        //读取可连接状态
        BOOL isOn = [[content substringWithRange:NSMakeRange(6, 2)] isEqualToString:@"01"];
        returnDic = @{@"isOn":@(isOn)};
        operationID = mk_taskReadConnectableStatusOperation;
    }else if ([function isEqualToString:@"0d"]) {
        //读取过滤Mac地址
        BOOL isOn = (len > 0);
        NSString *mac = @"";
        if (isOn) {
            mac = [content substringWithRange:NSMakeRange(6, len * 2)];
        }
        returnDic = @{
            @"isOn":@(isOn),
            @"filterMac":mac
        };
        operationID = mk_taskReadMacFilterStatusOperation;
    }else if ([function isEqualToString:@"0e"]) {
        //读取过滤的RSSI
        NSString *rssi = [NSString stringWithFormat:@"%ld",(long)[[MKBLEBaseSDKAdopter signedHexTurnString:[content substringWithRange:NSMakeRange(6, 2)]] integerValue]];
        returnDic = @{@"rssi":rssi};
        operationID = mk_taskReadFilterRssiValueOperation;
    }else if ([function isEqualToString:@"0f"]) {
        //读取过滤设备名称
        BOOL isOn = (len > 0);
        NSString *advName = @"";
        if (isOn) {
            advName = [[NSString alloc] initWithData:[characteristicData subdataWithRange:NSMakeRange(3, len)] encoding:NSUTF8StringEncoding];
        }
        if (!advName) {
            advName = @"";
        }
        returnDic = @{
            @"isOn":@(isOn),
            @"advName":advName
        };
        operationID = mk_taskReadAdvNameFilterStatusOperation;
    }else if ([function isEqualToString:@"10"]) {
        //读取过滤Major范围
        BOOL isOn = (len > 0);
        NSString *majorMinValue = @"";
        NSString *majorMaxValue = @"";
        if (isOn) {
            majorMinValue = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(6, 4)];
            majorMaxValue = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(10, 4)];
        }
        returnDic = @{
            @"isOn":@(isOn),
            @"majorMinValue":majorMinValue,
            @"majorMaxValue":majorMaxValue,
        };
        operationID = mk_taskReadMajorFilterStateOperation;
    }else if ([function isEqualToString:@"11"]) {
        //读取过滤Minor范围
        BOOL isOn = (len > 0);
        NSString *minorMinValue = @"";
        NSString *minorMaxValue = @"";
        if (isOn) {
            minorMinValue = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(6, 4)];
            minorMaxValue = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(10, 4)];
        }
        returnDic = @{
            @"isOn":@(isOn),
            @"minorMinValue":minorMinValue,
            @"minorMaxValue":minorMaxValue,
        };
        operationID = mk_taskReadMinorFilterStateOperation;
    }else if ([function isEqualToString:@"12"]) {
        //读取报警RSSI值
        NSNumber *rssi = [MKBLEBaseSDKAdopter signedHexTurnString:[content substringWithRange:NSMakeRange(6, 2)]];
        returnDic = @{@"rssi":rssi};
        operationID = mk_taskReadAlarmTriggerRssiOperation;
    }else if ([function isEqualToString:@"13"]) {
        //读取LoRa上报数据间隔
        NSString *interval = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(6, 2)];
        returnDic = @{@"interval":interval};
        operationID = mk_taskReadLoRaReportingIntervalOperation;
    }else if ([function isEqualToString:@"14"]) {
        NSString *note = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(6, 2)];
        returnDic = @{@"noteType":note};
        operationID = mk_taskReadAlarmNotificationOperation;
    }else if ([function isEqualToString:@"15"]) {
        //读取LoRaWAN Mode
        returnDic = @{
        @"modem":[MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(6, 2)],
        };
        operationID = mk_taskReadLoraWANModemOperation;
    }else if ([function isEqualToString:@"16"]) {
        //读取DevEUI
        returnDic = @{
            @"devEUI":[content substringWithRange:NSMakeRange(6, len * 2)],
        };
        operationID = mk_taskReadDevEUIOperation;
    }else if ([function isEqualToString:@"17"]) {
        //读取AppEUI
        returnDic = @{
                       @"appEUI":[content substringWithRange:NSMakeRange(6, len * 2)],
                       };
        operationID = mk_taskReadAPPEUIOperation;
    }else if ([function isEqualToString:@"18"]) {
        //读取AppKey
        returnDic = @{
            @"appKey":[content substringWithRange:NSMakeRange(6, len * 2)],
        };
        operationID = mk_taskReadAPPKeyOperation;
    }else if ([function isEqualToString:@"19"]) {
        //读取DevAddr
        returnDic = @{
            @"devAddr":[content substringWithRange:NSMakeRange(6, len * 2)],
        };
        operationID = mk_taskReadDevAddrOperation;
    }else if ([function isEqualToString:@"1a"]) {
        //读取AppSKey
        returnDic = @{
            @"appSKey":[content substringWithRange:NSMakeRange(6, len * 2)],
        };
        operationID = mk_taskReadAPPSKeyOperation;
    }else if ([function isEqualToString:@"1b"]) {
        //读取NwkSKey
        returnDic = @{
            @"nwkSKey":[content substringWithRange:NSMakeRange(6, len * 2)],
        };
        operationID = mk_taskReadNwkSKeyOperation;
    }else if ([function isEqualToString:@"1c"]) {
        //读取Region
        returnDic = @{
            @"region":[MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(6, 2 * len)],
        };
        operationID = mk_taskReadRegionOperation;
    }else if ([function isEqualToString:@"1d"]) {
        //读取设备确认帧
        NSString *messageType = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(6, 2 * len)];
        returnDic = @{
                       @"messageType":messageType,
                       };
        operationID = mk_taskReadLoRaMessageTypeOperation;
    }else if ([function isEqualToString:@"1e"]) {
        //读取CH
        returnDic = @{
                       @"CHL":[MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(6, 2)],
                       @"CHH":[MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(8, 2)],
                       };
        operationID = mk_taskReadCHDataOperation;
    }else if ([function isEqualToString:@"1f"]) {
        //读取DR
        returnDic = @{
                       @"DR":[MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(6, 2)],
                       };
        operationID = mk_taskReadDRDataOperation;
    }else if ([function isEqualToString:@"20"]) {
        //读取ADR
        BOOL isOn = ([MKBLEBaseSDKAdopter getDecimalWithHex:content range:NSMakeRange(6, 2 * len)] == 1);
        returnDic = @{
                       @"adrOpen":@(isOn),
                       };
        operationID = mk_taskReadADRDataOperation;
    }else if ([function isEqualToString:@"22"]) {
        //读取LoRa联网状态
        NSString *status = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(6, 2 * len)];
        returnDic = @{
                       @"status":status,
                       };
        operationID = mk_taskReadLoRaNetworkStatusOperation;
    }else if ([function isEqualToString:@"23"]) {
        //读取设备Mac地址
        NSString *tempMac = [[content substringWithRange:NSMakeRange(6, 2 * len)] uppercaseString];
        NSString *macAddress = [NSString stringWithFormat:@"%@:%@:%@:%@:%@:%@",[tempMac substringWithRange:NSMakeRange(0, 2)],[tempMac substringWithRange:NSMakeRange(2, 2)],[tempMac substringWithRange:NSMakeRange(4, 2)],[tempMac substringWithRange:NSMakeRange(6, 2)],[tempMac substringWithRange:NSMakeRange(8, 2)],[tempMac substringWithRange:NSMakeRange(10, 2)]];
        returnDic = @{
            @"macAddress":macAddress
        };
        operationID = mk_taskReadMacAddressOperation;
    }else if ([function isEqualToString:@"25"]) {
        //读取设备过滤的Raw Data
        BOOL isFirst = ([MKBLEBaseSDKAdopter getDecimalWithHex:content range:NSMakeRange(6, 2)] == 1);
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:@(isFirst) forKey:@"isFirst"];
        BOOL haveRaw = YES;
        if (isFirst) {
            NSInteger totalNumber = ([MKBLEBaseSDKAdopter getDecimalWithHex:content range:NSMakeRange(8, 2)] + 1);
            [dic setValue:[NSString stringWithFormat:@"%ld",(long)totalNumber] forKey:mk_communicationDataNum];
            if (len == 2) {
                //长度为2是特殊情况，如果第一个包长度为2且是最后一个包表示清空过滤规则
                haveRaw = NO;
                [dic setValue:@"0" forKey:mk_communicationDataNum];
            }
        }
        if (haveRaw) {
            [dic setValue:[content substringWithRange:NSMakeRange(10, (len - 2) * 2)] forKey:@"rawData"];
            NSString *remainPacket = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(8, 2)];
            [dic setValue:remainPacket forKey:@"remainPacket"];
        }
        returnDic = [NSDictionary dictionaryWithDictionary:dic];
        operationID = mk_taskReadFilterRawDatasOperation;
    }else if ([function isEqualToString:@"27"]) {
        NSString *pwm_value = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(6, 2 * len)];
        returnDic = @{
                       @"pwm_value":pwm_value,
                       };
        operationID = mk_taskReadPWMDataOperation;
    }else if ([function isEqualToString:@"28"]) {
        NSString *duration = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(6, 2 * len)];
        returnDic = @{
                       @"duration":duration,
                       };
        operationID = mk_taskReadDurationOfVibrationOperation;
    }else if ([function isEqualToString:@"29"]) {
        NSString *cycle = [MKBLEBaseSDKAdopter getDecimalStringWithHex:content range:NSMakeRange(6, 2 * len)];
        returnDic = @{
                       @"cycle":cycle,
                       };
        operationID = mk_taskReadVibrationCycleOperation;
    }
    return [self dataParserGetDataSuccess:returnDic operationID:operationID];
}

+ (NSDictionary *)dataParserGetDataSuccess:(NSDictionary *)returnData operationID:(mk_taskOperationID)operationID{
    if (!returnData) {
        return @{};
    }
    return @{@"returnData":returnData,@"operationID":@(operationID)};
}

+ (NSString *)fetchTxPower:(NSString *)content {
    if ([content isEqualToString:@"04"]) {
        return @"4dBm";
    }
    if ([content isEqualToString:@"03"]) {
        return @"3dBm";
    }
    if ([content isEqualToString:@"00"]) {
        return @"0dBm";
    }
    if ([content isEqualToString:@"fc"]) {
        return @"-4dBm";
    }
    if ([content isEqualToString:@"f8"]) {
        return @"-8dBm";
    }
    if ([content isEqualToString:@"f4"]) {
        return @"-12dBm";
    }
    if ([content isEqualToString:@"f0"]) {
        return @"-16dBm";
    }
    if ([content isEqualToString:@"ec"]) {
        return @"-20dBm";
    }
    if ([content isEqualToString:@"d8"]) {
        return @"-40dBm";
    }
    return @"-4dBm";
}

@end
