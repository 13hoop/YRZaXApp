//
//  DeviceStatusUtil.m
//  ebooksystem
//
//  Created by wanghaoyu on 14-10-21.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import "DeviceStatusUtil.h"
#import "Reachability.h"
@implementation DeviceStatusUtil

//check net status
-(NSString *)GetCurrntNet
{
    NSString* result;
    Reachability *r = [Reachability reachabilityWithHostName:@"www.apple.com"];
    switch ([r currentReachabilityStatus]) {
        case NotReachable:// 没有网络连接
            result=@"no connect";
            break;
        case ReachableViaWWAN:// 使用3G网络
            result=@"3g";
            break;
        case ReachableViaWiFi:// 使用WiFi网络
            result=@"wifi";
            break;
    }
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"当前网络状态" message:result delegate:nil cancelButtonTitle:nil otherButtonTitles:@"好的，我知道了", nil];
    [alert show];
    return result;
}
//
-(BOOL)isHorizontalScreen
{
    UIInterfaceOrientation orientation =[UIApplication sharedApplication].statusBarOrientation;
    if(orientation == UIDeviceOrientationLandscapeLeft ||orientation == UIDeviceOrientationLandscapeRight){
        // 横屏。
        return YES;
    }else{
        return NO;
    }
}
//获取当前屏幕的长度&&高度
static CGSize appScreenSize;
static UIInterfaceOrientation lastOrientation;

+(CGSize) screenSize{
    UIInterfaceOrientation orientation =[UIApplication sharedApplication].statusBarOrientation;
    if(appScreenSize.width==0 || lastOrientation != orientation){
        appScreenSize = CGSizeMake(0, 0);
        CGSize screenSize = [[UIScreen mainScreen] bounds].size; // 这里如果去掉状态栏，只要用applicationFrame即可。
//        CGSize screensize=[[UIScreen mainScreen] applicationFrame].size;
        if(orientation == UIDeviceOrientationLandscapeLeft ||orientation == UIDeviceOrientationLandscapeRight){
            // 横屏，那么，返回的宽度就应该是系统给的高度。注意这里，全屏应用和非全屏应用，应该注意增减状态栏的高度。
            appScreenSize.width = screenSize.height;
            appScreenSize.height = screenSize.width;
        }else{
            appScreenSize.width = screenSize.width;
            appScreenSize.height = screenSize.height;
        }
        lastOrientation = orientation;
    }
    return appScreenSize;
}
//识别当前为哪种设备
-(NSString *)checkDevice
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        NSString *device=@"iphone";
        return device;
        
    } else {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            NSString *device=@"ipad";
            return device;
        }
        return nil;
    }
}

@end
