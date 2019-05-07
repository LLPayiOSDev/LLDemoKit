//
//  LLPayOrderQuery.h
//  LLMPay
//
//  Created by EvenLin on 2019/4/23.
//  Copyright © 2019 LianLian Pay Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LLPOrder : NSObject

@property (nonatomic, strong) NSString *oid_partner;
@property (nonatomic, strong) NSString *no_order;
@property (nonatomic, strong) NSString *dt_order;
@property (nonatomic, strong) NSString *sign_type;
@property (nonatomic, strong) NSString *sign;
@property (nonatomic, strong, nullable) NSString *oid_paybill;
@property (nonatomic, strong, nullable) NSString *query_version;

@end

typedef void(^OQCallBack)(BOOL success, NSString *info, NSDictionary *result);

@interface LLPayOrderQuery : NSObject

@property (nonatomic, strong) NSString *orderQueryPath;
@property (nonatomic, assign) BOOL isTestEnv;
@property (nonatomic, assign) NSUInteger maxQueryCount;
- (void)queryOrder: (LLPOrder *)order complete: (OQCallBack)complete;

@end

NS_ASSUME_NONNULL_END
