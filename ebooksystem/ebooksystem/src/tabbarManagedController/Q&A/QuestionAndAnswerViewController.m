//
//  QuestionAndAnswerViewController.m
//  ebooksystem
//
//  Created by wanghaoyu on 15/1/15.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import "QuestionAndAnswerViewController.h"
#import "WebViewJavascriptBridge.h"
#import "PathUtil.h"
#import "LogUtil.h"
#import "Config.h"
#import "ScanQRCodeViewController.h"
#import "SBJson.h"
#import "WebViewBridgeRegisterUtil.h"
#import "MRActivityIndicatorView.h"
#import "DeviceStatusUtil.h"
#import "CustomPromptView.h"


@interface QuestionAndAnswerViewController ()<UIWebViewDelegate>

{
    MRActivityIndicatorView *activityIndicatorView;
    NSTimer *timer;
}

#pragma mark - properties
// bridge between webview and js
@property (nonatomic, strong) WebViewJavascriptBridge *javascriptBridge;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSString *oldUserAgent;

//没网时的提示动画视图
@property (nonatomic, strong) CustomPromptView *promptView;

#pragma mark - methods
- (BOOL)updateWebView;


@end

@implementation QuestionAndAnswerViewController



// webUrl
- (NSString *)webUrl {
    //加载本地的html
    
    NSString *questionAndAnswerNonParam = @"http://test.zaxue100.com/index.php?c=bbs_ctrl&m=question_list_page";
    self.webUrl = questionAndAnswerNonParam;
//    NSString *bundlePath = [PathUtil getBundlePath];
//    NSString *userCenterUrlStrWithParams = [NSString stringWithFormat:@"%@/%@/%@/%@", bundlePath, @"assets",@"native-html",@"user_center.html"];
//    self.webUrl = userCenterUrlStrWithParams;
    
    if (_webUrl != nil && ![_webUrl hasSuffix:[Config instance].webConfig.userAgent]) {
        NSString *connector = @"&";
        if ([_webUrl hasSuffix:@"/"]) {
            connector = @"\?";
        }
        
        _webUrl = [NSString stringWithFormat:@"%@", _webUrl];
        
    }
    
    return _webUrl;
}

// webview
- (UIWebView *)webView {
    if (_webView == nil) {
        CGRect rect = [[UIScreen mainScreen] bounds];
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,20, rect.size.width, rect.size.height - 48)];
        _webView.delegate = self;
        _webView.dataDetectorTypes = UIDataDetectorTypeNone;//iOS7及以上禁止webview解析数字成电话号码
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


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    
    
//    [self initWebView];
    WebViewBridgeRegisterUtil *webviewBridgeUtil = [[WebViewBridgeRegisterUtil alloc] init];
    webviewBridgeUtil.webView = self.webView;
    webviewBridgeUtil.controller = self;
    webviewBridgeUtil.mainControllerView = self.view;
    webviewBridgeUtil.navigationController = self.navigationController;
    webviewBridgeUtil.tabBarController = self.tabBarController;
    [webviewBridgeUtil initWebView];
    
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.webView.scrollView.bounces = NO;
    self.webView.scrollView.showsVerticalScrollIndicator = NO;
    [self updateWebView];
    //创建加载动画视图 创建视图的顺序必须是在创建webview之后
    [self createActivityIndicator];
    //判断是否连接网络
    DeviceStatusUtil *cruDeviceStatus = [[DeviceStatusUtil alloc] init];
    NSString *CruStatus = [cruDeviceStatus GetCurrntNet];
    if ([CruStatus isEqualToString:@"no connect"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"网络不给力，请检查网络连接后重试" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"好", nil];
        [alert show];
        //1 创建提示视图
        [self createPromptView];
        
        //2 开启定时器，进行检测
        timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(haveConnected) userInfo:nil repeats:YES];
    }
    
    
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    //显示掉状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:false];
    //隐藏导航栏
    self.navigationController.navigationBarHidden = YES;
    //个人中心页需要显示tabbar
    self.tabBarController.tabBar.hidden = NO;
    //触发JS事件
    [self injectJSToWebview:self.webView andJSFileName:@"SamaPageShow"];

}

