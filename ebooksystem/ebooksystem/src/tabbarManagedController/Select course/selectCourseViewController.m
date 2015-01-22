//
//  selectCourseViewController.m
//  ebooksystem
//
//  Created by wanghaoyu on 15/1/19.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import "selectCourseViewController.h"
#import "NSUserDefaultUtil.h"
#import "CustomTabBarViewController.h"
#import "DiscoveryViewController.h"
#import "AppDelegate.h"

@interface selectCourseViewController ()

@property (nonatomic,strong) IBOutlet UIButton *kaoYanBtn;
@property (nonatomic,strong) IBOutlet UIButton *teacherBtn;

@end

@implementation selectCourseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)kaoyanBtn:(id)sender {
    NSString *studyType = @"0";
    [self setStudyType:studyType];
//    [self showTabbarViewController];
    
    
}

- (IBAction)teacherBtn:(id)sender {
    NSString *studyType = @"1";
    [self setStudyType:studyType];
//    [self showTabbarViewController];
}

#pragma mark btn click method
- (void)setStudyType:(NSString *)studyType {
    [NSUserDefaultUtil setCurStudyTypeWithType:studyType];
    NSLog(@"看一下是否成功=====%@",[NSUserDefaultUtil getCurStudyType]);
    
}
//切换根视图的方法
- (void)showTabbarViewController {
    UIApplication *app = [UIApplication sharedApplication];
    AppDelegate *app2 = app.delegate;
    CustomTabBarViewController *custom = [[CustomTabBarViewController alloc] init];
    app2.window.rootViewController = custom;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    
    
}
@end
