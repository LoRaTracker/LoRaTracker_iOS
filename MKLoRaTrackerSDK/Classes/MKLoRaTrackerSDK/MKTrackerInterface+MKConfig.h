//
//  MKTrackerInterface+MKConfig.h
//  MKContactTracker
//
//  Created by aa on 2020/4/27.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKTrackerInterface.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MKDeviceTimeProtocol <NSObject>

@property (nonatomic, assign)NSInteger year;

@property (nonatomic, assign)NSInteger month;

@property (nonatomic, assign)NSInteger day;

@property (nonatomic, assign)NSInteger hour;

@property (nonatomic, assign)NSInteger minutes;

@property (nonatomic, assign)NSInteger second;

@end

typedef NS_ENUM(NSInteger, mk_trackerTxPower) {
    mk_trackerTxPower4dBm,       //RadioTxPower:4dBm
    mk_trackerTxPower3dBm,       //3dBm
    mk_trackerTxPower0dBm,       //0dBm
    mk_trackerTxPowerNeg4dBm,    //-4dBm
    mk_trackerTxPowerNeg8dBm,    //-8dBm
    mk_trackerTxPowerNeg12dBm,   //-12dBm
    mk_trackerTxPowerNeg16dBm,   //-16dBm
    mk_trackerTxPowerNeg20dBm,   //-20dBm
    mk_trackerTxPowerNeg40dBm,   //-40dBm
};

typedef NS_ENUM(NSInteger, mk_alarmNotification) {
    mk_closeAlarmNotification,
    mk_ledAlarmNotification,
    mk_motorAlarmNotification,
    mk_ledMotorAlarmNotification,
};

typedef NS_ENUM(NSInteger, mk_scannWindowType) {
    mk_scannWindowTypeClose,            //close.
    mk_scannWindowTypeOpen,             //open.
    mk_scannWindowTypeHalfOpen,         //Open in half time.
    mk_scannWindowTypeQuarterOpen,      //Open a quarter of the time.
    mk_scannWindowTypeOneEighthOpen,    //Open in one eighth time.
};

typedef NS_ENUM(NSInteger, mk_loraWANModem) {
    mk_loraWANModemABP,
    mk_loraWANModemOTAA,
};

typedef NS_ENUM(NSInteger, mk_loraWanRegion) {
    mk_loraWanRegionEU868,
    mk_loraWanRegionUS915,
    mk_loraWanRegionUS915HYBRID,
    mk_loraWanRegionCN779,
    mk_loraWanRegionEU433,
    mk_loraWanRegionAU915,
    mk_loraWanRegionAU915OLD,
    mk_loraWanRegionCN470,
    mk_loraWanRegionAS923,
    mk_loraWanRegionKR920,
    mk_loraWanRegionIN865,
    mk_loraWanRegionCN470PREQUEL,
    mk_loraWanRegionSTE920,
};

@protocol MKRawFilterProtocol <NSObject>

/// 参考https://www.bluetooth.com/specifications/assigned-numbers/generic-access-profile/
@property (nonatomic, copy)NSString *dataType;

@property (nonatomic, assign)NSInteger minIndex;

@property (nonatomic, assign)NSInteger maxIndex;

@property (nonatomic, copy)NSString *rawData;

@end

@interface MKTrackerInterface (MKConfig)

/// Configure iBeacon UUID
/// @param uuid uuid
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configProximityUUID:(NSString *)uuid
                   sucBlock:(void (^)(void))sucBlock
                failedBlock:(void (^)(NSError *error))failedBlock;

/// Configure iBeacon Major
/// @param major 0~65535
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configMajor:(NSInteger)major
           sucBlock:(void (^)(void))sucBlock
        failedBlock:(void (^)(NSError *error))failedBlock;

/// Configure iBeacon Minor
/// @param minor 0~65535
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configMinor:(NSInteger)minor
           sucBlock:(void (^)(void))sucBlock
        failedBlock:(void (^)(NSError *error))failedBlock;

/// Configure Measured Power
/// @param measuredPower (RSSI@1M),-127~0
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configMeasuredPower:(NSInteger)measuredPower
                   sucBlock:(void (^)(void))sucBlock
                failedBlock:(void (^)(NSError *error))failedBlock;

/// Configure Tx Power
/// @param txPower Tx Power
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configTxPower:(mk_trackerTxPower)txPower
             sucBlock:(void (^)(void))sucBlock
          failedBlock:(void (^)(NSError *error))failedBlock;

/// Advertising interval
/// @param interval Advertising interval, unit: 100ms, range: 1~100
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configAdvInterval:(NSInteger)interval
                 sucBlock:(void (^)(void))sucBlock
              failedBlock:(void (^)(NSError *error))failedBlock;

