//
//  CustomLoginNavgationBar.m
//  ebooksystem
//
//  Created by wanghaoyu on 14-10-2.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import "CustomLoginNavgationBar.h"
#import "UIColor+Hex.h"

@interface CustomLoginNavgationBar()
@property(nonatomic,strong)UIButton *rightBUtton;

@end

@implementation CustomLoginNavgationBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self createRightButton];
    }
    return self;
}
-(void)createRightButton
{
    self.rightBUtton=[UIButton buttonWithType:UIButtonTypeCustom];
    //CGRectMake(10, 0, 40, 44);
    self.rightBUtton.frame=CGRectMake(self.frame.size.width-50, 0, 40, 44);
    [self.rightBUtton setTitle:@"注册" forState:UIControlStateNormal];
    [self.rightBUtton setTitleColor:[UIColor colorWithHexString:@"44a0ff" alpha:1] forState:UIControlStateNormal];
     self.rightBUtton.titleLabel.font=[UIFont systemFontOfSize:13.0f];
    [self.rightBUtton addTarget:self action:@selector(btn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.rightBUtton];
    
}
-(void)btn:(UIButton *)btn
{
    [self.customRegistration_delegate gotoRegistrationController:btn];
}

@end
