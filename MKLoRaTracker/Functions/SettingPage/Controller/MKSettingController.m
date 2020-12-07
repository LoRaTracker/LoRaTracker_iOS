//
//  MKSettingController.m
//  MKContactTracker
//
//  Created by aa on 2020/4/22.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKSettingController.h"

#import "MKSettingTableViewCell.h"
#import "MKSwitchStatusCell.h"

#import "MKSwitchStatusCellModel.h"

#import "MKUpdateController.h"
#import "MKTriggerSensitivityView.h"
#import "MKScannWindowConfigView.h"

#import "MKLoRaSettingController.h"

@interface MKSettingController ()<UITableViewDelegate, UITableViewDataSource, MKSwitchStatusCellDelegate>

@property (nonatomic, strong)UILabel *networkLabel;

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *section0List;

@property (nonatomic, strong)NSMutableArray *section1List;

@property (nonatomic, strong)dispatch_queue_t configQueue;

@property (nonatomic, strong)dispatch_semaphore_t semaphore;

@property (nonatomic, strong)UITextField *passwordField;

@property (nonatomic, strong)UITextField *passwordTextField;

@property (nonatomic, strong)UITextField *confirmTextField;

/// 第一次需要读取设备是否可连接，以后只需要读取LoRa是否联网
@property (nonatomic, assign)BOOL needReadConnectStatus;

/// 当前present的alert
@property (nonatomic, strong)UIAlertController *currentAlert;

@end

@implementation MKSettingController

- (void)dealloc {
    NSLog(@"MKSettingController销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startReadStatus:self.needReadConnectStatus];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self loadTableDatas];
    self.needReadConnectStatus = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(needDismissAlert)
                                                 name:@"MKSettingPageNeedDismissAlert"
                                               object:nil];
}

#pragma mark - super method
- (void)leftButtonMethod {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MKPopToRootViewControllerNotification" object:nil];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        //
        if (indexPath.row == 0) {
            //设置密码
            [self setPassword];
            return;
        }
        if (indexPath.row == 1) {
            //恢复出厂设置
            [self factoryReset];
            return;
        }
        if (indexPath.row == 2) {
            //dfu
            MKUpdateController *vc = [[MKUpdateController alloc] init];
            self.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
            self.hidesBottomBarWhenPushed = NO;
            return;
        }
        if (indexPath.row == 3) {
            //LoRa Setting
            MKLoRaSettingController *vc = [[MKLoRaSettingController alloc] init];
            self.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
            self.hidesBottomBarWhenPushed = NO;
            return;
        }
        //设置Scan Window
        [self scanWindowMethod];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.section0List.count;
    }
    return self.section1List.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        MKSettingTableViewCell *cell = [MKSettingTableViewCell initCellWithTableView:tableView];
        cell.dataModel = self.section0List[indexPath.row];
        return cell;
    }
    MKSwitchStatusCell *cell = [MKSwitchStatusCell initCellWithTableView:tableView];
    cell.dataModel = self.section1List[indexPath.row];
    cell.delegate = self;
    return cell;
}

#pragma mark - MKSwitchStatusCellDelegate
- (void)needChangedCellSwitchStatus:(BOOL)isOn row:(NSInteger)row {
    if (row == 0) {
        //可连接状态
        [self setConnectEnable:isOn];
        return;
    }
    if (row == 1) {
        //关机
        [self powerOff];
        return;
    }
}

#pragma mark - note
- (void)needDismissAlert {
    if (self.currentAlert && (kAppRootController.presentedViewController == self.currentAlert)) {
        [self.currentAlert dismissViewControllerAnimated:NO completion:nil];
    }
}