/// Configure the broadcast name of the device
/// @param deviceName 1 ~ 10 length ASCII code characters
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configDeviceName:(NSString *)deviceName
                sucBlock:(void (^)(void))sucBlock
             failedBlock:(void (^)(NSError *error))failedBlock;

/// Configure the device's connection password.
/// @param password 8-character ascii code characters
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configPassword:(NSString *)password
              sucBlock:(void (^)(void))sucBlock
           failedBlock:(void (^)(NSError *error))failedBlock;

/// Resetting to factory state (RESET).NOTE:When resetting the device, the connection password will not be restored which shall remain set to its current value.
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)factoryDataResetWithSucBlock:(nonnull void (^)(void))sucBlock
                         failedBlock:(void (^)(NSError *error))failedBlock;

/// Configure Valid BLE Data Filter Interval.
/// @param interval Interval,1~600s
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configValidBLEDataFilterInterval:(NSInteger)interval
                                sucBlock:(void (^)(void))sucBlock
                             failedBlock:(void (^)(NSError *error))failedBlock;

/// The scan duration of every 1000ms
/// @param type type
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configScannWindow:(mk_scannWindowType)type
                 sucBlock:(void (^)(void))sucBlock
              failedBlock:(void (^)(NSError *error))failedBlock;

/// Configure the connectable status of the device.
/// @param isOn isOn
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configConnectableStatus:(BOOL)isOn
                       sucBlock:(void (^)(void))sucBlock
                    failedBlock:(void (^)(NSError *error))failedBlock;

/// Set the current MAC address filtering conditions
/// @param isOn Whether to enable mac address filtering
/// @param mac The mac address to be filtered. If isOn = NO, the item can be omitted. If isOn = YES, the mac address with a maximum length of 12 characters must be filled in.
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configMacFilterStatus:(BOOL)isOn
                          mac:(NSString *)mac
                     sucBlock:(void (^)(void))sucBlock
                  failedBlock:(void (^)(NSError *error))failedBlock;

/// 配置过滤的RSSI
/// @param rssi rssi,-127dBm~0dBm
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configFilterRssiValue:(NSInteger)rssi
                     sucBlock:(void (^)(void))sucBlock
                  failedBlock:(void (^)(NSError *error))failedBlock;

/// Set the current advertising name filtering conditions
/// @param isOn Whether to enable advertising name filtering
/// @param advName The advertising name to be filtered. If isOn = NO, the item can be omitted. If isOn = YES, the advertising name with a maximum length of 10 characters must be filled in.
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configAdvNameFilterStatus:(BOOL)isOn
                              advName:(NSString *)advName
                         sucBlock:(void (^)(void))sucBlock
                      failedBlock:(void (^)(NSError *error))failedBlock;

/// Set the current major filtering conditions.(Firmware Version 3.1.0 or later)
/// @param isOn Whether to enable major filtering
/// @param majorMinValue Major minimum value to be filtered. This value is invalid when isOn = NO.0~65535 && majorMinValue<=majorMaxValue
/// @param majorMaxValue The maximum value of Major to be filtered. This value is invalid when isOn = NO.0~65535 && majorMinValue<=majorMaxValue
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configMajorFilterStatus:(BOOL)isOn
                  majorMinValue:(NSInteger)majorMinValue
                  majorMaxValue:(NSInteger)majorMaxValue
                       sucBlock:(void (^)(void))sucBlock
                    failedBlock:(void (^)(NSError *error))failedBlock;

/// Set the current minor filtering conditions.(Firmware Version 3.1.0 or later)
/// @param isOn Whether to enable minor filtering
/// @param minorMinValue Minor minimum value to be filtered. This value is invalid when isOn = NO.0~65535 && minorMinValue<=minorMaxValue
/// @param minorMaxValue The maximum value of Minor to be filtered. This value is invalid when isOn = NO.0~65535 && minorMinValue<=minorMaxValue
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configMinorFilterStatus:(BOOL)isOn
                  minorMinValue:(NSInteger)minorMinValue
                  minorMaxValue:(NSInteger)minorMaxValue
                       sucBlock:(void (^)(void))sucBlock
                    failedBlock:(void (^)(NSError *error))failedBlock;

/// Configure Alarm Trigger Rssi.
/// @param rssi -127dBm ~ 0dBm
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configAlarmTriggerRssi:(NSInteger)rssi
                      sucBlock:(void (^)(void))sucBlock
                   failedBlock:(void (^)(NSError *error))failedBlock;

/// 配置扫描数据定时上报时间
/// @param interval interval,1min~60min
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
+ (void)configLoRaReportingInterval:(NSInteger)interval
                           sucBlock:(void (^)(void))sucBlock
                        failedBlock:(void (^)(NSError *error))failedBlock;

/// Configure Alarm Notification
/// @param note Alarm Notification
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configAlarmNotification:(mk_alarmNotification)note
                       sucBlock:(void (^)(void))sucBlock
                    failedBlock:(void (^)(NSError *error))failedBlock;

