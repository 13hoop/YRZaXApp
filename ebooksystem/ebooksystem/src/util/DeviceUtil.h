//
//  DeviceUtil.h
//  ebooksystem
//
//  Created by zhenghao on 10/10/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceUtil : NSObject

#pragma mark - methods

// 设备标识符. 同一个vendor, 同一个app, 保持唯一.
// The value of this property is the same for apps that come from the same vendor running on the same device. A different value is returned for apps on the same device that come from different vendors, and for apps on different devices regardless of vendor.
+ (NSString *)getVendorId;

@end
