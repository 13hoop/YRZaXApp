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


@interface MatchViewController () <UIWebViewDelegate>

#pragma mark - properties
// bridge between webview and js
@property (nonatomic, strong) WebViewJavascriptBridge *javascriptBridge;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSString *oldUserAgent;



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
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
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
    
    WebViewBridgeRegisterUtil *webviewBridgeUtil = [[WebViewBridgeRegisterUtil alloc] init];
    webviewBridgeUtil.webView = self.webView;
    webviewBridgeUtil.controller = self;
    webviewBridgeUtil.mainControllerView = self.view;
    webviewBridgeUtil.navigationController = self.navigationController;
    webviewBridgeUtil.tabBarController = self.tabBarController;
    [webviewBridgeUtil initWebView];
    
    if ([self.shouldChangeBackground isEqualToString:@"needChange"]) {
        self.view.backgroundColor=[UIColor colorWithHexString:@"#242021" alpha:1];
    }
    else {
        self.view.backgroundColor = [UIColor colorWithHexString:@"#4C501D" alpha:1];
    }
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.webView.scrollView.bounces = NO;
    self.webView.scrollView.showsVerticalScrollIndicator = NO;
  

    [self updateWebView];
    [self checkCookie];
}

- (void)viewWillAppear:(BOOL)animated {

    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.navigationController.navigationBarHidden = YES;
    [self.webView reload];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"WARNING" message:@"MemoryWarning,Please release memory immediately" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"ok", nil];
    [alert show];
    
}


#pragma mark - init

- (BOOL)initWebView {
//    self.webView.delegate = self.javascriptBridge;
    
    // goback()
    [self.javascriptBridge registerHandler:@"goBack" handler:^(id data, WVJBResponseCallback responseCallback) {
        LogDebug(@"MatchViewController::goBack() called: %@", data);

        [self.navigationController popViewControllerAnimated:YES];
    }];
    //share
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
    
    //change Background
    [self.javascriptBridge registerHandler:@"setStatusBarBackground" handler:^(id data, WVJBResponseCallback responseCallback) {
        [self changeBackgourndColorWithColor:data];
    }];
    
    
    //js要求调到新的页面时，调到这个里面：
    //getData      ********     *********
    [self.javascriptBridge registerHandler:@"getData" handler:^(id data,WVJBResponseCallback responseCallback){
        LogDebug(@"MatchViewController::getData() called: %@", data);
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
        LogDebug(@"MatchViewController::renderPage() called: %@", data);
        SBJsonParser *parse = [[SBJsonParser alloc] init];
        NSDictionary *dic = [parse objectWithString:data];
        [self showPageWithDictionary:dic];
        
    }];
    
    // ******* set && get current user study type **********
    //getCurStudyType
    [self.javascriptBridge registerHandler:@"getCurStudyType" handler:^(id data ,WVJBResponseCallback responseCallback){
        //在nsuserDefault中设置一个curStudyType字段，用来存储当前用户的学习状态
        LogDebug(@"MatchViewController::getCurStudyType() called: %@", data);
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
        LogDebug(@"MatchViewController::setCurStudyType() called: %@", data);
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
            LogError(@"MatchViewController::setCurStudyType() failed because of curStudyType is equal to nil");
            NSString *data = @"0";
            responseCallback(data);//失败返回0；
        }
       
    }];
    
    //************ get book status **********
    //getBookList
    [self.javascriptBridge registerHandler:@"getBookList" handler:^(id data,WVJBResponseCallback responseCallback){
        LogDebug(@"MatchViewController::getBookList() called: %@", data);
        NSString *book_category = data;//值：0，1
        //根据book_category遍历数据库，将数据拼成json格式返回给JS。（具体操作：1、就是根据book_category做遍历数据库的操作 2、book_status ：下载过程中用的download_Status字段（下载成功，下载失败，下载中）也是修改这个字段。）
        
        NSMutableArray *arr = [NSMutableArray array];
        NSArray *bookListArr = [[KnowledgeManager instance] getBookList:book_category];
        if (bookListArr != nil || bookListArr.count > 0) {
            //
            arr = (NSMutableArray *)bookListArr;
        }
        SBJsonWriter *writer = [[SBJsonWriter alloc] init];
        NSString *string = [writer stringWithObject:arr];
        NSLog(@"%@",string);
        
        if (responseCallback != nil) {
            responseCallback(string);//getBookList和queryBookStatus若是数组为空，都必须返回“[]”,格式字符串否则解析JS失败。
        }
        

        
    }];
    
    //checkUpdate
    [self.javascriptBridge registerHandler:@"checkUpdate" handler:^(id data,WVJBResponseCallback responseCallback){
        LogDebug(@"MatchViewController::checkUpdate() called: %@", data);
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
        LogDebug(@"MatchViewController::startDownload() called: %@", data);
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
        LogDebug(@"MatchViewController::startDownload() called: %@", data);
        
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
                //根据book_id从数据库中去相应的状态
                NSMutableDictionary *dic = [self getDicFormDataBase:bookId];
                [booksArray addObject:dic];
            }
        SBJsonWriter *writer = [[SBJsonWriter alloc] init];
        NSString *jsonStr = [writer stringWithObject:booksArray];
        if (responseCallback != nil) {
            responseCallback(jsonStr);
        }
        
       
        
    }];
    //goUserSettingPage
    [self.javascriptBridge registerHandler:@"goUserSettingPage" handler:^(id data, WVJBResponseCallback responseCallback) {
        //跳转到设置页面
        RenderKnowledgeViewController *render = [[RenderKnowledgeViewController alloc] init];
        NSString *bundlePath = [PathUtil getBundlePath];
         NSString *userCenterUrlStrWithParams = [NSString stringWithFormat:@"%@/%@/%@/%@", bundlePath, @"assets",@"native-html",@"user_center.html"];
        render.webUrl = userCenterUrlStrWithParams;
        [self.navigationController pushViewController:render animated:YES];
        
    }];
    //goDiscoverPage
    [self.javascriptBridge registerHandler:@"goDiscoverPage" handler:^(id data, WVJBResponseCallback responseCallback) {
        //跳转到发现页
        self.tabBarController.selectedIndex = 1;
    }];
    //getCoverSrc
    [self.javascriptBridge registerHandler:@"getCoverSrc" handler:^(id data, WVJBResponseCallback responseCallback) {
        //获取封面
        NSString *book_id = data;
        if (responseCallback != nil) {
            NSString *partialPathInSandBox = [self getCoverImageFilePath:book_id];
            NSString *documentPath = [PathUtil getDocumentsPath];
            NSString *coverImagePathStr = [NSString stringWithFormat:@"%@/%@",documentPath,partialPathInSandBox];
            LogInfo(@"=======封面的URL====%@",coverImagePathStr);
            responseCallback(coverImagePathStr);
        }
        //
    }];
    //
    
    
    
    
    
    
    
    
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

