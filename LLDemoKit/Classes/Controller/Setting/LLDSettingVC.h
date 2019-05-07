//
//  LLDBaseVC.h
//  LLDemoKit
//
//  Created by EvenLin on 2018/3/15.
//  Copyright © 2018年 LianLian Pay Inc. All rights reserved.
//  测试环境地址缓存KEY：com.lianlianpay.address.test
//  UAT环境地址缓存KEY: com.lianlianpay.address.uat
//  环境切换缓存KEY: com.lianlianpay.environment

#import "LLDBaseVC.h"

typedef NS_ENUM(NSUInteger, EnvironmentType) {
    EnvironmentTypeDefault,
    EnvironmentTypeTest,
    EnvironmentTypeUAT,
};

@interface LLDSettingVC : UIViewController

+ (instancetype)defaultSetting;
+ (BOOL)isDebug;

@property (nonatomic, assign) EnvironmentType envType;

@property (nonatomic, strong) NSString *defaultAddress;
@property (nonatomic, strong) NSString *testAddress;
@property (nonatomic, strong) NSString *uatAddress;

@property (nonatomic, strong) NSString *updateUrl;
@property (nonatomic, strong) NSString *sdkVersion;
@property (nonatomic, strong) NSString *sdkAbout;

+ (EnvironmentType)environment;
+ (void)addConfiguration:(NSString *)configurationName forKey:(NSString *)key;

@end
