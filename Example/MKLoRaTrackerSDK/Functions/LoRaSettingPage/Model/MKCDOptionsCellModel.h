//
//  MKCDOptionsCellModel.h
//  MKLorawanGpsTracker
//
//  Created by aa on 2019/4/29.
//  Copyright © 2019 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKCDOptionsCellModel : NSObject

@property (nonatomic, copy)NSString *msg;

@property (nonatomic, assign)NSInteger valueL;

@property (nonatomic, assign)NSInteger valueH;

@property (nonatomic, strong)NSArray <NSString *>*dataList;

@property (nonatomic, assign)NSInteger row;

/// DR为NO，CH为YES
@property (nonatomic, assign)BOOL needHValue;

/// 选择范围的按钮是否可点击
@property (nonatomic, assign)BOOL canShowList;

+ (NSArray *)fetchCHDataList:(mk_loraWanRegion)region;

+ (NSArray *)fetchDRDataList:(mk_loraWanRegion)region;

+ (NSInteger)fetchCHHValue:(mk_loraWanRegion)region;

+ (NSInteger)fetchCHLValue:(mk_loraWanRegion)region;

+ (NSInteger)fetchDRValue:(mk_loraWanRegion)region;

@end

NS_ASSUME_NONNULL_END
