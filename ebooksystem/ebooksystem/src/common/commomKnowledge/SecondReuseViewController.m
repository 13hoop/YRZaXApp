//
//  SecondReuseViewController.m
//  ebooksystem
//
//  Created by wanghaoyu on 15/2/2.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import "SecondReuseViewController.h"
#import "WebViewJavascriptBridge.h"
#import "LogUtil.h"
#import "UIColor+Hex.h"
#import "UMSocial.h"
#import "UMSocialSnsService.h"
#import "UMSocialScreenShoter.h"

#import "DirectionMPMoviePlayerViewController.h"
#import "CustomURLProtocol.h"

#import "Config.h"

#import "WebUtil.h"
#import "LogUtil.h"
#import "KnowledgeManager.h"
#import "KnowledgeWebViewController.h"
#import "NSUserDefaultUtil.h"
#import "PathUtil.h"
#import "OperateCookie.h"
#import "SBJson.h"
#import "KnowledgeMetaManager.h"
#import "FirstReuseViewController.h"


#import "BookMarkMeta.h"
#import "UUIDUtil.h"
#import "UserRecordDataManager.h"

#import "CollectionMeta.h"
#import "ScanQRCodeViewController.h"

#import "UMFeedbackViewController.h"
#import "StatisticsManager.h"
#import "PersionalCenterUrlConfig.h"
#import "SecondRenderKnowledgeViewController.h"
#import "WebViewBridgeRegisterUtil.h"
#import "StatisticsManager.h"


@interface SecondReuseViewController ()<UIWebViewDelegate>


#pragma mark - properties
// bridge between webview and js
@property (nonatomic, strong) WebViewJavascriptBridge *javascriptBridge;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic,strong) NSString *oldUserAgent;



#pragma mark - methods

// 设置user agent
- (BOOL)checkUserAgent;





@end

@implementation SecondReuseViewController


#pragma mark - properties
// webUrl
- (NSString *)webUrl {
    if (_webUrl != nil && ![_webUrl hasSuffix:[Config instance].webConfig.userAgent]) {
        NSString *connector = @"&";
        if ([_webUrl hasSuffix:@"/"]) {
            connector = @"\?";
        }
        _webUrl = [NSString stringWithFormat:@"%@%@ua=%@", _webUrl, connector, [Config instance].webConfig.userAgent];
    }
    
    return _webUrl;
}

// webview
- (UIWebView *)webView {
    if (_webView == nil) {
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height - 20)];
        _webView.delegate = self;
        
        [self.view addSubview:_webView];
    }
    
    return _webView;
}

/*
// bridge between webview and js
-(WebViewJavascriptBridge *)javascriptBridge {
    if (_javascriptBridge == nil) {
        _javascriptBridge = [WebViewJavascriptBridge bridgeForWebView:self.webView webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
            LogDebug(@"Received message from javascript: %@", data);
            responseCallback(@"'response data from obj-c'");
        }];
        [self initWebView];
    }
    
    return _javascriptBridge;
}
*/





- (void)viewDidLoad {
    [super viewDidLoad];
    LogInfo(@"现在进入了secondReusecontroller中");
//    [self initWebView];
    self.view.backgroundColor = [UIColor colorWithHexString:@"#4A90E2"];
    
    WebViewBridgeRegisterUtil *webviewBridgeUtil = [[WebViewBridgeRegisterUtil alloc] init];
    webviewBridgeUtil.webView = self.webView;
    webviewBridgeUtil.controller = self;
    webviewBridgeUtil.mainControllerView = self.view;
    webviewBridgeUtil.navigationController = self.navigationController;
    webviewBridgeUtil.tabBarController = self.tabBarController;
    [webviewBridgeUtil initWebView];
    
//    if ([self.shouldChangeBackground isEqualToString:@"needChange"]) {
//        self.view.backgroundColor=[UIColor colorWithHexString:@"#242021" alpha:1];
//    }
//    else {
//        self.view.backgroundColor = [UIColor colorWithHexString:@"#4C501D" alpha:1];
//    }
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.webView.scrollView.bounces = NO;
    self.webView.scrollView.showsVerticalScrollIndicator = NO;
    
    //    [self injectJSToWebView:self.webView];
    //    self.webview.delegate=self;
    [self updateWebView];

}

