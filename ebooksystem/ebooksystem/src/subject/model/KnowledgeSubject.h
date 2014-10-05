//
//  KnowledgeSubject.h
//  ebooksystem
//
//  Created by zhenghao on 10/4/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KnowledgeSubject : NSObject

#pragma mark - properties
@property (nonatomic, copy)NSString *subjectId;
@property (nonatomic, copy)NSString *name;
@property (nonatomic, copy)NSString *desc;
@property (nonatomic, copy)NSString *coverImage;

#pragma mark - methods

@end
