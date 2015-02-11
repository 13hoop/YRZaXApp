//
//  RenderKnowledgeViewController.m
//  ebooksystem
//
//  Created by wanghaoyu on 15/1/23.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import "RenderKnowledgeViewController.h"
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



@interface RenderKnowledgeViewController ()<UIWebViewDelegate>

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
//加载html页面的的方法
//加载页面上的data的方法

@end

@implementation RenderKnowledgeViewController

#pragma mark - properties
// webUrl
- (NSString *)webUrl {
    if (_webUrl != nil && ![_webUrl hasSuffix:[Config instance].webConfig.userAgent]) {
        NSString *connector = @"&";
        if ([_webUrl hasSuffix:@"/"]) {
            connector = @"\?";
        }
//        _webUrl = [NSString stringWithFormat:@"%@%@ua=%@", _webUrl, connector, [Config instance].webConfig.userAgent];
        
            _webUrl = [NSString stringWithFormat:@"%@", _webUrl];

    }
    
    return _webUrl;
}

// webview
- (UIWebView *)webView {
    if (_webView == nil) {
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height - 48)];
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

#pragma mark - app life

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
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
    [self checkCookie];
}

- (void)viewWillAppear:(BOOL)animated {
    //重新加载网页，因为个人中心页复用了这个webview
    [self.webView reload];
    //隐藏掉状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:TRUE];
    //隐藏掉导航栏
    self.navigationController.navigationBarHidden = YES;
    
    

    //判断，书籍详情页也复用了这个controller,详情页中不需要隐藏tabbar
    if ([self.flag isEqualToString:@"discovery"]) {
        //
        self.tabBarController.tabBar.hidden = NO;
        
    }
    else {
        //个人中心页和看书页都是需要隐藏掉tabbar
        self.tabBarController.tabBar.hidden = YES;
        CGRect rect = [[UIScreen mainScreen] bounds];
        self.webView.frame = CGRectMake(0,0, self.view.frame.size.width, rect.size.height);
    }
    
    
    
}

- (void)viewWillDisappear:(BOOL)animated {
    self.tabBarController.tabBar.hidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    /*
    NSLog(@"RenderKnowledgeViewController didReceiveMemoryWarning");
    
    if (self.isViewLoaded && self.view.window == nil) {
        self.view = nil;
        NSLog(@"RenderKnowledgeViewController warning");
    }
     */
}

#pragma mark - init

