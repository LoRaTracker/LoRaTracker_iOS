//
//  MKAlarmTriggerRssiCell.h
//  MKLoRaTracker
//
//  Created by aa on 2020/7/18.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKBaseCell.h"
#import "MKScannerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKAlarmTriggerRssiCell : MKBaseCell

@property (nonatomic, copy)NSString *alarmTriggerRssi;

@property (nonatomic, weak)id <MKScannerDelegate>delegate;

+ (MKAlarmTriggerRssiCell *)initCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
