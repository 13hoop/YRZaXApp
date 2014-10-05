//
//  UUIDUtil.m
//  ebooksystem
//
//  Created by zhenghao on 10/3/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "UUIDUtil.h"

@implementation UUIDUtil

+ (NSString *)getUUID {
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuidStringRef];
    CFRelease(uuidStringRef);
    
    return uuid;
}

@end