//看书时，新开一个controller 
- (BOOL)readBookWithSafeUrl:(NSString *)urlStr {
    FirstReuseViewController *first = [[FirstReuseViewController alloc] init];
    first.webUrl = urlStr;
    [self.navigationController pushViewController:first animated:YES];
    return YES;
}



//2.0中打开在线的webView, 并跳转到指定的url
- (BOOL)showSafeURL:(NSString *)urlStr {
    
    RenderKnowledgeViewController *render = [[RenderKnowledgeViewController alloc] init];
    render.webUrl = urlStr;
    [self.navigationController pushViewController:render animated:YES];
    return YES;
}



- (BOOL)goUserCenterWithUrl:(NSString *)urlStr {
    RenderKnowledgeViewController *render = [[RenderKnowledgeViewController alloc] init];
    render.webUrl = urlStr;
    [self.navigationController pushViewController:render animated:YES];
    return YES;
}

- (BOOL)updateWebView {
    NSString *studyType = [NSUserDefaultUtil getCurStudyType];
    NSString *bundlePath = [PathUtil getBundlePath];
    NSString *myBagUrlStrWithParams = [NSString stringWithFormat:@"%@/%@/%@/%@%@%@", bundlePath, @"assets",@"native-html",@"schoolbag.html",@"?study_type=",studyType];
    NSURL *myBagUrl = [NSURL URLWithString:myBagUrlStrWithParams];
    NSURLRequest *request = [NSURLRequest requestWithURL:myBagUrl];
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

#pragma mark - set User Agent

- (BOOL)checkUserAgent {
    return [WebUtil checkUserAgent];
}


#pragma test changeColor
-(void)changeBackgourndColorWithColor:(NSString *)colorString
{
    self.view.backgroundColor = [UIColor colorWithHexString:colorString alpha:1];
}

#pragma  get session
- (void)checkCookie {
    [OperateCookie checkCookie];
}



- (void)justForMoreDownloadTest {
    KnowledgeManager *manager = [KnowledgeManager instance];
    NSArray *book_ids = [NSArray arrayWithObjects:@"test_book_4",@"test_book_5",@"test_book_6", nil];
    for (int i =0; i<3; i++) {
        [manager startDownloadDataManagerWithDataId:[book_ids objectAtIndex:i]];
    }
}
- (NSString *)fileToJsonString {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"book-list-json-2" ofType:@"json"];
    NSFileHandle *fileHandler = [NSFileHandle fileHandleForReadingAtPath:filePath];
    NSData *data = [fileHandler readDataToEndOfFile];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    SBJsonParser *parse = [[SBJsonParser alloc] init];
    NSArray *arr = [parse objectWithString:string];

    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSString *jsonString = [writer stringWithObject:arr];
//    NSLog(@"%@",jsonString);
    return jsonString;
}

- (NSString *)getImage {
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"封面图片-2-base64" ofType:@"txt"];
    NSString *imageStr = [[NSString alloc] initWithContentsOfFile:imagePath encoding:NSUTF8StringEncoding error:nil];
    return imageStr;
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


#pragma mark get cover image filePath

- (NSString *)getCoverImageFilePath:(NSString *)dataId {
    //从db中获取书分封面图片信息不能限定dataType
    NSArray *bookArr = [[KnowledgeMetaManager instance] getKnowledgeMetaWithDataId:dataId andDataType:DATA_TYPE_DATA_SOURCE];
//    NSArray *bookArr = [[KnowledgeMetaManager instance] getKnowledgeMetaWithDataId:dataId];
    NSString *coverSrc = nil;
    for (NSManagedObject *entity in bookArr) {
        if (entity == nil) {
            continue;
        }
         coverSrc = [entity valueForKey:@"coverSrc"];
        if (coverSrc == nil) {
            LogInfo(@"[ MatchViewController - getConverImageFilePath ]:get coverImage failed because of coverImage url is nil");
            return nil;
        }
    }
    return coverSrc;
}




 


@end
