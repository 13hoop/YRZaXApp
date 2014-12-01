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



@interface MatchViewController () <UIWebViewDelegate>

#pragma mark - properties

// bridge between webview and js
@property (nonatomic, strong) WebViewJavascriptBridge *javascriptBridge;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic,strong) NSString *oldUserAgent;


#pragma mark - methods
- (BOOL)updateWebView;

// 播放视频
- (void)playVideo:(NSString *)urlStr;

// 设置user agent
- (BOOL)checkUserAgent;

@end

@implementation MatchViewController

@synthesize webUrl = _webUrl;
@synthesize webView = _webView;
@synthesize javascriptBridge = _javascriptBridge;


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
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height-20)];
        _webView.delegate = self;
        
        [self.view addSubview:_webView];
    }
    
    return _webView;
}

// bridge between webview and js
-(WebViewJavascriptBridge *)javascriptBridge {
    if (_javascriptBridge == nil) {
        _javascriptBridge = [WebViewJavascriptBridge bridgeForWebView:self.webView webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
            LogDebug(@"Received message from javascript: %@", data);
            responseCallback(@"'response data from obj-c'");
        }];
        //        [self initWebView];
    }
    
    return _javascriptBridge;
}

#pragma mark - app life

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [CustomURLProtocol register];
    
    [self initWebView];
    self.view.backgroundColor = [UIColor colorWithHexString:@"#4C501D" alpha:1];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.webView.scrollView.bounces = NO;
    self.webView.scrollView.showsVerticalScrollIndicator = NO;
  
//    [self injectJSToWebView:self.webView];
//    self.webview.delegate=self;
    [self updateWebView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - init

- (BOOL)initWebView {
//    self.webview.delegate = self.javascriptBridge;
    
    // goback()
    [self.javascriptBridge registerHandler:@"goBack" handler:^(id data, WVJBResponseCallback responseCallback) {
        LogDebug(@"MatchViewController::goBack() called: %@", data);
        // 判断是否可以继续回退
//        BOOL iscan = self.webView.canGoBack;
//        LogDebug(@"iscanBack=====%hhd",iscan);
//        if (iscan) {
//            [self.webView goBack];
//            
//        }
//        else
//        {
//            [self.navigationController popViewControllerAnimated:YES];
//        }
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [self.javascriptBridge registerHandler:@"share" handler:^(id data, WVJBResponseCallback responseCallback) {
        LogDebug(@"MatchViewController::share() called: %@", data);
        
        NSDictionary *shareDic = (NSDictionary *)data;
        
        [self share:shareDic];
    }];
    
    // playVideo()
    [self.javascriptBridge registerHandler:@"playVideo" handler:^(id dataId, WVJBResponseCallback responseCallback) {
        LogDebug(@"MatchViewController::playVideo() called: %@", dataId);
        
        NSString *urlStr = (NSString *)dataId;
        [self playVideo:urlStr];
    }];
    
    return YES;
}

- (BOOL)updateWebView {
    // 在加载loadRuquest之前设置userAgent
//    [self checkUserAgent];
    
    // load url
    //    self.webUrl=@"http://pk2015.zaxue100.com"; // test
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.webUrl]];
    [self.webView loadRequest:request];
    
    return YES;
}

#pragma mark - share

- (void)share:(NSDictionary *)shareDic {
    /*
     url :
     img_url :
     weixin_img_url :
     title :
     content :
     screen_shot : false
     */
    //title
    NSString *titleAll=[shareDic objectForKey:@"title"];
    //分享链接
    NSString *callBackUrl=[shareDic objectForKey:@"url"];
//    NSURL *weburl=[NSURL URLWithString:urlString];
    //分享的图片链接
    NSString *imageString=[shareDic objectForKey:@"img_url"];
    //是否截屏
    BOOL shouldScreen_shot=(BOOL)[shareDic objectForKey:@"screen_shot"];
    //微信使用的url
    NSString *weixinImageUrl=[shareDic objectForKey:@"weixin_img_url"];
    //分享内容
    NSString *shareString=[shareDic objectForKey:@"content"];
    
    
    /*
    //(1)使用ui，分享url定义的图片
    [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeImage url:imageString];
    //(2)使用ui,分享截屏图片
//    UIImage *image = [[UMSocialScreenShoterDefault screenShoter] getScreenShot];
    //不同的平台分享不同的内容
    //新浪微博平台
    [UMSocialData defaultData].extConfig.sinaData.shareText = @"分享到新浪微博内容";
    //腾讯
    [UMSocialData defaultData].extConfig.tencentData.shareImage = [UIImage imageNamed:@"meinv.jpg"]; //分享到腾讯微博图片
     */
    
    //1、分享到QQ
    [UMSocialData defaultData].extConfig.qqData.shareText=shareString;
    //分享到QQ的title
    [UMSocialData defaultData].extConfig.qqData.title=titleAll;
    //分享到QQ的image
    [[UMSocialData defaultData].extConfig.qqData.urlResource setResourceType:UMSocialUrlResourceTypeImage url:weixinImageUrl];
    //点击分享的内容跳转到的网站
    [UMSocialData defaultData].extConfig.qqData.url = callBackUrl;

    
    //2、分享到qq空间的图片
    [[UMSocialData defaultData].extConfig.qzoneData.urlResource setResourceType:UMSocialUrlResourceTypeImage url:weixinImageUrl];
    //分享qq空间的title
    [UMSocialData defaultData].extConfig.qzoneData.title = titleAll;
    //分享qq空间的内容
    [UMSocialData defaultData].extConfig.qzoneData.shareText=shareString;
    //回调的url
     [UMSocialData defaultData].extConfig.qzoneData.url = callBackUrl;
    
    
    //3、设置微信好友分享url图片
    [[UMSocialData defaultData].extConfig.wechatSessionData.urlResource setResourceType:UMSocialUrlResourceTypeImage url:weixinImageUrl];
    //设置微信的分享文字
    [UMSocialData defaultData].extConfig.wechatSessionData.shareText=shareString;
    //设置微信的title
    [UMSocialData defaultData].extConfig.wechatSessionData.title=titleAll;
    //回调的url
    [UMSocialData defaultData].extConfig.wechatSessionData.url=callBackUrl;
    
    
    //4、设置微信朋友圈的分享的URL图片
    [[UMSocialData defaultData].extConfig.wechatTimelineData.urlResource setResourceType:UMSocialUrlResourceTypeImage url:weixinImageUrl];
    //设置微信朋友圈的分享文字
    [UMSocialData defaultData].extConfig.wechatTimelineData.shareText=shareString;
    //
    [UMSocialData defaultData].extConfig.wechatTimelineData.url=callBackUrl;
    
    [UMSocialSnsService presentSnsIconSheetView:self appKey:@"543dea72fd98c5fc98004e08" shareText:shareString shareImage:nil shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatSession,UMShareToWechatTimeline,UMShareToQzone,UMShareToQQ,nil] delegate:nil];
}

