//
//  MatchViewController.m
//  ebooksystem
//
//  Created by wanghaoyu on 14-11-5.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import "MatchViewController.h"

#import "WebViewJavascriptBridge.h"
#import "LogUtil.h"


@interface MatchViewController ()<UIWebViewDelegate>

// bridge between webview and js
@property (nonatomic, strong) WebViewJavascriptBridge *javascriptBridge;
@property(nonatomic,strong)UIWebView *webview;

@end

@implementation MatchViewController

@synthesize javascriptBridge = _javascriptBridge;


#pragma mark - properties
// bridge between webview and js
-(WebViewJavascriptBridge *)javascriptBridge {
    if (_javascriptBridge == nil) {
        _javascriptBridge = [WebViewJavascriptBridge bridgeForWebView:self.webview
                                                              handler:^(id data, WVJBResponseCallback responseCallback) {
                                                                  LogDebug(@"Received message from javascript: %@", data);
                                                                  responseCallback(@"'response data from obj-c'");
                                                              }];
        //        [self initWebView];
    }
    
    return _javascriptBridge;
}




- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createWeb];
    [self initWebView];
    [self writeJSintowebview];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)createWeb
{
//    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.zaxue100.com"]];
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:self.webUrl]];

    //给出具体样式后再修改
    self.webview=[[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webview.delegate=self;
    [self.webview loadRequest:request];
    [self.view addSubview:self.webview];
}
- (BOOL)initWebView {
//    self.webview.delegate = self.javascriptBridge;
    
    // goback()
    [self.javascriptBridge registerHandler:@"goBack" handler:^(id data, WVJBResponseCallback responseCallback) {
        LogDebug(@"CommonWebViewController::showMenu() called: %@", data);
        //判断是否可以继续回退
        BOOL iscan = self.webview.canGoBack;
        if (iscan) {
            [self.webview goBack];
        }
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }];
    //-(void)share:(NSDictionary *)shareDic
    [self.javascriptBridge registerHandler:@"share" handler:^(id data, WVJBResponseCallback responseCallback) {
        LogDebug(@"CommonWebViewController::share() called: %@", data);
        
        NSDictionary *shareDic=(NSDictionary *)data;
        
        [self share:shareDic];
        
        
    }];
    
    return YES;
}


-(void)share:(NSDictionary *)shareDic
{
    /*
     {
     url : '',
     img_url : '',
     title : '',
     screen_shot : true | false
     
     }
     */
    //分享链接
    NSString *urlString=[shareDic objectForKey:@"url"];
    NSURL *weburl=[NSURL URLWithString:urlString];
    //分享的图片链接
    NSString *imageString=[shareDic objectForKey:@"img_url"];
    NSURL *imageUrl=[NSURL URLWithString:imageString];
    //分享的title
    NSString *title=[shareDic objectForKey:@"title"];
    BOOL shouldScreen_shot=(BOOL)[shareDic objectForKey:@"screen_shot"];
    
    NSLog(@"点击了分享");
    
}

//-(void)webViewDidStartLoad:(UIWebView *)webView
//{
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"webview-js-bridge" ofType:@"js"];
//    NSString *jsString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
//    NSLog(@"hahao====%@",jsString);
//    [self.webview stringByEvaluatingJavaScriptFromString:jsString];
//}
-(void)writeJSintowebview
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"webview-js-bridge" ofType:@"js"];
    NSString *jsString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"hahao====%@",jsString);
    [self.webview stringByEvaluatingJavaScriptFromString:jsString];
}
@end
