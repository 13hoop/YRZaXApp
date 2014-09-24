//
//  UMContactViewController.m
//  Demo
//
//  Created by liuyu on 4/2/13.
//  Copyright (c) 2013 iOS@Umeng. All rights reserved.
//

#import "UMContactViewController.h"

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
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
//#ifdef __IPHONE_5_0
//    
//    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
//    
//    if (version >= 5.0) {
//        
//        //不作处理
//        
//    }
//    else
//    {
//        if (textField.tag==1002) {
//            self.backgroundView.frame=CGRectMake(0, -100, 320, 417);
//        }
//    }
//    NSLog(@"version====%f",version);
//#endif
    if (textField.tag==1002) {
        self.backgroundView.frame=CGRectMake(0, -40, 320, 417);
    }
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

@end
