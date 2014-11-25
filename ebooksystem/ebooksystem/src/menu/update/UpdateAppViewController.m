//
//  UpdateAppViewController.m
//  ebooksystem
//
//  Created by wanghaoyu on 14-10-29.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import "UpdateAppViewController.h"
#import "CustomNavigationBar.h"
#import "TBActivityView.h"
#import "UIColor+Hex.h"
#import "MRActivityIndicatorView.h"



@interface UpdateAppViewController ()<CustomNavigationBarDelegate,UIWebViewDelegate>
{
    MRActivityIndicatorView *activityIndicatorView;
}
@property(nonatomic,strong)UIWebView *webview;

@end

@implementation UpdateAppViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor colorWithHexString:@"#242021" alpha:1];
    [self createWebView];
    [self createNavigationBar];
    [self createActivityIndicator];
}

-(void)createNavigationBar
{
    CustomNavigationBar *nav=[[CustomNavigationBar alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 44)];
    nav.customNav_delegate=self;
    nav.title=@"更新“咋学”";
    [self.view addSubview:nav];
}
-(void)createWebView
{
    
    self.webview=[[UIWebView alloc] initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height-44)];
    self.webview.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webview.scalesPageToFit=YES;
    self.webview.delegate=self;
    [self.view addSubview:self.webview];
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:self.updateUrlStr]];
    NSLog(@"链接======%@",self.updateUrlStr);
    [self.webview loadRequest:request];
    
}
-(void)createActivityIndicator
{
    
    activityIndicatorView=[[MRActivityIndicatorView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-30)/2, (self.view.frame.size.height-30)/2,30, 30)];
    [self.view addSubview:activityIndicatorView];
    
    
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
    //    [self.tbactivityView startAnimate];
    [self showProgressAsActivityIndicator];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    //    [self.tbactivityView stopAnimate];
    [self hideProgressOfActivityIndicator];
}
#pragma mark - KnowledgeManagerDelegate methods
- (void)showProgressAsActivityIndicator {
    if (activityIndicatorView) {
        activityIndicatorView.hidden = NO;
        activityIndicatorView.hidesWhenStopped = YES;
        activityIndicatorView.tintColor = [UIColor blueColor];
        activityIndicatorView.backgroundColor = [UIColor clearColor];
        [activityIndicatorView startAnimating];
    }
}

- (void)hideProgressOfActivityIndicator {
    if (activityIndicatorView) {
        [activityIndicatorView stopAnimating];
        //    activityIndicatorView.hidden = YES;
    }
}




@end
