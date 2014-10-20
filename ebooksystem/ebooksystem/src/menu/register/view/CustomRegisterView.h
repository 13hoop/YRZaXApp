//
//  CustomRegisterView.h
//  ebooksystem
//
//  Created by wanghaoyu on 14-10-3.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RegisterUserInfo.h"
@protocol CustomRegisterViewDelegate <NSObject>

-(void)registerClick:(RegisterUserInfo*)userInfo;

@end



@interface CustomRegisterView : UIView

@property(nonatomic,weak)id <CustomRegisterViewDelegate>register_delegate;

@end
