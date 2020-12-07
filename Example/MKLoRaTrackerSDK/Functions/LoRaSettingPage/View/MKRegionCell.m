//
//  MKRegionCell.m
//  MKLorawanGpsTracker
//
//  Created by aa on 2019/4/29.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKRegionCell.h"
#import "MKPickerView.h"

@interface MKRegionCell ()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UIButton *selectedButton;

@property (nonatomic, strong)NSDictionary *regionDataDic;

@end

@implementation MKRegionCell

+ (MKRegionCell *)initCellWithTableView:(UITableView *)tableView {
    MKRegionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MKRegionCellIdenty"];
    if (!cell) {
        cell = [[MKRegionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MKRegionCellIdenty"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.msgLabel];
        [self.contentView addSubview:self.selectedButton];
    }
    return self;
}

#pragma mark - super method
- (void)layoutSubviews {
    [super layoutSubviews];
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(self.selectedButton.mas_left).mas_offset(-5.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.selectedButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.width.mas_equalTo(130.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(30.f);
    }];
}

#pragma mark - event method
- (void)selectedButtonPressed {
    //隐藏其他cell里面的输入框键盘
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MKTextFieldNeedHiddenKeyboard" object:nil];
    NSArray *dataList = @[@"EU868",@"US915",@"CN779",@"EU433",@"AU915",@"CN470",@"AS923",@"KR920",@"IN865"];
    NSInteger row = 0;
    for (NSInteger i = 0; i < dataList.count; i ++) {
        if ([self.selectedButton.titleLabel.text isEqualToString:dataList[i]]) {
            row = i;
            break;
        }
    }
    MKPickerView *pickView = [[MKPickerView alloc] init];
    pickView.dataList = dataList;
    [pickView showPickViewWithIndex:row block:^(NSInteger currentRow) {
        [self.selectedButton setTitle:dataList[currentRow] forState:UIControlStateNormal];
        if ([self.delegate respondsToSelector:@selector(deviceRegionChanged:)]) {
            [self.delegate deviceRegionChanged:[self.regionDataDic[dataList[currentRow]] integerValue]];
        }
    }];
}

#pragma mark -
- (void)setRegion:(NSInteger)region {
    _region = region;
    NSString *key = [NSString stringWithFormat:@"%ld",(long)region];
    NSDictionary *dataDic = @{
        @"0":@"EU868",
        @"1":@"US915",
        @"2":@"US915HYBRID",
        @"3":@"CN779",
        @"4":@"EU433",
        @"5":@"AU915",
        @"6":@"AU915OLD",
        @"7":@"CN470",
        @"8":@"AS923",
        @"9":@"KR920",
        @"10":@"IN865",
        @"11":@"CN470",
        @"12":@"STE920",
    };
    NSString *title = dataDic[key];
    if (!title) {
        title = @"EU868";
    }
    [self.selectedButton setTitle:title forState:UIControlStateNormal];
}

#pragma mark - setter & getter
- (UILabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textColor = DEFAULT_TEXT_COLOR;
        _msgLabel.textAlignment = NSTextAlignmentLeft;
        _msgLabel.font = MKFont(15.f);
        _msgLabel.text = @"Region/Subnet";
    }
    return _msgLabel;
}

- (UIButton *)selectedButton {
    if (!_selectedButton) {
        _selectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectedButton setTitle:@"CN470" forState:UIControlStateNormal];
        [_selectedButton setTitleColor:COLOR_WHITE_MACROS forState:UIControlStateNormal];
        [_selectedButton setBackgroundColor:UIColorFromRGB(0x2F84D0)];
        [_selectedButton.layer setMasksToBounds:YES];
        [_selectedButton.layer setCornerRadius:6.f];
        [_selectedButton addTapAction:self selector:@selector(selectedButtonPressed)];
    }
    return _selectedButton;
}

- (NSDictionary *)regionDataDic {
    if (!_regionDataDic) {
        _regionDataDic = @{
            @"EU868":@(0),
            @"US915":@(1),
            @"US915HYBRID":@(2),
            @"CN779":@(3),
            @"EU433":@(4),
            @"AU915":@(5),
            @"AU915OLD":@(6),
            @"CN470":@(7),
            @"AS923":@(8),
            @"KR920":@(9),
            @"IN865":@(10),
            @"CN470":@(11),
            @"STE920":@(12),
        };
    }
    return _regionDataDic;
}

@end
