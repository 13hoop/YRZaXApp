//
//  SecondReuseViewController.m
//  ebooksystem
//
//  Created by wanghaoyu on 15/2/2.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import "SecondReuseViewController.h"
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
#import "FirstReuseViewController.h"

@interface SecondReuseViewController ()<UIWebViewDelegate>


#pragma mark - properties
// bridge between webview and js
@property (nonatomic, strong) WebViewJavascriptBridge *javascriptBridge;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic,strong) NSString *oldUserAgent;



#pragma mark - methods

// 设置user agent
- (BOOL)checkUserAgent;





@end

@implementation SecondReuseViewController


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
        [self initWebView];
    }
    
    return _javascriptBridge;
}






- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"现在进入了secondReusecontroller中");
    [self initWebView];
    
    if ([self.shouldChangeBackground isEqualToString:@"needChange"]) {
        self.view.backgroundColor=[UIColor colorWithHexString:@"#242021" alpha:1];
    }
    else {
        self.view.backgroundColor = [UIColor colorWithHexString:@"#4C501D" alpha:1];
    }
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

#pragma mark update webView
- (BOOL)updateWebView {
    // 在加载loadRuquest之前设置userAgent
    LogInfo(@"self.webUrl ===== %@",self.webUrl);
    NSURL *Url = [NSURL URLWithString:self.webUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:Url];
    
    [self.webView loadRequest:request];
    return YES;
}




#pragma mark init Web view

- (BOOL)initWebView {
    //    self.webView.delegate = self.javascriptBridge;
    
    // goback()
    [self.javascriptBridge registerHandler:@"goBack" handler:^(id data, WVJBResponseCallback responseCallback) {
        LogDebug(@"SecondReuseViewController::goBack() called: %@", data);
        
        [self.navigationController popViewControllerAnimated:YES];
    }];
    //shareApp
    [self.javascriptBridge registerHandler:@"shareApp" handler:^(id data, WVJBResponseCallback responseCallback) {
        LogDebug(@"SecondReuseViewController::share() called: %@", data);
        NSString *shareContentStr = data;
        //parse
        SBJsonParser *parse = [[SBJsonParser alloc] init];
        NSDictionary *shareDic = [parse objectWithString:shareContentStr];
        //share
        [self share:shareDic];
    }];
    
    // playVideo()
    [self.javascriptBridge registerHandler:@"playVideo" handler:^(id dataId, WVJBResponseCallback responseCallback) {
        LogDebug(@"SecondReuseViewController::playVideo() called: %@", dataId);
        
        NSString *urlStr = (NSString *)dataId;
        [self playVideo:urlStr];
    }];
    
    //change Background
    [self.javascriptBridge registerHandler:@"setStatusBarBackground" handler:^(id data, WVJBResponseCallback responseCallback) {
        [self changeBackgourndColorWithColor:data];
    }];
    
    
    //js要求调到新的页面时，调到这个里面：
    //getData      ********     *********
    [self.javascriptBridge registerHandler:@"getData" handler:^(id data,WVJBResponseCallback responseCallback){
        LogDebug(@"SecondReuseViewController::getData() called: %@", data);
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *dataDic = [parser objectWithString:data];
        NSString *dataId = [dataDic objectForKey:@"book_id"];
        NSString *queryId = [dataDic objectForKey:@"query_id"];
        if (responseCallback != nil) {
            NSArray *dataArray = [[KnowledgeManager instance] getLocalDataWithDataId:dataId andQueryId:queryId andIndexFilename:nil];
            NSString *data = nil;
            for (NSString *dataStr in dataArray) {
                if (dataStr == nil || dataStr.length <= 0) {
                    continue;
                }
                
                data = dataStr;
                break;
            }
            responseCallback(data);
        }
    }];
    
    
    
    //renderPage   *******       ********
    [self.javascriptBridge registerHandler:@"renderPage" handler:^(id data,WVJBResponseCallback responseCallback){
        LogDebug(@"SecondReuseViewController::renderPage() called: %@", data);
        SBJsonParser *parse = [[SBJsonParser alloc] init];
        NSDictionary *dic = [parse objectWithString:data];
        [self showPageWithDictionary:dic];
        
    }];
    //getCurStudyType
    [self.javascriptBridge registerHandler:@"getCurStudyType" handler:^(id data ,WVJBResponseCallback responseCallback){
        //在nsuserDefault中设置一个curStudyType字段，用来存储当前用户的学习状态
        LogDebug(@"SecondReuseViewController::getCurStudyType() called: %@", data);
        if (responseCallback != nil) {
            NSString *data =nil;
            NSString *curStudyType = [NSUserDefaultUtil getCurStudyType];
            if (curStudyType != nil && curStudyType.length > 0) {
                data = curStudyType;
                
                responseCallback(data);
            }
        }
        
    }];
    
    return YES;
}


