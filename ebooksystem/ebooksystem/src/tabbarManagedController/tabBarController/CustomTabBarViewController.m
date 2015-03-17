//
//  CustomTabBarViewController.m
//  ebooksystem
//
//  Created by wanghaoyu on 15/1/9.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import "CustomTabBarViewController.h"
#import "Config.h"

#import "ScanQRCodeViewController.h"
#import "MatchViewController.h"
#import "DiscoveryViewController.h"
#import "QuestionAndAnswerViewController.h"
#import "PersonalCenterViewController.h"
#import "PurchaseTabViewController.h"
#import "UIColor+Hex.h"


@interface CustomTabBarViewController ()<UITabBarControllerDelegate>



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
//    [self settingTabbarItemImage];
    //使用属性字符串来设置tabbar的title
    [self setTabBarItemTitleColor];
    self.delegate= self;
   
    //自定义
    [self createVC];
    //1
    [self createCustomTabbar];
    
    
    
    //创建扫一扫按钮
    [self createBUtton];
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
    [self setItemWithIndex:3 andImageName:@"Q&A.png" andSelectedImageName:@"Q&ASelected.png"];
    
    //个人页
    [self setItemWithIndex:4 andImageName:@"person.png" andSelectedImageName:@"personSelected.png"];
    
    //扫一扫页面
    [self setItemWithIndex:2 andImageName:@"scan.png" andSelectedImageName:@"scanSelected.png"];
    
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
- (void)setTabBarItemTitleColor {
    //ios5.0属性字符串的使用
//    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor orangeColor],UITextAttributeTextColor,[UIColor redColor],UITextAttributeTextShadowColor,nil] forState:UIControlStateSelected];
    //ios7.0及以上属性字符串的使用
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor orangeColor],NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
}



//1、获取上次选中的tabba的index
//2、若是本次选中的是中间的tab，则保持tabbarcontroller的选中属性不变。
//3 、present一个新的controller，开始扫一扫



//自定义效果
- (void)createBUtton {
    UIButton *btn = [[UIButton alloc] init];
    CGFloat width = self.view.frame.size.width/5;
    CGFloat height = self.tabBar.frame.size.height;
    btn.frame =CGRectMake(width*2, 0, width, height);
//    btn.backgroundColor = [UIColor orangeColor];
    //正常显示的照片
    UIImage *scanImage = [UIImage imageNamed:[[[Config instance] drawableConfig]getTabbarItemImageFullPath :@"scanTab.png"]];
    [btn setImage:scanImage forState:UIControlStateNormal];
    //选中后的照片
    UIImage *scanImageSelect = [UIImage imageNamed:[[[Config instance] drawableConfig]getTabbarItemImageFullPath :@"scanTabSelected.png"]];
    [btn setImage:scanImageSelect forState:UIControlStateSelected];

    
    [btn addTarget:self action:@selector(showScanPage) forControlEvents:UIControlEventTouchUpInside];
    self.tabBar.userInteractionEnabled = YES;
    [self.tabBar addSubview:btn];
    
}

//自定义底部状态栏button试一下



- (void)showScanPage {
    ScanQRCodeViewController *scan = [[ScanQRCodeViewController alloc] init];
//    scan.fromController = @"mainPage";
    [self.globalNav pushViewController:scan animated:YES];
    
}

//设置自定义的动画效
- (CATransition *)customAnimation {
    
    //根据JS传的参数来设置动画的切入，出方向。
    CATransition *animation = [CATransition animation];
    [animation setDuration:1];
//    [animation setType: kCATransitionPush];//设置为推入效果
    [animation setSubtype: kCATransitionFromBottom];//设置方向
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    return animation;
}
////作用：选中某一个tab时，不切换到对应的Tab页面的方法
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController  {
    if ([[self.viewControllers objectAtIndex:2] isEqual:viewController] ) {
//        [self showScanPage];
        return NO;
    }
    return YES;
}

