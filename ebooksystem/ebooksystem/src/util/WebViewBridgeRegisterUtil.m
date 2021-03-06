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
#import "MobClick.h"

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
#import "GTMBase64.h"
#import "UpLoadUtil.h"

#import "XGSetting.h"
#import "XGPush.h"
#import "DeviceStatusUtil.h"
#import "KnowledgeDataManager.h"

#import "UserDataMeta.h"
#import "HttpRequestUtil.h"

//测试
#import "wordTestViewController.h"



typedef enum {
    HADITEMDOWNLOAD = -2,
	UNKNOWN = -1,
	FAILED, //操作失败
	SUCCESS,//操作成功
} OPERATIONRESULT;



@interface WebViewBridgeRegisterUtil () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, uploadDelegate, UIAlertViewDelegate>

#pragma mark - properties
// bridge between webview and js
@property (nonatomic, strong) WebViewJavascriptBridge *javascriptBridge;
//存储图片base64编码后的字符串
@property (nonatomic, strong) NSString *imageString;
@property (nonatomic, strong) NSData *upLoadData;

//拍照接口用到的属性
@property (nonatomic, strong) NSString *callIdString;
@property (nonatomic, strong) NSString *uploadCallId;
@property (nonatomic, strong) WVJBResponseCallback responseCall;
@property (nonatomic, strong) WVJBResponseCallback upLoadresponseCallBack;
@property (nonatomic, assign) BOOL upLoadSuccess;


@end



@implementation WebViewBridgeRegisterUtil

+ (WebViewBridgeRegisterUtil *)instance {
	static WebViewBridgeRegisterUtil *sharedInstance = nil;
	static dispatch_once_t predicate;
	dispatch_once(&predicate, ^{
		sharedInstance = [[WebViewBridgeRegisterUtil alloc] init];
	});

	return sharedInstance;
}

/*
    做两件事情：
    （1）把webview传进来，bridge创建需要注入的js和webview
    （2）实例化bridge时，webviewDelegate的参数需要是controller。具体原因还需要再调研
 */

// bridge between webview and js
- (WebViewJavascriptBridge *)javascriptBridge {
	if (_javascriptBridge == nil) {
		_javascriptBridge = [WebViewJavascriptBridge bridgeForWebView:self.webView webViewDelegate:self.controller handler: ^(id data, WVJBResponseCallback responseCallback) {
		    LogDebug(@"Received message from javascript: %@", data);
		    responseCallback(@"'response data from obj-c'");
		}];
		[self initWebView];
	}
	return _javascriptBridge;
}

