//
//  PurchaseViewController.m
//  ebooksystem
//
//  Created by wanghaoyu on 14-10-20.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import "PurchaseViewController.h"
#import "CustomNavigationBar.h"
#import "TBActivityView.h"

@interface PurchaseViewController ()<CustomNavigationBarDelegate,UIWebViewDelegate>
@property(nonatomic,strong)UIWebView *webview;
@property(nonatomic,strong)UIActivityIndicatorView *activityIndicator;
@property(nonatomic,strong)TBActivityView *tbactivityView;
@end

@implementation PurchaseViewController

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
    self.view.backgroundColor=[UIColor whiteColor];
    [self createWebView];
    [self createNavigationBar];
    [self createActivityIndicator];
}
-(void)createNavigationBar
{
    CustomNavigationBar *nav=[[CustomNavigationBar alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 44)];
    nav.customNav_delegate=self;
    nav.title=@"购买图书";
    [self.view addSubview:nav];
}
-(void)createWebView
{
    
    self.webview=[[UIWebView alloc] initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height-64)];
    self.webview.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webview.scalesPageToFit=YES;
    self.webview.delegate=self;
    [self.view addSubview:self.webview];
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://product.dangdang.com/23559777.html"]];
    [self.webview loadRequest:request];
    
}
-(void)createActivityIndicator
{
    self.tbactivityView=[[TBActivityView alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.height-30)/2, 320, 30)];
    [self.view addSubview:self.tbactivityView];
    
}

#pragma mark customNavigationBar delegate method
-(void)getClick:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark webview delegate method
-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.tbactivityView startAnimate];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.tbactivityView stopAnimate];
}

@end
