//
//  MoreViewController.m
//  ebooksystem
//
//  Created by wanghaoyu on 14-9-22.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import "MoreViewController.h"

#import "Config.h"

#import "CustomNavigationBar.h"
#import "CustomMoreView.h"
//#import "MainViewController.h"
#import "UMFeedbackViewController.h"
#import "AboutUsViewController.h"

#import "LoginViewController.h"
#import "LogoutViewController.h"
#import "RechargeViewController.h"
#import "UIColor+Hex.h"
#import "PurchaseViewController.h"

#import "StatisticsManager.h"
#import "UIColor+Hex.h"
#import "UserManager.h"
#import "LogUtil.h"
//#import "MobClick.h"
#import "UpdateManager.h"
#import "UpdateAppViewController.h"

#import "CommonWebViewController.h"
#import "AliPayViewController.h"

//#define UMENG_APPKEY @"5420c86efd98c51541017684"

@interface MoreViewController () <CustomNavigationBarDelegate,CustomMoreViewDelegate,UserManagerDelegate,UpdateManagerDelegate,UIAlertViewDelegate>

@property(nonatomic,strong) CustomNavigationBar *navBar;
@property(nonatomic,strong) CustomMoreView *moreView;
@property(nonatomic,strong) UserManager *manage;
@property(nonatomic,strong) UpdateManager *updatemanager;

// 新版app下载地址
@property (nonatomic, copy) NSString *higherVersionAppDownloadUrl;

@end


@implementation MoreViewController

@synthesize higherVersionAppDownloadUrl;



