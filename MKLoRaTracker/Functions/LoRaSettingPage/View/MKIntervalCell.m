//
//  MKIntervalCell.m
//  MKLorawanGpsTracker
//
//  Created by aa on 2019/4/29.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKIntervalCell.h"

@interface MKIntervalCell ()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UITextField *textField;

@property (nonatomic, strong)UILabel *unitLabel;

@end

@implementation MKIntervalCell

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (MKIntervalCell *)initCellWithTableView:(UITableView *)tableView {
    MKIntervalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MKIntervalCellIdenty"];
    if (!cell) {
        cell = [[MKIntervalCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MKIntervalCellIdenty"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.backView addSubview:self.msgLabel];
        [self.backView addSubview:self.textField];
        [self.backView addSubview:self.unitLabel];
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
        make.width.mas_equalTo(210.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.msgLabel.mas_right).mas_offset(5.f);
        make.right.mas_equalTo(self.unitLabel.mas_left).mas_offset(-5.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(30.f);
    }];
    [self.unitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.width.mas_equalTo(50.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
}

#pragma mark - note
- (void)needHiddenKeyboard {
    [self.textField resignFirstResponder];
}

#pragma mark - event method
- (void)textFieldValueChanged {
    if ([self.delegate respondsToSelector:@selector(deviceReportIntervalChanged:)]) {
        [self.delegate deviceReportIntervalChanged:[self.textField.text integerValue]];
    }
}

#pragma mark -
- (void)setInterval:(NSInteger)interval {
    _interval = interval;
    self.textField.text = [NSString stringWithFormat:@"%ld",(long)interval];
}

#pragma mark - setter & getter

- (UILabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textColor = DEFAULT_TEXT_COLOR;
        _msgLabel.textAlignment = NSTextAlignmentLeft;
        _msgLabel.font = MKFont(15.f);
        _msgLabel.text = @"Non-Alarm Reporting Interval";
    }
    return _msgLabel;
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] initWithTextFieldType:realNumberOnly];
        _textField.backgroundColor = COLOR_WHITE_MACROS;
        _textField.layer.masksToBounds = YES;
        _textField.layer.borderWidth = 0.5f;
        _textField.layer.borderColor = DEFAULT_TEXT_COLOR.CGColor;
        _textField.layer.cornerRadius = 6.f;
        [_textField addTarget:self
                       action:@selector(textFieldValueChanged)
             forControlEvents:UIControlEventEditingChanged];
        _textField.prohibitedMethodsList = @[@"cut:",@"paste:",@"copy:",@"select:",@"selectAll:"];
    }
    return _textField;
}

- (UILabel *)unitLabel {
    if (!_unitLabel) {
        _unitLabel = [[UILabel alloc] init];
        _unitLabel.textAlignment = NSTextAlignmentLeft;
        _unitLabel.textColor = DEFAULT_TEXT_COLOR;
        _unitLabel.font = MKFont(15.f);
        _unitLabel.text = @"Min";
    }
    return _unitLabel;
}

@end