- (void)initWebView {
	//保证在queue队列只创建一次
	dispatch_queue_t queue = dispatch_queue_create("queryBookStatusThread", NULL);
	//保证下载的queue只创建一次
	dispatch_queue_t startDownloadQueue = dispatch_queue_create("startDownloadThread", NULL);
	//
	dispatch_queue_t getBookListQueue = dispatch_queue_create("startDownloadThread", NULL);

	// goback()
	[self.javascriptBridge registerHandler:@"goBack" handler: ^(id data, WVJBResponseCallback responseCallback) {
	    LogDebug(@"WebViewBridgeRegisterUtil::goBack() called: %@", data);
	    //
	    NSString *backInfo = data;
	    SBJsonParser *parse = [[SBJsonParser alloc] init];
	    NSDictionary *dic = [parse objectWithString:backInfo];
	    if (dic == nil) {
	        LogInfo(@"WebViewBridgeRegisterUtil::goBack() goback info is nil");
		}
	    //每次注入，都会导致WebviewRegisterUtil 持有一次controller对象，导致退出controller时，webviewRegisterUtil对象持有一次controller实例，导致从当前视图pop回去后无法释放，所以要在这里消除掉

	    //
	    [self goBack:dic];
	}];


	//getData
	[self.javascriptBridge registerHandler:@"getData" handler: ^(id data, WVJBResponseCallback responseCallback) {
	    LogDebug(@"WebViewBridgeRegisterUtil::getData() called: %@", data);
	    SBJsonParser *parser = [[SBJsonParser alloc] init];
	    NSDictionary *dataDic = [parser objectWithString:data];
	    NSString *dataId = [dataDic objectForKey:@"book_id"];
	    NSString *queryId = [dataDic objectForKey:@"query_id"];
	    if (responseCallback != nil) {
	        NSArray *dataArray = [[KnowledgeManager instance] getLocalDataWithDataId:dataId andQueryId:queryId andIndexFilename:nil];
	        NSString *data = nil;

	        if (dataArray == nil || dataArray.count <= 0) {
	            data = @"";
			}
	        else {
	            for (NSString *dataStr in dataArray) {
	                if (dataStr == nil || dataStr.length <= 0) {
	                    continue;
					}

	                data = dataStr;
	                break;
				}
			}


	        responseCallback(data);
		}
	}];
	//renderPage
	[self.javascriptBridge registerHandler:@"renderPage" handler: ^(id data, WVJBResponseCallback responseCallback) {
	    LogDebug(@"WebViewBridgeRegisterUtil::renderPage() called: %@", data);
	    SBJsonParser *parse = [[SBJsonParser alloc] init];
	    NSDictionary *dic = [parse objectWithString:data];
	    [self showPageWithDictionary:dic];

	    //统计页面点击次数
	    NSString *book_id = dic[@"book_id"];
	    NSString *page_type = dic[@"page_type"];
//	    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			NSString *urlString = [NSString stringWithFormat:@"http://log.zaxue100.com/pv.gif?t=book_click&k=%@&v=1&pageType=%@", book_id, page_type];
			[[StatisticsManager instance] statisticWithUrl:urlString];
        //发到友盟
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSDictionary *paramDic = [NSDictionary dictionaryWithObjectsAndKeys:book_id,@"book_id",page_type,@"page_type", nil];
            [MobClick event:@"render_page" attributes:paramDic];
        });
        
            
            
//		});
	}];

	//************* 书签的接口 **************

	//addBookmark
	[self.javascriptBridge registerHandler:@"addBookmark" handler: ^(id data, WVJBResponseCallback responseCallback) {
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
	[self.javascriptBridge registerHandler:@"removeBookmark" handler: ^(id data, WVJBResponseCallback responseCallback) {
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
	            NSString *successStr = [NSString stringWithFormat:@"%d", SUCCESS];
	            responseCallback(successStr);//成功 1
			}
	        else {
	            NSString *failedStr = [NSString stringWithFormat:@"%d", FAILED];
	            responseCallback(failedStr);//失败 0
			}
		}
	}];


	//updateBookmark
	[self.javascriptBridge registerHandler:@"updateBookmark" handler: ^(id data, WVJBResponseCallback responseCallback) {
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
	[self.javascriptBridge registerHandler:@"getBookmarkList" handler: ^(id data, WVJBResponseCallback responseCallback) {
	    NSString *infoStr = data;
	    if (infoStr == nil || infoStr.length <= 0) {
	        LogError(@"WebViewBridgeRegisterUtil - getBookmarkList:get book mark list failed because data is nil ");
	        return;
		}
	    SBJsonParser *parse = [[SBJsonParser alloc] init];
	    NSDictionary *dic = [parse objectWithString:infoStr];
	    if (dic == nil) {
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
	        NSArray *array = [manager getAllBookMark];

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
	[self.javascriptBridge registerHandler:@"addCollection" handler: ^(id data, WVJBResponseCallback responseCallback) {
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
	[self.javascriptBridge registerHandler:@"getCollectionList" handler: ^(id data, WVJBResponseCallback responseCallback) {
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
	        if (bookId == nil || bookId.length <= 0) {
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
	                if (error) {//判断转成JSON字符串时是否出错。
	                    LogError(@"WebViewBridgeRegisterUtil - getCollectionList : failed because of error :%@", error);
					}
	                responseCallback(returnStr);
				}
			}
		}
	}];

	//removeCollectionList
	[self.javascriptBridge registerHandler:@"removeCollectionList" handler: ^(id data, WVJBResponseCallback responseCallback) {
	    //
	    NSString *infoDicStr = data;
	    if (infoDicStr == nil || infoDicStr.length <= 0) {
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
	            NSString *successStr = [NSString stringWithFormat:@"%d", SUCCESS];
	            responseCallback(successStr);//成功 1
			}
	        else {
	            NSString *failedStr = [NSString stringWithFormat:@"%d", FAILED];
	            responseCallback(failedStr);//失败 0
			}
		}
	}];

	//************ 扫一扫接口 ***********
	//startQRCodeScan
	[self.javascriptBridge registerHandler:@"startQRCodeScan" handler: ^(id data, WVJBResponseCallback responseCallback) {
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
	[self.javascriptBridge registerHandler:@"showAppPageByAction" handler: ^(id data, WVJBResponseCallback responseCallback) {
	    //
	    NSString *actionStr = data;
	    SBJsonParser *parse = [[SBJsonParser alloc] init];
	    NSDictionary *dic = [parse objectWithString:actionStr];
	    //根据Js传的参数来决定是否需要开新的WebView
	    [self showAppPageByaction:dic];
	}];

	//showURL 打开在线网页
	[self.javascriptBridge registerHandler:@"showURL" handler: ^(id data, WVJBResponseCallback responseCallback) {
	    //
	    NSString *dataStr = data;
	    SBJsonParser *parse = [[SBJsonParser alloc] init];
	    NSDictionary *dic = [parse objectWithString:dataStr];
//        self.needRefresh = [dic objectForKey:@"need_refresh"];//记录当前这个页面再次出现时是否需要刷新
	    if ([[dic objectForKey:@"target"] isEqualToString:@"activity"]) {
	        //新开controller 加载url
	        [self showSafeURL:[dic objectForKey:@"url"] withAnimation:[dic objectForKey:@"open_animate"]];
		}
	    else {
	        NSString *urlStr = [dic objectForKey:@"url"];
	        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
		}
	}];


	//  ******* 播放视频的接口 *******
	// playVideo()
	[self.javascriptBridge registerHandler:@"playVideo" handler: ^(id dataId, WVJBResponseCallback responseCallback) {
	    LogDebug(@"WebViewBridgeRegisterUtil::playVideo() called: %@", dataId);

	    NSString *urlStr = (NSString *)dataId;
	    [self playVideo:urlStr];
	}];
	// ********* 分享 *******
	//shareApp
	[self.javascriptBridge registerHandler:@"shareApp" handler: ^(id data, WVJBResponseCallback responseCallback) {
	    LogDebug(@"WebViewBridgeRegisterUtil::share() called: %@", data);
	    NSString *shareContentStr = data;
	    //parse
	    SBJsonParser *parse = [[SBJsonParser alloc] init];
	    NSDictionary *shareDic = [parse objectWithString:shareContentStr];
	    //share
	    [self share:shareDic];
	}];
	//change Background
	[self.javascriptBridge registerHandler:@"setStatusBarBackground" handler: ^(id data, WVJBResponseCallback responseCallback) {
	    [self changeBackgourndColorWithColor:data];
	}];

	// ******* set && get current user study type **********
	//getCurStudyType
	[self.javascriptBridge registerHandler:@"getCurStudyType" handler: ^(id data, WVJBResponseCallback responseCallback) {
	    //在nsuserDefault中设置一个curStudyType字段，用来存储当前用户的学习状态
	    LogDebug(@"WebViewBridgeRegisterUtil::getCurStudyType() called: %@", data);
	    if (responseCallback != nil) {
	        NSString *data = nil;
	        NSString *curStudyType = [NSUserDefaultUtil getCurStudyType];
	        if (curStudyType != nil && curStudyType.length > 0) {
	            data = curStudyType;

	            responseCallback(data);
			}
		}
	}];

	//setCurStudyType
	[self.javascriptBridge registerHandler:@"setCurStudyType" handler: ^(id data, WVJBResponseCallback responseCallback) {
	    LogDebug(@"WebViewBridgeRegisterUtil::setCurStudyType() called: %@", data);
	    NSString *curStudyType = data;
	    if (curStudyType != nil && curStudyType.length > 0) {
	        BOOL isSuccess = [NSUserDefaultUtil setCurStudyTypeWithType:curStudyType];
	        if (isSuccess) {
	            NSString *successStr = [NSString stringWithFormat:@"%d", SUCCESS];
	            responseCallback(successStr);//成功 1
			}
	        else {
	            NSString *failedStr = [NSString stringWithFormat:@"%d", FAILED];
	            responseCallback(failedStr);//失败 0
			}
		}
	    else {
	        LogError(@"WebViewBridgeRegisterUtil::setCurStudyType() failed because of curStudyType is equal to nil");
	        NSString *failedStr = [NSString stringWithFormat:@"%d", FAILED];
	        responseCallback(failedStr);//失败 0
		}
	}];


	//curUserLogout
	[self.javascriptBridge registerHandler:@"setCurStudyType" handler: ^(id data, WVJBResponseCallback responseCallback) {
	    NSLog(@"用户登出，方法体中只有这一句代码");
	}];


	//************ get book's all status **********
	//getBookList
	[self.javascriptBridge registerHandler:@"getBookList" handler: ^(id data, WVJBResponseCallback responseCallback) {
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
        NSLog(@"getBookList 接口返给JS的内容=====%@",string);
	    if (responseCallback != nil) {
	        responseCallback(string);    //getBookList和queryBookStatus若是数组为空，都必须返回“[]”,格式字符串否则解析JS失败。
		}



	}];

	//checkDataUpdate
	[self.javascriptBridge registerHandler:@"checkDataUpdate" handler: ^(id data, WVJBResponseCallback responseCallback) {
	    LogDebug(@"WebViewBridgeRegisterUtil::checkDataUpdate() called: %@", data);
	    NSString *book_category = data;//值：0，1 还需要分类型吗？
	    //检查某类书籍是否有更新，需要从数据库中查找（方法：1、获取更新数据的版本文件 2、把是否有更新的信息存储到数据库中，只需要返回给js是否开始检查的通知即可，不需要检查更新的结果给JS）。
	    //返回0，1
	    BOOL isStart = NO;
	    {
	        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				[[KnowledgeManager instance] getUpdateInfoFileFromServerAndUpdateDataBase];
			});
	        isStart = YES;
		}
	    if (responseCallback != nil) {
	        if (isStart) {
	            NSString *successStr = [NSString stringWithFormat:@"%d", SUCCESS];
	            responseCallback(successStr);//成功 1
			}
	        else {
	            NSString *failedStr = [NSString stringWithFormat:@"%d", FAILED];
	            responseCallback(failedStr);//失败 0
			}
		}
	}];

	//startDownload
	[self.javascriptBridge registerHandler:@"startDownload" handler: ^(id data, WVJBResponseCallback responseCallback) {
        
        //书包页中同样只允许下载一本
        
        NSString *hadItemDownloadStr = [NSUserDefaultUtil getDownLoadStatus];
        if ([hadItemDownloadStr isEqualToString:@"ITEMDOWNLOADING"]) {//正在下载返回-2
            NSString *hadItemDownload = [NSString stringWithFormat:@"%d", HADITEMDOWNLOAD];
            responseCallback(hadItemDownload);//失败 0
            return ;
        }
        
        
        
	    LogDebug(@"WebViewBridgeRegisterUtil::startDownload() called: %@", data);
	    NSString *book_id = data;
	    //下载的过程就是只有一步，拿到data_id后直接开始下载。（具体操作：1、根据book_id去下载 2、将下载的进度实时存到数据库中即可，不需要做读取的操作，也不需要将进度返回给JS。只需要告诉JS是否已经开始下载）。
	    BOOL isStart = NO;
	    {


//            dispatch_async(dispatch_get_global_queue(0, 0), ^{
	        dispatch_async(startDownloadQueue, ^{
				BOOL updateStatus = [self updateDownloadStatusWithDataId:book_id];
				BOOL ret = [[KnowledgeManager instance] startDownloadDataManagerWithDataId:book_id];


            });

	        isStart = YES;
		}



	    if (responseCallback != nil) {
	        if (isStart) {
	            NSString *successStr = [NSString stringWithFormat:@"%d", SUCCESS];
	            responseCallback(successStr);//成功 1
			}
	        else {
	            NSString *failedStr = [NSString stringWithFormat:@"%d", FAILED];
	            responseCallback(failedStr);//失败 0
			}
		}
	}];


	
	//queryBookStatus
	[self.javascriptBridge registerHandler:@"queryBookStatus" handler: ^(id data, WVJBResponseCallback responseCallback) {
	    LogDebug(@"RenderKnowledgeViewController::queryBookStatus() called: %@", data);

    

	    dispatch_async(dispatch_get_global_queue(0, 0), ^{
            //只开辟一条线程来串行的操作数据库（而不是开辟多条线程并发的操作数据库）

			SBJsonParser *parse = [[SBJsonParser alloc] init];
			NSArray *book_ids = [parse objectWithString:data];
			//操作：遍历获取到的book_id数组
			//根据book_ids来获取下载进度，需要从数据库中取到，（具体操作：1、根据book_id对数据库做读取操作 2、返回结果是一个json，其中downLoad_status需要返回汉字）。
			NSMutableArray *booksArray = [NSMutableArray array];
			for (NSString *bookId in book_ids) {
			    if (bookId == nil) {
			        continue;
				}
			    //根据book_id从数据库中取相应的状态
			    NSMutableDictionary *dic = nil;


			    dic = [self getDicFormDataBase:bookId];


			    if (dic == nil) {
			        continue;
				}
			    [booksArray addObject:dic];
			}
			NSLog(@"获取的数据状态===%@", booksArray);
			//返回的是数组类型的值，即使是空数组也要解析一下
			SBJsonWriter *writer = [[SBJsonWriter alloc] init];
			NSString *jsonStr = [writer stringWithObject:booksArray];
			if (responseCallback != nil) {
			    responseCallback(jsonStr);
			}
		});
	}];

	// ****** 获取封面图片 *****
	//getCoverSrc
	[self.javascriptBridge registerHandler:@"getCoverSrc" handler: ^(id data, WVJBResponseCallback responseCallback) {
	    //获取封面

	    NSString *book_id = data;
	    if (responseCallback != nil) {
	        NSString *partialPathInSandBox = [self getCoverImageFilePath:book_id];
	        NSString *documentPath = [PathUtil getDocumentsPath];
	        NSString *coverImagePathStr = [NSString stringWithFormat:@"%@/%@", documentPath, partialPathInSandBox];
	        if (coverImagePathStr == nil || coverImagePathStr.length <= 0) {
	            //将默认图片的SRC传给JS
	            NSString *defaultBookCoverPath = [[[Config instance] drawableConfig]getTabbarItemImageFullPath:@"default_book_cover.png"];
	            coverImagePathStr = defaultBookCoverPath;
			}
	        responseCallback(coverImagePathStr);
		}
	    //
	}];

	//goDiscoverPage
	[self.javascriptBridge registerHandler:@"goDiscoverPage" handler: ^(id data, WVJBResponseCallback responseCallback) {
	    //跳转到发现页
	    self.tabBarController.selectedIndex = 1;
//        [self.delegate goDiscoverPage];//代理属性调用代理方法
	}];

	//************** ****
	//goUserSettingPage
	[self.javascriptBridge registerHandler:@"goUserSettingPage" handler: ^(id data, WVJBResponseCallback responseCallback) {
	    /*
	       //跳转到设置页面
	       RenderKnowledgeViewController *render = [[RenderKnowledgeViewController alloc] init];
	       NSString *bundlePath = [PathUtil getBundlePath];
	       NSString *userCenterUrlStrWithParams = [NSString stringWithFormat:@"%@/%@/%@/%@", bundlePath, @"assets",@"native-html",@"user_center.html"];
	       render.webUrl = userCenterUrlStrWithParams;
	       [self.navigationController pushViewController:render animated:YES];
	     */
	    //测试相机使用

	    [self openCameraDelaied];
//        [self openPhotoLibrary];
	}];


	// *******  发现页的接口 ********
	//showURL
	//addToNative
	[self.javascriptBridge registerHandler:@"addToNative" handler: ^(id data, WVJBResponseCallback responseCallback) {
        
        //addTonative时需要先判断是否有书籍正在下载
        
        NSString *hadItemDownloadStr = [NSUserDefaultUtil getDownLoadStatus];
        if ([hadItemDownloadStr isEqualToString:@"ITEMDOWNLOADING"]) {//正在下载返回-2
            NSString *hadItemDownload = [NSString stringWithFormat:@"%d", HADITEMDOWNLOAD];
            responseCallback(hadItemDownload);//失败 0
            return ;
        }
        
        
        
	    /*
	       1先调queryBookStatus接口，检查本地是否有这本书。（若是本地没有该书的记录，返回空数组）
	       2若是没有则掉addToNative接口
	        (1)首先检查数据库中的记录，若是已经存在则返回成功
	        (2.1)若是不存在，则向数据库中add一条记录，并设置status为系在中，进度为0
	        (2.2)开始下载
	     */
	    NSString *bookID = data;

	    //异步请求
	    //1、检查数据库
        dispatch_async(dispatch_get_global_queue(0, 0), ^{

	    NSArray *knowledgeMetaArray = [[KnowledgeMetaManager instance] getKnowledgeMetaWithDataId:bookID andDataType:DATA_TYPE_UNKNOWN];

	    BOOL isSuccess = NO;
	    discoveryModel *model = [[discoveryModel alloc] init];
	    NSArray *arr = [NSArray arrayWithObjects:bookID, nil];

	    if (knowledgeMetaArray == nil || knowledgeMetaArray.count <= 0) {
	        //数据库中没有记录（1）在数据库中添加一条
	        [[KnowledgeMetaManager instance] setDataStatusTo:DATA_STATUS_DOWNLOAD_IN_PROGRESS andDataStatusDescTo:@"0" forDataWithDataId:bookID andType:DATA_TYPE_DATA_SOURCE];
	        //（2）发起网络请求，并进行下载
	        self.needCheckBookId = bookID;//获取需要下载的书籍
//            dispatch_async(startDownloadQueue, ^{
//
//                [model getBookInfoWithDataIds:arr];
//            });

	        isSuccess =  [model getBookInfoWithDataIds:arr];
		}
	    else {//数据库中有对应的记录
            for (KnowledgeMeta *knowledgeMeta in knowledgeMetaArray) {
                if (knowledgeMeta == nil) {
                    continue;
                }
                
                NSNumber *dicBookStatusNum = [NSNumber numberWithInt:(int)knowledgeMeta.dataStatus];
                int bookStatusInt = [dicBookStatusNum intValue];
                if (bookStatusInt == 14 || bookStatusInt == 16 || bookStatusInt == 18 || bookStatusInt == 20) {//四种失败状态
                    self.needCheckBookId = bookID;//获取需要下载的书籍
                    isSuccess = [model getBookInfoWithDataIds:arr];
                }
                else {
                    isSuccess = YES;
                }
            }
//
		}


	    if (responseCallback != nil) {
	        if (isSuccess) {
	            NSString *successStr = [NSString stringWithFormat:@"%d", SUCCESS];
	            responseCallback(successStr);//成功 1
			}
	        else {
	            NSString *failedStr = [NSString stringWithFormat:@"%d", FAILED];
	            responseCallback(failedStr);//失败 0
			}
		}
            
            
            
        });
	}];



	// ********** 个人中心页的接口 ****************
	//showAppPageByAction
	[self.javascriptBridge registerHandler:@"showAppPageByAction" handler: ^(id data, WVJBResponseCallback responseCallback) {
	    //
	    NSString *actionStr = data;
	    SBJsonParser *parse = [[SBJsonParser alloc] init];
	    NSDictionary *dic = [parse objectWithString:actionStr];
	    //根据Js传的参数来决定是否需要开新的WebView
	    [self showAppPageByaction:dic];
	}];

	//setCurUserInfo
	[self.javascriptBridge registerHandler:@"setCurUserInfo" handler: ^(id data, WVJBResponseCallback responseCallback) {
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
        if (userId != nil && userId.length > 0) {
            [NSUserDefaultUtil saveUserId:userId];
        }
        
        
	    //******** 登陆成功后要注册用户到XG后台 *********
	    [XGPush setAccount:userId];
	    //再次注册设备
	    NSData *deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"];

	    void (^successBlock)(void) = ^(void) {
	        LogInfo(@"信鸽注册失败");
		};

	    void (^errorBlock)(void) = ^(void) {
	        LogInfo(@"信鸽注册失败");
		};

	    if (deviceToken != nil && deviceToken.length > 0) {//做一次判断，防止程序崩溃
	        [XGPush registerDevice:deviceToken successCallback:successBlock errorCallback:errorBlock];
		}

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
	        NSString *successStr = [NSString stringWithFormat:@"%d", SUCCESS];
	        responseCallback(successStr);//成功 1
		}
	    else {
	        NSString *failedStr = [NSString stringWithFormat:@"%d", FAILED];
	        responseCallback(failedStr);//失败 0
		}
	}];

	//getCurUserInfo
	[self.javascriptBridge registerHandler:@"getCurUserInfo" handler: ^(id data, WVJBResponseCallback responseCallback) {
	    //默认图片
	    NSString *imageUrl = [[[Config instance] drawableConfig] getImageFullPath:@"defaultPersonImage.png"];
	    NSString *imageBundlePath = [[NSBundle mainBundle] bundlePath];
	    NSString *fullpath = [NSString stringWithFormat:@"%@/%@", imageBundlePath, imageUrl];
	    //其他用户信息
	    UserManager *userManager = [UserManager instance];
	    UserInfo *userinfo = [userManager getCurUser];
	    if (userinfo.userId == nil || userinfo.userId <= 0) {
	        if (responseCallback != nil) {
	            responseCallback(@"{}");
			}
		}
	    else {
	        NSString *cruUserName = userinfo.username;
	        NSString *cruUserInfoBalance = userinfo.balance;
	        NSString *cruUserId = userinfo.userId;
	        NSString *cruPhone = userinfo.phoneNumber;
	        NSDictionary *userInfoDic = @{ @"user_id":cruUserId, @"user_name":cruUserName, @"avatar_src":fullpath, @"balance":cruUserInfoBalance, @"mobile":cruPhone };
	        SBJsonWriter *writer = [[SBJsonWriter alloc] init];
	        NSString *userInfoStr = [writer stringWithObject:userInfoDic];
	        if (responseCallback != nil) {
	            responseCallback(userInfoStr);
			}
		}
	}];
	// curUserLogout
	[self.javascriptBridge registerHandler:@"curUserLogout" handler: ^(id data, WVJBResponseCallback responseCallback) {

	    //logout
	    UserManager *usermanager = [UserManager instance];
	    [usermanager cruUserLogout];
	    //用户登出时，注销设备
//        [XGPush unRegisterDevice];
        //用户登出时，清掉用户记录
        [NSUserDefaultUtil removeUserId];
	    if (responseCallback != nil) {
	        responseCallback(@"1");//需要回调，否则页面不能在登出后，返回到上一个页面
		}
	}];

	// ********* 设置页面接口 *******
	//voteForZaxue
	[self.javascriptBridge registerHandler:@"voteForZaxue" handler: ^(id data, WVJBResponseCallback responseCallback) {
	    //appId需要修改 -- App打分
	    [self gotoAppStoreWithAppId:@"982159280"];
	}];
	//checkAppUpdate
	[self.javascriptBridge registerHandler:@"checkAppUpdate" handler: ^(id data, WVJBResponseCallback responseCallback) {
	    //检查更新
	    UpdateManager *manager = [UpdateManager instance];
	    BOOL needUpdate = [manager updateAble];
	    if (responseCallback != nil) {
	        if (needUpdate == YES) {
	            NSString *successStr = [NSString stringWithFormat:@"%d", SUCCESS];
	            responseCallback(successStr);//有更新返回 1
			}
	        else {
	            NSString *failedStr = [NSString stringWithFormat:@"%d", FAILED];
	            responseCallback(failedStr);//无更新返回 0
			}
		}
	}];
	//showAboutPage
	[self.javascriptBridge registerHandler:@"showAboutPage" handler: ^(id data, WVJBResponseCallback responseCallback) {
	    //关于页面
	    AboutUsViewController *about = [[AboutUsViewController alloc] init];
	    [self.navigationController pushViewController:about animated:YES];
	}];
	//shareApp
	//getSystemInfoList


	// *********  问答页相关接口 **********
	//openCam
	[self.javascriptBridge registerHandler:@"openCam" handler: ^(id data, WVJBResponseCallback responseCallback) {
	    //打开摄像头
	    NSString *callIdStr = data;
	    if (callIdStr == nil || callIdStr.length <= 0) {
	        LogWarn(@"[ WebViewBridgeRegisterUtil-initWebView ]:callId is nil");
		}

	    //保存callID，在Native调用JS时将callId返回给JS。
	    SBJsonParser *parse = [[SBJsonParser alloc] init];
	    NSDictionary *dataDic = [parse objectWithString:callIdStr];
	    NSString *callId = [dataDic objectForKey:@"call_id"];
	    self.callIdString = callId;

	    //打开相机拍照，并将获得照片进行base64编码
	    [self openCameraDelaied];

	    if (responseCallback != nil) {
	        NSString *successStr = [NSString stringWithFormat:@"%d", SUCCESS];
	        responseCallback(successStr);//成功 1
		}
	    else {
	        NSString *failedStr = [NSString stringWithFormat:@"%d", FAILED];
	        responseCallback(failedStr);//失败 0
		}
	}];
	//openAlbum
	[self.javascriptBridge registerHandler:@"openAlbum" handler: ^(id data, WVJBResponseCallback responseCallback) {
	    //代开相册
	    NSString *callIdStr = data;
	    if (callIdStr == nil || callIdStr.length <= 0) {
	        LogWarn(@"[ WebViewBridgeRegisterUtil-initWebView ]:callId is nil");
		}
	    //保存callID，在Native调用JS时将callId返回给JS。
	    SBJsonParser *parse = [[SBJsonParser alloc] init];
	    NSDictionary *dataDic = [parse objectWithString:callIdStr];
	    NSString *callId = [dataDic objectForKey:@"call_id"];
	    self.callIdString = callId;

	    //打开相册，并将获得照片进行base64编码
	    [self openPhotoLibrary];

	    if (responseCallback != nil) {
	        NSString *successStr = [NSString stringWithFormat:@"%d", SUCCESS];
	        responseCallback(successStr);//成功 1
		}
	    else {
	        NSString *failedStr = [NSString stringWithFormat:@"%d", FAILED];
	        responseCallback(failedStr);//失败 0
		}
	}];

	//uploadImage
	[self.javascriptBridge registerHandler:@"uploadImage" handler: ^(id data, WVJBResponseCallback responseCallback) {
	    //上传图片
	    NSString *metaInfo = data;
	    if (metaInfo == nil || metaInfo.length <= 0) {
	        LogWarn(@"[ WebViewBridgeRegisterUtil-initWebView ]:callId is nil");
		}
	    SBJsonParser *parse = [[SBJsonParser alloc] init];
	    NSDictionary *metaInfoDic = [parse objectWithString:metaInfo];
	    NSString *callId = [metaInfoDic objectForKey:@"call_id"];
	    NSString *token = [metaInfoDic objectForKey:@"token"];
	    //保存callId，当native调用JS时讲这个参数传给JS
	    self.uploadCallId = callId;
	    //开始上传图片
	    [self upLoadImageWithTokenString:token];
	    //回调
	    if (responseCallback != nil) {
	        NSString *successStr = [NSString stringWithFormat:@"%d", SUCCESS];
	        responseCallback(successStr);//成功 1
		}
	    else {
	        responseCallback(@"0");
	        NSString *failedStr = [NSString stringWithFormat:@"%d", FAILED];
	        responseCallback(failedStr);//失败 0
		}
	}];

	// ********** 网络刷新 ************
	//refreshOnlinePage
	[self.javascriptBridge registerHandler:@"refreshOnlinePage" handler: ^(id data, WVJBResponseCallback responseCallback) {
	    DeviceStatusUtil *device = [[DeviceStatusUtil alloc] init];
	    NSString *cruStatus = [device GetCurrntNet];
	    if (![cruStatus isEqualToString:@"no connect"]) {//有网络连接
//            [self.webView removeFromSuperview];
	        NSURL *discoveryUrl = [NSURL URLWithString:self.discoveryOnlineUrl];
	        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:discoveryUrl];
	        [self.webView loadRequest:request];
		}
	}];

	// *********** 获取网络状况 **********
	//getNetworkType
	[self.javascriptBridge registerHandler:@"getNetworkType" handler: ^(id data, WVJBResponseCallback responseCallback) {
	    DeviceStatusUtil *device = [[DeviceStatusUtil alloc] init];
	    NSString *cruStatus = [device GetCurrntNet];
	    if ([cruStatus isEqualToString:@"no connect"]) {
	        cruStatus = @"offline";
		}
	    //
	    NSDictionary *networkStatusDic = [NSDictionary dictionaryWithObjectsAndKeys:cruStatus, @"network_status", nil];
	    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
	    NSString *netWorkStatusStr = [writer stringWithObject:networkStatusDic];
	    if (responseCallback != nil) {
	        responseCallback(netWorkStatusStr);
		}
	}];

	// ********* 删除书籍 ************
	//removeLocalBooks
	[self.javascriptBridge registerHandler:@"removeLocalBooks" handler: ^(id data, WVJBResponseCallback responseCallback) {
	    NSString *bookIdArrayString = data;
	    if (bookIdArrayString == nil || bookIdArrayString.length <= 0) {
	        LogInfo(@"[WebViewBridgeRegisterUtil - removeLocalBooks]no data need delete");
	        NSString *successStr = [NSString stringWithFormat:@"%d", SUCCESS];
	        responseCallback(successStr);
		}
	    //开始解析
	    SBJsonParser *parse = [[SBJsonParser alloc] init];
	    NSArray *bookIdArrays = [parse objectWithString:bookIdArrayString];
	    if (bookIdArrays == nil || bookIdArrays.count <= 0) {
	        LogInfo(@"[WebViewBridgeRegisterUtil - removeLocalBooks]no data need delete");
	        NSString *successStr = [NSString stringWithFormat:@"%d", SUCCESS];
	        responseCallback(successStr);
		}
	    //根据JS传来的信息，进行解析
	    BOOL removeSuccess = [self removeLocalBookWithBookIds:bookIdArrays];
	    if (removeSuccess) {
	        NSString *successStr = [NSString stringWithFormat:@"%d", SUCCESS];
	        responseCallback(successStr);
		}
	    else {
	        NSString *failedStr = [NSString stringWithFormat:@"%d", FAILED];
	        responseCallback(failedStr);
		}
	}];


	//setGlobalData
	[self.javascriptBridge registerHandler:@"setGlobalData" handler: ^(id data, WVJBResponseCallback responseCallback) {
	    NSString *dataStr = data;
	    if (dataStr == nil || dataStr.length <= 0) {
	        LogError(@"[WebViewBridgeRegisterUtil - setGlobalData] no global data to set");
		}

	    SBJsonParser *parse = [[SBJsonParser alloc] init];
	    NSDictionary *dic = [parse objectWithString:dataStr];
	    //白天夜间模式
//        NSString *mode = [dic objectForKey:@"render-mode"];
	    //设置代理刷新tabbar的背景
//        [self.delegate refreshTabbarBackgroundWithMode:mode];


	    BOOL saveSuccess = [NSUserDefaultUtil setGlobalDataWithObject:dic];
	    if (saveSuccess) {
	        NSString *successStr = [NSString stringWithFormat:@"%d", SUCCESS];
	        responseCallback(successStr);
		}
	    else {
	        NSString *failedStr = [NSString stringWithFormat:@"%d", FAILED];
	        responseCallback(failedStr);
		}
	}];

	//getGlobalData
	[self.javascriptBridge registerHandler:@"getGlobalData" handler: ^(id data, WVJBResponseCallback responseCallback) {
	    NSString *dataStr = data;
	    if (dataStr == nil || dataStr.length <= 0) {
	        LogError(@"[WebViewBridgeRegisterUtil - setGlobalData] data is nil");
		}
	    SBJsonParser *parse = [[SBJsonParser alloc] init];
	    NSArray *keyArray = [parse objectWithString:dataStr];
	    NSDictionary *dic = [NSUserDefaultUtil getGlobalDataWithKeyArray:keyArray];
	    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
	    NSString *dicStr = [writer stringWithObject:dic];
	    if (dicStr == nil || dicStr.length <= 0) {
	        responseCallback(@"{}");
		}
	    else {
	        responseCallback(dicStr);
		}
	}];
    
    //*********** 用户数据 ******************
    
    //setUserData
    [self.javascriptBridge registerHandler:@"setUserData" handler: ^(id data, WVJBResponseCallback responseCallback) {
        //1 解析页面传来的数据
        NSString *dataString = data;
        if (dataString == nil || dataString.length <= 0) {
            LogError(@"[WebViewBridgeRegisterUtil - setUserData] data is nil");
        }
        SBJsonParser *parse = [[SBJsonParser alloc] init];
        NSArray *userDataArray = [parse objectWithString:dataString];
//         [ { k1 : '', k2 : '', k3 : '', k4 : '', k5 : '', type : '', value : '' }, {}, {}  ]
        
        //2 开线程，保存用户数据
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //获取userId
        NSString *userId = [NSUserDefaultUtil getUserId];
        if (userId == nil || userId.length <= 0) {
            LogError(@"[[WebViewBridgeRegisterUtil - setUserData] userId is nil]");
        }
        UserRecordDataManager *userRecordManager = [UserRecordDataManager instance];
        BOOL successSaved = NO;
        for (NSDictionary *tempDic in userDataArray) {//得到最外层数组中的每一个dic
            if (tempDic == nil) {
                continue;
            }
            {
                UserDataMeta *usrDataMeta = [[UserDataMeta alloc] init];
                usrDataMeta.userId = userId;
                usrDataMeta.k1 = [tempDic objectForKey:@"k1"];
                usrDataMeta.k2 = [tempDic objectForKey:@"k2"];
                usrDataMeta.k3 = [tempDic objectForKey:@"k3"];
                usrDataMeta.k4 = [tempDic objectForKey:@"k4"];
                usrDataMeta.k5 = [tempDic objectForKey:@"k5"];
                usrDataMeta.type = [tempDic objectForKey:@"type"];
                usrDataMeta.value = [tempDic objectForKey:@"value"];
                successSaved = [userRecordManager saveUserDataMeta:usrDataMeta];
                
                //
            
            }
        }
        //3 有一个存储出现错误，返回NO
        if (successSaved) {
            NSString *successStr = [NSString stringWithFormat:@"%d", SUCCESS];
            responseCallback(successStr);
        }
        else {
            NSString *failedStr = [NSString stringWithFormat:@"%d", FAILED];
            responseCallback(failedStr);
        }
            
        });
    }];
    
    //getUserData
    [self.javascriptBridge registerHandler:@"getUserData" handler: ^(id data, WVJBResponseCallback responseCallback) {
        NSString *dataString = data;
        if (dataString == nil || dataString.length <= 0) {
            LogError(@"[WebViewBridgeRegisterUtil - getUserData] data is nil");
        }
        //1 解析
        SBJsonParser *parse = [[SBJsonParser alloc] init];
        NSDictionary *userDataDic = [parse objectWithString:dataString];
        //2 异步线程 ，从数据库中查找对应的记录，并转换成指定格式
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //获取userId
        NSString *userId = [NSUserDefaultUtil getUserId];
        NSArray *resultArray = [self getUserDataFromDBWithDictionary:userDataDic andUserId:userId];
        
        //3 encode成JSON字符串
        SBJsonWriter *writer = [[SBJsonWriter alloc] init];
        NSString *userDatasString = [writer stringWithObject:resultArray];
            
            
        //4 将结果返还给JS
        if (userDatasString == nil || userDatasString.length <= 0) {
            responseCallback(@"[]");
        }
        else {
            responseCallback(userDatasString);
        }
        
            });
        
        
        
    }];
    
    //getBatchUserData
    [self.javascriptBridge registerHandler:@"getBatchUserData" handler: ^(id data, WVJBResponseCallback responseCallback) {
        NSString *dataString = data;
        if (dataString == nil || dataString.length <= 0) {
            LogError(@"[WebViewBridgeRegisterUtil - getBatchUserData] data is nil");
        }
        NSMutableDictionary *batchUserDataDic = [[NSMutableDictionary alloc] init];
        //1 解析JS传来的JSON格式的数据
        SBJsonParser *parse = [[SBJsonParser alloc] init];
        NSDictionary *userDataDic = [parse objectWithString:dataString];
        SBJsonWriter *writer = [[SBJsonWriter alloc] init];
        //2 从数据库中获取数据
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
        NSString *userId = [NSUserDefaultUtil getUserId];
        NSArray *keyArray = [userDataDic allKeys];//获取所有arg参数
        for (NSString *tempKey in keyArray) {
            if (tempKey == nil || tempKey.length <= 0) {
                continue;
            }
            NSDictionary *tempDic = [userDataDic objectForKey:tempKey];
            //查找数据库，得到指定的数组
            NSArray *resultArray = [self getUserDataFromDBWithDictionary:tempDic andUserId:userId];
            //拼成指定的键值对
            if (resultArray == nil || resultArray.count <= 0) {//防止因为value值为nil导致程序崩掉
               [batchUserDataDic setValue:@"[]" forKey:tempKey];
            }else {//从数据库中查找到的数组不为空
                //需要将数组转换成JSON格式的字符串
                NSString *resultArrayString = [writer stringWithObject:resultArray];
                [batchUserDataDic setValue:resultArrayString forKey:tempKey];
            }
            
            
        }
            
        //3 encode成JSON字符串
        
        NSString *userDataDicString = [writer stringWithObject:batchUserDataDic];
        //4 将结果返回给JS
        if (userDataDicString == nil || userDataDicString.length <= 0) {
            responseCallback(@"{}");
        }
        else {
            responseCallback(userDataDicString);
        }
        
        });
    }];
    
    //getBatchShitData
    [self.javascriptBridge registerHandler:@"getBatchShitData" handler: ^(id data, WVJBResponseCallback responseCallback) {
        
        NSString *dataString = data;
        if (dataString == nil || dataString.length <= 0) {
            LogError(@"[WebViewBridgeRegisterUtil - getBatchShitData] data is nil");
        }
        
        
        NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] init];
        //1 解析JSON格式的数据
        SBJsonParser *parse = [[SBJsonParser alloc] init];
        NSDictionary *shitDic = [parse objectWithString:dataString];
        //2 从shit 文件中查找指定的数据
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSArray *keyArray = [shitDic allKeys];
        for (NSString *tempKey in keyArray) {
            if (tempKey == nil || tempKey.length <= 0) {
                continue;
            }
            //args参数对应dic
            NSDictionary *tempDic = [shitDic objectForKey:tempKey];
            //从shit中查找数据
            NSString *bookId = [tempDic objectForKey:@"book_id"];
            NSString *queryId = [tempDic objectForKey:@"query_id"];
            NSArray *dataArray = [[KnowledgeManager instance] getLocalDataWithDataId:bookId andQueryId:queryId andIndexFilename:nil];
            NSString *data = nil;
            
            if (dataArray == nil || dataArray.count <= 0) {
                data = @"";
            }
            else {
                for (NSString *dataStr in dataArray) {
                    if (dataStr == nil || dataStr.length <= 0) {
                        continue;
                    }
                    
                    data = dataStr;//dataId，queryId只能获取到唯一的数据
                    break;//跳出当前循环，多层循环，break只跳出一层循环
                }
            }
            //将获取到的数据添加到字典中
            [resultDic setValue:data forKey:tempKey];
            
        }
        
        //3 encode成指定格式的JSON字符串，并返回给JS
        if (resultDic == nil) {
            responseCallback(@"{}");
        }
        SBJsonWriter *writer = [[SBJsonWriter alloc] init];
        NSString *shitDataString = [writer stringWithObject:resultDic];
        
        if (shitDataString == nil || shitDataString.length <= 0) {
            responseCallback(@"{}");
        }
        else {
            responseCallback(shitDataString);
        }
            
        });
        
    }];
    
    //deleteUserData
    [self.javascriptBridge registerHandler:@"deleteUserData" handler: ^(id data, WVJBResponseCallback responseCallback) {
        //开辟线程进行操作
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //1 解析页面上传来的数据
        NSString *dataString = data;
        if (dataString == nil || dataString.length <= 0) {
            LogError(@"[WebViewBridgeRegisterUtil - deleteUserData] data is nil");
        }
        SBJsonParser *parse = [[SBJsonParser alloc] init];
        NSDictionary *contentDic = [parse objectWithString:dataString];
        //2 删除指定的userData
        UserRecordDataManager *userRecordManager = [UserRecordDataManager instance];
        NSString *userId = [NSUserDefaultUtil getUserId];
        NSString *amount = [userRecordManager deleteUserDataWithDictionary:contentDic andUserId:userId];
        if (responseCallback != nil) {
            responseCallback(amount);
        }
        
        });
    }];
    
    
    
    
   
    //httpGet
    [self.javascriptBridge registerHandler:@"httpGet" handler: ^(id data, WVJBResponseCallback responseCallback) {
        NSString *dataString = data;
        if (dataString == nil || dataString.length <= 0) {
            LogError(@"[WebViewBridgeRegisterUtil - httpGet] data is nil");
        }
        
        SBJsonParser *parse = [[SBJsonParser alloc] init];
        NSDictionary *dataDic = [parse objectWithString:dataString];
        NSString *urlString = [[dataDic objectForKey:@"url"] objectForKey:@"gson_fix"];
        NSDictionary *headerDic = [dataDic objectForKey:@"header"];
        //开辟线程，进行get请求
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [HttpRequestUtil httpGetWithUrl:urlString andHeader:headerDic andResponseCallBack:responseCallback];
        });
        
    }];
    
    //httpPost
    [self.javascriptBridge registerHandler:@"httpPost" handler: ^(id data, WVJBResponseCallback responseCallback) {
        
        NSString *dataString = data;
        if (dataString == nil || dataString.length <= 0) {
            LogError(@"[WebViewBridgeRegisterUtil - httpPost] data is nil");
        }
        
        SBJsonParser *parse = [[SBJsonParser alloc] init];
        NSDictionary *dataDic = [parse objectWithString:dataString];
        NSString *urlString = [[dataDic objectForKey:@"url"] objectForKey:@"gson_fix"];
        NSDictionary *headerDic = [dataDic objectForKey:@"header"];
        NSDictionary *bodyDic = [dataDic objectForKey:@"body"];
        //开辟线程，进行post请求
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [HttpRequestUtil httpPostWithUrl:urlString andHeader:headerDic andBody:bodyDic andResponseCallBack:responseCallback];
        });
        
    }];
    
    //pageStatistic
    [self.javascriptBridge registerHandler:@"pageStatistic" handler: ^(id data, WVJBResponseCallback responseCallback) {
        NSString *dataString = data;
        if (dataString == nil || dataString.length <= 0) {
            LogError(@"[WebViewBridgeRegisterUtil - pageStatistic] data is nil");
        }
        //开辟线程进行统计
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //1 解析
        SBJsonParser *parse = [[SBJsonParser alloc] init];
        NSDictionary *dic = [parse objectWithString:dataString];
        //事件名称
        NSString *eventName = [[dic objectForKey:@"event_name"] objectForKey:@"gson_fix"];
        //事件的参数
        NSDictionary *paramDic = [dic objectForKey:@"value"];
        //2 使用友盟进行统计
        [MobClick event:eventName attributes:paramDic];
        
        });
    }];
    
    
    
}

