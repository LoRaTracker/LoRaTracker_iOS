//
//  MKTrackerInterface.h
//  MKContactTracker
//
//  Created by aa on 2020/4/27.
//  Copyright © 2020 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKTrackerInterface : NSObject

#pragma mark - Device Service Information

/// Read the battery level of the device
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)readBatteryPowerWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                         failedBlock:(nonnull void (^)(NSError *error))failedBlock;

/// Read device manufacturer information
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)readManufacturerWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                         failedBlock:(nonnull void (^)(NSError *error))failedBlock;

/// Read product model
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)readDeviceModelWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                        failedBlock:(nonnull void (^)(NSError *error))failedBlock;

/// Read device hardware information
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)readHardwareWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                     failedBlock:(nonnull void (^)(NSError *error))failedBlock;

/// Read device software information
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)readSoftwareWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                     failedBlock:(nonnull void (^)(NSError *error))failedBlock;

/// Read device firmware information
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)readFirmwareWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                     failedBlock:(nonnull void (^)(NSError *error))failedBlock;

#pragma mark -

/// Reading the proximity UUID of the device
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)readProximityUUIDWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                          failedBlock:(nonnull void (^)(NSError *error))failedBlock;

/// Reading the major of the device
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)readMajorWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                  failedBlock:(nonnull void (^)(NSError *error))failedBlock;

/// Reading the minor of the device
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)readMinorWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                  failedBlock:(nonnull void (^)(NSError *error))failedBlock;

/// RSSI@1M
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)readMeasurePowerWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                         failedBlock:(nonnull void (^)(NSError *error))failedBlock;

/// Reading Advertised Tx Power(RSSI@0m)
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)readTxPowerWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                    failedBlock:(nonnull void (^)(NSError *error))failedBlock;

/// Reading the broadcast interval of the device
/// units:100ms
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)readAdvIntervalWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                        failedBlock:(nonnull void (^)(NSError *error))failedBlock;

/// Reading the broadcast name of the device
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)readAdvNameWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                    failedBlock:(nonnull void (^)(NSError *error))failedBlock;

/// Reading Valid BLE Data Filter Interval.
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)readValidBLEDataFilterIntervalWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                                       failedBlock:(nonnull void (^)(NSError *error))failedBlock;

/// The scan duration of every 1000ms.If you set the duration to 0ms,the Beacon will stop scanning,
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)readScanWindowDataWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                           failedBlock:(nonnull void (^)(NSError *error))failedBlock;

/// Read the connectable status of the device.
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)readConnectableWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                        failedBlock:(nonnull void (^)(NSError *error))failedBlock;

/// Whether the filtering of the mac address of the device is turned on.
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)readMacAddressFilterStatusWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                                   failedBlock:(nonnull void (^)(NSError *error))failedBlock;

/// 读取过滤的RSSI
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)readFilterRssiValueWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                            failedBlock:(nonnull void (^)(NSError *error))failedBlock;

/// Whether the filtering of the adversting name of the device is turned on.
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)readAdvNameFilterStatusWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                                failedBlock:(nonnull void (^)(NSError *error))failedBlock;

/// Whether the filtering of the major of the device is turned on.(Firmware:V3.1.0 or later)
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)readMajorFilterStateWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                             failedBlock:(nonnull void (^)(NSError *error))failedBlock;

/// Whether the filtering of the minor of the device is turned on.(Firmware:V3.1.0 or later)
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)readMinorFilterStateWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                             failedBlock:(nonnull void (^)(NSError *error))failedBlock;

/// Read alarm RSSI value.(-127dBm - 0dBm)
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)readAlarmTriggerRssiWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                             failedBlock:(nonnull void (^)(NSError *error))failedBlock;

/// 读取LoRa上报时间
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)readLoRaReportingIntervalWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                                  failedBlock:(nonnull void (^)(NSError *error))failedBlock;

/// Read the alarm reminder function. 0x00 means the alarm reminder is off, 0x01 means the alarm is turned on, the LED reminder is on, 0x02 means the motor reminder is turned on, and 0x03 means both the LED and motor reminder are turned on
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)readAlarmNotificationWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                              failedBlock:(nonnull void (^)(NSError *error))failedBlock;

/// 读取lora入网类型
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)readLoraWANModemWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                         failedBlock:(nonnull void (^)(NSError *error))failedBlock;

/// 读取DevEUI
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)readDevEUIWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                   failedBlock:(nonnull void (^)(NSError *error))failedBlock;

/// 读取APPEUI
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)readAPPEUIWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                   failedBlock:(nonnull void (^)(NSError *error))failedBlock;

/// 读取AppKey
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)readAppKeyWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                   failedBlock:(nonnull void (^)(NSError *error))failedBlock;

/// 读取DevAddr
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)readDevAddrWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                    failedBlock:(nonnull void (^)(NSError *error))failedBlock;

/// 读取APPSKey
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)readAPPSKeyWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                    failedBlock:(nonnull void (^)(NSError *error))failedBlock;

/// 读取NwkSKey
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)readNwkSKeyWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                    failedBlock:(nonnull void (^)(NSError *error))failedBlock;

/// 读取Region
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)readRegionWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                   failedBlock:(nonnull void (^)(NSError *error))failedBlock;

/// 读取LoRa Message type
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)readMessageTypeWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                        failedBlock:(nonnull void (^)(NSError *error))failedBlock;

/// 读取
/// CH @{
///@"CHL":0
///@"CHH":2
///}
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)readCHDataWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                   failedBlock:(nonnull void (^)(NSError *error))failedBlock;

/// 读取DR @{
///@"DR":1
///}
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)readDRDataWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                   failedBlock:(nonnull void (^)(NSError *error))failedBlock;

/// 读取ADR状态
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)readADRStatusWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                      failedBlock:(nonnull void (^)(NSError *error))failedBlock;

/// 读取LoRa网络状态,0:未连接,1：已连接，2：正在连接
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)readLoRaNetworkStatusWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                              failedBlock:(nonnull void (^)(NSError *error))failedBlock;

/// Reading mac address
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)readMacaddressWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                       failedBlock:(nonnull void (^)(NSError *error))failedBlock;

/// 读取过滤规则数据列表
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)readFilterRawDatasWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                           failedBlock:(nonnull void (^)(NSError *error))failedBlock;

/// 读取PWM占空比
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)readPWMDatasWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                     failedBlock:(nonnull void (^)(NSError *error))failedBlock;

/// 读取马达震动时长
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)readDurationOfVibrationWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                                failedBlock:(nonnull void (^)(NSError *error))failedBlock;

/// 读取马达周期时长
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
+ (void)readVibrationCycleWithSucBlock:(nonnull void (^)(id returnData))sucBlock
                           failedBlock:(nonnull void (^)(NSError *error))failedBlock;

@end

NS_ASSUME_NONNULL_END
