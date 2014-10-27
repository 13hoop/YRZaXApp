//
//  StatisticsManager.h
//  ebooksystem
//
//  Created by zhenghao on 10/9/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface StatisticsManager : NSObject

#pragma mark - properties
// app key, form umeng
@property (nonatomic, copy, readonly) NSString *appKeyFromUmeng;

// channel
@property (nonatomic, copy) NSString *channel;



#pragma mark - singleton
+ (StatisticsManager *)instance;

#pragma mark - statistics
// page start
- (void)beginLogPageView:(NSString *)pageName;
// page end
- (void)endLogPageView:(NSString *)pageName;

// event
- (void)event:(NSString *)eventId label:(NSString *)label;


- (BOOL)pageStatisticWithEvent:(NSString *)eventName andArgs:(NSString *)args;

#pragma mark - update
// check update
- (void)checkUpdate;

@end
