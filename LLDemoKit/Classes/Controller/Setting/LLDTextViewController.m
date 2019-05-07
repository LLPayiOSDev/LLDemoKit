//
//  LLDTextViewController.m
//  LLDemoKit
//
//  Created by EvenLin on 2018/3/26.
//  Copyright © 2018年 LianLian Pay Inc. All rights reserved.
//

#import "LLDTextViewController.h"

@interface LLDTextViewController () <UITextViewDelegate>

@property (nonatomic, strong) UITextView *textView;

@end

@implementation LLDTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.title.length > 0 ? self.title : @"关于";
    [self.view addSubview:self.textView];
}

- (void)viewDidAppear:(BOOL)animated {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showText];
    });
}

- (void)showText {
    _textView.dataDetectorTypes = UIDataDetectorTypeLink | UIDataDetectorTypePhoneNumber;

    NSMutableParagraphStyle *pStyle = [[NSMutableParagraphStyle alloc] init];
    pStyle.alignment = NSTextAlignmentLeft;
    pStyle.paragraphSpacing = 10;
    pStyle.lineSpacing = 2;
    pStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attArr = @{
        NSFontAttributeName : [UIFont systemFontOfSize:14],
        NSForegroundColorAttributeName : [UIColor darkGrayColor],
        NSParagraphStyleAttributeName : pStyle
    };
    NSAttributedString *attrStringAbout = [[NSAttributedString alloc] initWithString:[self textToShow] attributes:attArr];
    _textView.attributedText = attrStringAbout;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    return YES;
}

- (UITextView *)textView {
    if (!_textView) {
        BOOL translucent = self.navigationController.navigationBar.isTranslucent;
        CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - (translucent ? 0 : 64));
        _textView = [[UITextView alloc] initWithFrame:rect];
        _textView.editable = NO;
        _textView.scrollEnabled = YES;
        _textView.delegate = self;
    }
    return _textView;
}

- (NSString *)stringForFile:(NSString *)file {
    if (!file) return nil;
    NSString *path = [[NSBundle mainBundle] pathForResource:file ofType:@"md"];
    NSString *readMe = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    return readMe;
}

- (NSString *)textToShow {
    if (self.text.length > 0) {
        return self.text;
    }
    if (self.fileName.length > 0) {
        return [self stringForFile:self.fileName] ?: @"NO INFORMATION";
    }
    return @"NO INFORMATION";
}

@end