#pragma mark - play video
// 播放视频
- (void)playVideo:(NSString *)urlStr {
    if (urlStr == nil || urlStr.length <= 0) {
        return;
    }
    
    NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    if (url == nil) {
        return;
    }
    
    // 不要加
//    [CustomURLProtocol injectURL:urlStr cookie:@"User-Agent:ZAXUE_IOS_POLITICS_APP"];
    
    // 播放
    //    MPMoviePlayerViewController *playerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    
    DirectionMPMoviePlayerViewController *playerViewController = [[DirectionMPMoviePlayerViewController alloc] initWithContentURL:url];
    playerViewController.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    playerViewController.view.frame = self.view.frame; // 全屏
    playerViewController.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallback:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:[playerViewController moviePlayer]];
    
    //---play movie---
    [[playerViewController moviePlayer] play];
    
    // 注: 用present会导致playerViewController中设置的transform不生效, 故转为push
    //    [self presentMoviePlayerViewControllerAnimated:playerViewController];
    [self.navigationController pushViewController:playerViewController animated:YES];
}

- (void)movieFinishedCallback:(NSNotification*) aNotification {
    MPMoviePlayerController *playerViewController = [aNotification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:playerViewController];
    [playerViewController stop];
    
    //    [self dismissMoviePlayerViewControllerAnimated];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - web view delegate methods

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (request) {
        LogDebug(@"[MatchViewConroller] Web request: UA: %@", [request valueForHTTPHeaderField:@"User-Agent"]);
    }
    
    [self injectJSToWebView:webView];
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

#pragma mark - set User Agent

- (BOOL)checkUserAgent {
    return [WebUtil checkUserAgent];
}

@end
