//
//  CustomGetUserInfoModel.h
//  ebooksystem
//
//  Created by wanghaoyu on 14-10-9.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CustomGetUserInfoModelDelegate <NSObject>

-(void)getUserinfo:(NSString *)userInfo;

@end


@interface CustomGetUserInfoModel : NSObject
@property(nonatomic,weak)id<CustomGetUserInfoModelDelegate>userInfo_delegate;
-(void)getUserInfo;

@end
