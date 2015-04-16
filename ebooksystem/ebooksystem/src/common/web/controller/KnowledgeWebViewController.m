//
//  CommonWebViewController.m
//  ebooksystem
//
//  Created by zhenghao on 10/8/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "KnowledgeWebViewController.h"

#import "Config.h"

#import "KnowledgeSubject.h"

#import "KnowledgeManager.h"
#import "StatisticsManager.h"

//#import <MediaPlayer/MediaPlayer.h>
#import "DirectionMPMoviePlayerViewController.h"

#import "MoreViewController.h"

#import "WebViewJavascriptBridge.h"

#import "LogUtil.h"
#import "DeviceUtil.h"


#import "StatisticsManager.h"
#import "UpdateManager.h"

#import "MatchViewController.h"

#import "UIColor+Hex.h"
#import "NSUserDefaultUtil.h"
#import "PathUtil.h"


@interface KnowledgeWebViewController () <UIWebViewDelegate, UpdateManagerDelegate, UIAlertViewDelegate>

#pragma mark - outlets
@property (strong, nonatomic) IBOutlet UIWebView *webView;

#pragma mark - properties
// bridge between webview and js
@property (nonatomic, copy) WebViewJavascriptBridge *javascriptBridge;

@property(nonatomic,strong)NSString *updateAppURL;

#pragma mark - methods
// 初始化webView
- (BOOL)initWebView;

// 更新webview
- (BOOL)updateWebView;

// update navigation bar
- (void)updateNavigationBar;

// 跳转到指定的页面
- (BOOL)showPageWithPageId:(NSString *)pageId andArgs:(NSString *)args;
// 跳转到指定的url
- (BOOL)showPageWithURL:(NSString *)urlStr;
// 打开新的webView, 并跳转到指定的url
- (BOOL)showSafeURL:(NSString *)urlStr;

// 视频播放开始
- (void)playVideo:(NSString *)urlStr;
// 视频播放结束
- (void)movieFinishedCallback:(NSNotification*) aNotification;

// 延迟执行
- (void)performBlock:(void(^)())block afterDelay:(NSTimeInterval)delay;


@end




@implementation KnowledgeWebViewController

@synthesize javascriptBridge = _javascriptBridge;

//@synthesize knowledgeSubject = _knowledgeSubject;
@synthesize pageId = _pageId;


#pragma mark - properties
// bridge between webview and js
- (WebViewJavascriptBridge *)javascriptBridge {
    if (_javascriptBridge == nil) {
        _javascriptBridge = [WebViewJavascriptBridge bridgeForWebView:self.webView
                                                    handler:^(id data, WVJBResponseCallback responseCallback) {
                                                        LogDebug(@"Received message from javascript: %@", data);
                                                        responseCallback(@"'response data from obj-c'");
                                                    }];
//        [self initWebView];
    }
    
    return _javascriptBridge;
}

//- (void)setKnowledgeSubject:(KnowledgeSubject *)knowledgeSubject {
//    _knowledgeSubject = knowledgeSubject;
//}


#pragma mark - app life
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor colorWithHexString:@"#242021" alpha:1];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initWebView];
    [self updateWebView];
    [self updateApp];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateNavigationBar];
    
    // 友盟统计
    [[StatisticsManager instance] beginLogPageView:@"KnowledgeWebViewController"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // 友盟统计
    [[StatisticsManager instance] endLogPageView:@"KnowledgeWebViewController"];
}



#pragma mark - ui related methods
// update navigation bar
- (void)updateNavigationBar {
    self.navigationController.navigationBarHidden = YES;
}

