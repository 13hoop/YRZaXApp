//
//  RechargeViewController.m
//  ebooksystem
//
//  Created by wanghaoyu on 14-10-8.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import "RechargeViewController.h"
#import "CustomRechargeView.h"
#import "CustomNavigationBar.h"
#import "RechargeModel.h"
#import "UserManager.h"
#import "UIColor+Hex.h"
#import "UserManager.h"



#define TABLEVIEW_Y 64
#define NAVBAR_HEIGHT 44 
#define NAVBAR_Y 20 
#define NAVBAR_X 0
@interface RechargeViewController ()<CustomNavigationBarDelegate,CustomRechargeViewDelegate,RechargeModelDelegate,UserManagerDelegate>


@property(nonatomic,strong)CustomRechargeView *rechargeView;
@property(nonatomic,strong)CustomNavigationBar *navBar;
@end

@implementation RechargeViewController

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
    self.view.backgroundColor=[UIColor colorWithHexString:@"#242021" alpha:1];
    [self createCustomNavigationBar];
    [self createCustomRechargeView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark create navgationBar
-(void)createCustomNavigationBar
{
    self.navBar=[[CustomNavigationBar alloc] initWithFrame:CGRectMake(NAVBAR_X,NAVBAR_Y, self.view.frame.size.width,NAVBAR_HEIGHT)];
    self.navBar.customNav_delegate=self;
    self.navBar.title=@"输入验证码";
    [self.view addSubview:self.navBar];
}
-(void)createCustomRechargeView
{
    self.rechargeView=[[CustomRechargeView alloc] initWithFrame:CGRectMake(NAVBAR_X,TABLEVIEW_Y, self.view.frame.size.width, self.view.frame.size.height-TABLEVIEW_Y)];
    self.rechargeView.recharge_delegate=self;
    [self.view addSubview:self.rechargeView];
    
}
#pragma mark customNavgationBar delegate method
-(void)getClick:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark customRechargeView delegate method
-(void)getRechargeClick:(NSString *)cardID
{
    //发起网络请求--开线程
    
//    RechargeModel *model=[[RechargeModel alloc] init];
//    model.recharge_delegate=self;
//
//    [model getRecharge:cardID];
    UserManager *manager=[UserManager shareInstance];
    manager.recharge_delegate=self;
    [manager getRecharge:cardID];
    
}
#pragma mark userManager Delegate method
-(void)getRechargeMessage:(NSString *)msg
{
    
    NSString *message=nil;
    if ([msg isEqualToString:@"success"]) {
        message=@"充值成功";
        UserManager *manager=[UserManager shareInstance];
        manager.balance_delegate=self;
        [manager getUserInfo];
        NSLog(@"余额信息====%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"surplus_score"]);
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        message=msg;
    }
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"充值信息" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    alert.backgroundColor=[UIColor lightGrayColor];
    [alert show];
    
}
@end
