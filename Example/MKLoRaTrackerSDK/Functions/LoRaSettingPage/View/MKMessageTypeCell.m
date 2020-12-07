//
//  MKMessageTypeCell.m
//  MKLoRaTracker
//
//  Created by aa on 2020/7/18.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKMessageTypeCell.h"
#import "MKPickerView.h"

@interface MKMessageTypeCell ()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UIButton *selectedButton;

@end

@implementation MKMessageTypeCell

+ (MKMessageTypeCell *)initCellWithTableView:(UITableView *)tableView {
    MKMessageTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MKMessageTypeCellIdenty"];
    if (!cell) {
        cell = [[MKMessageTypeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MKMessageTypeCellIdenty"];
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
    NSArray *dataList = @[@"Unconfirmed",@"Confirmed"];
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
            [self.delegate messageTypeChanged:currentRow];
        }
    }];
}

#pragma mark -
- (void)setMessageType:(NSInteger)messageType {
    _messageType = messageType;
    NSArray *dataList = @[@"Unconfirmed",@"Confirmed"];
    [self.selectedButton setTitle:dataList[messageType] forState:UIControlStateNormal];
}

#pragma mark - setter & getter
- (UILabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textColor = DEFAULT_TEXT_COLOR;
        _msgLabel.textAlignment = NSTextAlignmentLeft;
        _msgLabel.font = MKFont(15.f);
        _msgLabel.text = @"Message Type";
    }
    return _msgLabel;
}

- (UIButton *)selectedButton {
    if (!_selectedButton) {
        _selectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectedButton setTitle:@"Unconfirmed" forState:UIControlStateNormal];
        [_selectedButton setTitleColor:COLOR_WHITE_MACROS forState:UIControlStateNormal];
        [_selectedButton setBackgroundColor:UIColorFromRGB(0x2F84D0)];
        [_selectedButton.layer setMasksToBounds:YES];
        [_selectedButton.layer setCornerRadius:6.f];
        [_selectedButton addTapAction:self selector:@selector(selectedButtonPressed)];
    }
    return _selectedButton;
}

@end
