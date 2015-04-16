//
//  RenderKnowledgeViewController.h
//  ebooksystem
//
//  Created by wanghaoyu on 15/1/23.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RenderKnowledgeViewController : UIViewController

@property (nonatomic,strong) NSString *webUrl;
@property (nonatomic,strong) NSString *shouldChangeBackground;
//设置一个flag，用来区分是哪个页面过来，要展示那个页面
@property (nonatomic,strong) NSString *flag;
@end
