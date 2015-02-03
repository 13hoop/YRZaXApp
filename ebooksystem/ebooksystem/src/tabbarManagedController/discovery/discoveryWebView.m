//
//  discoveryWebView.m
//  ebooksystem
//
//  Created by wanghaoyu on 15/1/25.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import "discoveryWebView.h"

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
#import "MatchViewController.h"
#import "discoveryModel.h"



@interface discoveryWebView()<UIWebViewDelegate>

// bridge between webview and js
@property (nonatomic, strong) WebViewJavascriptBridge *javascriptBridge;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic,strong) NSString *oldUserAgent;
@end


@implementation discoveryWebView

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


- (UIWebView *)webView {
    if (_webView == nil) {
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _webView.delegate = self;
        
        [self addSubview:_webView];
    }
    
    return _webView;
}

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


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//        self.userInteractionEnabled = YES;
        [self initWebView];

        
    }
    return self;
}
- (void)drawRect:(CGRect)rect {
    [self updateWebView];
}

- (BOOL)initWebView {
    //    self.webView.delegate = self.javascriptBridge;
    
    // goback()
    [self.javascriptBridge registerHandler:@"goBack" handler:^(id data, WVJBResponseCallback responseCallback) {
        LogDebug(@"discoveryWebView::goBack() called: %@", data);
        
        //到controller中切换视图
        [self.discoverDelegate controllerSwitchOver];
    }];
    
    [self.javascriptBridge registerHandler:@"share" handler:^(id data, WVJBResponseCallback responseCallback) {
        LogDebug(@"discoveryWebView::share() called: %@", data);
        
        NSDictionary *shareDic = (NSDictionary *)data;
        
        [self share:shareDic];
    }];
    
    // playVideo()
    [self.javascriptBridge registerHandler:@"playVideo" handler:^(id dataId, WVJBResponseCallback responseCallback) {
        LogDebug(@"discoveryWebView::playVideo() called: %@", dataId);
        
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
        LogDebug(@"discoveryWebView::getData() called: %@", data);
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
                //                SBJsonParser *parse = [[SBJsonParser alloc] init];
                //                id objc = [parse objectWithString:dataStr];
                //                SBJsonWriter *writer = [[SBJsonWriter alloc] init];
                //                data = [writer stringWithObject:objc];
                //                NSLog(@"data====%@",data);
                break;
            }
            responseCallback(data);
        }
    }];
    
    
    
    //renderPage   *******       ********
    [self.javascriptBridge registerHandler:@"renderPage" handler:^(id data,WVJBResponseCallback responseCallback){
        LogDebug(@"discoveryWebView::renderPage() called: %@", data);
        SBJsonParser *parse = [[SBJsonParser alloc] init];
        NSDictionary *dic = [parse objectWithString:data];
        [self showPageWithDictionary:dic];
        
    }];
    //getCurStudyType
    [self.javascriptBridge registerHandler:@"getCurStudyType" handler:^(id data ,WVJBResponseCallback responseCallback){
        //在nsuserDefault中设置一个curStudyType字段，用来存储当前用户的学习状态
        LogDebug(@"discoveryWebView::getCurStudyType() called: %@", data);
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
        LogDebug(@"discoveryWebView::setCurStudyType() called: %@", data);
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
            LogError(@"discoveryWebView::setCurStudyType() failed because of curStudyType is equal to nil");
            NSString *data = @"0";
            responseCallback(data);//失败返回0；
        }
        
    }];
    
    //getBookList
    [self.javascriptBridge registerHandler:@"getBookList" handler:^(id data,WVJBResponseCallback responseCallback){
        LogDebug(@"discoveryWebView::getBookList() called: %@", data);
        NSString *book_category = data;//值：0，1
        //根据book_category遍历数据库，将数据拼成json格式返回给JS。（具体操作：1、就是根据book_category做遍历数据库的操作 2、book_status ：下载过程中用的download_Status字段（下载成功，下载失败，下载中）也是修改这个字段。）
        NSLog(@"调用getBooklist了，js注入成功了");
//        [self justForTest];
        //        [self justForMoreDownloadTest];
        NSString *string = [self fileToJsonString];
        if (responseCallback != nil) {
            responseCallback(string);
        }
        
        
        
    }];
    
    //checkUpdate
    [self.javascriptBridge registerHandler:@"checkUpdate" handler:^(id data,WVJBResponseCallback responseCallback){
        LogDebug(@"discoveryWebView::checkUpdate() called: %@", data);
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
        LogDebug(@"discoveryWebView::startDownload() called: %@", data);
        [self output];
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
        LogDebug(@"discoveryWebView::startDownload() called: %@", data);
        
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
            //根据book_id从数据库中去相应的状态
            NSMutableDictionary *dic = [self getDicFormDataBase:bookId];
            [booksArray addObject:dic];
        }
        SBJsonWriter *writer = [[SBJsonWriter alloc] init];
        NSString *jsonStr = [writer stringWithObject:booksArray];
        if (responseCallback != nil) {
            responseCallback(jsonStr);
        }
        
        
        
    }];
    //goUserSettingPage
    [self.javascriptBridge registerHandler:@"goUserSettingPage" handler:^(id data, WVJBResponseCallback responseCallback) {
        //跳转到设置页面
    }];
    //goDiscoverPage
    [self.javascriptBridge registerHandler:@"goDiscoverPage" handler:^(id data, WVJBResponseCallback responseCallback) {
        //跳转到发现页
    }];
    //getCoverSrc
    [self.javascriptBridge registerHandler:@"getCoverSrc" handler:^(id data, WVJBResponseCallback responseCallback) {
        //获取封面
        NSString *book_id = data;
        if (responseCallback != nil) {
            NSString *imageStr = [self getImage];
            responseCallback(imageStr);
        }
        //
    }];
    //showURL
    [self.javascriptBridge registerHandler:@"showURL" handler:^(id data, WVJBResponseCallback responseCallback) {
        //
        NSString *dataStr = data;
        SBJsonParser *parse = [[SBJsonParser alloc] init];
        NSDictionary *dic = [parse objectWithString:dataStr];
        if ([[dic objectForKey:@"target"] isEqualToString:@"activity"]) {
            [self showSafeURL:[dic objectForKey:@"url"]];
        }
        else
        {
            NSString *urlStr = [dic objectForKey:@"url"];
            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
        }
        
    }];
    //addToNative
    [self.javascriptBridge registerHandler:@"addToNative" handler:^(id data, WVJBResponseCallback responseCallback) {
        //
        NSString *bookID = data;
        if (responseCallback != nil) {
            //直接调model中的方法
            discoveryModel *model = [[discoveryModel alloc] init];
            NSArray *arr = [NSArray arrayWithObjects:bookID, nil];
            [model getBookInfoWithDataIds:arr];
        }
        //返回值给JS
    }];
    
    /*
        先调queryBookStatus,获取该本书的状态，若是已经下载过，则直接打开，若是没有下载
        再调addtonative接口，将meta数据保存到数据库中，并讲试读书下载到本地，并打开。
     */
    
    return YES;
}


