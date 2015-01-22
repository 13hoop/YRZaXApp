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

//@synthesize webUrl = _webUrl;
//@synthesize webView = _webView;
//@synthesize javascriptBridge = _javascriptBridge;


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

#pragma mark - app life

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [CustomURLProtocol register];
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - init

- (BOOL)initWebView {
//    self.webView.delegate = self.javascriptBridge;
    
    // goback()
    [self.javascriptBridge registerHandler:@"goBack" handler:^(id data, WVJBResponseCallback responseCallback) {
        LogDebug(@"MatchViewController::goBack() called: %@", data);

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
    
    //change Background
    [self.javascriptBridge registerHandler:@"setStatusBarBackground" handler:^(id data, WVJBResponseCallback responseCallback) {
        [self changeBackgourndColorWithColor:data];
    }];
    
    
    //js要求调到新的页面时，调到这个里面：
    //getData      ********     *********
    [self.javascriptBridge registerHandler:@"getData" handler:^(id data,WVJBResponseCallback responseCallback){
        LogDebug(@"KnowledgeWebViewController::getData() called: %@", data);
        NSString *dataId = [data objectForKey:@"bookID"];
        NSString *queryId = [data objectForKey:@"queryID"];
        
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
        LogDebug(@"KnowledgeWebViewController::renderPage() called: %@", data);
        NSError *error = nil;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithStream:data options:0 error:&error];
        if (error) {
            NSLog(@"error======%@",error);
        }
        [self showPageWithDictionary:dic];
        
    }];
    //getCurStudyType
    [self.javascriptBridge registerHandler:@"getCurStudyType" handler:^(id data ,WVJBResponseCallback responseCallback){
        //在nsuserDefault中设置一个curStudyType字段，用来存储当前用户的学习状态
        LogDebug(@"KnowledgeWebViewController::getCurStudyType() called: %@", data);
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
        LogDebug(@"KnowledgeWebViewController::setCurStudyType() called: %@", data);
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
            LogError(@"KnowledgeWebViewController::setCurStudyType() failed because of curStudyType is equal to nil");
            NSString *data = @"0";
            responseCallback(data);//失败返回0；
        }
       
    }];
    
    //getBookList
    [self.javascriptBridge registerHandler:@"getBookList" handler:^(id data,WVJBResponseCallback responseCallback){
        LogDebug(@"KnowledgeWebViewController::getBookList() called: %@", data);
        NSString *book_category = data;//值：0，1
        //根据book_category遍历数据库，将数据拼成json格式返回给JS。（具体操作：1、就是根据book_category做遍历数据库的操作 2、book_status ：下载过程中用的download_Status字段（下载成功，下载失败，下载中）也是修改这个字段。）
        NSLog(@"调用getBooklist了，js注入成功了");
//         [self justForTest];
//        [self justForMoreDownloadTest];
        NSString *string = [self fileToJsonString];
        if (responseCallback != nil) {
            responseCallback(string);
        }
        

        
    }];
    
    //checkUpdate
    [self.javascriptBridge registerHandler:@"checkUpdate" handler:^(id data,WVJBResponseCallback responseCallback){
        LogDebug(@"KnowledgeWebViewController::checkUpdate() called: %@", data);
        NSString *book_category = data;//值：0，1
        //检查某类书籍是否有更新，需要从数据库中查找（方法：1、获取更新数据的版本文件 2、把是否有更新的信息存储到数据库中，只需要返回给js是否开始检查的通知即可，不需要检查更新的结果给JS）。
        //返回0，1
        
        
    }];
    
    //startDownload
    [self.javascriptBridge registerHandler:@"startDownload" handler:^(id data, WVJBResponseCallback responseCallback) {
        LogDebug(@"KnowledgeWebViewController::startDownload() called: %@", data);
                [self output];
        NSString *book_id = data;
        //下载的过程就是只有一步，拿到data_id后直接开始下载。（具体操作：1、根据book_id去下载 2、将下载的进度实时存到数据库中即可，不需要做读取的操作，也不需要将进度返回给JS。只需要告诉JS是否已经开始下载）。
        
    }];
    
    //queryDownloadProgress
    [self.javascriptBridge registerHandler:@"queryDownloadProgress" handler:^(id data, WVJBResponseCallback responseCallback) {
        LogDebug(@"KnowledgeWebViewController::startDownload() called: %@", data);
        NSError *error = nil;
        NSArray *book_ids = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        //操作：遍历获取到的book_id数组
        //根据book_ids来获取下载进度，需要从数据库中取到，（具体操作：1、根据book_id对数据库做读取操作 2、返回结果是一个json，其中downLoad_status需要设计具体有哪些状态）。
        
        
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
        //跳转到发现页
    }];
    
    
    
    
    return YES;
}
-(void)output {
    NSLog(@"调了，调了");
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
        NSString *args = dic[@"getArgs"];
        
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
            NSURL *url = [[NSURL alloc] initFileURLWithPath:[NSString stringWithFormat:@"%@/%@/%@", htmlFilePath,page_type, @".html"]];
            
            NSString *urlStrWithParams = nil;
            NSString *args = dic[@"getArgs"];
            if (args != nil && args.length > 0) {
                urlStrWithParams = [NSString stringWithFormat:@"%@?%@", [url absoluteString], args];
            }
            else {
                urlStrWithParams = [NSString stringWithFormat:@"%@", [url absoluteString]];
                
            }
            //打开新的controller
            return [self showSafeURL:urlStrWithParams];
            
        }
    }
    
    return YES;
    
}
//2.0中打开新的webView, 并跳转到指定的url
- (BOOL)showSafeURL:(NSString *)urlStr {
    //    NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    /*
     复用knowledgeWebViewcontroller 和MatchViewController,需要重复包含头文件，问题：
        同一个类的不同对象，同时扔到nav管理的栈中，会报错？
     */
    KnowledgeWebViewController *knowLedge = [[KnowledgeWebViewController alloc] init];
    knowLedge.webURLStr = urlStr;
    [self.navigationController pushViewController:knowLedge animated:YES];
    
    return YES;
}


