//
//  UpdateManager.h
//  ebooksystem
//
//  Created by zhenghao on 10/29/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UpdateInfo.h"


@class UpdateManager;


@protocol UpdateManagerDelegate <NSObject>

// 响应检查结果
- (void)onCheckUpdateResult:(UpdateInfo *)updateInfo;

@end



@interface UpdateManager : NSObject

@property (nonatomic, copy) id<UpdateManagerDelegate> delegate;


#pragma mark - singleton
+ (UpdateManager *)instance;

#pragma mark - check update
- (BOOL)checkUpdate;

@end



