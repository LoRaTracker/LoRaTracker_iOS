//
//  MKSettingTableViewCell.h
//  MKLoRaTracker
//
//  Created by aa on 2020/7/31.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKSettingTableViewCellModel : NSObject

@property (nonatomic, copy)NSString *leftMsg;

@end

@interface MKSettingTableViewCell : MKBaseCell

@property (nonatomic, strong)MKSettingTableViewCellModel *dataModel;

+ (MKSettingTableViewCell *)initCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