#pragma mark 用户数据接口用到的方法
//将获取到的数组转成指定格式的数组
- (NSArray*)getUserDataFromDBWithDictionary:(NSDictionary *)userDataDic andUserId:(NSString *)userId {
    UserRecordDataManager *userRecordManager = [UserRecordDataManager instance];
    //1 获取数据库中的记录
    NSArray *userDataMetaArray  = [userRecordManager getUserDataWithDictionary:userDataDic andUserId:userId];
    
    //2 组装成指定格式的JSON
    NSMutableArray *userDatas = [[NSMutableArray alloc] init];
    if (userDataMetaArray == nil || userDataMetaArray.count <= 0) {
        //直接返回
        return nil;
    }
    
    
    for (id objc in userDataMetaArray) {
        if (objc == nil) {
            continue;
        }
        NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
        UserDataMeta *tempMeta = (UserDataMeta *)objc;
        [tempDic setValue:tempMeta.k1 forKey:@"k1"];
        [tempDic setValue:tempMeta.k2 forKey:@"k2"];
        [tempDic setValue:tempMeta.k3 forKey:@"k3"];
        [tempDic setValue:tempMeta.k4 forKey:@"k4"];
        [tempDic setValue:tempMeta.k5 forKey:@"k5"];
        [tempDic setValue:tempMeta.type forKey:@"type"];
        [tempDic setValue:tempMeta.value forKey:@"value"];
        //创建时间
        NSString *createTimeStr = [NSString stringWithFormat:@"%lld",(long long)[tempMeta.createTime timeIntervalSince1970]];
        [tempDic setValue:createTimeStr forKey:@"create_time"];
        //更新时间
        NSString *updateTimeStr = [NSString stringWithFormat:@"%lld",(long long)[tempMeta.updateTime timeIntervalSince1970]];
        [tempDic setValue:updateTimeStr forKey:@"update_time"];
        if (tempDic != nil) {
            [userDatas addObject:tempDic];
        }
        
        
    }
    //3 返回结果
    if (userDatas == nil || userDatas.count <= 0) {
        return  nil;
    }
    return userDatas;
    
}



