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
#import "UIColor+Hex.h"
#import "UMSocial.h"
#import "UMSocialSnsService.h"
#import "UMSocialScreenShoter.h"

#import "DirectionMPMoviePlayerViewController.h"
#import "CustomURLProtocol.h"

#import "Config.h"

#import "WebUtil.h"
#import "LogUtil.h"
#import "KnowledgeManager.h"
#import "KnowledgeWebViewController.h"
#import "NSUserDefaultUtil.h"
#import "PathUtil.h"
#import "OperateCookie.h"
#import "SBJson.h"
#import "KnowledgeMetaManager.h"
#import "RenderKnowledgeViewController.h"
#import "FirstReuseViewController.h"

#import "WebViewBridgeRegisterUtil.h"
#import "StatisticsManager.h"

typedef enum {
    UNKNOWN = -1,
    FAILED, //操作失败
    SUCCESS,//操作成功
    
    
} OPERATIONRESULT;

@interface MatchViewController () <UIWebViewDelegate,WebviewBridgeRegisterDelegate>

#pragma mark - properties
// bridge between webview and js
@property (nonatomic, strong) WebViewJavascriptBridge *javascriptBridge;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSString *oldUserAgent;
@property (nonatomic, strong) WebViewBridgeRegisterUtil *webviewBridgeUtil;

@property (nonatomic, assign) BOOL flag;


#pragma mark - methods
- (BOOL)updateWebView;

// 播放视频
- (void)playVideo:(NSString *)urlStr;

// 设置user agent
- (BOOL)checkUserAgent;

@end

@implementation MatchViewController


#pragma mark - properties
// webUrl
- (NSString *)webUrl {
    if (_webUrl != nil && ![_webUrl hasSuffix:[Config instance].webConfig.userAgent]) {
        NSString *connector = @"&";
        if ([_webUrl hasSuffix:@"/"]) {
            connector = @"\?";
        }
        _webUrl = [NSString stringWithFormat:@"%@%@ua=%@", _webUrl, connector, [Config instance].webConfig.userAgent];
    }
    
    return _webUrl;
}

// webview
- (UIWebView *)webView {
    if (_webView == nil) {
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height - 20 - 48)];
        _webView.delegate = self;
        
        [self.view addSubview:_webView];
    }
    
    return _webView;
}


/*
// bridge between webview and js
-(WebViewJavascriptBridge *)javascriptBridge {
    if (_javascriptBridge == nil) {
        _javascriptBridge = [WebViewJavascriptBridge bridgeForWebView:self.webView webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
            LogDebug(@"Received message from javascript: %@", data);
            responseCallback(@"'response data from obj-c'");
        }];
                [self initWebView];
    }
    
    return _javascriptBridge;
}
*/



#pragma mark - app life

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //状态栏显示
//    [self initWebView];
    [self updateWebView];
    
    [self createUI];
    
    
    self.flag = YES;
    
    //统计app启动次数
    [[StatisticsManager instance] statisticWithUrl:@"http://log.zaxue100.com/pv.gif?t=device&k=start&v=1"];
    
}

- (void)createUI {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.webviewBridgeUtil = [[WebViewBridgeRegisterUtil alloc] init] ;
    self.webviewBridgeUtil.webView = self.webView;
    self.webviewBridgeUtil.controller = self;
    self.webviewBridgeUtil.mainControllerView = self.view;
    self.webviewBridgeUtil.navigationController = self.navigationController;
    self.webviewBridgeUtil.tabBarController = self.tabBarController;
    self.webviewBridgeUtil.delegate = self;
    [self.webviewBridgeUtil initWebView];
    
    
    
    
    
    /*
     if ([self.shouldChangeBackground isEqualToString:@"needChange"]) {
     self.view.backgroundColor=[UIColor colorWithHexString:@"#242021" alpha:1];
     }
     else {
     self.view.backgroundColor = [UIColor colorWithHexString:@"#4C501D" alpha:1];
     }
     */
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.webView.scrollView.bounces = NO;
    self.webView.scrollView.showsVerticalScrollIndicator = NO;
    
    
    
//    [self checkCookie];
    
    
    
    
}


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden = YES;
    //显示状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:false];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    //触发JS事件
    [self injectJSToWebview:self.webView andJSFileName:@"SamaPageShow"];
    //页面登陆统计
    [[StatisticsManager instance] beginLogPageView:@"myBagPage"];

    if (self.webView == nil) {
        [self createUI];
        
    }

    //切换白天夜间模式
      NSString *globalMode = [NSUserDefaultUtil getGlobalMode];
    if ([globalMode isEqualToString:@"day"]) {
        self.view.backgroundColor = [UIColor whiteColor];
    }
    else if ([globalMode isEqualToString:@"night"]) {
        self.view.backgroundColor = [UIColor colorWithHexString:@"#373E4F"];
    }
    
    
}