- (BOOL)initWebView {
    //    self.webView.delegate = self.javascriptBridge;
    
    // goback()
    [self.javascriptBridge registerHandler:@"goBack" handler:^(id data, WVJBResponseCallback responseCallback) {
        LogDebug(@"RenderKnowledgeViewController::goBack() called: %@", data);
        
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    //share app
    [self.javascriptBridge registerHandler:@"share" handler:^(id data, WVJBResponseCallback responseCallback) {
        LogDebug(@"RenderKnowledgeViewController::share() called: %@", data);
        
        NSDictionary *shareDic = (NSDictionary *)data;
        
        [self share:shareDic];
    }];
    
    // playVideo()
    [self.javascriptBridge registerHandler:@"playVideo" handler:^(id dataId, WVJBResponseCallback responseCallback) {
        LogDebug(@"RenderKnowledgeViewController::playVideo() called: %@", dataId);
        
        NSString *urlStr = (NSString *)dataId;
        [self playVideo:urlStr];
    }];
    
    //change Background
    [self.javascriptBridge registerHandler:@"setStatusBarBackground" handler:^(id data, WVJBResponseCallback responseCallback) {
        [self changeBackgourndColorWithColor:data];
    }];
    
    
    //js要求跳到新的页面时，调到这个里面：
    //getData      ********     *********
    [self.javascriptBridge registerHandler:@"getData" handler:^(id data,WVJBResponseCallback responseCallback){
        LogDebug(@"RenderKnowledgeViewController::getData() called: %@", data);
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
        LogDebug(@"RenderKnowledgeViewController::renderPage() called: %@", data);
        SBJsonParser *parse = [[SBJsonParser alloc] init];
        NSDictionary *dic = [parse objectWithString:data];
        [self showPageWithDictionary:dic];
        
    }];
    //getCurStudyType
    [self.javascriptBridge registerHandler:@"getCurStudyType" handler:^(id data ,WVJBResponseCallback responseCallback){
        //在nsuserDefault中设置一个curStudyType字段，用来存储当前用户的学习状态
        LogDebug(@"RenderKnowledgeViewController::getCurStudyType() called: %@", data);
        if (responseCallback != nil) {
            NSString *data =nil;
            NSString *curStudyType = [NSUserDefaultUtil getCurStudyType];
            if (curStudyType != nil && curStudyType.length > 0) {
                data = curStudyType;
                
                responseCallback(data);
            }
        }
        
    }];
    
    //setCurStudyType
    [self.javascriptBridge registerHandler:@"setCurStudyType" handler:^(id data,WVJBResponseCallback responseCallback){
        LogDebug(@"RenderKnowledgeViewController::setCurStudyType() called: %@", data);
        NSString *curStudyType = data;
        if (curStudyType != nil && curStudyType.length > 0) {
            BOOL isSuccess = [NSUserDefaultUtil setCurStudyTypeWithType:curStudyType];
            if (isSuccess) {
                NSString *data = @"1";
                responseCallback(data);
            }
            else {
                NSString *data = @"0";
                responseCallback(data);
            }
            
        }
        else {
            LogError(@"RenderKnowledgeViewController::setCurStudyType() failed because of curStudyType is equal to nil");
            NSString *data = @"0";
            responseCallback(data);//失败返回0；
        }
        
    }];
    
    //getBookList
    [self.javascriptBridge registerHandler:@"getBookList" handler:^(id data,WVJBResponseCallback responseCallback){
        LogDebug(@"RenderKnowledgeViewController::getBookList() called: %@", data);
        NSString *book_category = data;//值：0，1
        
        
        
        
    }];
    
    //checkUpdate
    [self.javascriptBridge registerHandler:@"checkUpdate" handler:^(id data,WVJBResponseCallback responseCallback){
        LogDebug(@"RenderKnowledgeViewController::checkUpdate() called: %@", data);
        NSString *book_category = data;//值：0，1 还需要分类型吗？
        //检查某类书籍是否有更新，需要从数据库中查找（方法：1、获取更新数据的版本文件 2、把是否有更新的信息存储到数据库中，只需要返回给js是否开始检查的通知即可，不需要检查更新的结果给JS）。
        //返回0，1
        BOOL isStart = NO;
        {
            dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[KnowledgeManager instance] getUpdateInfoFileFromServerAndUpdateDataBase];
            });
            isStart = YES;
        }
        if (responseCallback != nil) {
            if (isStart) {
                responseCallback(@"1");
            }
            else {
                responseCallback(@"0");
            }
        }
    }];
    
    //startDownload
    [self.javascriptBridge registerHandler:@"startDownload" handler:^(id data, WVJBResponseCallback responseCallback) {
        LogDebug(@"RenderKnowledgeViewController::startDownload() called: %@", data);
        NSString *book_id = data;
        NSLog(@"调了=====%@",book_id);
        //下载的过程就是只有一步，拿到data_id后直接开始下载。（具体操作：1、根据book_id去下载 2、将下载的进度实时存到数据库中即可，不需要做读取的操作，也不需要将进度返回给JS。只需要告诉JS是否已经开始下载）。
        BOOL isStart = NO;
        {
            dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                BOOL ret = [[KnowledgeManager instance] startDownloadDataManagerWithDataId:book_id];
            });
            isStart = YES;
        }
        if (responseCallback != nil) {
            if (isStart) {
                responseCallback(@"1");
            }
            else {
                responseCallback(@"0");
            }
        }
        
        
    }];
    
    //queryBookStatus
    [self.javascriptBridge registerHandler:@"queryBookStatus" handler:^(id data, WVJBResponseCallback responseCallback) {
        LogDebug(@"RenderKnowledgeViewController::queryBookStatus() called: %@", data);
        
        SBJsonParser *parse = [[SBJsonParser alloc] init];
        NSArray *book_ids = [parse objectWithString:data];
        NSLog(@"queryBookStatus 接口的返回值是%@",data);
        //操作：遍历获取到的book_id数组
        //根据book_ids来获取下载进度，需要从数据库中取到，（具体操作：1、根据book_id对数据库做读取操作 2、返回结果是一个json，其中downLoad_status需要返回汉字）。
        NSMutableArray *booksArray = [NSMutableArray array];
        for (NSString *bookId in book_ids) {
            if (bookId ==nil) {
                continue;
            }
            //根据book_id从数据库中取相应的状态
            NSMutableDictionary *dic = [self getDicFormDataBase:bookId];
            if(dic == nil) {
                continue;
            }
            [booksArray addObject:dic];
        }
        //返回的是数组类型的值，即使是空数组也要解析一下
        SBJsonWriter *writer = [[SBJsonWriter alloc] init];
        NSString *jsonStr = [writer stringWithObject:booksArray];
        if (responseCallback != nil) {
            responseCallback(jsonStr);
        }
        
        
        
    }];
    //goUserSettingPage
    [self.javascriptBridge registerHandler:@"goUserSettingPage" handler:^(id data, WVJBResponseCallback responseCallback) {
        //跳转到设置页面
    }];
    //goDiscoverPage
    [self.javascriptBridge registerHandler:@"goDiscoverPage" handler:^(id data, WVJBResponseCallback responseCallback) {
        //跳转到发现页
    }];
    //getCoverSrc
    [self.javascriptBridge registerHandler:@"getCoverSrc" handler:^(id data, WVJBResponseCallback responseCallback) {
        //获取封面
        NSString *book_id = data;
        if (responseCallback != nil) {
            /*
            NSString *imageStr = [self getImage];
            responseCallback(imageStr);
             */
        }
        
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
    
    //addToNative  
    [self.javascriptBridge registerHandler:@"addToNative" handler:^(id data, WVJBResponseCallback responseCallback) {
        /*
            1先调queryBookStatus接口，检查本地是否有这本书。（若是本地没有该书的记录，返回空数组）
            2若是没有则掉addToNative接口
         */
        NSString *bookID = data;
        //异步请求
        discoveryModel *model = [[discoveryModel alloc] init];
        NSArray *arr = [NSArray arrayWithObjects:bookID, nil];
        BOOL isSuccess =  [model getBookInfoWithDataIds:arr];

        if (responseCallback != nil) {
            if (isSuccess) {
                responseCallback(@"1");
            }
            else {
                responseCallback(@"0");
            }
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

#pragma mark 2.0调用的接口
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
//            return [self showSafeURL:urlStrWithParams];
            //读书使用单独的两个页面
            return [self readBookWithSafeUrl:urlStrWithParams];
        }
    }
    
    return YES;
    
}

//看书的页面使用单独的controller,不再使用上面的方法
- (BOOL)readBookWithSafeUrl:(NSString *)urlStr {
    FirstReuseViewController *first = [[FirstReuseViewController alloc] init];
    first.webUrl = urlStr;
    [self.navigationController pushViewController:first animated:YES];
    return YES;
}


//在线网页接口showUrl 调用的接口
- (BOOL)showSafeURL:(NSString *)urlStr {
    
    SecondRenderKnowledgeViewController *secondRender = [[SecondRenderKnowledgeViewController alloc] init];
    secondRender.webUrl = urlStr;
    secondRender.flag = self.flag;
    [self.navigationController pushViewController:secondRender animated:YES];
    
    return YES;
}





- (BOOL)updateWebView {
    NSURL *Url = [NSURL URLWithString:self.webUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:Url];
    
    [self.webView loadRequest:request];
    
    return YES;
}

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
        LogDebug(@"[RenderKnowledgeViewController] Web request: UA: %@", [request valueForHTTPHeaderField:@"User-Agent"]);
    }
//    [self injectJSToWebView:webView];
    NSLog(@" url === %@",request.URL);
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

#pragma mark - set User Agent

- (BOOL)checkUserAgent {
    return [WebUtil checkUserAgent];
}


#pragma  mark test changeColor
-(void)changeBackgourndColorWithColor:(NSString *)colorString
{
    self.view.backgroundColor = [UIColor colorWithHexString:colorString alpha:1];
}

#pragma   mark get session
- (void)checkCookie {
    [OperateCookie checkCookie];
}


#pragma mark getknowledgeMeta
//get dic :{book_id, book_status, book_status_detail}
- (NSMutableDictionary *)getDicFormDataBase:(NSString *)bookId {
    //限制dataType
    NSArray *bookArr = [[KnowledgeMetaManager instance] getKnowledgeMetaWithDataId:bookId andDataType:DATA_TYPE_DATA_SOURCE];
    
//    NSArray *bookArr = [[KnowledgeMetaManager instance] getKnowledgeMetaWithDataId:bookId];
    
    
    //1 数据库中没有bookId对应的记录，返回nil
    if (bookArr == nil || bookArr.count <= 0) {
        return nil;
    }
    //2 从数据库中查到对应的字段
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for (NSManagedObject *entity in bookArr) {
        if (entity == nil) {
            continue;
        }
        NSString *dicBookId = [entity valueForKey:@"dataId"];
        NSNumber *dicBookStatusNum = [entity valueForKey:@"dataStatus"];
        int bookStatusInt = [dicBookStatusNum intValue];
        NSString *bookStatusStr = nil;
        NSString *downLoadStatus = nil;//该状态暂时未设置
        
         if (bookStatusInt >= 1 && bookStatusInt <= 3) {
         bookStatusStr = @"下载中";
         }
         else if (bookStatusInt == 7) {
         bookStatusStr = @"可更新";
         }
         else if (bookStatusInt == 8 || bookStatusInt ==9) {
         bookStatusStr = @"更新中";
         }
         else if (bookStatusInt == 10) {
         bookStatusStr = @"完成";
         }
         else if (bookStatusInt == 11) {
         bookStatusStr = @"APP版本过低";
         }
         else if (bookStatusInt == 12) {
         bookStatusStr = @"APP版本过高";
         }
         else if (bookStatusInt == 14) {
         bookStatusStr = @"下载失败";
         }
         else if (bookStatusInt == 15) {
         bookStatusStr = @"下载暂停";
         }
         else if (bookStatusInt == -1  || bookStatusInt > 15) {
         bookStatusStr = @"未下载";
         }
        
        NSString *dicBookStatusDetails = [entity valueForKey:@"dataStatusDesc"];
        //将浮点型转换成integer型，再转换成字符串类型
        NSString *downLoadProgressStr = nil;
        CGFloat downLoadProgressFloat = [dicBookStatusDetails floatValue];
        if (downLoadProgressFloat == 100) {
             downLoadProgressStr = [NSString stringWithFormat:@"%@",@"100"];
        }
        else {
            NSInteger downLoadProgress = (NSInteger)(downLoadProgressFloat*100);
            downLoadProgressStr = [NSString stringWithFormat:@"%ld",(long)downLoadProgress];
        }
        
       
        //构造字典
        [dic setValue:dicBookId forKey:@"book_id"];
        [dic setValue:bookStatusStr forKey:@"book_status"];
        [dic setValue:downLoadProgressStr forKey:@"book_status_detail"];
       
        
        
    }
    
    return dic;
    
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


@end
