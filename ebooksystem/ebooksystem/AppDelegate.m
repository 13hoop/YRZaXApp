//
//  AppDelegate.m
//  ebooksystem
//
//  Created by wanghaoyu on 14-9-22.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import "AppDelegate.h"

#import "KnowledgeManager.h"
#import "ErrorManager.h"


#import "CoreDataUtil.h"
#import "LogUtil.h"
#import "PathUtil.h"
#import "DeviceUtil.h"
#import "AppUtil.h"
#import "WebUtil.h"

#import "StatisticsManager.h"
#import "UpdateManager.h"
#import "UpdateAppViewController.h"

#import "UMSocial.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "UMSocialSinaHandler.h"

#import "UMessage.h"

#import "ZBarSDK.h"


#define UMAPPKEY @"543dea72fd98c5fc98004e08"

#define UMSYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define _IPHONE80_ 80000

@interface AppDelegate() //<UpdateManagerDelegate>

// 初始化app
//- (BOOL)initApp;


@end




@implementation AppDelegate

//@synthesize managedObjectContext = _managedObjectContext;
//@synthesize managedObjectModel = _managedObjectModel;
//@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


#pragma mark - app life
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    // 友盟, 获取devideId, 用于集成测试
//    Class cls = NSClassFromString(@"UMANUtil");
//    SEL deviceIDSelector = @selector(openUDIDString);
//    NSString *deviceID = nil;
//    if(cls && [cls respondsToSelector:deviceIDSelector]){
//        deviceID = [cls performSelector:deviceIDSelector];
//    }
//    NSLog(@"{\"oid\": \"%@\"}", deviceID);
    
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    [self initUmengShare];
    
    // 初始化logger
    [LogUtil init];
    
    // 打印相关信息
    NSString *model = [DeviceUtil getModel];
    LogInfo(@"model: %@", model);
    LogInfo(@"Bundle path: %@", [PathUtil getBundlePath]);
    LogInfo(@"Log file path: %@", [LogUtil getLogFilePath]);
    
    // 初始化统计
    [[StatisticsManager instance] event:@"app_start" label:@""];
    
    // 设置UserAgent
    [WebUtil checkUserAgent];
    
    // 安装异常处理函数
    [ErrorManager installUncaughtExceptionHandler];
    
    // 检查更新, 已转到KnowledgeWebViewController中进行
//    [UpdateManager instance].delegate = self;
//    [[UpdateManager instance] checkUpdate];

    
    // 设置navigationBar的背景色
//    UIColor *color = [UIColor colorWithRed:107/255.0f green:211/255.0f blue:217/255.0f alpha:1.0f];
//    [[UINavigationBar appearance] setBarTintColor:color];
//    return YES;
    
//    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    // Override point for customization after application launch.
//    self.window.backgroundColor = [UIColor whiteColor];
//    
//    MainViewController *main=[[MainViewController alloc] init];
//    
//    UINavigationController *navigation=[[UINavigationController alloc] initWithRootViewController:main];
//    [self UmengMethod];
//    self.window.rootViewController=navigation;
//    
//    [self.window makeKeyAndVisible];
//    return YES;
    
    
    //友盟消息推送
    [UMessage startWithAppkey:UMAPPKEY launchOptions:launchOptions];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
    if(UMSYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
    {
        //register remoteNotification types
        UIMutableUserNotificationAction *action1 = [[UIMutableUserNotificationAction alloc] init];
        action1.identifier = @"action1_identifier";
        action1.title=@"Accept";
        action1.activationMode = UIUserNotificationActivationModeForeground;//当点击的时候启动程序
        
        UIMutableUserNotificationAction *action2 = [[UIMutableUserNotificationAction alloc] init];  //第二按钮
        action2.identifier = @"action2_identifier";
        action2.title=@"Reject";
        action2.activationMode = UIUserNotificationActivationModeBackground;//当点击的时候不启动程序，在后台处理
        action2.authenticationRequired = YES;//需要解锁才能处理，如果action.activationMode = UIUserNotificationActivationModeForeground;则这个属性被忽略；
        action2.destructive = YES;
        
        UIMutableUserNotificationCategory *categorys = [[UIMutableUserNotificationCategory alloc] init];
        categorys.identifier = @"category1";//这组动作的唯一标示
        [categorys setActions:@[action1,action2] forContext:(UIUserNotificationActionContextDefault)];
        
        UIUserNotificationSettings *userSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert
                                                                                     categories:[NSSet setWithObject:categorys]];
        [UMessage registerRemoteNotificationAndUserNotificationSettings:userSettings];
        
    } else{
        //register remoteNotification types
        [UMessage registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge
         |UIRemoteNotificationTypeSound
         |UIRemoteNotificationTypeAlert];
    }
