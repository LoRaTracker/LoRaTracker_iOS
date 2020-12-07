//
//  MKCDOptionsCell.h
//  MKLorawanGpsTracker
//
//  Created by aa on 2019/4/29.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKDeviceSettingBaseCell.h"
#import "MKDeviceSettingProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class MKCDOptionsCellModel;
@interface MKCDOptionsCell : MKDeviceSettingBaseCell

@property (nonatomic, strong)MKCDOptionsCellModel *dataModel;

@property (nonatomic, weak)id <MKDeviceSettingCDOptionsDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
