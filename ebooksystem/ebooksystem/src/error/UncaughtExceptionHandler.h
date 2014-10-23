//
//  UncaughtExceptionHandler.h
//  ebooksystem
//
//  Created by zhenghao on 10/22/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UncaughtExceptionHandler : NSObject

+ (void)handleSignal:(NSInteger)signal;

@end