- (void)viewWillAppear:(BOOL)animated {
    
    NSLog(@"进入到第二个页面了");
    //隐藏tabbar状态
    self.tabBarController.tabBar.hidden = YES;
    //隐藏掉状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:false];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //隐藏navbar状态
    self.navigationController.navigationBarHidden = YES;
    
    //JS传来的need_refresh参数为0,暂定为每次都要刷新。
//    [self.webView reload];
    
    //根据JS传的need_refresh参数决定当前页面是否需要刷新
    if([self.needRefresh isEqualToString:@"1"]) {
        [self.webView reload];//等于1是就刷新，反之不作处理
    }
    
    //在当前页面渲染时，若是需要横屏，则横屏
    if ([self.needOrientation isEqualToString:@"landscape"]) {
        //1 将self.view旋转
        CGAffineTransform transform = CGAffineTransformIdentity;
        transform = CGAffineTransformRotate(transform, M_PI/2);
        self.view.transform = transform;
        //2 self.view旋转后，重新设置webview的frame
        CGRect rect = [[UIScreen mainScreen] bounds];
        self.webView.frame = CGRectMake(0, 0, rect.size.height, rect.size.width);//将原始视图的宽高和新视图的宽高值互换
        
        
        //旋转时隐藏掉状态栏
        [[UIApplication sharedApplication] setStatusBarHidden:TRUE];
    }
    //触发JS事件
    [self injectJSToWebview:self.webView andJSFileName:@"SamaPageShow"];
    self.tabBarController.tabBar.hidden = YES;
    
    //进入读书页的统计
    [[StatisticsManager instance] beginLogPageView:@"readPage"];
    
   
}
//iOS7之后修改状态栏的方法
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillDisappear:(BOOL)animated {
    self.tabBarController.tabBar.hidden = NO;
    //触发JS事件
    [self injectJSToWebview:self.webView andJSFileName:@"SamaPageHide"];
    //退出读书页的统计
    [[StatisticsManager instance] endLogPageView:@"readPage"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
//     Dispose of any resources that can be recreated.
}

#pragma mark update webView
- (BOOL)updateWebView {
    // 在加载loadRuquest之前设置userAgent
    LogInfo(@"self.webUrl ===== %@",self.webUrl);
    NSURL *Url = [NSURL URLWithString:self.webUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:Url];
    self.webView.dataDetectorTypes = UIDataDetectorTypeNone;//禁掉数字自动解析

    [self.webView loadRequest:request];
    return YES;
}




#pragma mark init Web view

- (BOOL)initWebView {
    //    self.webView.delegate = self.javascriptBridge;
    
    // goback()
    [self.javascriptBridge registerHandler:@"goBack" handler:^(id data, WVJBResponseCallback responseCallback) {
        LogDebug(@"SecondReuseViewController::goBack() called: %@", data);
        
        //
        NSString *backInfo = data;
        SBJsonParser *parse = [[SBJsonParser alloc] init];
        NSDictionary *dic = [parse objectWithString:backInfo];
        if (dic == nil) {
            LogInfo(@"SecondReuseViewController::goBack() goback info is nil");
        }
        //
        [self goBack:dic];

    }];
    //shareApp
    [self.javascriptBridge registerHandler:@"shareApp" handler:^(id data, WVJBResponseCallback responseCallback) {
        LogDebug(@"SecondReuseViewController::share() called: %@", data);
        NSString *shareContentStr = data;
        //parse
        SBJsonParser *parse = [[SBJsonParser alloc] init];
        NSDictionary *shareDic = [parse objectWithString:shareContentStr];
        //share
        [self share:shareDic];
    }];
    
    // playVideo()
    [self.javascriptBridge registerHandler:@"playVideo" handler:^(id dataId, WVJBResponseCallback responseCallback) {
        LogDebug(@"SecondReuseViewController::playVideo() called: %@", dataId);
        
        NSString *urlStr = (NSString *)dataId;
        [self playVideo:urlStr];
    }];
    
    //change Background
    [self.javascriptBridge registerHandler:@"setStatusBarBackground" handler:^(id data, WVJBResponseCallback responseCallback) {
        [self changeBackgourndColorWithColor:data];
    }];
    
    
    //js要求调到新的页面时，调到这个里面：
    //getData      ********     *********
    [self.javascriptBridge registerHandler:@"getData" handler:^(id data,WVJBResponseCallback responseCallback){
        LogDebug(@"SecondReuseViewController::getData() called: %@", data);
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *dataDic = [parser objectWithString:data];
        NSString *dataId = [dataDic objectForKey:@"book_id"];
        NSString *queryId = [dataDic objectForKey:@"query_id"];
        if (responseCallback != nil) {
            NSArray *dataArray = [[KnowledgeManager instance] getLocalDataWithDataId:dataId andQueryId:queryId andIndexFilename:nil];
            NSString *data = nil;
            for (NSString *dataStr in dataArray) {
                if (dataStr == nil || dataStr.length <= 0) {
                    continue;
                }
                
                data = dataStr;
                break;
            }
            responseCallback(data);
        }
    }];
    
    
    
    //renderPage   *******       ********
    [self.javascriptBridge registerHandler:@"renderPage" handler:^(id data,WVJBResponseCallback responseCallback){
        LogDebug(@"SecondReuseViewController::renderPage() called: %@", data);
        SBJsonParser *parse = [[SBJsonParser alloc] init];
        NSDictionary *dic = [parse objectWithString:data];
        [self showPageWithDictionary:dic];
        
    }];
    //getCurStudyType
    [self.javascriptBridge registerHandler:@"getCurStudyType" handler:^(id data ,WVJBResponseCallback responseCallback){
        //在nsuserDefault中设置一个curStudyType字段，用来存储当前用户的学习状态
        LogDebug(@"SecondReuseViewController::getCurStudyType() called: %@", data);
        if (responseCallback != nil) {
            NSString *data =nil;
            NSString *curStudyType = [NSUserDefaultUtil getCurStudyType];
            if (curStudyType != nil && curStudyType.length > 0) {
                data = curStudyType;
                
                responseCallback(data);
            }
        }
        
    }];
    
    
    
    
    
    //************* 书签的接口 **************
    
    //addBookmark
    [self.javascriptBridge registerHandler:@"addBookmark" handler:^(id data ,WVJBResponseCallback responseCallback){
        NSString *bookMarkInfoStr = data;
        if (bookMarkInfoStr == nil || bookMarkInfoStr.length <= 0) {
            LogError(@"SecondReuseViewController - addBookmark:failed to add booKMark because of data from JS is nil");
            return;
        }
        SBJsonParser *parse = [[SBJsonParser alloc] init];
        NSDictionary *bookMarkMetaDic = [parse objectWithString:bookMarkInfoStr];
        if (bookMarkMetaDic == nil) {
            LogError(@"SecondReuseViewController - addBookmark:SBJson parse JS's string error");
            return;
        }
        BOOL ret = NO;
        NSString *UUID = [NSString stringWithFormat:@"%@", [UUIDUtil getUUID]];
        {
            //转化成BookMarkMeta对象
            
            BookMarkMeta *bookMarkMeta = [[BookMarkMeta alloc] init];
            bookMarkMeta.bookId = [bookMarkMetaDic objectForKey:@"book_id"];
            //            bookMarkMeta.bookMarkId = [bookMarkMetaDic objectForKey:@"bookmark_id"];
            bookMarkMeta.bookMarkName = [bookMarkMetaDic objectForKey:@"bookmark_name"];
            bookMarkMeta.bookMarkContent = [bookMarkMetaDic objectForKey:@"bookmark_content"];
            bookMarkMeta.bookMarkType = [bookMarkMetaDic objectForKey:@"type"];
            bookMarkMeta.targetId = [bookMarkMetaDic objectForKey:@"target_id"];
            bookMarkMeta.bookMarkId = UUID;//bookMarkId 设置成为UUID
            
            //保存
            UserRecordDataManager *manager = [UserRecordDataManager instance];
            ret = [manager saveBookMarkMeta:bookMarkMeta];
        }
        
        if (responseCallback != nil) {
            if (ret) {
                responseCallback(UUID);
            }
            else {
                responseCallback(@"");
            }
        }
        
    }];
    
    //removeBookmark
    [self.javascriptBridge registerHandler:@"removeBookmark" handler:^(id data ,WVJBResponseCallback responseCallback){
        NSString *bookMarkInfoStr = data;
        if (bookMarkInfoStr == nil) {
            LogError(@"SecondReuseViewController - removeBookmark: remove booKMark failed because of data from JS is nil");
            return;
        }
        //解析
        SBJsonParser *parse = [[SBJsonParser alloc] init];
        NSDictionary *dic = [parse objectWithString:bookMarkInfoStr];
        if (dic == nil) {
            LogError(@"SecondReuseViewController - removeBookmark: parse Error");
            return;
        }
        UserRecordDataManager *manager = [UserRecordDataManager instance];
        BOOL ret = [manager deleteBookMarkMetaWithUpdateInfoDic:dic];
        if (responseCallback != nil) {
            if (ret) {
                responseCallback(@"1");
            }
            else {
                responseCallback(@"0");
            }
        }
        
        
    }];
    
    //updateBookmark
    [self.javascriptBridge registerHandler:@"updateBookmark" handler:^(id data ,WVJBResponseCallback responseCallback){
        //获取字符串并解析
        NSString *updateInfoStr = data;
        if (updateInfoStr == nil) {
            LogError(@"SecondReuseViewController - updateBookmark: update booKMark failed because of data from JS is nil");
            return;
        }
        SBJsonParser *parse = [[SBJsonParser alloc] init];
        NSDictionary *dic = [parse objectWithString:updateInfoStr];
        if (dic == nil) {
            LogError(@"SecondReuseViewController - updateBookmark: parse error");
            return;
        }
        NSString *bookMarkId = [dic objectForKey:@"bookmark_id"];
        //update
        UserRecordDataManager *manager = [UserRecordDataManager instance];
        BOOL ret = [manager updateBookMarkMeta:dic];
        if (responseCallback != nil) {
            if (ret) {
                responseCallback(bookMarkId);
            }
            else {
                responseCallback(@"");//失败返回空字符串
            }
        }
        
        
    }];
    
    
    //getBookmarkList
    [self.javascriptBridge registerHandler:@"getBookmarkList" handler:^(id data ,WVJBResponseCallback responseCallback){
        
        NSString *infoStr = data;
        if (infoStr == nil || infoStr.length <= 0) {
            LogError (@"SecondReuseViewController - getBookmarkList:get book mark list failed because data is nil ");
            return ;
        }
        SBJsonParser *parse = [[SBJsonParser alloc] init];
        NSDictionary *dic = [parse objectWithString:infoStr];
        if(dic == nil) {
            LogError(@"SecondReuseViewController - getBookmarkList:parse error");
            return;
        }
        //获取相应的参数
        NSString *bookId = [dic objectForKey:@"book_id"];//这三个参数都有可能为空
        NSString *bookMarkType = [dic objectForKey:@"type"];
        NSString *targetId = [dic objectForKey:@"target_id"];
        //获取数据
        UserRecordDataManager *manager = [UserRecordDataManager instance];
        SBJsonWriter *writer = [[SBJsonWriter alloc] init];
        if (bookId == nil || bookId.length <= 0) {//bookId为空时
            
            NSArray  *array = [manager getAllBookMark];
            
            if (array == nil || array.count <= 0) { //从数据库中取得的数组为空
                if (responseCallback != nil) {
                    NSMutableArray *mutableArr = [NSMutableArray array];
                    NSString *string = [writer stringWithObject:mutableArr];
                    responseCallback(string);
                }
            }
            else {//从数据库中取得的数组不为空
                if (responseCallback != nil) {
                    NSString *string = [writer stringWithObject:array];
                    responseCallback(string);
                }
            }
            
        }
        else { //bookId不为空时
            NSArray *array = [manager getBookMarkListWithBookId:bookId andBookType:bookMarkType andQueryId:targetId];
            
            if (array == nil || array.count <= 0) {
                //实例化之后的数组为：[]
                NSMutableArray *resultArr = [NSMutableArray array];
                if (responseCallback != nil) {
                    NSString *string = [writer stringWithObject:resultArr];
                    responseCallback(string);
                }
                
            }
            
            else {//从数据库中取得的bookMarkList不为空，返回数组
                if (responseCallback != nil) {
                    NSString *string = [writer stringWithObject:array];
                    responseCallback(string);
                }
            }
            
            
        }
        
        
        
    }];

    
    //****************************收藏的接口************************
    //addCollection
    [self.javascriptBridge registerHandler:@"addCollection" handler:^(id data ,WVJBResponseCallback responseCallback){
        NSString *collectInfoStr = data;
        if (collectInfoStr == nil || collectInfoStr.length <= 0) {
            LogError(@"[SecondReuseViewController - removeBookmark]:addCollection failed because of info from Js is nil");
            return;
        }
        //解析
        SBJsonParser *parse = [[SBJsonParser alloc] init];
        NSDictionary *infoDic = [parse objectWithString:collectInfoStr];
        BOOL isSuccess = NO;
        CollectionMeta *collectionMeta = [[CollectionMeta alloc] init];
        UserRecordDataManager *userRecordManager = [UserRecordDataManager instance];
        NSString *UUID = [NSString stringWithFormat:@"%@", [UUIDUtil getUUID]];
        {
            collectionMeta.bookId = [infoDic objectForKey:@"book_id"];
            collectionMeta.contentQueryId = [infoDic objectForKey:@"content_query_id"];
            collectionMeta.collectionType = [infoDic objectForKey:@"type"];
            collectionMeta.content = [infoDic objectForKey:@"content"];
            collectionMeta.collectionId = UUID;
            isSuccess = [userRecordManager saveCollectionMeta:collectionMeta];
        }
        //
        if (responseCallback != nil) {
            if (isSuccess) {
                responseCallback(UUID);
            }
            else {
                responseCallback(@"0");
            }
        }
        
        
    }];
    
    //getCollectionList
    [self.javascriptBridge registerHandler:@"getCollectionList" handler:^(id data ,WVJBResponseCallback responseCallback){
        //
        NSString *infoDicStr = data;
        if (infoDicStr == nil || infoDicStr.length <= 0) {
            LogError(@"SecondReuseViewController - getCollectionList : getCollectionList failed because of data from JS is nil");
        }
        
        UserRecordDataManager *userRecordManager = [UserRecordDataManager instance];
        SBJsonParser *parse = [[SBJsonParser alloc] init];
        NSDictionary *infoDic = [parse objectWithString:infoDicStr];
        NSString *bookId = [infoDic objectForKey:@"book_id"];
        SBJsonWriter *writer = [[SBJsonWriter alloc] init];
        if (responseCallback != nil) {
            if (bookId == nil || bookId.length <= 0 ) {
                NSArray *collectionLists = [userRecordManager getAllCollectionList];
                if (collectionLists == nil || collectionLists.count <= 0) {
                    responseCallback(@"[]");//获取到的数组为空，则返回空数组
                }
                else {//获取到的数组非空
                    NSString *collectionStr = [writer stringWithObject:collectionLists];
                    responseCallback(collectionStr);
                }
                
            }
            else {//bookId不为空
                NSArray *collectionListArr = [userRecordManager getCollectionListWithInfoDic:infoDic];
                if (collectionListArr == nil || collectionListArr.count <= 0) {
                    responseCallback(@"[]");//获取到的数组为空，则返回空数组
                }
                else {//获取到的数组非空
                    //                    NSString *collectionStr = [writer stringWithObject:collectionListArr];
                    NSError *error;
                    NSString *returnStr = [writer stringWithObject:collectionListArr error:&error];
                    LogError(@"SecondReuseViewController - getCollectionList : failed because of error :%@",error);
                    responseCallback(returnStr);
                    
                }
                
            }
        }
        
        
    }];
    
    //removeCollectionList
    [self.javascriptBridge registerHandler:@"removeCollectionList" handler:^(id data ,WVJBResponseCallback responseCallback){
        //
        NSString *infoDicStr = data;
        if (infoDicStr == nil || infoDicStr.length <= 0 ) {
            LogError(@"SecondReuseViewController - removeCollectionList : remove collection meta failed because data from is nil");
            //            return;
        }
        //解析
        SBJsonParser *parse = [[SBJsonParser alloc] init];
        NSDictionary *infoDic = [parse objectWithString:infoDicStr];
        //删除“收藏”
        UserRecordDataManager *userRecordManager = [UserRecordDataManager instance];
        BOOL ret = [userRecordManager deleteCollectionMetaWithInfoDic:infoDic];
        if (responseCallback != nil) {
            if (ret) {
                responseCallback(@"1");//成功
            }
            else {
                responseCallback(@"0");//失败
            }
        }

        
    }];

    //************ 扫一扫接口 ***********
    //startQRCodeScan
    [self.javascriptBridge registerHandler:@"startQRCodeScan" handler:^(id data ,WVJBResponseCallback responseCallback){
        NSString *infoDicStr = data;
        if (infoDicStr == nil || infoDicStr.length <= 0) {
            LogWarn(@"[FirstReuseViewController -  startQrcodeScan]: failed go to scan COntroller because of data from Js is nil ");
            return;
        }
        SBJsonParser *parse = [[SBJsonParser alloc] init];
        NSDictionary *dic = [parse objectWithString:infoDicStr];
        //
        [self goScanViewController:dic];
        
        
    }];
    
    //************ 用户反馈 *************
    //showAppPageByAction
    [self.javascriptBridge registerHandler:@"showAppPageByAction" handler:^(id data, WVJBResponseCallback responseCallback) {
        //
        NSString *actionStr = data;
        SBJsonParser *parse = [[SBJsonParser alloc] init];
        NSDictionary *dic = [parse objectWithString:actionStr];
        //根据Js传的参数来决定是否需要开新的WebView
        [self showAppPageByaction:dic];
    }];
    
    //showURL 打开在线网页
    [self.javascriptBridge registerHandler:@"showURL" handler:^(id data, WVJBResponseCallback responseCallback) {
        //
        NSString *dataStr = data;
        SBJsonParser *parse = [[SBJsonParser alloc] init];
        NSDictionary *dic = [parse objectWithString:dataStr];
        self.needRefresh = [dic objectForKey:@"need_refresh"];//记录当前这个页面再次出现时是否需要刷新
        if ([[dic objectForKey:@"target"] isEqualToString:@"activity"]) {
            //新开controller 加载url
            [self showSafeURL:[dic objectForKey:@"url"] withAnimation:[dic objectForKey:@"open_animate"]];
        }
        else
        {
            NSString *urlStr = [dic objectForKey:@"url"];
            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
        }
        
    }];
    
    
    
    
    return YES;
}


#pragma mark js -- native interface method

//1 shareApp
- (void)share:(NSDictionary *)shareDic {
    
    
    /* 2.0
     title          标题
     content        内容
     image_url      小图片url
     target_url     目标页面url
     */
    //title
    NSString *titleAll=[shareDic objectForKey:@"title"];
    //分享链接
    NSString *callBackUrl=[shareDic objectForKey:@"target_url"];
    //    NSURL *weburl=[NSURL URLWithString:urlString];
    //分享的图片链接
    NSString *imageString=[shareDic objectForKey:@"img_url"];
    //是否截屏
    //    BOOL shouldScreen_shot=(BOOL)[shareDic objectForKey:@"screen_shot"];
    //微信使用的url
    NSString *weixinImageUrl=[shareDic objectForKey:@"image_url"];
    //分享内容
    NSString *shareString=[shareDic objectForKey:@"content"];
    
    
    /*
     //(1)使用ui，分享url定义的图片
     [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeImage url:imageString];
     //(2)使用ui,分享截屏图片
     //    UIImage *image = [[UMSocialScreenShoterDefault screenShoter] getScreenShot];
     //不同的平台分享不同的内容
     //新浪微博平台
     [UMSocialData defaultData].extConfig.sinaData.shareText = @"分享到新浪微博内容";
     //腾讯
     [UMSocialData defaultData].extConfig.tencentData.shareImage = [UIImage imageNamed:@"meinv.jpg"]; //分享到腾讯微博图片
     */
    
    /*1.0 used share scene
     //1、分享到QQ
     [UMSocialData defaultData].extConfig.qqData.shareText=shareString;
     //分享到QQ的title
     [UMSocialData defaultData].extConfig.qqData.title=titleAll;
     //分享到QQ的image
     [[UMSocialData defaultData].extConfig.qqData.urlResource setResourceType:UMSocialUrlResourceTypeImage url:weixinImageUrl];
     //点击分享的内容跳转到的网站
     [UMSocialData defaultData].extConfig.qqData.url = callBackUrl;
     
     
     //2、分享到qq空间的图片
     [[UMSocialData defaultData].extConfig.qzoneData.urlResource setResourceType:UMSocialUrlResourceTypeImage url:weixinImageUrl];
     //分享qq空间的title
     [UMSocialData defaultData].extConfig.qzoneData.title = titleAll;
     //分享qq空间的内容
     [UMSocialData defaultData].extConfig.qzoneData.shareText=shareString;
     //回调的url
     [UMSocialData defaultData].extConfig.qzoneData.url = callBackUrl;
     
     
     //3、设置微信好友分享url图片
     [[UMSocialData defaultData].extConfig.wechatSessionData.urlResource setResourceType:UMSocialUrlResourceTypeImage url:weixinImageUrl];
     //设置微信的分享文字
     [UMSocialData defaultData].extConfig.wechatSessionData.shareText=shareString;
     //设置微信的title
     [UMSocialData defaultData].extConfig.wechatSessionData.title=titleAll;
     //回调的url
     [UMSocialData defaultData].extConfig.wechatSessionData.url=callBackUrl;
     */
    
    
    //2.0 share to wechatTimeline only
    //4、设置微信朋友圈的分享的URL图片
    [[UMSocialData defaultData].extConfig.wechatTimelineData.urlResource setResourceType:UMSocialUrlResourceTypeImage url:weixinImageUrl];
    //设置微信朋友圈的分享文字
    [UMSocialData defaultData].extConfig.wechatTimelineData.shareText=shareString;
    //
    [UMSocialData defaultData].extConfig.wechatTimelineData.url=callBackUrl;
    
    [UMSocialSnsService presentSnsIconSheetView:self appKey:@"543dea72fd98c5fc98004e08" shareText:shareString shareImage:nil shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatTimeline,nil] delegate:nil];//UMShareToWechatSession
}


