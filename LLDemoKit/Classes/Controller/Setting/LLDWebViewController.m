//
//  LLDWebViewController.m
//  LLDemoKit
//
//  Created by EvenLin on 2019/5/7.
//

#import "LLDWebViewController.h"

@interface LLDWebViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@end

@implementation LLDWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    self.webView.delegate = self;
    self.webView.opaque = NO;
    self.webView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.webView];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.webUrl]]];
    self.indicator = [[UIActivityIndicatorView alloc] init];
    self.indicator.frame = CGRectMake(0, 0, 20, 20);
    self.indicator.center = self.view.center;
    self.indicator.hidesWhenStopped = YES;
    self.indicator.color = [UIColor lightGrayColor];
    [self.view addSubview:self.indicator];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    [self.indicator startAnimating];
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.indicator stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.indicator stopAnimating];
}


@end
