//
//  CustomLoginView.h
//  ebooksystem
//
//  Created by wanghaoyu on 14-10-3.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomLoginModel.h"
@protocol CustomLoginViewDelegate <NSObject>

-(void)loginClick:(CustomLoginModel *)model;

@end


@interface CustomLoginView : UIView
@property(nonatomic,weak)id <CustomLoginViewDelegate>login_deleagte;
@end
