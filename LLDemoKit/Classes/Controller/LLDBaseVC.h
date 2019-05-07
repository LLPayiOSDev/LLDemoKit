//
//  LLDBaseVC.h
//  LLDemoKit
//
//  Created by EvenLin on 2017/9/21.
//  Copyright © 2017年 LianLian Pay Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLDTableView.h"
#import "LLDConsts.h"
#import "LLResultInfoVC.h"
#import "LLDInterface.h"
#import "LLDUtil.h"
#import "LLDSettingVC.h"
#import <SVProgressHUD/SVProgressHUD.h>

@import CoreLocation;

typedef void (^ExitParam)(NSDictionary *exitParam);

@interface LLDBaseVC : UIViewController

@property (nonatomic, strong) CLLocationManager *locationMgr;
@property (nonatomic, strong) LLDTableView *tableView;
@property (nonatomic, strong) NSMutableDictionary *paymentInfo;
@property (nonatomic, copy) ExitParam exitParam;
@property (nonatomic, assign) BOOL showHud;
@property (nonatomic, strong) NSString *merchantTest;
@property (nonatomic, strong) NSString *merchantRelease;
///与时间相关的输入框
@property (nonatomic, strong) NSArray *timeRelatedFields;

#pragma mark - UI

- (void)userInterfaceWithPlist:(NSString *)plist;
- (void)userInterfaceWithModel:(LLUIModel *)model;
- (void)userInterfaceWithInterface:(LLDInterface *)interface;
- (void)uiStyleConfiguration;
- (void)lldNavConfig;

#pragma mark - action

//检查更新方法
- (void)checkUpdate;
- (void)lldNextAction;
- (void)pushInfoVCWithTitle:(NSString *)title andDic:(NSDictionary *)dic;
- (void)pushInfoVC:(NSString *)title
           success:(BOOL)success
              text:(NSString *)text
            detail:(NSString *)detail
              info:(NSDictionary *)info;
- (void)alertWithMsg:(NSString *)msg;
- (void)lldAlertWithTitle:(NSString *)title andMsg:(NSString *)msg;

- (NSString *)keyForMerchant;
- (NSString *)keyForMerchant:(NSString *)merchant isRSA:(BOOL)isRSA;
- (NSString *)text:(NSString *)key;

@end

#pragma mark - Right Action

@interface LLDBaseVC (RightAction)

- (void)refreshTimeRelatedTexts;

- (void)requestTokenWithDic:(NSDictionary *)paramDic path:(NSString *)path complete:(void (^)(NSDictionary *responseDic))complete;

- (void)requestConfiguration:(NSMutableURLRequest *)request;

@end
