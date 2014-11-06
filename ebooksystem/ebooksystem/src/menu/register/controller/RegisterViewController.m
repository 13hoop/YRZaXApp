//
//  RegisterViewController.m
//  ebooksystem
//
//  Created by wanghaoyu on 14-10-2.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import "RegisterViewController.h"
#import "CustomNavigationBar.h"
#import "MoreViewController.h"
#import "RegisterModel.h"
#import "CustomRegisterView.h"
#import "RegisterUserInfo.h"
#import "MoreViewController.h"
#import "LogUtil.h"
#import "UIColor+Hex.h"

#define REGISTERVIEW_X 70
@interface RegisterViewController ()<CustomNavigationBarDelegate,CustomRegisterViewDelegate,RegisterModelDelegate>

@property(nonatomic,strong)CustomNavigationBar *navBar;
@property(nonatomic,strong)NSMutableArray *usedUserArray;
@end

@implementation RegisterViewController

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
    self.usedUserArray=[NSMutableArray array];
    self.view.backgroundColor=[UIColor colorWithHexString:@"#242021" alpha:1];
    [self addNavigationBar];
    [self createRegisterView];
}
-(void)addNavigationBar
{
    
    self.navBar=[[CustomNavigationBar alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 50)];
    self.navBar.title=@"新用户注册";
    self.navBar.customNav_delegate=self;
    [self.view addSubview:self.navBar];
}
#pragma mark customNavgationBar delegate method
-(void)getClick:(UIButton *)btn
{
    //navigationControler pop到指定的页面上
    NSArray *controllerArr=self.navigationController.viewControllers;
    [self.navigationController popViewControllerAnimated:YES];
//    [self.navigationController popToViewController:[controllerArr objectAtIndex:1] animated:YES];
}

#pragma mark create customregisterView
-(void)createRegisterView
{
    CustomRegisterView *registerView=[[CustomRegisterView alloc] initWithFrame:CGRectMake(0, REGISTERVIEW_X, self.view.frame.size.width, self.view.frame.size.height-REGISTERVIEW_X)];
    registerView.register_delegate=self;
    [self.view addSubview:registerView];
}



#pragma mark customRegisterView delegate method
-(void)registerClick:(RegisterUserInfo *)userInfo
{
    NSLog(@"将自定义控件中的注册信息传递到了controller中username====%@",userInfo.userName);
    RegisterModel *model=[[RegisterModel alloc] init];
    model.register_delegate=self;
    [model getUserInfo:userInfo];
    [model getPublickey];
    
    
}
#pragma mark registerModel delegate method
-(void)registerMessage:(NSDictionary *)data anduserInfo:(RegisterUserInfo *)userInfo
{
    NSString *status=data[@"status"];
    NSLog(@"status===%@",status);
    NSInteger statusInteger=[status integerValue];
    NSLog(@"statusInteger====%d",statusInteger);
    if (statusInteger<0 || data[@"msg"]==NULL || [data[@"msg"] isEqualToString:@"success"]==NO) {
        //注册失败
        LogError(@"register failed because of %@",data[@"msg"]);
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"错误提示" message:data[@"msg"] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"重新输入", nil];
        [alert show];
        
    }
    else
    {
        
        //添加新用户到（保存登陆过本台设备的用户数组）数组中----加密----------
        //成为当前用户
        NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
        [userDefaults setObject:userInfo.userName forKey:@"userInfoName"];
        [userDefaults setObject:userInfo.passWord forKey:@"userinfoPassword"];
        [userDefaults setObject:userInfo.email forKey:@"userInfoEmail"];
        //save usedUserArray
        NSDictionary *userInfoDic=@{@"userInfoName":userInfo.userName,@"userinfoPassword":userInfo.passWord,@"userInfoEmail":userInfo.email};
        [self.usedUserArray addObject:userInfoDic];
        [userDefaults setObject:self.usedUserArray forKey:@"usedUserArray"];
        [userDefaults synchronize];
        // navigationControler pop  moreviewcontroller
        NSArray *controllerArr=self.navigationController.viewControllers;
        
        [self.navigationController popToViewController:controllerArr[2] animated:YES];

    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
