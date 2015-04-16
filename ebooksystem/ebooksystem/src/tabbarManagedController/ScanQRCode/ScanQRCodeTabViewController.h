//
//  ScanQRCodeTabViewController.h
//  ebooksystem
//
//  Created by wanghaoyu on 15/1/13.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import <UIKit/UIKit.h>

//扫描二维码的落地页
@interface ScanQRCodeTabViewController : UIViewController

@property (nonatomic, strong) NSString *scanInfoStr;

//判断从哪个页面进入到扫码页
@property (nonatomic, strong) NSString *fromController;
@end
