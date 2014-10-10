//
//  MD5Util.m
//  ebooksystem
//
//  Created by zhenghao on 10/10/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "MD5Util.h"

#import <CommonCrypto/CommonDigest.h>



@implementation MD5Util

+ (NSString *)md5ForString:(NSString *)originalStr {
    const char *original_str = [originalStr UTF8String];
    
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, strlen(original_str), result);
    
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}

@end
