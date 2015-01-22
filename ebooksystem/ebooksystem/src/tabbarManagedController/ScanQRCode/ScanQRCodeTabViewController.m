//
//  ScanQRCodeTabViewController.m
//  ebooksystem
//
//  Created by wanghaoyu on 15/1/13.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import "ScanQRCodeTabViewController.h"
#import "ScanQRCodeViewController.h"
#import "ZBarScanViewController.h"
@interface ScanQRCodeTabViewController ()

@property (nonatomic,strong) IBOutlet UIButton *zBarBtn;
@property (nonatomic,strong) IBOutlet UIButton *appleBtn;
@property (nonatomic,strong) IBOutlet UIButton *zxingBtn;

@end

@implementation ScanQRCodeTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)ZbarBtn:(id)sender {
    ZBarScanViewController *zBarScan = [[ZBarScanViewController alloc] init];
    [self.navigationController pushViewController:zBarScan animated:YES];
    NSLog(@"点了");
}

- (IBAction)appleBtn:(id)sender {
    ScanQRCodeViewController *scanQR = [[ScanQRCodeViewController alloc] init];
    [self.navigationController pushViewController:scanQR animated:YES];
//    [self presentViewController:scanQR animated:YES completion:nil];
}

- (IBAction)zxingBtn:(id)sender {
}




- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"%@",self.navigationController.viewControllers);
}
@end
