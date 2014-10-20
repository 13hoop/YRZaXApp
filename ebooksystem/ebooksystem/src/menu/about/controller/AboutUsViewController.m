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
#import "MobClick.h"
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
    self.view.backgroundColor=[UIColor whiteColor];
    [self creatCustomNavigationBar];
    [self createCustomAboutUs];
    
}
-(void)createCustomAboutUs
{
    CustomAboutUsview *custom=[[CustomAboutUsview alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64)];
    
    [self.view addSubview:custom];
}
-(void)creatCustomNavigationBar
{
    CustomNavigationBar *navigationBar=[[CustomNavigationBar alloc] initWithFrame:CGRectMake(0, 20, 320, 44)];
    navigationBar.title=@"关于咋学";
    navigationBar.customNav_delegate=self;
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
    [MobClick beginLogPageView:@"PageAboutUs"];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"PageAboutUs"];
}



@end
