//
//  DiscoveryViewController.m
//  ebooksystem
//
//  Created by wanghaoyu on 15/1/9.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import "DiscoveryViewController.h"
#import "discoveryWebView.h"
#import "discoveryModel.h"
@interface DiscoveryViewController ()

@property (nonatomic,strong) discoveryWebView *discoverWeb;


@end

@implementation DiscoveryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.tabBarController.selectedIndex = 2;
    //消除状态栏的20像素差
    self.automaticallyAdjustsScrollViewInsets = NO;
   
    [self makeWebView];
    [self test];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:TRUE];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//创建webview
- (void)makeWebView {
     self.discoverWeb = [[discoveryWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    [self.view addSubview:self.discoverWeb];
}

- (void)test {
    NSArray *arr = [NSArray arrayWithObjects:@"test_book_4", nil];
    discoveryModel *disMod = [[discoveryModel alloc] init];
    [disMod getBookInfoWithDataIds:arr];
}

@end
