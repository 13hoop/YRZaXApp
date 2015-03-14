//
//  ScanQRCodeViewController.h
//  ebooksystem
//
//  Created by wanghaoyu on 15/1/13.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol scanQRCodeDelegate <NSObject>

- (void)getScanInfo:(NSString *)scaninfo;

@end


@interface ScanQRCodeViewController : UIViewController
//判断是从哪个页面进到这个扫一扫界面
@property (nonatomic, strong) NSString *fromController;

@property (nonatomic, weak) id <scanQRCodeDelegate> scanDelegate;


@end
