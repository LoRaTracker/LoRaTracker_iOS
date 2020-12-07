//
//  MKDeviceSettingTextCellModel.h
//  MKLorawanGpsTracker
//
//  Created by aa on 2019/4/29.
//  Copyright © 2019 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKDeviceSettingTextCellModel : NSObject

@property (nonatomic, copy)NSString *msg;

@property (nonatomic, copy)NSString *value;

@property (nonatomic, assign)NSInteger maxLen;

/// 0 : DevEUI, 1 : AppEUI, 2 : DevAddr ,3 : AppSkey, 4 : NwkSkey, 5 : AppKey
@property (nonatomic, assign)NSInteger index;

@end

NS_ASSUME_NONNULL_END
