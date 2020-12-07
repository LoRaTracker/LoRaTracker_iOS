//
//  MKScannerDataModel.h
//  MKContactTracker
//
//  Created by aa on 2020/4/29.
//  Copyright © 2020 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKScannerDataModel : NSObject

@property (nonatomic, copy)NSString *interval;

/// 0表示报警提醒关闭 ，1表示报警打开LED提醒，2表示打开马达提醒，3表示LED和马达提醒都打开
@property (nonatomic, assign)NSInteger alarmNote;

/// 振动周期,0:Low, 1:Medium,2:Strong
@property (nonatomic, assign)NSInteger intenSity;

/// 振动周期
@property (nonatomic, copy)NSString *vibCycle;

/// 振动持续时长
@property (nonatomic, copy)NSString *duration;

@property (nonatomic, copy)NSString *triggerRssi;

- (void)updateWithDataModel:(MKScannerDataModel *)model;

- (void)startReadDatasWithSucBlock:(void (^)(void))sucBlock
                       failedBlock:(void (^)(NSError *error))failedBlock;

- (void)startConfigDatas:(MKScannerDataModel *)dataModel
                sucBlock:(void (^)(void))sucBlock
             failedBlock:(void (^)(NSError *error))failedBlock;

@end

NS_ASSUME_NONNULL_END
