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
@property (nonatomic, strong) NSString *pageId;

@property (nonatomic,strong) NSString *dataStoreLocation;

//2.0中为了能在MatchViewController中将数据传回KnowledgeWebViewController中
@property (nonatomic,strong) NSString *webURLStr;

@end
