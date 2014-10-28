//
//  DeviceUtil.h
//  ebooksystem
//
//  Created by zhenghao on 10/10/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    // iPhone 1,3,3GS 标准分辨率(320x480px)
    UIDevice_iPhone_Res_320_480      = 1,
    // iPhone 4,4S 高清分辨率(640x960px)
    UIDevice_iPhone_Res_640_960,
    // iPhone 5, 5S 高清分辨率(640x1136px)
    UIDevice_iPhone_Res_640_1136,
    // iPhone 6
    UIDevice_iPhone_Res_750_1334,
    // iPhone 6P
    UIDevice_iPhone_Res_1080_1920,
    
    
    // iPad 1,2 标准分辨率(1024x768px)
    UIDevice_iPad_Res_1024_768,
    // iPad 3 High Resolution(2048x1536px)
    UIDevice_iPad_Res_2048_1536,
} UIDeviceResolution;


@interface DeviceUtil : NSObject

#pragma mark - methods

// 设备标识符. 同一个vendor, 同一个app, 保持唯一.
// The value of this property is the same for apps that come from the same vendor running on the same device. A different value is returned for apps on the same device that come from different vendors, and for apps on different devices regardless of vendor.
+ (NSString *)getVendorId;

// 获取机器型号, 如iphone4, ipad1等
+ (NSString *)getModel;

/******************************************************************************
 函数名称 : + (UIDeviceResolution) currentResolution
 函数描述 : 获取当前分辨率
 输入参数 : N/A
 输出参数 : N/A
 返回参数 : N/A
 备注信息 :
 ******************************************************************************/
+ (UIDeviceResolution) currentResolution;

/******************************************************************************
 函数名称 : + (UIDeviceResolution) currentResolution
 函数描述 : 当前是否运行在iPhone5端
 输入参数 : N/A
 输出参数 : N/A
 返回参数 : N/A
 备注信息 :
 ******************************************************************************/
+ (BOOL)isRunningOniPhone5;

/******************************************************************************
 函数名称 : + (BOOL)isRunningOniPhone
 函数描述 : 当前是否运行在iPhone端
 输入参数 : N/A
 输出参数 : N/A
 返回参数 : N/A
 备注信息 :
 ******************************************************************************/
+ (BOOL)isRunningOniPhone;

@end
