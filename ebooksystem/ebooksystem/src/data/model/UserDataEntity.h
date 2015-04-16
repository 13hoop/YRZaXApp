//
//  UserDataEntity.h
//  ebooksystem
//
//  Created by wanghaoyu on 15/4/8.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UserDataEntity : NSManagedObject

@property (nonatomic, retain) NSString * k1;
@property (nonatomic, retain) NSString * k2;
@property (nonatomic, retain) NSString * k3;
@property (nonatomic, retain) NSString * k4;
@property (nonatomic, retain) NSString * k5;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSDate * createTime;
@property (nonatomic, retain) NSDate * updateTime;
@property (nonatomic, retain) NSString * backup1;
@property (nonatomic, retain) NSString * backup2;

@end
