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
        
    } ];
    
    
    
    return YES;
    
    
}


//为了获取上传的进度，使用AFHTTPRequestSerializer类来实例化一个请求。
- (BOOL)upoadImageWithImageData:(NSData*)imageData andToken:(NSString *)token uploadUrl:(NSString *)uploadUrl {
    // 1. Create `AFHTTPRequestSerializer` which will create your request.
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:token,@"token", nil];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
    // 2. Create an `NSMutableURLRequest`.
    /*
    NSMutableURLRequest *request =
    [serializer multipartFormRequestWithMethod:@"POST" URLString:uploadUrl
                                    parameters:dic
                     constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                         [formData appendPartWithFileData:imageData
                                                     name:@"file"
                                                 fileName:fileName
                                                 mimeType:@"image/jpeg"];
                     }];
     */
    
     NSMutableURLRequest *request =
    [serializer multipartFormRequestWithMethod:@"POST" URLString:uploadUrl parameters:dic constructingBodyWithBlock:^(id<AFMultipartFormData> formData){
        [formData appendPartWithFileData:imageData
                                    name:@"file"
                                fileName:fileName
                                mimeType:@"image/jpeg"];
    }  error:nil];
    
    
    // 3. Create and use `AFHTTPRequestOperationManager` to create an `AFHTTPRequestOperation` from the `NSMutableURLRequest` that we just created.
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestOperation *operation =
    [manager HTTPRequestOperationWithRequest:request
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         LogDebug (@"[UpLoadUtil - upLaodImage: toUploadUrl: andUploadInfo:] upload image file success success");
                                         [self.uploadDelegte uploadSuccess];
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         LogError (@"[UpLoadUtil - upLaodImage: toUploadUrl: andUploadInfo:] upload image file  failed with reason:%@",error.localizedDescription);
                                         [self.uploadDelegte uploadFailedWithError:error];
                                     }];
    
    // 4. Set the progress block of the operation.
    [operation setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                        long long totalBytesWritten,
                                        long long totalBytesExpectedToWrite) {
        NSLog(@"上传的进度是 %lld/%lld", totalBytesWritten, totalBytesExpectedToWrite);
    }];
    
    // 5. !!!
    [operation start];
    return YES;
}


@end
