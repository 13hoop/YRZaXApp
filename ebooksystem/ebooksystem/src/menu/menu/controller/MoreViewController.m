//
//  MoreViewController.m
//  ebooksystem
//
//  Created by wanghaoyu on 14-9-22.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import "MoreViewController.h"
#import "CustomNavigationBar.h"
#import "CustomMoreView.h"
//#import "MainViewController.h"
#import "UMFeedbackViewController.h"
#import "AboutUsViewController.h"
#import "MobClick.h"

#import "LoginViewController.h"
#import "LogoutViewController.h"

#define UMENG_APPKEY @"5420c86efd98c51541017684"

@interface MoreViewController ()<CustomNavigationBarDelegate,CustomMoreViewDelegate>

@property(nonatomic,strong)CustomNavigationBar *navBar;
@property(nonatomic,strong)CustomMoreView *moreView;

@end


@implementation MoreViewController

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
    self.view.backgroundColor=[UIColor whiteColor];
    [self addNavigationBar];
    [self addCustomMoreview];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"PageMore"];
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"userInfoName"]!=NULL)
    {
        self.moreView.userNameLable.text=[[NSUserDefaults standardUserDefaults] objectForKey:@"userInfoName"];
    }
    else
    {
        self.moreView.userNameLable.text=@"登录";
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"PageMore"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 添加自定义控件
-(void)addNavigationBar {
    self.navBar = [[CustomNavigationBar alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 44)];
    self.navBar.title = @"更多";
    self.navBar.customNav_delegate = self;
    [self.view addSubview:self.navBar];
}

-(void)addCustomMoreview {
    self.moreView = [[CustomMoreView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64)];
    self.moreView.more_delegate = self;
    [self.view addSubview:self.moreView];
}

#pragma mark - CustomNavigationBar delegate method
-(void)getClick:(UIButton *)btn {
    // 一层层往回撤
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - CustomMoreView delegate method
-(void)getSelectIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    switch (section) {
        case 0:
            //进入到登陆界面
            if (row==0) {
                if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userInfoName"]!=NULL) {
                    //进入到用户信息界面,
                    //只要登陆成功了，本地就会存储相关的用户名和密码
                    //因此需要退出登录时把本地的数据置为空
                    LogoutViewController *logout=[[LogoutViewController alloc] init];
                    [self.navigationController pushViewController:logout animated:YES];
                    
                }
                else
                {
                    LoginViewController *login=[[LoginViewController alloc] init];
                    [self.navigationController pushViewController:login animated:YES];
                    

                }
                
                            }
            break;
        case 1:
            if (row == 0) {
                //进行正版验证
            }
            break;
        case 2:
            if (row == 0) {
                //意见反馈
                [self showNativeFeedbackWithAppkey:UMENG_APPKEY];
            }
            else {
                if (row == 1) {
                    //软件更新
                    [MobClick checkUpdate:@"新版本" cancelButtonTitle:@"稍后更新" otherButtonTitles:@"立即更新"];
                    //软件更新自定义
                    [MobClick checkUpdateWithDelegate:self selector:@selector(appUpdate:)];
                }
                else {
                    //关于
                    AboutUsViewController *aboutUsview = [[AboutUsViewController alloc] init];
                    [self.navigationController pushViewController:aboutUsview animated:YES];
                }
                
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

//自动更新会将这个方法作为参数传到mobclick中
- (void)appUpdate:(NSDictionary *)appInfo {
    //在这里面修改cell上面的lable的显示
    //定制alertView在这里面实现
    NSLog(@"appInfo==%@",appInfo);
    
}

@end