#pragma mark - interface
- (void)startReadStatus:(BOOL)needConnectStatus {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    dispatch_async(self.configQueue, ^{
        NSDictionary *scanWindowDic = [self readScanWindow];
        if (![scanWindowDic[@"success"] boolValue]) {
            moko_dispatch_main_safe(^{
                [[MKHudManager share] hide];
//                [self.view showCentralToast:@"Read scan window error!"];
            });
            return ;
        }
        MKSettingTableViewCellModel *scanWindowModel = self.section0List[4];
        BOOL isOn = [scanWindowDic[@"isOn"] boolValue];
        if (!isOn) {
            //关闭状态
            scanWindowModel.leftMsg = @"Scan Window(0)";
        }else {
            NSInteger scanValue = [scanWindowDic[@"type"] integerValue];
            if (scanValue == mk_scannWindowTypeOpen) {
                scanWindowModel.leftMsg = @"Scan Window(1)";
            }else if (scanValue == mk_scannWindowTypeHalfOpen) {
                scanWindowModel.leftMsg = @"Scan Window(1/2)";
            }else if (scanValue == mk_scannWindowTypeQuarterOpen) {
                scanWindowModel.leftMsg = @"Scan Window(1/4)";
            }else if (scanValue == mk_scannWindowTypeOneEighthOpen) {
                scanWindowModel.leftMsg = @"Scan Window(1/8)";
            }
        }
        moko_dispatch_main_safe(^{
            [self.tableView reloadRow:4 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
        });
        NSDictionary *networkDic = [self readLoRaNetworkStatus];
        if (![networkDic[@"success"] boolValue]) {
            moko_dispatch_main_safe(^{
                [[MKHudManager share] hide];
//                [self.view showCentralToast:@"Read LoRa Network status error!"];
            });
            return ;
        }
        NSInteger status = [networkDic[@"status"] integerValue];
        NSString *stateMsg = @"";
        if (status == 0) {
            stateMsg = @"Disconnected";
        }else if (status == 1) {
            stateMsg = @"Connected";
        }else {
            stateMsg = @"Connecting";
        }
        moko_dispatch_main_safe(^{
            self.networkLabel.text = stateMsg;
        });
        if (!needConnectStatus) {
            moko_dispatch_main_safe(^{
                [[MKHudManager share] hide];
            });
            return ;
        }
        NSDictionary *connectDic = [self readConnectableStatus];
        if (![connectDic[@"success"] boolValue]) {
            moko_dispatch_main_safe(^{
                [[MKHudManager share] hide];
//                [self.view showCentralToast:@"Read connectable status error!"];
            });
            return ;
        }
        MKSwitchStatusCellModel *connectModel = self.section1List[0];
        connectModel.isOn = [connectDic[@"isOn"] boolValue];
        self.needReadConnectStatus = NO;
        moko_dispatch_main_safe(^{
            [[MKHudManager share] hide];
            [self.tableView reloadSection:1 withRowAnimation:UITableViewRowAnimationNone];
        });
    });
}

- (NSDictionary *)readConnectableStatus {
    __block NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
    [MKTrackerInterface readConnectableWithSucBlock:^(id  _Nonnull returnData) {
        [resultDic setValue:@(YES) forKey:@"success"];
        [resultDic setValue:returnData[@"result"][@"isOn"] forKey:@"isOn"];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        [resultDic setValue:@(NO) forKey:@"success"];
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return resultDic;
}

- (NSDictionary *)readScanWindow {
    __block NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
    [MKTrackerInterface readScanWindowDataWithSucBlock:^(id  _Nonnull returnData) {
        [resultDic setValue:@(YES) forKey:@"success"];
        [resultDic setValue:returnData[@"result"][@"value"] forKey:@"type"];
        [resultDic setValue:returnData[@"result"][@"isOn"] forKey:@"isOn"];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        [resultDic setValue:@(NO) forKey:@"success"];
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return resultDic;
}

- (BOOL)configScanWindowType:(mk_scannWindowType)type {
    __block BOOL success = NO;
    [MKTrackerInterface configScannWindow:type sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (NSDictionary *)readLoRaNetworkStatus {
    __block NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
    [MKTrackerInterface readLoRaNetworkStatusWithSucBlock:^(id  _Nonnull returnData) {
        [resultDic setValue:@(YES) forKey:@"success"];
        [resultDic setValue:returnData[@"result"][@"status"] forKey:@"status"];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        [resultDic setValue:@(NO) forKey:@"success"];
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return resultDic;
}

#pragma mark - 设置可连接状态
- (void)setConnectEnable:(BOOL)connect{
    self.currentAlert = nil;
    NSString *msg = (connect ? @"Are you sure to make the device connectable?" : @"Are you sure to make the device Unconnectable?");
    self.currentAlert = [UIAlertController alertControllerWithTitle:@"Warning!"
                                                            message:msg
                                                     preferredStyle:UIAlertControllerStyleAlert];
    WS(weakSelf);
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        MKSwitchStatusCellModel *model = weakSelf.section1List[0];
        model.isOn = !connect;
        [weakSelf.tableView reloadRow:0 inSection:1 withRowAnimation:UITableViewRowAnimationNone];
    }];
    [self.currentAlert addAction:cancelAction];
    UIAlertAction *moreAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf setConnectStatusToDevice:connect];
    }];
    [self.currentAlert addAction:moreAction];
    
    [kAppRootController presentViewController:self.currentAlert animated:YES completion:nil];
}

- (void)setConnectStatusToDevice:(BOOL)connect{
    [[MKHudManager share] showHUDWithTitle:@"Setting..."
                                     inView:self.view
                              isPenetration:NO];
    WS(weakSelf);
    [MKTrackerInterface configConnectableStatus:connect sucBlock:^{
        [[MKHudManager share] hide];
        [weakSelf.view showCentralToast:@"Success!"];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [weakSelf.view showCentralToast:error.userInfo[@"errorInfo"]];
        MKSwitchStatusCellModel *model = weakSelf.section1List[0];
        model.isOn = !connect;
        [weakSelf.tableView reloadRow:0 inSection:1 withRowAnimation:UITableViewRowAnimationNone];
    }];
}

#pragma mark - 开关机
- (void)powerOff{
    self.currentAlert = nil;
    NSString *msg = @"Are you sure to turn off the device? Please make sure the device has a button to turn on!";
    self.currentAlert = [UIAlertController alertControllerWithTitle:@"Warning!"
                                                            message:msg
                                                     preferredStyle:UIAlertControllerStyleAlert];
    WS(weakSelf);
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        MKSwitchStatusCellModel *model = weakSelf.section1List[1];
        model.isOn = NO;
        [weakSelf.tableView reloadRow:1 inSection:1 withRowAnimation:UITableViewRowAnimationNone];
    }];
    [self.currentAlert addAction:cancelAction];
    UIAlertAction *moreAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf commandPowerOff];
    }];
    [self.currentAlert addAction:moreAction];
    
    [kAppRootController presentViewController:self.currentAlert animated:YES completion:nil];
}

