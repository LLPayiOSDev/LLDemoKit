//
//  LLUIModel.h
//  LLDemoKit
//
//  Created by EvenLin on 2017/8/15.
//  Copyright © 2017年 LianLian Pay Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLDTextField.h"
#import "LLDInterface.h"

@interface LLUIModel : NSObject

- (instancetype)initWithPlist:(NSString *)name;
- (instancetype)initWithInterface:(LLDInterface *)interface;

// plist名称， 根据此字段缓存
@property (nonatomic, strong) NSString *plistName;
@property (nonatomic, strong) NSString *headerTitle;
@property (nonatomic, strong) NSString *footerTitle;
@property (nonatomic, strong) NSString *downloadUrl;
@property (nonatomic, strong) NSArray *textFields;
@property (nonatomic, strong) id target;
@property (nonatomic, strong) NSArray *headers;

- (NSDictionary *)getFieldsData;
- (void)reloadFields;
- (NSDictionary *)fieldsDataWithArray:(NSArray *)arr;
- (void)parseFields;
- (LLDTextField *)fieldForKey:(NSString *)key;
- (LLDTextField *)fieldAtIndexPath:(NSIndexPath *)indexPath;

@end
