//
//  LLDUtil.h
//  LLDemoKit
//
//  Created by EvenLin on 2018/2/1.
//  Copyright © 2018年 LianLian Pay Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LLDUtil : NSObject

+ (instancetype)sharedUtil;

@property (nonatomic, strong) UIColor *demoColor;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *navTextColor;
+ (NSString *)ipAddress;
+ (NSString *)uuidString;
+ (NSString *)timeStamp;
+ (NSString *)generateOrderNO;
+ (UIBarButtonItem *)llBBIWithTitle:(NSString *)title andTarget:(id)target action:(SEL)action;

@end

@interface NSString (lldAddition)

- (NSString *)formatTime;

- (id)lldObject;

- (NSString *)lldUrlEncodedString;

- (NSString *)lldUrlDecodedString;

@end

@interface NSDictionary (lldAddition)

- (NSString *)prettyString;

- (NSString *)lldJsonString;

- (NSString *)lldSortedJsonString;

@end

@interface UIImage (lldAddition)

- (UIImage *)lld_imageInRect:(CGRect)rect scale:(CGFloat)scale bgColor:(UIColor *)bgColor rounded:(BOOL)rounded;

@end
