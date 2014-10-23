//
//  AppConfig.h
//  ebooksystem
//
//  Created by zhenghao on 10/20/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    APP_WITH_FULL_DATA = 0, // app自带全量数据
    APP_WITHOUT_FULL_DATA // app未带全量数据, 按需下载
} AppMode;


@interface AppConfig : NSObject

#pragma mark - properties
// app version in num
@property (nonatomic, assign) NSInteger appVersionNum;

// app mode
@property (nonatomic, assign) int appMode;



#pragma mark - methods
// singleton
+ (AppConfig *)instance;

@end