//2 播放视频
- (void)playVideo:(NSString *)urlStr {
    if (urlStr == nil || urlStr.length <= 0) {
        return;
    }
    
    NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    if (url == nil) {
        return;
    }
    
    // 不要加
    //    [CustomURLProtocol injectURL:urlStr cookie:@"User-Agent:ZAXUE_IOS_POLITICS_APP"];
    
    // 播放
    //    MPMoviePlayerViewController *playerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    
    DirectionMPMoviePlayerViewController *playerViewController = [[DirectionMPMoviePlayerViewController alloc] initWithContentURL:url];
    playerViewController.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    playerViewController.view.frame = self.view.frame; // 全屏
    playerViewController.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallback:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:[playerViewController moviePlayer]];
    
    //---play movie---
    [[playerViewController moviePlayer] play];
    
    // 注: 用present会导致playerViewController中设置的transform不生效, 故转为push
    //    [self presentMoviePlayerViewControllerAnimated:playerViewController];
    [self.navigationController pushViewController:playerViewController animated:YES];
}

- (void)movieFinishedCallback:(NSNotification*) aNotification {
    MPMoviePlayerController *playerViewController = [aNotification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:playerViewController];
    [playerViewController stop];
    
    //    [self dismissMoviePlayerViewControllerAnimated];
    
    [self.navigationController popViewControllerAnimated:YES];
}

