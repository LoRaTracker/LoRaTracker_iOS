//
//  MKFilterOptionsHeaderView.h
//  MKLoRaTracker
//
//  Created by aa on 2020/7/22.
//  Copyright © 2020 MK. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MKFliterRssiValueCellDelegate <NSObject>

- (void)mk_fliterRssiValueChanged:(NSInteger)rssi;

@end

@interface MKFilterOptionsHeaderView : UIView

@property (nonatomic, assign)NSInteger rssi;

@property (nonatomic, weak)id <MKFliterRssiValueCellDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