- (BOOL)updateWebView {
    // 在加载loadRuquest之前设置userAgent
//    [self checkUserAgent];
    
    // load url
    //    self.webUrl=@"http://pk2015.zaxue100.com"; // test
    NSString *bundlePath = [PathUtil getBundlePath];
    NSString *myBagUrlStrWithParams = [NSString stringWithFormat:@"%@/%@/%@/%@%@", bundlePath, @"assets",@"native-html",@"schoolbag.html",@"?study_type=1"];
    NSLog(@"要显示的本地html链接是%@",myBagUrlStrWithParams);
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


#pragma test changeColor
-(void)changeBackgourndColorWithColor:(NSString *)colorString
{
    self.view.backgroundColor = [UIColor colorWithHexString:colorString alpha:1];
}

#pragma  get session
- (void)checkCookie {
    [OperateCookie checkCookie];
}

#pragma mark test
- (void)justForTest {
    KnowledgeManager *manager = [KnowledgeManager instance];
    [manager getUpdateInfoFileFromServerAndUpdateDataBase];
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
//    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//    string = [string stringByReplacingOccurrencesOfString:@"\r" withString:@""];
//    NSMutableArray *array = [[NSMutableArray alloc]initWithCapacity:0];
//    NSDictionary *dic  = [NSJSONSerialization JSONObjectWithData:(NSData *)string options:NSJSONReadingMutableLeaves error:nil];
//    NSArray *arr = [dic objectForKey:@"people"];
    SBJsonParser *parse = [[SBJsonParser alloc] init];
    NSArray *arr = [parse objectWithString:string];
//    NSLog(@"%@",arr);
//    NSLog(@"array === %@",jsonObject);
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSString *jsonString = [writer stringWithObject:arr];
    NSLog(@"%@",jsonString);
    return jsonString;
}

@end
