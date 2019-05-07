//
//  LLUIModel.m
//  LLDemoKit
//
//  Created by EvenLin on 2017/8/15.
//  Copyright © 2017年 LianLian Pay Inc. All rights reserved.
//

#import "LLUIModel.h"
#import "LLDConsts.h"

@implementation LLUIModel

- (instancetype)initWithPlist:(NSString *)name {
    self = [super init];
    if (self) {
        self.plistName = name;
        NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"plist"];
        if (path == nil) {
            path = [[NSBundle bundleWithPath:kLLDBundlePath] pathForResource:name ofType:@"plist"];
        }
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

- (instancetype)initWithInterface:(LLDInterface *)interface {
    self = [super init];
    if (self) {
        self.plistName = interface.interfaceName;
        self.headerTitle = interface.headTitle;
        self.footerTitle = interface.nextTitle;
        self.detail = interface.headDetail;
        self.downloadUrl = interface.downloadUrl;
        NSMutableArray *arr = @[].mutableCopy;
        NSDictionary *optionalArr =
            [self sectionDicWithHeader:@"Optional" footer:nil andFields:interface.optionalKeys isNecessary:NO];
        if (interface.optionalKeys.count > 0) {
            [arr addObject:optionalArr];
        }
        NSDictionary *necessaryArr =
            [self sectionDicWithHeader:@"Necessary" footer:nil andFields:interface.necessaryKeys isNecessary:YES];
        if (interface.necessaryKeys.count > 0) {
            [arr addObject:necessaryArr];
        }
        NSDictionary *sdkParamArr = [self sectionDicWithHeader:@"SDKParams"
                                                        footer:@"SDKParams为创单后请求SDK的参数,请先获取Token"
                                                     andFields:interface.sdkParams
                                                   isNecessary:YES];
        if (interface.sdkParams.count > 0) {
            [arr addObject:sdkParamArr];
        }
        self.textFields = [arr copy];
    }
    return self;
}

- (NSDictionary *)sectionDicWithHeader:(NSString *)header
                                footer:(NSString *)footer
                             andFields:(NSArray *)fields
                           isNecessary:(BOOL)necessary {
    NSMutableDictionary *dic = @{}.mutableCopy;
    dic[@"sectionHeader"] = header;
    dic[@"sectionFooter"] = footer;
    dic[@"fields"] = fields;
    dic[@"mustPass"] = necessary ? @"1" : @"0";
    return [dic copy];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
}

- (NSDictionary *)getFieldsData {
    NSMutableDictionary *mutDic = [NSMutableDictionary dictionary];
    for (NSDictionary *dic in self.textFields) {
        NSArray *fields = dic[@"fields"];
        for (LLDTextField *field in fields) {
            if (field.model.shouldRemove.boolValue) {
                continue;
            }
            [mutDic setValue:field.text.length > 0 ? field.text : nil forKey:field.key];
        }
    }
    if (mutDic.allKeys.count > 0) {
        return [mutDic copy];
    }
    return nil;
}

- (NSDictionary *)fieldsDataWithArray:(NSArray *)arr {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for (NSDictionary *dic in self.textFields) {
        NSArray *fields = dic[@"fields"];
        for (LLDTextField *field in fields) {
            if ([arr containsObject:field.key]) {
                [dic setValue:field.text.length > 0 ? field.text : nil forKey:field.key];
            }
        }
    }
    return [dic copy];
}

- (void)reloadFields {

    for (NSDictionary *dic in self.textFields) {
        NSArray *arr = dic[@"fields"];
        for (LLDTextField *field in arr) {
            [field reloadField];
        }
    }
}

- (LLDTextField *)fieldForKey:(NSString *)key {
    for (NSDictionary *dic in self.textFields) {
        NSArray *fields = dic[@"fields"];
        for (LLDTextField *field in fields) {
            if ([field.key isEqualToString:key]) {
                return field;
            }
        }
    }
    return nil;
}

- (LLDTextField *)fieldAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *targetDic = [self.textFields objectAtIndex:indexPath.section];
    NSArray *fields = [targetDic objectForKey:@"fields"];
    LLDTextField *field = [fields objectAtIndex:indexPath.row];
    return field;
}

- (void)parseFields {

    NSMutableArray *models = [NSMutableArray array];

    for (NSDictionary *dic in self.textFields) {
        NSMutableDictionary *section = [NSMutableDictionary dictionary];
        NSString *sectionHeader = [dic valueForKey:@"sectionHeader"];
        NSString *sectionFooter = [dic valueForKey:@"sectionFooter"];
        if (sectionHeader.length > 0) {
            section[@"sectionHeader"] = sectionHeader;
        }
        if (sectionFooter.length > 0) {
            section[@"sectionFooter"] = sectionFooter;
        }
        BOOL mustPass = [dic[@"mustPass"] isEqualToString:@"1"];
        NSMutableArray *fieldModelArr = [NSMutableArray array];
        NSArray *fieldsArr = [dic valueForKey:@"fields"];
        for (NSString *key in fieldsArr) {
            LLDTextField *field = [[LLDTextField alloc] initWithKey:key andTarget:self.target];
            field.llCacheKey = [NSString stringWithFormat:@"%@-%@", self.plistName, key];
            field.mustPass = mustPass;
            [field parseField];
            [fieldModelArr addObject:field];
        }
        section[@"fields"] = [fieldModelArr copy];
        [models addObject:section];
    }
    self.textFields = [models copy];
}
@end
