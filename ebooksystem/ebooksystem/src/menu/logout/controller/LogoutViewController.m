//
//  LogoutViewController.m
//  ebooksystem
//
//  Created by wanghaoyu on 14-10-7.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import "LogoutViewController.h"
#import "CustomLogoutView.h"
#import "CustomNavigationBar.h"
#import "LogoutModel.h"
#define NAVBAR_HEIGHT 44
#define LOGOUTVIEW_X 64
#define PROMPTVIEW_HEIGHT 30
#define PROMPTVIEW_WIDTH 50
#define DISTANCE 100
@interface LogoutViewController ()<CustomNavigationBarDelegate,CustomLogoutViewDelegate,LogoutModelDelegate>
{
    NSUInteger alpha;
}
@property(nonatomic,strong)UILabel *promptLable;

@end

@implementation LogoutViewController

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
    alpha=1;
    [self createNavBar];
    [self createCustomLogoutView];
    
    // Do any additional setup after loading the view.
}
-(void)createNavBar
{
    CustomNavigationBar *nav=[[CustomNavigationBar alloc] initWithFrame:CGRectMake(0,20, self.view.frame.size.width,NAVBAR_HEIGHT)];
    nav.title=@"用户信息";
    nav.customNav_delegate=self;
    [self.view addSubview:nav];
}
-(void)createCustomLogoutView
{
    CustomLogoutView *logout=[[CustomLogoutView alloc] initWithFrame:CGRectMake(0, LOGOUTVIEW_X, self.view.frame.size.width, self.view.frame.size.height-LOGOUTVIEW_X)];
    logout.logout_delegate=self;
    [self.view addSubview:logout];
    
}

#pragma mark customNavatonBar delegate method
-(void)getClick:(UIButton *)btn
{
    //返回
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)getLogoutClick:(UIButton *)btn
{
    //用户退出,1.清除掉本地保存的用户名和密码 2.通知服务器用户退出
    //http://s-115744.gotocdn.com:8296/index.php?c=passportctrl&m=logout
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userInfoName"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userinfoPassword"];
	[[NSUserDefaults standardUserDefaults] synchronize];
    
    LogoutModel *logout=[[LogoutModel alloc] init];
    logout.logout_delegate=self;
    [logout logout];
    
    
}
#pragma mark logout delegate method
-(void)logoutMessage:(NSString *)msg
{
            if ([msg isEqualToString:@"success"])
            {
                //登出成功
                //弹出窗口提示用户登出成功，然后跳转到更多页面
                self.promptLable=[[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width-PROMPTVIEW_WIDTH)/2, self.view.frame.size.height-PROMPTVIEW_HEIGHT-DISTANCE, PROMPTVIEW_WIDTH, PROMPTVIEW_HEIGHT)];
                self.promptLable.text=@"登出成功";
                self.promptLable.font=[UIFont systemFontOfSize:12.0f];
                self.promptLable.backgroundColor=[UIColor lightGrayColor];
                [self.view addSubview:self.promptLable];
                //
                NSTimer *myTimer = [NSTimer  timerWithTimeInterval:2.0 target:self selector:@selector(timeFired)userInfo:nil repeats:NO];
                [[NSRunLoop  currentRunLoop] addTimer:myTimer forMode:NSDefaultRunLoopMode];
                //
                NSTimer *Timer = [NSTimer  timerWithTimeInterval:0.4 target:self selector:@selector(changeAlpha)userInfo:nil repeats:YES];
                [[NSRunLoop  currentRunLoop] addTimer:Timer forMode:NSDefaultRunLoopMode];
    
            }
            else
            {
                //提示用户登出失败
                CGSize feelSize = [msg sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(190,200)];
                float  feelHeight = feelSize.height;
                UILabel *promptLable=[[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width-PROMPTVIEW_WIDTH)/2, self.view.frame.size.height-PROMPTVIEW_HEIGHT, feelHeight, PROMPTVIEW_HEIGHT)];
                promptLable.text=@"登出成功";
                promptLable.font=[UIFont systemFontOfSize:12.0f];
                promptLable.backgroundColor=[UIColor lightGrayColor];
                [NSThread sleepForTimeInterval:5.0];
                [promptLable removeFromSuperview];
                
                

            }
}
-(void)timeFired
{
   
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)changeAlpha
{
    self.promptLable.alpha=alpha;
    alpha=alpha-0.02;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
