//
//  UserDataMeta.h
//  ebooksystem
//
//  Created by wanghaoyu on 15/4/8.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UserDataEntity;



@interface UserDataMeta : NSObject

@property (nonatomic, copy) NSString *k1;
@property (nonatomic, copy) NSString *k2;
@property (nonatomic, copy) NSString *k3;
@property (nonatomic, copy) NSString *k4;
@property (nonatomic, copy) NSString *k5;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *value;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSDate *createTime;
@property (nonatomic, copy) NSDate *updateTime;
@property (nonatomic, copy) NSString *backup1;
@property (nonatomic, copy) NSString *backup2;

#pragma mark - 同UserDataEntity转换
//由UserDataEntity转为UserDataMeta
+ (UserDataMeta *)fromUserDataEntity:(UserDataEntity *)userDataEntity;

//将bookMarkMeta各属性赋予userDataEntity
- (BOOL)setValuesForEntity:(NSManagedObject *)userDataEntity;

@end
