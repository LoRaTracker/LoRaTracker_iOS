//
//  MKFilterOptionsController.m
//  MKLoRaTracker
//
//  Created by aa on 2020/7/22.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKFilterOptionsController.h"

#import "MKFilterOptionsHeaderView.h"
#import "MKFilterRawOptionsView.h"

#import "MKAdvDataFliterCell.h"
#import "MKFilterMajorMinorCell.h"
#import "MKFilterRawDataCell.h"

#import "MKFilterMajorMinorCellModel.h"
#import "MKAdvDataFliterCellModel.h"
#import "MKFilterOptionsModel.h"
#import "MKFilterRawDataCellModel.h"

static NSInteger const statusOnHeight = 85.f;
static NSInteger const statusOffHeight = 44.f;

@interface MKFilterOptionsController ()
<UITableViewDelegate,
UITableViewDataSource,
MKAdvDataFliterCellDelegate,
MKFliterRssiValueCellDelegate,
MKFilterMajorMinorCellDelegate,
MKFilterRawDataCellDelegate,
MKFilterRawMsgCellDelegate>

/// section0:mac地址、advName过滤------------------>MKAdvDataFliterCell
/// section1:Major、Minor范围值过滤------------------>MKFilterMajorMinorCell
/// section2:Raw过滤------------------>MKFilterRawDataCell
@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)MKFilterOptionsHeaderView *tableHeaderView;

@property (nonatomic, strong)MKFilterRawOptionsView *rawOptionsView;

/// mac地址、advName过滤------------------>MKAdvDataFliterCell
@property (nonatomic, strong)NSMutableArray *section0List;

/// Major、Minor范围值过滤------------------>MKFilterMajorMinorCell
@property (nonatomic, strong)NSMutableArray *section1List;

/// Raw过滤------------------>MKFilterRawDataCell
@property (nonatomic, strong)NSMutableArray *section2List;

@property (nonatomic, strong)MKFilterOptionsModel *optionsModel;

@end

@implementation MKFilterOptionsController

- (void)dealloc {
    NSLog(@"MKFilterOptionsController销毁");
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.view.shiftHeightAsDodgeViewForMLInputDodger = 50.0f;
    [self.view registerAsDodgeViewForMLInputDodgerWithOriginalY:self.view.frame.origin.y];
    //本页面禁止右划退出手势
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self startReadDataFromDevice];
}

#pragma mark - super method
- (void)rightButtonMethod {
    [[MKHudManager share] showHUDWithTitle:@"Setting..." inView:self.view isPenetration:NO];
    WS(weakSelf);
    [self.optionsModel startConfigData:self.section2List sucBlock:^{
        [[MKHudManager share] hide];
        [weakSelf.view showCentralToast:@"Success"];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [weakSelf.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self loadCellHeightWithIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 2) {
        return 44.f;
    }
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 2) {
        return self.rawOptionsView;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0.01)];
    view.backgroundColor = COLOR_WHITE_MACROS;
    return view;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.section0List.count;
    }
    if (section == 1) {
        return self.section1List.count;
    }
    
    return (self.optionsModel.filterRawDataIsOn ? self.section2List.count : 0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self loadCellWithIndexPath:indexPath];
}

#pragma mark - MKFliterRssiValueCellDelegate
- (void)mk_fliterRssiValueChanged:(NSInteger)rssi {
    self.optionsModel.rssiValue = rssi;
}

#pragma mark - MKAdvDataFliterCellDelegate
- (void)advDataFliterCellSwitchStatusChanged:(BOOL)isOn index:(NSInteger)index {
    if (index == 0) {
        //mac address
        self.optionsModel.macIson = isOn;
    }else if (index == 1) {
        //adv name
        self.optionsModel.advNameIson = isOn;
    }
    MKAdvDataFliterCellModel *dataModel = self.section0List[index];
    dataModel.isOn = isOn;
    [self.tableView reloadRow:index inSection:0 withRowAnimation:UITableViewRowAnimationNone];
}

- (void)advertiserFilterContent:(NSString *)newValue index:(NSInteger)index {
    if (index == 0) {
        //mac address
        self.optionsModel.macValue = newValue;
    }else if (index == 1) {
        //adv name
        self.optionsModel.advNameValue = newValue;
    }
    MKAdvDataFliterCellModel *dataModel = self.section0List[index];
    dataModel.textFieldValue = newValue;
}

#pragma mark - MKFilterMajorMinorCellDelegate
- (void)majorMinorFliterSwitchStatusChanged:(BOOL)isOn index:(NSInteger)index {
    if (index == 0) {
        //Major
        self.optionsModel.majorIson = isOn;
    }else if (index == 1) {
        //Minor
        self.optionsModel.minorIson = isOn;
    }
    MKFilterMajorMinorCellModel *dataModel = self.section1List[index];
    dataModel.isOn = isOn;
    [self.tableView reloadRow:index inSection:1 withRowAnimation:UITableViewRowAnimationNone];
}

