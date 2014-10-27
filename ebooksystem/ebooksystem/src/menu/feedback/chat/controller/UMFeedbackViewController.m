//
//  UMFeedbackViewController.m
//  UMeng Analysis
//
//  Created by liu yu on 7/12/12.
//  Copyright (c) 2012 Realcent. All rights reserved.
//

#import "UMFeedbackViewController.h"

#import "UMFeedbackTableViewCellLeft.h"
#import "UMFeedbackTableViewCellRight.h"
#import "UMContactViewController.h"

#import "StatisticsManager.h"


#define TOP_MARGIN 20.0f
#define kNavigationBar_ToolBarBackGroundColor  [UIColor colorWithRed:0.149020 green:0.149020 blue:0.149020 alpha:1.0]
#define kContactViewBackgroundColor  [UIColor colorWithRed:0.078 green:0.584 blue:0.97 alpha:1.0]

static UITapGestureRecognizer *tapRecognizer;

@implementation UINavigationBar (CustomImage)
- (void)drawRect:(CGRect)rect {
    UIImage *image = [UIImage imageNamed:@"nav_btn_bg"];
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}
@end

@interface UMFeedbackViewController ()
@property(nonatomic, copy) NSString *mContactInfo;
@property(nonatomic,copy)NSString *remarkInfo;
@end

@implementation UMFeedbackViewController

@synthesize mTextField = _mTextField, mTableView = _mTableView, mToolBar = _mToolBar, mFeedbackData = _mFeedbackData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //设置一下bool值，在完善信息处使用
        self.isSelected=YES;
    }
    return self;
}

- (void)customizeNavigationBar:(UINavigationBar *)bar {
    bar.clipsToBounds = YES;
    if ([bar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        UIImage *image = [self imageWithColor:kNavigationBar_ToolBarBackGroundColor];

        [bar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    }
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

- (void)setupTableView {
    _tableViewTopMargin = self.navigationController.navigationBar.frame.size.height;
    //从本地取到bool值
    BOOL contactViewHide = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UMFB_ShowContactView"] boolValue];

    if (!contactViewHide) {
        _tableViewTopMargin = 88.0f;
        UILabel *title = (UILabel *) [self.mContactView viewWithTag:11];
        title.text = NSLocalizedString(@"您的联系方式", @"您的联系方式");
        //第一次置为NO,第二次置为YES,为YES时置反就成了NO
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"UMFB_ShowContactView"];
    } else {
        _tableViewTopMargin = 0;
        //判断是否是第一次登陆，若是第一次登陆则显示联系人试图，否则隐藏
        //给用户选择是否要是选择自己的信息-只需修改UMFB_ShowContactView为NO即可
        
        [self.mContactView removeFromSuperview];
    }

    self.mTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
}

- (void)setupEGORefreshTableHeaderView {
    if (_refreshHeaderView == nil) {

        UMEGORefreshTableHeaderView *view = [[UMEGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.mTableView.bounds.size.height, self.mTableView.frame.size.width, self.mTableView.bounds.size.height)];
        view.delegate = (id <UMEGORefreshTableHeaderDelegate>) self;
        [self.mTableView addSubview:view];
        _refreshHeaderView = view;
    }

    [_refreshHeaderView refreshLastUpdatedDate];
}
//发送按钮
- (void)setupToolbar {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    button.frame = CGRectMake(256, 7, 57.0f, 30.0f);
    button.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [button setTitle:NSLocalizedString(@"发送", @"发送") forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"res/drawable/umeng-images/send.png"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"res/drawable/umeng-images/send_selected.png"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(sendFeedback:) forControlEvents:UIControlEventTouchUpInside];

    [self.mToolBar addSubview:button];

    [self setupTextField];
}

- (void)setupTextField {
    _mTextField = [[UITextField alloc] initWithFrame:CGRectMake(6, 7, _mToolBar.frame.size.width - 74.0f, 30.0f)];
    _mTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _mTextField.backgroundColor = [UIColor whiteColor];
    _mTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _mTextField.textAlignment = NSTextAlignmentLeft;
    _mTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _mTextField.borderStyle = UITextBorderStyleLine;
    _mTextField.font = [UIFont systemFontOfSize:14.0f];
    _mTextField.placeholder=@"我想说";
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 30)];
    _mTextField.leftView = paddingView;
    _mTextField.leftViewMode = UITextFieldViewModeAlways;
    _mTextField.delegate = (id <UITextFieldDelegate>) self;

    [self.mToolBar addSubview:_mTextField];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {

    UMContactViewController *contactViewController = [[UMContactViewController alloc] initWithNibName:@"UMContactViewController" bundle:nil];

    contactViewController.delegate = (id <UMContactViewControllerDelegate>) self;
    [self.navigationController pushViewController:contactViewController animated:YES];
    if ([self.mContactInfo length]) {
//        contactViewController.textView.text = self.mContactInfo;
        //应该是显示之前注册的信息的
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [_refreshHeaderView egoRefreshScrollViewShowLoadingManual:self.mTableView];
    [_refreshHeaderView egoRefreshScrollViewDataSourceStartManualLoading:self.mTableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
//Feedback
    self.navigationItem.title = NSLocalizedString(@"用户反馈", @"用户反馈");

    [self setBackButton];
    [self setBackgroundColor];
    [self setupTableView];
    [self setupEGORefreshTableHeaderView];
    [self setupToolbar];
    [self customizeNavigationBar:self.navigationController.navigationBar];
    [self setFeedbackClient];
    [self updateTableView:nil];
    [self handleKeyboard];
    [self setAddContactButton];

    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(handleSingleTap:)];
    [self.mContactView addGestureRecognizer:singleFingerTap];

    _shouldScrollToBottom = YES;

}

- (void)handleKeyboard {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAnywhere:)];
}

