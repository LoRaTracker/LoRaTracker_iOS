//
//  MKDeviceInfoModel.h
//  BeaconXPlus
//
//  Created by aa on 2019/5/24.
//  Copyright © 2019 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKDeviceInfoModel : NSObject

/**
 电池电量
 */
@property (nonatomic, copy)NSString *batteryPower;

/**
 产品型号
 */
@property (nonatomic, copy)NSString *deviceModel;

/**
 软件版本
 */
@property (nonatomic, copy)NSString *software;

/**
 固件版本
 */
@property (nonatomic, copy)NSString *firmware;

/**
 硬件版本
 */
@property (nonatomic, copy)NSString *hardware;

/**
 厂商信息
 */
@property (nonatomic, copy)NSString *manu;

/// Mac地址
@property (nonatomic, copy)NSString *macAddress;

/// 开始读取设备信息
/// @param onlyVoltage 是否只读取电池电压
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
- (void)startLoadSystemInformation:(BOOL)onlyVoltage
                          sucBlock:(void (^)(void))sucBlock
                       failedBlock:(void (^)(NSError *error))failedBlock;

@end

NS_ASSUME_NONNULL_END
