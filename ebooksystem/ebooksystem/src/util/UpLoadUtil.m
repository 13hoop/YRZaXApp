//
//  UpLoadUtil.m
//  ebooksystem
//
//  Created by wanghaoyu on 15/2/28.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import "UpLoadUtil.h"
#import "LogUtil.h"
#import "AFNetworking.h"
#import "UIKit+AFNetworking.h"
#import "SBJson.h"

@implementation UpLoadUtil

+ (BOOL)upLoadImage:(NSData *)imageData andToken:(NSString *)token toUploadUrl:(NSString *)upLoadUrl {
    //判断要上传的图片是否存在
    if (imageData == nil || imageData.length <= 0) {
        LogError (@"[UpLoadUtil - upLaodImage: toUploadUrl: andUploadInfo:] upload image file failed ,imageData url is nil");
    }
    //判断upload url是否存在
    if (upLoadUrl == nil || upLoadUrl.length <= 0) {
        LogError (@"[UpLoadUtil - upLaodImage: toUploadUrl: andUploadInfo:] upload image file failed ,upload url is nil");
        return NO;
    }
    //
   
    AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:upLoadUrl parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
        
        // 上传图片，以文件流的格式,form对应html中的表单。
        //上传图片只需要两个参数（对应到html就是表单中的元素） file和token
        [formData appendPartWithFileData:imageData name:@"file" fileName:fileName mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        LogDebug (@"[UpLoadUtil - upLaodImage: toUploadUrl: andUploadInfo:] upload image file success success");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        LogError (@"[UpLoadUtil - upLaodImage: toUploadUrl: andUploadInfo:] upload image file  failed with reason:%@",error);
    }];
    
    return YES;
    
    
}

@end