#pragma mark 2.0调用的接口
//2.0中跳转到指定页面
- (BOOL)showPageWithDictionary:(NSDictionary *)dic {
    NSString *target = dic[@"target"];
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
        NSString *args = dic[@"get_args"];
        
        
        if (args != nil && args.length > 0) {
            urlStrWithParams = [NSString stringWithFormat:@"%@?%@", [url absoluteString], args];
        }
        else {
            urlStrWithParams = [NSString stringWithFormat:@"%@", [url absoluteString]];
        }
        
        NSURL *urlWithParams = [[NSURL alloc] initWithString:urlStrWithParams];
        
        [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:urlWithParams]];
        
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
            //打开新的controller
            return [self showSafeURL:urlStrWithParams];
            
        }
    }
    
    return YES;
    
}



//makeUI

- (void)updateWebView {
    NSString *webUrlStr = @"http://test.zaxue100.com/index.php?c=discovery_ctrl&m=index";
//    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",webUrlStr]]]];
    self.webView.scrollView.bounces = NO;
    self.webView.scrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:self.webView];
}


- (BOOL)showSafeURL:(NSString *)urlStr {
    //视图切换到controller中
    [self.discoverDelegate showSafeUrl:urlStr];
    return YES;
}



#pragma mark - share

- (void)share:(NSDictionary *)shareDic {
    /*
     url :
     img_url :
     weixin_img_url :
     title :
     content :
     screen_shot : false
     */
    //title
    NSString *titleAll=[shareDic objectForKey:@"title"];
    //分享链接
    NSString *callBackUrl=[shareDic objectForKey:@"url"];
    //    NSURL *weburl=[NSURL URLWithString:urlString];
    //分享的图片链接
    NSString *imageString=[shareDic objectForKey:@"img_url"];
    //是否截屏
    BOOL shouldScreen_shot=(BOOL)[shareDic objectForKey:@"screen_shot"];
    //微信使用的url
    NSString *weixinImageUrl=[shareDic objectForKey:@"weixin_img_url"];
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
    
    
    //4、设置微信朋友圈的分享的URL图片
    [[UMSocialData defaultData].extConfig.wechatTimelineData.urlResource setResourceType:UMSocialUrlResourceTypeImage url:weixinImageUrl];
    //设置微信朋友圈的分享文字
    [UMSocialData defaultData].extConfig.wechatTimelineData.shareText=shareString;
    //
    [UMSocialData defaultData].extConfig.wechatTimelineData.url=callBackUrl;
    
    [UMSocialSnsService presentSnsIconSheetView:self appKey:@"543dea72fd98c5fc98004e08" shareText:shareString shareImage:nil shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatSession,UMShareToWechatTimeline,UMShareToQzone,UMShareToQQ,nil] delegate:nil];
}

