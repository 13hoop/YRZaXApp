//
//  DiscoveryViewController.m
//  ebooksystem
//
//  Created by wanghaoyu on 15/1/9.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import "DiscoveryViewController.h"
#import "PurchaseTabViewController.h"
#import "KnowledgeMetaManager.h"
#import "KnowledgeDataTypes.h"
@interface DiscoveryViewController ()

@property (nonatomic,strong) IBOutlet UIButton *nextBtn;

@property (nonatomic,strong) UISwipeGestureRecognizer *swipeGestureRecognizerLeft;
@property (nonatomic,strong) UISwipeGestureRecognizer *swipeGestureRecognizerRight;


@end

@implementation DiscoveryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor yellowColor];
//    self.tabBarController.selectedIndex = 2;
    self.swipeGestureRecognizerLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(checkSwipGestureDirectionWith:)];
        self.swipeGestureRecognizerLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    self.swipeGestureRecognizerLeft.numberOfTouchesRequired = 1;//手指个数
    
    [self.view addGestureRecognizer:self.swipeGestureRecognizerLeft];
    
    //add gestureRecognizer right
    self.swipeGestureRecognizerRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(checkSwipGestureDirectionWith:)];
        self.swipeGestureRecognizerRight.direction = UISwipeGestureRecognizerDirectionRight;
    self.swipeGestureRecognizerRight.numberOfTouchesRequired = 1;//手指个数
    [self.view addGestureRecognizer:self.swipeGestureRecognizerRight];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 通过判断手指滑动方向，切换tab
- (void)checkSwipGestureDirectionWith:(UISwipeGestureRecognizer*)gesture {
    
    [self swip:gesture];
    NSLog(@"滑动了");
}


- (void)swip:(UISwipeGestureRecognizer *)swip

{
    
    NSUInteger index = self.tabBarController.selectedIndex;
    
    NSUInteger count = [self.tabBarController.viewControllers count];
    
    
    
    if (swip.direction == UISwipeGestureRecognizerDirectionLeft && ++index == count){
        
        index = 0;
    }
    else if (swip.direction == UISwipeGestureRecognizerDirectionRight && --index < 0)
        
        index = count-1;
    
    
    
    [self.tabBarController setSelectedIndex:index];
    
    
}

- (IBAction)next:(id)sender {
//    PurchaseTabViewController *pb = [[PurchaseTabViewController alloc] init];
//    [self.navigationController pushViewController:pb animated:YES];
    
    [[KnowledgeMetaManager instance] setDataStatusTo:DATA_STATUS_DOWNLOAD_FAILED andDataStatusDescTo:@"100" forDataWithDataId:@"test_book_1" andType:DATA_TYPE_DATA_SOURCE];
}

@end
