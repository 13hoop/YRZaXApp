//
//  UserInfo.h
//  ebooksystem
//
//  Created by zhenghao on 10/9/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject

#pragma mark - properties
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *balance; // 余额


@end
