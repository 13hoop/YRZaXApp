//
//  ScanResultInfoViewController.m
//  ebooksystem
//
//  Created by wanghaoyu on 15/3/4.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import "ScanResultInfoViewController.h"
#import "Config.h"
#import "UIColor+Hex.h"

@interface ScanResultInfoViewController ()

@end

@implementation ScanResultInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customNav];
    if (self.scanContext != nil && self.scanContext.length > 0) {
       [self createUI];
    }
    if (self.urlString != nil && self.urlString.length > 0 ) {
        [self createWebview];
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
    self.tabBarController.tabBar.hidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}


//自定义导航栏
- (void)customNav {
    UIView *navgationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    navgationView.backgroundColor = [UIColor blackColor];
    navgationView.userInteractionEnabled = YES;
    [self.view addSubview:navgationView];
    //create 返回箭头
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10,(64-25)/2, 16, 25)];
    UIImage *image = [UIImage imageNamed:[[[Config instance] drawableConfig] getImageFullPath:@"backNew.png"]];
    imageView.image = image;
    [navgationView addSubview:imageView];
    //create 返回按钮,宽度设置的较大，保证返回的操作足够流畅
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 64)];
    [backButton addTarget:self action:@selector(backToFrontPage) forControlEvents:UIControlEventTouchUpInside];
    //
    [navgationView addSubview:backButton];
    //create title
    UILabel *textLable = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 160)/2, 0, 160, 64)];
    textLable.text = @"咋学";
    [textLable setTextAlignment:NSTextAlignmentCenter];
    textLable.textColor = [UIColor whiteColor];
    [textLable setFont:[UIFont fontWithName:@"Courier" size:23.0f]];
    [navgationView addSubview:textLable];
    
}
//创建普通文字的提示UI
- (void)createUI {
    //提示性文字
    CGRect rect = [[UIScreen mainScreen] bounds];
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, rect.size.width, rect.size.height - 64)];
    backgroundView.backgroundColor = [UIColor colorWithHexString:@"#413E3E"];
//    backgroundView.alpha = 0.3;
    [self.view addSubview:backgroundView];
    //标题
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 200)/2, 100, 200, 30)];
    titleLable.text = @"已扫描到以下内容";
    titleLable.textColor = [UIColor whiteColor];
    titleLable.font = [UIFont systemFontOfSize:16];
    titleLable.textAlignment = NSTextAlignmentCenter;
    [backgroundView addSubview:titleLable];
    //上间隔线
    UIView *upLine = [[UIView alloc] initWithFrame:CGRectMake(10, 140, self.view.frame.size.width - 20, 2)];
    upLine.backgroundColor = [UIColor whiteColor];
    [backgroundView addSubview:upLine];
    //显示扫描结果的lable
    CGSize titleSize = [self.scanContext sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(260, MAXFLOAT) lineBreakMode:UILineBreakModeWordWrap];
    UILabel *scanInfoLable = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 260)/2, 148, 260, titleSize.height)];
    scanInfoLable.text = self.scanContext;
    scanInfoLable.numberOfLines = 0;
    scanInfoLable.textColor = [UIColor whiteColor];
    scanInfoLable.font = [UIFont systemFontOfSize:13.0f];
    scanInfoLable.textAlignment = NSTextAlignmentCenter;
    [backgroundView addSubview:scanInfoLable];
    //下分割线
    UIView *downView = [[UIView alloc] initWithFrame:CGRectMake(10,153 + titleSize.height, self.view.frame.size.width - 20, 2)];
    downView.backgroundColor = [UIColor whiteColor];
    [backgroundView addSubview:downView];
    //说明lable
    UILabel *tipLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 158 + titleSize.height, self.view.frame.size.width - 20, 30)];
    tipLable.text = @"扫描所得内容并非“咋学”提供，请谨慎使用";
    tipLable.font = [UIFont systemFontOfSize:14.0f];
    tipLable.textAlignment = NSTextAlignmentCenter;
    tipLable.textColor = [UIColor whiteColor];
    [backgroundView addSubview:tipLable];
    
    
}

- (void)backToFrontPage {
//    NSMutableArray *controllers = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
//    
//    [controllers removeObjectAtIndex:controllers.count -2];
//    [self.navigationController setViewControllers:controllers];
    [self.navigationController popViewControllerAnimated:YES];
}

//创建webview
- (void)createWebview {
    CGRect rect = [[UIScreen mainScreen] bounds];
    UIWebView *webview = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, rect.size.height - 64)];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.urlString]];
    [webview loadRequest:request];
    [self.view addSubview:webview];
}



@end
