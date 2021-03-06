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
#import "UserManager.h"
#import "UserInfo.h"
#import "DeviceUtil.h"
#import "DeviceStatusUtil.h"
#import "LogUtil.h"
#import "UIColor+Hex.h"

#import "LogUtil.h"


#define CUSTOMVIEW_X 70
@interface LoginViewController ()<CustomNavigationBarDelegate,CustomLoginNavgationBarDelegate,CustomLoginViewDelegate,UserManagerDelegate>

{
//    AFHTTPClient *_client;
    NSUInteger index;
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
    index=0;
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor colorWithHexString:@"#242021" alpha:1];
    [self addNavigationBar];
    [self createLoginView];
    [self testNetStatus];
    
}

-(void)addNavigationBar
{
    
    self.navBar=[[CustomLoginNavgationBar alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 50)];
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
    
    //
    [self testUserManager];
    
    
}
#pragma mark customLoginview delegate method
-(void)loginClick:(CustomLoginModel*)model
{
    BOOL isExist=NO;
    DeviceStatusUtil *device=[[DeviceStatusUtil alloc] init];
    NSString *currentNetStatus=[device GetCurrntNet];
    // 检测当前网络状态
    if ([currentNetStatus isEqualToString:@"no connect"]==YES) {
        //本地登陆
        UserManager *manager=[UserManager shareInstance];
        NSMutableArray *userArray=[manager getUsers];
        for (NSDictionary *tempDic in userArray)
        {
            if ([tempDic[@"userInfoName"] isEqualToString:model.userName]==YES && [tempDic[@"userinfoPassword"] isEqualToString:model.passWord]==YES)
            {
                isExist=YES;
                break;
            }
        }
        
        if (isExist==YES)
        {
            NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
            [userDefaults setObject:model.userName forKey:@"userInfoName"];
            [userDefaults setObject:model.passWord forKey:@"userinfoPassword"];
            [userDefaults synchronize];
            //本地登陆成功
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"错误提示" message:@"用户名或密码错误，请检查后重新输入或打开网络注册" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"立即检查", nil];
            [alert show];
        }
    }
    else
    {
        //登陆操作
        dispatch_queue_t t=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(t, ^{
            [self Encryption:model];
        });
    }
    
   
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
        NSString *identifier =[DeviceUtil getVendorId];
        [self btnDown:string andWithId:identifier andWithUserModel:model];
    
}

-(void)btnDown:(NSString*)jsonString andWithId:(NSString *)device_id andWithUserModel:(CustomLoginModel*)model
{

    AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes=[NSSet setWithObject:@"text/html"];
    NSDictionary *parameters=@{@"encrypt_method":@"2",@"encrypt_key_type":@"2",@"user_name":self.userName,@"device_id":device_id,@"data":jsonString};

    [manager POST:@"http://zaxue100.com/index.php?c=passportctrl&m=login" parameters:parameters success:^(AFHTTPRequestOperation *operation,id responsrObject){
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
                  
                    //可变数组在遍历的时候不能进行删改的操作
                  
                  //save current userinfo
                    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
                    [userDefaults setObject:model.userName forKey:@"userInfoName"];
                    [userDefaults setObject:model.passWord forKey:@"userinfoPassword"];
                    [userDefaults synchronize];
                    LogDebug(@"model.user===%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userInfoName"]);
        
                  
                    CustomMoreView *moreview=[[CustomMoreView alloc] init];
                    moreview.userName=[[NSUserDefaults standardUserDefaults] objectForKey:@"userInfoName"];
                    LogDebug(@"使用kvo后，给赋值%@",moreview.userName);
                  
                  //再次发起网络请求--获取用户所有信息
                  UserManager *manager=[UserManager shareInstance];
                  manager.userInfo_delegate=self;
                  [manager getUserInfo];
//                  [self getUserInfo];
                
                }
                else
                {
                     LogError(@"login fail and receive message is %@",data[@"msg"]);
                    //弹出对话框来显示提示用户错误信息
                    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"错误提示" message:data[@"msg"] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"重新输入", nil];
                    [alert show];
               }
       
            } failure:^(AFHTTPRequestOperation *operation,NSError *error){
                LogDebug(@"登陆失败");
                LogError(@"net connect error");
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"网络状况不佳，请设置您的网络" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"重试", nil];
                [alert show];
            }];
    
}


#pragma mark userManager delegate method
-(void)getUserBalance:(NSString *)balance
{
    //获取到余额信息
    LogDebug(@"%@",balance);
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    [userDefaults setObject:balance forKey:@"surplus_score"];
    LogDebug(@"LOGINVIEWCONTROLLER=====%@",balance);
    [userDefaults synchronize];
    //
    UserInfo *userinfo=[[UserInfo alloc] init];
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    userinfo.username=[userDefault objectForKey:@"userInfoName"];
    userinfo.password=[userDefault objectForKey:@"userinfoPassword"];
    userinfo.email=[userDefault objectForKey:@"userInfoEmail"];
    userinfo.balance=[userDefault objectForKey:@"surplus_score"];
    
    UserManager *manager=[UserManager shareInstance];
    [manager saveUserInfo:userinfo];
    
    [self.navigationController popViewControllerAnimated:YES];
}

//***********test**********
-(void)testUserManager
{
    UserInfo *userinfo=[[UserInfo alloc] init];
    UserManager *manager=[UserManager shareInstance];
    userinfo.username=@"test";
    userinfo.password=@"123456";
    userinfo.balance=@"1000";
    userinfo.email=@"1223556769@qq.com";
    BOOL issave=[manager saveUserInfo:userinfo];
    LogDebug(@"issave=====%hhd",issave);
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    NSMutableArray *arr=[userDefault objectForKey:@"usedUserArray"];
    for (NSDictionary *dic in arr) {
        LogDebug(@"%@",dic[@"userInfoName"]);
    }
//    [manager removeAllUserInfo];
}

//test net status
-(void)testNetStatus
{
    DeviceStatusUtil *device=[[DeviceStatusUtil alloc] init];
    BOOL is=[device isHorizontalScreen];
    LogDebug(@"是否是横屏%hhd",is);
    CGSize ff=[DeviceStatusUtil screenSize];
    LogDebug(@"当前屏幕的高度是%f",ff.height);
    NSString *deviceStr=[device checkDevice];
    LogDebug(@"device===%@",deviceStr);
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