#pragma mark - app events
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexString:@"#242021" alpha:1];
    [self addNavigationBar];
    [self addCustomMoreview];
    [self getNewBalance];
    self.manage = [UserManager shareInstance];
    self.manage.upDateBalance_delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
    [super viewWillAppear:animated];
    
    [[StatisticsManager instance] beginLogPageView:@"PageMore"];
    
    if (self.moreView.menuStyle == MENU_STYLE_OLD) {
        // 用户信息
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userInfoName"]) {
            self.moreView.userNameLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"userInfoName"];
        }
        else {
            self.moreView.userNameLabel.textColor = [UIColor colorWithHexString:@"aaaaaa" alpha:1];
            self.moreView.userNameLabel.text = @"登录体验更多精彩内容";
        }
        
        // 余额
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"surplus_score"]) {
            self.moreView.lable.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"surplus_score"];
        }
        else {
            self.moreView.lable.text = @"0.00";
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[StatisticsManager instance] endLogPageView:@"PageMore"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 添加自定义控件
-(void)addNavigationBar {
    self.navBar = [[CustomNavigationBar alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 50)];
    self.navBar.title = @"更多";
    self.navBar.customNav_delegate = self;
    [self.view addSubview:self.navBar];
}

-(void)addCustomMoreview {
    self.moreView = [[CustomMoreView alloc] initWithFrame:CGRectMake(0, 70, self.view.frame.size.width, self.view.frame.size.height - 70)];
    self.moreView.more_delegate = self;
    [self.view addSubview:self.moreView];
}

#pragma mark - CustomNavigationBar delegate method
-(void)getClick:(UIButton *)btn {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - CustomMoreView delegate method

// 点击某item后的响应
- (void)viewItemClicked:(ViewItemId)viewItemId {
    switch (viewItemId) {
        case VIEW_ITEM_USER_INFO_VIA_WEB:
        {
            CommonWebViewController *webViewController = [[CommonWebViewController alloc] init];
            webViewController.url = [Config instance].userConfig.urlForUserInfo;
            [self.navigationController pushViewController:webViewController animated:YES];
        }
            break;
            
        case VIEW_ITEM_USER_INFO_VIA_NATIVE:
        {
            //　登入/登出
            // 登出
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userInfoName"] != NULL) {
                // 进入到用户信息界面,
                // 只要登陆成功了，本地就会存储相关的用户名和密码
                // 因此需要退出登录时把本地的数据置为空
                
                // native logout
                LogoutViewController *logout = [[LogoutViewController alloc] init];
                [self.navigationController pushViewController:logout animated:YES];
            }
            // 登入
            else {
                self.moreView.userNameLabel.text = @"登录";
                
                // native login
                LoginViewController *login = [[LoginViewController alloc] init];
                [self.navigationController pushViewController:login animated:YES];
            }
        }
            break;
            
        case VIEW_ITEM_USER_CHARGE:
        {
            // 进行正版验证
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userInfoName"]) {
                RechargeViewController *recharge=[[RechargeViewController alloc] init];
                [self.navigationController pushViewController:recharge animated:YES];
            }
            else {
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"您还没有登录,请您先登录" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                //                    alert.backgroundColor=[UIColor lightGrayColor];
                [alert show];
            }
        }
            break;
            
        case VIEW_ITEM_PURCHASE:
        {
            // 购买干货书籍
            PurchaseViewController *purchase=[[PurchaseViewController alloc] init];
            [self.navigationController pushViewController:purchase animated:YES];
        }
            break;
            
        case VIEW_ITEM_FEEDBACK:
        {
            // 意见反馈
            [self showNativeFeedbackWithAppkey:[[StatisticsManager instance] appKeyFromUmeng]];
        }
            break;
            
        case VIEW_ITEM_CHECK_APP_UPDATE:
        {
            // 软件更新
            self.updatemanager=[UpdateManager instance];
            self.updatemanager.delegate=self;
            [self.updatemanager checkUpdate];
        }
            break;
            
        case VIEW_ITEM_ABOUT_APP:
        {
            // 关于
            AboutUsViewController *aboutUsview = [[AboutUsViewController alloc] init];
            [self.navigationController pushViewController:aboutUsview animated:YES];
        }
            break;
            
        case VIEW_ITEM_TEST:
        {
            // 测试
            [self toAlipay];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - UMdelegate
- (void)showNativeFeedbackWithAppkey:(NSString *)appkey {
    UMFeedbackViewController *feedbackViewController = [[UMFeedbackViewController alloc] initWithNibName:@"UMFeedbackViewController" bundle:nil];
    feedbackViewController.appkey = appkey;
    //    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:feedbackViewController];
    //    navigationController.navigationBar.barStyle = UIBarStyleBlack;
    //    navigationController.navigationBar.translucent = NO;
    //    [self presentModalViewController:navigationController animated:YES];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController pushViewController:feedbackViewController animated:YES];
}


#pragma mark updateManager delegate method
-(void)onCheckUpdateResult:(UpdateInfo *)updateInfo
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *status=updateInfo.status;
        if ([status isEqualToString:@"0"])
        {
            NSString *shouldUpdate=updateInfo.shouldUpdate;
            if ([shouldUpdate isEqualToString:@"NO"])
            {
                self.moreView.updateLable.text=@"当前已经是最新版本";
            }
            else
            {
                self.moreView.updateLable.text=@"检测到新版本";
                
                self.higherVersionAppDownloadUrl = updateInfo.appDownloadUrl;
                
                
                //            NSLog(@"appDownloadUrl====%@",updateInfo.appDownloadUrl);
                NSString *desc=updateInfo.appVersionDesc;
                NSString *version=updateInfo.appVersionStr;
                NSString *title=[NSString stringWithFormat:@"有新版本可供更新%@",version];
                NSString *msg=[NSString stringWithFormat:@"更新信息：%@",desc];
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"忽略" otherButtonTitles:@"更新", nil];
                [alert show];
            }
        }
        else
        {
            LogError(@"检查版本更新出错");
        }
    });
}

#pragma mark alertView delegate method
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (higherVersionAppDownloadUrl == nil) {
        return;
    }
    
    if (buttonIndex !=alertView.cancelButtonIndex) {
//        [self.navigationController pushViewController:self.updateApp animated:YES];
        NSURL *requestURL = [NSURL URLWithString:[self.higherVersionAppDownloadUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        [[UIApplication sharedApplication] openURL:requestURL];
    }
    
}




#pragma mark 每次进入到menu都要获取最新的余额
-(void)getNewBalance
{
    NSString *userName=[[NSUserDefaults standardUserDefaults]objectForKey:@"userInfoName"];
    if (userName==nil || [userName isEqualToString:@""] ||[[NSUserDefaults standardUserDefaults] objectForKey:@"userInfoName"]==NULL)
    {
         LogWarn(@"当前无用户，所以无法取到余额信息");
        
    }
    else
    {
       
        UserManager *manager=[UserManager shareInstance];
        [manager getBalance];
        LogWarn(@"最新的余额是%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"surplus_score"]);
    }
   
}
#pragma mark updateBalabce delegate method
-(void)upDateBalance:(NSString *)balance
{
    
    self.moreView.lable.text=[[NSUserDefaults standardUserDefaults] objectForKey:@"surplus_score"];
}
#pragma mark test alipay
-(void)toAlipay
{
    AliPayViewController *alipay=[[AliPayViewController alloc] init];
    [self.navigationController pushViewController:alipay animated:YES];
    
}

@end
