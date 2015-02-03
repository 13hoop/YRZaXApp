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

@interface DiscoveryViewController ()<discoverDelegate,UpdateManagerDelegate, UIAlertViewDelegate>

@property (nonatomic,strong) discoveryWebView *discoverWeb;
@property(nonatomic,strong)NSString *updateAppURL;

@end

@implementation DiscoveryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.tabBarController.selectedIndex = 2;
    //消除状态栏的20像素差
    self.automaticallyAdjustsScrollViewInsets = NO;
   //隐藏掉状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:TRUE];

    [self makeWebView];
    //检查更新
    [self updateApp];
}

- (void)viewWillAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:TRUE];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"WARNING" message:@"MemoryWarning,Please release memory immediately" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"ok", nil];
    [alert show];
    
    /*
    NSLog(@"DiscoveryViewController didReceiveMemoryWarning");
    
    if (self.isViewLoaded && self.view.window == nil) {
        self.view = nil;
        NSLog(@"DiscoveryViewController warning");
    }
     */
}

//创建webview
- (void)makeWebView {
     self.discoverWeb = [[discoveryWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-48)];
    self.discoverWeb.discoverDelegate =self;
    [self.view addSubview:self.discoverWeb];
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

@end
