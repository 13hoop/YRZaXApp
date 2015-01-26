//
//  discoveryWebView.m
//  ebooksystem
//
//  Created by wanghaoyu on 15/1/25.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import "discoveryWebView.h"

@interface discoveryWebView()<UIWebViewDelegate>

@property (nonatomic,strong) UIWebView *webView;

@end


@implementation discoveryWebView

//- (UIWebView *)webView {
//    if (_webView == nil) {
//        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
//        _webView.delegate = self;
//        
//        [self addSubview:_webView];
//    }
//    
//    return _webView;
//}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self updateWebView];
    }
    return self;
}

//makeUI

- (void)updateWebView {
    NSString *webUrlStr = @"http://test.zaxue100.com/index.php?c=discovery_ctrl&m=index";
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",webUrlStr]]]];
    self.webView.scrollView.bounces = NO;
    self.webView.scrollView.showsVerticalScrollIndicator = NO;
    self.webView.delegate =self;
    [self addSubview:self.webView];
}



#pragma mark webview delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"url ====== %@",request.URL);
    return YES;
}
@end
