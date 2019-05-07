//
//  LLDBaseVC+RightAction.m
//  LLDemoKit
//
//  Created by EvenLin on 2018/2/5.
//  Copyright © 2018年 LianLian Pay Inc. All rights reserved.
//

#import "LLDBaseVC+RightAction.h"
#import "LLIDCardGenerator.h"
#import "LLDicJsonStringVC.h"

@implementation LLDBaseVC (RightAction)

- (void)requestTokenWithDic:(NSDictionary *)paramDic path:(NSString *)path complete:(void (^)(NSDictionary *))complete {
    DemoLog(@"\n👉👉👉👉👉👉👉👉👉👉 \n");
    DemoLog(@"\n 请求地址:\n %@\n\n 请求报文: \n%@", path, paramDic.prettyString);
    __block NSDictionary *jsonObject = nil;

    NSURL *url = [NSURL URLWithString:path];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";

    NSString *param = paramDic.lldJsonString;

    request.HTTPBody = [param dataUsingEncoding:NSUTF8StringEncoding];
    request.timeoutInterval = 40;

    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    [self requestConfiguration:request];

    NSURLSession *session = [NSURLSession sharedSession];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.showHud) {
            [SVProgressHUD show];
        } else {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        }
    });

    NSURLSessionDataTask *task = [session
        dataTaskWithRequest:request
          completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
              dispatch_async(dispatch_get_main_queue(), ^{
                  if (self.showHud) {
                      [SVProgressHUD dismiss];
                  } else {
                      [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                  }
              });
              if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                  NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
                  if (httpResp.statusCode != 200) {
                      DemoLog(@"%@", response.description);
                      dispatch_async(dispatch_get_main_queue(), ^{
                          NSString *errorString = [NSString
                              stringWithFormat:@"%ld %@,%@", (long)httpResp.statusCode,
                                               [NSHTTPURLResponse localizedStringForStatusCode:httpResp.statusCode], httpResp.URL.absoluteString];
                          complete(@{ @"ret_code" : @"LE9001", @"ret_msg" : errorString });
                      });
                      return;
                  }
              }
              if (error || !data) {
                  DemoLog(@"请求出错：%@", error.description);
                  dispatch_async(dispatch_get_main_queue(), ^{
                      complete(@{ @"ret_code" : @"LE9001", @"ret_msg" : error.localizedDescription });
                  });
                  return;
              }
              jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
              DemoLog(@"\n👈👈👈👈👈👈👈👈👈👈");
              DemoLog(@"返回报文:\n %@", jsonObject.prettyString);
              DemoLog(@"\nret_msg = %@", jsonObject[@"ret_msg"]);
              dispatch_async(dispatch_get_main_queue(), ^{
                  complete(jsonObject);
              });
          }];
    [task resume];
}

- (void)requestConfiguration:(NSMutableURLRequest *)request {
}

- (void)refreshOrder {
    [self refreshTimeRelatedTexts];
}

- (void)refreshTimeStamp {
    [self refreshTimeRelatedTexts];
}

- (void)refreshTimeRelatedTexts {
    NSArray *arr = @[ @"timestamp", @"time_stamp", @"dt_order", @"no_order", @"request_time" ];
    if (self.timeRelatedFields) {
        arr = [arr arrayByAddingObjectsFromArray:self.timeRelatedFields];
    }
    NSString *time = [LLDUtil timeStamp];
    for (NSString *key in arr) {
        LLDTextField *field = [self.tableView field:key];
        if (!field) {
            continue;
        }
        field.text = time;
        if ([key isEqualToString:@"no_order"]) {
            field.text = [LLDUtil generateOrderNO];
        }
    }
}

- (void)requestToken {
}

- (void)generateIDCard {
    NSString *idcard = [LLIDCardGenerator generateIDCard];
    [self.tableView field:@"id_no"].text = idcard;
    if ([self.tableView field:@"user_info_id_no"]) {
        [self.tableView field:@"user_info_id_no"].text = idcard;
    }
}

- (void)configRiskItem {
    LLDicJsonStringVC *vc = [[LLDicJsonStringVC alloc] init];
    vc.interface = [
        [LLDInterface alloc] initWithName:@"com.lianlianpay.riskitem"
                                headTitle:@"风控参数配置"
                               headDetail:nil
                            necessaryKeys:@[]
                             optionalKeys:@[
                                 @"user_info_mercht_userno", @"user_info_dt_register", @"user_info_full_name", @"user_info_id_no", @"user_info_identify_type", @"user_info_identify_state", @"frms_ip_addr"
                             ]
                                sdkParams:nil];
    __weak typeof(self) weakSelf = self;
    vc.exitParam = ^(NSDictionary *exitParam) {
        LLDTextField *field = [weakSelf.tableView field:@"risk_item"];
        field.text = exitParam.lldJsonString;
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)configShareingData {
    LLDicJsonStringVC *sharingDataVC = [[LLDicJsonStringVC alloc] init];
    NSArray *sharingDataArr = @[ @"oid_partner", @"busi_partner", @"money_order", @"sharingDataInfo" ];
    sharingDataVC.interface = [[LLDInterface alloc] initWithName:@"LLSharingData"
                                                       headTitle:@"分账说明"
                                                      headDetail:@"shareing_data"
                                                   necessaryKeys:sharingDataArr
                                                    optionalKeys:nil
                                                       sdkParams:nil];
    __weak typeof(self) weakSelf = self;
    sharingDataVC.exitParam = ^(NSDictionary *exitParam) {
        LLDTextField *field = [weakSelf.tableView field:@"shareing_data"];
        NSString *inputedSD = @"";
        if (exitParam && exitParam.allKeys.count == sharingDataArr.count) {
            NSMutableArray *mArr = @[].mutableCopy;
            for (NSString *key in sharingDataArr) {
                [mArr addObject:[exitParam valueForKey:key]];
            }
            inputedSD = [mArr.copy componentsJoinedByString:@"^"];
            if (field.text.length > 0) {
                field.text = [@[ field.text, inputedSD ] componentsJoinedByString:@"|"];
            } else {
                field.text = inputedSD;
            }
        }

    };
    [self.navigationController pushViewController:sharingDataVC animated:YES];
}

- (void)deviceID {
    [self.tableView field:@"device_id"].text = [LLDUtil uuidString];
}

- (void)deviceIPAddress {
    NSString *ip = [LLDUtil ipAddress];
    [self.tableView field:@"source_ip"].text = ip;
    [self.tableView field:@"frms_ip_addr"].text = ip;
}

- (void)locateUser {
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"定位服务没有开启！请设置打开！");
        return;
    }

    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.locationMgr requestWhenInUseAuthorization];
        });
    }
    self.locationMgr.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationMgr.distanceFilter = 10.0;
    [self.locationMgr startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *location = [locations firstObject];
    CLLocationCoordinate2D coordinate = location.coordinate;//经纬度
    [self.tableView field:@"device_location"].text = [NSString stringWithFormat:@"%.3f+%.3f", coordinate.longitude, coordinate.latitude];
    [manager stopUpdatingLocation];
}

@end
