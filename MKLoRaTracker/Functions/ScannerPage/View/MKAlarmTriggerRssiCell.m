//
//  MKAlarmTriggerRssiCell.m
//  MKLoRaTracker
//
//  Created by aa on 2020/7/18.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKAlarmTriggerRssiCell.h"
#import "MKSlider.h"

static NSString *const noteMsg = @"*The device alarm  is triggered when the BLE RSSI scanned is greater than -20dbm.";

@interface MKAlarmTriggerRssiCell ()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)MKSlider *alarmTriggerRssiSlider;

@property (nonatomic, strong)UILabel *alarmTriggerRssiLabel;

@property (nonatomic, strong)UILabel *noteLabel;

@end

@implementation MKAlarmTriggerRssiCell

+ (MKAlarmTriggerRssiCell *)initCellWithTableView:(UITableView *)tableView {
    MKAlarmTriggerRssiCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MKAlarmTriggerRssiCellIdenty"];
    if (!cell) {
        cell = [[MKAlarmTriggerRssiCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MKAlarmTriggerRssiCellIdenty"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.msgLabel];
        [self.contentView addSubview:self.alarmTriggerRssiSlider];
        [self.contentView addSubview:self.alarmTriggerRssiLabel];
        [self.contentView addSubview:self.noteLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(5.f);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.alarmTriggerRssiSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(self.alarmTriggerRssiLabel.mas_left).mas_offset(-5.f);
        make.top.mas_equalTo(self.msgLabel.mas_bottom).mas_offset(5.f);
        make.height.mas_equalTo(20.f);
    }];
    [self.alarmTriggerRssiLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.width.mas_equalTo(60.f);
        make.centerY.mas_equalTo(self.alarmTriggerRssiSlider.mas_centerY);
        make.height.mas_equalTo(MKFont(11.f).lineHeight);
    }];
    CGSize size = [NSString sizeWithText:noteMsg
                                 andFont:MKFont(12.f)
                              andMaxSize:CGSizeMake(kScreenWidth - 2 * 15.f, MAXFLOAT)];
    [self.noteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.bottom.mas_equalTo(-5.f);
        make.height.mas_equalTo(size.height);
    }];
}

#pragma mark - event method
- (void)alarmTriggerRssiSliderValueChanged {
    self.alarmTriggerRssiLabel.text = [NSString stringWithFormat:@"%.fdBm",self.alarmTriggerRssiSlider.value];
    [self updateNoteMsg];
    if ([self.delegate respondsToSelector:@selector(advertiserParamsChanged:index:)]) {
        [self.delegate advertiserParamsChanged:[NSString stringWithFormat:@"%.f",self.alarmTriggerRssiSlider.value] index:5];
    }
}

#pragma mark - setter
- (void)setAlarmTriggerRssi:(NSString *)alarmTriggerRssi {
    _alarmTriggerRssi = nil;
    _alarmTriggerRssi = alarmTriggerRssi;
    self.alarmTriggerRssiSlider.value = [alarmTriggerRssi floatValue];
    self.alarmTriggerRssiLabel.text = [NSString stringWithFormat:@"%.fdBm",self.alarmTriggerRssiSlider.value];
    [self updateNoteMsg];
}

#pragma mark - private method
- (void)updateNoteMsg {
    self.noteLabel.text = [NSString stringWithFormat:@"*The device alarm  is triggered when the BLE RSSI scanned is greater than %@.",self.alarmTriggerRssiLabel.text];
}

#pragma mark - getter
- (UILabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textAlignment = NSTextAlignmentLeft;
        _msgLabel.attributedText = [MKAttributedString getAttributedString:@[@"Alarm Trigger RSSI",@"   -127-0dBm"] fonts:@[MKFont(15.f),MKFont(12.f)] colors:@[DEFAULT_TEXT_COLOR,RGBCOLOR(223, 223, 223)]];
    }
    return _msgLabel;
}

- (MKSlider *)alarmTriggerRssiSlider {
    if (!_alarmTriggerRssiSlider) {
        _alarmTriggerRssiSlider = [[MKSlider alloc] init];
        _alarmTriggerRssiSlider.maximumValue = 0.f;
        _alarmTriggerRssiSlider.minimumValue = -127.f;
        _alarmTriggerRssiSlider.value = -20;
        [_alarmTriggerRssiSlider addTarget:self
                            action:@selector(alarmTriggerRssiSliderValueChanged)
                  forControlEvents:UIControlEventValueChanged];
    }
    return _alarmTriggerRssiSlider;
}

- (UILabel *)alarmTriggerRssiLabel {
    if (!_alarmTriggerRssiLabel) {
        _alarmTriggerRssiLabel = [[UILabel alloc] init];
        _alarmTriggerRssiLabel.textColor = DEFAULT_TEXT_COLOR;
        _alarmTriggerRssiLabel.textAlignment = NSTextAlignmentLeft;
        _alarmTriggerRssiLabel.font = MKFont(11.f);
        _alarmTriggerRssiLabel.text = @"-20dBm";
    }
    return _alarmTriggerRssiLabel;
}

- (UILabel *)noteLabel {
    if (!_noteLabel) {
        _noteLabel = [[UILabel alloc] init];
        _noteLabel.textAlignment = NSTextAlignmentLeft;
        _noteLabel.textColor = RGBCOLOR(193, 88, 38);
        _noteLabel.text = noteMsg;
        _noteLabel.numberOfLines = 0;
        _noteLabel.font = MKFont(12.f);
    }
    return _noteLabel;
}

@end
