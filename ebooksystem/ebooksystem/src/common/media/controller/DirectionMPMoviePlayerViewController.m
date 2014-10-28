//
//  DirectionMPMoviePlayerViewController.m
//  ebooksystem
//
//  Created by zhenghao on 10/28/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "DirectionMPMoviePlayerViewController.h"

@interface DirectionMPMoviePlayerViewController ()

@end

@implementation DirectionMPMoviePlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformRotate(transform, M_PI/2);
    self.view.transform = transform;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
//
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
////    return UIDeviceOrientationIsLandscape(interfaceOrientation);
//    return (interfaceOrientation != UIDeviceOrientationPortraitUpsideDown);
//}


@end
