//
//  WebViewBridgeRegisterUtil.m
//  ebooksystem
//
//  Created by wanghaoyu on 15/2/11.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import "WebViewBridgeRegisterUtil.h"

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
#import "SecondReuseViewController.h"

#import "BookMarkMeta.h"
#import "UUIDUtil.h"
#import "UserRecordDataManager.h"

#import "CollectionMeta.h"
#import "ScanQRCodeViewController.h"

#import "UMFeedbackViewController.h"
#import "StatisticsManager.h"
#import "PersionalCenterUrlConfig.h"
#import "SecondRenderKnowledgeViewController.h"
#import "discoveryModel.h"
#import "UserInfo.h"
#import "UserManager.h"
#import "UpdateManager.h"
#import "AboutUsViewController.h"

@interface WebViewBridgeRegisterUtil ()

#pragma mark - properties
// bridge between webview and js
@property (nonatomic, strong) WebViewJavascriptBridge *javascriptBridge;

@end



@implementation WebViewBridgeRegisterUtil

/*
    做两件事情：
    （1）把webview传进来，bridge创建需要注入的js和webview
    （2）实例化bridge时，webviewDelegate的参数需要是controller。具体原因还需要再调研
 */

// bridge between webview and js
-(WebViewJavascriptBridge *)javascriptBridge {
    if (_javascriptBridge == nil) {
        _javascriptBridge = [WebViewJavascriptBridge bridgeForWebView:self.webView webViewDelegate:self.controller handler:^(id data, WVJBResponseCallback responseCallback) {
            LogDebug(@"Received message from javascript: %@", data);
            responseCallback(@"'response data from obj-c'");
        }];
        [self initWebView];
    }
    return _javascriptBridge;
}

