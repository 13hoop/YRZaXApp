//
//  CustomTabBarViewController.m
//  ebooksystem
//
//  Created by wanghaoyu on 15/1/9.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import "CustomTabBarViewController.h"
#import "Config.h"


@interface CustomTabBarViewController ()

@end

@implementation CustomTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //设置tabbarcontroller默认选中的位置
    self.selectedIndex= 1;
    //setting tabbar background
    self.tabBar.backgroundColor = [UIColor whiteColor];
    
    //设置tabbar item 图片
    [self settingTabbarItemImage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


//setting custom tabbar item image
- (void)settingTabbarItemImage {
    //书包页
    [self setItemWithIndex:0 andImageName:@"myBag.png" andSelectedImageName:@"myBagSelected.png"];
    
    //发现页
    [self setItemWithIndex:1 andImageName:@"discovery.png" andSelectedImageName:@"discoverySelected.png"];
    
    
    //问答页
    [self setItemWithIndex:2 andImageName:@"Q&A.png" andSelectedImageName:@"Q&ASelected.png"];
    
    //二维码
    [self setItemWithIndex:3 andImageName:@"scan.png" andSelectedImageName:@"scanSelected.png"];
}

//setting tabbar item image && selected image
- (void)setItemWithIndex:(int)number andImageName:(NSString *)imageName andSelectedImageName:(NSString *)selectedImageName {
    UITabBarItem *item = [self.tabBar.items objectAtIndex:number];
    NSString *itemImagePath = [[[Config instance] drawableConfig]getTabbarItemImageFullPath :imageName];
    NSString *itemSelectedImagePath = [[[Config instance] drawableConfig] getTabbarItemImageFullPath:selectedImageName];
    UIImage *itemImage = [[UIImage imageNamed:itemImagePath] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *itemImageSelected = [[UIImage imageNamed:itemSelectedImagePath] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    //
    item.image = itemImage;
    item.selectedImage = itemImageSelected;
    //title可以设置属性字符串来改变title值，字体颜色等
}

@end