- (void)viewWillDisappear:(BOOL)animated {
    
    //触发JS事件
    [self injectJSToWebview:self.webView andJSFileName:@"SamaPageHide"];
    //关掉页面统计
    [[StatisticsManager instance] endLogPageView:@"myBagPage"];
    
   
    // 退出时将所有的内容释放掉
    self.webviewBridgeUtil.delegate = nil;
    self.webviewBridgeUtil.webView = nil;
    self.webviewBridgeUtil.mainControllerView = nil;
    self.webviewBridgeUtil.controller = nil;
    self.webView.delegate = nil;
    self.webView = nil;
    self.view = nil;
    
    
    
}


- (void)dealloc {
    
    self.webView.delegate = nil;
    NSLog(@"书包页也进dealloc");
}


//- (void)viewDidAppear:(BOOL)animated {
//    // test - 每次视图出现时则设置代理
//    self.webView.delegate = self;
//    self.webviewBridgeUtil.delegate = self;
//}
- (void)viewDidDisappear:(BOOL)animated {
    // test - 视图消失时则将代理释放
//    self.webView.delegate = nil;
//    self.webviewBridgeUtil.delegate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    /*
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"WARNING" message:@"手机内存使用率过高,Please release memory immediately" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"ok", nil];
    [alert show];
    */
    
}


#pragma mark - init


- (BOOL)updateWebView {
    NSString *studyType = [NSUserDefaultUtil getCurStudyType];
    NSString *bundlePath = [PathUtil getBundlePath];
    NSString *myBagUrlStrWithParams = [NSString stringWithFormat:@"%@/%@/%@/%@%@%@", bundlePath, @"assets",@"native-html",@"schoolbag.html",@"?study_type=",studyType];
    NSURL *myBagUrl = [NSURL URLWithString:myBagUrlStrWithParams];
    NSURLRequest *request = [NSURLRequest requestWithURL:myBagUrl];
    [self.webView loadRequest:request];
    
    return YES;
}



#pragma mark - web view delegate methods

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (request) {
        LogDebug(@"[MatchViewConroller] Web request: UA: %@", [request valueForHTTPHeaderField:@"User-Agent"]);
    }
    
//    [self injectJSToWebView:webView];
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self injectJSToWebView:webView];
}

#pragma mark - js injection

- (void)injectJSToWebView:(UIWebView *)webView {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"webview-js-bridge" ofType:@"js"];
    NSString *jsString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    [webView stringByEvaluatingJavaScriptFromString:jsString];
}

//给JS的响应事件，分别在viewWillAppear、viewWillDisAppear时触发。
- (void)injectJSToWebview:(UIWebView *)webView andJSFileName:(NSString *)JSfileName {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:JSfileName ofType:@"js"];
    NSString *jsString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    [webView stringByEvaluatingJavaScriptFromString:jsString];
}


#pragma mark - set User Agent


#pragma  get session
- (void)checkCookie {
    [OperateCookie setCookieWithCustomKeyAndValue:nil];
    [OperateCookie checkCookie];
    
}






#pragma mark webviewJavascriptRegisterUtil delegate
//修改tabbar的背景
- (void)refreshTabbarBackgroundWithMode:(NSString *)mode {
    if ([mode isEqualToString:@"night"]) {
        for (UIView *tempView in self.tabBarController.tabBar.subviews) {
            if ([tempView isKindOfClass:[UIButton class]]) {
                UIButton *btn = (UIButton *)tempView;
                [btn setBackgroundColor:[UIColor colorWithHexString:@"#373E4F"]];
            }
            if ([tempView isKindOfClass:[UILabel class]]) {
                UILabel *currentLable = (UILabel *)tempView;
                currentLable.backgroundColor = [UIColor colorWithHexString:@"#373E4F"];
            }
        }
    }
    else if ([mode isEqualToString:@"day"]) {
        for (UIView *tempView in self.tabBarController.tabBar.subviews) {
            if ([tempView isKindOfClass:[UIButton class]]) {
                UIButton *btn = (UIButton *)tempView;
                [btn setBackgroundColor:[UIColor whiteColor]];
            }
            if ([tempView isKindOfClass:[UILabel class]]) {
                UILabel *currentLable = (UILabel *)tempView;
                currentLable.backgroundColor = [UIColor whiteColor];
            }
        }
    }
}



@end
