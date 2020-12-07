//
//  MKRegionCell.h
//  MKLorawanGpsTracker
//
//  Created by aa on 2019/4/29.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKDeviceSettingBaseCell.h"
#import "MKDeviceSettingProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKRegionCell : MKDeviceSettingBaseCell

@property (nonatomic, assign)NSInteger region;

@property (nonatomic, weak)id <MKDeviceSettingRegionDelegate>delegate;

+ (MKRegionCell *)initCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