#pragma mark - web view methods
- (BOOL)initWebView {
//    self.webView.delegate = self.javascriptBridge;
    
    // 注册obj-c方法, 供js调用
    // test method
    [self.javascriptBridge registerHandler:@"testObjCCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
        LogDebug(@"KnowledgeWebViewController::testObjcCallback() called: %@", data);
        
        if (responseCallback != nil) {
            responseCallback(@"Response from testObjcCallback");
        }
    }];
    
    // goBack()
    [self.javascriptBridge registerHandler:@"goBack" handler:^(id data, WVJBResponseCallback responseCallback) {
        LogDebug(@"KnowledgeWebViewController::goBack() called: %@", data);
        [self.webView goBack];
//        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    // showMenu()
    [self.javascriptBridge registerHandler:@"showMenu" handler:^(id data, WVJBResponseCallback responseCallback) {
        LogDebug(@"KnowledgeWebViewController::showMenu() called: %@", data);
        
        // native menu
        MoreViewController *more = [[MoreViewController alloc] init];
        [self.navigationController pushViewController:more animated:YES];
    }];
    
    // getNodeDataById()
    // deprecated: 读取数据, 非index方式
    [self.javascriptBridge registerHandler:@"getNodeDataById" handler:^(id dataId, WVJBResponseCallback responseCallback) {
        LogDebug(@"KnowledgeWebViewController::getNodeDataById() called: %@", dataId);
        
        if (responseCallback != nil) {
            NSString *data = [[KnowledgeManager instance] getLocalData:dataId];
            responseCallback(data);
        }
    }];
    
    // getNodeDataByIdAndQueryId()
    // 读取数据, index方式
    [self.javascriptBridge registerHandler:@"getNodeDataByIdAndQueryId" handler:^(id data, WVJBResponseCallback responseCallback) {
        LogDebug(@"KnowledgeWebViewController::getNodeDataByIdAndQueryId() called: %@", data);
        
        NSString *dataId = [data objectForKey:@"dataId"];
        NSString *queryId = [data objectForKey:@"queryId"];
        NSString *indexFilename = [data objectForKey:@"indexFilename"];
        
        if (responseCallback != nil) {
            NSArray *dataArray = [[KnowledgeManager instance] getLocalDataWithDataId:dataId andQueryId:queryId andIndexFilename:indexFilename];
//            LogDebug(@"====dataArray: %@", dataArray);
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
//        [self showPageWithDictionary:dic];
        
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
        NSString *curStudyType = [data objectForKey:@"studyType"];
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
        NSString *book_category = [data objectForKey:@"book_category"];//值：0，1
        //根据book_category遍历数据库，将数据平成json格式返回给JS
        

    }];
    
    //checkUpdate
    [self.javascriptBridge registerHandler:@"checkUpdate" handler:^(id data,WVJBResponseCallback responseCallback){
        LogDebug(@"KnowledgeWebViewController::checkUpdate() called: %@", data);
        NSString *book_category = [data objectForKey:@"book_category"];//值：0，1
        //检查某类书籍是否有更新，需要从数据库中查找（方法：1、先进行更新的两步，把更新记录到数据库中 2、根据dataStatus和book_category来遍历数据库）
        //返回0，1
        

    }];
    
    //startDownload
    [self.javascriptBridge registerHandler:@"startDownload" handler:^(id data, WVJBResponseCallback responseCallback) {
        LogDebug(@"KnowledgeWebViewController::startDownload() called: %@", data);
        NSString *book_id = [data objectForKey:@"book_id"];
        
        
    }];
    
    //queryDownloadProgress
    [self.javascriptBridge registerHandler:@"queryDownloadProgress" handler:^(id data, WVJBResponseCallback responseCallback) {
        LogDebug(@"KnowledgeWebViewController::startDownload() called: %@", data);
        NSArray *book_ids = [data objectForKey:@"book_ids"];
        //根据book_ids来获取下载进度，需要从数据库中去，（一开始下载就要将进度写到数据库中，然后就开始读）
        
    }];
    
    
    
    
    // searchData()
    [self.javascriptBridge registerHandler:@"searchData" handler:^(id data, WVJBResponseCallback responseCallback) {
        LogDebug(@"KnowledgeWebViewController::searchData() called: %@", data);
        
        NSString *searchId = (NSString *)data;
        
        if (responseCallback != nil) {
            NSString *data = [[KnowledgeManager instance] searchLocalData:searchId];
            responseCallback(data);
        }
    }];
    
    // hasNodeDownloaded()
    [self.javascriptBridge registerHandler:@"hasNodeDownloaded" handler:^(id dataId, WVJBResponseCallback responseCallback) {
        LogDebug(@"KnowledgeWebViewController::hasNodeDownloaded() called: %@", dataId);
        
        NSString *pagePath = [[KnowledgeManager instance] getPagePath:dataId];
        BOOL downloaded = (pagePath == nil || pagePath.length <= 0 ? NO : YES);
        
        if (responseCallback != nil) {
            responseCallback(downloaded ? @"1" : @"0");
        }
    }];
    
    // tryDownloadNodeById()
    [self.javascriptBridge registerHandler:@"tryDownloadNodeById" handler:^(id dataId, WVJBResponseCallback responseCallback) {
        LogDebug(@"KnowledgeWebViewController::tryDownloadNodeById() called: %@", dataId);
        
        [[KnowledgeManager instance] getRemoteData:dataId];
        
        if (responseCallback != nil) {
        }
    }];
    
    // getDataStatus()
    [self.javascriptBridge registerHandler:@"getDataStatus" handler:^(id dataId, WVJBResponseCallback responseCallback) {
        LogDebug(@"KnowledgeWebViewController::getDataStatus() called: %@", dataId);
        
        if (responseCallback != nil) {
            // status##desc
            NSString *status = [[KnowledgeManager instance] getDataStatus:dataId];
            responseCallback(status);
        }
    }];
    
    // startCheckDataUpdate()
    [self.javascriptBridge registerHandler:@"startCheckDataUpdate" handler:^(id data, WVJBResponseCallback responseCallback) {
        LogDebug(@"KnowledgeWebViewController::startCheckDataUpdate() called: %@", data);
        
        [[KnowledgeManager instance] startCheckDataUpdate];
    }];
    
    // showPageById()
    [self.javascriptBridge registerHandler:@"showPageById" handler:^(id data, WVJBResponseCallback responseCallback) {
        LogDebug(@"KnowledgeWebViewController::showPageById() called: %@", data);
        
        NSString *pageID = [data objectForKey:@"pageID"];
        NSString *args = [data objectForKey:@"args"];
        NSDictionary *postArgsStr = [data objectForKey:@"postArgsStr"];
        
        [self showPageWithPageId:pageID andArgs:args];
    }];
    
    // showSafeURL()
    [self.javascriptBridge registerHandler:@"showSafeURL" handler:^(id dataId, WVJBResponseCallback responseCallback) {
        LogDebug(@"KnowledgeWebViewController::showSafeURL() called: %@", dataId);
        
        NSString *urlStr = (NSString *)dataId;
        [self showSafeURL:urlStr];
    }];
    
    // playVideo()
    [self.javascriptBridge registerHandler:@"playVideo" handler:^(id dataId, WVJBResponseCallback responseCallback) {
        LogDebug(@"CommonWebViewController::playVideo() called: %@", dataId);
        
        NSString *urlStr = (NSString *)dataId;
        [self playVideo:urlStr];
    }];
    
    // pageStatistic()
    [self.javascriptBridge registerHandler:@"pageStatistic" handler:^(id data, WVJBResponseCallback responseCallback) {
        LogDebug(@"KnowledgeWebViewController::pageStatistic() called: %@", data);
        
        NSString *eventName = [data objectForKey:@"eventName"];
        NSString *args = [data objectForKey:@"args"];
        
        [[StatisticsManager instance] event:eventName label:args];
    }];
    
    // 获取机器型号
    [self.javascriptBridge registerHandler:@"getDeviceModel" handler:^(id data, WVJBResponseCallback responseCallback) {
        LogDebug(@"KnowledgeWebViewController::getDeviceModel() called: %@", data);
        
        if (responseCallback) {
            NSString *model = [DeviceUtil getModel];
            responseCallback(model);
        }
    }];
    
    // 进入政治客观题大赛入口页
    [self.javascriptBridge registerHandler:@"showWebUrl" handler:^(id data, WVJBResponseCallback responseCallback) {
        LogDebug(@"KnowledgeWebViewController::showWebUrl() called: %@", data);
        
        NSString *webUrl = (NSString *)data;
        MatchViewController *match = [[MatchViewController alloc] init];
        match.webUrl = webUrl;
        
        [self.navigationController pushViewController:match animated:YES];
    }];
    
    
    // 发送消息给 html
    //    [self.javascriptBridge send:@"Well hello there"];
    //    [self.javascriptBridge send:[NSDictionary dictionaryWithObject:@"Foo" forKey:@"Bar"]];
    //    [self.javascriptBridge send:@"Give me a response, will you?" responseCallback:^(id responseData) {
    //        LogDebug(@"ObjC got its response! %@", responseData);
    //    }];
    
    // 调用js中的方法
//    [self.javascriptBridge callHandler:@"showAlert" data:@"alert message from oc"];
//    [self.javascriptBridge callHandler:@"getCurrentPageUrl" data:@"xxxx" responseCallback:^(id responseData){
//        LogDebug(@"ObjC got its response: %@", responseData);
//    }];
    
    return YES;
}

- (UIColor *)getColor:(NSString*)hexColor
{
    unsigned int red,green,blue;
    NSRange range;
    range.length = 2;
    
    range.location = 0;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]]scanHexInt:&red];
    
    range.location = 2;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]]scanHexInt:&green];
    
    range.location = 4;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]]scanHexInt:&blue];
    
    return [UIColor colorWithRed:(float)(red/255.0f)green:(float)(green / 255.0f) blue:(float)(blue / 255.0f)alpha:1.0f];
}

