//
//  LLResultInfoVC.m
//  LLDemoKit
//
//  Created by EvenLin on 2016/12/19.
//  Copyright © 2016年 LianLian Pay Inc. All rights reserved.
//

#import "LLResultInfoVC.h"
#import "LLDConsts.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface LLResultInfoVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSDictionary *resultDic;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation LLResultInfoVC

- (instancetype)initWithInfoDic:(NSDictionary *)dic {
    self = [super init];
    if (self) {
        self.resultDic = dic;
        self.showHeadView = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kLLDHexColor(0xf0f0f0);
    [self tableView];
}

- (UIView *)showView {
    CGFloat kWidth = [UIScreen mainScreen].bounds.size.width;
    //背景
    UIView *showingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 70)];
    UIImage *image = self.isSuccess ? kLLDImage(@"icon_success@2x") : kLLDImage(@"icon_fail@2x");
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    CGFloat ivWidth = 75;
    imageView.frame = CGRectMake((kLLDScreenWidth - ivWidth) / 2, 30, ivWidth, ivWidth);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [showingView addSubview:imageView];

    CGRect textRect = [self.text boundingRectWithSize:CGSizeMake(kLLDScreenWidth - 40, CGFLOAT_MAX)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{
                                               NSFontAttributeName : [UIFont boldSystemFontOfSize:20]
                                           }
                                              context:nil];
    CGRect detailRect = [self.detail boundingRectWithSize:CGSizeMake(kLLDScreenWidth - 40, CGFLOAT_MAX)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{
                                                   NSFontAttributeName : [UIFont systemFontOfSize:14]
                                               }
                                                  context:nil];

    UILabel *infoLabel =
        [[UILabel alloc] initWithFrame:CGRectMake(20, imageView.frame.size.height + imageView.frame.origin.y + 15, kLLDScreenWidth - 40, textRect.size.height)];
    infoLabel.textAlignment = NSTextAlignmentCenter;
    infoLabel.numberOfLines = 0;
    infoLabel.textColor = kLLDHexColor(0x333333);
    infoLabel.text = self.text;
    infoLabel.font = [UIFont boldSystemFontOfSize:20];
    [showingView addSubview:infoLabel];

    UILabel *detailLabel =
        [[UILabel alloc] initWithFrame:CGRectMake(20, infoLabel.frame.size.height + infoLabel.frame.origin.y + 10, kLLDScreenWidth - 40, detailRect.size.height)];
    detailLabel.textColor = kLLDHexColor(0x999999);
    detailLabel.textAlignment = NSTextAlignmentCenter;
    detailLabel.numberOfLines = 0;
    detailLabel.font = [UIFont systemFontOfSize:14];
    detailLabel.text = self.detail;
    [showingView addSubview:detailLabel];

    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15, detailLabel.frame.size.height + detailLabel.frame.origin.y + 2, kLLDScreenWidth - 30, 0.8)];
    line.backgroundColor = [UIColor lightGrayColor];
    if (self.resultDic.allKeys.count > 0) {
        [showingView addSubview:line];
    }
    CGRect frame = showingView.frame;
    frame.size.height = detailLabel.frame.size.height + detailLabel.frame.origin.y + 15;
    showingView.frame = frame;

    return showingView;
}

- (UIView *)tableFooterView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.backgroundColor = [kLLDemoColor isEqual:[UIColor whiteColor]] ? kLLDNavTextColor : kLLDemoColor;
    [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backToPay) forControlEvents:UIControlEventTouchUpInside];
    backBtn.frame = CGRectMake(15, 10, self.view.frame.size.width - 30, 40);
    backBtn.layer.cornerRadius = 5.0;
    backBtn.layer.masksToBounds = YES;
    [view addSubview:backBtn];
    return view;
}

- (void)backToPay {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSString *)finalPayMoney {
    NSDecimalNumber *moneyOrder = [NSDecimalNumber decimalNumberWithString:self.resultDic[@"money_order"]];
    NSDecimalNumber *discountAmt = [NSDecimalNumber decimalNumberWithString:self.resultDic[@"discountAmt"]];
    NSDecimalNumber *finalMoney = [moneyOrder decimalNumberBySubtracting:discountAmt];
    return finalMoney.stringValue;
}
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.resultDic.allKeys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [self.resultDic.allKeys[indexPath.row] stringByAppendingString:@":"];
    cell.textLabel.textColor = kLLDHexColor(0x999999);
    cell.textLabel.font = [UIFont systemFontOfSize:14];

    cell.detailTextLabel.textColor = kLLDHexColor(0x333333);
    cell.detailTextLabel.text = [self valueAtIndex:indexPath.row];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    return cell;
}

- (NSString *)valueAtIndex:(NSUInteger)index {
    id value = [self.resultDic.allValues objectAtIndex:index];
    if ([value isKindOfClass:[NSString class]]) {
        return value;
    } else {
        return [value lldJsonString];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 35;
}

- (void)tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *action = [UITableViewRowAction
        rowActionWithStyle:UITableViewRowActionStyleNormal
                     title:@"详情"
                   handler:^(UITableViewRowAction *_Nonnull action, NSIndexPath *_Nonnull indexPath) {
                       [tableView setEditing:NO animated:YES];
                       UIAlertController *alert = [UIAlertController alertControllerWithTitle:self.resultDic.allKeys[indexPath.row]
                                                                                      message:[self valueAtIndex:indexPath.row]
                                                                               preferredStyle:UIAlertControllerStyleActionSheet];
                       [alert addAction:[UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:nil]];
                       [self presentViewController:alert animated:YES completion:nil];
                   }];
    action.backgroundColor = [kLLDemoColor isEqual:[UIColor whiteColor]] ? kLLDNavTextColor : kLLDemoColor;
    UITableViewRowAction *pasteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                                                           title:@"复制"
                                                                         handler:^(UITableViewRowAction *_Nonnull action, NSIndexPath *_Nonnull indexPath) {
                                                                             UIPasteboard *paste = [UIPasteboard generalPasteboard];
                                                                             paste.string = [self valueAtIndex:indexPath.row];
                                                                             [SVProgressHUD showInfoWithStatus:@"已"
                                                                                                               @"复制到剪贴板"];
                                                                             [tableView setEditing:NO animated:YES];
                                                                         }];
    pasteAction.backgroundColor = [UIColor grayColor];
    return @[ action, pasteAction ];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]
            initWithFrame:CGRectMake(0, 0, kLLDScreenWidth, kLLDScreenHeight - (self.navigationController.navigationBar.translucent ? 0 : 64))
                    style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableHeaderView = self.showHeadView ? [self showView] : nil;
        _tableView.tableFooterView = [self tableFooterView];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

@end
