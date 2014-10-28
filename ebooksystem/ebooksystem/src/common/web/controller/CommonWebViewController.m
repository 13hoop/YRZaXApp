//
//  CommonWebViewController.m
//  ebooksystem
//
//  Created by zhenghao on 10/8/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "CommonWebViewController.h"

#import "Config.h"

#import "KnowledgeSubject.h"

#import "KnowledgeManager.h"
#import "StatisticsManager.h"

//#import <MediaPlayer/MediaPlayer.h>
#import "DirectionMPMoviePlayerViewController.h"

#import "MoreViewController.h"

#import "WebViewJavascriptBridge.h"

#import "LogUtil.h"


#import "StatisticsManager.h"




@interface CommonWebViewController () <UIWebViewDelegate>

#pragma mark - outlets
@property (strong, nonatomic) IBOutlet UIWebView *webView;

#pragma mark - properties
// bridge between webview and js
@property (nonatomic, copy) WebViewJavascriptBridge *javascriptBridge;


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

// 打开播放链接
- (void)gotoMediaPlayerViewController:(NSString *)url;

// 视频播放开始
- (void)playVideo:(NSString *)urlStr;
// 视频播放结束
- (void)movieFinishedCallback:(NSNotification*) aNotification;

// 延迟执行
- (void)performBlock:(void(^)())block afterDelay:(NSTimeInterval)delay;


@end




@implementation CommonWebViewController

@synthesize javascriptBridge = _javascriptBridge;

@synthesize knowledgeSubject = _knowledgeSubject;
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

