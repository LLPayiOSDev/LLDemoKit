//
//  LLPayOrderQuery.m
//  LLMPay
//
//  Created by EvenLin on 2019/4/23.
//  Copyright © 2019 LianLian Pay Inc. All rights reserved.
//

#import "LLPayOrderQuery.h"
#import <UIKit/UIKit.h>

@implementation LLPOrder

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
}

@end

@interface LLPayOrderQuery ()

@property (nonatomic, copy) OQCallBack complete;
@property (nonatomic, assign) NSUInteger queryCount;

@end


@implementation LLPayOrderQuery

- (instancetype)init {
    self = [super init];
    if (self) {
        self.maxQueryCount = 1;
        self.queryCount = 0;
        self.isTestEnv = NO;
    }
    return self;
}

- (void)queryOrder:(LLPOrder *)order complete:(OQCallBack)complete {
    self.complete = complete;
    if (![self checkOrder:order]) {
        complete(NO, @"订单查询参数有误", @{ @"ret_msg" : @"订单查询参数有误" });
        return;
    }
    [self queryOrderWithDic:[self queryParamForOrder:order]];
}

- (BOOL)checkOrder:(LLPOrder *)order {
    if (order.oid_partner == nil || order.no_order == nil || order.dt_order == nil || order.sign == nil || order.sign_type == nil) {
        return NO;
    }
    return YES;
}

- (NSDictionary *)queryParamForOrder:(LLPOrder *)order {
    NSMutableDictionary *mdic = [NSMutableDictionary dictionary];
    mdic[@"oid_partner"] = order.oid_partner;
    mdic[@"no_order"] = order.no_order;
    mdic[@"dt_order"] = order.dt_order;
    mdic[@"sign_type"] = order.sign_type;
    mdic[@"sign"] = order.sign;
    mdic[@"query_version"] = order.query_version;
    mdic[@"oid_paybill"] = order.oid_paybill;
    return [mdic copy];
}

- (NSString *)queryPath {
    if (self.orderQueryPath.length > 0) {
        return self.orderQueryPath;
    }
    return self.isTestEnv ? @"https://test.lianlianpay-inc.com/traderapi/orderquery.htm"
                          : @"https://queryapi.lianlianpay.com/orderquery.htm";
}

- (void)queryOrderWithDic:(NSDictionary *)paramDic {
    self.queryCount++;
    __block NSDictionary *jsonObject = nil;

    NSURL *url = [NSURL URLWithString:[self queryPath]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";

    NSString *param = [self orderJsonString:paramDic];

    request.HTTPBody = [param dataUsingEncoding:NSUTF8StringEncoding];
    request.timeoutInterval = 10;

    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    NSURLSession *session = [NSURLSession sharedSession];
    [self showHud:YES];
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task =
        [session dataTaskWithRequest:request
                   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                       [self showHud:NO];
                       if (error || !data) {
                           dispatch_async(dispatch_get_main_queue(), ^{
                               self.complete(NO, error.localizedDescription, @{ @"ret_msg" : error.localizedDescription });
                           });
                           return;
                       }
                       jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                       //订单查询成功
                       if ([jsonObject[@"ret_code"] isEqualToString:@"0000"]) {
                           NSString *resultPay = [jsonObject valueForKey:@"result_pay"];
                           BOOL paySucceeded = [resultPay isEqualToString:@"SUCCESS"];
                           NSString *resultInfo = [self textForResultPay:jsonObject[@"result_pay"]];
                           NSDictionary *resultDic = [self friendlyResultDic:jsonObject];
                           
                           if (([resultPay isEqualToString:@"WAITING"] || [resultPay isEqualToString:@"PROCESSING"]) && self.queryCount < self.maxQueryCount) {
                               [weakSelf queryOrderWithDic:paramDic];
                           } else {
                               [weakSelf querySuccess:paySucceeded info:resultInfo dic:resultDic];
                           }
                       } else {
                           [weakSelf querySuccess:NO info:@"订单查询失败" dic:jsonObject];
                       }
                   }];
    [task resume];
}

- (void)querySuccess:(BOOL)success info:(NSString *)info dic:(NSDictionary *)dic{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.complete(success, info, dic);
    });
}



- (NSString *)orderJsonString:(NSDictionary *)dic {

    if (self == nil) {
        return nil;
    }
    NSError *err = nil;

    NSData *stringData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:&err];

    NSString *str = [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
    return str;
}

- (NSDictionary *)friendlyResultDic:(NSDictionary *)resultDic {
    NSMutableDictionary *mdic = [NSMutableDictionary dictionary];
    //    mdic[@"签名方式"] = resultDic[@"sign_type"];
    //    mdic[@"签        名"] = resultDic[@"sign"];
    mdic[@"支付结果"] = [self textForResultPay:resultDic[@"result_pay"]];
    mdic[@"商户编号"] = resultDic[@"oid_partner"];
    mdic[@"订单时间"] = [self formatTime:resultDic[@"dt_order"]];
    mdic[@"商户单号"] = resultDic[@"no_order"];
    mdic[@"连连单号"] = resultDic[@"oid_paybill"];
    mdic[@"交易金额"] = resultDic[@"money_order"];
    mdic[@"清算日期"] = resultDic[@"settle_date"];
    mdic[@"订单描述"] = resultDic[@"info_order"];
    mdic[@"支付方式"] = resultDic[@"pay_type"];
    mdic[@"银行编号"] = resultDic[@"info_order"];
    mdic[@"银行名称"] = resultDic[@"bank_name"];
    mdic[@"支付备注"] = resultDic[@"memo"];
    return [mdic copy];
}

- (NSString *)textForResultPay:(NSString *)resultPay {
    if ([resultPay isEqualToString:@"SUCCESS"]) {
        return @"交易成功";
    }
    if ([resultPay isEqualToString:@"WAITING"]) {
        return @"等待付款";
    }
    if ([resultPay isEqualToString:@"PROCESSING"]) {
        return @"处理中";
    }
    if ([resultPay isEqualToString:@"REFUND"]) {
        return @"已退款";
    }
    if ([resultPay isEqualToString:@"FAILURE"]) {
        return @"交易失败";
    }
    return @"";
}


- (NSString *)formatTime:(NSString *)time {
    if (time.length < 12) {
        return nil;
    }
    NSString *ret = nil;
    @try {
        NSString *year = [time substringWithRange:NSMakeRange(0, 4)];
        NSString *mon = [time substringWithRange:NSMakeRange(4, 2)];
        NSString *day = [time substringWithRange:NSMakeRange(6, 2)];
        NSString *HH = [time substringWithRange:NSMakeRange(8, 2)];
        NSString *MM = [time substringWithRange:NSMakeRange(10, 2)];
        NSString *SS = [time substringWithRange:NSMakeRange(12, 2)];

        ret = [NSString stringWithFormat:@"%@-%@-%@ %@:%@:%@", year, mon, day, HH, MM, SS];
    } @catch (NSException *exception) {
        ret = @"";
    } @finally {
    }

    return ret;
}

- (void)showHud:(BOOL)isShow {
    Class Hud = NSClassFromString(@"SVProgressHUD");
    SEL selector = NSSelectorFromString(isShow ? @"showWithStatus:" : @"dismiss");
    if (Hud && [Hud respondsToSelector:selector]) {
        [Hud performSelectorOnMainThread:selector withObject:isShow ? @"订单查询中..." : nil waitUntilDone:NO];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:isShow];
        });
    }
}

@end
