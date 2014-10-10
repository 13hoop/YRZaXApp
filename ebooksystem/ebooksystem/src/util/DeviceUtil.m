//
//  DeviceUtil.m
//  ebooksystem
//
//  Created by zhenghao on 10/10/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "DeviceUtil.h"

@implementation DeviceUtil

+ (NSString *)getVendorId {
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

@end
