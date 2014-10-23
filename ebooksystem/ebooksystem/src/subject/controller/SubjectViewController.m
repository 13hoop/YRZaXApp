//
//  SubjectViewController.m
//  ebooksystem
//
//  Created by zhenghao on 10/4/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "SubjectViewController.h"
#import "Config.h"
#import "KnowledgeSubject.h"
#import "SubjectTableViewCell.h"

#import "ProgressOverlayViewController.h"
#import "MoreViewController.h"
#import "CommonWebViewController.h"


#import "BaseTitleBar.h"
#import "QBTitleView.h"
#import "UIImage+tintedImage.h"

#import "KnowledgeManager.h"

#import "MobClick.h"


//#define IS_TEST_MODE 1
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@interface SubjectViewController () <UITableViewDataSource, UITableViewDelegate, ProgressOverlayViewControllerDelegate, KnowledgeManagerDelegate>
{
    ProgressOverlayViewController *progressOverlayViewController;
}

// data
@property (nonatomic, strong) NSMutableArray *subjects;

// outlets
@property (strong, nonatomic) IBOutlet UIView *bannerView;
@property (strong, nonatomic) IBOutlet UITableView *subjectTableView;

// actions
- (IBAction)menuButtonPressed:(id)sender;

// methods
// 初始化app data
- (BOOL)initAppData;

// load data
- (void)loadData;

// load views
- (void)loadBannerView;
- (void)loadSubjectView;

// update navigation bar
- (void)updateNavigationBar;

// update title bar
- (void)updateTitleBar;

@end

@implementation SubjectViewController

@synthesize subjects = _subjects;

#pragma mark - properties
- (NSMutableArray *)subjects {
    if (_subjects == nil) {
        _subjects = [[NSMutableArray alloc] init];
    }
    
    return _subjects;
}

#pragma mark - app life
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
    
    [self loadBannerView];
    [self loadSubjectView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateNavigationBar];
    [self updateTitleBar];
    
    // 友盟统计
    [MobClick beginLogPageView:@"SubjectView"];
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
    [MobClick endLogPageView:@"SubjectView"];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - 初始化app data
- (BOOL)initAppData {
    // 触发一次数据初始化
    [[KnowledgeManager instance] setDelegate:self];
    [[KnowledgeManager instance] initKnowledgeDataSync];
    
    return YES;
}

#pragma mark - load data
- (void)loadData {
    // english
    KnowledgeSubject *englishSubject = [[KnowledgeSubject alloc] init];
    englishSubject.subjectId = @"subject_english_id";
    englishSubject.name = @"英语";
    englishSubject.desc = @"关联词汇分组式记忆，历年真题碎片化讲解。考什么学什么，帮你减轻考研英语压力。";
    englishSubject.coverImage = [[[Config instance] drawableConfig] getImageFullPath:@"index_english_cover.png"];
    
    [self.subjects addObject:englishSubject];
    
    // potilics
    KnowledgeSubject *politicsSubject = [[KnowledgeSubject alloc] init];
    politicsSubject.subjectId = @"subject_politics_id";
    politicsSubject.name = @"政治";
    politicsSubject.desc = @"重要考点习题，疑难知识点精讲。第一款权威考研政治APP。形势与政策、20天20题即将上线，敬请期待。";
    politicsSubject.coverImage = [[[Config instance] drawableConfig] getImageFullPath:@"index_politics_cover.png"];
    
    [self.subjects addObject:politicsSubject];
}

#pragma mark - load views
- (void)loadBannerView {
    [self.bannerView setFrame:CGRectMake(0, 0, self.view.frame.size.width, 260)];
    
    UIImageView *bannerImageView = [[UIImageView alloc] initWithFrame:self.bannerView.frame];
    bannerImageView.image = [UIImage imageNamed:[[[Config instance] drawableConfig] getImageFullPath:@"index_video_banner.png"]];
    [self.bannerView addSubview:bannerImageView];
}

- (void)loadSubjectView {
    [self.subjectTableView setFrame:CGRectMake(0,
                                               20 + self.bannerView.frame.size.height,
                                               self.view.frame.size.width,
                                               self.view.frame.size.height - (20 + self.bannerView.frame.size.height))];
    
    self.subjectTableView.delegate = self;
    self.subjectTableView.dataSource = self;
    
    //    self.subjectTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //    self.subjectTableView.bounces = NO;
}

// update navigation bar
- (void)updateNavigationBar {
    self.navigationController.navigationBarHidden = YES;
}

