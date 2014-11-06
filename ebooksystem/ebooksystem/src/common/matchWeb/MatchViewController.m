//
//  MatchViewController.m
//  ebooksystem
//
//  Created by wanghaoyu on 14-11-5.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import "MatchViewController.h"

@interface MatchViewController ()

@end

@implementation MatchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createWeb];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showWebUrl:(NSString *)url
{
    self.webUrl=url;
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
    
    NSString *urlString=[shareDic objectForKey:@"url"];
    NSURL *weburl=[NSURL URLWithString:urlString];
    
    NSString *imageString=[shareDic objectForKey:@"img_url"];
    NSURL *imageUrl=[NSURL URLWithString:imageString];
    
    NSString *title=[shareDic objectForKey:@"title"];
    BOOL shouldScreen_shot=(BOOL)[shareDic objectForKey:@"screen_shot"];
    
    
    
}
-(void)createWeb
{
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.zaxue100.com"]];
//    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:self.webUrl]];

    //给出具体样式后再修改
    UIWebView *webview=[[UIWebView alloc] initWithFrame:self.view.bounds];
    [webview loadRequest:request];
    [self.view addSubview:webview];
}



@end
