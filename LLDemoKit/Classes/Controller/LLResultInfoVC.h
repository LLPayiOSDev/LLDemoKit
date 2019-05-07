//
//  LLResultInfoVC.h
//  LLDemoKit
//
//  Created by EvenLin on 2016/12/19.
//  Copyright © 2016年 LianLian Pay Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LLResultInfoVC : UIViewController

- (instancetype)initWithInfoDic:(NSDictionary *)dic;
@property (nonatomic, getter=isSuccess) BOOL success;
@property (nonatomic, assign) BOOL showHeadView;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *detail;

@end