#pragma mark goBack 接口调用的方法

- (void)goBack:(NSDictionary *)backDictionary {
	//由nav管理的页面之间的跳转只能由对应的NAV来管理,所以解决办法是
	//判断回去的方式
	NSString *closeAnimation = [backDictionary objectForKey:@"close_animate"];
	if (closeAnimation == nil || closeAnimation.length <= 0) { //返回动画要求为空
		if ([self.lastPage isEqualToString:@"BooKDetailPage"]) {
			//bookId 一定可以在这个实例中获取到
			if (self.needCheckBookId == nil || self.needCheckBookId.length <= 0) {
				//没有开始下载书籍,则直接返回
				[self.navigationController popViewControllerAnimated:YES];
			}
			else {//有对应的bookid，需要从数据库中获取到对应的数据状态
				NSDictionary *bookInfoDic = [self getDicFormDataBase:self.needCheckBookId];
				NSString *bookStatus = [bookInfoDic objectForKey:@"book_status"];
				/*if ([bookStatus isEqualToString:@"下载中"]== YES  || [bookStatus isEqualToString:@"解压中"]== YES || [bookStatus isEqualToString:@"校验中"]== YES || [bookStatus isEqualToString:@"应用中"]== YES  ) {
				    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"下载提示" message:@"数据正在下载中，确定要结束下载" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
				    [alert show];
				   }
				   else*/{
					[self.navigationController popViewControllerAnimated:YES];
				}
			}
		}
		else {
			[self.navigationController popViewControllerAnimated:YES];
		}



		if (self.controller != nil) {
			self.controller = nil;
		}
		if (self.webView != nil) {
			self.webView = nil;
		}
		if (self.mainControllerView != nil) {
			self.mainControllerView = nil;
		}
	}
	else {//返回动画不为空
		CATransition *animation = [self customAnimation:closeAnimation];
		[self.navigationController.view.layer addAnimation:animation forKey:nil];
		[self.navigationController popViewControllerAnimated:NO];

		if (self.controller != nil) {
			self.controller = nil;
		}
		if (self.webView != nil) {
			self.webView = nil;
		}
		if (self.mainControllerView != nil) {
			self.mainControllerView = nil;
		}
	}
}

