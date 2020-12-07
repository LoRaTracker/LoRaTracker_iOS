//
//  MKMessageTypeCell.h
//  MKLoRaTracker
//
//  Created by aa on 2020/7/18.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKDeviceSettingBaseCell.h"
#import "MKDeviceSettingProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKMessageTypeCell : MKDeviceSettingBaseCell

@property (nonatomic, assign)NSInteger messageType;

@property (nonatomic, weak)id <MKDeviceSettingMessageTypeDelegate>delegate;

+ (MKMessageTypeCell *)initCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
