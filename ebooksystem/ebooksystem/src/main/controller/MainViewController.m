//
//  MainViewController.m
//  ebooksystem
//
//  Created by wanghaoyu on 14-9-22.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import "MainViewController.h"
#import "CustomUpview.h"
#import "CustomDownview.h"
#import "MoreViewController.h"
#import "MobClick.h"
@interface MainViewController ()<CustomUpviewDelegate>

@property(nonatomic,strong)CustomUpview *customUpView;
@property(nonatomic,strong)CustomDownview *customDownView;

@end

@implementation MainViewController

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
    self.navigationController.navigationBarHidden=YES;
    [self addUpview];
    [self addDownview];
    
}
#pragma mark 添加自定义的上方视图
-(void)addUpview
{
    self.customUpView=[[CustomUpview alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width,220)];
    self.customUpView.more_delegate=self;
    [self.view addSubview:self.customUpView];
    
}
-(void)addDownview
{
    self.customDownView=[[CustomDownview alloc] initWithFrame:CGRectMake(0,20+self.customUpView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-(20+self.customUpView.frame.size.height))];
    [self.view addSubview:self.customDownView];
    
}
#pragma mark 实现CustomUpview中的代理方法
-(void)getClick:(UIButton *)btn
{
    MoreViewController *more=[[MoreViewController alloc] init];
    [self.navigationController pushViewController:more animated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"PageMain"];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"PageMain"];
}



@end
