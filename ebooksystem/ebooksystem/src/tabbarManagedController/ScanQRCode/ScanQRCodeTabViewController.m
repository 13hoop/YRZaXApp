//
//  ScanQRCodeTabViewController.m
//  ebooksystem
//
//  Created by wanghaoyu on 15/1/13.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import "ScanQRCodeTabViewController.h"
#import "ScanQRCodeViewController.h"
#import "scanQRcodeDataManager.h"
#import "Config.h"
#import "FirstReuseViewController.h"
#import "LogUtil.h"
#import "UserRecordDataManager.h"
#import "WebViewBridgeRegisterUtil.h"

#import "MRActivityIndicatorView.h"

@interface ScanQRCodeTabViewController ()<UITableViewDelegate,UITableViewDataSource,UIWebViewDelegate>
{
    MRActivityIndicatorView *activityIndicatorView;
}

@property (nonatomic, strong) UITableView *tableView;//tableView
@property (nonatomic, strong) UITableViewCell *cell;
@property (nonatomic, strong) NSMutableArray *dataArray;

//扫码：只加载扫码得到的url
@property (nonatomic, strong) UIWebView *webView;

@end

@implementation ScanQRCodeTabViewController

// webview
- (UIWebView *)webView {
    if (_webView == nil) {
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        _webView.delegate = self;
        
        [self.view addSubview:_webView];
    }
    
    return _webView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    /*
    self.dataArray = [NSMutableArray array];
    self.dataArray = (NSMutableArray *)[self getScanResultItemArrayWithScanInfo];//获取数据源
//
    //扫描得到的结果不为空，则电子书已经下载
    if (self.dataArray.count > 0 && self.dataArray != nil) {
        [self createTableView];
    }
    else {
        //回到扫描controller中，为了：再次点击扫一扫时时能够出现相机而不是黑屏。
        scanResultItem *item = [[scanResultItem alloc] init];
            item.descInMap = @"您的扫描结果为空，请下载电子书后再试";
            [self.dataArray addObject:item];
            [self createTableView];

        //电子书未下载
        self.tabBarController.selectedIndex = 1;

    }
     */

    //2 所有的操作都有服务端进行处理，native只需要加载拿到的url。
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.webView.scrollView.bounces = NO;
    self.webView.scrollView.showsVerticalScrollIndicator = NO;
    self.webView.dataDetectorTypes = UIDataDetectorTypeNone;//禁掉数字自动解析
    
    
    WebViewBridgeRegisterUtil *webviewBridgeUtil = [[WebViewBridgeRegisterUtil alloc] init];
    webviewBridgeUtil.webView = self.webView;
    webviewBridgeUtil.controller = self;
    webviewBridgeUtil.mainControllerView = self.view;
    webviewBridgeUtil.navigationController = self.navigationController;
    webviewBridgeUtil.tabBarController = self.tabBarController;
    [webviewBridgeUtil initWebView];
    
    //进到扫描页面就移除掉nav管理的view controller数组中的倒数第二个元素
//    NSMutableArray *controllers = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
//    [controllers removeObjectAtIndex:controllers.count-2];
//    [self.navigationController setViewControllers:controllers];
    
    
    [self updateWebView];
    //创建网络加载视图
    [self createActivityIndicator];

    
}

- (BOOL)updateWebView {
    NSURL *myBagUrl = [NSURL URLWithString:self.scanInfoStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:myBagUrl];
    [self.webView loadRequest:request];
    
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.navigationController.navigationBarHidden = YES;
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    self.tabBarController.tabBar.hidden = NO;
}


