//
//  CustomNavigationBar.h
//  ebooksystem
//
//  Created by wanghaoyu on 14-9-22.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomNavigationBarDelegate <NSObject>

-(void)getClick:(UIButton *)btn;

@end


@interface CustomNavigationBar : UIView

@property(nonatomic,strong)NSString *title;

@property(nonatomic,strong)id <CustomNavigationBarDelegate> customNav_delegate;

@end