// 3 修改背景的颜色
-(void)changeBackgourndColorWithColor:(NSString *)colorString
{
    self.view.backgroundColor = [UIColor colorWithHexString:colorString alpha:1];
}

// 4 打开指定的页面
//2.0中跳转到指定页面
- (BOOL)showPageWithDictionary:(NSDictionary *)dic {
    NSString *target = dic[@"target"];
    
    //是否需要刷新
    NSString *needRefreshStr = dic[@"need_refresh"];
    self.needRefresh = needRefreshStr;
    //是否需要横屏
    NSString *orientation = dic[@"orientation"];
    
    if ([target isEqualToString:@"self"]) {
        
        NSString *book_id = dic[@"book_id"];
        
        NSString *htmlFilePath = [[KnowledgeManager instance] getPagePath:book_id];
        if (htmlFilePath == nil || htmlFilePath.length <= 0) {
            return NO;
        }
        NSString *page_type = dic[@"page_type"];
        
        // 加载指定的html文件
        NSURL *url = [[NSURL alloc] initFileURLWithPath:[NSString stringWithFormat:@"%@/%@/%@", htmlFilePath,page_type, @".html"]];
        
        NSString *urlStrWithParams = nil;
        //        NSString *args = dic[@"getArgs"];
        NSString *args = dic[@"get_args"];
        
        if (args != nil && args.length > 0) {
            urlStrWithParams = [NSString stringWithFormat:@"%@?%@", [url absoluteString], args];
        }
        else {
            urlStrWithParams = [NSString stringWithFormat:@"%@", [url absoluteString]];
        }
        
        NSURL *urlWithParams = [[NSURL alloc] initWithString:urlStrWithParams];
        
        [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:urlWithParams]];
        //在当前页面渲染时，若是需要横屏，则横屏
        if ([orientation isEqualToString:@"landscape"]) {
            CGAffineTransform transform = CGAffineTransformIdentity;
            transform = CGAffineTransformRotate(transform, M_PI/2);
            self.view.transform = transform;
        }
        return YES;
    }
    else
    {
        if ([target isEqualToString:@"activity"]) {
            NSString *book_id = dic[@"book_id"];
            
            NSString *htmlFilePath = [[KnowledgeManager instance] getPagePath:book_id];
            if (htmlFilePath == nil || htmlFilePath.length <= 0) {
                return NO;
            }
            NSString *page_type = dic[@"page_type"];
            
            // 加载指定的html文件
            NSString *urlStr = [NSString stringWithFormat:@"%@/%@/%@%@", htmlFilePath,@"render",page_type, @".html"];
            
            NSString *urlStrWithParams = nil;
            NSString *args = dic[@"get_args"];
            if (args != nil && args.length > 0) {
                urlStrWithParams = [NSString stringWithFormat:@"%@%@", urlStr, args];
            }
            else {
                urlStrWithParams = [NSString stringWithFormat:@"%@", urlStr];
                
            }
            //获取渲染页面时的值
            NSString *animation = [dic objectForKey:@"open_animate"];
            //打开新的controller
            //打开新的controller
            return [self readBookWithSafeUrl:urlStrWithParams andAnimation:animation andOrientation:orientation];
            
        }
    }
    
    return YES;
    
}

