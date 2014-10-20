//
//  CustomRegisterView.m
//  ebooksystem
//
//  Created by wanghaoyu on 14-10-3.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import "CustomRegisterView.h"
#import "UIColor+Hex.h"
#import "CustomTextField.h"

#define TEXT_HEIGHT 44

@interface CustomRegisterView()<UITextFieldDelegate>

//@property(nonatomic,strong)UITextField *text;
@property(nonatomic,strong)CustomTextField *text;
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
    backgroundView.backgroundColor=[UIColor colorWithHexString:@"#393636" alpha:1];
    backgroundView.userInteractionEnabled=YES;
    [self addSubview:backgroundView];
    //创建注册信息
    NSArray *placeHolder=[NSArray arrayWithObjects:@"用户名",@"您的邮箱",@"密码",@"重复密码", nil];
    for (NSUInteger i=0; i<4; i++) {
        self.text=[[CustomTextField alloc] initWithFrame:CGRectMake(0, i*(TEXT_HEIGHT+1), self.frame.size.width, TEXT_HEIGHT)];
        self.text.placeholder=[placeHolder objectAtIndex:i];
        self.text.backgroundColor=[UIColor colorWithHexString:@"#4e4c4c" alpha:1];
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
    btn.titleLabel.font=[UIFont systemFontOfSize:16.0f];
    btn.backgroundColor=[UIColor colorWithHexString:@"#44a0ff" alpha:1];
    [btn addTarget:self action:@selector(btnDwon:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
}
-(void)btnDwon:(UIButton *)btn
{
    UITextField *userName=(UITextField*)[self viewWithTag:1000];
    UITextField *email=(UITextField*)[self viewWithTag:1001];
    UITextField *password=(UITextField*)[self viewWithTag:1002];
    UITextField *repeatPassword=(UITextField*)[self viewWithTag:1003];
    NSString *alertText=nil;
    if ([userName.text isEqualToString:@""]==NO && [email.text isEqualToString:@""] ==NO && [password.text isEqualToString:@""]==NO && [repeatPassword.text isEqualToString:@""] ==NO)
    {
        if ([password.text isEqualToString:repeatPassword.text]==YES && [self isValidateEmail:email.text]==YES) {
            
            RegisterUserInfo *model=[[RegisterUserInfo alloc] init];
            model.userName=userName.text;
            model.email=email.text;
            model.passWord=password.text;
            model.repeatPassword=repeatPassword.text;
            
            [self.register_delegate registerClick:model];
        }
        else
        {
            NSString *msg=nil;
            if ([self isValidateEmail:email.text]==NO)
            {
                msg=@"邮箱格式错误";
            }
            else
            {
                msg=@"两次输入的密码不一致,请检查输入的密码";
            }
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示信息" message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"重新检查", nil];
            [alert show];

        }
    }
    else
    {
        
        if ([userName.text isEqualToString:@""]) {
            alertText=@"用户名不能为空";
        }
        else
        {
            if ([email.text isEqualToString:@""]) {
                alertText=@"邮箱不能为空";
            }
            
            else
            {
                //检查邮箱格式
                if ([self isValidateEmail:email.text]==NO) {
                    alertText=@"邮箱格式错误";
                }
                    else
                    {
                        if ([password.text isEqualToString:@""]) {
                            alertText=@"密码不能为空";
                        }
                        else
                        {
                            alertText=@"请再次输入您的密码";
                        }
                        
                    }
                
                
                
            }
            
        }
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示信息" message:alertText delegate:nil cancelButtonTitle:nil otherButtonTitles:@"重新输入", nil];
        [alert show];
    }
    
}

//check email form
- (BOOL)isValidateEmail:(NSString *)Email
{
    NSString *emailCheck = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",emailCheck];
    return [emailTest evaluateWithObject:Email];
}
#pragma mark textfield delegate method
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.textColor=[UIColor whiteColor];
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.textColor=[UIColor whiteColor];
}
@end
