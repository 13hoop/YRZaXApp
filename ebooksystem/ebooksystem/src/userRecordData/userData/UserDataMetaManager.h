//
//  UserDataMetaManager.h
//  ebooksystem
//
//  Created by wanghaoyu on 15/4/8.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserDataMeta.h"


@interface UserDataMetaManager : NSObject
#pragma mark - singleton单例
+ (UserDataMetaManager *)instance;

#pragma mark - save && update userData meta
- (BOOL)saveUserDataMeta:(UserDataMeta *)userDataMeta;

#pragma mark - get userData
- (NSArray *)getUserDataWithDictionary:(NSDictionary *)keyDic andWithUserId:(NSString *)userId;
#pragma mark - delete userData
- (NSString *)deleteUserDataWithDictionary:(NSDictionary *)contentDic andWithUserId:(NSString *)userId ;

@end