- (void)setKnowledgeSubject:(KnowledgeSubject *)knowledgeSubject {
    _knowledgeSubject = knowledgeSubject;
}


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
    
    [self initWebView];
    [self updateWebView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateNavigationBar];
    
    // 友盟统计
    [[StatisticsManager instance] beginLogPageView:@"CommonWebView"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
//    // test video play
//    {
//        [self performBlock:^{
//            [self gotoMediaPlayerViewController];
//        } afterDelay:1];
//    }
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
    [[StatisticsManager instance] endLogPageView:@"CommonWebView"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



#pragma mark - ui related methods
// update navigation bar
- (void)updateNavigationBar {
    self.navigationController.navigationBarHidden = YES;
}

#pragma mark - web view methods
- (BOOL)initWebView {
    self.webView.delegate = self.javascriptBridge;
    
    // 注册obj-c方法, 供js调用
    // test method
    [self.javascriptBridge registerHandler:@"testObjCCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
        LogDebug(@"CommonWebViewController::testObjcCallback() called: %@", data);
        
        if (responseCallback != nil) {
            responseCallback(@"Response from testObjcCallback");
        }
    }];
    
    // goBack()
    [self.javascriptBridge registerHandler:@"goBack" handler:^(id data, WVJBResponseCallback responseCallback) {
        LogDebug(@"CommonWebViewController::goBack() called: %@", data);
        [self.webView goBack];
//        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    // showMenu()
    [self.javascriptBridge registerHandler:@"showMenu" handler:^(id data, WVJBResponseCallback responseCallback) {
        LogDebug(@"CommonWebViewController::showMenu() called: %@", data);
        
        MoreViewController *more = [[MoreViewController alloc] init];
        [self.navigationController pushViewController:more animated:YES];
    }];
    
    // getNodeDataById()
    // deprecated: 读取数据, 非index方式
    [self.javascriptBridge registerHandler:@"getNodeDataById" handler:^(id dataId, WVJBResponseCallback responseCallback) {
        LogDebug(@"CommonWebViewController::getNodeDataById() called: %@", dataId);
        
        if (responseCallback != nil) {
            NSString *data = [[KnowledgeManager instance] getLocalData:dataId];
            responseCallback(data);
        }
    }];
    
    // getNodeDataByIdAndQueryId()
    // 读取数据, index方式
    [self.javascriptBridge registerHandler:@"getNodeDataByIdAndQueryId" handler:^(id data, WVJBResponseCallback responseCallback) {
        LogDebug(@"CommonWebViewController::getNodeDataByIdAndQueryId() called: %@", data);
        
        NSString *dataId = [data objectForKey:@"dataId"];
        NSString *queryId = [data objectForKey:@"queryId"];
        NSString *indexFilename = [data objectForKey:@"indexFilename"];
        
        if (responseCallback != nil) {
            NSArray *dataArray = [[KnowledgeManager instance] getLocalDataWithDataId:dataId andQueryId:queryId andIndexFilename:indexFilename];
//            NSLog(@"====dataArray: %@", dataArray);
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
    
    // searchData()
    [self.javascriptBridge registerHandler:@"searchData" handler:^(id data, WVJBResponseCallback responseCallback) {
        LogDebug(@"CommonWebViewController::searchData() called: %@", data);
        
        NSString *searchId = (NSString *)data;
        
        if (responseCallback != nil) {
            NSString *data = [[KnowledgeManager instance] searchLocalData:searchId];
            responseCallback(data);
        }
    }];
    
    // hasNodeDownloaded()
    [self.javascriptBridge registerHandler:@"hasNodeDownloaded" handler:^(id dataId, WVJBResponseCallback responseCallback) {
        LogDebug(@"CommonWebViewController::hasNodeDownloaded() called: %@", dataId);
        
        NSString *pagePath = [[KnowledgeManager instance] getPagePath:dataId];
        BOOL downloaded = (pagePath == nil || pagePath.length <= 0 ? NO : YES);
        
        if (responseCallback != nil) {
            responseCallback(downloaded ? @"1" : @"0");
        }
    }];
    
    // tryDownloadNodeById()
    [self.javascriptBridge registerHandler:@"tryDownloadNodeById" handler:^(id dataId, WVJBResponseCallback responseCallback) {
        LogDebug(@"CommonWebViewController::tryDownloadNodeById() called: %@", dataId);
        
        [[KnowledgeManager instance] getRemoteData:dataId];
        
        if (responseCallback != nil) {
        }
    }];
    
    // getDataStatus()
    [self.javascriptBridge registerHandler:@"getDataStatus" handler:^(id dataId, WVJBResponseCallback responseCallback) {
        LogDebug(@"CommonWebViewController::getDataStatus() called: %@", dataId);
        
        if (responseCallback != nil) {
            // status##desc
            NSString *status = [[KnowledgeManager instance] getDataStatus:dataId];
            responseCallback(status);
        }
    }];
    
    // startCheckDataUpdate()
    [self.javascriptBridge registerHandler:@"startCheckDataUpdate" handler:^(id data, WVJBResponseCallback responseCallback) {
        LogDebug(@"CommonWebViewController::startCheckDataUpdate() called: %@", data);
        
        [[KnowledgeManager instance] startCheckDataUpdate];
    }];
    
    // showPageById()
    [self.javascriptBridge registerHandler:@"showPageById" handler:^(id data, WVJBResponseCallback responseCallback) {
        LogDebug(@"CommonWebViewController::showPageById() called: %@", data);
        
        NSString *pageID = [data objectForKey:@"pageID"];
        NSString *args = [data objectForKey:@"args"];
        NSDictionary *postArgsStr = [data objectForKey:@"postArgsStr"];
        
        [self showPageWithPageId:pageID andArgs:args];
    }];
    
    // playVideo()
    [self.javascriptBridge registerHandler:@"playVideo" handler:^(id dataId, WVJBResponseCallback responseCallback) {
        LogDebug(@"CommonWebViewController::playVideo() called: %@", dataId);
        
        NSString *urlStr = (NSString *)dataId;
        [self playVideo:urlStr];
    }];
    
    // pageStatistic()
    [self.javascriptBridge registerHandler:@"pageStatistic" handler:^(id data, WVJBResponseCallback responseCallback) {
        LogDebug(@"CommonWebViewController::pageStatistic() called: %@", data);
        
        NSString *eventName = [data objectForKey:@"eventName"];
        NSString *args = [data objectForKey:@"args"];
        
        [[StatisticsManager instance] event:eventName label:args];
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

// 更新webview
- (BOOL)updateWebView {
    [((UIScrollView *)[self.webView.subviews objectAtIndex:0]) setShowsVerticalScrollIndicator:NO]; // 去除webView右侧垂直滚动条
    //    self.webView.delegate = self;
    [((UIScrollView *)[self.webView.subviews objectAtIndex:0]) setBounces:NO];
    
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
    
    //        NSString *urlStrWithParams = [NSString stringWithFormat:@"%@?page_id=%@&data_id=%@", [url absoluteString], self.pageId, dataId];
    NSString *urlStrWithParams = [NSString stringWithFormat:@"%@?page_id=%@", [url absoluteString], self.pageId];
    NSURL *urlWithParams = [[NSURL alloc] initWithString:urlStrWithParams];
    
    [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:urlWithParams]];
    
    return YES;
}

// 跳转到指定的页面
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

// 跳转到指定的url
- (BOOL)showPageWithURL:(NSString *)urlStr {
    NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:url]];
    
    return YES;
}

#pragma mark - play video
- (void)playVideo:(NSString *)urlStr {
    if (urlStr == nil || urlStr.length <= 0) {
        // todo: show alert view
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
- (void)javascriptBridge:(WebViewJavascriptBridge *)bridge receivedMessage:(NSString *)message fromWebView:(UIWebView *)webView
{
    NSLog(@"MyJavascriptBridgeDelegate received message: %@", message);
}


#pragma mark - web view delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
}

#pragma mark - 屏幕旋转

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (interfaceOrientation==UIInterfaceOrientationLandscapeLeft) {
        //zuo
    }
    if (interfaceOrientation==UIInterfaceOrientationLandscapeRight) {
        //you
    }
    if (interfaceOrientation==UIInterfaceOrientationPortrait) {
        //shang
    }
    if (interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown) {
        //xia
    }
    return YES;
}

- (BOOL)shouldAutorotate {
    return YES;
}



- (NSUInteger)supportedInterfaceOrientations {
//    return UIInterfaceOrientationMaskAllButUpsideDown;
    return UIInterfaceOrientationMaskAll;
//    return UIInterfaceOrientationPortrait;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    //宣告一個UIDevice指標，並取得目前Device的狀況
    UIDevice *device = [UIDevice currentDevice] ;
    //取得當前Device的方向，來當作判斷敘述。（Device的方向型態為Integer）
    switch (device.orientation) {
        case UIDeviceOrientationFaceUp:
            NSLog(@"螢幕朝上平躺");
            break;
        case UIDeviceOrientationFaceDown:
            NSLog(@"螢幕朝下平躺");
            break;
            //系統無法判斷目前Device的方向，有可能是斜置
        case UIDeviceOrientationUnknown:
            NSLog(@"未知方向");
            break;
        case UIDeviceOrientationLandscapeLeft:
            NSLog(@"螢幕向左橫置");
            break;
        case UIDeviceOrientationLandscapeRight:
            NSLog(@"螢幕向右橫置");
            break;
        case UIDeviceOrientationPortrait:
            NSLog(@"螢幕直立");
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            NSLog(@"螢幕直立，上下顛倒");
            break;
        default:
            NSLog(@"無法辨識");
            break;    
    }
    
    CGRect frame = self.view.frame;
    self.webView.frame = frame;
    
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) { // 横屏, home在右
        
        ;
    }
    else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) { // 横屏, home在左
        ;
    }
    else if (toInterfaceOrientation == UIInterfaceOrientationPortrait) { // 竖屏, home在下
        ;
    }
    else if (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) { // 竖屏, home在上
        ;
    }

    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

@end
