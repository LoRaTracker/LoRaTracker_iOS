//
//  MKDeviceTypeManager.h
//  MKContactTracker
//
//  Created by aa on 2020/6/30.
//  Copyright © 2020 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKDeviceTypeManager : NSObject

/// 当前连接密码
@property (nonatomic, copy, readonly)NSString *password;

+ (MKDeviceTypeManager *)shared;

- (void)connectTracker:(MKTrackerModel *)trackerModel
              password:(NSString *)password
              sucBlock:(void (^)(void))sucBlock
           failedBlock:(void (^)(NSError *error))failedBlock;

@end

NS_ASSUME_NONNULL_END
