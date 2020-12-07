//
//  MKVibrationInfoCell.m
//  MKLoRaTracker
//
//  Created by aa on 2020/9/25.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKVibrationInfoCell.h"

@implementation MKVibrationInfoCellModel
@end

@interface MKVibrationInfoCell ()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UITextField *textField;

@end

@implementation MKVibrationInfoCell

+ (MKVibrationInfoCell *)initCellWithTableView:(UITableView *)tableView {
    MKVibrationInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MKVibrationInfoCellIdenty"];
    if (!cell) {
        cell = [[MKVibrationInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MKVibrationInfoCellIdenty"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.msgLabel];
        [self.contentView addSubview:self.textField];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(self.textField.mas_left).mas_offset(-10.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.width.mas_equalTo(100.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(35.f);
    }];
}

#pragma mark - event method
- (void)textFieldValueChanged {
    if (self.textField.text.length > 3) {
        return;
    }
    if (ValidStr(self.textField.text)) {
        self.textField.text = [NSString stringWithFormat:@"%ld",(long)[self.textField.text integerValue]];
    }
    if ([self.delegate respondsToSelector:@selector(advertiserParamsChanged:index:)]) {
        [self.delegate advertiserParamsChanged:self.textField.text index:self.dataModel.index];
    }
}

#pragma mark - setter
- (void)setDataModel:(MKVibrationInfoCellModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    self.msgLabel.text = SafeStr(_dataModel.msg);
    self.textField.placeholder = _dataModel.placeHolder;
    self.textField.text = _dataModel.value;
}

#pragma mark - getter
- (UILabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textColor = DEFAULT_TEXT_COLOR;
        _msgLabel.font = MKFont(15.f);
        _msgLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _msgLabel;
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] initWithTextFieldType:realNumberOnly];
        _textField.maxLength = 3;
        _textField.font = MKFont(13.f);
        _textField.textColor = DEFAULT_TEXT_COLOR;
        _textField.textAlignment = NSTextAlignmentCenter;
        [_textField addTarget:self
                       action:@selector(textFieldValueChanged)
             forControlEvents:UIControlEventEditingChanged];
        
        _textField.layer.masksToBounds = YES;
        _textField.layer.borderColor = CUTTING_LINE_COLOR.CGColor;
        _textField.layer.borderWidth = 0.3f;
        _textField.layer.cornerRadius = 6.f;
    }
    return _textField;
}

@end
