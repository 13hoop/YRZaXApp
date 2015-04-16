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
//点击书包页的“+”时触发代理，切换tab
- (void)goDiscoverPage;
//根据白天夜间模式刷新tabbar
- (void)refreshTabbarBackgroundWithMode:(NSString *)mode;

@end


@interface WebViewBridgeRegisterUtil : NSObject

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) UIViewController *controller;
@property (nonatomic, strong) UIView *mainControllerView;
@property (nonatomic, strong) UITabBarController *tabBarController;
//刷新  -- 发现页的url
@property (nonatomic, strong) NSString *discoveryOnlineUrl;

@property (nonatomic, weak) id<WebviewBridgeRegisterDelegate>delegate;

//实现返回时检查书籍的状态
@property (nonatomic, strong) NSString *lastPage;
@property (nonatomic, strong) NSString *needCheckBookId;


+ (WebViewBridgeRegisterUtil *)instance;
//注册js同native交互时会调用的接口
- (void)initWebView;



@end
