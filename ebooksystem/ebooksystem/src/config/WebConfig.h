//
//  WebConfig.h
//  ebooksystem
//
//  Created by zhenghao on 10/10/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebConfig : NSObject

#pragma mark - properties
// web request params
@property (nonatomic, copy, readonly) NSString *userAgent;

#pragma mark - methods
// singleton
+ (WebConfig *)instance;

@end
