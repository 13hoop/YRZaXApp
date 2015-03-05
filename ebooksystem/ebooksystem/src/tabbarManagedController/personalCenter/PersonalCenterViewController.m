//
//  PersonalCenterViewController.m
//  ebooksystem
//
//  Created by wanghaoyu on 15/2/11.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import "PersonalCenterViewController.h"

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
#import "MatchViewController.h"
#import "SecondRenderKnowledgeViewController.h"
#import "discoveryModel.h"
#import "PersionalCenterUrlConfig.h"
#import "UserInfo.h"
#import "UserManager.h"
#import "StatisticsManager.h"
#import "UMFeedbackViewController.h"
#import "FirstReuseViewController.h"
#import "WebViewBridgeRegisterUtil.h"

@interface PersonalCenterViewController ()<UIWebViewDelegate>

#pragma mark - properties
// bridge between webview and js
@property (nonatomic, strong) WebViewJavascriptBridge *javascriptBridge;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic,strong) NSString *oldUserAgent;


#pragma mark - methods
- (BOOL)updateWebView;

@end

@implementation PersonalCenterViewController


#pragma mark - properties
// webUrl
- (NSString *)webUrl {
    //加载本地的html
    NSString *bundlePath = [PathUtil getBundlePath];
    NSString *userCenterUrlStrWithParams = [NSString stringWithFormat:@"%@/%@/%@/%@", bundlePath, @"assets",@"native-html",@"user_center.html"];
    self.webUrl = userCenterUrlStrWithParams;
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
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,0, rect.size.width, rect.size.height - 48)];
        _webView.delegate = self;
