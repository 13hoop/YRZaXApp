//
//  CustomMoreView.h
//  ebooksystem
//
//  Created by wanghaoyu on 14-9-22.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomMoreViewDelegate <NSObject>

-(void)getSelectIndexPath:(NSIndexPath*)indexPath;

@end

@interface CustomMoreView : UIView
//实现注册成功时显示用户名的功能
@property(nonatomic,strong)UILabel *userNameLable;


@property(nonatomic,strong)NSString *balance;
@property(nonatomic,weak)id <CustomMoreViewDelegate>more_delegate;
@property(nonatomic,strong)NSString *userName;
@end