#pragma mark js -- native interface method

//1 shareApp
- (void)share:(NSDictionary *)shareDic {
    
    
    /* 2.0
     title          标题
     content        内容
     image_url      小图片url
     target_url     目标页面url
     */
    //title
    NSString *titleAll=[shareDic objectForKey:@"title"];
    //分享链接
    NSString *callBackUrl=[shareDic objectForKey:@"target_url"];
    //    NSURL *weburl=[NSURL URLWithString:urlString];
    //分享的图片链接
    NSString *imageString=[shareDic objectForKey:@"img_url"];
    //是否截屏
    //    BOOL shouldScreen_shot=(BOOL)[shareDic objectForKey:@"screen_shot"];
    //微信使用的url
    NSString *weixinImageUrl=[shareDic objectForKey:@"image_url"];
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
    
    /*1.0 used share scene
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
     */
    
    
    //2.0 share to wechatTimeline only
    //4、设置微信朋友圈的分享的URL图片
    [[UMSocialData defaultData].extConfig.wechatTimelineData.urlResource setResourceType:UMSocialUrlResourceTypeImage url:weixinImageUrl];
    //设置微信朋友圈的分享文字
    [UMSocialData defaultData].extConfig.wechatTimelineData.shareText=shareString;
    //
    [UMSocialData defaultData].extConfig.wechatTimelineData.url=callBackUrl;
    
    [UMSocialSnsService presentSnsIconSheetView:self appKey:@"543dea72fd98c5fc98004e08" shareText:shareString shareImage:nil shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatTimeline,nil] delegate:nil];//UMShareToWechatSession
}


//2 播放视频
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

// 3 修改背景的颜色
-(void)changeBackgourndColorWithColor:(NSString *)colorString
{
    self.view.backgroundColor = [UIColor colorWithHexString:colorString alpha:1];
}

// 4 打开指定的页面
//2.0中跳转到指定页面
- (BOOL)showPageWithDictionary:(NSDictionary *)dic {
    NSString *target = dic[@"target"];
    if ([target isEqualToString:@"self"]) {
        
        NSString *book_id = dic[@"book_id"];
        
        NSString *htmlFilePath = [[KnowledgeManager instance] getPagePath:book_id];
        if (htmlFilePath == nil || htmlFilePath.length <= 0) {
            return NO;
        }
        NSString *page_type = dic[@"page_type"];
        
        // 加载指定的html文件
        NSURL *url = [[NSURL alloc] initFileURLWithPath:[NSString stringWithFormat:@"%@/%@/%@", htmlFilePath,page_type, @".html"]];
        
        NSString *urlStrWithParams = nil;
        //        NSString *args = dic[@"getArgs"];
        NSString *args = dic[@"get_args"];
        
        if (args != nil && args.length > 0) {
            urlStrWithParams = [NSString stringWithFormat:@"%@?%@", [url absoluteString], args];
        }
        else {
            urlStrWithParams = [NSString stringWithFormat:@"%@", [url absoluteString]];
        }
        
        NSURL *urlWithParams = [[NSURL alloc] initWithString:urlStrWithParams];
        
        [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:urlWithParams]];
        
        return YES;
    }
    else
    {
        if ([target isEqualToString:@"activity"]) {
            NSString *book_id = dic[@"book_id"];
            
            NSString *htmlFilePath = [[KnowledgeManager instance] getPagePath:book_id];
            if (htmlFilePath == nil || htmlFilePath.length <= 0) {
                return NO;
            }
            NSString *page_type = dic[@"page_type"];
            
            // 加载指定的html文件
            NSString *urlStr = [NSString stringWithFormat:@"%@/%@/%@%@", htmlFilePath,@"render",page_type, @".html"];
            
            NSString *urlStrWithParams = nil;
            NSString *args = dic[@"get_args"];
            if (args != nil && args.length > 0) {
                urlStrWithParams = [NSString stringWithFormat:@"%@%@", urlStr, args];
            }
            else {
                urlStrWithParams = [NSString stringWithFormat:@"%@", urlStr];
                
            }
            //打开新的controller
            return [self readBookWithSafeUrl:urlStrWithParams];
            
        }
    }
    
    return YES;
    
}

//读书页用这两个页面
- (BOOL)readBookWithSafeUrl:(NSString *)urlStr {
    FirstReuseViewController *first = [[FirstReuseViewController alloc] init];
    first.webUrl = urlStr;
    [self.navigationController pushViewController:first animated:YES];
    return YES;
}




- (BOOL)showSafeURL:(NSString *)urlStr {
    
    FirstReuseViewController *first = [[FirstReuseViewController alloc] init];
    first.webUrl = urlStr;
    [self.navigationController pushViewController:first animated:YES];
    return YES;
}




//
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



@end
