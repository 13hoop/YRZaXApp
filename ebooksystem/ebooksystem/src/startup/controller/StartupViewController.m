//
//  StartupViewController.m
//  ebooksystem
//
//  Created by zhenghao on 10/23/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "StartupViewController.h"

#import "KnowledgeManager.h"

#import "ProgressOverlayViewController.h"
#import "CommonWebViewController.h"


#import "MobClick.h"




@interface StartupViewController() <ProgressOverlayViewControllerDelegate, KnowledgeManagerDelegate>
{
    ProgressOverlayViewController *progressOverlayViewController;
}

// 初始化app data
- (BOOL)initAppData;

// load data
- (void)loadData;

// update navigation bar
- (void)updateNavigationBar;

// update view
- (void)updateView;

// jump to webview
- (void)gotoWebView;

@end




@implementation StartupViewController

#pragma mark - properties

#pragma mark - app events
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateNavigationBar];
    [self updateView];
    
    // 友盟统计
    [MobClick beginLogPageView:@"StartupView"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self initAppData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // 友盟统计
    [MobClick endLogPageView:@"StartupView"];
}

#pragma mark - 初始化app data
- (BOOL)initAppData {
    if (![[KnowledgeManager instance] knowledgeDataInited]) {
        // 触发一次数据初始化
        [[KnowledgeManager instance] setDelegate:self];
        [[KnowledgeManager instance] initKnowledgeDataSync];
    }
    else {
        self.tipLabel.text = @"";
        
        [self performBlock:^{
            [self gotoWebView];
        }afterDelay:1];
    }
    
    return YES;
}

#pragma mark - load data
- (void)loadData {
}

#pragma mark - update navigation bar
- (void)updateNavigationBar {
    self.navigationController.navigationBarHidden = YES;
}

#pragma mark - update view
- (void)updateView {
    self.tipLabel.text = @"程序初始化...";
}

#pragma mark - segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[CommonWebViewController class]]) {
        CommonWebViewController *commonWebViewController = (CommonWebViewController *)segue.destinationViewController;
    }
}

- (void)gotoWebView {
    [self performSegueWithIdentifier:@"segue_goto_webview" sender:self];
}

#pragma mark - 延迟执行
- (void)performBlock:(void(^)())block afterDelay:(NSTimeInterval)delay {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), block);
}

#pragma mark - ProgressOverlayViewControllerDelegate methods
- (UIView *)viewForProgressOverlay {
    return self.view;
}

#pragma mark - KnowledgeManagerDelegate methods
- (void)dataInitStartedWithResult:(BOOL)result andDesc:(NSString *)desc {
    self.tipLabel.text = desc;
    
    if (progressOverlayViewController) {
        [progressOverlayViewController dismissProgressView];
    }
    
    // 显示数据初始化进度
    //    dispatch_sync(dispatch_get_main_queue(), ^{
    progressOverlayViewController = [[ProgressOverlayViewController alloc] init];
    [progressOverlayViewController setDelegate:self];
    [progressOverlayViewController showSmallProgressViewWithLongTitleLabelText:desc];
    //    });
}

- (void)dataInitProgressChangedTo:(NSNumber *)progress withDesc:(NSString *)desc {
    self.tipLabel.text = desc;
    
    if (progressOverlayViewController) {
        [progressOverlayViewController updateProgress:[progress integerValue]];
    }
}

- (void)dataInitEndedWithResult:(BOOL)result andDesc:(NSString *)desc {
    self.tipLabel.text = desc;
    
    if (progressOverlayViewController) {
        [progressOverlayViewController dismissProgressView];
    }
    
    self.tipLabel.text = @"程序初始化完成";
}




@end
