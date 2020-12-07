//
//  MKIntervalCell.h
//  MKLorawanGpsTracker
//
//  Created by aa on 2019/4/29.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKDeviceSettingBaseCell.h"
#import "MKDeviceSettingProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKIntervalCell : MKDeviceSettingBaseCell

@property (nonatomic, weak)id <MKDeviceSettingReportIntervalDelegate>delegate;

@property (nonatomic, assign)NSInteger interval;

+ (MKIntervalCell *)initCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