- (BOOL)readBookWithSafeUrl:(NSString *)urlStr andAnimation:(NSString *)openAnimation andOrientation:(NSString *)orientation {
    
    FirstReuseViewController *first = [[FirstReuseViewController alloc] init];
    if (openAnimation != nil && openAnimation.length > 0) {
        //自定义动画
        CATransition *animation = [self customAnimation:openAnimation];
        first.webUrl = urlStr;
        //判断是否需要横屏，把JS传来的参数传到下一个页面上
        first.needOrientation = orientation;
        [self.navigationController.view.layer addAnimation:animation forKey:nil];
        [self.navigationController pushViewController:first animated:NO];
    }
    else {
        first.webUrl = urlStr;
        //判断是否需要横屏，把JS传来的参数传到下一个页面上
        first.needOrientation = orientation;
        [self.navigationController pushViewController:first animated:YES];
        
    }
    
    return YES;
    
}







//设置自定义的动画效果
- (CATransition *)customAnimation:(NSString *)openAnimation {
    
    //根据JS传的参数来设置动画的切入，出方向。
    CATransition *animation = [CATransition animation];
    [animation setDuration:1];
    [animation setType: kCATransitionPush];//设置为推入效果
    if ([openAnimation isEqualToString:@"pull_left_out"] || [openAnimation isEqualToString:@"push_right_in"]) {
        [animation setSubtype: kCATransitionFromRight];//设置方向
        
    }
    else if ([openAnimation isEqualToString:@"pull_right_out"]|| [openAnimation isEqualToString:@"push_left_in"]) {
        [animation setSubtype: kCATransitionFromLeft];//设置方向
        
    }
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    return animation;
}



