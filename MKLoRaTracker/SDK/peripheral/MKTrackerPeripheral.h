//
//  MKTrackerPeripheral.h
//  MKContactTracker
//
//  Created by aa on 2020/4/25.
//  Copyright © 2020 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CBPeripheral;
@interface MKTrackerPeripheral : NSObject<MKBLEBasePeripheralProtocol>

@property (nonatomic, strong, nonnull)CBPeripheral *peripheral;

@end

NS_ASSUME_NONNULL_END
