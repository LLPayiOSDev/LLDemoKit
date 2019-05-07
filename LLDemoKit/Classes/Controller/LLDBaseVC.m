//
//  LLDBaseVC.m
//  LLDemoKit
//
//  Created by EvenLin on 2017/9/21.
//  Copyright © 2017年 LianLian Pay Inc. All rights reserved.
//

#import "LLDBaseVC.h"

@import CoreLocation;

@interface LLDBaseVC () <CLLocationManagerDelegate>

@end

@implementation LLDBaseVC

#pragma mark - life cycle

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkUpdate)
                                                 name:@"com.lianlianpay.checkUpdate"
                                               object:nil];
    self.showHud = YES;
    [self hudConfig];
    [self uiStyleConfiguration];
    [self lldNavConfig];
}

- (void)checkUpdate {
    Class UpdateMgr = NSClassFromString(@"PgyUpdateManager");
    if (!UpdateMgr) {
        return;
    }
    SEL sharedMgr = NSSelectorFromString(@"sharedPgyManager");
    SEL method = NSSelectorFromString(@"checkUpdate");
    if ([UpdateMgr respondsToSelector:sharedMgr]) {
        id mgr = [UpdateMgr performSelector:sharedMgr];
        if ([mgr respondsToSelector:method]) {
            [UpdateMgr performSelector:method];
        }
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)hudConfig {
    [SVProgressHUD setMaximumDismissTimeInterval:1];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (@available(iOS 11.0, *)) {
        [self.navigationController.navigationBar setPrefersLargeTitles:YES];
    }
    [self choooseEnvironmentMappedMerchant];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (@available(iOS 11.0, *)) {
        [self.navigationController.navigationBar setPrefersLargeTitles:NO];
    }
}

- (void)choooseEnvironmentMappedMerchant {
    LLDTextField *field = [self.tableView field:@"oid_partner"] ?: [self.tableView field:@"oid_plat"];
    NSString *text = field.text;
    NSArray *arr = field.model.text;
    for (NSDictionary *dic in arr) {
        if ([dic[@"field"] isEqualToString:text]) {
            field.text = [LLDSettingVC environment] == EnvironmentTypeTest ? self.merchantTest ?: field.text
                                                                           : self.merchantRelease ?: field.text;
        }
    }
}

#pragma mark - private

- (void)uiStyleConfiguration {
}

- (void)configMerchantForTest:(NSString *)testMerchantNo andRelease:(NSString *)releaseMerchantNo {
    LLDTextField *merchantField = [self.tableView field:@"oid_partner"];
    if (merchantField == nil) {
        merchantField = [self.tableView field:@"oid_plat"];
    }
    NSMutableArray *arr = @[].mutableCopy;
    if (releaseMerchantNo.length > 0) {
        [arr addObject:@{ @"field" : releaseMerchantNo, @"picker" : @"正式商户号" }];
    }
    if (testMerchantNo.length > 0) {
        [arr addObject:@{ @"field" : testMerchantNo, @"picker" : @"测试商户号" }];
    }

    [arr addObject:@{ @"field" : @"", @"picker" : @"自定义" }];
    merchantField.model.text = arr.copy;
    if (!(merchantField.text.length > 0)) {
        merchantField.text = [LLDSettingVC environment] == EnvironmentTypeTest ? testMerchantNo ?: @"" : releaseMerchantNo ?: @"";
    }
}

- (void)lldNavConfig {
    self.view.backgroundColor = kLLDemoBGColor;
    self.navigationController.navigationBar.barTintColor = kLLDemoColor;
    NSDictionary *attributes = @{NSForegroundColorAttributeName : kLLDNavTextColor};
    if (@available(iOS 11.0, *)) {
        [self.navigationController.navigationBar setLargeTitleTextAttributes:attributes];
    }
    [self.navigationController.navigationBar setTintColor:[kLLDemoColor isEqual:[UIColor whiteColor]] ? kLLDNavTextColor : [UIColor whiteColor]];
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];
    if (self == self.navigationController.viewControllers.firstObject) {
        UIBarButtonItem *rightBBI = [LLDUtil llBBIWithTitle:@"设置" andTarget:self action:@selector(configEnv)];
        self.navigationItem.rightBarButtonItem = rightBBI;
    }
}

- (void)configEnv {
    [LLDSettingVC defaultSetting].updateUrl = self.tableView.uiModel.downloadUrl;
    [self.navigationController pushViewController:[LLDSettingVC defaultSetting] animated:YES];
}

- (NSString *)text:(NSString *)key {
    return [self.tableView field:key].text;
}
- (void)lldNextAction {
    [self.tableView endEditing:YES];
}

- (void)userInterfaceWithPlist:(NSString *)plist {
    [self.tableView configWithPlist:plist];
    [self.view addSubview:self.tableView];
    [self refreshTimeAndUser];
    self.title = self.tableView.uiModel.headerTitle;
}

