//
//  CommonWebViewController.h
//  ebooksystem
//
//  Created by zhenghao on 10/8/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CommonWebViewController : UIViewController

#pragma mark - properties

// web view展现时, 需要展示的url
@property (nonatomic, copy) NSString *url;

@property (nonatomic,strong) NSString *dataStoreLocation;

@end
