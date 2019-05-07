//
//  LLDTableView.m
//  LLDemoKit
//
//  Created by EvenLin on 2017/8/15.
//  Copyright © 2017年 LianLian Pay Inc. All rights reserved.
//

#import "LLDTableView.h"
#import "LLDConsts.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface LLDTableView () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, strong) id target;

@end

@implementation LLDTableView

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame style:UITableViewStyleGrouped];
    if (self) {

        self.delegate = self;
        self.dataSource = self;
        self.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        if (@available(iOS 10.0, *)) {
            self.refreshControl = [[UIRefreshControl alloc] init];
            self.refreshControl.tintColor = [UIColor whiteColor];
            [self.refreshControl addTarget:self action:@selector(refreshTV) forControlEvents:UIControlEventValueChanged];
        }
        self.backgroundColor = [UIColor whiteColor];
        self.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    }
    return self;
}

#pragma mark - delegate

#pragma mark tableView delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    NSString *name = self.uiModel.textFields[section][@"sectionHeader"];
    return name.length > 0 ? 44 : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    NSString *tip = [self footerTipInSection:section];
    return tip ? [self heightForFooterTip:tip] : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kLLDScreenWidth, 44)];
    view.backgroundColor = kLLDHexColor(0xffffff);
    [view addSubview:self.uiModel.headers[section]];
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    NSString *tip = [self footerTipInSection:section];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, (tip ? [self heightForFooterTip:tip] : 0))];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, self.frame.size.width - 15, (tip ? [self heightForFooterTip:tip] : 0))];
    label.backgroundColor = [UIColor clearColor];
    label.text = tip;
    label.numberOfLines = 0;
    label.textColor = [UIColor lightGrayColor];
    label.font = [UIFont systemFontOfSize:12];
    [view addSubview:label];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

#pragma mark tableView datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.uiModel.textFields.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    UIButton *btn = self.uiModel.headers[section];
    NSArray *fields = [[self.uiModel.textFields objectAtIndex:section] objectForKey:@"fields"];
    return btn.selected ? 0 : fields.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    } else {
        while (cell.contentView.subviews.count > 0) {
            [cell.contentView.subviews.firstObject removeFromSuperview];
        }
    }
    LLDTextField *field = [self.uiModel fieldAtIndexPath:indexPath];
    field.delegate = self;
    [cell.contentView addSubview:field];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark tableView edit

- (void)tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    __block LLDTextField *field = [self fieldInIndexPath:indexPath];
    UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal
                                                                      title:@"详情"
                                                                    handler:^(UITableViewRowAction *_Nonnull action, NSIndexPath *_Nonnull indexPath) {
                                                                        [tableView setEditing:NO animated:YES];
                                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                                            [[[UIAlertView alloc] initWithTitle:field.key
                                                                                                        message:field.text
                                                                                                       delegate:self
                                                                                              cancelButtonTitle:@"好"
                                                                                              otherButtonTitles:nil] show];
                                                                        });
                                                                    }];
    action.backgroundColor = [kLLDemoColor isEqual:[UIColor whiteColor]] ? kLLDNavTextColor : kLLDemoColor;
    UITableViewRowAction *pasteAction =
        [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                           title:@"复制"
                                         handler:^(UITableViewRowAction *_Nonnull action, NSIndexPath *_Nonnull indexPath) {
                                             UIPasteboard *paste = [UIPasteboard generalPasteboard];
                                             paste.string = field.text;
                                             [SVProgressHUD showInfoWithStatus:@"已"
                                                                               @"复制到剪贴板"];
                                             [tableView setEditing:NO animated:YES];
                                         }];
    pasteAction.backgroundColor = [UIColor grayColor];
    NSMutableArray *arr = [NSMutableArray array];
    if (field.text.length > 0) {
        [arr addObject:action];
        [arr addObject:pasteAction];
    }
    return [arr copy];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    CGPoint textfieldPoint = [textField convertPoint:CGPointMake(0, 22) toView:self];

    NSIndexPath *textIndex = [self indexPathForRowAtPoint:textfieldPoint];
    CGRect rect = [self rectForRowAtIndexPath:textIndex];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setContentOffset:CGPointMake(0, rect.origin.y + 64 + 44 - 216) animated:YES];
    });
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [((LLDTextField *)textField)cacheText];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - private

- (UIView *)footerView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 100)];
    view.backgroundColor = kLLDemoBGColor;
    [view addSubview:self.nextBtn];
    [self.nextBtn setTitle:self.uiModel.footerTitle forState:UIControlStateNormal];
    return view;
}