// update title bar
- (void)updateTitleBar {
    // 状态栏高度
    CGRect statusBarRect = [[UIApplication sharedApplication] statusBarFrame];
    
    // 标题栏
    BaseTitleBar *titleBar = [[BaseTitleBar alloc] initWithFrame:CGRectMake(0, statusBarRect.size.height, self.view.frame.size.width, 44)];
    
    //// 标题栏背景色
    titleBar.backgroundColor = [UIColor blackColor];
    
    //// 标题栏中部
    {
        titleBar.titleText = @"";
        titleBar.titleImage = [UIImage imageNamed:[[[Config instance] drawableConfig] getImageFullPath:@"main_portal_logo.png"]];
        titleBar.titleHighlightedImage = [[UIImage imageNamed:[[[Config instance] drawableConfig] getImageFullPath:@"main_portal_logo.png"]] tintedImageUsingColor:[UIColor colorWithWhite:0.2 alpha:0.5]];
    }
    
    //// 标题栏左侧
    {
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backButton.frame = CGRectMake(10, 0, 40, 44);
        
//        NSString *backButtonTitle = (IS_TEST_MODE ? @"测试" : @"");
        NSString *backButtonTitle = @"测试";
        [backButton setTitle:backButtonTitle forState:UIControlStateNormal];
        backButton.titleLabel.font=[UIFont systemFontOfSize:12.0f];
        [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        titleBar.leftView = backButton;
    }
    
    //// 标题栏右侧
    {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(statusBarRect.size.width - 28, 15, 16, 14)];
        imageView.image = [UIImage imageNamed:[[[Config instance] drawableConfig] getImageFullPath:@"main_portal_top_menu.png"]];
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(menuButtonPressed:)];
        [imageView addGestureRecognizer:singleTap];
        
        titleBar.rightView = imageView;
    }
    
    [self.view addSubview:titleBar];
}

#pragma mark - subject table view delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.subjects.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.subjectTableView.frame.size.height / 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"subject_table_view_cell";
    
    // 注册SubjectTableViewCell.xib
    static BOOL nibsRegistered = NO;
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:@"SubjectTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:cellId];
        nibsRegistered = YES;
    }
    
    // 构造cell
    SubjectTableViewCell *cell = (SubjectTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[SubjectTableViewCell alloc] initWithStyle:
                UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    cell.backgroundColor = [UIColor colorWithRed:226/250.0 green:226/250.0 blue:226/250.0 alpha:1.0];
    
    KnowledgeSubject *subject = [self.subjects objectAtIndex:indexPath.row];
    
    cell.coverImageView.image = [UIImage imageNamed:subject.coverImage];
    cell.nameLabel.text = subject.name;
    cell.descLabel.text = subject.desc;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // todo: 根据iphone还是ipad来查找不同的storyboard
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"storyboard_main_iphone" bundle:nil];
    
    CommonWebViewController *commonWebViewController = [storyBoard instantiateViewControllerWithIdentifier:@"common_web_view_controller"];
    if (commonWebViewController == nil) {
        return;
    }
    
    KnowledgeSubject *subject = [self.subjects objectAtIndex:indexPath.row];
    commonWebViewController.knowledgeSubject = subject;
    
    [self.navigationController pushViewController:commonWebViewController animated:YES];
}

#pragma mark - actions
- (IBAction)backButtonPressed:(id)sender {
//    if (IS_TEST_MODE) {
        [[KnowledgeManager instance] test];
        return;
//    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)menuButtonPressed:(id)sender {
    MoreViewController *more = [[MoreViewController alloc] init];
    [self.navigationController pushViewController:more animated:YES];
}

#pragma mark - ProgressOverlayViewControllerDelegate methods
- (UIView *)viewForProgressOverlay {
    return self.view;
}

#pragma mark - KnowledgeManagerDelegate methods
- (void)dataInitStartedWithResult:(BOOL)result andDesc:(NSString *)desc {
    if (progressOverlayViewController) {
        [progressOverlayViewController dismissProgressView];
    }
    
    // 显示数据初始化进度
//    dispatch_async(dispatch_get_main_queue(), ^{
    progressOverlayViewController = [[ProgressOverlayViewController alloc] init];
    [progressOverlayViewController setDelegate:self];
    [progressOverlayViewController showSmallProgressViewWithLongTitleLabelText:desc];
//    });
}

- (void)dataInitProgressChangedTo:(NSNumber *)progress withDesc:(NSString *)desc {
    if (progressOverlayViewController) {
        [progressOverlayViewController updateProgress:[progress integerValue]];
    }
}

- (void)dataInitEndedWithResult:(BOOL)result andDesc:(NSString *)desc {
    if (progressOverlayViewController) {
        [progressOverlayViewController dismissProgressView];
    }
}



@end
