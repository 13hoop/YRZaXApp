//
//  CustomRegisterView.m
//  ebooksystem
//
//  Created by wanghaoyu on 14-10-3.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import "CustomRegisterView.h"
#define TEXT_HEIGHT 40

@interface CustomRegisterView()<UITextFieldDelegate>

@property(nonatomic,strong)UITextField *text;
@end

@implementation CustomRegisterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self createRegisterView];
    }
    return self;
}
#pragma mark create customRegisterView
-(void)createRegisterView
{
    //创建背景色
    UIView *backgroundView=[[UIView alloc] initWithFrame:self.bounds];
    backgroundView.backgroundColor=[UIColor colorWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:1];
    backgroundView.userInteractionEnabled=YES;
    [self addSubview:backgroundView];
    //创建注册信息
    NSArray *placeHolder=[NSArray arrayWithObjects:@"   用户名",@"   您的邮箱",@"   密码",@"   重复密码", nil];
    for (NSUInteger i=0; i<4; i++) {
        self.text=[[UITextField alloc] initWithFrame:CGRectMake(0, i*(TEXT_HEIGHT+1), self.frame.size.width, TEXT_HEIGHT)];
        self.text.placeholder=[placeHolder objectAtIndex:i];
        self.text.backgroundColor=[UIColor whiteColor];
        self.text.borderStyle=UITextBorderStyleNone;
        self.text.tag=1000+i;
        //开启一键轻触功能
        self.text.clearsOnBeginEditing=YES;
        self.text.clearButtonMode=UITextFieldViewModeAlways;
        self.text.rightViewMode=UITextFieldViewModeAlways;
        //屏蔽首字母大写
        self.text.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.text.font=[UIFont systemFontOfSize:13.0f];
        self.text.delegate=self;
        [self addSubview:self.text];
        
    }
    //创建按钮
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(0, 4*TEXT_HEIGHT+20, self.frame.size.width, TEXT_HEIGHT);
    [btn setTitle:@"确定" forState:UIControlStateNormal];
    btn.titleLabel.font=[UIFont systemFontOfSize:13.0f];
    btn.backgroundColor=[UIColor blueColor];
    [btn addTarget:self action:@selector(btnDwon:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
}
-(void)btnDwon:(UIButton *)btn
{
    UITextField *userName=(UITextField*)[self viewWithTag:1000];
    UITextField *email=(UITextField*)[self viewWithTag:1001];
    UITextField *password=(UITextField*)[self viewWithTag:1002];
    UITextField *repeatPassword=(UITextField*)[self viewWithTag:1003];

    RegisterModel *model=[[RegisterModel alloc] init];
    model.userName=userName.text;
    model.email=email.text;
    model.passWord=password.text;
    model.repeatPassword=repeatPassword.text;
    [self.register_delegate registerClick:model];
}
#pragma mark textfield delegate method
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
@end
