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
#import "NSUserDefaultUtil.h"



@implementation UpLoadUtil

- (BOOL)upLoadImage:(NSData *)imageData andToken:(NSString *)token toUploadUrl:(NSString *)upLoadUrl {
    
    //保存传进来的block代码块
//    self.successBlock = successBlock;
//    self.failedBlock = failedBlock;
    //判断要上传的图片是否存在
    if (imageData == nil || imageData.length <= 0) {
        LogError (@"[UpLoadUtil - upLaodImage: toUploadUrl: andUploadInfo:] upload image file failed ,imageData url is nil");
        [NSUserDefaultUtil saveErrorMessage:@"图片文件不存在"];

    }
    //判断upload url是否存在
    if (upLoadUrl == nil || upLoadUrl.length <= 0) {
        LogError (@"[UpLoadUtil - upLaodImage: toUploadUrl: andUploadInfo:] upload image file failed ,upload url is nil");
        [NSUserDefaultUtil saveErrorMessage:@"上传链接不存在"];
        return NO;
    }
    //
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:token,@"token", nil];
    AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:upLoadUrl parameters:dic constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
        
        // 上传图片，以文件流的格式,form对应html中的表单。
        //上传图片只需要两个参数（对应到html就是表单中的元素） file和token
        [formData appendPartWithFileData:imageData name:@"file" fileName:fileName mimeType:@"image/jpeg"];
    //token字段需要上传
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        LogDebug (@"[UpLoadUtil - upLaodImage: toUploadUrl: andUploadInfo:] upload image file success success");
        [self.uploadDelegte uploadSuccess];
        
    
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        LogError (@"[UpLoadUtil - upLaodImage: toUploadUrl: andUploadInfo:] upload image file  failed with reason:%@",error.localizedDescription);
        [self.uploadDelegte uploadFailedWithError:error];
        
    }];
    
    
    
    return YES;
    
    
}



@end