#pragma mark goBack 接口调用的方法

- (void)goBack:(NSDictionary *)backDictionary {
    
    //判断回去的方式
    NSString *closeAnimation = [backDictionary objectForKey:@"close_animate"];
    if (closeAnimation == nil || closeAnimation.length <= 0 ) {//返回动画要求为空
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {//返回动画不为空
        CATransition *animation = [self customAnimation:closeAnimation];
        [self.navigationController.view.layer addAnimation:animation forKey:nil];
        [self.navigationController popViewControllerAnimated:NO];
    }
    
    
}


#pragma mark goScanViewController
- (void)goScanViewController:(NSDictionary *)dic {
    NSString *openAnimation = [dic objectForKey:@"open_animate"];
    ScanQRCodeViewController *scanQrcodeViewController = [[ScanQRCodeViewController alloc] init];
    if (openAnimation == nil || openAnimation.length <= 0 ) {//页面上不指定入场动画
        [self.navigationController pushViewController:scanQrcodeViewController animated:YES];
        
    }
    else {//入场动画不为空
        CATransition *animation = [self customAnimation:openAnimation];
        [self.navigationController.view.layer addAnimation:animation forKey:nil];
        [self.navigationController pushViewController:scanQrcodeViewController animated:NO];
    }
    
}







- (BOOL)showSafeURL:(NSString *)urlStr {
    
    FirstReuseViewController *first = [[FirstReuseViewController alloc] init];
    first.webUrl = urlStr;
    [self.navigationController pushViewController:first animated:YES];
    return YES;
}




//
#pragma mark - web view delegate methods

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (request) {
        LogDebug(@"[MatchViewConroller] Web request: UA: %@", [request valueForHTTPHeaderField:@"User-Agent"]);
    }
    
    //    [self injectJSToWebView:webView];
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self injectJSToWebView:webView];
}

