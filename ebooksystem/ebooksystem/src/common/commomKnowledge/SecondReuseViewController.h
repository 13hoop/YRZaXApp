//
//  SecondReuseViewController.h
//  ebooksystem
//
//  Created by wanghaoyu on 15/2/2.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import <UIKit/UIKit.h>




@interface SecondReuseViewController : UIViewController

@property (nonatomic,strong) NSString *webUrl;
@property (nonatomic,strong) NSString *shouldChangeBackground;

//判断本页是否需要刷新
@property (nonatomic,strong) NSString *needRefresh;
//判断本页是否需要横屏
@property (nonatomic,strong) NSString *needOrientation;

@end
