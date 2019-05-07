//
//  LLDUtil.m
//  LLDemoKit
//
//  Created by EvenLin on 2018/2/1.
//  Copyright © 2018年 LianLian Pay Inc. All rights reserved.
//

#import "LLDUtil.h"
#import "LLDConsts.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>

static LLDUtil *util;

@implementation LLDUtil

+ (instancetype)sharedUtil {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        util = [[LLDUtil alloc] init];
    });
    return util;
}

+ (NSString *)timeStamp {
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"yyyyMMddHHmmss"];
    NSString *simOrder = [dateFormater stringFromDate:[NSDate date]];
    return simOrder;
}

+ (NSString *)generateOrderNO {
    static int kNumber = 4;
    NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand((unsigned)time(0));
    for (int i = 0; i < kNumber; i++) {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return [NSString stringWithFormat:@"LL%@%@", [self timeStamp], resultStr];
}

+ (NSString *)uuidString {
    NSString *uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    uuid = [uuid stringByReplacingOccurrencesOfString:@"-" withString:@""];
    return uuid;
}


+ (NSString *)ipAddress {
    NSString *address = @"192.168.1.3";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;

    success = getifaddrs(&interfaces);

    if (success == 0) {
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if (temp_addr->ifa_addr->sa_family == AF_INET) {
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    freeifaddrs(interfaces);
    return address;
}

+ (UIBarButtonItem *)llBBIWithTitle:(NSString *)title andTarget:(id)target action:(SEL)action {
    UIButton *setBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    setBtn.frame = CGRectMake(0, 0, 40, 30);
    [setBtn setTitle:title forState:UIControlStateNormal];
    [setBtn setTitleColor:kLLDNavTextColor forState:UIControlStateNormal];
    setBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [setBtn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithCustomView:setBtn];
    return bbi;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.demoColor = kLLDHexColor(0x00a0e9);
        self.backgroundColor = [UIColor whiteColor];
        self.navTextColor = [UIColor whiteColor];
    }
    return self;
}

@end

@implementation NSString (lldAddition)

- (id)lldObject {
    NSError *error = nil;

    NSData *stringData = [self dataUsingEncoding:NSUTF8StringEncoding];
    id jsonObj = [NSJSONSerialization JSONObjectWithData:stringData options:NSJSONReadingAllowFragments error:&error];
    if (error != nil) {
        return nil;
    }
    return jsonObj;
}

- (NSString *)lldUrlEncodedString {
#if __has_feature(objc_arc)
    NSString *result = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)self, NULL, CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8);
#else
    NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, NULL,
                                                                           CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8);
#endif
    return result;
}

- (NSString *)lldUrlDecodedString {
    NSString *result = [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return result;
}

- (NSString *)formatTime {
    if (self.length < 12) {
        return nil;
    }
    NSString *ret = nil;
    @try {
        NSString *year = [self substringWithRange:NSMakeRange(0, 4)];
        NSString *mon = [self substringWithRange:NSMakeRange(4, 2)];
        NSString *day = [self substringWithRange:NSMakeRange(6, 2)];
        NSString *HH = [self substringWithRange:NSMakeRange(8, 2)];
        NSString *MM = [self substringWithRange:NSMakeRange(10, 2)];
        NSString *SS = [self substringWithRange:NSMakeRange(12, 2)];

        ret = [NSString stringWithFormat:@"%@-%@-%@ %@:%@:%@", year, mon, day, HH, MM, SS];
    } @catch (NSException *exception) {
        ret = @"";
    } @finally {
    }

    return ret;
}
@end

@implementation NSDictionary (lldAddition)

- (NSString *)prettyString {
    if (!self) {
        return nil;
    }
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    NSString *prettyString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //去除 log 中的转义符
    prettyString = [prettyString stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    return prettyString;
}

- (NSString *)lldJsonString {

    if (self == nil) {
        return nil;
    }
    NSError *err = nil;

    NSData *stringData = [NSJSONSerialization dataWithJSONObject:self options:0 error:&err];

    NSString *str = [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
    return str;
}

- (NSString *)lldSortedJsonString {
    NSString *jsonString = [self lldJsonString];
    if (self.allKeys.count < 2) {
        return jsonString;
    }
    return [self sortString:jsonString];
}

- (NSString *)sortString:(NSString *)unSortedString {
    if (![NSJSONSerialization isValidJSONObject:self]) {
        return nil;
    }
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_10_3
    if (@available(iOS 11.0, *)) {
        NSError *err = nil;
        NSData *strData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingSortedKeys error:&err];
        NSString *sortedString = [[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding];
        return sortedString;
    }
#endif
    NSMutableArray *sortedKeys = [NSMutableArray arrayWithArray:[self allKeys]];
    [sortedKeys sortUsingSelector:@selector(caseInsensitiveCompare:)];
    NSMutableString *jsonString = [[NSMutableString alloc] init];
    [jsonString appendString:@"{"];
    for (NSString *key in sortedKeys) {
        [jsonString appendFormat:@"\"%@\"", key];
        [jsonString appendString:@":"];
        [jsonString appendFormat:@"\"%@\"", [self objectForKey:key]];
        [jsonString appendString:@","];
    }
    if ([jsonString length] > 2) {
        [jsonString deleteCharactersInRange:NSMakeRange([jsonString length] - 1, 1)];
    }
    [jsonString appendString:@"}"];

    return jsonString;
}

@end


@implementation UIImage (lldAddition)


- (UIImage *)lld_imageInRect:(CGRect)rect scale:(CGFloat)scale bgColor:(UIColor *)bgColor rounded:(BOOL)rounded {
    if (scale < 1) {
        scale = 1;
    }

    CGFloat width = rect.size.width / scale;
    CGFloat height = rect.size.height / scale;
    if (self.size.width > self.size.height) {
        height = width * self.size.height / self.size.width;
    } else {
        width = height * self.size.width / self.size.height;
    }
    CGFloat x = (rect.size.width - width) / 2;
    CGFloat y = (rect.size.height - height) / 2;

    CGRect scaledRect = CGRectMake(x, y, width, height);

    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:rounded ? rect.size.width / 2 : 0];
    [path addClip];
    if (bgColor) {
        [bgColor setFill];
        [path fill];
    }
    [self drawInRect:scaledRect];
    UIImage *contextImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return contextImage;
}

@end
