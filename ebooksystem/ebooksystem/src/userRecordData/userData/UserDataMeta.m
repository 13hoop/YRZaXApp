//
//  UserDataMeta.m
//  ebooksystem
//
//  Created by wanghaoyu on 15/4/8.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import "UserDataMeta.h"
#import "UserDataEntity.h"



@implementation UserDataMeta
@synthesize k1;
@synthesize k2;
@synthesize k3;
@synthesize k4;
@synthesize k5;
@synthesize type;
@synthesize value;
@synthesize userId;
@synthesize createTime;
@synthesize updateTime;
@synthesize backup1;
@synthesize backup2;

#pragma mark - 同userDataEntity转换
+ (UserDataMeta *)fromUserDataEntity:(UserDataEntity *)userDataEntity {
    if (userDataEntity == nil) {
        return nil;
    }
    UserDataMeta *userData = [[UserDataMeta alloc] init];
    userData.userId = userDataEntity.userId;
    userData.k1 = userDataEntity.k1;
    userData.k2 = userDataEntity.k2;
    userData.k3 = userDataEntity.k3;
    userData.k4 = userDataEntity.k4;
    userData.k5 = userDataEntity.k5;
    userData.type = userDataEntity.type;
    userData.value = userDataEntity.value;
    userData.createTime = userDataEntity.createTime;
    userData.updateTime = userDataEntity.updateTime;
    userData.backup1 = userDataEntity.backup1;
    userData.backup2 = userDataEntity.backup2;
    return userData;
    
}


//将UserDataMeta各属性赋予userDataEntity
- (BOOL)setValuesForEntity:(NSManagedObject *)userDataEntity {
    if (userDataEntity == nil) {
        return NO;
    }
    //userId  虽然是在native从本地获取，但是约定userId作为userDataMeta的一个属性传进来。
    if (self.userId == nil || self.userId.length <= 0) {//userId为空，则不保存该条记录
        return NO;
    }
    else {
        [userDataEntity setValue:self.userId forKey:@"userId"];
    }
    
    //k1
    if (self.k1 == nil || self.k1.length <= 0 ) {
        [userDataEntity setValue:@"" forKey:@"k1"];
    }
    else {
        [userDataEntity setValue:self.k1 forKey:@"k1"];
    }
    
    //k2
    if (self.k2 == nil || self.k2.length <= 0 ) {
        [userDataEntity setValue:@"" forKey:@"k2"];
    }
    else {
        [userDataEntity setValue:self.k2 forKey:@"k2"];
    }
    
    //k3
    if (self.k3 == nil || self.k3.length <= 0 ) {
        [userDataEntity setValue:@"" forKey:@"k3"];
    }
    else {
        [userDataEntity setValue:self.k3 forKey:@"k3"];
    }
    
    //k4
    if (self.k4 == nil || self.k4.length <= 0 ) {
        [userDataEntity setValue:@"" forKey:@"k4"];
    }
    else {
        [userDataEntity setValue:self.k4 forKey:@"k4"];
    }
    
    //k5
    if (self.k5 == nil || self.k5.length <= 0 ) {
        [userDataEntity setValue:@"" forKey:@"k5"];
    }
    else {
        [userDataEntity setValue:self.k5 forKey:@"k5"];
    }
    
    //type
    if (self.type == nil || self.type.length <= 0 ) {
        [userDataEntity setValue:@"" forKey:@"type"];
    }
    else {
        [userDataEntity setValue:self.type forKey:@"type"];
    }
    
    //createTime
    if (self.createTime != nil) {
        [userDataEntity setValue:[NSDate date] forKey:@"createTime"];
        [userDataEntity setValue:@"" forKey:@"updateTime"];//创建时，updateTime置为空
    }
    
    //updateTime
    if (self.updateTime != nil) {
        [userDataEntity setValue:self.updateTime forKey:@"updateTime"];
    }
    
    //backup1
    if (self.backup1 == nil || self.backup1.length <= 0) {
        [userDataEntity setValue:@"" forKey:@"backup1"];
    }
    else {
        [userDataEntity setValue:self.backup1 forKey:@"backup1"];
    }
    
    //backup2
    if (self.backup2 == nil || self.backup2.length <= 0) {
        [userDataEntity setValue:@"" forKey:@"backup2"];
    }
    else {
        [userDataEntity setValue:self.backup2 forKey:@"backup2"];
    }
    
    return  YES;
    
}



@end
