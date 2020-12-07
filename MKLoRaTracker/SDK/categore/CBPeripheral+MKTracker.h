//
//  CBPeripheral+MKTracker.h
//  MKContactTracker
//
//  Created by aa on 2020/4/25.
//  Copyright © 2020 MK. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface CBPeripheral (MKTracker)

#pragma mark - Read only

/// R
@property (nonatomic, strong, readonly)CBCharacteristic *manufacturer;

/// R
@property (nonatomic, strong, readonly)CBCharacteristic *deviceModel;

@property (nonatomic, strong, readonly)CBCharacteristic *hardware;

/// R
@property (nonatomic, strong, readonly)CBCharacteristic *sofeware;

/// R
@property (nonatomic, strong, readonly)CBCharacteristic *firmware;

/// R
@property (nonatomic, strong, readonly)CBCharacteristic *batteryPower;

#pragma mark - custom

/// N/W
@property (nonatomic, strong, readonly)CBCharacteristic *password;

/// N
@property (nonatomic, strong, readonly)CBCharacteristic *disconnectType;

/// N/W
@property (nonatomic, strong, readonly)CBCharacteristic *custom;

- (void)updateCharacterWithService:(CBService *)service;

- (void)updateCurrentNotifySuccess:(CBCharacteristic *)characteristic;

- (BOOL)connectSuccess;

- (void)setNil;

@end

NS_ASSUME_NONNULL_END