// 更新webview
- (BOOL)updateWebView {
    
    [((UIScrollView *)[self.webView.subviews objectAtIndex:0]) setShowsVerticalScrollIndicator:NO]; // 去除webView右侧垂直滚动条
    [((UIScrollView *)[self.webView.subviews objectAtIndex:0]) setBounces:NO];
    //2.0新开controller页面
    if (self.webURLStr !=nil && self.webURLStr.length >0) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.webURLStr]]];
        return YES;
    }
    
    if (self.pageId == nil) {
        return NO;
    }
    
    // 打开pageId对应的页面
    NSString *pagePath = [[KnowledgeManager instance] getPagePath:self.pageId];
    if (pagePath == nil || pagePath.length <= 0) {
        return NO;
    }
    // 加载指定的html文件
    NSURL *url = [[NSURL alloc] initFileURLWithPath:[NSString stringWithFormat:@"%@/%@", pagePath, @"index.html"]];
    
    NSString *urlStrWithParams = [NSString stringWithFormat:@"%@?page_id=%@", [url absoluteString], self.pageId];
    NSURL *urlWithParams = [[NSURL alloc] initWithString:urlStrWithParams];
    
    //直接拼一个地址为书包页
    NSString *bundlePath = [PathUtil getBundlePath];
    NSString *myBagUrlStrWithParams = [NSString stringWithFormat:@"%@/%@/%@/%@/%@", bundlePath, @"assets",@"native-html",@"schoolbag.html",@"?study_type=1"];
    NSURL *myBagUrl = [NSURL URLWithString:myBagUrlStrWithParams];
    //H:change for 2.0
    if (self.webURLStr == nil || self.webURLStr.length <= 0) {
        [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:myBagUrl]];

    }
    
    
    return YES;
}

