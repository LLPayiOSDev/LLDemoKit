//
//  LLDTextField.h
//  LLDemoKit
//
//  Created by EvenLin on 2017/8/15.
//  Copyright © 2017年 LianLian Pay Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LLTextFieldModel : NSObject

- (instancetype)initWithKey:(NSString *)key;

@property (nonatomic, strong) id text;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *keyboardType;
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *secure;
@property (nonatomic, strong) NSString *rightViewText;
@property (nonatomic, strong) NSString *booleanText;
@property (nonatomic, strong) NSString *rightViewAction;
@property (nonatomic, strong) NSString *shouldRemove;

@end

@interface LLDTextField : UITextField

@property (nonatomic, strong) id target;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) LLTextFieldModel *model;
@property (nonatomic, strong) NSString *llCacheKey;
@property (nonatomic, assign) BOOL mustPass;

- (instancetype)initWithKey:(NSString *)key andTarget:(id)target;
- (void)parseField;
- (void)reloadField;
///使用NSUserDefault缓存Text
- (void)cacheText;
- (void)startLoad;
- (void)endLoad;
@end
