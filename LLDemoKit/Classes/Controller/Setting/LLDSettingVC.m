//
//  LLDSettingVC.m
//  LLDemoKit
//
//  Created by EvenLin on 2018/3/15.
//  Copyright © 2018年 LianLian Pay Inc. All rights reserved.
//

#import "LLDSettingVC.h"
#import "LLDTextViewController.h"
#import "LLDWebViewController.h"

static LLDSettingVC *setting;

@interface LLDSettingVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *settingTb;
@property (nonatomic, strong) NSArray *configArr;

@end

@implementation LLDSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.envType = [LLDSettingVC environment];
    self.title = @"设置";
    [self.view addSubview:self.settingTb];
}

#pragma mark - delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3 + [self add];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [self environmentInfo].count;
    }
    if (section == 1) {
        return 1;
    }
    if (section == 2 && self.configArr.count > 0) {
        return self.configArr.count;
    }
    if (section == (2 + [self add])) {
        return 2;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"set"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"set"];
    }
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    //环境
    if (indexPath.section == 0) {
        cell.detailTextLabel.text = @"";
        cell.textLabel.text = [[self environmentInfo] objectAtIndex:indexPath.row];
        if (indexPath.row == self.envType) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }

    //地址
    if (indexPath.section == 1) {
        cell.textLabel.text = @"地址";
        cell.detailTextLabel.numberOfLines = 2;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        switch (self.envType) {
            case EnvironmentTypeDefault:
                cell.detailTextLabel.text = self.defaultAddress ?: @"正式环境不支持自定义";
                cell.accessoryType = UITableViewCellAccessoryNone;
                break;
            case EnvironmentTypeTest:
                cell.detailTextLabel.text = self.testAddress.length > 0 ? self.testAddress : @"请配置测试环境地址";
                break;
            case EnvironmentTypeUAT:
                cell.detailTextLabel.text = self.uatAddress.length > 0 ? self.uatAddress : @"请配置UAT环境地址";
                break;
            default: break;
        }
    }

    //配置
    if (indexPath.section == 2 && self.configArr.count > 0) {
        cell.textLabel.text = self.configArr[indexPath.row][@"name"];
        UISwitch *accessorySwitch = [UISwitch new];
        accessorySwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:self.configArr[indexPath.row][@"key"]];
        accessorySwitch.tag = indexPath.row;
        [accessorySwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = accessorySwitch;
    }

    if (indexPath.section == (2 + [self add])) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"检查更新";
            cell.detailTextLabel.text = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
            cell.accessoryType = UITableViewCellAccessoryDetailButton;
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = @"关于";
            cell.detailTextLabel.text =
                self.sdkVersion ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }



    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    if ([[tableView cellForRowAtIndexPath:indexPath].textLabel.text isEqualToString:@"检查更新"]) {
        LLDWebViewController *webVC = [[LLDWebViewController alloc] init];
        webVC.webUrl = self.updateUrl;
        webVC.title = @"检查更新";
        [self.navigationController pushViewController:webVC animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //切换环境
    if (indexPath.section == 0) {
        self.envType = indexPath.row;
        [tableView reloadData];
    }
    //测试环境地址
    if (indexPath.section == 1 && !(self.envType == EnvironmentTypeDefault)) {
        UIAlertController *alert =
            [UIAlertController alertControllerWithTitle:@"自定义地址" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *_Nonnull textField) {
            textField.text = self.testAddress;
            if (self.envType == EnvironmentTypeUAT) textField.text = self.uatAddress;
            textField.textAlignment = NSTextAlignmentCenter;
            textField.accessibilityIdentifier = @"testAddrField";
            textField.borderStyle = UITextBorderStyleRoundedRect;
            textField.placeholder = @"请输入自定义地址";
            textField.borderStyle = UITextBorderStyleNone;
            textField.keyboardType = UIKeyboardTypeURL;
            textField.textAlignment = NSTextAlignmentCenter;
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        }];
        UIAlertAction *action =
            [UIAlertAction actionWithTitle:@"好"
                                     style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *_Nonnull action) {
                                       UITextField *field = alert.textFields.firstObject;

                                       NSString *key = @"com.lianlianpay.address.test";
                                       if (self.envType == EnvironmentTypeUAT) key = @"com.lianlianpay.address.uat";

                                       [[NSUserDefaults standardUserDefaults] setValue:field.text forKey:key];
                                       [[NSUserDefaults standardUserDefaults] synchronize];
                                       [tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:1] ]
                                                        withRowAnimation:UITableViewRowAnimationAutomatic];
                                   }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }

    if (indexPath.section == (2 + [self add])) {
        //检查更新
        if (indexPath.row == 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"com.lianlianpay.checkUpdate" object:nil];
        }
        //关于
        if (indexPath.row == 1) {
            if (self.sdkAbout.length > 0) {
                LLDTextViewController *aboutVC = [[LLDTextViewController alloc] init];
                aboutVC.fileName = self.sdkAbout;
                [self.navigationController pushViewController:aboutVC animated:YES];
            }
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"环境";
    }
    if (section == 1) {
        return @"自定义环境地址";
    }
    if (section == 2 && self.configArr.count > 0) {
        return @"配置";
    }
    return @"";
}