#else
    //register remoteNotification types
    [UMessage registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge
     |UIRemoteNotificationTypeSound
     |UIRemoteNotificationTypeAlert];
#endif
    
    //for log
    [UMessage setLogEnabled:YES];
    
    
    
    //使用Zbar进行二维码扫描
    [ZBarReaderView class];
    return YES;
    
}
#pragma mark umeng push used method
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [UMessage registerDeviceToken:deviceToken];
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [UMessage didReceiveRemoteNotification:userInfo];
}

//-(void)UmengMethod
//{
//    [MobClick startWithAppkey:UMENG_APPKEY reportPolicy:BATCH channelId:@""];
//    //Xcode4及以上的版本的version标识的取值--
//    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
//    [MobClick setAppVersion:version];
//    //（1）多渠道完成自动更新
//    [MobClick checkUpdate];
//    //（2）使用这个方法，这些方法已经设置好（在弹出的AlertView中点击按钮就会实现相应的方法）
//    [MobClick checkUpdate:@"新版本" cancelButtonTitle:@"取消" otherButtonTitles:@"到APP Store中下载新版本"];
//    //(3)自定义的方式来完成
//    [MobClick checkUpdateWithDelegate:self selector:@selector(update:)];
//    
//    //在线参数配置
//    [MobClick updateOnlineConfig];  //在线参数配置
//    
//    //    1.6.8之前的初始化方法
//    //    [MobClick setDelegate:self reportPolicy:REALTIME];  //建议使用新方法
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onlineConfigCallBack:) name:UMOnlineConfigDidFinishedNotification object:nil];
//    
//    
//}

////实现打开app就自动检查是否有新版本可以更新
//- (void)update:(NSDictionary *)appInfo {
//    //后期需要在这里面定制alertView
//    NSLog(@"update info %@",appInfo);
//}
//
////后期修改
//- (void)onlineConfigCallBack:(NSNotification *)note {
//    
//    NSLog(@"online config has fininshed and note = %@", note.userInfo);
//}

-(void)initUmengShare {
    [UMSocialData setAppKey:UMAPPKEY];
    //wechat---需要填写appkey 和 appSecret
    [UMSocialWechatHandler setWXAppId:@"wxb4cfa6949e15a303" appSecret:@"42846370c09438a05448519e76952326" url:@"http://www.baidu.com"];
    //qqzone ----需要注册，填写id和url
    //设置分享到QQ空间的应用Id，和分享url 链接
    [UMSocialQQHandler setQQWithAppId:@"1102966210" appKey:@"RGudHqtJ5mvFYLsY" url:@"http://www.baidu.com"];
    //设置新浪微博
    [UMSocialSinaHandler openSSOWithRedirectURL:nil];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return  [UMSocialSnsService handleOpenURL:url];
}

// 禁止横屏
-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Saves changes in the application's managed object context before the application terminates.
    [[CoreDataUtil instance] saveContext];
    
    [LogUtil uninit];
    
    [[StatisticsManager instance] event:@"app_exit" label:@""];
}

//// 跳转到app store去评分
//-(void)goToAppStore
//{
//    NSString *str = [NSString stringWithFormat:
//                     @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%d",appID]; //appID 解释如下
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
//    
//}

#pragma mark - 更新
//- (void)onCheckUpdateResult:(UpdateInfo *)updateInfo {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSString *status=updateInfo.status;
//        if ([status isEqualToString:@"0"]) {
//            NSString *shouldUpdate = updateInfo.shouldUpdate;
//            if ([shouldUpdate isEqualToString:@"NO"]) {
//                LogInfo(@"已经是最新版本");
//            }
//            else {
//                //            NSLog(@"appDownloadUrl====%@",updateInfo.appDownloadUrl);
//                self.updateAppURL=updateInfo.appDownloadUrl;
//                NSString *desc=updateInfo.appVersionDesc;
//                NSString *version=updateInfo.appVersionStr;
//                NSString *title=[NSString stringWithFormat:@"有新版本可供更新%@",version];
//                NSString *msg=[NSString stringWithFormat:@"更新信息：%@",desc];
//                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"忽略" otherButtonTitles:@"更新", nil];
//                [alert show];
//            }
//        }
//        else {
//            LogError(@"检查版本更新出错");
//        }
//    });
//}

@end
