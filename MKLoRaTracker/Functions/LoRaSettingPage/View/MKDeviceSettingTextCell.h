//
//  MKDeviceSettingTextCell.h
//  MKLorawanGpsTracker
//
//  Created by aa on 2019/4/29.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKDeviceSettingBaseCell.h"

#import "MKDeviceSettingProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class MKDeviceSettingTextCellModel;
@interface MKDeviceSettingTextCell : MKDeviceSettingBaseCell

@property (nonatomic, strong)MKDeviceSettingTextCellModel *dataModel;

@property (nonatomic, weak)id <MKDeviceSettingTextCellDelegate>delegate;

+ (MKDeviceSettingTextCell *)initCellWithTableView:(UITableView *)table;

@end

NS_ASSUME_NONNULL_END
