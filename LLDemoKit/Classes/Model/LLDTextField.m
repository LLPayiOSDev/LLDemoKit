//
//  LLDTextField.m
//  LLDemoKit
//
//  Created by EvenLin on 2017/8/15.
//  Copyright © 2017年 LianLian Pay Inc. All rights reserved.
//

#import "LLDTextField.h"
#import "LLDConsts.h"

@implementation LLTextFieldModel

- (instancetype)initWithKey:(NSString *)key {
    self = [super init];
    if (self) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"InputFields" ofType:@"plist"];
        NSArray *fieldArr = [NSArray arrayWithContentsOfFile:plistPath];
        BOOL avalableInPlist = NO;

        for (id field in fieldArr) {
            if ([field isKindOfClass:[NSString class]]) {
                continue;
            }
            if ([field isKindOfClass:[NSDictionary class]]) {
                if ([field[@"key"] isEqualToString:key]) {
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"com.lianlianpay.saveplist"]) {
                        [self saveFieldToPlist:field];
                    }
                    avalableInPlist = YES;
                    [self setValuesForKeysWithDictionary:field];
                }
            }
        }
        if (!avalableInPlist) {
            self.key = key;
            self.title = key;
            self.keyboardType = @"0";
            self.placeholder = [@"请输入 " stringByAppendingString:self.key];
        }
    }
    return self;
}

- (void)saveFieldToPlist:(NSDictionary *)dic {
    NSMutableArray *cachedFields = @[].mutableCopy;
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.cachePath]) {
        cachedFields = [NSArray arrayWithContentsOfFile:[self cachePath]].mutableCopy;
    }
    if (![cachedFields containsObject:dic]) {
        [cachedFields addObject:dic];
        [cachedFields.copy writeToFile:[self cachePath] atomically:YES];
    }
}

- (NSString *)cachePath {
    NSString *path =
        [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"InputFields.plist"];
    return path;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
}

@end

@interface LLDTextField () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) UIButton *rightBtn;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UISwitch *fieldSwitch;

@end


@implementation LLDTextField

- (instancetype)initWithKey:(NSString *)key andTarget:(id)target {
    self = [super init];
    if (self) {
        self.key = key;
        self.target = target;
    }
    return self;
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self cacheText];
}

- (void)hide {
    [self resignFirstResponder];
}

- (BOOL)becomeFirstResponder {
    if (self.model.booleanText.length > 0) {
        return NO;
    }
    if ([self.model.text isKindOfClass:[NSArray class]]) {
        NSArray *arr = self.model.text;
        for (NSDictionary *dic in arr) {
            if ([dic[@"field"] isEqualToString:self.text]) {
                NSInteger index = [arr indexOfObject:dic];
                [self.pickerView selectRow:index inComponent:0 animated:YES];
            }
        }
    }
    UILabel *leftLb = ((UILabel *)self.leftView.subviews.firstObject);
    [UIView animateWithDuration:0.5
                     animations:^{
                         leftLb.font = [UIFont boldSystemFontOfSize:18];
                     }];
    return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    UILabel *leftLb = ((UILabel *)self.leftView.subviews.firstObject);
    [UIView animateWithDuration:0.5
                     animations:^{
                         leftLb.font = [UIFont systemFontOfSize:15];
                     }];

    if ([self.model.text isKindOfClass:[NSArray class]]) {
        self.inputView = self.pickerView;
    }
    return [super resignFirstResponder];
}

- (CGRect)caretRectForPosition:(UITextPosition *)position {
    return [super caretRectForPosition:position];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return [super canPerformAction:action withSender:sender];
}

- (void)reloadField {
    [self setFieldWithModel:self.model];
}

- (void)parseField {
    LLTextFieldModel *model = [[LLTextFieldModel alloc] initWithKey:self.key];
    self.model = model;
    [self setFieldWithModel:model];
}

