//
//  MKVibIntenSityCell.h
//  MKLoRaTracker
//
//  Created by aa on 2020/9/25.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKBaseCell.h"
#import "MKScannerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKVibIntenSityCell : MKBaseCell

@property (nonatomic, assign)NSInteger intensity;

@property (nonatomic, weak)id <MKScannerDelegate>delegate;

+ (MKVibIntenSityCell *)initCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
