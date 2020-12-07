//
//  MKVibIntenSityCell.m
//  MKLoRaTracker
//
//  Created by aa on 2020/9/25.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKVibIntenSityCell.h"

#import "MKPickerView.h"

@interface MKVibIntenSityCell ()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UILabel *typeLabel;

@end

@implementation MKVibIntenSityCell

+ (MKVibIntenSityCell *)initCellWithTableView:(UITableView *)tableView {
    MKVibIntenSityCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MKVibIntenSityCellIdenty"];
    if (!cell) {
        cell = [[MKVibIntenSityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MKVibIntenSityCellIdenty"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.msgLabel];
        [self.contentView addSubview:self.typeLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(self.typeLabel.mas_left).mas_offset(-10.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.width.mas_equalTo(100.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(35.f);
    }];
}

#pragma mark - event method
- (void)typeLabelPressed {
    NSArray *dataList = @[@"Low",@"Medium",@"Strong"];
    MKPickerView *pickView = [[MKPickerView alloc] init];
    pickView.dataList = dataList;
    [pickView showPickViewWithIndex:[self fetchCurrentDataIndex] block:^(NSInteger currentRow) {
        self.typeLabel.text = dataList[currentRow];
        if ([self.delegate respondsToSelector:@selector(advertiserParamsChanged:index:)]) {
            [self.delegate advertiserParamsChanged:@(currentRow) index:2];
        }
    }];
}

#pragma mark - setter
- (void)setIntensity:(NSInteger)intensity {
    _intensity = intensity;
    NSArray *dataList = @[@"Low",@"Medium",@"Strong"];
    [self.typeLabel setText:dataList[_intensity]];
}

#pragma mark - private method
- (NSInteger)fetchCurrentDataIndex {
    if ([self.typeLabel.text isEqualToString:@"Low"]) {
        return 0;
    }
    if ([self.typeLabel.text isEqualToString:@"Medium"]) {
        return 1;
    }
    if ([self.typeLabel.text isEqualToString:@"Strong"]) {
        return 2;
    }
    
    return 0;
}

#pragma mark - getter
- (UILabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textColor = DEFAULT_TEXT_COLOR;
        _msgLabel.textAlignment = NSTextAlignmentLeft;
        _msgLabel.font = MKFont(15.f);
        _msgLabel.text = @"Vibration Intensity";
    }
    return _msgLabel;
}

- (UILabel *)typeLabel {
    if (!_typeLabel) {
        _typeLabel = [[UILabel alloc] init];
        _typeLabel.textColor = UIColorFromRGB(0x2F84D0);
        _typeLabel.font = MKFont(13.f);
        _typeLabel.textAlignment = NSTextAlignmentCenter;
        _typeLabel.text = @"Low";
        [_typeLabel addTapAction:self selector:@selector(typeLabelPressed)];
    }
    return _typeLabel;
}

@end
