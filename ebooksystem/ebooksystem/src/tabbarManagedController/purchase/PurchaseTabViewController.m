//
//  PurchaseTabViewController.m
//  ebooksystem
//
//  Created by wanghaoyu on 15/1/13.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import "PurchaseTabViewController.h"

@interface PurchaseTabViewController ()
@property (nonatomic,strong) IBOutlet UIButton *backBtn;
@end

@implementation PurchaseTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor orangeColor];
    [self createBtn];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btn:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createBtn {
    UIButton *btn = [[UIButton alloc] init];
    btn.frame = CGRectMake(100, 100, 100, 100);
    [btn setTitle:@"确定" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btndown:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
}

- (void)btndown:(UIButton *)btn {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
