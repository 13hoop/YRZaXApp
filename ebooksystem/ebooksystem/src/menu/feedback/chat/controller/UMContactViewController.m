//
//  UMContactViewController.m
//  Demo
//
//  Created by liuyu on 4/2/13.
//  Copyright (c) 2013 iOS@Umeng. All rights reserved.
//

#import "UMContactViewController.h"
#import "MobClick.h"
#define SCREEN_HEIGHT 480
@implementation UMContactViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)backToPrevious {

    [self.navigationController popViewControllerAnimated:YES];
}

//更改了更新方法中的内容
- (void)updateContactInfo {
    NSString *name=[NSString stringWithFormat:@"姓名：%@",self.nameText.text];
    NSString *contact=[NSString stringWithFormat:@"联系方式：%@",self.contactInfo.text];
    NSString *date=[NSString stringWithFormat:@"入学时间：%@",self.date.text];
    NSString *email=[NSString stringWithFormat:@"QQ、邮箱：%@",self.email.text];
    NSString *project=[NSString stringWithFormat:@"报考专业：%@",self.project.text];
    NSString *contactInfo=[NSString stringWithFormat:@"%@，%@，%@",name,contact,email];
    NSString *remarkinfo=[NSString stringWithFormat:@"%@，%@",date,project];
    if ([self.delegate respondsToSelector:@selector(updateContactInfo:contactInfo:andWithReamrkInfo:)]) {
        [self.delegate updateContactInfo:self contactInfo:contactInfo andWithReamrkInfo:remarkinfo];
    }

    [self backToPrevious];
}
//取消按钮的点击事件
-(IBAction)cancelButton:(id)sender
{
    [self backToPrevious];
}
//保存按钮的上点击事件
-(IBAction)okButton:(id)sender
{
    [self updateContactInfo];
    NSUserDefaults *userInfo=[NSUserDefaults standardUserDefaults];
    [userInfo setObject:self.nameText.text forKey:@"userName"];
    [userInfo setObject:self.date.text forKey:@"SchoolDate"];
    [userInfo setObject:self.contactInfo.text forKey:@"userContact"];
    [userInfo setObject:self.email.text forKey:@"userEmail"];
    [userInfo setObject:self.project.text forKey:@"chooseProject"];
    
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    self.navigationController.navigationBarHidden=YES;
    UIView *navBarview=[[UIView alloc] initWithFrame:CGRectMake(0, 20, 320, 44)];
    navBarview.backgroundColor=[UIColor colorWithRed:238.0 / 255 green:238.0 / 255 blue:238.0 / 255 alpha:1.0];
    self.nameText.delegate=self;
    self.contactInfo.delegate=self;
    self.date.delegate=self;
    self.email.delegate=self;
    self.project.delegate=self;
    
}
//还需要修改一下
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGFloat height=[self screenHeight];
    if (height>480) {
        if (textField.tag) {
            if (textField.tag==1003 || textField.tag==1004) {
                self.backgroundView.frame=CGRectMake(0, 30, 320, 568-64);
            }
        }
    }
    else
    {
        if (textField.tag==1001) {
            self.backgroundView.frame=CGRectMake(0, 20, 320, 417);
        }
        if (textField.tag==1002 ||textField.tag==1003 || textField.tag==1004) {
            self.backgroundView.frame=CGRectMake(0, -43, 320, 417);
        }
    }
    
}
-(CGFloat)screenHeight
{
    CGRect rect=[UIScreen mainScreen].bounds;
    CGSize size=rect.size;
    CGFloat height=size.height;
    return height;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    self.backgroundView.frame=CGRectMake(0, 64, 320, 417);
    return YES;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

//    [self.textView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"PageContact"];
    NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
    self.nameText.text=[user valueForKey:@"userName"];
    self.date.text=[user valueForKey:@"SchoolDate"];
    self.contactInfo.text=[user valueForKey:@"userContact"];
    self.email.text=[user valueForKey:@"userEmail"];
    self.project.text=[user valueForKey:@"chooseProject"];
    
    UIImage *okImage=[UIImage imageNamed:@"res/drawable/umeng-images/item_ok.png"];
    [self.okButton setImage:okImage forState:UIControlStateNormal];
    UIImage *cancelImage=[UIImage imageNamed:@"res/drawable/umeng-images/item_cancel.png"];
    [self.cancelButton setImage:cancelImage forState:UIControlStateNormal];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"PageContact"];
}

@end
