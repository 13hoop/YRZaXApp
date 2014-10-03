//
//  CustomLoginNavgationBar.h
//  ebooksystem
//
//  Created by wanghaoyu on 14-10-2.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import "CustomNavigationBar.h"

@protocol CustomLoginNavgationBarDelegate <NSObject>

-(void)gotoRegistrationController:(UIButton*)btn;

@end



@interface CustomLoginNavgationBar : CustomNavigationBar
@property(nonatomic,weak)id <CustomLoginNavgationBarDelegate>customRegistration_delegate;
@end
