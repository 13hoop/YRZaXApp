//
//  CustomLogoutView.h
//  ebooksystem
//
//  Created by wanghaoyu on 14-10-7.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomLogoutViewDelegate <NSObject>

-(void)getLogoutClick:(UIButton *)btn;

@end


@interface CustomLogoutView : UIView

@property(nonatomic,weak)id<CustomLogoutViewDelegate>logout_delegate;

@end
