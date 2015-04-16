//
//  PersionalCenterUrlConfig.h
//  ebooksystem
//
//  Created by wanghaoyu on 15/1/29.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PersionalCenterUrlConfig : NSObject

//根据target值来返回不同url
+ (NSString *)getUrlWithAction:(NSString *)action;
@end
