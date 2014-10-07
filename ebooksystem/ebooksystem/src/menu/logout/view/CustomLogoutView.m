//
//  CustomLogoutView.m
//  ebooksystem
//
//  Created by wanghaoyu on 14-10-7.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import "CustomLogoutView.h"
#define HEIGHT 40

@interface CustomLogoutView()


@end


@implementation CustomLogoutView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self createLogoutView];
    }
    return self;
}
-(void)createLogoutView
{
    //创建一个背景view,颜色使用rgb来设置
    UIView *backgroundView=[[UIView alloc] initWithFrame:self.bounds];
    backgroundView.backgroundColor=[UIColor colorWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:1];
    backgroundView.userInteractionEnabled=YES;
    [self addSubview:backgroundView];
    //创建登陆框
    NSString *userName=[NSString stringWithFormat:@"   用户名：%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userInfoName"]];
    NSString *password=[NSString stringWithFormat:@"   密码：%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userinfoPassword"]];
    NSArray *placeHolderArr=[[NSArray alloc] initWithObjects:userName,password, nil];
    for (NSUInteger i=0; i<2; i++)
    {
        UITextField *text=[[UITextField alloc] initWithFrame:CGRectMake(0, 30+i*(HEIGHT+1), self.frame.size.width, HEIGHT)];
        text.borderStyle = UITextBorderStyleNone;
        text.backgroundColor=[UIColor whiteColor];
        text.font=[UIFont systemFontOfSize:13.0f];
        text.placeholder=[placeHolderArr objectAtIndex:i];
        
        [self addSubview:text];
    }
    //创建登出按钮
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(0, 130, self.frame.size.width,HEIGHT);
    btn.backgroundColor=[UIColor blueColor];
    btn.titleLabel.font=[UIFont systemFontOfSize:13.0f];
    [btn setTitle:@"退出登录" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnDown:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];

}
-(void)btnDown:(UIButton*)btn
{
    [self.logout_delegate getLogoutClick:btn];
    
}
@end