#pragma mark 2.0版本中展示html页面
//2.0版本需要修改的地方，传来的是一个json字符串，json解析完成后得到的是一个字典

// 1.0中跳转到指定的页面
- (BOOL)showPageWithPageId:(NSString *)pageId andArgs:(NSString *)args {
    NSString *htmlFilePath = [[KnowledgeManager instance] getPagePath:pageId];
    if (htmlFilePath == nil || htmlFilePath.length <= 0) {
        return NO;
    }
    
    // 加载指定的html文件
    NSURL *url = [[NSURL alloc] initFileURLWithPath:[NSString stringWithFormat:@"%@/%@", htmlFilePath, @"index.html"]];
    
    NSString *urlStrWithParams = nil;
    if (args != nil && args.length > 0) {
        urlStrWithParams = [NSString stringWithFormat:@"%@?page_id=%@&%@", [url absoluteString], pageId, args];
    }
    else {
        [NSString stringWithFormat:@"%@?page_id=%@", [url absoluteString], pageId];
    }
    
    NSURL *urlWithParams = [[NSURL alloc] initWithString:urlStrWithParams];
    
    [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:urlWithParams]];
    
    return YES;
}

// 1.0 跳转到指定的url
- (BOOL)showPageWithURL:(NSString *)urlStr {
    NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:url]];
    
    return YES;
}


