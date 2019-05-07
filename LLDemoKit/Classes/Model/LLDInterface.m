//
//  LLDInterface.m
//  LLDemoKit
//
//  Created by EvenLin on 2018/1/25.
//  Copyright © 2018年 LianLian Pay Inc. All rights reserved.
//

#import "LLDInterface.h"

@implementation LLDInterface

- (instancetype)init {
    self = [super init];
    if (self) {
        self.nextTitle = self.nextTitle ?: @"下一步";
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name
                   headTitle:(NSString *)headTitle
                  headDetail:(NSString *)headDetail
               necessaryKeys:(NSArray *)necessaryKeys
                optionalKeys:(NSArray *)optionalKeys
                   sdkParams:(NSArray *)sdkParams {
    self = [self init];
    if (self) {
        self.interfaceName = name;
        self.headTitle = headTitle;
        self.headDetail = headDetail;
        self.necessaryKeys = necessaryKeys.count > 0 ? necessaryKeys : nil;
        self.optionalKeys = optionalKeys.count > 0 ? optionalKeys : nil;
        self.sdkParams = sdkParams.count > 0 ? sdkParams : nil;
    }
    return self;
}

@end
