//
//  discoveryWebView.h
//  ebooksystem
//
//  Created by wanghaoyu on 15/1/25.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol discoverDelegate <NSObject>

- (void)controllerSwitchOver;
- (void)showSafeUrl:(NSString *)url;
//addToNative
- (void)addToNative:(NSString *)bookId;

@end


@interface discoveryWebView : UIView

@property (nonatomic, strong) NSString *webUrl;

@property (nonatomic ,strong) id<discoverDelegate>discoverDelegate;
@end