- (void)filterMaxValueContentChanged:(NSString *)newValue index:(NSInteger)index {
    if (index == 0) {
        self.optionsModel.majorMaxValue = newValue;
    }else if (index == 1) {
        self.optionsModel.minorMaxValue = newValue;
    }
    MKFilterMajorMinorCellModel * dataModel = self.section1List[index];
    dataModel.maxValue = newValue;
}

- (void)filterMinValueContentChanged:(NSString *)newValue index:(NSInteger)index {
    if (index == 0) {
        self.optionsModel.majorMinValue = newValue;
    }else if (index == 1) {
        self.optionsModel.minorMinValue = newValue;
    }
    MKFilterMajorMinorCellModel * dataModel = self.section1List[index];
    dataModel.minValue = newValue;
}

#pragma mark - MKFilterRawDataCellDelegate
/// 输入框内容发生改变
/// @param textType 哪个输入框发生改变了
/// @param index 当前cell所在的row
/// @param textValue 当前textField内容
- (void)rawFilterDataChanged:(mk_filterRawDataCellTextType)textType
                       index:(NSInteger)index
                   textValue:(NSString *)textValue {
    if (index >= self.section2List.count) {
        return;
    }
    MKFilterRawDataCellModel *model = self.section2List[index];
    if (textType == mk_filterRawDataCellTextTypeDataType) {
        model.dataType = textValue;
    }else if (textType == mk_filterRawDataCellTextTypeMinIndex) {
        model.minIndex = textValue;
    }else if (textType == mk_filterRawDataCellTextTypeMaxIndex) {
        model.maxIndex = textValue;
    }else if (textType == mk_filterRawDataCellTextTypeRawDataType) {
        model.rawData = textValue;
    }
}

#pragma mark - MKFilterRawMsgCellDelegate
- (void)filterRawDataStatusChanged:(BOOL)isOn {
    self.optionsModel.filterRawDataIsOn = isOn;
    [self.tableView reloadSection:2 withRowAnimation:UITableViewRowAnimationNone];
}

- (void)addFilterRawDataConditions {
    if (!self.optionsModel.filterRawDataIsOn) {
        return;
    }
    [self addButtonPressed];
}

- (void)subFilterRawDataConditions {
    if (!self.optionsModel.filterRawDataIsOn) {
        return;
    }
    [self subButtonPressed];
}

#pragma mark - event method
- (void)subButtonPressed {
    if (self.section2List.count == 0) {
        [self.view showCentralToast:@"There are currently no filters to delete"];
        return;
    }
    NSString *msg = @"Please confirm whether to delete  a filter option，If yes，the last option will be deleted.";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Warning!"
                                                                             message:msg
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    WS(weakSelf);
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:cancelAction];
    UIAlertAction *moreAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf deleteRawDataFilterDatas];
    }];
    [alertController addAction:moreAction];
    
    [kAppRootController presentViewController:alertController animated:YES completion:nil];
}

- (void)addButtonPressed {
    if (self.section2List.count >= 5) {
        [self.view showCentralToast:@"You can set up to 5 filters!"];
        return;
    }
    MKFilterRawDataCellModel *dataModel = [[MKFilterRawDataCellModel alloc] init];
    [self.section2List addObject:dataModel];
    [UIView performWithoutAnimation:^{
        [self.tableView reloadSection:2 withRowAnimation:UITableViewRowAnimationNone];
    }];
}

#pragma mark - tableView相关方法
- (CGFloat)loadCellHeightWithIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return (self.optionsModel.macIson ? statusOnHeight : statusOffHeight);
        }
        if (indexPath.row == 1) {
            return (self.optionsModel.advNameIson ? statusOnHeight : statusOffHeight);
        }
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            return (self.optionsModel.majorIson ? statusOnHeight : statusOffHeight);
        }
        if (indexPath.row == 1) {
            return (self.optionsModel.minorIson ? statusOnHeight : statusOffHeight);
        }
    }
    return 95.f;
}

- (UITableViewCell *)loadCellWithIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        MKAdvDataFliterCell *cell = [MKAdvDataFliterCell initCellWithTableView:self.tableView];
        cell.dataModel = self.section0List[indexPath.row];
        cell.delegate = self;
        return cell;
    }
    if (indexPath.section == 1) {
        MKFilterMajorMinorCell *cell = [MKFilterMajorMinorCell initCellWithTableView:self.tableView];
        cell.dataModel = self.section1List[indexPath.row];
        cell.delegate = self;
        return cell;
    }
    MKFilterRawDataCell *cell = [MKFilterRawDataCell initCellWithTableView:self.tableView];
    cell.dataModel = self.section2List[indexPath.row];
    cell.indexPath = indexPath;
    cell.delegate = self;
    return cell;
}

#pragma mark - Private method

