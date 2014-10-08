//
//  CommonWebViewController.m
//  ebooksystem
//
//  Created by zhenghao on 10/8/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "CommonWebViewController.h"

#import "KnowledgeSubject.h"

#import "BaseTitleBar.h"
#import "QBTitleView.h"
#import "UIImage+tintedImage.h"

#import "WebViewJavascriptBridge.h"

#import "Config.h"




@import JavaScriptCore;
@import ObjectiveC;


@interface CommonWebViewController () <UIWebViewDelegate>

#pragma mark - outlets
@property (strong, nonatomic) IBOutlet UIWebView *webView;

#pragma mark - properties
// bridge between webview and js
@property (nonatomic, copy) WebViewJavascriptBridge *bridge;


#pragma mark - methods
// 更新webview
- (BOOL)updateWebView;

// webView与objC交互测试
- (BOOL)testWebView;

// 注入对象, 方法等到页面中
- (BOOL)injectJS;

// update navigation bar
- (void)updateNavigationBar;


@end




@implementation CommonWebViewController

@synthesize bridge = _bridge;

@synthesize knowledgeSubject = _knowledgeSubject;


#pragma mark - properties
// bridge between webview and js
- (WebViewJavascriptBridge *)bridge {
    if (_bridge == nil) {
        _bridge = [WebViewJavascriptBridge bridgeForWebView:self.webView
                                                    handler:^(id data, WVJBResponseCallback responseCallback) {
                                                        NSLog(@"Received message from javascript: %@", data);
                                                        responseCallback(@"Right back atcha");
                                                    }];
    }
    
    return _bridge;
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
    // Do any additional setup after loading the view.
    
    [self updateWebView];
    
//    [self testWebView];
    
    // 向页面注入js
    [self injectJS];
    
    //    KnowledgeSubject *subject = [self.subjects objectAtIndex:indexPath.row];
    //    if (subject.subjectId  @"subject_politics_id";) {
    //        <#statements#>
    //    }
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
// 更新webview
- (BOOL)updateWebView {
    self.webView.delegate = self;
    
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

- (BOOL)testWebView {
    // set up a full-screen UIWebView
    UIView *view = self.view;
    UIWebView *webView = [[UIWebView alloc] init];
    [view addSubview:webView];
    
    // 偏移
//    webView.translatesAutoresizingMaskIntoConstraints = view.translatesAutoresizingMaskIntoConstraints = NO;
//    for (NSString *fitFormat in @[@"H:|-0-[webView]-0-|", @"V:|-0-[webView]-0-|"]) {
//        [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:fitFormat options:0 metrics:nil views:NSDictionaryOfVariableBindings(webView)]];
//    }
    
    JSContext *ctx = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    NSAssert([ctx isKindOfClass:[JSContext class]], @"could not find context in web view");
    [ctx evaluateScript:@"console.log(‘this is a log message that goes nowhere :(‘)"];
    ctx[@"console"][@"log"] = ^(JSValue *msg) {
        NSLog(@"JavaScript %@ log message: %@", [JSContext currentContext], msg);
    };
    [ctx evaluateScript:@"console.log(‘this is a log message that goes to my Xcode debug console :)’)"];
    
    JSValue *style = ctx[@"document"][@"body"][@"style"]; // yes, thus works: KVC FTW!
    NSAssert(style, @"there should be a style element in the document body");
    // set up the body’s style so all CSS changes are animated
    NSTimeInterval colorChangeInterval = 1.0;
    style[@"transition-timing-function"] = @"linear";
    style[@"transition-delay"] = @(0);
    style[@"transition-duration"] = [NSString stringWithFormat:@"%@s", @(colorChangeInterval)];
    // this sets up a JavaScript-function-to-Cocoa-block bridge
    ctx[@"setRandomColor"] = ^() {
        style[@"background"] = [NSString stringWithFormat:@"hsl(%@, %@, %@)", @(arc4random() % 255), @"50%", @"50%"];
        NSLog(@"fading to color: %@", style[@"background"]); // notably, this will not output hsl format, but instead rgb format like: “rgb(63, 191, 179)”
    };
    JSValue *setColorFunction = ctx[@"setRandomColor"];
    NSAssert([setColorFunction isObject], @"it was a block, but now it should be a bridged JSValue function object");
    // we can call our background-setting code directly via JavaScript
    [setColorFunction callWithArguments:nil];
    JSValue *setIntervalFunction = ctx[@"setInterval"]; // grab the built-in setInterval repeating timer function
    NSAssert([setIntervalFunction isObject], @"setInterval should have been a function object");
    // now set up a repeating timer in JavaScript that calls our background-changing Cocoa function
    [setIntervalFunction callWithArguments:@[setColorFunction, @(colorChangeInterval * 1000.)]];
    
    return YES;
}

// 注入对象, 方法等到页面中
- (BOOL)injectJS {
    //    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"js"];
    //    NSString *jsString = [[NSString alloc] initWithContentsOfFile:filePath];
    //    [self.webView stringByEvaluatingJavaScriptFromString:jsString];
    //
    //    xx
    return YES;
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
