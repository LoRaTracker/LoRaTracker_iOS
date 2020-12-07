//
//  MKDeviceSettingBaseCell.h
//  MKLorawanGpsTracker
//
//  Created by aa on 2019/4/29.
//  Copyright © 2019 MK. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKDeviceSettingBaseCell : UITableViewCell

@property (nonatomic, strong, readonly)UIView *backView;

@property (nonatomic, strong)NSIndexPath *path;

@end

NS_ASSUME_NONNULL_END