- (void)startReadDataFromDevice {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    WS(weakSelf);
    [self.optionsModel startReadDataWithSucBlock:^{
        [weakSelf loadFilterOptionDatas];
        weakSelf.rawOptionsView.filterIsOn = weakSelf.optionsModel.filterRawDataIsOn;
        weakSelf.tableHeaderView.rssi = weakSelf.optionsModel.rssiValue;
        [[MKHudManager share] hide];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [weakSelf.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

- (void)loadFilterOptionDatas {
    MKAdvDataFliterCellModel *macModel = [[MKAdvDataFliterCellModel alloc] init];
    macModel.msg = @"Filter by MAC Address";
    macModel.textPlaceholder = @"1 ~ 6 Bytes";
    macModel.textFieldType = hexCharOnly;
    macModel.maxLength = 12;
    macModel.index = 0;
    macModel.textFieldValue = self.optionsModel.macValue;
    macModel.isOn = self.optionsModel.macIson;
    [self.section0List addObject:macModel];
    
    MKAdvDataFliterCellModel *advNameModel = [[MKAdvDataFliterCellModel alloc] init];
    advNameModel.msg = @"Filter by ADV Name";
    advNameModel.textPlaceholder = @"1 ~ 10 Characters";
    advNameModel.textFieldType = normalInput;
    advNameModel.maxLength = 10;
    advNameModel.index = 1;
    advNameModel.textFieldValue = self.optionsModel.advNameValue;
    advNameModel.isOn = self.optionsModel.advNameIson;
    [self.section0List addObject:advNameModel];
    
    MKFilterMajorMinorCellModel *majorModel = [[MKFilterMajorMinorCellModel alloc] init];
    majorModel.msg = @"Filter by iBeacon Major";
    majorModel.minValue = self.optionsModel.majorMinValue;
    majorModel.maxValue = self.optionsModel.majorMaxValue;
    majorModel.index = 0;
    majorModel.isOn = self.optionsModel.majorIson;
    [self.section1List addObject:majorModel];
    
    MKFilterMajorMinorCellModel *minorModel = [[MKFilterMajorMinorCellModel alloc] init];
    minorModel.msg = @"Filter by iBeacon Minor";
    minorModel.minValue = self.optionsModel.minorMinValue;
    minorModel.maxValue = self.optionsModel.minorMaxValue;
    minorModel.index = 1;
    minorModel.isOn = self.optionsModel.minorIson;
    [self.section1List addObject:minorModel];
    
    [self.section2List removeAllObjects];
    [self.section2List addObjectsFromArray:self.optionsModel.filterRawDataList];
    
    [self.tableView reloadData];
}

- (void)deleteRawDataFilterDatas {
    [self.section2List removeLastObject];
    if (self.section2List.count == 0) {
        self.optionsModel.filterRawDataIsOn = NO;
        self.rawOptionsView.filterIsOn = NO;
    }
    [UIView performWithoutAnimation:^{
        [self.tableView reloadSection:2 withRowAnimation:UITableViewRowAnimationNone];
    }];
}

#pragma mark - UI
- (void)loadSubViews {
    self.custom_naviBarColor = UIColorFromRGB(0x2F84D0);
    self.titleLabel.textColor = COLOR_WHITE_MACROS;
    self.defaultTitle = @"FILTER OPTIONS";
    self.view.backgroundColor = COLOR_WHITE_MACROS;
    [self.rightButton setImage:LOADIMAGE(@"slotSaveIcon", @"png") forState:UIControlStateNormal];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(defaultTopInset);
        make.bottom.mas_equalTo(-VirtualHomeHeight);
    }];
}

#pragma mark - getter

- (MKFilterOptionsHeaderView *)tableHeaderView {
    if (!_tableHeaderView) {
        _tableHeaderView = [[MKFilterOptionsHeaderView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 80.f)];
        _tableHeaderView.delegate = self;
    }
    return _tableHeaderView;
}

- (MKFilterRawOptionsView *)rawOptionsView {
    if (!_rawOptionsView) {
        _rawOptionsView = [[MKFilterRawOptionsView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44.f)];
        _rawOptionsView.delegate = self;
    }
    return _rawOptionsView;
}

- (MKBaseTableView *)tableView {
    if (!_tableView) {
        _tableView = [[MKBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = COLOR_WHITE_MACROS;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        _tableView.tableHeaderView = self.tableHeaderView;
    }
    return _tableView;
}

- (MKFilterOptionsModel *)optionsModel {
    if (!_optionsModel) {
        _optionsModel = [[MKFilterOptionsModel alloc] init];
    }
    return _optionsModel;
}

- (NSMutableArray *)section0List {
    if (!_section0List) {
        _section0List = [NSMutableArray array];
    }
    return _section0List;
}

- (NSMutableArray *)section1List {
    if (!_section1List) {
        _section1List = [NSMutableArray array];
    }
    return _section1List;
}

- (NSMutableArray *)section2List {
    if (!_section2List) {
        _section2List = [NSMutableArray array];
    }
    return _section2List;
}

@end
