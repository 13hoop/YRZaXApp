//
//  CustomLoginView.m
//  ebooksystem
//
//  Created by wanghaoyu on 14-10-3.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import "CustomLoginView.h"
#define HEIGHT 40

@interface CustomLoginView()<UITextFieldDelegate>


@end

@implementation CustomLoginView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self createCustomLoginView];
    }
    return self;
}

-(void)createCustomLoginView
{
    //创建一个背景view,颜色使用rgb来设置
    UIView *backgroundView=[[UIView alloc] initWithFrame:self.bounds];
    backgroundView.backgroundColor=[UIColor colorWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:1];
    backgroundView.userInteractionEnabled=YES;
    [self addSubview:backgroundView];
    //创建登陆框
    NSArray *placeHolderArr=[[NSArray alloc] initWithObjects:@"   用户名/邮箱",@"   密码", nil];
    for (NSUInteger i=0; i<2; i++)
    {
        UITextField *text=[[UITextField alloc] initWithFrame:CGRectMake(0, 30+i*(HEIGHT+1), self.frame.size.width, HEIGHT)];
        text.borderStyle = UITextBorderStyleNone;
        text.backgroundColor=[UIColor whiteColor];
        text.font=[UIFont systemFontOfSize:13.0f];
        text.placeholder=[placeHolderArr objectAtIndex:i];
        text.tag=1000+i;
        //开启一键清除功能
        text.clearsOnBeginEditing=YES;
        text.clearButtonMode=UITextFieldViewModeAlways;
        text.rightViewMode=UITextFieldViewModeAlways;
        //屏蔽首字母大写
        text.autocapitalizationType = UITextAutocapitalizationTypeNone;

        text.delegate=self;
        [self addSubview:text];
    }
    //创建登陆按钮
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(0, 130, self.frame.size.width,HEIGHT);
    btn.backgroundColor=[UIColor blueColor];
    btn.titleLabel.font=[UIFont systemFontOfSize:13.0f];
    [btn setTitle:@"登录" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnDown:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    
}
-(void)btnDown:(UIButton *)btn
{
    UITextField *userName=(UITextField *)[self viewWithTag:1000];
    UITextField *passWord=(UITextField *)[self viewWithTag:1001];
    CustomLoginModel *model=[[CustomLoginModel alloc] init];
    model.userName=userName.text;
    model.passWord=passWord.text;
    [self.login_deleagte loginClick:model];
}
#pragma mark uitextfield delegate method

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return  YES;
    
}
@end
