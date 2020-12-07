//
//  MKLoRaSettingController.m
//  MKLoRaTracker
//
//  Created by aa on 2020/7/18.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKLoRaSettingController.h"

#import "MKDeviceSettingProtocol.h"

#import "MKDeviceSettingTextCell.h"
#import "MKMessageTypeCell.h"
#import "MKRegionCell.h"
#import "MKIntervalCell.h"
#import "MKCDOptionsCell.h"

#import "MKPickerView.h"

#import "MKDeviceSettingModel.h"
#import "MKDeviceSettingTextCellModel.h"
#import "MKCDOptionsCellModel.h"

static CGFloat const headerModeViewHeight = 50.f;
static CGFloat const modeButtonWidth = 50.f;
static CGFloat const modeButtonHeight = 40.f;
static CGFloat const optionalViewHeight = 70.f;

@interface MKLoRaSettingController ()<
UITableViewDelegate,
UITableViewDataSource,
MKDeviceSettingTextCellDelegate,
MKDeviceSettingRegionDelegate,
MKDeviceSettingMessageTypeDelegate,
MKDeviceSettingReportIntervalDelegate,
MKDeviceSettingCDOptionsDelegate
>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)UIButton *modeButton;

@property (nonatomic, strong)UISwitch *ADRSwitch;

@property (nonatomic, strong)UISwitch *optionalSwitch;

@property (nonatomic, strong)NSMutableArray *section0List;

@property (nonatomic, strong)NSMutableArray *section1List;

@property (nonatomic, strong)NSMutableArray *section2List;

@property (nonatomic, strong)NSMutableArray *section3List;

@property (nonatomic, strong)NSMutableArray <MKCDOptionsCellModel *>*optionsList;

@property (nonatomic, assign)BOOL isDebugMode;

@property (nonatomic, strong)MKDeviceSettingModel *settingModel;

@end

@implementation MKLoRaSettingController

- (void)dealloc {
    NSLog(@"MKLoRaSettingController销毁");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.view.shiftHeightAsDodgeViewForMLInputDodger = 50.f;
    [self.view registerAsDodgeViewForMLInputDodgerWithOriginalY:self.view.frame.origin.y];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self readDatasFromDevice];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return headerModeViewHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 2) {
        return optionalViewHeight;
    }
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 2) {
        return [self fetchAdvancedSettingView];
    }
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0.01)];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (self.isDebugMode ? 4 : 3);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.section0List.count;
    }
    if (section == 1) {
        return self.section1List.count;
    }
    if (section == 2) {
        return self.section2List.count;
    }
    return self.section3List.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return self.section0List[indexPath.row];
    }
    if (indexPath.section == 1) {
        return self.section1List[indexPath.row];
    }
    if (indexPath.section == 2) {
        return self.section2List[indexPath.row];
    }
    return self.section3List[indexPath.row];
}

#pragma mark - MKDeviceSettingTextCellDelegate
- (void)MKDeviceTextCellValueChanged:(NSInteger)index value:(NSString *)value {
    if (index == 0) {
        //DevEUI
        self.settingModel.devEUI = value;
        return;
    }
    if (index == 1) {
        //AppEUI
        self.settingModel.appEUI = value;
        return;
    }
    if (index == 2) {
        //DevAddr
        self.settingModel.devAddr = value;
        return;
    }
    if (index == 3) {
        //AppSkey
        self.settingModel.appSKey = value;
        return;
    }
    if (index == 4) {
        //NwkSkey
        self.settingModel.nwkSKey = value;
        return;
    }
    if (index == 5) {
        //AppKey
        self.settingModel.appKey = value;
        return;
    }
}

