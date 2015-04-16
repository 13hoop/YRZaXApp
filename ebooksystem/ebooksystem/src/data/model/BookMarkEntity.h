//
//  BookMarkEntity.h
//  ebooksystem
//
//  Created by wanghaoyu on 15/2/4.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BookMarkEntity : NSManagedObject

@property (nonatomic, retain) NSString * bookId;
@property (nonatomic, retain) NSString * bookMarkContent;
@property (nonatomic, retain) NSString * bookMarkDescInfo;
@property (nonatomic, retain) NSString * bookMarkId;
@property (nonatomic, retain) NSString * bookMarkName;
@property (nonatomic, retain) NSString * bookMarkType;
@property (nonatomic, retain) NSDate * createBookMarkTime;
@property (nonatomic, retain) NSString * gUserId;
@property (nonatomic, retain) NSString * targetId;
@property (nonatomic, retain) NSDate * updateBookMarkTime;

@end
