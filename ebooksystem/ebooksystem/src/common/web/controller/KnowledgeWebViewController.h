//
//  CommonWebViewController.h
//  ebooksystem
//
//  Created by zhenghao on 10/8/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KnowledgeSubject;



@interface KnowledgeWebViewController : UIViewController

#pragma mark - properties
//@property (nonatomic, copy) KnowledgeSubject *knowledgeSubject;

// web view展现时, 需要展示的page id
@property (nonatomic, copy) NSString *pageId;



@end