#pragma mark - play video
// 播放视频
- (void)playVideo:(NSString *)urlStr {
}

#pragma mark - web view delegate methods

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (request) {
        LogDebug(@"[RenderKnowledgeViewController] Web request: UA: %@", [request valueForHTTPHeaderField:@"User-Agent"]);
    }
//    [self injectJSToWebView:webView];
    NSLog(@" url === %@",request.URL);
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self injectJSToWebView:webView];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
//    [self injectJSToWebView:webView];
}
#pragma mark - js injection

- (void)injectJSToWebView:(UIWebView *)webView {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"webview-js-bridge" ofType:@"js"];
    NSString *jsString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    [webView stringByEvaluatingJavaScriptFromString:jsString];
}

#pragma mark - set User Agent

- (BOOL)checkUserAgent {
    return [WebUtil checkUserAgent];
}


#pragma test changeColor
-(void)changeBackgourndColorWithColor:(NSString *)colorString
{
    self.backgroundColor = [UIColor colorWithHexString:colorString alpha:1];
}

#pragma  get session
- (void)checkCookie {
    [OperateCookie checkCookie];
}

#pragma mark test
- (void)justForTest {
    KnowledgeManager *manager = [KnowledgeManager instance];
    [manager getUpdateInfoFileFromServerAndUpdateDataBase];
}

- (void)justForMoreDownloadTest {
    KnowledgeManager *manager = [KnowledgeManager instance];
    NSArray *book_ids = [NSArray arrayWithObjects:@"test_book_4",@"test_book_5",@"test_book_6", nil];
    for (int i =0; i<3; i++) {
        [manager startDownloadDataManagerWithDataId:[book_ids objectAtIndex:i]];
    }
}
- (NSString *)fileToJsonString {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"book-list-json-2" ofType:@"json"];
    NSFileHandle *fileHandler = [NSFileHandle fileHandleForReadingAtPath:filePath];
    NSData *data = [fileHandler readDataToEndOfFile];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    SBJsonParser *parse = [[SBJsonParser alloc] init];
    NSArray *arr = [parse objectWithString:string];
    
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSString *jsonString = [writer stringWithObject:arr];
    //    NSLog(@"%@",jsonString);
    return jsonString;
}

- (NSString *)getImage {
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"封面图片-2-base64" ofType:@"txt"];
    NSString *imageStr = [[NSString alloc] initWithContentsOfFile:imagePath encoding:NSUTF8StringEncoding error:nil];
    return imageStr;
}

#pragma mark getknowledgeMeta
//get dic :{book_id, book_status, book_status_detail}
- (NSMutableDictionary *)getDicFormDataBase:(NSString *)bookId {
    NSArray *bookArr = [[KnowledgeMetaManager instance] getKnowledgeMetaWithDataId:bookId andDataType:DATA_TYPE_DATA_SOURCE];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for (NSManagedObject *entity in bookArr) {
        if (entity == nil) {
            continue;
        }
        NSString *dicBookId = [entity valueForKey:@"dataId"];
        NSNumber *dicBookStatusNum = [entity valueForKey:@"dataStatus"];
        int dicBookStatusInteger = [dicBookStatusNum intValue];
        NSString *dicBookStatus = nil;
        NSString *downLoadStatus = nil;
        if (dicBookStatusInteger >= 1 && dicBookStatusInteger <=3  ) {
            dicBookStatus = @"下载";
        }
        else if (dicBookStatusInteger >= 4 && dicBookStatusInteger <=6) {
            dicBookStatus = @"解包";
            //            downLoadStatus = @""
        }
        else if (dicBookStatusInteger == 10) {
            dicBookStatus = @"完成";
        }
        else if (dicBookStatusInteger >= 8 && dicBookStatusInteger <= 9) {
            dicBookStatus = @"更新本地文件";
        }
        else {
            dicBookStatus = @"校验";
        }
        //        else {
        //
        //        }
        NSString *dicBookStatusDetails = [entity valueForKey:@"dataStatusDesc"];
        //
        [dic setValue:dicBookId forKey:@"book_id"];
        [dic setValue:dicBookStatus forKey:@"book_status"];
        [dic setValue:dicBookStatusDetails forKey:@"book_status_detail"];
        
    }
    return dic;
    
}





-(void)output {
    NSLog(@"调了，调了");
}




@end