#pragma mark - js injection
- (void)injectJSToWebView:(UIWebView *)webView {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"webview-js-bridge" ofType:@"js"];
    NSString *jsString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    [webView stringByEvaluatingJavaScriptFromString:jsString];
}

//给JS的响应事件，分别在viewWillAppear、viewWillDisAppear时触发。
- (void)injectJSToWebview:(UIWebView *)webView andJSFileName:(NSString *)JSfileName {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:JSfileName ofType:@"js"];
    NSString *jsString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    [webView stringByEvaluatingJavaScriptFromString:jsString];
}

//用户反馈用到的方法
#pragma mark showAppPageByAction methods
- (void)showAppPageByaction:(NSDictionary *)dic {
    NSString *target = [dic objectForKey:@"target"];
    NSString *action = [dic objectForKey:@"action"];
    NSString *urlStr = [PersionalCenterUrlConfig getUrlWithAction:action];
    if ([urlStr isEqualToString:@"feedback"]) {
        //进入到用户反馈页
        [self showNativeFeedbackWithAppkey:[[StatisticsManager instance] appKeyFromUmeng]];
        self.tabBarController.tabBar.hidden = YES;
        return;
    }
    if (urlStr == nil) {
        LogWarn(@"[RenderKnowledgeViewController - showAppPageByaction]:go to target web failed , urlStr is equal to nil");
        return;
    }
    if ([target isEqualToString:@"activity"]) {
        [self showSafeURL:urlStr withAnimation:nil];//在这个页面这些都不会被调用。
    }
    else {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
    }
}

