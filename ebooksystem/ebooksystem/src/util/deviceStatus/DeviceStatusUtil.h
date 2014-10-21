//
//  DeviceStatusUtil.h
//  ebooksystem
//
//  Created by wanghaoyu on 14-10-21.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceStatusUtil : NSObject

//检查网络状态
-(NSString*)GetCurrntNet;
//判断是否为横屏
-(BOOL)isHorizontalScreen;
//获取当前屏幕的宽度&&高度
+(CGSize) screenSize;
//识别当前为哪种设备
-(NSString *)checkDevice;
@end
