//
//  AboutUsViewController.m
//  ebooksystem
//
//  Created by wanghaoyu on 14-9-26.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import "AboutUsViewController.h"

#import "CustomAboutUsview.h"
#import "CustomNavigationBar.h"

#import "StatisticsManager.h"
#import "UIColor+Hex.h"



@interface AboutUsViewController ()<CustomNavigationBarDelegate>

@end



@implementation AboutUsViewController

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
    self.view.backgroundColor=[UIColor colorWithHexString:@"#e95510" alpha:1];
    [self creatCustomNavigationBar];
    [self createCustomAboutUs];
    
}

-(void)createCustomAboutUs
{
    CustomAboutUsview *custom=[[CustomAboutUsview alloc] initWithFrame:CGRectMake(0, 70, self.view.frame.size.width, self.view.frame.size.height-70)];
    
    [self.view addSubview:custom];
}

-(void)creatCustomNavigationBar
{
    CustomNavigationBar *navigationBar=[[CustomNavigationBar alloc] initWithFrame:CGRectMake(0, 20, 320, 50)];
    navigationBar.title = @"关于咋学";
    [navigationBar setTintColor:[UIColor colorWithHexString:@"#fffff3" alpha:1]];
    navigationBar.customNav_delegate = self;
    [self.view addSubview:navigationBar];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getClick:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    //页面开始渲染时将tabbar隐藏掉
    self.tabBarController.tabBar.hidden = YES;
    
    [[StatisticsManager instance] beginLogPageView:@"PageAboutUs"];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //页面消失时将tabbar显示出来
    self.tabBarController.tabBar.hidden = NO;
    
    [[StatisticsManager instance] endLogPageView:@"PageAboutUs"];
}



@end
