//
//  CustomTabBarViewController.h
//  ebooksystem
//
//  Created by wanghaoyu on 15/1/9.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTabBarViewController : UITabBarController

@property (nonatomic, strong) UINavigationController *globalNav;

@property (nonatomic, retain) NSMutableArray *viewControllerArrar;

@end