- (void)commandPowerOff{
    [[MKHudManager share] showHUDWithTitle:@"Setting..."
                                     inView:self.view
                              isPenetration:NO];
    WS(weakSelf);
    [MKTrackerInterface powerOffDeviceWithSucBlock:^{
        [[MKHudManager share] hide];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [weakSelf.view showCentralToast:error.userInfo[@"errorInfo"]];
        MKSwitchStatusCellModel *model = weakSelf.section1List[1];
        model.isOn = YES;
        [weakSelf.tableView reloadRow:1 inSection:1 withRowAnimation:UITableViewRowAnimationNone];
    }];
}

#pragma mark - 恢复出厂设置

- (void)factoryReset{
    self.currentAlert = nil;
    NSString *msg = @"After factory reset,all the data will be reseted to the factory values.";
    self.currentAlert = [UIAlertController alertControllerWithTitle:@"Factory Reset"
                                                            message:msg
                                                     preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [self.currentAlert addAction:cancelAction];
    WS(weakSelf);
    UIAlertAction *moreAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf sendResetCommandToDevice];
    }];
    [self.currentAlert addAction:moreAction];
    
    [kAppRootController presentViewController:self.currentAlert animated:YES completion:nil];
}

- (void)passwordInput {
    NSString *tempInputString = self.passwordField.text;
    if (!ValidStr(tempInputString)) {
        self.passwordField.text = @"";
        return;
    }
    self.passwordField.text = (tempInputString.length > 8 ? [tempInputString substringToIndex:8] : tempInputString);
}

