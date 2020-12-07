//
//  CBPeripheral+MKTracker.m
//  MKContactTracker
//
//  Created by aa on 2020/4/25.
//  Copyright © 2020 MK. All rights reserved.
//

#import "CBPeripheral+MKTracker.h"
#import <objc/runtime.h>

#import "MKTrackerSDKDefines.h"

static const char *batteryPowerKey = "batteryPowerKey";
static const char *manufacturerKey = "manufacturerKey";
static const char *deviceModelKey = "deviceModelKey";
static const char *hardwareKey = "hardwareKey";
static const char *softwareKey = "softwareKey";
static const char *firmwareKey = "firmwareKey";

static const char *disconnectTypeKey = "disconnectTypeKey";
static const char *passwordKey = "passwordKey";
static const char *customKey = "customKey";

static const char *passwordNotifySuccessKey = "passwordNotifySuccessKey";
static const char *customNotifySuccessKey = "customNotifySuccessKey";
static const char *disconnectNotifySuccessKey = "disconnectNotifySuccessKey";

@implementation CBPeripheral (MKTracker)

/*
 
 */

#pragma mark - public method
- (void)updateCharacterWithService:(CBService *)service {
    NSArray *characteristicList = service.characteristics;
    if ([service.UUID isEqual:MKUUID(@"180A")]) {
        //设备信息
        for (CBCharacteristic *characteristic in characteristicList) {
            if ([characteristic.UUID isEqual:MKUUID(@"2A24")]) {
                objc_setAssociatedObject(self, &deviceModelKey, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }else if ([characteristic.UUID isEqual:MKUUID(@"2A26")]) {
                objc_setAssociatedObject(self, &firmwareKey, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }else if ([characteristic.UUID isEqual:MKUUID(@"2A27")]) {
                objc_setAssociatedObject(self, &hardwareKey, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }else if ([characteristic.UUID isEqual:MKUUID(@"2A28")]) {
                objc_setAssociatedObject(self, &softwareKey, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }else if ([characteristic.UUID isEqual:MKUUID(@"2A29")]) {
                objc_setAssociatedObject(self, &manufacturerKey, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
        }
        return;
    }
    if ([service.UUID isEqual:MKUUID(@"180F")]) {
        //电池电量
        for (CBCharacteristic *characteristic in characteristicList) {
            if ([characteristic.UUID isEqual:MKUUID(@"2A19")]) {
                objc_setAssociatedObject(self, &batteryPowerKey, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                break;
            }
        }
        return;
    }
    if ([service.UUID isEqual:MKUUID(@"FF00")]) {
        //自定义服务
        for (CBCharacteristic *characteristic in characteristicList) {
            if ([characteristic.UUID isEqual:MKUUID(@"FF00")]) {
                objc_setAssociatedObject(self, &passwordKey, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }else if ([characteristic.UUID isEqual:MKUUID(@"FF01")]) {
                objc_setAssociatedObject(self, &disconnectTypeKey, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }else if ([characteristic.UUID isEqual:MKUUID(@"FF02")]) {
                objc_setAssociatedObject(self, &customKey, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
            [self setNotifyValue:YES forCharacteristic:characteristic];
        }
        return;
    }
}

- (void)updateCurrentNotifySuccess:(CBCharacteristic *)characteristic {
    if ([characteristic.UUID isEqual:MKUUID(@"FF00")]) {
        objc_setAssociatedObject(self, &passwordNotifySuccessKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return;
    }
    if ([characteristic.UUID isEqual:MKUUID(@"FF01")]) {
        objc_setAssociatedObject(self, &disconnectNotifySuccessKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return;
    }
    if ([characteristic.UUID isEqual:MKUUID(@"FF02")]) {
        objc_setAssociatedObject(self, &customNotifySuccessKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return;
    }
}

- (BOOL)connectSuccess {
    if (![objc_getAssociatedObject(self, &customNotifySuccessKey) boolValue] || ![objc_getAssociatedObject(self, &passwordNotifySuccessKey) boolValue] || ![objc_getAssociatedObject(self, &disconnectNotifySuccessKey) boolValue]) {
        return NO;
    }
    if (!self.batteryPower || !self.manufacturer || !self.deviceModel || !self.hardware || !self.sofeware || !self.firmware) {
        return NO;
    }
    if (!self.password || !self.disconnectType || !self.custom) {
        return NO;
    }
    return YES;
}

- (void)setNil {
    objc_setAssociatedObject(self, &batteryPowerKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &manufacturerKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &deviceModelKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &hardwareKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &softwareKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &firmwareKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    objc_setAssociatedObject(self, &disconnectTypeKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &passwordKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &customKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    objc_setAssociatedObject(self, &passwordNotifySuccessKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &customNotifySuccessKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &disconnectNotifySuccessKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - getter

- (CBCharacteristic *)batteryPower {
    return objc_getAssociatedObject(self, &batteryPowerKey);
}

- (CBCharacteristic *)manufacturer {
    return objc_getAssociatedObject(self, &manufacturerKey);
}

- (CBCharacteristic *)deviceModel {
    return objc_getAssociatedObject(self, &deviceModelKey);
}

- (CBCharacteristic *)hardware {
    return objc_getAssociatedObject(self, &hardwareKey);
}

- (CBCharacteristic *)sofeware {
    return objc_getAssociatedObject(self, &softwareKey);
}

- (CBCharacteristic *)firmware {
    return objc_getAssociatedObject(self, &firmwareKey);
}

- (CBCharacteristic *)password {
    return objc_getAssociatedObject(self, &passwordKey);
}

- (CBCharacteristic *)disconnectType {
    return objc_getAssociatedObject(self, &disconnectTypeKey);
}

- (CBCharacteristic *)custom {
    return objc_getAssociatedObject(self, &customKey);
}

@end
