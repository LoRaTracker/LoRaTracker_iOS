//
//  MKDeviceSettingModel.h
//  MKLorawanGpsTracker
//
//  Created by aa on 2019/4/30.
//  Copyright © 2019 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKDeviceSettingModel : NSObject

/**
 1:ABP,2:OTAA
 */
@property (nonatomic, assign)NSInteger modem;

/**
 OTAA模式下
 */
@property (nonatomic, copy)NSString *devEUI;

@property (nonatomic, copy)NSString *appEUI;

@property (nonatomic, copy)NSString *appKey;

/**
 ABP模式下
 */
@property (nonatomic, copy)NSString *devAddr;

@property (nonatomic, copy)NSString *nwkSKey;

@property (nonatomic, copy)NSString *appSKey;



/**
 0:EU868 1:US915 2:US915HYBRID 3:CN779 4:EU433 5:AU915 6:AU915OLD 7:CN470 8:AS923 9:KR920 10:IN865 11:CN470PREQUEL 12:STE920
 */
@property (nonatomic, assign)NSInteger region;

/**
 上传间隔,1~60,单位分钟
 */
@property (nonatomic, assign)NSInteger reportingInterval;

/// 0:非确认帧，1:确认帧
@property (nonatomic, assign)NSInteger messageType;

/**
 0~95
 */
@property (nonatomic, assign)NSInteger CHHValue;

@property (nonatomic, assign)NSInteger CHLValue;

/**
 0~15
 */
@property (nonatomic, assign)NSInteger DRValue;

@property (nonatomic, assign)BOOL adrIsOn;

- (void)startReadDatas:(BOOL)isDebugMode block:(void (^) (NSError *error, BOOL complete))block;
- (void)configDatas:(BOOL)isDebugMode block:(void (^) (NSError *error, BOOL complete))block;

@end

NS_ASSUME_NONNULL_END