- (void)setFeedbackClient {
    _mFeedbackData = [[NSArray alloc] init];
    feedbackClient = [UMFeedback sharedInstance];
    if ([self.appkey isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"NO Umeng kUmengAppkey"
                                                        message:@"Please define UMENG_APPKEY macro!"
                                                       delegate:nil cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    [feedbackClient setAppkey:self.appkey delegate:(id <UMFeedbackDataDelegate>) self];

//    从缓存取topicAndReplies
    self.mFeedbackData = feedbackClient.topicAndReplies;
}

- (void)setBackgroundColor {
//    self.mTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"messages_tableview_background"]];
    //颜色rgb使用方法：
    self.mTableView.backgroundColor=[UIColor colorWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:1.0];
    if ([self.mToolBar respondsToSelector:@selector(setBackgroundImage:forToolbarPosition:barMetrics:)]) {
//        UIImage *image = [self imageWithColor:kNavigationBar_ToolBarBackGroundColor];
//        UIImage *image=[self imageWithColor:[UIColor whiteColor]];
        UIImage *image=[self imageWithColor:[UIColor grayColor]];

        [self.mToolBar setBackgroundImage:image forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
    } else {
        self.mToolBar.barStyle = UIBarStyleBlack;
    }
    self.mContactView.backgroundColor = kContactViewBackgroundColor;
}

- (void)setBackButton {
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];

    [backBtn addTarget:self action:@selector(backToPrevious) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backButtonItem;

    backBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [backBtn setTitle:NSLocalizedString(@"返回", @"返回") forState:UIControlStateNormal];
    backBtn.frame = CGRectMake(0, 0, 51.0f, self.navigationController.navigationBar.frame.size.height * 0.7);
    backBtn.autoresizingMask = UIViewAutoresizingFlexibleHeight;
}

-(void)setAddContactButton
{
    UIButton *contactButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [contactButton addTarget:self action:@selector(showContactview:) forControlEvents:UIControlEventTouchUpInside];
    [contactButton setTitle:NSLocalizedString(@"完善信息", @"完善信息") forState:UIControlStateNormal];
    [contactButton setTitle:NSLocalizedString(@"下次再说", @"下次再说") forState:UIControlStateSelected];
    contactButton.titleLabel.font=[UIFont systemFontOfSize:12.0f];
    contactButton.frame=CGRectMake(0, self.navigationController.navigationBar.frame.size.width-51.0f, 51.0f, self.navigationController.navigationBar.frame.size.height*0.7);
    UIBarButtonItem *contactButtonItem=[[UIBarButtonItem alloc] initWithCustomView:contactButton];
    self.navigationItem.rightBarButtonItem=contactButtonItem;
    contactButton.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
}

-(void)showContactview:(UIButton*)btn
{
    if (self.isSelected) {
        [self.view addSubview:self.mContactView];
        [btn setTitle:@"下次再说" forState:UIControlStateNormal];
    }
    else
    {
        [self.mContactView removeFromSuperview];
        [btn setTitle:@"完善信息" forState:UIControlStateNormal];
    }

     self.isSelected=! self.isSelected;
    NSLog(@"点击了，点击了");
}
- (void)didTapAnywhere:(UITapGestureRecognizer *)recognizer {
    [self.mTextField resignFirstResponder];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark keyboard notification

- (void)keyboardWillShow:(NSNotification *)notification {
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGFloat keyboardHeight = [[[notification userInfo] objectForKey:UIKeyboardBoundsUserInfoKey] CGRectValue].size.height;

    [UIView animateWithDuration:animationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{

                         CGRect toolbarFrame = self.mToolBar.frame;
                         toolbarFrame.origin.y = self.view.bounds.size.height - keyboardHeight - toolbarFrame.size.height;
                         self.mToolBar.frame = toolbarFrame;

                         CGRect tableViewFrame = self.mTableView.frame;
                         tableViewFrame.size.height = self.view.bounds.size.height - self.navigationController.navigationBar.frame.size.height - keyboardHeight;
                         self.mTableView.frame = tableViewFrame;
                     }
                     completion:^(BOOL finished) {
                         if (_shouldScrollToBottom) {
                             [self scrollToBottom];
                         }
                     }
    ];

    [self.view addGestureRecognizer:tapRecognizer];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];

    [UIView beginAnimations:@"bottomBarDown" context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];

    CGRect toolbarFrame = self.mToolBar.frame;
    toolbarFrame.origin.y = self.view.bounds.size.height - toolbarFrame.size.height;
    self.mToolBar.frame = toolbarFrame;

    CGRect tableViewFrame = self.mTableView.frame;
    tableViewFrame.size.height = self.view.bounds.size.height - self.navigationController.navigationBar.frame.size.height;
    self.mTableView.frame = tableViewFrame;

    [UIView commitAnimations];

    [self.view removeGestureRecognizer:tapRecognizer];
}

- (void)backToPrevious {
//    [self dismissModalViewControllerAnimated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (IBAction)sendFeedback:(id)sender {
    if ([self.mTextField.text length]) {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [dictionary setObject:self.mTextField.text forKey:@"content"];

        if ([self.mContactInfo length]) {
            [dictionary setObject:[NSDictionary dictionaryWithObjectsAndKeys:self.mContactInfo, @"plain", nil] forKey:@"contact"];
            [dictionary setObject:[NSDictionary dictionaryWithObjectsAndKeys:self.remarkInfo,@"info", nil] forKey:@"remark"];
            
            //在这里重新拼一个字典
            /*
            gender,     性别,      NSString, "1"或"male"为男 "0"或"female" 为女
            age_group,  年龄段,    NSString, "1"..."8",对应表如下
            content,    反馈内容,  NSString,  长度不应超过255个字符
            remark,     备注,      NSDictionary, 可以存放自定义的内容，比如评分等
            contact,    联系方式，  NSDictionary, 可以存放和用户信息相关的内容，比如用户名等
            
            "remark"和"contact"两个字段可供开发者传入自定义内容，这些内容会在网页上展现.
            */
            //再拼一个remark到字典中
            
            

        }

        [feedbackClient post:dictionary];
        [self.mTextField resignFirstResponder];
        _shouldScrollToBottom = YES;
    }
}

#pragma mark tableview delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [_mFeedbackData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *content = [[feedbackClient.topicAndReplies objectAtIndex:(NSUInteger) indexPath.row] objectForKey:@"content"];
    CGSize labelSize = [content sizeWithFont:[UIFont systemFontOfSize:14.0f]
                           constrainedToSize:CGSizeMake(226.0f, MAXFLOAT)
                               lineBreakMode:UILineBreakModeWordWrap];
    return labelSize.height + 40 + TOP_MARGIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *L_CellIdentifier = @"L_UMFBTableViewCell";
    static NSString *R_CellIdentifier = @"R_UMFBTableViewCell";

    NSDictionary *data = [self.mFeedbackData objectAtIndex:(NSUInteger) indexPath.row];

    if ([[data valueForKey:@"type"] isEqualToString:@"dev_reply"]) {
        UMFeedbackTableViewCellLeft *cell = (UMFeedbackTableViewCellLeft *) [tableView dequeueReusableCellWithIdentifier:L_CellIdentifier];
        if (cell == nil) {
            cell = [[UMFeedbackTableViewCellLeft alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:L_CellIdentifier];
        }
        cell.textLabel.text = [data valueForKey:@"content"];
        cell.timestampLabel.text = [data valueForKey:@"datetime"];
        return cell;
    }
    else {

        UMFeedbackTableViewCellRight *cell = (UMFeedbackTableViewCellRight *) [tableView dequeueReusableCellWithIdentifier:R_CellIdentifier];
        if (cell == nil) {
            cell = [[UMFeedbackTableViewCellRight alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:R_CellIdentifier];
        }

        cell.textLabel.text = [data valueForKey:@"content"];
        cell.timestampLabel.text = [data valueForKey:@"datetime"];

        return cell;

    }
}

#pragma mark ContactViewController中的代理方法 delegate method
//更新mContentview上的内容
- (void)updateContactInfo:(UMContactViewController *)controller contactInfo:(NSString *)info  andWithReamrkInfo:(NSString *)remarkInfo{
    if ([info length]) {
        self.mContactInfo = info;
        self.remarkInfo=remarkInfo;
        UILabel *title = (UILabel *) [self.mContactView viewWithTag:11];
        title.text = [NSString stringWithFormat:@"%@ : %@", NSLocalizedString(@"您的联系方式", @"您的联系方式"), info];
    }
}

#pragma mark Umeng Feedback delegate

- (void)updateTableView:(NSError *)error {
    if ([self.mFeedbackData count]) {
        [self.mTableView reloadData];
    }
}

- (void)updateTextField:(NSError *)error {
    if (!error) {
        self.mTextField.text = @"";
        [feedbackClient get];
    }
}

- (void)getFinishedWithError:(NSError *)error {
    if (!error) {
        [self updateTableView:error];
    }

    if (_shouldScrollToBottom) {
        [self scrollToBottom];
    }

    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:1.0];
}

- (void)postFinishedWithError:(NSError *)error {
//    UIAlertView *alertView;
//    if (!error)
//    {
//        alertView = [[UIAlertView alloc] initWithTitle:@"感谢您的反馈!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    }
//    else
//    {
//        alertView = [[UIAlertView alloc] initWithTitle:@"发送失败!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    }
//    
//    [alertView show];

    [self updateTextField:error];
}

- (void)doneLoadingTableViewData {
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.mTableView];
    //刷新完成滚动到底部
//    [self scrollToBottom];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollToBottom {
    if ([self.mTableView numberOfRowsInSection:0] > 1) {
        int lastRowNumber = [self.mTableView numberOfRowsInSection:0] - 1;
        NSIndexPath *ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
        [self.mTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {

    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)reloadTableViewDataSource {
    _reloading = YES;
    [feedbackClient get];
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(UMEGORefreshTableHeaderView *)view {
    _shouldScrollToBottom = NO;
    [self reloadTableViewDataSource];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(UMEGORefreshTableHeaderView *)view {
    return _reloading; // should return if data source model is reloading
}

- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(UMEGORefreshTableHeaderView *)view {
    return [NSDate date]; // should return date data source was last changed
}

#pragma mark UITextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];

    return YES;
}

- (void)dealloc {

    feedbackClient.delegate = nil;
}
-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden=NO;
    [super viewWillAppear:animated];
    
    [[StatisticsManager instance] beginLogPageView:@"PageFeedback"];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[StatisticsManager instance] endLogPageView:@"PageFeedback"];
}
@end