#pragma mark 设置动画的效果
//设置自定义的动画效果
- (CATransition *)customAnimation:(NSString *)openAnimation {
	//根据JS传的参数来设置动画的切入，出方向。
	CATransition *animation = [CATransition animation];
	[animation setDuration:1];
	[animation setType:kCATransitionPush]; //设置为推入效果
	if ([openAnimation isEqualToString:@"pull_left_out"] || [openAnimation isEqualToString:@"push_right_in"]) {
		[animation setSubtype:kCATransitionFromRight]; //设置方向
	}
	else if ([openAnimation isEqualToString:@"pull_right_out"] || [openAnimation isEqualToString:@"push_left_in"]) {
		[animation setSubtype:kCATransitionFromLeft]; //设置方向
	}
	else if ([openAnimation isEqualToString:@"push_bottom_in"]) {
		[animation setSubtype:kCATransitionFromBottom]; //从底部推入
	}
	else if ([openAnimation isEqualToString:@"pull_bottom_out"]) {
		[animation setSubtype:kCATransitionFromTop];  //从顶部推入
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

		// 加载指定的html文件 --
        //单词--新修改的
        NSURL *url = [[NSURL alloc] initFileURLWithPath:[NSString stringWithFormat:@"%@/%@/%@%@", htmlFilePath,@"render", page_type, @".html"]];
        
        
		NSString *urlStrWithParams = nil;
		//        NSString *args = dic[@"getArgs"];
		NSString *args = dic[@"get_args"];

		if (args != nil && args.length > 0) {

            //单词--新修改的
            urlStrWithParams = [NSString stringWithFormat:@"%@%@", [url absoluteString], args];
            
            
		}
		else {
			urlStrWithParams = [NSString stringWithFormat:@"%@", [url absoluteString]];
		}

		NSURL *urlWithParams = [[NSURL alloc] initWithString:urlStrWithParams];

		[self.webView loadRequest:[[NSURLRequest alloc] initWithURL:urlWithParams]];
		//在当前页面渲染时，若是需要横屏，则横屏
		if ([orientation isEqualToString:@"landscape"]) {
			CGAffineTransform transform = CGAffineTransformIdentity;
			transform = CGAffineTransformRotate(transform, M_PI / 2);
			self.mainControllerView.transform = transform;//在这里可以实现横屏
		}


		return YES;
	}
	else {
		if ([target isEqualToString:@"activity"]) {
			NSString *book_id = dic[@"book_id"];

			NSString *htmlFilePath = [[KnowledgeManager instance] getPagePath:book_id];
			if (htmlFilePath == nil || htmlFilePath.length <= 0) {
				return NO;
			}
			NSString *page_type = dic[@"page_type"];

			// 加载指定的html文件
			NSString *urlStr = [NSString stringWithFormat:@"%@/%@/%@%@", htmlFilePath, @"render", page_type, @".html"];

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
	if (openAnimation == nil || openAnimation.length <= 0) { //
//        [self.navigationController pushViewController:scanQrcodeViewController animated:YES];
		//设置默认的打开动画 -- 解决：二维码扫描时，扫描controller中动画未加载完的情况下，就进入到下个controller中，出现界面卡死的问题。
		NSString *defaultOpenAnimaytion = @"push_right_in";
		CATransition *animation = [self customAnimation:defaultOpenAnimaytion];
		[self.navigationController.view.layer addAnimation:animation forKey:nil];
		[self.navigationController pushViewController:scanQrcodeViewController animated:NO];
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
 * FirstReuseViewController、SecondReuseViewController。看书过程之间的复用，跳转在两个controller中进行
 * RenderKnowledgeViewController、SecondRenderKnowledgeViewController。除看书的内容外，所有的页面跳转，复用都在这两个controller中进行。
 */

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

- (void)movieFinishedCallback:(NSNotification *)aNotification {
	MPMoviePlayerController *playerViewController = [aNotification object];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:playerViewController];
	[playerViewController stop];

	//    [self dismissMoviePlayerViewControllerAnimated];

	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 分享
- (void)share:(NSDictionary *)shareDic {
	//title
	NSString *titleAll = [shareDic objectForKey:@"title"];
	//分享链接
	NSString *callBackUrl = [shareDic objectForKey:@"target_url"];
	//    NSURL *weburl=[NSURL URLWithString:urlString];
	//分享的图片链接
	NSString *imageString = [shareDic objectForKey:@"img_url"];
	//是否截屏
	//    BOOL shouldScreen_shot=(BOOL)[shareDic objectForKey:@"screen_shot"];
	//微信使用的url
	NSString *weixinImageUrl = [shareDic objectForKey:@"image_url"];
	//分享内容
	NSString *shareString = [shareDic objectForKey:@"content"];

	//2.0 分享到新浪微博
	[[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeImage url:weixinImageUrl];
	[UMSocialData defaultData].extConfig.sinaData.shareText = shareString;


	//2.0 share to wechatTimeline only
	//4、设置微信朋友圈的分享的URL图片
	[[UMSocialData defaultData].extConfig.wechatTimelineData.urlResource setResourceType:UMSocialUrlResourceTypeImage url:weixinImageUrl];
	//设置微信朋友圈的分享文字
	[UMSocialData defaultData].extConfig.wechatTimelineData.shareText = shareString;
	//
	[UMSocialData defaultData].extConfig.wechatTimelineData.url = callBackUrl;

	//
	[UMSocialSnsService presentSnsIconSheetView:self.controller appKey:@"543dea72fd98c5fc98004e08" shareText:shareString shareImage:nil shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatTimeline, UMShareToSina, nil] delegate:nil];//UMShareToWechatSession
	//
}

#pragma mark change back ground
- (void)changeBackgourndColorWithColor:(NSString *)colorString {
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
    for (KnowledgeMeta *knowledgeMeta in bookArr) {
        if (knowledgeMeta == nil) {
            continue;
        }
        
        NSString *dicBookId = knowledgeMeta.dataId;
        int bookStatusInt = (int)knowledgeMeta.dataStatus;
//	for (NSManagedObject *entity in bookArr) {
//		if (entity == nil) {
//			continue;
//		}
//        
//		NSString *dicBookId = [entity valueForKey:@"dataId"];
//		NSNumber *dicBookStatusNum = [entity valueForKey:@"dataStatus"];
//		int bookStatusInt = [dicBookStatusNum intValue];

		//获取数据的更新状态，在调用startDownload接口时，判断本地是否有数据，若有将update_status改为有更新。
		NSString *bookStatusStr = nil;
		NSString *updateStatus = nil;
		NSString *bookAvail = nil;
		//修改接口后多加的操作
		/*
		   处理流程：
		   判断沙盒中bookID对应的书籍是否存在，根据是否存本地书籍确定Updata_status的字段
		 */
		NSString *knowledgeDataInDocument = [[Config instance] knowledgeDataConfig].knowledgeDataRootPathInDocuments;
		NSString *bookPath = [NSString stringWithFormat:@"%@/%@", knowledgeDataInDocument, bookId];
		//获取book_avail
		BOOL isAvail = [[KnowledgeDataManager instance] checkIsAvailableWithFilePath:bookPath];

		if (bookStatusInt == 0) {
			bookStatusStr = @"未下载";
			if (isAvail) {
				updateStatus = @"有更新";
			}
			else {
				updateStatus = @"无更新";
			}
		}
		else if (bookStatusInt >= 1 && bookStatusInt <= 3) {
			bookStatusStr = @"下载中";
			if (isAvail) {
				updateStatus = @"有更新";
			}
			else {
				updateStatus = @"无更新";
			}
		}
		else if (bookStatusInt == 7) {//检测到有更新
			updateStatus = @"有更新";//有更新肯定数据库中是有数据的
			bookStatusStr = @"完成";
		}
		else if (bookStatusInt == 8 || bookStatusInt == 9) {
			//            bookStatusStr = @"更新中";
			if (isAvail) {
				updateStatus = @"有更新";
			}
			else {
				updateStatus = @"无更新";
			}
		}
		else if (bookStatusInt == 10) {
			bookStatusStr = @"完成";
			updateStatus = @"无更新";
		}
		else if (bookStatusInt == 11) {
			bookStatusStr = @"完成";
			updateStatus = @"有更新但APP版本过低";
		}
		else if (bookStatusInt == 12) {
			bookStatusStr = @"完成";
			updateStatus = @"有更新APP版本过高";
		}
		else if (bookStatusInt == 14) {
			bookStatusStr = @"下载失败";
			if (isAvail) {
				updateStatus = @"有更新";
			}
			else {
				updateStatus = @"无更新";
			}
		}
		else if (bookStatusInt == 15) {
			bookStatusStr = @"下载暂停";
			if (isAvail) {
				updateStatus = @"有更新";
			}
			else {
				updateStatus = @"无更新";
			}
		}
		else if (bookStatusInt == -1) {
			bookStatusStr = @"未下载";
		}
		else if (bookStatusInt >= 4 && bookStatusInt <= 6) {
			bookStatusStr = @"解压中";
			if (isAvail) {
				updateStatus = @"有更新";
			}
			else {
				updateStatus = @"无更新";
			}
		}
		else if (bookStatusInt == 18) {
			bookStatusStr = @"解压失败";
			if (isAvail) {
				updateStatus = @"有更新";
			}
			else {
				updateStatus = @"无更新";
			}
		}
		else if (bookStatusInt == 19) {
			bookStatusStr = @"校验中";
			if (isAvail) {
				updateStatus = @"有更新";
			}
			else {
				updateStatus = @"无更新";
			}
		}
		else if (bookStatusInt == 20) {
			bookStatusStr = @"校验失败";
			if (isAvail) {
				updateStatus = @"有更新";
			}
			else {
				updateStatus = @"无更新";
			}
		}
		else if (bookStatusInt == 17) {
			bookStatusStr = @"应用中";
			if (isAvail) {
				updateStatus = @"有更新";
			}
			else {
				updateStatus = @"无更新";
			}
		}
		else if (bookStatusInt == 16) {
			bookStatusStr = @"应用失败";
			if (isAvail) {
				updateStatus = @"有更新";
			}
			else {
				updateStatus = @"无更新";
			}
		}

		NSString *completeString = [NSUserDefaultUtil getMoveCompleteString];
		//获取update_status
		if (isAvail && [completeString isEqualToString:@"completed"] == YES) {
			bookAvail = @"1";
			[NSUserDefaultUtil removeMoveCompleteString];
		}
		else {
			bookAvail = @"0";
		}

		NSLog(@"书籍可用状态===%@，bookStatus====%@", bookAvail, bookStatusStr);
        NSString *dicBookStatusDetails = knowledgeMeta.dataStatusDesc;
        
//		NSString *dicBookStatusDetails = [entity valueForKey:@"dataStatusDesc"];
		//将浮点型转换成integer型，再转换成字符串类型
		NSString *downLoadProgressStr = nil;
		CGFloat downLoadProgressFloat = [dicBookStatusDetails floatValue];
		if (downLoadProgressFloat == 100) {
			downLoadProgressStr = [NSString stringWithFormat:@"%@", @"100"];
		}
		else {
			NSInteger downLoadProgress = (NSInteger)(downLoadProgressFloat * 100);
			downLoadProgressStr = [NSString stringWithFormat:@"%ld", (long)downLoadProgress];
		}
		//获取封面图片的URL
        NSString *bookCover = knowledgeMeta.coverSrc;
//		NSString *bookCover = [entity valueForKey:@"coverSrc"];
		NSString *documentPath = [PathUtil getDocumentsPath];
		NSString *coverImagePathStr = [NSString stringWithFormat:@"%@/%@", documentPath, bookCover];


		//构造字典
		[dic setValue:dicBookId forKey:@"book_id"];
		[dic setValue:bookStatusStr forKey:@"book_status"];
		[dic setValue:updateStatus forKey:@"update_status"];
		[dic setValue:bookAvail forKey:@"book_avail"];
		[dic setValue:downLoadProgressStr forKey:@"book_status_detail"];
		//新加一个字段book_cover
		[dic setValue:coverImagePathStr forKey:@"book_cover"];
	}

	return dic;
}

#pragma mark 获取封面图片调用的接口

- (NSString *)getCoverImageFilePath:(NSString *)dataId {
	//从db中获取书分封面图片信息不能限定dataType
	NSArray *bookArr = [[KnowledgeMetaManager instance] getKnowledgeMetaWithDataId:dataId andDataType:DATA_TYPE_DATA_SOURCE];
	//    NSArray *bookArr = [[KnowledgeMetaManager instance] getKnowledgeMetaWithDataId:dataId];
	NSString *coverSrc = nil;
    for (KnowledgeMeta *knowledgeMeta in bookArr) {
        if (knowledgeMeta != nil) {
            coverSrc = knowledgeMeta.coverSrc;
            break;
        }

//	for (NSManagedObject *entity in bookArr) {
//		if (entity == nil) {
//			continue;
//		}
//		coverSrc = [entity valueForKey:@"coverSrc"];
	}
	return coverSrc;
}

#pragma mark app内设置页面的接口
//go to apple  App Store
- (void)gotoAppStoreWithAppId:(NSString *)appId {
	NSString *str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", appId];//appID
	NSLog(@"评论页面的URL = %@", str);
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}

#pragma mark 打开相机 调用相册的方法
//代理指定的self（而不是self.controller，因为UINavigationControllerDelegate,UIImagePickerControllerDelegate是在这里面遵守）
//延迟调用camera
- (void)openCameraDelaied {
	[self performSelector:@selector(showcamera) withObject:nil afterDelay:0.3];
}

//打开相机
- (void)showcamera {
	UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
	if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	}
	UIImagePickerController *picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
	picker.allowsEditing = YES;
	picker.sourceType = sourceType;
	[self.controller presentViewController:picker animated:YES completion:nil];//进入照相机界面
}

//打开相册
- (void)openPhotoLibrary {
	UIImagePickerController *pickerImage = [[UIImagePickerController alloc] init];
	//iphone
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
			pickerImage.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			//pickerImage.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
			pickerImage.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:pickerImage.sourceType];
		}
		pickerImage.delegate = self;
		pickerImage.allowsEditing = YES;
		[self.controller presentViewController:pickerImage animated:YES completion:nil];
	}
	else {
		//ipad
		if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
			UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			//sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum; //保存的相片
			pickerImage.delegate = self;
			pickerImage.allowsEditing = YES;//是否允许编辑
			pickerImage.sourceType = sourceType;
			[self.controller presentViewController:pickerImage animated:YES completion:nil];
		}
	}
}

