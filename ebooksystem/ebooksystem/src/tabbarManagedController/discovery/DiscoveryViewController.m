//
//  DiscoveryViewController.m
//  ebooksystem
//
//  Created by wanghaoyu on 15/1/9.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import "DiscoveryViewController.h"
#import "discoveryWebView.h"
#import "discoveryModel.h"
#import "RenderKnowledgeViewController.h"
#import "UpdateManager.h"
#import "LogUtil.h"
#import "SubjectChoose.h"
#import "NSUserDefaultUtil.h"
#import "ErrorManager.h"
#import "DeviceStatusUtil.h"

#import "CustomPromptView.h"


@interface DiscoveryViewController ()<discoverDelegate,UpdateManagerDelegate, UIAlertViewDelegate,SubjectChooseDelegate>
{
    NSTimer *timer;
}

@property (nonatomic,strong) discoveryWebView *discoverWeb;
@property (nonatomic,strong) NSString *updateAppURL;
@property (nonatomic,strong) SubjectChoose *subjectChooseView;

//
@property (nonatomic,strong) CustomPromptView *promptView;

@end

@implementation DiscoveryViewController


#pragma mark  - app life
- (void)viewDidLoad {
    [super viewDidLoad];
//    self.tabBarController.selectedIndex = 2;
    //消除状态栏的20像素差
    self.automaticallyAdjustsScrollViewInsets = NO;
   //隐藏掉状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:TRUE];
    //判断是否是第一次加载
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]) {
        self.tabBarController.tabBar.hidden = YES;
        [self makeSelectView];
    }
    else {
        //加载发现页
        [self makeWebView];
        //检查更新
        [self updateApp];
    }
    
    //判断当前网络连接
    DeviceStatusUtil *cruDeviceStatus = [[DeviceStatusUtil alloc] init];
    NSString *CruStatus = [cruDeviceStatus GetCurrntNet];
    if ([CruStatus isEqualToString:@"no connect"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"网络不给力，请检查网络连接后重试" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"好", nil];
        [alert show];
        //1 创建提示界面
        [self createNoConnectPromptView];
        
        //2 开定时器，不断刷新，检测到网络连接后，重新加载webview
        timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(haveConnected) userInfo:nil repeats:YES];
        
    }
    
}



- (void)viewWillAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:TRUE];

}
- (void)viewDidAppear:(BOOL)animated {
    // 回发error log
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[ErrorManager instance] sendCrashToServer];
    });

}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    /*
    NSLog(@"DiscoveryViewController didReceiveMemoryWarning");
    
    if (self.isViewLoaded && self.view.window == nil) {
        self.view = nil;
        NSLog(@"DiscoveryViewController warning");
    }
     */
}

#pragma mark 创建提示界面
- (void)createNoConnectPromptView {
    
    self.promptView = [[CustomPromptView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height -44)];
    [self.view addSubview:self.promptView];
    
}

#pragma mark 不断检测网络状态
- (void)haveConnected {
    DeviceStatusUtil *device = [[DeviceStatusUtil alloc] init];
    NSString *cruStatus = [device GetCurrntNet];
    if (![cruStatus isEqualToString:@"no connect"]) {
        //有网络
        //移除掉提示视图
        [self.promptView removeFromSuperview];
        //移除掉已有的视图
        [self.discoverWeb removeFromSuperview];
        //添加新的视图
        [self makeWebView];
        //关闭定时器
        [timer invalidate];
        timer = nil;
       
    }
}


#pragma mark - 创建要显示的视图

//创建webview
- (void)makeWebView {
     self.discoverWeb = [[discoveryWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-48)];
    self.discoverWeb.discoverDelegate = self;
    [self.view addSubview:self.discoverWeb];
}

//创建选择view
- (void)makeSelectView {

    self.subjectChooseView = [[SubjectChoose alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-48)];
    self.subjectChooseView.userSelectedDelegate = self;
    [self.view addSubview:self.subjectChooseView];
}


#pragma mark discoveryView delegate method

//在发现页开新的controller
- (void)showSafeUrl:(NSString *)url {
    RenderKnowledgeViewController *render = [[RenderKnowledgeViewController alloc] init];
    render.webUrl = url;
    render.flag = @"discovery";
    [self.navigationController pushViewController:render animated:YES];
}

//切换视图，从nav中退出
- (void)controllerSwitchOver {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)test {
    NSArray *arr = [NSArray arrayWithObjects:@"test_book_4", nil];
    discoveryModel *disMod = [[discoveryModel alloc] init];
    [disMod getBookInfoWithDataIds:arr];
}


#pragma  mark updatemanager delegate method 

#pragma mark - 更新
- (void)updateApp {
    [UpdateManager instance].delegate = self;
    [[UpdateManager instance] checkUpdate];
}

- (void)onCheckUpdateResult:(UpdateInfo *)updateInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *status=updateInfo.status;
        if ([status isEqualToString:@"0"]) {
            NSString *shouldUpdate=updateInfo.shouldUpdate;
            //将
            if ([shouldUpdate isEqualToString:@"NO"]) {
                LogInfo(@"已经是最新版本");
            }
            else {
                
                //            LogDebug(@"appDownloadUrl====%@",updateInfo.appDownloadUrl);
                self.updateAppURL=updateInfo.appDownloadUrl;
                NSString *desc=updateInfo.appVersionDesc;
                NSString *version=updateInfo.appVersionStr;
                NSString *title=[NSString stringWithFormat:@"有新版本可供更新%@",version];
                NSString *msg=[NSString stringWithFormat:@"更新信息：%@",desc];
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"忽略" otherButtonTitles:@"更新", nil];
                [alert show];
            }
        }
        else {
            LogError(@"检查版本更新出错");
        }
    });
}

#pragma mark alertView delegate method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        //        [self.navigationController pushViewController:self.updateApp animated:YES];
        NSURL *requestURL = [NSURL URLWithString:[self.updateAppURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        [[UIApplication sharedApplication] openURL:requestURL];
    }
}




#pragma mark subjectChoose delegate method 
- (void)setUserSelectedResult:(NSString *)result {
    
    if ([result isEqualToString:@"考研"]) {
        [NSUserDefaultUtil setCurStudyTypeWithType:@"0"];
    }
    else if ([result isEqualToString:@"教师资格证"]) {
        [NSUserDefaultUtil setCurStudyTypeWithType:@"1"];
    }
    [self.subjectChooseView removeFromSuperview];
    self.tabBarController.tabBar.hidden = NO;
    //创建新的页面
    [self makeWebView];
    
}

@end
