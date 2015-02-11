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

@property (nonatomic, weak) id <scanQRCodeDelegate> scanDelegate;


@end
