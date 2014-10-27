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

#import "StatisticsManager.h"




@interface AppDelegate ()

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

    
    
    // Config the logger
    [LogUtil init];
    
    LogInfo(@"Bundle path: %@", [PathUtil getBundlePath]);
    LogInfo(@"Log file path: %@", [LogUtil getLogFilePath]);
    
    // 安装异常处理函数
    [ErrorManager installUncaughtExceptionHandler];
    
    // 初始化统计
    [[StatisticsManager instance] event:@"app_start" label:@""];
    
    // Override point for customization after application launch.
//    UIColor *color = [UIColor colorWithRed:107/255.0f green:211/255.0f blue:217/255.0f alpha:1.0f];
//    [[UINavigationBar appearance] setBarTintColor:color];
    return YES;
    
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

//禁止横屏的方法
-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [[CoreDataUtil instance] saveContext];
    
    [LogUtil uninit];
    
    [[StatisticsManager instance] event:@"app_exit" label:@""];
//    [self saveContext];
}

//- (void)saveContext
//{
//    NSError *error = nil;
//    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
//    if (managedObjectContext != nil) {
//        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
//            // Replace this implementation with code to handle the error appropriately.
//            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//            abort();
//        }
//    }
//}

//#pragma mark - Core Data stack
//
//// Returns the managed object context for the application.
//// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
//- (NSManagedObjectContext *)managedObjectContext
//{
//    if (_managedObjectContext != nil) {
//        return _managedObjectContext;
//    }
//    
//    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
//    if (coordinator != nil) {
//        _managedObjectContext = [[NSManagedObjectContext alloc] init];
//        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
//    }
//    return _managedObjectContext;
//}
//
//// Returns the managed object model for the application.
//// If the model doesn't already exist, it is created from the application's model.
//- (NSManagedObjectModel *)managedObjectModel
//{
//    if (_managedObjectModel != nil) {
//        return _managedObjectModel;
//    }
//    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ebooksystem" withExtension:@"momd"];
//    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
//    return _managedObjectModel;
//}
//
//// Returns the persistent store coordinator for the application.
//// If the coordinator doesn't already exist, it is created and the application's store added to it.
//- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
//{
//    if (_persistentStoreCoordinator != nil) {
//        return _persistentStoreCoordinator;
//    }
//    
//    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"ebooksystem.sqlite"];
//    
//    NSError *error = nil;
//    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
//    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
//        /*
//         Replace this implementation with code to handle the error appropriately.
//         
//         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//         
//         Typical reasons for an error here include:
//         * The persistent store is not accessible;
//         * The schema for the persistent store is incompatible with current managed object model.
//         Check the error message to determine what the actual problem was.
//         
//         
//         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
//         
//         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
//         * Simply deleting the existing store:
//         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
//         
//         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
//         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
//         
//         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
//         
//         */
//        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
//    }
//    
//    return _persistentStoreCoordinator;
//}

//#pragma mark - Application's Documents directory
//
//// Returns the URL to the application's Documents directory.
//- (NSURL *)applicationDocumentsDirectory
//{
//    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
//}

@end
