//
//  CustomMoreView.h
//  ebooksystem
//
//  Created by wanghaoyu on 14-9-22.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    MENU_STYLE_OLD = 0, // 老菜单样式
    MENU_STYLE_NEW // 新菜单样式
} MenuStyle;

typedef enum {
    VIEW_ITEM_NONE = -1, // 空
    VIEW_ITEM_USER_INFO_VIA_WEB, // 用户信息，通过webView展示
    VIEW_ITEM_USER_INFO_VIA_NATIVE, // 用户信息，通过native展示
    VIEW_ITEM_USER_LOG_IN, // 用户登入
    VIEW_ITEM_USER_LOG_OUT, //　用户登出
    VIEW_ITEM_USER_CHARGE, // 充值
    VIEW_ITEM_PURCHASE, // 购买图书
    VIEW_ITEM_FEEDBACK, // 反馈
    VIEW_ITEM_CHECK_APP_UPDATE, // 检查软件更新
    VIEW_ITEM_ABOUT_APP, // 关于
    VIEW_ITEM_TEST // 测试
} ViewItemId;

@protocol CustomMoreViewDelegate <NSObject>

// 点击某item后的响应
- (void)viewItemClicked:(ViewItemId)viewItemId;

@end

@interface CustomMoreView : UIView
// delegate
@property(nonatomic, weak) id<CustomMoreViewDelegate> more_delegate;

// 菜单样式
@property (nonatomic, assign) MenuStyle menuStyle;

// ui
// 实现注册成功时显示用户名的功能
@property(nonatomic, strong) UILabel *userNameLabel;
@property(nonatomic, strong) UILabel *lable;
// 提示文字
@property(nonatomic, strong) UILabel *updateLable;

@property(nonatomic, strong) NSString *userName;
@property(nonatomic, strong) NSString *balance;

@end