- (CGFloat)heightForFooterTip:(NSString *)tip {
    CGRect rect = [tip boundingRectWithSize:CGSizeMake(self.frame.size.width - 15, CGFLOAT_MAX)
                                    options:NSStringDrawingUsesLineFragmentOrigin
                                 attributes:@{
                                     NSFontAttributeName : [UIFont systemFontOfSize:12]
                                 }
                                    context:nil];
    return rect.size.height + 5;
}

- (NSString *)footerTipInSection:(NSUInteger)section {
    NSDictionary *dic = self.uiModel.textFields[section];
    NSString *tip = [dic valueForKey:@"sectionFooter"];
    if (tip.length > 0) {
        return tip;
    }
    return nil;
}

- (void)mfAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:sender.tag];
    [self reloadSections:set withRowAnimation:UITableViewRowAnimationNone];
}

- (void)addTarget:(id)target action:(SEL)action {
    self.target = target;
    [self.nextBtn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

- (void)refreshTV {
    [self.uiModel reloadFields];
    [self reloadData];
    if (@available(iOS 10.0, *)) {
        [self.refreshControl endRefreshing];
    }
}

- (void)configWithPlist:(NSString *)plist {

    self.uiModel = [[LLUIModel alloc] initWithPlist:plist];
    [self configWithModel];
}

- (void)configWithModel {
    self.uiModel.target = self.target;
    [self.uiModel parseFields];
    [self configSectionHeaderBtns];
    self.tableFooterView = self.uiModel.footerTitle.length > 0 ? [self footerView] : [UIView new];
}

- (void)configSectionHeaderBtns {
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i < self.uiModel.textFields.count; i++) {
        NSString *name = [self.uiModel.textFields objectAtIndex:i][@"sectionHeader"];
        UIButton *btn = [self btnWithName:name selector:@selector(mfAction:)];
        btn.tag = i;
        [arr addObject:btn];
    }
    self.uiModel.headers = [arr copy];
}
#pragma mark - Getter/Setter

- (LLDTextField *)field:(NSString *)key {
    return [self.uiModel fieldForKey:key];
}

- (NSString *)textForKeys:(NSArray *)keys {
    for (NSString *key in keys) {
        NSString *text = [self field:key].text;
        if (text.length > 0) {
            return text;
        }
    }
    return nil;
}

- (LLDTextField *)fieldInIndexPath:(NSIndexPath *)indexPath {
    return [self.uiModel fieldAtIndexPath:indexPath];
}

- (NSDictionary *)fieldsDataForSection:(NSUInteger)section {
    NSDictionary *dic = [self.uiModel.textFields objectAtIndex:section];
    NSArray *arr = [dic objectForKey:@"fields"];
    NSMutableDictionary *mutDic = [NSMutableDictionary dictionary];
    for (LLDTextField *field in arr) {
        [mutDic setValue:field.text forKey:field.key];
    }
    return [mutDic copy];
}

- (NSDictionary *)fieldsDataFromArray:(NSArray *)array {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for (NSString *key in array) {
        NSString *value = [self field:key].text;
        if (value.length > 0) {
            [dic setObject:value forKey:key];
        }
    }
    return [dic copy];
}

- (UIButton *)nextBtn {
    if (!_nextBtn) {
        _nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nextBtn setTitle:self.uiModel.footerTitle forState:UIControlStateNormal];
        [_nextBtn setBackgroundColor:kLLDemoColor];
        if ([kLLDemoColor isEqual:[UIColor whiteColor]]) {
            [_nextBtn setBackgroundColor:kLLDNavTextColor];
        }
        [_nextBtn setTitleColor:kLLDHexColor(0xFFFFFF) forState:UIControlStateNormal];
        [_nextBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        _nextBtn.frame = CGRectMake(15, 30, self.frame.size.width - 30, 44);
        _nextBtn.layer.cornerRadius = 5;
        _nextBtn.layer.masksToBounds = YES;
    }
    return _nextBtn;
}

- (UIButton *)btnWithName:(NSString *)name selector:(SEL)selector {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *normalImage = kLLDImage(@"arrowDown@2x");
    UIImage *selectedImage = kLLDImage(@"arrowRight@2x");
    btn.selected = NO;
    [btn setImage:normalImage forState:UIControlStateNormal];
    [btn setImage:selectedImage forState:UIControlStateSelected];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btn.imageEdgeInsets = UIEdgeInsetsMake(0, kLLDScreenWidth - 30, 0, 0);
    btn.frame = CGRectMake(0, 0, kLLDScreenWidth, 44);
    btn.backgroundColor = kLLDHexColor(0xffffff);
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:21];
    btn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [btn setTitle:name forState:UIControlStateNormal];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (NSDictionary *)fieldsData {
    return [self.uiModel getFieldsData];
}

@end
