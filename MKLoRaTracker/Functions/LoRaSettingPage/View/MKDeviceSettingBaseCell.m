//
//  MKDeviceSettingBaseCell.m
//  MKLorawanGpsTracker
//
//  Created by aa on 2019/4/29.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKDeviceSettingBaseCell.h"

@interface MKDeviceSettingBaseCell ()

@property (nonatomic, strong)UIView *backView;

@property (nonatomic, strong)UIView *lineView;

@end

@implementation MKDeviceSettingBaseCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = COLOR_WHITE_MACROS;
        [self.contentView addSubview:self.backView];
        [self.backView addSubview:self.lineView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(0.5f);
    }];
}

- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] init];
        _backView.backgroundColor = RGBCOLOR(239, 239, 239);
    }
    return _backView;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = CUTTING_LINE_COLOR;
    }
    return _lineView;
}

@end