/*现在扫描得到的结果都有服务端来处理（注释部分的代码是native处理扫描到的结果的代码）
 *
//创建tableView
- (void)createTableView {
    self.tabBarController.tabBar.hidden = YES;
    CGRect rect = [[UIScreen mainScreen] bounds];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    self.tableView.delegate = self;
    self.tableView.dataSource =self;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    {
        if ([self.tableView respondsToSelector:@selector(separatorInset)]) {
            self.tableView.separatorInset = UIEdgeInsetsZero;
        }
        
        if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
            self.tableView.layoutMargins = UIEdgeInsetsZero;
        }
    }
    
    
    [self.view addSubview:self.tableView];
    
    
}
//tableView的代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        NSInteger rowNumber = (unsigned long)self.dataArray.count;
        return rowNumber;

    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"cellMenuItem";
    
    self.cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (self.cell == nil) {
        self.cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        self.cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
        self.cell.textLabel.textColor = [UIColor lightGrayColor];
    }
    //找到对应的scanitem
    scanResultItem *item = [self.dataArray objectAtIndex:indexPath.row];
    self.cell.textLabel.text = item.descInMap;
    return self.cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //选中对应的item进行拼接
    scanResultItem *item = [self.dataArray objectAtIndex:indexPath.row];
    //3、更新progress（书签）
    UserRecordDataManager *recordManager = [UserRecordDataManager instance];
    BOOL ret = [recordManager updateBookMarkMetaProgressWithProgressInfo:item];
    if (!ret) {
        LogError(@"ScanQRCodeTabViewController - didSecelect : failed to update BookMarkMetaProgressWithProgressInfo: ");
    }
    
    //4、拼接字符串
    NSString *pagetype = item.pageTypeInMap;
    NSString *bookId = item.bookIdInMap;
    NSString *queryId = item.queryIdInMap;
    NSString *pageArgs = item.pageArgsInMap;
    NSString *knowledgePath = [[Config instance] knowledgeDataConfig].knowledgeDataRootPathInDocuments;
    NSString *pageTypePath = [NSString stringWithFormat:@"%@.html",pagetype];
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@/%@/%@?book_id=%@&query_id=%@",knowledgePath,bookId,@"render",pageTypePath,bookId,queryId];
    //进入到具体的书中
    FirstReuseViewController *first = [[FirstReuseViewController alloc] init];
    first.webUrl = urlStr;
    [self.navigationController pushViewController:first animated:YES];
}

#pragma mark 处理扫描controller中传过来的信息

//根据扫描结果从QR_code中查找信息，并获得item数组
- (NSArray *)getScanResultItemArrayWithScanInfo {
    //
    scanQRcodeDataManager *scanManager = [scanQRcodeDataManager instance];
    NSArray *itemArray = [scanManager getMapDataByScanInfo:self.scanInfoStr];
    if (itemArray == nil || itemArray.count <= 0) {
        LogWarn(@"根据扫描信息，查询数据得到的结果为空，跳到详情页上的操作在这里处理");
        //跳转到详情页的操作在这里处理。
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"二维码对应的电子书未下载" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
        return nil;
    }
    return itemArray;
}

*/

#pragma mark webview delegate method
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (request) {
        LogDebug(@"[MatchViewConroller] Web request: UA: %@", [request valueForHTTPHeaderField:@"User-Agent"]);
    }
    
    //    [self injectJSToWebView:webView];
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    //开始网络加载的动画
    [self showProgressAsActivityIndicator];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self injectJSToWebView:webView];
    //结束加载动画
    [self hideProgressOfActivityIndicator];
}

#pragma mark - js injection

- (void)injectJSToWebView:(UIWebView *)webView {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"webview-js-bridge" ofType:@"js"];
    NSString *jsString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    [webView stringByEvaluatingJavaScriptFromString:jsString];
}

#pragma mark 创建加载动画视图
-(void)createActivityIndicator
{
    activityIndicatorView=[[MRActivityIndicatorView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-30)/2, (self.view.frame.size.height-30)/2,30, 30)];
    [self.view addSubview:activityIndicatorView];
    
}

#pragma mark 加载提示动画view的开始结束动画方法

- (void)showProgressAsActivityIndicator {
    if (activityIndicatorView) {
        activityIndicatorView.hidden = NO;
        activityIndicatorView.hidesWhenStopped = YES;
        activityIndicatorView.tintColor = [UIColor blueColor];
        activityIndicatorView.backgroundColor = [UIColor clearColor];
        [activityIndicatorView startAnimating];
    }
}

- (void)hideProgressOfActivityIndicator {
    if (activityIndicatorView) {
        [activityIndicatorView stopAnimating];
        //    activityIndicatorView.hidden = YES;
    }
}

@end