// 1.0中打开新的webView, 并跳转到指定的url
- (BOOL)showSafeURL:(NSString *)urlStr {
//    NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    MatchViewController *matchViewController = [[MatchViewController alloc] init];
    matchViewController.webUrl = urlStr;
    matchViewController.shouldChangeBackground=@"needChange";
    [self.navigationController pushViewController:matchViewController animated:YES];
    
    return YES;
}


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




#pragma mark - play video
- (void)playVideo:(NSString *)urlStr {
    if (urlStr == nil || urlStr.length <= 0) {
        return;
    }
    
    NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    if (url == nil) {
        return;
    }
    
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

#pragma mark - delay run
- (void)performBlock:(void(^)())block afterDelay:(NSTimeInterval)delay {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), block);
}

#pragma mark - WebViewJavascriptBridge delegate methods
- (void)javascriptBridge:(WebViewJavascriptBridge *)bridge receivedMessage:(NSString *)message fromWebView:(UIWebView *)webView {
    LogDebug(@"MyJavascriptBridgeDelegate received message: %@", message);
}


#pragma mark - web view delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (request) {
        LogDebug(@"[KnowledgeWebViewController] Web request: UA: %@", [request valueForHTTPHeaderField:@"User-Agent"]);
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
}

#pragma mark - 更新
- (void)updateApp {
    [UpdateManager instance].delegate = self;
    [[UpdateManager instance] checkUpdate];
}

- (void)onCheckUpdateResult:(UpdateInfo *)updateInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *status=updateInfo.status;
        if ([status isEqualToString:@"0"]) {
            NSString *shouldUpdate=updateInfo.shouldUpdate;
            if ([shouldUpdate isEqualToString:@"NO"]) {
                LogInfo(@"已经是最新版本");
            }
            else {
                
                //            LogDebug(@"appDownloadUrl====%@",updateInfo.appDownloadUrl);
                self.updateAppURL=updateInfo.appDownloadUrl;
                NSString *desc=updateInfo.appVersionDesc;
                NSString *version=updateInfo.appVersionStr;
                NSString *title=[NSString stringWithFormat:@"有新版本可供更新%@",version];
                NSString *msg=[NSString stringWithFormat:@"更新信息：%@",desc];
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"忽略" otherButtonTitles:@"更新", nil];
                [alert show];
            }
        }
        else {
            LogError(@"检查版本更新出错");
        }
    });
}

#pragma mark alertView delegate method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        //        [self.navigationController pushViewController:self.updateApp animated:YES];
        NSURL *requestURL = [NSURL URLWithString:[self.updateAppURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        [[UIApplication sharedApplication] openURL:requestURL];
    }
}

@end
