//
//  RegisterUserInfo.h
//  ebooksystem
//
//  Created by wanghaoyu on 14-10-13.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RegisterUserInfo : NSObject

@property(nonatomic,strong)NSString *userName;
@property(nonatomic,strong)NSString *email;
@property(nonatomic,strong)NSString *passWord;
@property(nonatomic,strong)NSString *repeatPassword;

@end