- (void)sendResetCommandToDevice{
    [[MKHudManager share] showHUDWithTitle:@"Setting..."
                                     inView:self.view
                              isPenetration:NO];
    [MKTrackerInterface factoryDataResetWithSucBlock:^{
        [[MKHudManager share] hide];
        [self.view showCentralToast:@"Factory reset successfully!Please reconnect the device"];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - 设置密码
- (void)setPassword{
    WS(weakSelf);
    self.currentAlert = nil;
    NSString *msg = @"Note:The password should be 8 characters.";
    self.currentAlert = [UIAlertController alertControllerWithTitle:@"Change Password"
                                                            message:msg
                                                     preferredStyle:UIAlertControllerStyleAlert];
    [self.currentAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        weakSelf.passwordTextField = nil;
        weakSelf.passwordTextField = textField;
        [weakSelf.passwordTextField setPlaceholder:@"Enter new password"];
        [weakSelf.passwordTextField addTarget:weakSelf
                                       action:@selector(passwordTextFieldValueChanged:)
                             forControlEvents:UIControlEventEditingChanged];
    }];
    [self.currentAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        weakSelf.confirmTextField = nil;
        weakSelf.confirmTextField = textField;
        [weakSelf.confirmTextField setPlaceholder:@"Enter new password again"];
        [weakSelf.confirmTextField addTarget:weakSelf
                                      action:@selector(passwordTextFieldValueChanged:)
                            forControlEvents:UIControlEventEditingChanged];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [self.currentAlert addAction:cancelAction];
    UIAlertAction *moreAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf setPasswordToDevice];
    }];
    [self.currentAlert addAction:moreAction];
    
    [kAppRootController presentViewController:self.currentAlert animated:YES completion:nil];
}

- (void)passwordTextFieldValueChanged:(UITextField *)textField{
    NSString *tempInputString = textField.text;
    if (!ValidStr(tempInputString)) {
        textField.text = @"";
        return;
    }
    textField.text = (tempInputString.length > 8 ? [tempInputString substringToIndex:8] : tempInputString);
}