- (void)setFieldWithModel:(LLTextFieldModel *)model {
    self.frame = CGRectMake(18, 0, kLLDScreenWidth - 26, 44);
    self.placeholder = model.placeholder ?: self.key;
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    if (model.keyboardType.integerValue == 20) {
        self.inputView = self.datePicker;
    }
    if (model.keyboardType.integerValue == 21) {
        self.inputView = self.datePicker;
        self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    }
    self.keyboardType = model.keyboardType.integerValue;
    self.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.returnKeyType = UIReturnKeyDone;
    self.textColor = [UIColor blackColor];
    self.font = [UIFont systemFontOfSize:14];
    self.secureTextEntry = model.secure.boolValue;
    self.borderStyle = UITextBorderStyleNone;

    NSString *text = [[NSUserDefaults standardUserDefaults] valueForKey:self.llCacheKey ?: self.key];
    [self configRightView];
    if (text.length > 0) {
        self.text = text;
        if ([model.text isKindOfClass:[NSArray class]]) {
            NSArray *textArr = (NSArray *)model.text;
            self.inputView = self.pickerView;
            NSInteger index = [self indexForText:text];
            if (index < textArr.count) {
                [self.pickerView selectRow:index inComponent:0 animated:YES];
            }
        }
    } else {
        if ([model.text isKindOfClass:[NSArray class]]) {
            self.inputView = self.pickerView;
            self.text = model.text[0][@"field"];
            [self.pickerView selectRow:0 inComponent:0 animated:YES];
        } else {
            self.text = model.text;
        }
    }
    if (model.title) {
        [self leftViewSetting:model.title];
    } else {
        [self leftViewSetting:model.key];
    }
}

- (void)startLoad {
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] init];
    indicatorView.color = kLLDemoColor;
    indicatorView.frame = CGRectMake(0, 0, 40, 40);
    [indicatorView startAnimating];
    self.rightView = indicatorView;
}

- (void)endLoad {
    [self.rightView removeFromSuperview];
    self.rightView = self.rightBtn;
}

- (void)configRightView {
    if (self.model.booleanText.length > 0) {
        self.rightView = self.fieldSwitch;
        self.rightViewMode = UITextFieldViewModeAlways;
        self.allowsEditingTextAttributes = NO;
        NSString *text = [[NSUserDefaults standardUserDefaults] valueForKey:self.llCacheKey ?: self.key];
        NSString *textTrue = [self.model.booleanText componentsSeparatedByString:@":"].firstObject;
        NSString *textFalse = [self.model.booleanText componentsSeparatedByString:@":"].lastObject;
        if (text.length > 0) {
            self.fieldSwitch.on = [text isEqualToString:textTrue];
            self.text = text;
        } else {
            self.text = self.fieldSwitch.isOn ? textTrue : textFalse;
        }
        self.textColor = [UIColor clearColor];
        return;
    }
    if (!(self.model.rightViewText.length > 0)) {
        return;
    }
    self.rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rightBtn.frame = CGRectMake(0, 0, 40, 25);
    [self.rightBtn setTitle:self.model.rightViewText forState:UIControlStateNormal];
    self.rightBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.rightBtn setTitleColor:[kLLDemoColor isEqual:[UIColor whiteColor]] ? kLLDNavTextColor : kLLDemoColor
                        forState:UIControlStateNormal];
    if (self.model.rightViewAction.length > 0 && self.target) {
        if ([self.target respondsToSelector:NSSelectorFromString(self.model.rightViewAction)]) {
            [self.rightBtn addTarget:self.target
                              action:NSSelectorFromString(self.model.rightViewAction)
                    forControlEvents:UIControlEventTouchUpInside];
        }
    }
    self.rightView = self.rightBtn;
    self.rightViewMode = UITextFieldViewModeUnlessEditing;
}

- (void)leftViewSetting:(NSString *)title {
    self.leftView = [self labelWithText:title width:@"国国国国国国"];//💩
    self.leftViewMode = UITextFieldViewModeAlways;
}