#pragma mark - MKDeviceSettingRegionDelegate
- (void)deviceRegionChanged:(NSInteger)region {
    self.settingModel.region = region;
    self.settingModel.CHHValue = [MKCDOptionsCellModel fetchCHHValue:region];
    self.settingModel.CHLValue = [MKCDOptionsCellModel fetchCHLValue:region];
    self.settingModel.DRValue = [MKCDOptionsCellModel fetchDRValue:region];
    if (self.isDebugMode) {
        //选择了频段，
        [self loadSection3Datas];
        [self.tableView reloadSection:3 withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - MKDeviceSettingMessageTypeDelegate
- (void)messageTypeChanged:(NSInteger)messageType {
    self.settingModel.messageType = messageType;
}

#pragma mark - MKDeviceSettingReportIntervalDelegate
- (void)deviceReportIntervalChanged:(NSInteger)interval {
    self.settingModel.reportingInterval = interval;
}

#pragma mark - MKDeviceSettingCDOptionsDelegate
- (void)deviceCDOptionsChanged:(NSInteger)row valueL:(NSInteger)valueL valueH:(NSInteger)valueH {
    if (row == 0) {
        //CH
        self.settingModel.CHHValue = valueH;
        self.settingModel.CHLValue = valueL;
        return;
    }
    //DR
    self.settingModel.DRValue = valueL;
}

#pragma mark - event method
- (void)modeButtonPressed {
    MKPickerView *pickView = [[MKPickerView alloc] init];
    NSArray *modemList = @[@"ABP",@"OTAA"];
    pickView.dataList = modemList;
    [pickView showPickViewWithIndex:(self.settingModel.modem - 1) block:^(NSInteger currentRow) {
        if (currentRow == (self.settingModel.modem - 1)) {
            return ;
        }
        self.settingModel.modem = (currentRow + 1);
        [self.modeButton setTitle:modemList[currentRow] forState:UIControlStateNormal];
        [self loadSection1Datas];
        [self.tableView reloadSection:1 withRowAnimation:UITableViewRowAnimationNone];
    }];
}

- (void)connectButtonPressed {
    [[MKHudManager share] showHUDWithTitle:@"Config..." inView:self.view isPenetration:NO];
    WS(weakSelf);
    [self.settingModel configDatas:self.isDebugMode block:^(NSError * _Nonnull error, BOOL complete) {
        [[MKHudManager share] hide];
        if (error) {
            [weakSelf.view showCentralToast:error.userInfo[@"errorInfo"]];
            return ;
        }
        [weakSelf configDeviceConnectNetWork];
    }];
}

- (void)ADRSwitchStatusChanged {
    self.settingModel.adrIsOn = self.ADRSwitch.isOn;
    [self loadSection3Datas];
    [self.tableView reloadSection:3 withRowAnimation:UITableViewRowAnimationNone];
}

- (void)optionalSwitchStatusChanged {
    self.isDebugMode = self.optionalSwitch.isOn;
    self.tableView.tableFooterView = [self tableViewFooter];
    [self.ADRSwitch setOn:self.settingModel.adrIsOn];
    if (self.isDebugMode) {
        //重新按照当前频段加载CH、DR选项
        [self loadSection3Datas];
    }
    [self.tableView reloadData];
}

#pragma mark - Private method
- (void)readDatasFromDevice {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    WS(weakSelf);
    [self.settingModel startReadDatas:YES block:^(NSError * _Nonnull error, BOOL complete) {
        [[MKHudManager share] hide];
        if (error) {
            [weakSelf.view showCentralToast:error.userInfo[@"errorInfo"]];
            [weakSelf performSelector:@selector(leftButtonMethod) withObject:nil afterDelay:0.5f];
            return ;
        }
        NSString *modeType = (weakSelf.settingModel.modem == 1 ? @"ABP" : @"OTAA");
        [weakSelf.modeButton setTitle:modeType forState:UIControlStateNormal];
        [weakSelf.ADRSwitch setOn:weakSelf.settingModel.adrIsOn];
        [weakSelf loadSectionCells];
    }];
}

- (void)configDeviceConnectNetWork {
    [[MKHudManager share] showHUDWithTitle:@"Config..." inView:self.view isPenetration:NO];
    [MKTrackerInterface configLoRaWANConnectNetWorkWithSucBlock:^{
        [[MKHudManager share] hide];
        [self.view showCentralToast:@"Success"];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

- (void)loadSectionCells {
    [self loadSection0Datas];
    [self loadSection1Datas];
    [self loadSection2Datas];
    [self loadSection3Datas];
    [self.tableView reloadData];
}

- (void)loadSection0Datas {
    [self.section0List removeAllObjects];
    
    MKDeviceSettingTextCellModel *devEUIModel = [[MKDeviceSettingTextCellModel alloc] init];
    devEUIModel.msg = @"DevEUI";
    devEUIModel.value = self.settingModel.devEUI;
    devEUIModel.maxLen = 16;
    devEUIModel.index = 0;
    
    MKDeviceSettingTextCell *devEUICell = [MKDeviceSettingTextCell initCellWithTableView:self.tableView];
    devEUICell.delegate = self;
    devEUICell.dataModel = devEUIModel;
    [self.section0List addObject:devEUICell];
    
    MKDeviceSettingTextCellModel *appEUIModel = [[MKDeviceSettingTextCellModel alloc] init];
    appEUIModel.msg = @"AppEUI";
    appEUIModel.value = self.settingModel.appEUI;
    appEUIModel.maxLen = 16;
    appEUIModel.index = 1;
    
    MKDeviceSettingTextCell *appEUICell = [MKDeviceSettingTextCell initCellWithTableView:self.tableView];
    appEUICell.delegate = self;
    appEUICell.dataModel = appEUIModel;
    [self.section0List addObject:appEUICell];
}

- (void)loadSection1Datas {
    [self.section1List removeAllObjects];
    
    if (self.settingModel.modem == 2) {
        //OTAA
        
        MKDeviceSettingTextCellModel *appKeyModel = [[MKDeviceSettingTextCellModel alloc] init];
        appKeyModel.msg = @"AppKey";
        appKeyModel.value = self.settingModel.appKey;
        appKeyModel.maxLen = 32;
        appKeyModel.index = 5;
        
        MKDeviceSettingTextCell *appKeyCell = [MKDeviceSettingTextCell initCellWithTableView:self.tableView];
        appKeyCell.delegate = self;
        appKeyCell.dataModel = appKeyModel;
        [self.section1List addObject:appKeyCell];
        
        return;
    }
    //ABP
    MKDeviceSettingTextCellModel *devAddrModel = [[MKDeviceSettingTextCellModel alloc] init];
    devAddrModel.msg = @"DevAddr";
    devAddrModel.value = self.settingModel.devAddr;
    devAddrModel.maxLen = 8;
    devAddrModel.index = 2;
    
    MKDeviceSettingTextCell *devAddrCell = [MKDeviceSettingTextCell initCellWithTableView:self.tableView];
    devAddrCell.delegate = self;
    devAddrCell.dataModel = devAddrModel;
    [self.section1List addObject:devAddrCell];
    
    MKDeviceSettingTextCellModel *appSKeyModel = [[MKDeviceSettingTextCellModel alloc] init];
    appSKeyModel.msg = @"AppSKey";
    appSKeyModel.value = self.settingModel.appSKey;
    appSKeyModel.maxLen = 32;
    appSKeyModel.index = 3;
    
    MKDeviceSettingTextCell *appSKeyCell = [MKDeviceSettingTextCell initCellWithTableView:self.tableView];
    appSKeyCell.delegate = self;
    appSKeyCell.dataModel = appSKeyModel;
    [self.section1List addObject:appSKeyCell];
    
    MKDeviceSettingTextCellModel *nwkSKeyModel = [[MKDeviceSettingTextCellModel alloc] init];
    nwkSKeyModel.msg = @"NwkSKey";
    nwkSKeyModel.value = self.settingModel.nwkSKey;
    nwkSKeyModel.maxLen = 32;
    nwkSKeyModel.index = 4;
    
    MKDeviceSettingTextCell *nwkSKeyCell = [MKDeviceSettingTextCell initCellWithTableView:self.tableView];
    nwkSKeyCell.delegate = self;
    nwkSKeyCell.dataModel = nwkSKeyModel;
    [self.section1List addObject:nwkSKeyCell];
}

- (void)loadSection2Datas {
    [self.section2List removeAllObjects];
    
    MKRegionCell *regionCell = [MKRegionCell initCellWithTableView:self.tableView];
    regionCell.region = self.settingModel.region;
    regionCell.delegate = self;
    [self.section2List addObject:regionCell];
    
    MKMessageTypeCell *messageCell = [MKMessageTypeCell initCellWithTableView:self.tableView];
    messageCell.messageType = self.settingModel.messageType;
    messageCell.delegate = self;
    [self.section2List addObject:messageCell];
    
    MKIntervalCell *intervalCell = [MKIntervalCell initCellWithTableView:self.tableView];
    intervalCell.interval = self.settingModel.reportingInterval;
    intervalCell.delegate = self;
    [self.section2List addObject:intervalCell];
}

- (void)loadSection3Datas {
    [self.section3List removeAllObjects];
    MKCDOptionsCell *chCell = [[MKCDOptionsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MKCDOptionsCellIdenty"];
    chCell.dataModel = [self loadSection3Row0Model];
    chCell.delegate = self;
    [self.section3List addObject:chCell];
    
    MKCDOptionsCell *drCell = [[MKCDOptionsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MKCDOptionsCellIdenty"];
    drCell.dataModel = [self loadSection3Row1Model];
    drCell.delegate = self;
    [self.section3List addObject:drCell];
}

- (MKCDOptionsCellModel *)loadSection3Row0Model {
    MKCDOptionsCellModel *chModel = [[MKCDOptionsCellModel alloc] init];
    chModel.msg = @"CH";
    chModel.dataList = [MKCDOptionsCellModel fetchCHDataList:self.settingModel.region];
    chModel.valueH = self.settingModel.CHHValue;
    chModel.valueL = self.settingModel.CHLValue;
    chModel.row = 0;
    chModel.needHValue = YES;
    chModel.canShowList = YES;
    return chModel;
}

- (MKCDOptionsCellModel *)loadSection3Row1Model {
    MKCDOptionsCellModel *drModel = [[MKCDOptionsCellModel alloc] init];
    drModel.msg = @"DR";
    drModel.dataList = [MKCDOptionsCellModel fetchDRDataList:self.settingModel.region];
    drModel.valueL = self.settingModel.DRValue;
    drModel.row = 1;
    drModel.needHValue = NO;
    drModel.canShowList = !self.ADRSwitch.isOn;
    return drModel;
}

#pragma mark - UI
- (void)loadSubViews {
    self.custom_naviBarColor = UIColorFromRGB(0x2F84D0);
    self.titleLabel.textColor = COLOR_WHITE_MACROS;
    self.defaultTitle = @"LoRa SETTINGS";
    self.view.backgroundColor = COLOR_WHITE_MACROS;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(defaultTopInset);
        make.bottom.mas_equalTo(-VirtualHomeHeight);
    }];
}

#pragma mark - getter
- (MKBaseTableView *)tableView {
    if (!_tableView) {
        _tableView = [[MKBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = COLOR_WHITE_MACROS;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        _tableView.tableHeaderView = [self tableViewHeader];
        _tableView.tableFooterView = [self tableViewFooter];
    }
    return _tableView;
}

- (UIButton *)modeButton {
    if (!_modeButton) {
        _modeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _modeButton.frame = CGRectMake(kScreenWidth - 15.f - modeButtonWidth, (headerModeViewHeight - modeButtonHeight) / 2, modeButtonWidth, modeButtonHeight);
        _modeButton.titleLabel.font = MKFont(15.f);
        [_modeButton setTitle:@"ABP" forState:UIControlStateNormal];
        [_modeButton setTitleColor:UIColorFromRGB(0x2F84D0) forState:UIControlStateNormal];
        [_modeButton addTapAction:self selector:@selector(modeButtonPressed)];
    }
    return _modeButton;
}

- (UISwitch *)ADRSwitch {
    if (!_ADRSwitch) {
        _ADRSwitch = [[UISwitch alloc] init];
        [_ADRSwitch addTarget:self
                       action:@selector(ADRSwitchStatusChanged)
             forControlEvents:UIControlEventValueChanged];
    }
    return _ADRSwitch;
}

- (UISwitch *)optionalSwitch {
    if (!_optionalSwitch) {
        _optionalSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(kScreenWidth - 15.f - 50.f, 5.f, 50.f, 40.f)];
        _optionalSwitch.on = NO;
        [_optionalSwitch addTarget:self
                            action:@selector(optionalSwitchStatusChanged)
                  forControlEvents:UIControlEventValueChanged];
    }
    return _optionalSwitch;
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

- (NSMutableArray *)section3List {
    if (!_section3List) {
        _section3List = [NSMutableArray array];
    }
    return _section3List;
}

- (NSMutableArray<MKCDOptionsCellModel *> *)optionsList {
    if (!_optionsList) {
        _optionsList = [NSMutableArray array];
    }
    return _optionsList;
}

- (MKDeviceSettingModel *)settingModel {
    if (!_settingModel) {
        _settingModel = [[MKDeviceSettingModel alloc] init];
    }
    return _settingModel;
}

- (UIView *)tableViewHeader {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44.f)];
    headerView.backgroundColor = RGBCOLOR(239, 239, 239);
    
    UILabel *msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.f, (44.f - MKFont(15.f).lineHeight) / 2, 130.f, MKFont(15.f).lineHeight)];
    msgLabel.textColor = DEFAULT_TEXT_COLOR;
    msgLabel.textAlignment = NSTextAlignmentLeft;
    msgLabel.font = MKFont(15.f);
    msgLabel.text = @"LoRaWAN Mode";
    [headerView addSubview:msgLabel];
    
    [headerView addSubview:self.modeButton];
    
    return headerView;
}

- (UIView *)tableViewFooter {
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 180.f)];
    footView.backgroundColor = RGBCOLOR(239, 239, 239);
    
    if (self.isDebugMode) {
        UILabel *msgLabel = [[UILabel alloc] init];
        msgLabel.textColor = DEFAULT_TEXT_COLOR;
        msgLabel.textAlignment = NSTextAlignmentLeft;
        msgLabel.font = MKFont(15.f);
        msgLabel.text = @"ADR";
        [footView addSubview:msgLabel];
        [msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15.f);
            make.width.mas_equalTo(60.f);
            make.top.mas_equalTo(15.f);
            make.height.mas_equalTo(MKFont(15.f).lineHeight);
        }];
        
        [footView addSubview:self.ADRSwitch];
        [self.ADRSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(msgLabel.mas_right).mas_offset(10.f);
            make.centerY.mas_equalTo(msgLabel.mas_centerY);
            make.width.mas_equalTo(50.f);
            make.height.mas_equalTo(40.f);
        }];
    }
    
    UIButton *connectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [connectButton setTitle:@"Connect" forState:UIControlStateNormal];
    [connectButton setTitleColor:COLOR_WHITE_MACROS forState:UIControlStateNormal];
    [connectButton setBackgroundColor:UIColorFromRGB(0x2F84D0)];
    [connectButton.layer setMasksToBounds:YES];
    [connectButton.layer setCornerRadius:6.f];
    [connectButton addTapAction:self selector:@selector(connectButtonPressed)];
    [footView addSubview:connectButton];
    [connectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30.f);
        make.right.mas_equalTo(-30.f);
        make.bottom.mas_equalTo(-30.f);
        make.height.mas_equalTo(40.f);
    }];
    
    return footView;
}

