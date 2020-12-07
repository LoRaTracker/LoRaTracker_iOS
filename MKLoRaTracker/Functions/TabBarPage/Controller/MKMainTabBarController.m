//
//  MKMainTabBarController.m
//  MKContactTracker
//
//  Created by aa on 2020/4/22.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKMainTabBarController.h"

#import "MKAdvertiserPageController.h"
#import "MKScannerPageController.h"
#import "MKSettingController.h"
#import "MKDeviceInfoController.h"

@interface MKMainTabBarController ()

/// 当触发01:修改密码成功,02:恢复出厂设置,03:两分钟之内没有通信,04:关机这几种类型的断开连接的时候，就不需要显示断开连接的弹窗了，只需要显示对应的弹窗
@property (nonatomic, assign)BOOL disconnectType;

@end

@implementation MKMainTabBarController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"MKMainTabBarController销毁");
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    if (![[self.navigationController viewControllers] containsObject:self]){
        [[MKTrackerCentralManager shared] disconnect];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubPages];
    [self statusMonitoring];
    [[MKTrackerCentralManager shared] notifyDisconnectType:YES];
}

#pragma mark - Notification event
- (void)disconnectTypeNotification:(NSNotification *)note {
    NSString *type = note.userInfo[@"type"];
    //01:连接一分钟之内没有输入密码,02:修改密码成功,03:恢复出厂设置,04:两分钟之内没有通信,04:关机
    self.disconnectType = YES;
    if ([type isEqualToString:@"02"]) {
        [self showAlertWithMsg:@"Password changed successfully! Please reconnect the device." title:@"Change Password"];
        return;
    }
    if ([type isEqualToString:@"03"]) {
        [self showAlertWithMsg:@"Factory reset successfully! Please reconnect the device." title:@"Factory Reset"];
        return;
    }
    if ([type isEqualToString:@"04"]) {
        [self showAlertWithMsg:@"No data communication for 2 minutes,the device is disconnected." title:@""];
        return;
    }
    if ([type isEqualToString:@"05"]) {
        [self showAlertWithMsg:@"The Beacon is disconnected." title:@""];
        return;
    }
}

- (void)centralManagerStateChanged{
    if (self.disconnectType) {
        return;
    }
    if ([MKTrackerCentralManager shared].centralStatus != MKCentralManagerStateEnable) {
        [self showAlertWithMsg:@"The current system of bluetooth is not available!" title:@"Dismiss"];
    }
}

- (void)deviceConnectStateChanged {
    if (self.disconnectType) {
        return;
    }
    [self showAlertWithMsg:@"The Beacon is disconnected." title:@""];
    return;
}

- (void)gotoRootViewController{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MKNeedResetRootControllerToScanPage" object:nil userInfo:nil];
}

#pragma mark - Private method

- (void)statusMonitoring{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotoRootViewController)
                                                 name:@"MKCentralDeallocNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotoRootViewController)
                                                 name:@"MKPopToRootViewControllerNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(centralManagerStateChanged)
                                                 name:mk_centralManagerStateChangedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(disconnectTypeNotification:)
                                                 name:mk_deviceDisconnectTypeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceConnectStateChanged)
                                                 name:mk_peripheralConnectStateChangedNotification
                                               object:nil];
}

/**
 当前手机蓝牙不可用、锁定状态改为不可用的时候，提示弹窗
 
 @param msg 弹窗显示的内容
 */
- (void)showAlertWithMsg:(NSString *)msg title:(NSString *)title{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:msg
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    WS(weakSelf);
    UIAlertAction *moreAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf gotoRootViewController];
    }];
    [alertController addAction:moreAction];
    //让setting页面推出的alert消失
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MKSettingPageNeedDismissAlert" object:nil];
    [self performSelector:@selector(presentAlert:) withObject:alertController afterDelay:1.2f];
}

- (void)presentAlert:(UIAlertController *)alert {
    [kAppRootController presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UI

- (void)loadSubPages {
    MKAdvertiserPageController *advPage = [[MKAdvertiserPageController alloc] init];
    advPage.tabBarItem.title = @"ADVERTISER";
    advPage.tabBarItem.image = LOADIMAGE(@"advTabBarItemUnselected", @"png");
    advPage.tabBarItem.selectedImage = LOADIMAGE(@"advTabBarItemSelected", @"png");
    UINavigationController *advNav = [[UINavigationController alloc] initWithRootViewController:advPage];

    MKScannerPageController *scannerPage = [[MKScannerPageController alloc] init];
    scannerPage.tabBarItem.title = @"SCANNER";
    scannerPage.tabBarItem.image = LOADIMAGE(@"scannerTabBarItemUnselected", @"png");
    scannerPage.tabBarItem.selectedImage = LOADIMAGE(@"scannerTabBarItemSelected", @"png");
    UINavigationController *scannerNav = [[UINavigationController alloc] initWithRootViewController:scannerPage];

    MKSettingController *setting = [[MKSettingController alloc] init];
    setting.tabBarItem.title = @"SETTINGS";
    setting.tabBarItem.image = LOADIMAGE(@"settingTabBarItemUnselected", @"png");
    setting.tabBarItem.selectedImage = LOADIMAGE(@"settingTabBarItemSelected", @"png");
    UINavigationController *settingPage = [[UINavigationController alloc] initWithRootViewController:setting];
    
    MKDeviceInfoController *deviceInfo = [[MKDeviceInfoController alloc] init];
    deviceInfo.tabBarItem.title = @"DEVICE";
    deviceInfo.tabBarItem.image = LOADIMAGE(@"deviceTabBarItemUnselected", @"png");
    deviceInfo.tabBarItem.selectedImage = LOADIMAGE(@"deviceTabBarItemSelected", @"png");
    UINavigationController *deviceInfoPage = [[UINavigationController alloc] initWithRootViewController:deviceInfo];
    
    self.viewControllers = @[advNav,scannerNav,settingPage,deviceInfoPage];
}

@end