//点击相册中的图片或者照完相之后，（点击use后或在允许编辑的状态下选中选取按钮后）会调用的代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	//得到选择的图片
	UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
	if (!image) {
		//从（相册中）取图片
		image = [info objectForKey:UIImagePickerControllerOriginalImage];
	}
	//保存到相册中
	UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);

	//手动压缩图片

	//使用base64编码image
	NSData *imageData = UIImageJPEGRepresentation(image, 0.4);
	/*
	   NSData *imageDataFirst = UIImageJPEGRepresentation(image, 1);
	   UIImage *originalImage = [UIImage imageWithData:imageDataFirst];
	   UIImage *needImage = [self makeThumbnailFromImage:originalImage scale:0.5];
	   NSData *imageData = UIImageJPEGRepresentation(needImage, 0.3);
	   NSLog(@"图片的长度是========%lu",(unsigned long)imageData.length);
	 */
	//利用base64向HTML中添加插入图片需要在base64图片中插入前缀，否则不显示图片。
	NSString *base64ImageString = [imageData base64EncodedStringWithOptions:0];
	NSString *resultString = [NSString stringWithFormat:@"%@%@", @"data:image/png;base64, ", base64ImageString];
	self.imageString = resultString;
	self.upLoadData = imageData;



	//回调
	if (self.imageString == nil || self.imageString.length <= 0) {
		[self nativeCallHandleWithCallId:self.callIdString andErrorCode:@"1" andErrorMessage:@"图片文件不存在" andImageStr:self.imageString];
	}
	else {
		[self nativeCallHandleWithCallId:self.callIdString andErrorCode:@"0" andErrorMessage:nil andImageStr:self.imageString];
	}
	//关闭相册
	[self.controller dismissViewControllerAnimated:YES completion:nil];
}

