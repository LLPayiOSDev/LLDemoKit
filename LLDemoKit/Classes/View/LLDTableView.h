//
//  LLDTableView.h
//  LLDemoKit
//
//  Created by EvenLin on 2017/8/15.
//  Copyright © 2017年 LianLian Pay Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLDTextField.h"
#import "LLUIModel.h"

typedef void (^DTBlock)(void);

@interface LLDTableView : UITableView

- (instancetype)initWithFrame:(CGRect)frame;

- (void)addTarget:(id)target action:(SEL)action;

@property (nonatomic, strong) LLUIModel *uiModel;

@property (nonatomic, strong) NSMutableDictionary *dic;

@property (nonatomic, strong) NSDictionary *fieldsData;

@property (nonatomic, strong) UIButton *nextBtn;

- (NSDictionary *)fieldsDataFromArray:(NSArray *)array;
- (NSDictionary *)fieldsDataForSection:(NSUInteger)section;
- (LLDTextField *)field:(NSString *)key;
- (NSString *)textForKeys:(NSArray *)keys;
- (void)configWithPlist:(NSString *)plist;
- (void)configWithModel;

@end
