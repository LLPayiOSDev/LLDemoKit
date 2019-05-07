//
//  LLIDCardGenerator.m
//  LLDemoKit
//
//  Created by EvenLin on 2018/1/27.
//  Copyright © 2018年 LianLian Pay Inc. All rights reserved.
//

#import "LLIDCardGenerator.h"

@implementation LLIDCardGenerator

+ (NSString *)generateIDCard {
    NSMutableString *idcard = [NSMutableString string];
    [idcard appendString:[self randomAreaCode]];
    [idcard appendString:[self randomBirthday]];
    [idcard appendString:[self randomCode]];
    [idcard appendString:[self calculateLastNumber:[idcard copy]]];
    return [idcard copy];
}

/**
 * 随机地区
 */
+ (NSString *)randomAreaCode {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *url = [bundle URLForResource:@"LLDemoResources" withExtension:@"bundle"];
    NSBundle *plistBundle = [NSBundle bundleWithURL:url];
    NSString *path = [plistBundle pathForResource:@"AreaCode" ofType:@"plist"];
    NSArray *areas = [NSArray arrayWithContentsOfFile:path];
    NSDictionary *dic = [areas objectAtIndex:(arc4random() % areas.count)];
    return dic.allValues.firstObject;
}

/**
 * 随机出生日期
 */
+ (NSString *)randomBirthday {
    NSDate *date = nil;
    while (1) {
        date = [NSDate dateWithTimeIntervalSince1970:arc4random()];
        NSDate *today = [NSDate date];
        NSTimeInterval time = [date timeIntervalSinceDate:today];
        if (time > 0) {
            continue;
        } else {
            break;
        }
    }
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyyMMdd";
    return [fmt stringFromDate:date];
}

+ (NSString *)calculateLastNumber:(NSString *)IDNumber {
    NSMutableArray *IDArray = [NSMutableArray array];
    for (int i = 0; i < 17; i++) {
        NSRange range = NSMakeRange(i, 1);
        NSString *subString = [IDNumber substringWithRange:range];
        [IDArray addObject:subString];
    }
    NSArray *coefficientArray = [NSArray arrayWithObjects:@"7", @"9", @"10", @"5", @"8", @"4", @"2", @"1", @"6", @"3", @"7", @"9", @"10", @"5", @"8", @"4", @"2", nil];
    NSArray *resultArray = [NSArray arrayWithObjects:@"1", @"0", @"X", @"9", @"8", @"7", @"6", @"5", @"4", @"3", @"2", nil];
    int sum = 0;
    for (int i = 0; i < 17; i++) {
        int coefficient = [coefficientArray[i] intValue];
        int ID = [IDArray[i] intValue];
        sum += coefficient * ID;
    }
    NSInteger result = sum % 11;
    return resultArray[result];
}

+ (NSString *)randomCode {
    NSMutableString *string = [NSMutableString string];
    int a = arc4random() % 10;
    int b = arc4random() % 10;
    int c = arc4random() % 10;
    [string appendFormat:@"%d%d%d", a, b, c];
    return [string copy];
}

@end
