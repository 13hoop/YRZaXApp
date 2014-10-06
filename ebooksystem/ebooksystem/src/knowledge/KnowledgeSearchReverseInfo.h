//
//  KnowledgeSearchReverseInfo.h
//  ebooksystem
//
//  Created by zhenghao on 10/6/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>

// 检索结果项
@interface KnowledgeSearchResultItem : NSObject

#pragma mark - properties
@property (nonatomic, copy) NSString *dataId;
@property (nonatomic, copy) NSString *dataNameEn;
@property (nonatomic, copy) NSString *dataNameCh;

@end


// 检索倒排表
@interface KnowledgeSearchReverseInfo : NSObject

#pragma mark - properties
@property (nonatomic, copy) NSString *searchId;
@property (nonatomic, copy) NSArray *searchResults;

@end