- (void)initWebView {
    
    // goback()
    [self.javascriptBridge registerHandler:@"goBack" handler:^(id data, WVJBResponseCallback responseCallback) {
        LogDebug(@"WebViewBridgeRegisterUtil::goBack() called: %@", data);
        //
        NSString *backInfo = data;
        SBJsonParser *parse = [[SBJsonParser alloc] init];
        NSDictionary *dic = [parse objectWithString:backInfo];
        if (dic == nil) {
            LogInfo(@"WebViewBridgeRegisterUtil::goBack() goback info is nil");
        }
        //
        [self goBack:dic];
        
    }];
    
    
    //getData
    [self.javascriptBridge registerHandler:@"getData" handler:^(id data,WVJBResponseCallback responseCallback){
        LogDebug(@"WebViewBridgeRegisterUtil::getData() called: %@", data);
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
    //renderPage
    [self.javascriptBridge registerHandler:@"renderPage" handler:^(id data,WVJBResponseCallback responseCallback){
        LogDebug(@"WebViewBridgeRegisterUtil::renderPage() called: %@", data);
        SBJsonParser *parse = [[SBJsonParser alloc] init];
        NSDictionary *dic = [parse objectWithString:data];
        [self showPageWithDictionary:dic];
        
    }];
    
    //************* 书签的接口 **************
    
    //addBookmark
    [self.javascriptBridge registerHandler:@"addBookmark" handler:^(id data ,WVJBResponseCallback responseCallback){
        NSString *bookMarkInfoStr = data;
        if (bookMarkInfoStr == nil || bookMarkInfoStr.length <= 0) {
            LogError(@"WebViewBridgeRegisterUtil - addBookmark:failed to add booKMark because of data from JS is nil");
            return;
        }
        SBJsonParser *parse = [[SBJsonParser alloc] init];
        NSDictionary *bookMarkMetaDic = [parse objectWithString:bookMarkInfoStr];
        if (bookMarkMetaDic == nil) {
            LogError(@"WebViewBridgeRegisterUtil - addBookmark:SBJson parse JS's string error");
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
            LogError(@"WebViewBridgeRegisterUtil - removeBookmark: remove booKMark failed because of data from JS is nil");
            return;
        }
        //解析
        SBJsonParser *parse = [[SBJsonParser alloc] init];
        NSDictionary *dic = [parse objectWithString:bookMarkInfoStr];
        if (dic == nil) {
            LogError(@"WebViewBridgeRegisterUtil - removeBookmark: parse Error");
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
            LogError(@"WebViewBridgeRegisterUtil - updateBookmark: update booKMark failed because of data from JS is nil");
            return;
        }
        SBJsonParser *parse = [[SBJsonParser alloc] init];
        NSDictionary *dic = [parse objectWithString:updateInfoStr];
        if (dic == nil) {
            LogError(@"WebViewBridgeRegisterUtil - updateBookmark: parse error");
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
            LogError (@"WebViewBridgeRegisterUtil - getBookmarkList:get book mark list failed because data is nil ");
            return ;
        }
        SBJsonParser *parse = [[SBJsonParser alloc] init];
        NSDictionary *dic = [parse objectWithString:infoStr];
        if(dic == nil) {
            LogError(@"WebViewBridgeRegisterUtil - getBookmarkList:parse error");
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
    
    
//   *********** 收藏的接口   *******************
    //addCollection
    [self.javascriptBridge registerHandler:@"addCollection" handler:^(id data ,WVJBResponseCallback responseCallback){
        NSString *collectInfoStr = data;
        if (collectInfoStr == nil || collectInfoStr.length <= 0) {
            LogError(@"[WebViewBridgeRegisterUtil - removeBookmark]:addCollection failed because of info from Js is nil");
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
            LogError(@"WebViewBridgeRegisterUtil - getCollectionList : getCollectionList failed because of data from JS is nil");
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
                    LogError(@"FirstReuseViewController - getCollectionList : failed because of error :%@",error);
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
            LogError(@"WebViewBridgeRegisterUtil - removeCollectionList : remove collection meta failed because data from is nil");
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
            LogWarn(@"[WebViewBridgeRegisterUtil -  startQRCodeScan]: failed go to scan COntroller because of data from Js is nil ");
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
//        self.needRefresh = [dic objectForKey:@"need_refresh"];//记录当前这个页面再次出现时是否需要刷新
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
    
    
    //  ******* 播放视频的接口 *******
    // playVideo()
    [self.javascriptBridge registerHandler:@"playVideo" handler:^(id dataId, WVJBResponseCallback responseCallback) {
        LogDebug(@"WebViewBridgeRegisterUtil::playVideo() called: %@", dataId);
        
        NSString *urlStr = (NSString *)dataId;
        [self playVideo:urlStr];
    }];
    // ********* 分享 *******
    //shareApp
    [self.javascriptBridge registerHandler:@"shareApp" handler:^(id data, WVJBResponseCallback responseCallback) {
        LogDebug(@"WebViewBridgeRegisterUtil::share() called: %@", data);
        NSString *shareContentStr = data;
        //parse
        SBJsonParser *parse = [[SBJsonParser alloc] init];
        NSDictionary *shareDic = [parse objectWithString:shareContentStr];
        //share
        [self share:shareDic];
    }];
    //change Background
    [self.javascriptBridge registerHandler:@"setStatusBarBackground" handler:^(id data, WVJBResponseCallback responseCallback) {
        [self changeBackgourndColorWithColor:data];
    }];
    
    // ******* set && get current user study type **********
    //getCurStudyType
    [self.javascriptBridge registerHandler:@"getCurStudyType" handler:^(id data ,WVJBResponseCallback responseCallback){
        //在nsuserDefault中设置一个curStudyType字段，用来存储当前用户的学习状态
        LogDebug(@"WebViewBridgeRegisterUtil::getCurStudyType() called: %@", data);
        if (responseCallback != nil) {
            NSString *data =nil;
            NSString *curStudyType = [NSUserDefaultUtil getCurStudyType];
            if (curStudyType != nil && curStudyType.length > 0) {
                data = curStudyType;
                
                responseCallback(data);
            }
        }
        
    }];
    
    //setCurStudyType
    [self.javascriptBridge registerHandler:@"setCurStudyType" handler:^(id data,WVJBResponseCallback responseCallback){
        LogDebug(@"WebViewBridgeRegisterUtil::setCurStudyType() called: %@", data);
        NSString *curStudyType = data;
        if (curStudyType != nil && curStudyType.length > 0) {
            BOOL isSuccess = [NSUserDefaultUtil setCurStudyTypeWithType:curStudyType];
            if (isSuccess) {
                NSString *data = @"1";
                responseCallback(data);
            }
            else {
                NSString *data = @"0";
                responseCallback(data);
            }
            
        }
        else {
            LogError(@"WebViewBridgeRegisterUtil::setCurStudyType() failed because of curStudyType is equal to nil");
            NSString *data = @"0";
            responseCallback(data);//失败返回0；
        }
        
    }];
    
    
    
    //************ get book's all status **********
    //getBookList
    [self.javascriptBridge registerHandler:@"getBookList" handler:^(id data,WVJBResponseCallback responseCallback){
        LogDebug(@"WebViewBridgeRegisterUtil::getBookList() called: %@", data);
        NSString *book_category = data;//值：0，1
        //根据book_category遍历数据库，将数据拼成json格式返回给JS。（具体操作：1、就是根据book_category做遍历数据库的操作 2、book_status ：下载过程中用的download_Status字段（下载成功，下载失败，下载中）也是修改这个字段。）
        
        NSMutableArray *arr = [NSMutableArray array];
        NSArray *bookListArr = [[KnowledgeManager instance] getBookList:book_category];
        if (bookListArr != nil || bookListArr.count > 0) {
            //
            arr = (NSMutableArray *)bookListArr;
        }
        SBJsonWriter *writer = [[SBJsonWriter alloc] init];
        NSString *string = [writer stringWithObject:arr];
        NSLog(@"%@",string);
        
        if (responseCallback != nil) {
            responseCallback(string);//getBookList和queryBookStatus若是数组为空，都必须返回“[]”,格式字符串否则解析JS失败。
        }
        
        
        
    }];
    
    //checkUpdate
    [self.javascriptBridge registerHandler:@"checkUpdate" handler:^(id data,WVJBResponseCallback responseCallback){
        LogDebug(@"WebViewBridgeRegisterUtil::checkUpdate() called: %@", data);
        NSString *book_category = data;//值：0，1 还需要分类型吗？
        //检查某类书籍是否有更新，需要从数据库中查找（方法：1、获取更新数据的版本文件 2、把是否有更新的信息存储到数据库中，只需要返回给js是否开始检查的通知即可，不需要检查更新的结果给JS）。
        //返回0，1
        BOOL isStart = NO;
        {
            dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[KnowledgeManager instance] getUpdateInfoFileFromServerAndUpdateDataBase];
            });
            isStart = YES;
        }
        if (responseCallback != nil) {
            if (isStart) {
                responseCallback(@"1");
            }
            else {
                responseCallback(@"0");
            }
        }
    }];
    
    //startDownload
    [self.javascriptBridge registerHandler:@"startDownload" handler:^(id data, WVJBResponseCallback responseCallback) {
        LogDebug(@"WebViewBridgeRegisterUtil::startDownload() called: %@", data);
        NSString *book_id = data;
        NSLog(@"调了=====%@",book_id);
        //下载的过程就是只有一步，拿到data_id后直接开始下载。（具体操作：1、根据book_id去下载 2、将下载的进度实时存到数据库中即可，不需要做读取的操作，也不需要将进度返回给JS。只需要告诉JS是否已经开始下载）。
        BOOL isStart = NO;
        {
            dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                BOOL ret = [[KnowledgeManager instance] startDownloadDataManagerWithDataId:book_id];
            });
            isStart = YES;
        }
        if (responseCallback != nil) {
            if (isStart) {
                responseCallback(@"1");
            }
            else {
                responseCallback(@"0");
            }
        }
        
        
    }];
    
   
    //queryBookStatus
    [self.javascriptBridge registerHandler:@"queryBookStatus" handler:^(id data, WVJBResponseCallback responseCallback) {
        LogDebug(@"RenderKnowledgeViewController::queryBookStatus() called: %@", data);
        
        SBJsonParser *parse = [[SBJsonParser alloc] init];
        NSArray *book_ids = [parse objectWithString:data];
        NSLog(@"queryBookStatus 接口的返回值是%@",data);
        //操作：遍历获取到的book_id数组
        //根据book_ids来获取下载进度，需要从数据库中取到，（具体操作：1、根据book_id对数据库做读取操作 2、返回结果是一个json，其中downLoad_status需要返回汉字）。
        NSMutableArray *booksArray = [NSMutableArray array];
        for (NSString *bookId in book_ids) {
            if (bookId ==nil) {
                continue;
            }
            //根据book_id从数据库中取相应的状态
            NSMutableDictionary *dic = [self getDicFormDataBase:bookId];
            if(dic == nil) {
                continue;
            }
            [booksArray addObject:dic];
        }
        //返回的是数组类型的值，即使是空数组也要解析一下
        SBJsonWriter *writer = [[SBJsonWriter alloc] init];
        NSString *jsonStr = [writer stringWithObject:booksArray];
        if (responseCallback != nil) {
            responseCallback(jsonStr);
        }
        
        
        
    }];
    
    // ****** 获取封面图片 *****
    //getCoverSrc
    [self.javascriptBridge registerHandler:@"getCoverSrc" handler:^(id data, WVJBResponseCallback responseCallback) {
        //获取封面
        NSString *book_id = data;
        if (responseCallback != nil) {
            NSString *partialPathInSandBox = [self getCoverImageFilePath:book_id];
            NSString *documentPath = [PathUtil getDocumentsPath];
            NSString *coverImagePathStr = [NSString stringWithFormat:@"%@/%@",documentPath,partialPathInSandBox];
            responseCallback(coverImagePathStr);
        }
        //
    }];
    
    //goDiscoverPage
    [self.javascriptBridge registerHandler:@"goDiscoverPage" handler:^(id data, WVJBResponseCallback responseCallback) {
        //跳转到发现页
        self.tabBarController.selectedIndex = 1;
    }];
    
    /*
    //goUserSettingPage
    [self.javascriptBridge registerHandler:@"goUserSettingPage" handler:^(id data, WVJBResponseCallback responseCallback) {
        //跳转到设置页面
        RenderKnowledgeViewController *render = [[RenderKnowledgeViewController alloc] init];
        NSString *bundlePath = [PathUtil getBundlePath];
        NSString *userCenterUrlStrWithParams = [NSString stringWithFormat:@"%@/%@/%@/%@", bundlePath, @"assets",@"native-html",@"user_center.html"];
        render.webUrl = userCenterUrlStrWithParams;
        [self.navigationController pushViewController:render animated:YES];
        
    }];
     */

    // *******  发现页的接口 ********
    //showURL
    //addToNative
    [self.javascriptBridge registerHandler:@"addToNative" handler:^(id data, WVJBResponseCallback responseCallback) {
        /*
         1先调queryBookStatus接口，检查本地是否有这本书。（若是本地没有该书的记录，返回空数组）
         2若是没有则掉addToNative接口
         */
        NSString *bookID = data;
        //异步请求
        discoveryModel *model = [[discoveryModel alloc] init];
        NSArray *arr = [NSArray arrayWithObjects:bookID, nil];
        BOOL isSuccess =  [model getBookInfoWithDataIds:arr];
        
        if (responseCallback != nil) {
            if (isSuccess) {
                responseCallback(@"1");
            }
            else {
                responseCallback(@"0");
            }
        }
    }];
    
    
    
    // ********** 个人中心页的接口 ****************
    //showAppPageByAction
    [self.javascriptBridge registerHandler:@"showAppPageByAction" handler:^(id data, WVJBResponseCallback responseCallback) {
        //
        NSString *actionStr = data;
        SBJsonParser *parse = [[SBJsonParser alloc] init];
        NSDictionary *dic = [parse objectWithString:actionStr];
        //根据Js传的参数来决定是否需要开新的WebView
        [self showAppPageByaction:dic];
    }];
    
    //setCurUserInfo
    [self.javascriptBridge registerHandler:@"setCurUserInfo" handler:^(id data, WVJBResponseCallback responseCallback) {
        //设置当前用户信息
        NSString *cruUserInfoStr = data;
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *cruUserInfoDic = [parser objectWithString:cruUserInfoStr];
        
        // 1 parse cruUserInfoDic
        UserInfo *userInfo = [[UserInfo alloc] init];
        NSString *userId = [cruUserInfoDic objectForKey:@"user_id"];
        NSString *userName = [cruUserInfoDic objectForKey:@"user_name"];
        NSString *balance = [cruUserInfoDic objectForKey:@"balance"];
        NSString *mobile = [cruUserInfoDic objectForKey:@"mobile"];
        NSString *sessionId = [cruUserInfoDic objectForKey:@"session_id"];
        if (userId == nil || userId.length <= 0) {
            LogError(@"[RenderKnowledgeViewController - setCur]");
        }
        //userId
        userInfo.userId = userId;
        //userName
        if (userName == nil || userName.length <= 0) {
            userInfo.username = @"";
        }
        else {
            userInfo.username = userName;
        }
        //balance
        if (balance == nil || balance.length <= 0) {
            userInfo.balance = @"";
        }
        else {
            userInfo.balance = balance;
        }
        //phoneNumber
        if (mobile == nil || mobile.length <= 0) {
            userInfo.phoneNumber = @"";
        }
        else {
            userInfo.phoneNumber = mobile;
        }
        //sessionId
        if (sessionId == nil || sessionId.length <= 0) {
            userInfo.sessionId = @"";
        }
        else {
            userInfo.sessionId = sessionId;
        }
        //password
        userInfo.password = @"";
        //2 save userInfo
        UserManager *usermanager = [UserManager instance];
        BOOL setSuccess = [usermanager saveUserInfo:userInfo];
        if (setSuccess) {
            responseCallback (@"1");
        }
        else {
            responseCallback (@"0");
        }
        
    }];
    
    //getCurUserInfo
    [self.javascriptBridge registerHandler:@"getCurUserInfo" handler:^(id data, WVJBResponseCallback responseCallback) {
        //默认图片
        NSString *imageUrl = [[[Config instance] drawableConfig] getImageFullPath:@"default.jpg"];
        NSString *imageBundlePath = [[NSBundle mainBundle] bundlePath];
        NSString *fullpath = [NSString stringWithFormat:@"%@/%@",imageBundlePath,imageUrl];
        //其他用户信息
        UserManager *userManager = [UserManager instance];
        UserInfo *userinfo = [userManager getCurUser];
        if (userinfo.userId == nil || userinfo.userId <= 0) {
            if(responseCallback != nil) {
                responseCallback(@"{}");
            }
        }
        else {
            NSString *cruUserName = userinfo.username;
            NSString *cruUserInfoBalance = userinfo.balance;
            NSString *cruUserId = userinfo.userId;
            NSString *cruPhone = userinfo.phoneNumber;
            NSDictionary *userInfoDic = @{@"user_id":cruUserId,@"user_name":cruUserName,@"avatar_src":fullpath,@"balance":cruUserInfoBalance,@"mobile":cruPhone};
            SBJsonWriter *writer = [[SBJsonWriter alloc] init];
            NSString *userInfoStr = [writer stringWithObject:userInfoDic];
            if (responseCallback != nil) {
                responseCallback(userInfoStr);
                
            }
        }
        
    }];
    
    // ********* 设置页面接口 *******
    //voteForZaxue
    [self.javascriptBridge registerHandler:@"voteForZaxue" handler:^(id data, WVJBResponseCallback responseCallback) {
        //appId需要修改 -- App打分
        [self gotoAppStoreWithAppId:@"934792222"];
        
    }];
    //checkAppUpdate
    [self.javascriptBridge registerHandler:@"checkAppUpdate" handler:^(id data, WVJBResponseCallback responseCallback) {
        //检查更新
        UpdateManager *manager = [UpdateManager instance];
        BOOL needUpdate = [manager updateAble];
        if (responseCallback != nil) {
            if (needUpdate == YES) {
                responseCallback(@"1");
            }
            else {
                responseCallback(@"0");
            }
            
        }
    }];
    //showAboutPage
    [self.javascriptBridge registerHandler:@"showAboutPage" handler:^(id data, WVJBResponseCallback responseCallback) {
        //关于页面
        AboutUsViewController *about = [[AboutUsViewController alloc] init];
        [self.navigationController pushViewController:about animated:YES];
        
        
    }];
    //shareApp
    
    
}

#pragma mark goBack 接口调用的方法

- (void)goBack:(NSDictionary *)backDictionary {
    
   //由nav管理的页面之间的跳转只能由对应的NAV来管理,所以解决办法是
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

#pragma mark 设置动画的效果
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


#pragma mark render page method

- (BOOL)showPageWithDictionary:(NSDictionary *)dic {
    NSString *target = dic[@"target"];
    //是否需要刷新
    NSString *needRefreshStr = dic[@"need_refresh"];
//    self.needRefresh = needRefreshStr;//将是否需要刷新存到属性中,现在是强制横屏
//    是否需要横屏
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
            self.mainControllerView.transform = transform;//在这里可以实现横屏
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
            return [self readBookWithSafeUrl:urlStrWithParams andAnimation:animation andOrientation:orientation];
            
        }
    }
    
    return YES;
    
}


- (BOOL)readBookWithSafeUrl:(NSString *)urlStr andAnimation:(NSString *)openAnimation andOrientation:(NSString *)orientation {
    
    SecondReuseViewController *second = [[SecondReuseViewController alloc] init];
    if (openAnimation != nil && openAnimation.length > 0) {
        //自定义动画
        CATransition *animation = [self customAnimation:openAnimation];
        second.webUrl = urlStr;
        //判断是否需要横屏，把JS传来的参数传到下一个页面上
        second.needOrientation = orientation;
        [self.navigationController.view.layer addAnimation:animation forKey:nil];
        [self.navigationController pushViewController:second animated:NO];
    }
    else {
        //判断是否需要横屏，把JS传来的参数传到下一个页面上
        second.needOrientation = orientation;
        second.webUrl = urlStr;
        [self.navigationController pushViewController:second animated:YES];
        
    }
    
    return YES;
    
}

#pragma mark 扫一扫接口中的方法
- (void)goScanViewController:(NSDictionary *)dic {
    NSString *openAnimation = [dic objectForKey:@"open_animate"];
    ScanQRCodeViewController *scanQrcodeViewController = [[ScanQRCodeViewController alloc] init];
    if (openAnimation == nil || openAnimation.length <= 0 ) {//
        [self.navigationController pushViewController:scanQrcodeViewController animated:YES];
        
    }
    else {//开场动画不为空
        CATransition *animation = [self customAnimation:openAnimation];
        [self.navigationController.view.layer addAnimation:animation forKey:nil];
        [self.navigationController pushViewController:scanQrcodeViewController animated:NO];
    }
    
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
        LogWarn(@"[WebViewBridgeRegisterUtil - showAppPageByaction]:go to target web failed , urlStr is equal to nil");
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

//将js抽出来后怎么处理，怎样实现跳到不同的controller中？在线的页面每次都实例化一个secondRender对象
- (BOOL)showSafeURL:(NSString *)urlStr withAnimation:(NSString *)openAnimation {
    
    SecondRenderKnowledgeViewController *secondRender = [[SecondRenderKnowledgeViewController alloc] init];
    secondRender.webUrl = urlStr;
    //    secondRender.flag = self.flag;//每次都刷新，所以暂时在看书用的controller中不需要flag
    [self.navigationController pushViewController:secondRender animated:YES];
    
    return YES;
}


#pragma mark 播放视频的接口
// 播放视频
- (void)playVideo:(NSString *)urlStr {
    if (urlStr == nil || urlStr.length <= 0) {
        return;
    }
    
    NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    if (url == nil) {
        return;
    }
    
    DirectionMPMoviePlayerViewController *playerViewController = [[DirectionMPMoviePlayerViewController alloc] initWithContentURL:url];
    playerViewController.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    playerViewController.view.frame = self.mainControllerView.frame; // 全屏
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

#pragma mark 分享
- (void)share:(NSDictionary *)shareDic {
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
    
    [UMSocialSnsService presentSnsIconSheetView:self.controller appKey:@"543dea72fd98c5fc98004e08" shareText:shareString shareImage:nil shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatTimeline,nil] delegate:nil];//UMShareToWechatSession
}

#pragma mark change back ground
-(void)changeBackgourndColorWithColor:(NSString *)colorString
{
    self.mainControllerView.backgroundColor = [UIColor colorWithHexString:colorString alpha:1];
}

#pragma mark queryBookStatus接口调用的方法
//get dic :{book_id, book_status, book_status_detail}
- (NSMutableDictionary *)getDicFormDataBase:(NSString *)bookId {
    //限制dataType
    NSArray *bookArr = [[KnowledgeMetaManager instance] getKnowledgeMetaWithDataId:bookId andDataType:DATA_TYPE_DATA_SOURCE];
    
    //    NSArray *bookArr = [[KnowledgeMetaManager instance] getKnowledgeMetaWithDataId:bookId];
    
    
    //1 数据库中没有bookId对应的记录，返回nil
    if (bookArr == nil || bookArr.count <= 0) {
        return nil;
    }
    //2 从数据库中查到对应的字段
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for (NSManagedObject *entity in bookArr) {
        if (entity == nil) {
            continue;
        }
        NSString *dicBookId = [entity valueForKey:@"dataId"];
        NSNumber *dicBookStatusNum = [entity valueForKey:@"dataStatus"];
        int bookStatusInt = [dicBookStatusNum intValue];
        NSString *bookStatusStr = nil;
        NSString *downLoadStatus = nil;//该状态暂时未设置
        
        if (bookStatusInt >= 1 && bookStatusInt <= 3) {
            bookStatusStr = @"下载中";
        }
        else if (bookStatusInt == 7) {
            bookStatusStr = @"可更新";
        }
        else if (bookStatusInt == 8 || bookStatusInt ==9) {
            bookStatusStr = @"更新中";
        }
        else if (bookStatusInt == 10) {
            bookStatusStr = @"完成";
        }
        else if (bookStatusInt == 11) {
            bookStatusStr = @"APP版本过低";
        }
        else if (bookStatusInt == 12) {
            bookStatusStr = @"APP版本过高";
        }
        else if (bookStatusInt == 14) {
            bookStatusStr = @"下载失败";
        }
        else if (bookStatusInt == 15) {
            bookStatusStr = @"下载暂停";
        }
        else if (bookStatusInt == -1  || bookStatusInt > 15) {
            bookStatusStr = @"未下载";
        }
        
        NSString *dicBookStatusDetails = [entity valueForKey:@"dataStatusDesc"];
        //将浮点型转换成integer型，再转换成字符串类型
        NSString *downLoadProgressStr = nil;
        CGFloat downLoadProgressFloat = [dicBookStatusDetails floatValue];
        if (downLoadProgressFloat == 100) {
            downLoadProgressStr = [NSString stringWithFormat:@"%@",@"100"];
        }
        else {
            NSInteger downLoadProgress = (NSInteger)(downLoadProgressFloat*100);
            downLoadProgressStr = [NSString stringWithFormat:@"%ld",(long)downLoadProgress];
        }
        
        
        //构造字典
        [dic setValue:dicBookId forKey:@"book_id"];
        [dic setValue:bookStatusStr forKey:@"book_status"];
        [dic setValue:downLoadProgressStr forKey:@"book_status_detail"];
        
        
        
    }
    
    return dic;
    
}

#pragma mark 获取封面图片调用的接口

- (NSString *)getCoverImageFilePath:(NSString *)dataId {
    //从db中获取书分封面图片信息不能限定dataType
    NSArray *bookArr = [[KnowledgeMetaManager instance] getKnowledgeMetaWithDataId:dataId andDataType:DATA_TYPE_DATA_SOURCE];
    //    NSArray *bookArr = [[KnowledgeMetaManager instance] getKnowledgeMetaWithDataId:dataId];
    NSString *coverSrc = nil;
    for (NSManagedObject *entity in bookArr) {
        if (entity == nil) {
            continue;
        }
        coverSrc = [entity valueForKey:@"coverSrc"];
        if (coverSrc == nil) {
            LogInfo(@"[ WebViewBridgeRegisterUtil - getConverImageFilePath ]:get coverImage failed because of coverImage url is nil");
            return nil;
        }
    }
    return coverSrc;
}

#pragma mark app内设置页面的接口
//go to apple  App Store
- (void)gotoAppStoreWithAppId:(NSString *)appId {
    
    NSString *str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@",appId];//appID
    NSLog(@"评论页面的URL = %@",str);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}

@end
