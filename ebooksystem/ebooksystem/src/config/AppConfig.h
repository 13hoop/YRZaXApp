//
//  AppConfig.h
//  ebooksystem
//
//  Created by zhenghao on 10/20/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppConfig : NSObject

#pragma mark - methods
// singleton
+ (AppConfig *)instance;

// app version in num
- (NSInteger)appVersionNum;

@end