//不是imagePickerController的代理方法，是自己定义的方法，用来检测是否保存成功。
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
	if (error) {
		LogError(@"error info : %@", [error localizedDescription]);
	}
	else {
		//nil时保存成功
	}
}

//点击取消的代理方法
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	//取消时的处理，相当于选择图片成功
	[self nativeCallHandleWithCallId:self.callIdString andErrorCode:@"0" andErrorMessage:nil andImageStr:@""];

	//退出相机界面
	[self.controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark 上传图片的方法
- (BOOL)upLoadImageWithTokenString:(NSString *)token {
	if (token == nil || token.length <= 0) {
		LogWarn(@"[WebViewBridgeRegisterUtil - upLoadImageWithTokenString] upload image file failed , token string is nil");
	}
	//在选择图片时若是取消选择图片，应该能能够上传，不能拦截
//    if (self.imageString == nil || self.imageString.length <= 0) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您未选择将要上传的图片，请选择后再上传" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
//        [alert show];
//        return NO;
//    }
	//拼接parameter参数
	NSString *tokenStr = token;
	//upload url
	NSString *uploadUrl = @"http://upload.qiniu.com/";
	//upload
	UpLoadUtil *upload = [[UpLoadUtil alloc] init];
	upload.uploadDelegte = self;
//    self.upLoadSuccess = [upload upLoadImage:self.upLoadData andToken:tokenStr toUploadUrl:uploadUrl];
	self.upLoadSuccess = [upload upoadImageWithImageData:self.upLoadData andToken:tokenStr uploadUrl:uploadUrl];
	return self.upLoadSuccess;
}

#pragma mark uploadUtil delegate method
- (void)uploadSuccess {
	[self nativeCallHandleWithCallId:self.uploadCallId andErrorCode:@"0" andErrorMessage:nil];    //上传成功
}

- (void)uploadFailedWithError:(NSError *)error {
	NSString *errorCode = [NSString stringWithFormat:@"%ld", (long)error.code];
	[self nativeCallHandleWithCallId:self.uploadCallId andErrorCode:errorCode andErrorMessage:error.localizedDescription];//上传失败
}

#pragma mark native 调用 JS 的方法
- (void)nativeCallHandleWithCallId:(NSString *)callId andErrorCode:(NSString *)errorCode andErrorMessage:(NSString *)errorMessage andImageStr:(NSString *)imageString {
	NSString *jsStr = [NSString stringWithFormat:@"onGetImageFinish('%@','%@','%@','%@')", callId, errorCode, @"", imageString];
	[self.webView stringByEvaluatingJavaScriptFromString:jsStr];
}

//上传图片回调JS函数的方法
- (void)nativeCallHandleWithCallId:(NSString *)callId andErrorCode:(NSString *)errorCode andErrorMessage:(NSString *)errorMessage {
	NSString *jsMyAlert = [NSString stringWithFormat:@"setTimeout(function(){onUploadImageFinish('%@','%@','%@')}, 1);", callId, errorCode, errorMessage];
	[self.webView stringByEvaluatingJavaScriptFromString:jsMyAlert];
}

//2.0 解决下载过程中下载失败时，页面获取下载状态同native修改下载状态不同步的问题
- (BOOL)updateDownloadStatusWithDataId:(NSString *)dataId {
	//1 获取dataId对应的数据的状态
	NSArray *bookArr = [[KnowledgeMetaManager instance] getKnowledgeMetaWithDataId:dataId andDataType:DATA_TYPE_DATA_SOURCE];
	if (bookArr == nil || bookArr.count <= 0) {
		//调用startDownLoad接口时，数据库中这时一定是有dataId对应的数据
		return NO;
	}
	//2 获取dataId对应的数据的状态
    for (KnowledgeMeta *knowledgeMeta in bookArr) {
//	for (id obj in bookArr) {
////        KnowledgeMeta *knowledgeMeta = (KnowledgeMeta *)obj;
//		KnowledgeMeta *knowledgeMeta = [KnowledgeMeta fromKnowledgeMetaEntity:obj];
		if (knowledgeMeta == nil) {
			continue;
		}
		//3 判断数据状态，并修改为下载中
//        if ((DataStatus)knowledgeMeta.dataStatus == DATA_STATUS_DOWNLOAD_FAILED || (DataStatus)knowledgeMeta.dataStatus == DATA_STATUS_DOWNLOAD_PAUSE) {
		//修改下载状态未下载中
		return [[KnowledgeMetaManager instance] setDataStatusTo:DATA_STATUS_DOWNLOAD_IN_PROGRESS andDataStatusDescTo:@"0" forDataWithDataId:dataId andType:DATA_TYPE_DATA_SOURCE];

//        }
	}




	return YES;
}

#pragma mark 删除本地书籍

- (BOOL)removeLocalBookWithBookIds:(NSArray *)bookIds {
	for (NSString *bookId in bookIds) {
		//遍历数组，从数据库中查找相应的信息，并判断数据状态
		if (bookId == nil || bookId.length <= 0) {
			continue;
		}
		NSArray *bookMetaArray = [[KnowledgeMetaManager instance] getKnowledgeMetaWithDataId:bookId andDataType:DATA_TYPE_UNKNOWN];
        for (KnowledgeMeta *knowledgeMeta in bookMetaArray) {
            if (knowledgeMeta == nil) {
                continue;
            }
            
            NSNumber *dicBookStatusNum = [NSNumber numberWithInt:(int)knowledgeMeta.dataStatus];
//		for (NSManagedObject *entity in bookMetaArray) {
//			if (entity == nil) {
//				continue;
//			}
//			NSNumber *dicBookStatusNum = [entity valueForKey:@"dataStatus"];
        
			int bookStatusInt = [dicBookStatusNum intValue];
			NSString *bookStatusStr = nil;
			if (bookStatusInt >= 1 && bookStatusInt <= 3) {
				bookStatusStr = @"下载中";
			}
			else if (bookStatusInt == 7) {
				bookStatusStr = @"可更新";
			}
			else if (bookStatusInt == 8 || bookStatusInt == 9) {
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

			//1 根据数据状态,删除数据信息
			if ([bookStatusStr isEqualToString:@"完成"] == YES || [bookStatusStr isEqualToString:@"未下载"] == YES || [bookStatusStr isEqualToString:@"下载失败"] == YES || [bookStatusStr isEqualToString:@"可更新"]) {
				BOOL isRemoveFromDataBase = [[KnowledgeMetaManager instance] deleteKnowledgeMetaWithDataId:bookId andDataType:DATA_TYPE_UNKNOWN];
				if (!isRemoveFromDataBase) {
					LogWarn(@"[WebviewBridgeRegisterUtil - removeLocalBookWithBookIds] remove local bookmeta info  failed");
//                    return NO;//只要有一本删除失败，暂定为返回删除成功
				}
			}
            
			//2 删除沙盒目录下的文件
			NSString *knowledgeDataInDocument = [[Config instance] knowledgeDataConfig].knowledgeDataRootPathInDocuments;
			NSString *needDeleteBookPath = [NSString stringWithFormat:@"%@/%@", knowledgeDataInDocument, bookId];
			BOOL needDeleteBookExist = [[NSFileManager defaultManager] fileExistsAtPath:needDeleteBookPath];
			if (!needDeleteBookExist) {//需要删除的数据文件不存在,不需要做处理，直接返回
				continue;
			}
			NSError *deletePartialError;
			BOOL deleteBookFileSuccess = [[NSFileManager defaultManager] removeItemAtPath:needDeleteBookPath error:&deletePartialError];
			if (!deleteBookFileSuccess) {//删除本地文件失败，提示
				LogError(@"[KnowledgeDataManager - processDownloadedDataPack]: delete book file failed with errorInfo %@", deletePartialError.localizedDescription);
				//只要数据库中的信息成功清除，本地数据没有删除,返回成功下次
				return NO;//
			}
		}
	}
	return YES;
}

#pragma mark 手动压缩图片
//对图片尺寸进行压缩

- (UIImage *)makeThumbnailFromImage:(UIImage *)srcImage scale:(double)imageScale {
	UIImage *thumbnail = nil;
	CGSize imageSize = CGSizeMake(srcImage.size.width * imageScale, srcImage.size.height * imageScale);
	if (srcImage.size.width != imageSize.width || srcImage.size.height != imageSize.height) {
		UIGraphicsBeginImageContext(imageSize);
		CGRect imageRect = CGRectMake(0.0, 0.0, imageSize.width, imageSize.height);
		[srcImage drawInRect:imageRect];
		thumbnail = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
	}
	else {
		thumbnail = srcImage;
	}
	return thumbnail;
}

#pragma mark alertView delegate method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex != alertView.cancelButtonIndex) {
		//点击了确定按钮时会触发的代理
		//1 停止下载 2 是否要删除数据 3 退出当前页面
		BOOL stop = [[KnowledgeDataManager instance] stopDownloadData:self.needCheckBookId];
	}
}

@end