- (void)setPasswordToDevice{
    NSString *password = self.passwordTextField.text;
    NSString *confirmpassword = self.confirmTextField.text;
    if (!ValidStr(password) || !ValidStr(confirmpassword) || password.length != 8 || confirmpassword.length != 8) {
        [self.view showCentralToast:@"The password should be 8 characters.Please try again."];
        return;
    }
    if (![password isEqualToString:confirmpassword]) {
        [self.view showCentralToast:@"Password do not match! Please try again."];
        return;
    }
    WS(weakSelf);
    [[MKHudManager share] showHUDWithTitle:@"Setting..."
                                     inView:self.view
                              isPenetration:NO];
    [MKTrackerInterface configPassword:password sucBlock:^{
        [[MKHudManager share] hide];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [weakSelf.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - 设置scan window
- (void)scanWindowMethod {
    [[MKHudManager share] showHUDWithTitle:@"Reading..."
                                    inView:self.view
                             isPenetration:NO];
    dispatch_async(self.configQueue, ^{
        NSDictionary *scanWindowDic = [self readScanWindow];
        if (![scanWindowDic[@"success"] boolValue]) {
            moko_dispatch_main_safe(^{
                [[MKHudManager share] hide];
                [self.view showCentralToast:@"Read scan window error!"];
            });
            return ;
        }
        BOOL isOn = [scanWindowDic[@"isOn"] boolValue];
        if (!isOn) {
            //关闭状态
            moko_dispatch_main_safe(^{
                [[MKHudManager share] hide];
                [self showViewWithScanWindowValue:mk_scannWindowTypeClose];
            });
            return;
        }
        moko_dispatch_main_safe(^{
            [[MKHudManager share] hide];
            [self showViewWithScanWindowValue:[scanWindowDic[@"type"] integerValue]];
        });
    });
    
}

- (void)showViewWithScanWindowValue:(mk_scannWindowType)value {
    WS(weakSelf);
    MKScannWindowConfigView *view = [[MKScannWindowConfigView alloc] init];
    [view showViewWithValue:value completeBlock:^(mk_scannWindowType resultType) {
        __strong typeof(self) sself = weakSelf;
        [sself configScanWindowStatus:resultType];
    }];
}

- (void)configScanWindowStatus:(mk_scannWindowType)scanType {
    [[MKHudManager share] showHUDWithTitle:@"Setting..."
                                    inView:self.view
                             isPenetration:NO];
    dispatch_async(self.configQueue, ^{
        if (![self configScanWindowType:scanType]) {
            moko_dispatch_main_safe(^{
                [[MKHudManager share] hide];
                [self.view showCentralToast:@"Config scan window type error"];
            });
            return ;
        }
        MKSettingTableViewCellModel *scanWindowModel = self.section0List[4];
        if (scanType == mk_scannWindowTypeClose) {
            //关闭状态
            scanWindowModel.leftMsg = @"Scan Window(0)";
        }else if (scanType == mk_scannWindowTypeOpen) {
            scanWindowModel.leftMsg = @"Scan Window(1)";
        }else if (scanType == mk_scannWindowTypeHalfOpen) {
            scanWindowModel.leftMsg = @"Scan Window(1/2)";
        }else if (scanType == mk_scannWindowTypeQuarterOpen) {
            scanWindowModel.leftMsg = @"Scan Window(1/4)";
        }else if (scanType == mk_scannWindowTypeOneEighthOpen) {
            scanWindowModel.leftMsg = @"Scan Window(1/8)";
        }
        moko_dispatch_main_safe(^{
            [[MKHudManager share] hide];
            [self.view showCentralToast:@"Success"];
            [self.tableView reloadRow:4 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
        });
    });
}

#pragma mark -
- (void)loadTableDatas {
    MKSettingTableViewCellModel *passwrodModel = [[MKSettingTableViewCellModel alloc] init];
    passwrodModel.leftMsg = @"Change Password";
    [self.section0List addObject:passwrodModel];
    
    MKSettingTableViewCellModel *resetModel = [[MKSettingTableViewCellModel alloc] init];
    resetModel.leftMsg = @"Factory Reset";
    [self.section0List addObject:resetModel];
    
    MKSettingTableViewCellModel *dufModel = [[MKSettingTableViewCellModel alloc] init];
    dufModel.leftMsg = @"Update Firmware (DFU)";
    [self.section0List addObject:dufModel];
    
    MKSettingTableViewCellModel *loraSettingModel = [[MKSettingTableViewCellModel alloc] init];
    loraSettingModel.leftMsg = @"LoRa Settings";
    [self.section0List addObject:loraSettingModel];
    
    MKSettingTableViewCellModel *scanWindowModel = [[MKSettingTableViewCellModel alloc] init];
    scanWindowModel.leftMsg = @"Scan Window(0ms/1000ms)";
    [self.section0List addObject:scanWindowModel];
    
    MKSwitchStatusCellModel *connectModel = [[MKSwitchStatusCellModel alloc] init];
    connectModel.msg = @"Connectable";
    connectModel.index = 0;
    [self.section1List addObject:connectModel];
    
    MKSwitchStatusCellModel *powerOffModel = [[MKSwitchStatusCellModel alloc] init];
    powerOffModel.msg = @"Power Off";
    powerOffModel.index = 1;
    [self.section1List addObject:powerOffModel];
}

#pragma mark - UI
- (void)loadSubViews {
    self.custom_naviBarColor = UIColorFromRGB(0x2F84D0);
    self.titleLabel.textColor = COLOR_WHITE_MACROS;
    self.defaultTitle = @"SETTINGS";
    self.view.backgroundColor = COLOR_WHITE_MACROS;
    [self.rightButton setHidden:YES];
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
        
        _tableView.tableHeaderView = [self tableHeaderView];
    }
    return _tableView;
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

- (dispatch_semaphore_t)semaphore {
    if (!_semaphore) {
        _semaphore = dispatch_semaphore_create(0);
    }
    return _semaphore;
}

- (dispatch_queue_t)configQueue {
    if (!_configQueue) {
        _configQueue = dispatch_queue_create("filterParamsQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _configQueue;
}

- (UILabel *)networkLabel {
    if (!_networkLabel) {
        _networkLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 115.f, 0, 100, 44.f)];
        _networkLabel.textAlignment = NSTextAlignmentRight;
        _networkLabel.font = MKFont(13.f);
        _networkLabel.textColor = DEFAULT_TEXT_COLOR;
    }
    return _networkLabel;
}

- (UIView *)tableHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44.f)];
    headerView.backgroundColor = COLOR_WHITE_MACROS;
    
    UILabel *msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 130, 44.f)];
    msgLabel.textColor = DEFAULT_TEXT_COLOR;
    msgLabel.font = MKFont(15.f);
    msgLabel.textAlignment = NSTextAlignmentLeft;
    msgLabel.text = @"LoRaWAN Status";
    [headerView addSubview:msgLabel];
    
    [headerView addSubview:self.networkLabel];
    
    return headerView;
}

@end
