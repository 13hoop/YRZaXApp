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

#import "MediaPlayerViewController.h"

#import "WebViewJavascriptBridge.h"

#import "LogUtil.h"

#import "MobClick.h"




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

// 延迟执行
- (void)performBlock:(void(^)())block afterDelay:(NSTimeInterval)delay;

@end




@implementation CommonWebViewController

@synthesize javascriptBridge = _javascriptBridge;

@synthesize knowledgeSubject = _knowledgeSubject;


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
    [MobClick beginLogPageView:@"CommonWebView"];
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
    [MobClick endLogPageView:@"CommonWebView"];
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
        [self.navigationController popViewControllerAnimated:YES];
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
            NSString *data = [[KnowledgeManager instance] getLocalDataWithDataId:dataId andQueryId:queryId andIndexFilename:indexFilename];
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
    
    // pageStatistic()
    [self.javascriptBridge registerHandler:@"pageStatistic" handler:^(id data, WVJBResponseCallback responseCallback) {
        LogDebug(@"CommonWebViewController::pageStatistic() called: %@", data);
        
        NSString *eventName = [data objectForKey:@"eventName"];
        NSDictionary *args = [data objectForKey:@"args"];
        
        [[StatisticsManager instance] pageStatisticWithEvent:eventName andArgs:args];
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
//    self.webView.delegate = self;
    
    NSString *knowledgeDataRootPathInApp = [[Config instance] knowledgeDataConfig].knowledgeDataRootPathInApp;
    
    if (self.knowledgeSubject == nil) {
        return NO;
    }
    
    // 根据学科, 跳转到相应的entrance
    if ([self.knowledgeSubject.subjectId isEqualToString:@"subject_english_id"]) {
        // todo: load english entrance
    }
    else if ([self.knowledgeSubject.subjectId isEqualToString:@"subject_politics_id"]) {
        NSString *pageId = @"3b7942bf7d9f8a80dc3b7e43539ee40e";
        NSString *dataId = @"2a8ceed5e71a0ff16bafc9f082bceeec";
        
        NSString *htmlFilePath = [NSString stringWithFormat:@"%@/%@", knowledgeDataRootPathInApp, @"14/3b7942bf7d9f8a80dc3b7e43539ee40e"];
        
        // 加载指定的html文件
        NSURL *url = [[NSURL alloc] initFileURLWithPath:[NSString stringWithFormat:@"%@/%@", htmlFilePath, @"index.html"]];
        
        NSString *urlStrWithParams = [NSString stringWithFormat:@"%@?page_id=%@&data_id=%@", [url absoluteString], pageId, dataId];
        NSURL *urlWithParams = [[NSURL alloc] initWithString:urlStrWithParams];
        
        [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:urlWithParams]];
    }
    
    return YES;
}

// 跳转到指定的页面
- (BOOL)showPageWithPageId:(NSString *)pageId andArgs:(NSString *)args {
//    NSString *pageId = @"3b7942bf7d9f8a80dc3b7e43539ee40e";
//    NSString *dataId = @"2a8ceed5e71a0ff16bafc9f082bceeec";
//    
//    NSString *htmlFilePath = [NSString stringWithFormat:@"%@/%@", knowledgeDataRootPathInAssets, @"14/3b7942bf7d9f8a80dc3b7e43539ee40e"];
    
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

#pragma mark - segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[MediaPlayerViewController class]]) {
        MediaPlayerViewController *mediaPlayerViewController = (MediaPlayerViewController *)segue.destinationViewController;
        
        // test for play video
        {
            NSString *knowledgeDataRootPathInAssets = [[Config instance] knowledgeDataConfig].knowledgeDataRootPathInAssets;
            NSString *htmlFilePath = [NSString stringWithFormat:@"%@/%@", knowledgeDataRootPathInAssets, @"test_video.mp4"];
            
            // 加载指定的html文件
            NSURL *url = [[NSURL alloc] initFileURLWithPath:htmlFilePath];
            mediaPlayerViewController.url = url;
        }
    }
}

- (void)gotoMediaPlayerViewController {
    [self performSegueWithIdentifier:@"goto_media_player_view_controller" sender:self];
}

#pragma mark - 延迟执行
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

@end
