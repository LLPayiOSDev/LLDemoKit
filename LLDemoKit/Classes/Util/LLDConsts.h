//
//  LLDConsts.h
//  LLDemoKit
//
//  Created by EvenLin on 2017/7/21.
//  Copyright © 2017年 LianLian Pay Inc. All rights reserved.
//

#ifndef LLDConsts_h
#define LLDConsts_h


#endif /* LLDConsts_h */


@import UIKit;
#import "LLDUtil.h"
#import "LLDTableView.h"

#define kLLDScreenWidth [UIScreen mainScreen].bounds.size.width
#define kLLDScreenHeight [UIScreen mainScreen].bounds.size.height

#define kLLDHexColor(rgbValue)                                                                                                   \
    [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0                                                         \
                    green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0                                                            \
                     blue:((float)(rgbValue & 0xFF)) / 255.0                                                                     \
                    alpha:1.0]

#define kLLDemoColor [LLDUtil sharedUtil].demoColor
#define kLLDemoBGColor [LLDUtil sharedUtil].backgroundColor
#define kLLDNavTextColor [LLDUtil sharedUtil].navTextColor
#define kLLDBundlePath [[NSBundle bundleForClass:[LLDTableView class]] pathForResource:@"LLDemoResources" ofType:@"bundle"]
#define kLLDImage(name)                                                                                                          \
    [UIImage imageWithContentsOfFile:[[NSBundle bundleWithPath:kLLDBundlePath] pathForResource:name ofType:@"png"]]


#ifdef DEBUG

#define DemoLog(fmt, ...) ((NSLog((@"%@" fmt), @"", ##__VA_ARGS__)));
#else
#define DemoLog(fmt, ...)
#endif