/**
 配置loraWAN的上传模式

 @param modem modem
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)configLoraWANModem:(mk_loraWANModem)modem
                  sucBlock:(void (^)(void))sucBlock
               failedBlock:(void (^)(NSError *error))failedBlock;

/**
 设置DevEUI

 @param devEUI 16位，16进制
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)configDevEUI:(NSString *)devEUI
            sucBlock:(void (^)(void))sucBlock
         failedBlock:(void (^)(NSError *error))failedBlock;

/**
 设置AppEUI

 @param appEUI 16位，16进制
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)configAppEUI:(NSString *)appEUI
            sucBlock:(void (^)(void))sucBlock
         failedBlock:(void (^)(NSError *error))failedBlock;

/**
 设置appKey

 @param appKey 32位，16进制
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)configAppKey:(NSString *)appKey
            sucBlock:(void (^)(void))sucBlock
         failedBlock:(void (^)(NSError *error))failedBlock;

/**
 设置DevAddr

 @param devAddr 8位，16进制
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)configDevAddr:(NSString *)devAddr
             sucBlock:(void (^)(void))sucBlock
          failedBlock:(void (^)(NSError *error))failedBlock;

/**
 设置AppSKey

 @param appSKey 32位，16进制
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)configAppSKey:(NSString *)appSKey
             sucBlock:(void (^)(void))sucBlock
          failedBlock:(void (^)(NSError *error))failedBlock;

/**
 设置NwkSKey

 @param nwkSKey 32位，16进制
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)configNwkSKey:(NSString *)nwkSKey
             sucBlock:(void (^)(void))sucBlock
          failedBlock:(void (^)(NSError *error))failedBlock;

/**
 设置Region

 @param region region
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)configRegion:(mk_loraWanRegion)region
            sucBlock:(void (^)(void))sucBlock
         failedBlock:(void (^)(NSError *error))failedBlock;

/// 配置设备确认帧
/// @param messageType 0:非确认帧，1:确认帧
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
+ (void)configDeviceMessageType:(NSInteger)messageType
                       sucBlock:(void (^)(void))sucBlock
                    failedBlock:(void (^)(NSError *error))failedBlock;

/// 设置CH范围
/// @param CHLValue 最小值,0~95
/// @param CHHValue 最大值,0~95
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
+ (void)configCHValue:(NSInteger)CHLValue
             CHHValue:(NSInteger)CHHValue
             sucBlock:(void (^)(void))sucBlock
          failedBlock:(void (^)(NSError *error))failedBlock;

/// 设置DR
/// @param DRValue 最小值,0~15
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
+ (void)configDRValue:(NSInteger)DRValue
             sucBlock:(void (^)(void))sucBlock
          failedBlock:(void (^)(NSError *error))failedBlock;

/// 设置ADR状态
/// @param isOpen YES:开启，NO:关闭
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
+ (void)configADRStatus:(BOOL)isOpen
               sucBlock:(void (^)(void))sucBlock
            failedBlock:(void (^)(NSError *error))failedBlock;

/// Configure device time
/// @param protocol protocol
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configDeviceTime:(id <MKDeviceTimeProtocol>)protocol
                sucBlock:(void (^)(void))sucBlock
             failedBlock:(void (^)(NSError *error))failedBlock;

/**
 设置LoRaWAN连接网关

 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)configLoRaWANConnectNetWorkWithSucBlock:(void (^)(void))sucBlock
                                    failedBlock:(void (^)(NSError *error))failedBlock;

/// power off.
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)powerOffDeviceWithSucBlock:(void (^)(void))sucBlock
                       failedBlock:(void (^)(NSError *error))failedBlock;


/// 配置raw过滤数据规则
/// @param conditions conditions,最多五组,如果数组里面没有条件，则认为关闭过滤
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configRawFilterConditions:(nonnull NSArray <id <MKRawFilterProtocol>>*)conditions
                         sucBlock:(void (^)(void))sucBlock
                      failedBlock:(void (^)(NSError *error))failedBlock;

/// 配置PWM占空比
/// @param value 占空比0~100
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configPWM:(NSInteger)value
         sucBlock:(void (^)(void))sucBlock
      failedBlock:(void (^)(NSError *error))failedBlock;

/// 配置马达震动时长
/// @param duration 范围：0-255， 单个运行周期内震动时长
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configDurationOfVibration:(NSInteger)duration
                         sucBlock:(void (^)(void))sucBlock
                      failedBlock:(void (^)(NSError *error))failedBlock;

/// 配置马达周期时长
/// @param cycle 范围：1-600，单位：秒
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)configVibrationCycle:(NSInteger)cycle
                    sucBlock:(void (^)(void))sucBlock
                 failedBlock:(void (^)(NSError *error))failedBlock;

@end

NS_ASSUME_NONNULL_END
