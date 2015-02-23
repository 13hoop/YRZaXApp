//
//  customNavigationViewController.m
//  ebooksystem
//
//  Created by wanghaoyu on 15/2/11.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import "customNavigationViewController.h"

@interface customNavigationViewController ()

@end

@implementation customNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    return [self.viewControllers.lastObject shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return [self.viewControllers.lastObject supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [self.viewControllers.lastObject preferredInterfaceOrientationForPresentation];
}

@end
