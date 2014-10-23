//
//  StartupViewController.h
//  ebooksystem
//
//  Created by zhenghao on 10/23/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StartupViewController : UIViewController

#pragma mark - outlets
// 背景图片
@property (strong, nonatomic) IBOutlet UIImageView *bgImageView;
// 提示文字
@property (strong, nonatomic) IBOutlet UILabel *tipLabel;

@end
