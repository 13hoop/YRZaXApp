//
//  StatisticsManager.m
//  ebooksystem
//
//  Created by zhenghao on 10/9/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "StatisticsManager.h"

#import "MobClick.h"


@implementation StatisticsManager

#pragma mark - singleton
+ (StatisticsManager *)instance {
    static StatisticsManager *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[StatisticsManager alloc] init];
    });
    
    return sharedInstance;

}

#pragma mark - statistics
- (BOOL)pageStatisticWithEvent:(NSString *)eventName andArgs:(NSString *)args {
    if (eventName == nil || eventName.length <= 0) {
        return NO;
    }
    
    [MobClick event:eventName label:args];
    
    return YES;
}

@end
