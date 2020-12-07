//
//  MKSettingTableViewCell.m
//  MKLoRaTracker
//
//  Created by aa on 2020/7/31.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKSettingTableViewCell.h"

@implementation MKSettingTableViewCellModel

@end

@interface MKSettingTableViewCell ()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UIImageView *rightIcon;

@end

@implementation MKSettingTableViewCell

+ (MKSettingTableViewCell *)initCellWithTableView:(UITableView *)tableView {
    MKSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MKSettingTableViewCellIdenty"];
    if (!cell) {
        cell = [[MKSettingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MKSettingTableViewCellIdenty"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.msgLabel];
        [self.contentView addSubview:self.rightIcon];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(self.rightIcon.mas_left).mas_offset(-5.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.rightIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.width.mas_equalTo(8.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(14.f);
    }];
}

#pragma mark - setter
- (void)setDataModel:(MKSettingTableViewCellModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel) {
        return;
    }
    self.msgLabel.text = SafeStr(_dataModel.leftMsg);
}

#pragma mark - getter
- (UILabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textColor = DEFAULT_TEXT_COLOR;
        _msgLabel.textAlignment = NSTextAlignmentLeft;
        _msgLabel.font = MKFont(15.f);
    }
    return _msgLabel;
}

- (UIImageView *)rightIcon {
    if (!_rightIcon) {
        _rightIcon = [[UIImageView alloc] init];
        _rightIcon.image = LOADIMAGE(@"goto_next_button", @"png");
    }
    return _rightIcon;
}

@end
