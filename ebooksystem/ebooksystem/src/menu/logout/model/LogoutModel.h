//
//  LogoutModel.h
//  ebooksystem
//
//  Created by wanghaoyu on 14-10-7.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LogoutModelDelegate <NSObject>

-(void)logoutMessage:(NSString *)msg;

@end



@interface LogoutModel : NSObject

@property(nonatomic,weak)id <LogoutModelDelegate>logout_delegate;
-(void)logout;

@end