- (UIView *)labelWithText:(NSString *)text width:(NSString *)widthString {
    CGFloat fontSize = [UIFont systemFontSize];
    fontSize = 15;
    NSString *modelTitle = widthString;
    NSDictionary *strAttrbutes =
        @{NSFontAttributeName : [UIFont systemFontOfSize:fontSize], NSForegroundColorAttributeName : [UIColor redColor]};
    CGRect newFrame = [text boundingRectWithSize:CGSizeMake(999, self.frame.size.height)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:strAttrbutes
                                         context:nil];
    CGRect newFrameB = [modelTitle boundingRectWithSize:CGSizeMake(999, self.frame.size.height)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:strAttrbutes
                                                context:nil];
    CGRect frame = newFrame.size.width > newFrameB.size.width ? newFrame : newFrameB;
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width + 8, self.frame.size.height)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width + 8, self.frame.size.height)];
    label.textColor = [UIColor blackColor];
    label.text = text;
    label.font = [UIFont systemFontOfSize:fontSize];
    if (self.mustPass) {
        label.textColor = [UIColor redColor];
    } else {
        label.textColor = [UIColor darkTextColor];
    }
    label.adjustsFontSizeToFitWidth = YES;
    [leftView addSubview:label];
    return leftView;
}

- (void)cacheText {
    [[NSUserDefaults standardUserDefaults] setValue:self.text forKey:self.llCacheKey ?: self.key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (NSInteger)indexForText:(NSString *)text {
    NSArray *arr = (NSArray *)self.model.text;
    for (NSDictionary *dic in arr) {
        if ([dic[@"field"] isEqualToString:text]) {
            return [arr indexOfObject:dic];
        }
    }
    return 0;
}

#pragma mark - PickerView

- (UIPickerView *)pickerView {
    if (!_pickerView) {
        _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 300, 216)];
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
        _pickerView.backgroundColor = kLLDHexColor(0xf6f6f6);
    }
    return _pickerView;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return ((NSArray *)self.model.text).count;
}

- (UIView *)pickerView:(UIPickerView *)pickerView
            viewForRow:(NSInteger)row
          forComponent:(NSInteger)component
           reusingView:(UIView *)view {
    if (row >= ((NSArray *)self.model.text).count) {
        return nil;
    }
    UILabel *label = [self labelWithText:[((NSArray *)self.model.text) objectAtIndex:row][@"picker"]
                                   width:@"上岛咖啡盛开的积分速度快放假"];
    label.textColor = [UIColor darkTextColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:16];
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSArray *arr = (NSArray *)self.model.text;
    NSDictionary *dic = [arr objectAtIndex:row];
    if ([[dic valueForKey:@"picker"] isEqualToString:@"自定义"]) {
        [self resignFirstResponder];
        self.inputView = nil;
        [self becomeFirstResponder];
    } else {
        self.text = [dic valueForKey:@"field"];
    }
}

- (UIDatePicker *)datePicker {
    if (_datePicker == nil) {
        _datePicker = [[UIDatePicker alloc] init];
        _datePicker.backgroundColor = kLLDHexColor(0xf6f6f6);
        _datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh"];
        _datePicker.datePickerMode = UIDatePickerModeDate;
        [_datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _datePicker;
}

- (UISwitch *)fieldSwitch {
    if (!_fieldSwitch) {
        _fieldSwitch = [[UISwitch alloc] init];
        [_fieldSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _fieldSwitch;
}

- (void)switchChanged:(UISwitch *)sender {
    NSString *textTrue = [self.model.booleanText componentsSeparatedByString:@":"].firstObject;
    NSString *textFalse = [self.model.booleanText componentsSeparatedByString:@":"].lastObject;
    self.text = sender.isOn ? textTrue : textFalse;
}

- (void)dateChanged:(UIDatePicker *)sender {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if (sender.datePickerMode == UIDatePickerModeDate) {
        [dateFormatter setDateFormat:@"yyyyMMdd"];
    }
    if (sender.datePickerMode == UIDatePickerModeDateAndTime) {
        [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    }
    NSString *string = [dateFormatter stringFromDate:sender.date];
    self.text = string;
}

- (UIBarStyle)barStyleMatchingKeyboard {
    if (UIUserInterfaceIdiomPhone == UI_USER_INTERFACE_IDIOM()) {
        if (UIKeyboardAppearanceAlert == [self keyboardAppearance]) {
            return UIBarStyleBlackTranslucent;
        }
    }
    return UIBarStyleDefault;
}

@end
