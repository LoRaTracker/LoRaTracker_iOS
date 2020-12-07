//
//  MKCDOptionsCell.m
//  MKLorawanGpsTracker
//
//  Created by aa on 2019/4/29.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKCDOptionsCell.h"
#import "MKCDOptionsCellModel.h"
#import "MKPickerView.h"

@interface MKCDOptionsCell ()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UIButton *leftButton;

@property (nonatomic, strong)UIButton *rightButton;

@end

@implementation MKCDOptionsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.backView addSubview:self.msgLabel];
        [self.backView addSubview:self.leftButton];
        [self.backView addSubview:self.rightButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.width.mas_equalTo(50.f);
        make.centerY.mas_equalTo(self.backView.mas_centerY);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.msgLabel.mas_right).mas_offset(10.f);
        make.width.mas_equalTo(50.f);
        make.centerY.mas_equalTo(self.backView.mas_centerY);
        make.height.mas_equalTo(30.f);
    }];
    [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftButton.mas_right).mas_offset(5.f);
        make.width.mas_equalTo(50.f);
        make.centerY.mas_equalTo(self.backView.mas_centerY);
        make.height.mas_equalTo(30.f);
    }];
}

#pragma mark - event method
- (void)functionButtonPressed:(UIButton *)sender {
    if (!self.dataModel.canShowList) {
        return;
    }
    MKPickerView *pickView = [[MKPickerView alloc] init];
    NSArray *dataList = self.dataModel.dataList;
    if (sender == self.rightButton) {
        //最大值
        NSInteger minIndex = [self pickSelectedRow:self.leftButton.titleLabel.text dataList:self.dataModel.dataList];
        dataList = [self.dataModel.dataList subarrayWithRange:NSMakeRange(minIndex, self.dataModel.dataList.count - minIndex)];
    }
    pickView.dataList = dataList;
    [pickView showPickViewWithIndex:[self pickSelectedRow:sender.titleLabel.text dataList:dataList] block:^(NSInteger currentRow) {
        [sender setTitle:dataList[currentRow] forState:UIControlStateNormal];
        if (sender == self.leftButton) {
            //如果是左侧的最小值改变之后判断当前最大值，如果最大值小于新设置的最小值，则让最大值等于最小值
            NSInteger valueL = [self pickSelectedRow:self.leftButton.titleLabel.text dataList:self.dataModel.dataList];
            NSInteger valueH = [self pickSelectedRow:self.rightButton.titleLabel.text dataList:self.dataModel.dataList];
            if (valueH < valueL) {
                [self.rightButton setTitle:dataList[currentRow] forState:UIControlStateNormal];
            }
        }
        [self delegateMethod];
    }];
}

- (void)delegateMethod {
    if ([self.delegate respondsToSelector:@selector(deviceCDOptionsChanged:valueL:valueH:)]) {
        NSInteger valueL = [self pickSelectedRow:self.leftButton.titleLabel.text dataList:self.dataModel.dataList];
        NSInteger valueH = [self pickSelectedRow:self.rightButton.titleLabel.text dataList:self.dataModel.dataList];
        [self.delegate deviceCDOptionsChanged:self.dataModel.row valueL:valueL valueH:valueH];
    }
}

#pragma mark -
- (void)setDataModel:(MKCDOptionsCellModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel) {
        return;
    }
    self.msgLabel.text = _dataModel.msg;
    [self.leftButton setTitle:_dataModel.dataList[_dataModel.valueL] forState:UIControlStateNormal];
    [self.rightButton setTitle:_dataModel.dataList[_dataModel.valueH] forState:UIControlStateNormal];
    [self.rightButton setHidden:!_dataModel.needHValue];
}

#pragma mark -
- (NSInteger)pickSelectedRow:(NSString *)selectedString dataList:(NSArray *)dataList {
    for (NSInteger i = 0; i < dataList.count; i ++) {
        if ([selectedString isEqualToString:dataList[i]]) {
            return i;
        }
    }
    return 0;
}

#pragma mark - setter & getter
- (UILabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textAlignment = NSTextAlignmentLeft;
        _msgLabel.textColor = DEFAULT_TEXT_COLOR;
        _msgLabel.font = MKFont(15.f);
    }
    return _msgLabel;
}

- (UIButton *)leftButton {
    if (!_leftButton) {
        _leftButton = [self button:@"0" selector:@selector(functionButtonPressed:)];
    }
    return _leftButton;
}

- (UIButton *)rightButton {
    if (!_rightButton) {
        _rightButton = [self button:@"0" selector:@selector(functionButtonPressed:)];
    }
    return _rightButton;
}

- (UIButton *)button:(NSString *)title selector:(SEL)selector {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:DEFAULT_TEXT_COLOR forState:UIControlStateNormal];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    
    button.layer.masksToBounds = YES;
    button.layer.borderColor = DEFAULT_TEXT_COLOR.CGColor;
    button.layer.borderWidth = 0.5f;
    button.layer.cornerRadius = 6.f;
    return button;
}

@end
