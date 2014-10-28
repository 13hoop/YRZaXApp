//
//  DeviceUtil.m
//  ebooksystem
//
//  Created by zhenghao on 10/10/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "DeviceUtil.h"

@implementation DeviceUtil

+ (NSString *)getVendorId {
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

// 获取机器型号, 如iphone4, ipad1等
+ (NSString *)getModel {
    return [UIDevice currentDevice].model;
}

/******************************************************************************
 函数名称 : + (UIDeviceResolution) currentResolution
 函数描述 : 获取当前分辨率
 
 输入参数 : N/A
 输出参数 : N/A
 返回参数 : N/A
 备注信息 :
 ******************************************************************************/
+ (UIDeviceResolution) currentResolution {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        // nativeBounds: since ios8
        if ([[UIScreen mainScreen] respondsToSelector:@selector(nativeBounds)]) {
            CGRect rect = [UIScreen mainScreen].nativeBounds;
            
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
                if (rect.size.height <= 480.0f) {
                    return UIDevice_iPhone_Res_320_480;
                }
                else if (rect.size.height <= 960.0f) {
                    return UIDevice_iPhone_Res_640_960;
                }
                else if (rect.size.height <= 1136.0f) {
                    return UIDevice_iPhone_Res_640_1136;
                }
                else if (rect.size.height <= 1334.0f) {
                    return UIDevice_iPhone_Res_750_1334;
                }
                else if (rect.size.height <= 1920.0f) {
                    return UIDevice_iPhone_Res_1080_1920;
                }
                else {
                    return UIDevice_iPhone_Res_640_960;
                }
            }
            else {
                return (([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) ? UIDevice_iPad_Res_2048_1536 : UIDevice_iPad_Res_1024_768);
            }

        }
        else if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) {
            CGFloat scale = [UIScreen mainScreen].scale;
            CGSize screenBounds = [[UIScreen mainScreen] bounds].size;
            
            CGSize resolution = CGSizeMake(screenBounds.width * scale, screenBounds.height * scale);
            if (resolution.height <= 480.0f) {
                return UIDevice_iPhone_Res_320_480;
            }
            else if (resolution.height <= 960.0f) {
                return UIDevice_iPhone_Res_640_960;
            }
            else if (resolution.height <= 1136.0f) {
                return UIDevice_iPhone_Res_640_1136;
            }
            else if (resolution.height <= 1334.0f) {
                return UIDevice_iPhone_Res_750_1334;
            }
            else if (resolution.height <= 1920.0f) {
                return UIDevice_iPhone_Res_1080_1920;
            }
            else {
                return UIDevice_iPhone_Res_640_960;
            }
        } else
            return UIDevice_iPhone_Res_320_480;
    } else
        return (([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) ? UIDevice_iPad_Res_2048_1536 : UIDevice_iPad_Res_1024_768);
}

/******************************************************************************
 函数名称 : + (UIDeviceResolution) currentResolution
 函数描述 : 当前是否运行在iPhone5端
 输入参数 : N/A
 输出参数 : N/A
 返回参数 : N/A
 备注信息 :
 ******************************************************************************/
+ (BOOL)isRunningOniPhone5{
    if ([self currentResolution] == UIDevice_iPhone_Res_640_1136) {
        return YES;
    }
    return NO;
}

/******************************************************************************
 函数名称 : + (BOOL)isRunningOniPhone
 函数描述 : 当前是否运行在iPhone端
 输入参数 : N/A
 输出参数 : N/A
 返回参数 : N/A
 备注信息 :
 ******************************************************************************/
+ (BOOL)isRunningOniPhone{
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
}

@end
