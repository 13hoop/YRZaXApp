//
//  LoginViewController.m
//  ebooksystem
//
//  Created by wanghaoyu on 14-10-2.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import "LoginViewController.h"
#import "CustomLoginNavgationBar.h"
#import "RegisterViewController.h"
#import "CustomLoginView.h"
#define CUSTOMVIEW_X 64
@interface LoginViewController ()<CustomNavigationBarDelegate,CustomLoginNavgationBarDelegate,CustomLoginViewDelegate>

@property(nonatomic,strong)CustomLoginNavgationBar *navBar;

@end

@implementation LoginViewController

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
    [self addNavigationBar];
    [self createLoginView];
}

-(void)addNavigationBar
{
    
    self.navBar=[[CustomLoginNavgationBar alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 44)];
    self.navBar.title=@"登录";
    self.navBar.customNav_delegate=self;
    self.navBar.customRegistration_delegate=self;
    [self.view addSubview:self.navBar];
}

#pragma mark customNavgationBar delegate method
-(void)getClick:(UIButton *)btn
{
    //一层层往回撤
    [self.navigationController popViewControllerAnimated:YES];
    NSLog(@"这个是返回");
    
}
#pragma mark customLoginNaviagtionBar delegate method
-(void)gotoRegistrationController:(UIButton *)btn
{
    RegisterViewController *reg=[[RegisterViewController alloc] init];
    //进入到注册页面
    [self.navigationController pushViewController:reg animated:YES];
    
}
//创建login 按钮
-(void)createLoginView
{
    CustomLoginView *loginView=[[CustomLoginView alloc] initWithFrame:CGRectMake(0, CUSTOMVIEW_X, self.view.frame.size.width, self.view.frame.size.height-CUSTOMVIEW_X)];
    loginView.login_deleagte=self;
    [self.view addSubview:loginView];
    
}
#pragma mark customLoginview delegate method
-(void)loginClick:(CustomLoginModel*)model
{
    //在这里面进行登录的相关操作
    NSLog(@"将登录控件中的model传出来====%@",model.userName);
    NSLog(@"点击登录了");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
