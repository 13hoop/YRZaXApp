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

#import "SecurityUtil.h"
#import "GTMBase64.h"
#import "NSString+Hashing.h"
#import "UIDevice+IdentifierAddition.h"
#import "SBJson.h"
//#import "AFHTTPClient.h"
#import "AFNetworking.h"
#import "UIKit+AFNetworking.h"
#import "AFHTTPRequestOperation.h"

#import "MoreViewController.h"
#import "CustomMoreView.h"
#import "CustomGetUserInfoModel.h"

#import "LogUtil.h"



#define CUSTOMVIEW_X 64
@interface LoginViewController ()<CustomNavigationBarDelegate,CustomLoginNavgationBarDelegate,CustomLoginViewDelegate,CustomGetUserInfoModelDelegate>

{
//    AFHTTPClient *_client;
}
@property(nonatomic,strong)CustomLoginNavgationBar *navBar;
@property(nonatomic,strong)NSString *userName;
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
    dispatch_queue_t t=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(t, ^{
    [self Encryption:model];
    });
}

//加密
- (void) Encryption:(CustomLoginModel*)model
{
        //将object对象转成json
        SBJsonWriter *jsonWriter=[[SBJsonWriter alloc] init];
        NSError *error;
        //kmlin b
        self.userName=model.userName;
        NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:model.userName,@"user_name",model.passWord,@"pwd",nil];
        NSString *jsonString=[jsonWriter stringWithObject:dic error:&error];
        NSString *string=[SecurityUtil AES128Encrypt:jsonString andwithPassword:model.passWord];
        //拿到每台设备的唯一标识
        NSString *identifier = [[UIDevice currentDevice] uniqueDeviceIdentifier];
        [self btnDown:string andWithId:identifier andWithUserModel:model];
}

-(void)btnDown:(NSString*)jsonString andWithId:(NSString *)device_id andWithUserModel:(CustomLoginModel*)model
{

    AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes=[NSSet setWithObject:@"text/html"];
    NSDictionary *parameters=@{@"encrypt_method":@"2",@"encrypt_key_type":@"2",@"user_name":self.userName,@"device_id":device_id,@"data":jsonString};
    [manager POST:@"http://s-115744.gotocdn.com:8296/index.php?c=passportctrl&m=login" parameters:parameters success:^(AFHTTPRequestOperation *operation,id responsrObject){
               NSDictionary *dic=responsrObject;
                LogDebug(@"dic=====%@",dic);
                NSString *dataStr=dic[@"data"];
                NSData *dataData=[dataStr dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *data=[NSJSONSerialization JSONObjectWithData:dataData options:0 error:nil];
                //*********测试********
                LogDebug(@"登陆成功服务器返回的信息msg===%@",data[@"msg"]);
              if ([data[@"msg"] isEqualToString:@"success"]) {
                    LogDebug(@"登录成功");
                    //登录成功后要把数据保存在本地，在用户信息中可以读取这些数据，并返回到更多页面
                    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
                    [userDefaults setObject:model.userName forKey:@"userInfoName"];
                    [userDefaults setObject:model.passWord forKey:@"userinfoPassword"];
                    [userDefaults synchronize];
                    LogDebug(@"model.user===%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userInfoName"]);
        
                    //这样修改不了，上个视图中的值，而是新实例化了一个对象，把值赋值给了这个新的对象，再返回到原来的页面就不会有变化。----怎么办？
                    //实例化自定义的视图，为了改变视图里面的userName属性值，目的就是为了修改登录的值
                    CustomMoreView *moreview=[[CustomMoreView alloc] init];
                    moreview.userName=[[NSUserDefaults standardUserDefaults] objectForKey:@"userInfoName"];
                    LogDebug(@"使用kvo后，给赋值%@",moreview.userName);
                  
                  //再次发起网络请求
                  [self getUserInfo];
                
                }
                else
                {
                    //弹出对话框来显示提示用户错误信息
                    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"错误提示" message:data[@"msg"] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"重新输入", nil];
                    [alert show];
               }
       
            } failure:^(AFHTTPRequestOperation *operation,NSError *error){
                LogDebug(@"登陆失败");
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"网络状况不佳，请设置您的网络" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"重试", nil];
                [alert show];
            }];
    
}


-(void)getUserInfo
{
   
        CustomGetUserInfoModel *userinfo=[[CustomGetUserInfoModel alloc] init];
        userinfo.userInfo_delegate=self;
        [userinfo getUserInfo];

   
}
#pragma mark userInfo delegate method
-(void)getUserinfo:(NSString *)userInfo
{
    //获取到余额信息
    LogDebug(@"%@",userInfo);
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    [userDefaults setObject:userInfo forKey:@"surplus_score"];
    [userDefaults synchronize];
    [self.navigationController popViewControllerAnimated:YES];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
