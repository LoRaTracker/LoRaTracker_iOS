//
//  MKScannerPageController.m
//  MKContactTracker
//
//  Created by aa on 2020/4/22.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKScannerPageController.h"

#import "MKScannerDataModel.h"

#import "MKContactTrackerTextCell.h"
#import "MKScannerSliderCell.h"
#import "MKTrackingNotifiCell.h"
#import "MKAlarmTriggerRssiCell.h"
#import "MKVibIntenSityCell.h"
#import "MKVibrationInfoCell.h"

#import "MKFilterOptionsController.h"

@interface MKScannerPageController ()<UITableViewDelegate, UITableViewDataSource, MKScannerDelegate>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)MKScannerDataModel *dataModel;

@property (nonatomic, strong)NSMutableArray *cellList;

@end

@implementation MKScannerPageController

- (void)dealloc {
    NSLog(@"MKScannerPageController销毁");
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.view.shiftHeightAsDodgeViewForMLInputDodger = 50.0f;
    [self.view registerAsDodgeViewForMLInputDodgerWithOriginalY:self.view.frame.origin.y];
    [self readDatasFromDevice];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
}

#pragma mark - super method
- (void)rightButtonMethod {
    MKScannerDataModel *model = [[MKScannerDataModel alloc] init];
    [model updateWithDataModel:self.dataModel];
    if ([model.duration integerValue] > 10) {
        [self.view showCentralToast:@"Duration Of Vibration Error."];
        return;
    }
    if ([model.duration integerValue] > [model.vibCycle integerValue]) {
        [self.view showCentralToast:@"Vibration Cycle should be no less than Duration of  Vibration."];
        return;
    }
    [[MKHudManager share] showHUDWithTitle:@"Setting..." inView:self.view isPenetration:NO];
    WS(weakSelf);
    [self.dataModel startConfigDatas:model sucBlock:^{
        [[MKHudManager share] hide];
        [weakSelf.view showCentralToast:@"Success"];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [weakSelf.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

- (void)leftButtonMethod {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MKPopToRootViewControllerNotification" object:nil];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1 || indexPath.row == self.cellList.count - 1) {
        return 90.f;
    }
    
    return 44.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        MKFilterOptionsController *vc = [[MKFilterOptionsController alloc] init];
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
        self.hidesBottomBarWhenPushed = NO;
        return;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cellList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.cellList[indexPath.row];
}

#pragma mark - MKScannerDelegate
- (void)advertiserParamsChanged:(id)newValue index:(NSInteger)index {
    if (index == 0) {
        //Valid BLE Data Filter Interval
        self.dataModel.interval = (NSString *)newValue;
        return;
    }
    if (index == 1) {
        //trackingNote
        self.dataModel.alarmNote = [newValue integerValue];
        return;
    }
    if (index == 2) {
        //Vibration Intensity
        self.dataModel.intenSity = [newValue integerValue];
        return;
    }
    if (index == 3) {
        //Vibration Cycle
        self.dataModel.vibCycle = (NSString *)newValue;
        return;
    }
    if (index == 4) {
        //Duration Of Vibration
        self.dataModel.duration = (NSString *)newValue;
        return;
    }
    if (index == 5) {
        //Alarm Trigger RSSI
        self.dataModel.triggerRssi = (NSString *)newValue;
        return;
    }
}

#pragma mark - interface
- (void)readDatasFromDevice {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    WS(weakSelf);
    [self.dataModel startReadDatasWithSucBlock:^{
        [[MKHudManager share] hide];
        [weakSelf loadCellList];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [weakSelf.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - Private method
- (void)loadCellList {
    [self.cellList removeAllObjects];
    MKContactTrackerTextCell *optionsCell = [MKContactTrackerTextCell initCellWithTableView:self.tableView];
    MKContactTrackerTextCellModel *optionsDataModel = [[MKContactTrackerTextCellModel alloc] init];
    optionsDataModel.leftMsg = @"Filter Options";
    optionsDataModel.showRightIcon = YES;
    optionsCell.dataModel = optionsDataModel;
    [self.cellList addObject:optionsCell];
    
    MKScannerSliderCell *sliderCell = [MKScannerSliderCell initCellWithTableView:self.tableView];
    sliderCell.interval = self.dataModel.interval;
    sliderCell.delegate = self;
    [self.cellList addObject:sliderCell];
    
    MKTrackingNotifiCell *noteCell = [MKTrackingNotifiCell initCellWithTableView:self.tableView];
    noteCell.trackingNote = self.dataModel.alarmNote;
    noteCell.delegate = self;
    [self.cellList addObject:noteCell];
    
    MKVibIntenSityCell *intensityCell = [MKVibIntenSityCell initCellWithTableView:self.tableView];
    intensityCell.intensity = self.dataModel.intenSity;
    intensityCell.delegate = self;
    [self.cellList addObject:intensityCell];
    
    MKVibrationInfoCell *cycleCell = [MKVibrationInfoCell initCellWithTableView:self.tableView];
    cycleCell.delegate = self;
    MKVibrationInfoCellModel *cycleModel = [[MKVibrationInfoCellModel alloc] init];
    cycleModel.msg = @"Vibration Cycle";
    cycleModel.placeHolder = @"1~600s";
    cycleModel.value = self.dataModel.vibCycle;
    cycleModel.index = 3;
    cycleCell.dataModel = cycleModel;
    [self.cellList addObject:cycleCell];
    
    MKVibrationInfoCell *durationCell = [MKVibrationInfoCell initCellWithTableView:self.tableView];
    durationCell.delegate = self;
    MKVibrationInfoCellModel *durationModel = [[MKVibrationInfoCellModel alloc] init];
    durationModel.msg = @"Duration Of Vibration";
    durationModel.placeHolder = @"0~10s";
    durationModel.value = self.dataModel.duration;
    durationModel.index = 4;
    durationCell.dataModel = durationModel;
    [self.cellList addObject:durationCell];
    
    MKAlarmTriggerRssiCell *rssiSliderCell = [MKAlarmTriggerRssiCell initCellWithTableView:self.tableView];
    rssiSliderCell.alarmTriggerRssi = self.dataModel.triggerRssi;
    rssiSliderCell.delegate = self;
    [self.cellList addObject:rssiSliderCell];
    
    [self.tableView reloadData];
}

#pragma mark - UI
- (void)loadSubViews {
    self.custom_naviBarColor = UIColorFromRGB(0x2F84D0);
    self.titleLabel.textColor = COLOR_WHITE_MACROS;
    self.defaultTitle = @"SCANNER";
    self.view.backgroundColor = COLOR_WHITE_MACROS;
    [self.rightButton setImage:LOADIMAGE(@"slotSaveIcon", @"png") forState:UIControlStateNormal];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(defaultTopInset);
        make.bottom.mas_equalTo(-VirtualHomeHeight - 49.f);
    }];
}

#pragma mark - getter
- (MKBaseTableView *)tableView {
    if (!_tableView) {
        _tableView = [[MKBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = COLOR_WHITE_MACROS;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (NSMutableArray *)cellList {
    if (!_cellList) {
        _cellList = [NSMutableArray array];
    }
    return _cellList;
}

- (MKScannerDataModel *)dataModel {
    if (!_dataModel) {
        _dataModel = [[MKScannerDataModel alloc] init];
    }
    return _dataModel;
}

@end
