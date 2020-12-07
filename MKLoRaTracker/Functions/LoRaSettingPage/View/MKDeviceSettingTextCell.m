//
//  MKDeviceSettingTextCell.m
//  MKLorawanGpsTracker
//
//  Created by aa on 2019/4/29.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKDeviceSettingTextCell.h"
#import "MKDeviceSettingTextCellModel.h"

@interface MKDeviceSettingTextCell ()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UITextField *textField;

@end

@implementation MKDeviceSettingTextCell

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (MKDeviceSettingTextCell *)initCellWithTableView:(UITableView *)table {
    MKDeviceSettingTextCell *cell = [table dequeueReusableCellWithIdentifier:@"MKDeviceSettingTextCellIdenty"];
    if (!cell) {
        cell = [[MKDeviceSettingTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MKDeviceSettingTextCellIdenty"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.backView addSubview:self.msgLabel];
        [self.backView addSubview:self.textField];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(needHiddenKeyboard)
                                                     name:@"MKTextFieldNeedHiddenKeyboard"
                                                   object:nil];
    }
    return self;
}

#pragma mark - super method
- (void)layoutSubviews {
    [super layoutSubviews];
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.width.mas_equalTo(80.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.msgLabel.mas_right).mas_offset(5.f);
        make.right.mas_equalTo(-15.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(30.f);
    }];
}

#pragma mark - note
- (void)needHiddenKeyboard {
    [self.textField resignFirstResponder];
}

#pragma mark - event method
- (void)textFieldValueChanged {
    NSString *text = [self.textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (text.length > self.dataModel.maxLen) {
        text = [text substringWithRange:NSMakeRange(0, self.dataModel.maxLen)];
    }
    if ([self.delegate respondsToSelector:@selector(MKDeviceTextCellValueChanged:value:)]) {
        [self.delegate MKDeviceTextCellValueChanged:self.dataModel.index value:text];
    }
}

#pragma mark -
- (void)setDataModel:(MKDeviceSettingTextCellModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel) {
        return;
    }
    if (ValidStr(_dataModel.msg)) {
        self.msgLabel.text = _dataModel.msg;
    }else {
        self.msgLabel.text = @"";
    }
    if (ValidStr(_dataModel.value)) {
        self.textField.text = _dataModel.value;
    }else {
        self.textField.text = @"";
    }
    self.textField.maxLength = _dataModel.maxLen;
}

#pragma mark - setter & getter

- (UILabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textColor = DEFAULT_TEXT_COLOR;
        _msgLabel.textAlignment = NSTextAlignmentLeft;
        _msgLabel.font = MKFont(15.f);
    }
    return _msgLabel;
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] initWithTextFieldType:hexCharOnly];
        _textField.backgroundColor = COLOR_WHITE_MACROS;
        _textField.textColor = DEFAULT_TEXT_COLOR;
        _textField.layer.masksToBounds = YES;
        _textField.layer.borderWidth = 0.5f;
        _textField.layer.borderColor = DEFAULT_TEXT_COLOR.CGColor;
        _textField.layer.cornerRadius = 6.f;
        _textField.clearButtonMode = UITextFieldViewModeAlways;
        [_textField addTarget:self
                       action:@selector(textFieldValueChanged)
             forControlEvents:UIControlEventEditingChanged];
    }
    return _textField;
}

@end
