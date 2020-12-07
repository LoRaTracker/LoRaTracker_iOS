//
//  MKFilterRawOptionsView.h
//  MKLoRaTracker
//
//  Created by aa on 2020/7/22.
//  Copyright © 2020 MK. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MKFilterRawMsgCellDelegate <NSObject>

- (void)filterRawDataStatusChanged:(BOOL)isOn;

- (void)addFilterRawDataConditions;

- (void)subFilterRawDataConditions;

@end

@interface MKFilterRawOptionsView : UIView

@property (nonatomic, assign)BOOL filterIsOn;

@property (nonatomic, weak)id <MKFilterRawMsgCellDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
