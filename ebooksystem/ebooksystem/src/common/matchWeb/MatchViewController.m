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

#import "UMSocial.h"
#import "UMSocialSnsService.h"
#import "UMSocialScreenShoter.h"


@interface MatchViewController ()<UIWebViewDelegate>

// bridge between webview and js
@property (nonatomic, strong) WebViewJavascriptBridge *javascriptBridge;
@property(nonatomic,strong)UIWebView *webview;

@end

@implementation MatchViewController

@synthesize javascriptBridge = _javascriptBridge;


#pragma mark - properties
// bridge between webview and js
-(WebViewJavascriptBridge *)javascriptBridge {
    if (_javascriptBridge == nil) {
        _javascriptBridge = [WebViewJavascriptBridge bridgeForWebView:self.webview
                                                              handler:^(id data, WVJBResponseCallback responseCallback) {
                                                                  LogDebug(@"Received message from javascript: %@", data);
                                                                  responseCallback(@"'response data from obj-c'");
                                                              }];
        //        [self initWebView];
    }
    
    return _javascriptBridge;
}




- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createWeb];
    [self initWebView];
  
    [self writeJsonToWebview];
//    self.webview.delegate=self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)createWeb
{
//    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.zaxue100.com"]];
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:self.webUrl]];

    //给出具体样式后再修改
    self.webview=[[UIWebView alloc] initWithFrame:self.view.bounds];
    
    self.webview.delegate=self;
    [self.webview loadRequest:request];
    [self.view addSubview:self.webview];
}

- (BOOL)initWebView {
//    self.webview.delegate = self.javascriptBridge;
    
    // goback()
    [self.javascriptBridge registerHandler:@"goBack" handler:^(id data, WVJBResponseCallback responseCallback) {
        LogDebug(@"CommonWebViewController::showMenu() called: %@", data);
        //判断是否可以继续回退
        BOOL iscan = self.webview.canGoBack;
        NSLog(@"iscanBack=====%hhd",iscan);
        if (iscan) {
            [self.webview goBack];
        }
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }];
    //-(void)share:(NSDictionary *)shareDic
    [self.javascriptBridge registerHandler:@"share" handler:^(id data, WVJBResponseCallback responseCallback) {
        LogDebug(@"CommonWebViewController::share() called: %@", data);
        
        NSDictionary *shareDic=(NSDictionary *)data;
        
        [self share:shareDic];
        
        
    }];
    
    return YES;
}


-(void)share:(NSDictionary *)shareDic
{
    /*
     {
     url : '',
     img_url : '',
     title : '',
     screen_shot : true | false
     
     }
     */
    //分享链接
    NSString *urlString=[shareDic objectForKey:@"url"];
    NSURL *weburl=[NSURL URLWithString:urlString];
    //分享的图片链接
    NSString *imageString=[shareDic objectForKey:@"img_url"];
    NSURL *imageUrl=[NSURL URLWithString:imageString];
    //分享的title
    NSString *title=[shareDic objectForKey:@"title"];
    BOOL shouldScreen_shot=(BOOL)[shareDic objectForKey:@"screen_shot"];
    
    NSString *shareString=[NSString stringWithFormat:@"%@:%@",title,urlString];
    
    NSLog(@"点击了分享");
    //(1)使用ui，分享url定义的图片
    [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeImage url:imageString];
    //(2)使用ui,分享截屏图片
    UIImage *image = [[UMSocialScreenShoterDefault screenShoter] getScreenShot];
    //不同的平台分享不同的内容
    //新浪微博平台
    [UMSocialData defaultData].extConfig.sinaData.shareText = @"分享到新浪微博内容";
    //腾讯
    [UMSocialData defaultData].extConfig.tencentData.shareImage = [UIImage imageNamed:@"meinv.jpg"]; //分享到腾讯微博图片
    //设置微信好友分享url图片
//    [UMSocialData defaultData].extConfig.wechatSessionData.shareImage=[UIImage imageNamed:@"wechat.jpg"];
    [[UMSocialData defaultData].extConfig.wechatSessionData.urlResource setResourceType:UMSocialUrlResourceTypeImage url:imageString];
    //设置微信朋友圈的分享视频
    [[UMSocialData defaultData].extConfig.wechatTimelineData.urlResource setResourceType:UMSocialUrlResourceTypeImage url:imageString];
//    [[UMSocialData defaultData].extConfig.wechatTimelineData.urlResource setResourceType:UMSocialUrlResourceTypeVideo url:@"http://v.youku.com/v_show/id_XNjQ1NjczNzEy.html?f=21207816&ev=2"];
    
    
    
    
    [UMSocialSnsService presentSnsIconSheetView:self appKey:@"543dea72fd98c5fc98004e08" shareText:shareString shareImage:nil shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToTencent,UMShareToRenren,UMShareToWechatSession,UMShareToWechatTimeline,UMShareToQzone,UMShareToQQ,UMShareToEmail,nil] delegate:nil];
    
    
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    return YES;
}
-(void)webViewDidStartLoad:(UIWebView *)webView
{
   
    [self writeJsonToWebview];
    static int times = 0;
    ++times;
    NSLog(@"====webViewDidStartLoad was called %d times", times);
}

-(void)writeJsonToWebview
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"webview-js-bridge" ofType:@"js"];
    NSString *jsString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"hahao====%@",jsString);
    [self.webview stringByEvaluatingJavaScriptFromString:jsString];
}
@end
