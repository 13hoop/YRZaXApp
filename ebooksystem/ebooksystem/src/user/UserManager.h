//
//  UserManager.h
//  ebooksystem
//
//  Created by zhenghao on 10/9/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UserInfo.h"

@protocol UserManagerDelegate <NSObject>

@optional

-(void)getUserBalance:(NSString *)balance;
//用在菜单页中
-(void)getUserinfo:(NSString *)userInfo;
//recharge
-(void)getRechargeMessage:(NSString *)msg;


//刷新余额
-(void)upDateBalance:(NSString *)balance;
@end



@interface UserManager : NSObject

@property(nonatomic,weak)id<UserManagerDelegate>userInfo_delegate;
@property(nonatomic,weak)id<UserManagerDelegate> recharge_delegate;
@property(nonatomic,weak)id<UserManagerDelegate> upDateBalance_delegate;

#pragma mark - singleton
+ (UserManager *)instance;
+ (UserManager *)shareInstance;

#pragma mark - user related methods
// get default user
+ (UserInfo *)getDefaultUser;

// get cur user
- (UserInfo *)getCurUser;
// save userInfo
-(BOOL)saveUserInfo:(UserInfo *)userinfo;
//get local Users
-(NSMutableArray*)getUsers;

//set user info for 2.0
//- (void)setCurUserInfo:(UserInfo *)userInfo;

//getUserInfo
-(UserInfo*)getUserInfo:(NSString *)userName;
//setCurUser
-(BOOL)setCurUser:(UserInfo*)userinfo;
-(void)setCurUser;

//addUser
-(BOOL)addUser:(UserInfo*)userInfo andContext:(NSString *)context;
//removeUser
-(BOOL)removeUser:(NSString *)userName andContext:(NSString *)context;
//get online userInfo
-(void)getUserInfo;
//recharge
-(void)getRecharge:(NSString *)cardID;
//remove all userinfo
-(BOOL)removeAllUserInfo;

-(void)getBalance;
@end
