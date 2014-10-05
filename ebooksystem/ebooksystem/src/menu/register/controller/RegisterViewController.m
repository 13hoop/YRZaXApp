//
//  RegisterViewController.m
//  ebooksystem
//
//  Created by wanghaoyu on 14-10-2.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import "RegisterViewController.h"
#import "CustomNavigationBar.h"
#import "MoreViewController.h"
#import "RegisterModel.h"
#import "CustomRegisterView.h"
#define REGISTERVIEW_X 64
@interface RegisterViewController ()<CustomNavigationBarDelegate,CustomRegisterViewDelegate>
@property(nonatomic,strong)CustomNavigationBar *navBar;
@end

@implementation RegisterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    [self addNavigationBar];
    [self createRegisterView];
}
-(void)addNavigationBar
{
    
    self.navBar=[[CustomNavigationBar alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 44)];
    self.navBar.title=@"新用户注册";
    self.navBar.customNav_delegate=self;
    [self.view addSubview:self.navBar];
}
#pragma mark customNavgationBar delegate method
-(void)getClick:(UIButton *)btn
{
    //navigationControler pop到指定的页面上
    NSArray *controllerArr=self.navigationController.viewControllers;
    [self.navigationController popToViewController:[controllerArr objectAtIndex:1] animated:YES];
}

#pragma mark create customregisterView
-(void)createRegisterView
{
    CustomRegisterView *registerView=[[CustomRegisterView alloc] initWithFrame:CGRectMake(0, REGISTERVIEW_X, self.view.frame.size.width, self.view.frame.size.height-REGISTERVIEW_X)];
    registerView.register_delegate=self;
    [self.view addSubview:registerView];
}



#pragma mark customRegister delegate method
-(void)registerClick:(RegisterModel *)model
{
    NSLog(@"将自定义控件中的注册信息传递到了controller中username====%@",model.userName);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
