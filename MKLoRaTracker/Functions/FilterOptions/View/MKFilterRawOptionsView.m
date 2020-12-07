//
//  MKFilterRawOptionsView.m
//  MKLoRaTracker
//
//  Created by aa on 2020/7/22.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKFilterRawOptionsView.h"

@interface MKFilterRawOptionsView ()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UISwitch *switchView;

@property (nonatomic, strong)UIButton *subButton;

@property (nonatomic, strong)UIButton *addButton;

@property (nonatomic, strong)UIView *lineView;

@end

@implementation MKFilterRawOptionsView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.msgLabel];
        [self addSubview:self.switchView];
        [self addSubview:self.subButton];
        [self addSubview:self.addButton];
        [self addSubview:self.lineView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.switchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.width.mas_equalTo(45.f);
        make.top.mas_equalTo(5.f);
        make.height.mas_equalTo(30.f);
    }];
    [self.subButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.switchView.mas_left).mas_offset(-10.f);
        make.width.mas_equalTo(30.f);
        make.centerY.mas_equalTo(self.switchView.mas_centerY);
        make.height.mas_equalTo(30.f);
    }];
    [self.addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.subButton.mas_left).mas_offset(-10.f);
        make.width.mas_equalTo(30.f);
        make.centerY.mas_equalTo(self.switchView.mas_centerY);
        make.height.mas_equalTo(30.f);
    }];
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.width.mas_equalTo(250.f);
        make.centerY.mas_equalTo(self.switchView.mas_centerY);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(CUTTING_LINE_HEIGHT);
    }];
}

#pragma mark - event method
- (void)switchViewValueChanged {
    [self reloadSubViews];
    if ([self.delegate respondsToSelector:@selector(filterRawDataStatusChanged:)]) {
        [self.delegate filterRawDataStatusChanged:self.switchView.isOn];
    }
}

- (void)addButtonPressed {
    if ([self.delegate respondsToSelector:@selector(addFilterRawDataConditions)]) {
        [self.delegate addFilterRawDataConditions];
    }
}

- (void)subButtonPressed {
    if ([self.delegate respondsToSelector:@selector(subFilterRawDataConditions)]) {
        [self.delegate subFilterRawDataConditions];
    }
}

#pragma mark - setter
- (void)setFilterIsOn:(BOOL)filterIsOn {
    _filterIsOn = filterIsOn;
    [self.switchView setOn:filterIsOn];
    [self reloadSubViews];
}

#pragma mark - private method
- (void)reloadSubViews {
    [self.addButton setHidden:!self.switchView.isOn];
    [self.subButton setHidden:!self.switchView.isOn];
}

#pragma mark - getter
- (UILabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textAlignment = NSTextAlignmentLeft;
        _msgLabel.font = MKFont(15.f);
        _msgLabel.textColor = DEFAULT_TEXT_COLOR;
        _msgLabel.text = @"Filter by Raw Adv Data";
    }
    return _msgLabel;
}

- (UISwitch *)switchView {
    if (!_switchView) {
        _switchView = [[UISwitch alloc] init];
        [_switchView addTarget:self
                        action:@selector(switchViewValueChanged)
              forControlEvents:UIControlEventValueChanged];
    }
    return _switchView;
}

- (UIButton *)addButton {
    if (!_addButton) {
        _addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addButton setImage:LOADIMAGE(@"filterRawDataAddIcon", @"png") forState:UIControlStateNormal];
        [_addButton addTapAction:self selector:@selector(addButtonPressed)];
    }
    return _addButton;
}

- (UIButton *)subButton {
    if (!_subButton) {
        _subButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_subButton setImage:LOADIMAGE(@"filterRawDataSubIcon", @"png") forState:UIControlStateNormal];
        [_subButton addTapAction:self selector:@selector(subButtonPressed)];
    }
    return _subButton;
}

-(UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = CUTTING_LINE_COLOR;
    }
    return _lineView;
}

@end
