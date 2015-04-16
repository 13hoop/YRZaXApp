//
//  ScanResultInfoViewController.h
//  ebooksystem
//
//  Created by wanghaoyu on 15/3/4.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScanResultInfoViewController : UIViewController

@property (nonatomic, strong) NSString *scanContext;
@property (nonatomic, strong) NSString *urlString;

//判断是从哪个地方进入扫码界面
@property (nonatomic, strong) NSString *fromController;
@end
