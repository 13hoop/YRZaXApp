//
//  ErrorConfig.h
//  ebooksystem
//
//  Created by zhenghao on 10/23/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ErrorConfig : NSObject

@property (nonatomic, copy) NSString *crashFilepath;


#pragma mark - methods
// singleton
+ (ErrorConfig *)instance;


@end
