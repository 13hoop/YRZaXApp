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

#import "WebViewJavascriptBridge.h"




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

// 注入对象, 方法等到页面中
- (BOOL)injectJS;

// update navigation bar
- (void)updateNavigationBar;


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
                                                        NSLog(@"Received message from javascript: %@", data);
                                                        responseCallback(@"'response data from obj-c'");
                                                    }];
//        [self initWebView];
    }
    
    return _javascriptBridge;
}

- (void)setKnowledgeSubject:(KnowledgeSubject *)knowledgeSubject {
    _knowledgeSubject = knowledgeSubject;
}


#pragma mark - app events
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        NSLog(@"CommonWebViewController::testObjcCallback() called: %@", data);
        
        if (responseCallback != nil) {
            responseCallback(@"Response from testObjcCallback");
        }
    }];
    
    // goBack()
    [self.javascriptBridge registerHandler:@"goBack" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"CommonWebViewController::goBack() called: %@", data);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    // getNodeDataById()
    [self.javascriptBridge registerHandler:@"getNodeDataById" handler:^(id dataId, WVJBResponseCallback responseCallback) {
        NSLog(@"CommonWebViewController::getNodeDataById() called: %@", dataId);
        
        if (responseCallback != nil) {
            NSString *data = [[KnowledgeManager instance] getLocalData:dataId];
            responseCallback(data);
        }
    }];
    
    // hasNodeDownloaded()
    [self.javascriptBridge registerHandler:@"hasNodeDownloaded" handler:^(id dataId, WVJBResponseCallback responseCallback) {
        NSLog(@"CommonWebViewController::hasNodeDownloaded() called: %@", dataId);
        
        NSString *pagePath = [[KnowledgeManager instance] getPagePath:dataId];
        BOOL downloaded = (pagePath == nil || pagePath.length <= 0 ? NO : YES);
        
        if (responseCallback != nil) {
            responseCallback(downloaded ? @"1" : @"0");
        }
    }];
    
    // tryDownloadNodeById()
    [self.javascriptBridge registerHandler:@"tryDownloadNodeById" handler:^(id dataId, WVJBResponseCallback responseCallback) {
        NSLog(@"CommonWebViewController::tryDownloadNodeById() called: %@", dataId);
        
        NSString *pagePath = [[KnowledgeManager instance] getPagePath:dataId];
        BOOL downloaded = (pagePath == nil || pagePath.length <= 0 ? NO : YES);
        
        if (responseCallback != nil) {
            responseCallback(downloaded ? @"1" : @"0");
        }
    }];
    
    // showPageById()
    [self.javascriptBridge registerHandler:@"showPageById" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"CommonWebViewController::showPageById() called: %@", data);
        
        NSString *pageID = [data objectForKey:@"pageID"];
        NSDictionary *args = [data objectForKey:@"args"];
        NSDictionary *postArgsStr = [data objectForKey:@"postArgsStr"];
        
        // todo: do real work
    }];
    
    // pageStatistic()
    [self.javascriptBridge registerHandler:@"pageStatistic" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"CommonWebViewController::pageStatistic() called: %@", data);
        
        NSString *eventName = [data objectForKey:@"eventName"];
        NSDictionary *args = [data objectForKey:@"args"];
        
        [[StatisticsManager instance] pageStatisticWithEvent:eventName andArgs:args];
    }];
    
    // 发送消息给 html
    //    [self.javascriptBridge send:@"Well hello there"];
    //    [self.javascriptBridge send:[NSDictionary dictionaryWithObject:@"Foo" forKey:@"Bar"]];
    //    [self.javascriptBridge send:@"Give me a response, will you?" responseCallback:^(id responseData) {
    //        NSLog(@"ObjC got its response! %@", responseData);
    //    }];
    
    // 调用js中的方法
//    [self.javascriptBridge callHandler:@"showAlert" data:@"alert message from oc"];
//    [self.javascriptBridge callHandler:@"getCurrentPageUrl" data:@"xxxx" responseCallback:^(id responseData){
//        NSLog(@"ObjC got its response: %@", responseData);
//    }];
    
    return YES;
}

// 更新webview
- (BOOL)updateWebView {
//    self.webView.delegate = self;
    
    NSString *knowledgeDataRootPathInAssets = [[Config instance] knowledgeDataConfig].knowledgeDataRootPathInAssets;
    NSString *knowledgeDataRootPathInDocuments = [[Config instance] knowledgeDataConfig].knowledgeDataRootPathInDocuments;
    
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
        
        NSString *htmlFilePath = [NSString stringWithFormat:@"%@/%@", knowledgeDataRootPathInAssets, @"14/3b7942bf7d9f8a80dc3b7e43539ee40e"];
        
        // 加载指定的html文件
        NSURL *url = [[NSURL alloc] initFileURLWithPath:[NSString stringWithFormat:@"%@/%@", htmlFilePath, @"index.html"]];
        
        NSString *urlStrWithParams = [NSString stringWithFormat:@"%@?page_id=%@&data_id=%@", [url absoluteString], pageId, dataId];
        NSURL *urlWithParams = [[NSURL alloc] initWithString:urlStrWithParams];
        
        [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:urlWithParams]];
    }
    
    return YES;
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