- (void)userInterfaceWithModel:(LLUIModel *)model {
    self.tableView.uiModel = model;
    [self.tableView configWithModel];
    [self.view addSubview:self.tableView];
    [self refreshTimeAndUser];
    self.title = self.tableView.uiModel.headerTitle;
}

- (void)userInterfaceWithInterface:(LLDInterface *)interface {
    LLUIModel *model = [[LLUIModel alloc] initWithInterface:interface];
    [self userInterfaceWithModel:model];
    self.title = interface.headTitle;
}

- (void)refreshTimeAndUser {
    [self refreshTimeRelatedTexts];
    LLDTextField *userIDField = [self.tableView field:@"user_id"];
    if (userIDField.text.length == 0) {
        NSString *order = [LLDUtil generateOrderNO];
        order = [order substringFromIndex:order.length - 4];
        userIDField.text = [@"User" stringByAppendingString:order];
    }
}

- (NSString *)inputedKey {
    NSString *inputedKey = [self.tableView field:@"merchantKey"].text;
    if (inputedKey.length > 0) {
        return [self validKey:inputedKey];
    } else {
        return nil;
    }
}

- (NSString *)keyForMerchant {
    if ([self inputedKey]) return [self inputedKey];

    NSString *merchantID = [self.tableView textForKeys:@[ @"oid_partner", @"oid_plat" ]];
    NSString *sign_type = [self.tableView field:@"sign_type"].text;
    BOOL isUsingRSA = [sign_type rangeOfString:@"RSA"].length != 0;
    NSString *plistKey = [self keyForMerchant:merchantID isRSA:isUsingRSA];
    if (plistKey.length > 0) {
        return plistKey;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showInfoWithStatus:@"无对应密钥"];
    });
    return nil;
}

- (NSString *)keyForMerchant:(NSString *)merchant isRSA:(BOOL)isRSA {

    if ([self inputedKey]) return [self inputedKey];

    NSString *merchantID = merchant;
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Merchants" ofType:@"plist"];
    NSArray *merchants = [NSArray arrayWithContentsOfFile:plistPath];
    NSString *md5Key = @"yintong1234567890";
    for (NSDictionary *merchant in merchants) {
        if ([merchant[@"merchantNo"] isEqualToString:merchantID]) {
            if (isRSA) {
                NSString *rsaKey = [merchant valueForKey:@"rsaPrivateKey"];
                return [self validKey:rsaKey];
            }
            md5Key = [merchant valueForKey:@"md5Key"];
            return [self validKey:md5Key];
        }
    }
    return nil;
}


- (NSString *)validKey:(NSString *)key {
    return [[key componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsJoinedByString:@""];
}

- (void)pushInfoVCWithTitle:(NSString *)title andDic:(NSDictionary *)dic {
    NSString *retCode = dic[@"ret_code"];
    BOOL success = [retCode isEqualToString:@"0000"] || [retCode isEqualToString:@"LE0000"];
    NSString *retMsg = dic[@"ret_msg"];
    [self pushInfoVC:title success:success text:retMsg ?: title detail:nil info:dic];
}

- (void)pushInfoVC:(NSString *)title
           success:(BOOL)success
              text:(NSString *)text
            detail:(NSString *)detail
              info:(NSDictionary *)info {
    LLResultInfoVC *resultVC = [[LLResultInfoVC alloc] initWithInfoDic:info];
    resultVC.title = title;
    resultVC.text = text;
    resultVC.detail = detail;
    resultVC.showHeadView = text.length > 0 || detail.length > 0;
    resultVC.success = success;
    [self.navigationController pushViewController:resultVC animated:YES];
}

- (void)lldAlertWithTitle:(NSString *)title andMsg:(NSString *)msg {
    if ([UIDevice currentDevice].systemVersion.floatValue > 7.8) {
        UIAlertController *alert =
            [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [[[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil] show];
    }
}

- (void)alertWithMsg:(NSString *)msg {
    [self lldAlertWithTitle:@"提示" andMsg:msg];
}

#pragma mark - getter/setter

- (void)setMerchantTest:(NSString *)merchantTest {
    _merchantTest = merchantTest;
    [self configMerchantForTest:merchantTest andRelease:self.merchantRelease];
}

- (void)setMerchantRelease:(NSString *)merchantRelease {
    _merchantRelease = merchantRelease;
    [self configMerchantForTest:self.merchantTest andRelease:merchantRelease];
}

- (LLDTableView *)tableView {
    if (!_tableView) {
        _tableView = [[LLDTableView alloc] initWithFrame:CGRectMake(0, 0, kLLDScreenWidth, kLLDScreenHeight)];
        [_tableView addTarget:self action:@selector(lldNextAction)];
    }
    return _tableView;
}

- (NSMutableDictionary *)paymentInfo {
    if (!_paymentInfo) {
        _paymentInfo = [NSMutableDictionary dictionary];
    }
    return _paymentInfo;
}

- (CLLocationManager *)locationMgr {
    if (!_locationMgr) {
        _locationMgr = [CLLocationManager new];
        _locationMgr.delegate = self;
    }
    return _locationMgr;
}

@end
