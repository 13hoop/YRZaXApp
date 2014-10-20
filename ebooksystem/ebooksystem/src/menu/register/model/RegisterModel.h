//
//  RegisterModel.h
//  ebooksystem
//
//  Created by wanghaoyu on 14-10-3.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RegisterUserInfo.h"

@protocol RegisterModelDelegate <NSObject>

-(void)registerMessage:(NSDictionary*)data anduserInfo:(RegisterUserInfo*)userInfo;

@end



@interface RegisterModel : NSObject

@property(nonatomic,strong)id <RegisterModelDelegate> register_delegate;

-(void)getPublickey;
-(void)getUserInfo:(RegisterUserInfo*)userInfo;


@end