- (UIView *)fetchAdvancedSettingView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, optionalViewHeight)];
    
    CGFloat switchWidth = 50.f;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.f,
                                                                    10.f,
                                                                    kScreenWidth - 3 * 15.f - switchWidth,
                                                                    MKFont(15.f).lineHeight)];
    titleLabel.textColor = UIColorFromRGB(0x2F84D0);
    titleLabel.font = MKFont(15.f);
    titleLabel.text = @"Advanced Setting(Optional)";
    [view addSubview:titleLabel];
    
    UILabel *noteLabel = [[UILabel alloc] init];
    noteLabel.text = @"Note:Please do not modify advanced settings unless necessary.";
    noteLabel.font = MKFont(12.f);
    noteLabel.textColor = DEFAULT_TEXT_COLOR;
    noteLabel.numberOfLines = 0;
    CGSize noteSize = [NSString sizeWithText:noteLabel.text
                                     andFont:MKFont(12.f)
                                  andMaxSize:CGSizeMake(kScreenWidth - 3 * 15.f - switchWidth, MAXFLOAT)];
    noteLabel.frame = CGRectMake(15.f,
                                 15 + MKFont(15.f).lineHeight,
                                 kScreenWidth - 3 * 15.f - switchWidth,
                                 noteSize.height);
    [view addSubview:noteLabel];
    
    [view addSubview:self.optionalSwitch];
    
    return view;
}

@end
