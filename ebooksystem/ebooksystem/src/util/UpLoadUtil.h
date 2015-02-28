//
//  UpLoadUtil.h
//  ebooksystem
//
//  Created by wanghaoyu on 15/2/28.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UpLoadUtil : NSObject
//上传图片
+ (BOOL)upLoadImage:(NSData *)imageData andToken:(NSString *)token toUploadUrl:(NSString *)upLoadUrl;

@end