#pragma mark 自定义tabbar
// 1 创建VC
- (void)createVC {
    self.viewControllerArrar = [NSMutableArray arrayWithCapacity:0];
    //1 初始化每个tab 对象
    //书包页
    MatchViewController *match = [[MatchViewController alloc] init];
    UINavigationController *schoolBagNav = [[UINavigationController alloc] initWithRootViewController:match];
//    schoolBagNav.title = @"我的书包";
    
    //发现页
    DiscoveryViewController *discover = [[DiscoveryViewController alloc] init];
    UINavigationController *discoverNav = [[UINavigationController alloc] initWithRootViewController:discover];
    
//    discoverNav.title = @"发现";
    //扫一扫
    PurchaseTabViewController *purchase = [[PurchaseTabViewController alloc] init];
    UINavigationController *purchaseNav = [[UINavigationController alloc] initWithRootViewController:purchase];
    //问答
    QuestionAndAnswerViewController *answer = [[QuestionAndAnswerViewController alloc] init];
    UINavigationController *answerNav = [[UINavigationController alloc] initWithRootViewController:answer];
    //个人
    PersonalCenterViewController *person = [[PersonalCenterViewController alloc] init];
    UINavigationController *personNav = [[UINavigationController alloc] initWithRootViewController:person];
    
    // 2 添加到数组，并赋值给tabbarController
    [self.viewControllerArrar addObject:schoolBagNav];
    [self.viewControllerArrar addObject:discoverNav];
    [self.viewControllerArrar addObject:purchaseNav];
    [self.viewControllerArrar addObject:answerNav];
    [self.viewControllerArrar addObject:personNav];
    //
//    self.tabBar.hidden = YES;
    self.viewControllers = self.viewControllerArrar;
    
}
- (NSArray *)getImageNamePathArray {
    //正常显示的照片
    NSString *bagImagePath = [[[Config instance] drawableConfig]getTabbarItemImageFullPath:@"myBag.png"];
    NSString *discoveryPath = [[[Config instance] drawableConfig]getTabbarItemImageFullPath :@"discoveryNew.png"];
    NSString *answerPath = [[[Config instance] drawableConfig]getTabbarItemImageFullPath:@"Q&A.png"];
    NSString *scanPath = [[[Config instance] drawableConfig]getTabbarItemImageFullPath:@"scan.png"];
    NSString *personPath = [[[Config instance] drawableConfig]getTabbarItemImageFullPath:@"person.png"];
    NSArray *arr = [NSArray arrayWithObjects:bagImagePath,discoveryPath,scanPath,answerPath,personPath, nil];
    return arr;
    
}
- (NSArray *)getSelecetedImageNamePathArray {
    NSString *bagImagePath = [[[Config instance] drawableConfig]getTabbarItemImageFullPath:@"myBagSelected.png"];
    NSString *discoveryPath = [[[Config instance] drawableConfig]getTabbarItemImageFullPath :@"discoveryNewSelected.png"];
    NSString *answerPath = [[[Config instance] drawableConfig]getTabbarItemImageFullPath:@"Q&ASelected.png"];
    NSString *scanPath = [[[Config instance] drawableConfig]getTabbarItemImageFullPath:@"scanSelected.png"];
    NSString *personPath = [[[Config instance] drawableConfig]getTabbarItemImageFullPath:@"personSelected.png"];
    NSArray *arr = [NSArray arrayWithObjects:bagImagePath,discoveryPath,scanPath,answerPath,personPath, nil];
    return arr;
}

// 2 自定义tabbar
- (void)createCustomTabbar {
    //这样处理的前提是没有隐藏掉系统tabbar
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGFloat width = rect.size.width/5;
    CGFloat height = self.tabBar.frame.size.height;
    //背景图片
    UIView *tabbarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tabBar.frame.size.width, self.tabBar.frame.size.height)];
    tabbarView.backgroundColor = [UIColor whiteColor];
    [self.tabBar addSubview:tabbarView];
    
    
    //图片数组
    NSArray *imageArr = [NSArray arrayWithArray:[self getImageNamePathArray]];
    NSArray *selectedImageArr = [NSArray arrayWithArray:[self getSelecetedImageNamePathArray]];
    NSArray *titleArr = [NSArray arrayWithObjects:@"我的书包",@"发现",@"",@"问答",@"我", nil];
    for (NSUInteger i = 0; i <5; i++) {
        //创建按钮
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(i*width, 0, width, height - 10)];
        [btn setImage:[UIImage imageNamed:[imageArr objectAtIndex:i]] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:[selectedImageArr objectAtIndex:i]] forState:UIControlStateSelected];
        btn.tag = 1000+i;
//        btn.backgroundColor = [UIColor redColor];
        [self.tabBar addSubview:btn];

        //创建title
        UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(i*width  , height - 13, width, 9)];
        titleLable.text = [titleArr objectAtIndex:i];

        titleLable.textColor = [UIColor colorWithHexString:@"#666666"];
        [[UILabel appearance] setHighlightedTextColor:[UIColor orangeColor]];
        titleLable.tag = 2000+i;
        titleLable.textAlignment = NSTextAlignmentCenter;
        titleLable.font = [UIFont systemFontOfSize:11.0f];
        [self.tabBar addSubview:titleLable];
        
        if(i == 1)
        {
            btn.selected = YES;
            self.selectedIndex = 1;
            //获取对应的lable,并修改颜色
            UILabel *lable = (UILabel *)[self.tabBar viewWithTag:2000+i];
            lable.textColor = [UIColor orangeColor];
        }
        [btn addTarget:self action:@selector(btnDown:) forControlEvents:UIControlEventTouchUpInside];
        
    }
}

- (void)btnDown:(UIButton *)btn {
    //1 触发对应tab的选中事件
    int index = btn.tag -1000;
    self.selectedIndex = index;
    //2 取消非选中的btn的状态
    for (UIView *tempView in self.tabBar.subviews) {
        if([tempView isKindOfClass:[UIButton class]]) {
            UIButton *currentBtn = (UIButton*)tempView;
            if(currentBtn.tag == btn.tag)
            {
                currentBtn.selected = YES;
                
            }
            else {
                currentBtn.selected = NO;
            }
        }
        
    }
    for (UIView *tempView in self.tabBar.subviews) {
        if ([tempView isKindOfClass:[UILabel class]]) {
            UILabel *currentLable = (UILabel *)tempView;
            if (currentLable.tag == btn.tag +1000) {
                currentLable.textColor = [UIColor orangeColor];
            }
            else {
                currentLable.textColor = [UIColor colorWithHexString:@"#666666"];
            }
        }
    }
    
}




@end
