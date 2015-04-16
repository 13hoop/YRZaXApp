//
//  ScanQRCodeController.m
//  ebooksystem
//
//  Created by wanghaoyu on 15/2/10.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import "ScanQRCodeController.h"
#import "ScanQRCodeViewController.h"


@interface ScanQRCodeController ()

@property (nonatomic,strong) UIButton *appleBtn;

@end

@implementation ScanQRCodeController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //做一些基本的设置
    self.navigationController.navigationBarHidden = YES;
    //创建扫描button
    [self cretateButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//创建扫描按钮
- (void)cretateButton {
    self.appleBtn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 40)];
    [self.appleBtn setTitle:@"apple" forState:UIControlStateNormal];
    self.appleBtn.backgroundColor =[UIColor lightGrayColor];
    [self.appleBtn addTarget:self action:@selector(toScanViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.appleBtn];
}

- (void)toScanViewController {
    ScanQRCodeViewController *scanQR = [[ScanQRCodeViewController alloc] init];
    [self.navigationController pushViewController:scanQR animated:YES];
    //    [self presentViewController:scanQR animated:YES completion:nil];
}



@end
