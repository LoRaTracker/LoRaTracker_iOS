//
//  MKFilterOptionsModel.h
//  MKContactTracker
//
//  Created by aa on 2020/4/24.
//  Copyright © 2020 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MKFilterRawDataCellModel;
@interface MKFilterOptionsModel : NSObject

@property (nonatomic, assign)NSInteger rssiValue;

@property (nonatomic, assign)BOOL macIson;

@property (nonatomic, copy)NSString *macValue;

@property (nonatomic, assign)BOOL advNameIson;

@property (nonatomic, copy)NSString *advNameValue;

@property (nonatomic, assign)BOOL majorIson;

/// 对于支持新功能(V3.1.0以上)的设备来说，过滤的Major可以是一个范围值
@property (nonatomic, copy)NSString *majorMaxValue;

/// 对于支持新功能(V3.1.0以上)的设备来说，过滤的Major可以是一个范围值
@property (nonatomic, copy)NSString *majorMinValue;

@property (nonatomic, assign)BOOL minorIson;

//对于支持新功能(V3.1.0以上)的设备来说，过滤的Minor可以是一个范围值
@property (nonatomic, copy)NSString *minorMaxValue;

//对于支持新功能(V3.1.0以上)的设备来说，过滤的Minor可以是一个范围值
@property (nonatomic, copy)NSString *minorMinValue;

@property (nonatomic, strong, readonly)NSMutableArray <MKFilterRawDataCellModel *>*filterRawDataList;

@property (nonatomic, assign)BOOL filterRawDataIsOn;

- (void)startReadDataWithSucBlock:(void (^)(void))sucBlock
                      failedBlock:(void (^)(NSError *error))failedBlock;

- (void)startConfigData:(NSArray <MKFilterRawDataCellModel *>*)conditions
               sucBlock:(void (^)(void))sucBlock
            failedBlock:(void (^)(NSError *error))failedBlock;

@end

NS_ASSUME_NONNULL_END