- (void)viewWillDisappear:(BOOL)animated {
    [self injectJSToWebview:self.webView andJSFileName:@"SamaPageHide"];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 创建提示视图
- (void)createPromptView {
    self.promptView = [[CustomPromptView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height -44)];
    [self.view addSubview:self.promptView];
}

#pragma mark 不断检测网络状态

- (void)haveConnected {
    DeviceStatusUtil *device = [[DeviceStatusUtil alloc] init];
    NSString *cruStatus = [device GetCurrntNet];
    if (![cruStatus isEqualToString:@"no connect"]) {
        //有网络

        //移除掉提示视图
        [self.promptView removeFromSuperview];
        //重新加载
        NSURL *Url = [NSURL URLWithString:self.webUrl];
        NSURLRequest *request = [NSURLRequest requestWithURL:Url];
        [self.webView loadRequest:request];

        //关闭定时器
        [timer invalidate];
        timer = nil;
        
    }
}



/*
#pragma mark - init
- (BOOL)initWebView {
    
    //************ 扫一扫接口 ***********
    //startQRCodeScan
    [self.javascriptBridge registerHandler:@"startQRCodeScan" handler:^(id data ,WVJBResponseCallback responseCallback){
        NSString *infoDicStr = data;
        if (infoDicStr == nil || infoDicStr.length <= 0) {
            LogWarn(@"[FirstReuseViewController -  startQRCodeScan]: failed go to scan COntroller because of data from Js is nil ");
            return;
        }
        SBJsonParser *parse = [[SBJsonParser alloc] init];
        NSDictionary *dic = [parse objectWithString:infoDicStr];
        //
        [self goScanViewController:dic];
        
        
    }];
    
    return YES;
}
 */

#pragma mark - web view delegate methods

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (request) {
        LogDebug(@"[QuestionAndAnswerViewController] Web request: UA: %@", [request valueForHTTPHeaderField:@"User-Agent"]);
    }
//    [self injectJSToWebView:webView];

    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self injectJSToWebView:webView];
    //结束网络加载提示
    [self hideProgressOfActivityIndicator];
    
    
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    //开启网络加载的提示
     [self showProgressAsActivityIndicator];
    
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


- (BOOL)updateWebView {
    NSURL *Url = [NSURL URLWithString:self.webUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:Url];
    
    [self.webView loadRequest:request];
    
    return YES;
}




#pragma mark 创建加载控件
-(void)createActivityIndicator
{
    //    self.tbactivityView=[[TBActivityView alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.height-30)/2, 320, 30)];
    //    [self.view addSubview:self.tbactivityView];
    activityIndicatorView=[[MRActivityIndicatorView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-30)/2, (self.view.frame.size.height-30)/2,30, 30)];
    [self.view addSubview:activityIndicatorView];
    
}

#pragma mark 加载提示动画view的开始结束动画方法

- (void)showProgressAsActivityIndicator {
    if (activityIndicatorView) {
        activityIndicatorView.hidden = NO;
        activityIndicatorView.hidesWhenStopped = YES;
        activityIndicatorView.tintColor = [UIColor blueColor];
        activityIndicatorView.backgroundColor = [UIColor clearColor];
        [activityIndicatorView startAnimating];
    }
}

- (void)hideProgressOfActivityIndicator {
    if (activityIndicatorView) {
        [activityIndicatorView stopAnimating];
        //    activityIndicatorView.hidden = YES;
    }
}

/*
#pragma mark 问答页接口调用的方法
#pragma mark goScanViewController
- (void)goScanViewController:(NSDictionary *)dic {
    NSString *openAnimation = [dic objectForKey:@"open_animate"];
    ScanQRCodeViewController *scanQrcodeViewController = [[ScanQRCodeViewController alloc] init];
    if (openAnimation == nil || openAnimation.length <= 0 ) {//
        [self.navigationController pushViewController:scanQrcodeViewController animated:YES];
        
    }
    else {//开场动画不为空
        CATransition *animation = [self customAnimation:openAnimation];
        [self.navigationController.view.layer addAnimation:animation forKey:nil];
        [self.navigationController pushViewController:scanQrcodeViewController animated:NO];
    }
    
}

//设置自定义的动画效果
- (CATransition *)customAnimation:(NSString *)openAnimation {
    
    //根据JS传的参数来设置动画的切入，出方向。
    CATransition *animation = [CATransition animation];
    [animation setDuration:1];
    [animation setType: kCATransitionPush];//设置为推入效果
    if ([openAnimation isEqualToString:@"pull_left_out"] || [openAnimation isEqualToString:@"push_right_in"]) {
        [animation setSubtype: kCATransitionFromRight];//设置方向
        
    }
    else if ([openAnimation isEqualToString:@"pull_right_out"]|| [openAnimation isEqualToString:@"push_left_in"]) {
        [animation setSubtype: kCATransitionFromLeft];//设置方向
        
    }
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    return animation;
}
*/

@end
