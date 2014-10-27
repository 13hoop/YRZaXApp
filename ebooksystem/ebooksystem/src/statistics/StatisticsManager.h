//
//  StatisticsManager.h
//  ebooksystem
//
//  Created by zhenghao on 10/9/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StatisticsManager : NSObject

#pragma mark - singleton
+ (StatisticsManager *)instance;

#pragma mark - statistics
- (BOOL)pageStatisticWithEvent:(NSString *)eventName andArgs:(NSString *)args;

@end
