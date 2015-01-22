//
//  TestWebViewController.h
//  ebooksystem
//
//  Created by wanghaoyu on 14/12/23.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KnowledgeSubject;


@interface TestWebViewController : UIViewController

#pragma mark - properties
//@property (nonatomic, copy) KnowledgeSubject *knowledgeSubject;

// web view展现时, 需要展示的page id
@property (nonatomic, strong) NSString *pageId;

@property (nonatomic,strong) NSString *dataStoreLocation;

@end
