//
//  WebViewBridgeRegisterUtil.h
//  ebooksystem
//
//  Created by wanghaoyu on 15/2/11.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol WebviewBridgeRegisterDelegate <NSObject>

@optional
- (void)goBackWithDic:(NSDictionary *)dic;


@end


@interface WebViewBridgeRegisterUtil : NSObject

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) UIViewController *controller;
@property (nonatomic, strong) UIView *mainControllerView;
@property (nonatomic, strong) UITabBarController *tabBarController;

@property (nonatomic, weak) id<WebviewBridgeRegisterDelegate>delegate;

//注册js同native交互时会调用的接口
- (void)initWebView;



@end
