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
#import "AFHTTPClient.h"
#import "MoreViewController.h"
#import "CustomMoreView.h"

#define CUSTOMVIEW_X 64
@interface LoginViewController ()<CustomNavigationBarDelegate,CustomLoginNavgationBarDelegate,CustomLoginViewDelegate>

{
    AFHTTPClient *_client;
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
    [self Encryption:model];
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
        NSLog(@"jsonString==%@",jsonString);
    
        
        NSString *string=[SecurityUtil AES128Encrypt:jsonString andwithPassword:@"b"];
        NSLog(@"json格式的数据是：%@",string);
    
        //拿到每台设备的唯一标识
        NSString *identifier = [[UIDevice currentDevice] uniqueDeviceIdentifier];
        [self btnDown:string andWithId:identifier andWithUserModel:model];
        
    
    
}
//测试使用，调这个方法
-(void)btnDown:(NSString*)jsonString andWithId:(NSString *)device_id andWithUserModel:(CustomLoginModel*)model
{
    //@"c":@"passportctrl",@"m":@"login",
    //http://zaxue100.com/index.php?c=passportctrl&m=login
    //http://s-115744.gotocdn.com:8296/index.php?c=passportctrl&m=login
    //SFcdjqi5T5DAtE4HVVLNb4EfcuEP/mx5c88AWVWgHKLUAn4xKn19kIi7WeUGOfax
    _client=[[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://s-115744.gotocdn.com:8296/index.php?c=passportctrl&m=login"]];
    [_client postPath:nil parameters:@{@"encrypt_method":@"2",@"encrypt_key_type":@"2",@"user_name":self.userName,@"device_id":device_id,@"data":jsonString} success:^(AFHTTPRequestOperation *operation,id responsrObject){
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responsrObject options:0 error:nil];
        NSString *dataStr=dic[@"data"];
        NSData *dataData=[dataStr dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *data=[NSJSONSerialization JSONObjectWithData:dataData options:0 error:nil];
        //*********测试********
        NSLog(@"登陆成功服务器返回的信息msg===%@",data[@"msg"]);
        NSLog(@"网络请求回来的值是%@",dic);
        if ([data[@"msg"] isEqualToString:@"success"]) {
            NSLog(@"登录成功");
            //登录成功后要把数据保存在本地，在用户信息中可以读取这些数据，并返回到更多页面
            [[NSUserDefaults standardUserDefaults] setObject:model.userName forKey:@"userInfoName"];
            [[NSUserDefaults standardUserDefaults] setObject:model.passWord forKey:@"userinfoPassword"];
            NSLog(@"model.user===%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userInfoName"]);
            
            //这样修改不了，上个视图中的值，而是新实例化了一个对象，把值赋值给了这个新的对象，再返回到原来的页面就不会有变化。----怎么办？
            //实例化自定义的视图，为了改变视图里面的userName属性值，目的就是为了修改登录的值
            CustomMoreView *moreview=[[CustomMoreView alloc] init];
            moreview.userName=[[NSUserDefaults standardUserDefaults] objectForKey:@"userInfoName"];
            NSLog(@"使用kvo后，给赋值%@",moreview.userName);
            [self.navigationController popViewControllerAnimated:YES];
            
        }
        else
        {
            //弹出对话框来显示提示用户错误信息
            NSLog(@"登陆失败服务器返回的信息msg===%@",data[@"msg"]);

        }
//        NSLog(@"str==%@",[[NSString alloc] initWithData:responsrObject encoding:NSUTF8StringEncoding]);
    } failure:^(AFHTTPRequestOperation *operation,NSError *error){
        NSLog(@"登陆失败");
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
