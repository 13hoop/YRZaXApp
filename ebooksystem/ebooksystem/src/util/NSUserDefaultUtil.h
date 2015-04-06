//
//  NSUserDefaultUtil.h
//  ebooksystem
//
//  Created by wanghaoyu on 15/1/16.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaultUtil : NSObject
//为了能够明确知道项目中在NSUserDefault存放了哪些内容，故写到一个类中

//save && change user current study type
+ (BOOL)setCurStudyTypeWithType:(NSString *)studyType;
//get user current study type
+ (NSString *)getCurStudyType;

//save HTTP request response 存一下response ，里面是否有session？
+ (BOOL)saveHttpResponse:(id)response;


//设置UA字段
+ (BOOL)setUserAgent;
+ (BOOL)saveOriginalUserAgent;


//将上传图片时的错误信息储存到本地
+ (BOOL)saveErrorMessage:(NSString *)errorMessage;

//存储设备的deviceToken
+ (BOOL)saveDeviceTokenStr:(NSData *)deviceToken;
+ (NSData *)getDeviceTokenStr;

//在nsuserDefault中储存updateStatus
+ (BOOL)saveUpdateStatus:(NSString *)updateStatus;
+ (NSString *)getUpdateStataus;
+ (BOOL)removeUpdateStatus;


//夜间模式
+ (BOOL)setGlobalDataWithObject:(NSDictionary *)dic;
+ (NSDictionary *)getGlobalDataWithKeyArray:(NSArray *)keyArray;
+ (NSString *)getGlobalMode;//获取当前的模式





//存储移动完成的标志
+ (BOOL)saveMoveCompleteString;
+ (NSString *)getMoveCompleteString;
+ (BOOL)removeMoveCompleteString;

//存储下载中的标志
+ (BOOL)saveInDownloadStatusWithStatus:(NSString *)DownloadStatus;
+ (NSString *)getDownLoadStatus;


@end