#pragma mark - UMdelegate
- (void)showNativeFeedbackWithAppkey:(NSString *)appkey {
    UMFeedbackViewController *feedbackViewController = [[UMFeedbackViewController alloc] initWithNibName:@"UMFeedbackViewController" bundle:nil];
    feedbackViewController.appkey = appkey;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController pushViewController:feedbackViewController animated:YES];
}



/*在线网页接口showUrl 调用的接口方法说明：
 *在看书的controller中需要打开在线网页时，跳到复用的SecondRenderKnowledgeViewController中
 *FirstReuseViewController、SecondReuseViewController。看书过程之间的复用，跳转在两个controller中进行
 *RenderKnowledgeViewController、SecondRenderKnowledgeViewController。除看书的内容外，所有的页面跳转，复用都在这两个controller中进行。
 */

- (BOOL)showSafeURL:(NSString *)urlStr withAnimation:(NSString *)openAnimation {
    
    SecondRenderKnowledgeViewController *secondRender = [[SecondRenderKnowledgeViewController alloc] init];
    secondRender.webUrl = urlStr;
    //    secondRender.flag = self.flag;//每次都刷新，所以暂时在看书用的controller中不需要flag
    [self.navigationController pushViewController:secondRender animated:YES];
    
    return YES;
}



@end
