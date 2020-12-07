//
//  MKVibrationInfoCell.h
//  MKLoRaTracker
//
//  Created by aa on 2020/9/25.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKBaseCell.h"
#import "MKScannerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKVibrationInfoCellModel : NSObject

@property (nonatomic, copy)NSString *msg;

@property (nonatomic, copy)NSString *placeHolder;

@property (nonatomic, copy)NSString *value;

@property (nonatomic, assign)NSInteger index;

@end

@interface MKVibrationInfoCell : MKBaseCell

@property (nonatomic, strong)MKVibrationInfoCellModel *dataModel;

@property (nonatomic, weak)id <MKScannerDelegate>delegate;

+ (MKVibrationInfoCell *)initCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
