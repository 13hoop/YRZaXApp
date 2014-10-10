//
//  MD5Util.h
//  ebooksystem
//
//  Created by zhenghao on 10/10/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MD5Util : NSObject

// 计算originalStr的mdt
+ (NSString *)md5ForString:(NSString *)originalStr;

@end