#pragma mark - private

- (void)switchValueChanged:(UISwitch *)sender {
    NSString *key = [self.configArr objectAtIndex:sender.tag][@"key"];
    [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray *)environmentInfo {
    return @[ @"正式环境", @"测试环境", @"UAT环境" ];
}

- (NSInteger)add {
    return self.configArr.count > 0 ? 1 : 0;
}

+ (void)addConfiguration:(NSString *)configurationName forKey:(NSString *)key {
    if (!(configurationName.length > 0 && key.length > 0)) {
        return;
    }
    NSArray *savedConfigurations = [LLDSettingVC defaultSetting].configArr;
    NSMutableArray *mConf = savedConfigurations ? savedConfigurations.mutableCopy : @[].mutableCopy;
    NSDictionary *dic = @{ @"name" : configurationName, @"key" : key };
    if (![mConf containsObject:dic]) {
        [mConf addObject:dic];
    }
    [LLDSettingVC defaultSetting].configArr = mConf.copy;
}

- (NSString *)stringForFile:(NSString *)file {
    if (!file) return nil;
    NSString *path = [[NSBundle mainBundle] pathForResource:file ofType:@"md"];
    NSString *readMe = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    return readMe;
}

#pragma mark - getter

+ (instancetype)defaultSetting {

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        setting = [[LLDSettingVC alloc] init];
        setting.configArr = nil;
    });
    return setting;
}

+ (EnvironmentType)environment {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"com.lianlianpay.environment"];
}

- (NSString *)uatAddress {
    NSString *savedAddr = [[NSUserDefaults standardUserDefaults] valueForKey:@"com.lianlianpay.address.uat"];
    if (savedAddr.length > 0) {
        return savedAddr;
    }
    [[NSUserDefaults standardUserDefaults] setValue:_uatAddress forKey:@"com.lianlianpay.address.uat"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return _uatAddress;
}

- (NSString *)testAddress {
    NSString *savedAddr = [[NSUserDefaults standardUserDefaults] valueForKey:@"com.lianlianpay.address.test"];
    if (savedAddr.length > 0) {
        return savedAddr;
    }
    [[NSUserDefaults standardUserDefaults] setValue:_testAddress forKey:@"com.lianlianpay.address.test"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return _testAddress;
}

+ (BOOL)isDebug {
#ifdef DEBUG
    return YES;
#endif
    return NO;
}

- (void)setEnvType:(EnvironmentType)envType {
    _envType = envType;
    [[NSUserDefaults standardUserDefaults] setInteger:envType forKey:@"com.lianlianpay.environment"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (CGRect)tableRect {
    BOOL translucent = self.navigationController.navigationBar.isTranslucent;
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - (translucent ? 0 : 64));
    return rect;
}

- (UITableView *)settingTb {
    if (!_settingTb) {
        _settingTb = [[UITableView alloc] initWithFrame:[self tableRect] style:UITableViewStyleGrouped];
        _settingTb.delegate = self;
        _settingTb.dataSource = self;
        _settingTb.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    return _settingTb;
}

@end