//        _webView.dataDetectorTypes = UIDataDetectorTypeNone;//iOS7及以后禁掉将数字解析成电话号码
        
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
    
}
- (void)viewWillAppear:(BOOL)animated {
    //隐藏掉状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    //隐藏导航栏
    self.navigationController.navigationBarHidden = YES;
    //个人中心页需要显示tabbar
    self.tabBarController.tabBar.hidden = NO;
    //要修改用户设置信息，所以每次显示这个页面时都需要重新加载一次
    [self.webView reload];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - init
/*
- (BOOL)initWebView {
    // goback()
    [self.javascriptBridge registerHandler:@"goBack" handler:^(id data, WVJBResponseCallback responseCallback) {
        LogDebug(@"RenderKnowledgeViewController::goBack() called: %@", data);
        
        [self.navigationController popViewControllerAnimated:YES];
    }];
    //
    //share app
    [self.javascriptBridge registerHandler:@"share" handler:^(id data, WVJBResponseCallback responseCallback) {
        LogDebug(@"RenderKnowledgeViewController::share() called: %@", data);
        
        NSDictionary *shareDic = (NSDictionary *)data;
        
        [self share:shareDic];
    }];
    //change Background
    [self.javascriptBridge registerHandler:@"setStatusBarBackground" handler:^(id data, WVJBResponseCallback responseCallback) {
        [self changeBackgourndColorWithColor:data];
    }];
    //showURL
    [self.javascriptBridge registerHandler:@"showURL" handler:^(id data, WVJBResponseCallback responseCallback) {
        //
        NSString *dataStr = data;
        SBJsonParser *parse = [[SBJsonParser alloc] init];
        NSDictionary *dic = [parse objectWithString:dataStr];
        if ([[dic objectForKey:@"target"] isEqualToString:@"activity"]) {
            [self showSafeURL:[dic objectForKey:@"url"]];
        }
        else
        {
            NSString *urlStr = [dic objectForKey:@"url"];
            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
        }
        
    }];
    
    //showAppPageByAction
    [self.javascriptBridge registerHandler:@"showAppPageByAction" handler:^(id data, WVJBResponseCallback responseCallback) {
        //
        NSString *actionStr = data;
        SBJsonParser *parse = [[SBJsonParser alloc] init];
        NSDictionary *dic = [parse objectWithString:actionStr];
        //根据Js传的参数来决定是否需要开新的WebView
        [self showAppPageByaction:dic];
    }];
    
    //setCurUserInfo
    [self.javascriptBridge registerHandler:@"setCurUserInfo" handler:^(id data, WVJBResponseCallback responseCallback) {
        //设置当前用户信息
        NSString *cruUserInfoStr = data;
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *cruUserInfoDic = [parser objectWithString:cruUserInfoStr];
        
        // 1 parse cruUserInfoDic
        UserInfo *userInfo = [[UserInfo alloc] init];
        NSString *userId = [cruUserInfoDic objectForKey:@"user_id"];
        NSString *userName = [cruUserInfoDic objectForKey:@"user_name"];
        NSString *balance = [cruUserInfoDic objectForKey:@"balance"];
        NSString *mobile = [cruUserInfoDic objectForKey:@"mobile"];
        NSString *sessionId = [cruUserInfoDic objectForKey:@"session_id"];
        if (userId == nil || userId.length <= 0) {
            LogError(@"[RenderKnowledgeViewController - setCur]");
        }
        //userId
        userInfo.userId = userId;
        //userName
        if (userName == nil || userName.length <= 0) {
            userInfo.username = @"";
        }
        else {
            userInfo.username = userName;
        }
        //balance
        if (balance == nil || balance.length <= 0) {
            userInfo.balance = @"";
        }
        else {
            userInfo.balance = balance;
        }
        //phoneNumber
        if (mobile == nil || mobile.length <= 0) {
            userInfo.phoneNumber = @"";
        }
        else {
            userInfo.phoneNumber = mobile;
        }
        //sessionId
        if (sessionId == nil || sessionId.length <= 0) {
            userInfo.sessionId = @"";
        }
        else {
            userInfo.sessionId = sessionId;
        }
        //password
        userInfo.password = @"";
        //2 save userInfo
        UserManager *usermanager = [UserManager instance];
        BOOL setSuccess = [usermanager saveUserInfo:userInfo];
        if (setSuccess) {
            responseCallback (@"1");
        }
        else {
            responseCallback (@"0");
        }
        
    }];
    //getCurUserInfo
    [self.javascriptBridge registerHandler:@"getCurUserInfo" handler:^(id data, WVJBResponseCallback responseCallback) {
        //默认图片
        NSString *imageUrl = [[[Config instance] drawableConfig] getImageFullPath:@"default.jpg"];
        NSString *imageBundlePath = [[NSBundle mainBundle] bundlePath];
        NSString *fullpath = [NSString stringWithFormat:@"%@/%@",imageBundlePath,imageUrl];
        //其他用户信息
        UserManager *userManager = [UserManager instance];
        UserInfo *userinfo = [userManager getCurUser];
        if (userinfo.userId == nil || userinfo.userId <= 0) {
            if(responseCallback != nil) {
                responseCallback(@"{}");
            }
        }
        else {
            NSString *cruUserName = userinfo.username;
            NSString *cruUserInfoBalance = userinfo.balance;
            NSString *cruUserId = userinfo.userId;
            NSString *cruPhone = userinfo.phoneNumber;
            NSDictionary *userInfoDic = @{@"user_id":cruUserId,@"user_name":cruUserName,@"avatar_src":fullpath,@"balance":cruUserInfoBalance,@"mobile":cruPhone};
            SBJsonWriter *writer = [[SBJsonWriter alloc] init];
            NSString *userInfoStr = [writer stringWithObject:userInfoDic];
            if (responseCallback != nil) {
                responseCallback(userInfoStr);
                
            }
        }
        
    }];
    
    return YES;

    
}
*/

- (BOOL)updateWebView {
    NSURL *Url = [NSURL URLWithString:self.webUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:Url];
    
    [self.webView loadRequest:request];
    
    return YES;
}

/*
#pragma mark - share
- (void)share:(NSDictionary *)shareDic {
    
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

#pragma mark showAppPageByAction methods
- (void)showAppPageByaction:(NSDictionary *)dic {
    NSString *target = [dic objectForKey:@"target"];
    NSString *action = [dic objectForKey:@"action"];
    NSString *urlStr = [PersionalCenterUrlConfig getUrlWithAction:action];
    if ([urlStr isEqualToString:@"feedback"]) {
        //进入到用户反馈页
        [self showNativeFeedbackWithAppkey:[[StatisticsManager instance] appKeyFromUmeng]];
        self.tabBarController.tabBar.hidden = YES;
        return;
    }
    if (urlStr == nil) {
        LogWarn(@"[RenderKnowledgeViewController - showAppPageByaction]:go to target web failed , urlStr is equal to nil");
        return;
    }
    if ([target isEqualToString:@"activity"]) {
        [self showSafeURL:urlStr];
    }
    else {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
    }
}

#pragma mark - UMdelegate
- (void)showNativeFeedbackWithAppkey:(NSString *)appkey {
    UMFeedbackViewController *feedbackViewController = [[UMFeedbackViewController alloc] initWithNibName:@"UMFeedbackViewController" bundle:nil];
    feedbackViewController.appkey = appkey;
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController pushViewController:feedbackViewController animated:YES];
}

//在线网页接口showUrl 调用的接口
- (BOOL)showSafeURL:(NSString *)urlStr {
    
    SecondRenderKnowledgeViewController *secondRender = [[SecondRenderKnowledgeViewController alloc] init];
    secondRender.webUrl = urlStr;
    secondRender.flag = nil;
    [self.navigationController pushViewController:secondRender animated:YES];
    
    return YES;
}

 */

#pragma mark - web view delegate methods

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (request) {
        LogDebug(@"[RenderKnowledgeViewController] Web request: UA: %@", [request valueForHTTPHeaderField:@"User-Agent"]);
    }

    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self injectJSToWebView:webView];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    //    [self injectJSToWebView:webView];
}
#pragma mark - js injection

- (void)injectJSToWebView:(UIWebView *)webView {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"webview-js-bridge" ofType:@"js"];
    NSString *jsString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    [webView stringByEvaluatingJavaScriptFromString:jsString];
}


#pragma  mark test changeColor
-(void)changeBackgourndColorWithColor:(NSString *)colorString
{
    self.view.backgroundColor = [UIColor colorWithHexString:colorString alpha:1];
}


@end
