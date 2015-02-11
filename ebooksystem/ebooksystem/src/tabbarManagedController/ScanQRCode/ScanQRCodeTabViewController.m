//
//  ScanQRCodeTabViewController.m
//  ebooksystem
//
//  Created by wanghaoyu on 15/1/13.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import "ScanQRCodeTabViewController.h"
#import "ScanQRCodeViewController.h"
#import "ZBarScanViewController.h"
#import "scanQRcodeDataManager.h"
#import "Config.h"
#import "FirstReuseViewController.h"
#import "LogUtil.h"
#import "UserRecordDataManager.h"


@interface ScanQRCodeTabViewController ()<UITableViewDelegate,UITableViewDataSource>


@property (nonatomic,strong) UITableView *tableView;//tableView
@property (nonatomic, strong) UITableViewCell *cell;
@property (nonatomic,strong) NSMutableArray *dataArray;

@end

@implementation ScanQRCodeTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
    

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"%@",self.navigationController.viewControllers);
}



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

#pragma mark 更新书签 progress

//- (BOOL)updateBookMarkProgressWithBookId:(NSString *)bookId andWith


@end
