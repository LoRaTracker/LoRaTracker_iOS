//
//  MKCDOptionsCellModel.m
//  MKLorawanGpsTracker
//
//  Created by aa on 2019/4/29.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKCDOptionsCellModel.h"

@implementation MKCDOptionsCellModel

+ (NSArray *)fetchCHDataList:(mk_loraWanRegion)region {
    if (region == mk_loraWanRegionUS915 || region == mk_loraWanRegionAU915) {
        return [self chValueWithMax:63];
    }
    if (region == mk_loraWanRegionCN470) {
        return [self chValueWithMax:95];
    }
    return [self chValueWithMax:15];
}

+ (NSArray *)fetchDRDataList:(mk_loraWanRegion)region {
    if (region == mk_loraWanRegionUS915) {
        return [self drValueWithMax:4];
    }
    if (region == mk_loraWanRegionAU915) {
        return [self drValueWithMax:6];
    }
    return [self drValueWithMax:5];
}

+ (NSInteger)fetchCHHValue:(mk_loraWanRegion)region {
    if (region == mk_loraWanRegionUS915 || region == mk_loraWanRegionAU915 || region == mk_loraWanRegionCN470) {
        return 7;
    }
    if (region == mk_loraWanRegionCN779) {
        return 5;
    }
    if (region == mk_loraWanRegionAS923) {
        return 1;
    }
    return 2;
}

+ (NSInteger)fetchCHLValue:(mk_loraWanRegion)region {
    return 0;
}

+ (NSInteger)fetchDRValue:(mk_loraWanRegion)region {
    if (region == mk_loraWanRegionAS923 || region == mk_loraWanRegionAU915) {
        return 2;
    }
    return 0;
}

#pragma mark - private method
+ (NSArray *)chValueWithMax:(NSInteger)max {
    NSMutableArray *chList = [NSMutableArray array];
    for (NSInteger i = 0; i < (max + 1); i ++) {
        [chList addObject:[NSString stringWithFormat:@"%ld",(long)i]];
    }
    return chList;
}

+ (NSArray *)drValueWithMax:(NSInteger)max {
    NSMutableArray *drList = [NSMutableArray array];
    for (NSInteger i = 0; i < (max + 1); i ++) {
        [drList addObject:[NSString stringWithFormat:@"DR%ld",(long)i]];
    }
    return drList;
}

@end
