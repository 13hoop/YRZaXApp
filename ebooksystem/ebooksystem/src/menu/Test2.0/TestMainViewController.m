//
//  TestMainViewController.m
//  ebooksystem
//
//  Created by wanghaoyu on 14/12/22.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import "TestMainViewController.h"
#import "VideoDownloadManager.h"
#import "LogUtil.h"
#import "DeviceStatusUtil.h"
#import "DirectionMPMoviePlayerViewController.h"
#import "KnowledgeManager.h"
#import "KnowledgeDownloadManager.h"
#import "KnowledgeDataManager.h"
#import "Config.h"
#import "DateUtil.h"
#import "KnowledgeWebViewController.h"
#import "TestWebViewController.h"

@interface TestMainViewController ()<VideoDownloadManagerDelegate,KnowledgeDownloadManagerDelegate,KnowledgeManagerDelegate>

{
    BOOL isWeiKeSelected;
    BOOL isBibeiSelected;
}
@property (nonatomic,strong) IBOutlet UIButton *biBeiBtn;
@property (nonatomic,strong) IBOutlet UIButton *jiuBaiTiBtn;
@property (nonatomic,strong) IBOutlet UIButton *weiKeBtn;
@property (nonatomic,strong) IBOutlet UIButton *backBtn;
@property (nonatomic,strong) IBOutlet UIButton *arrowBtn;
@property (nonatomic,strong) IBOutlet UIButton *BookDownload;
@property (nonatomic,strong) IBOutlet UIButton *updateWithDataIdBtn;
@property (nonatomic,strong) IBOutlet UIProgressView *bibeiProgress;
@property (nonatomic,strong) IBOutlet UIProgressView *jiuBaiTiProgress;
@property (nonatomic,strong) IBOutlet UIProgressView *weiKeprogress;
@property (nonatomic,strong) IBOutlet UILabel *biBeiLable;
@property (nonatomic,strong) IBOutlet UILabel *jiuBaiTiLable;
@property (nonatomic,strong) IBOutlet UILabel *weiKeLable;
@property (nonatomic,strong) VideoDownloadManager *videoDownloadManager;
@property (nonatomic,strong) KnowledgeDownloadManager *knowledgeDownLoadManager;
@property (nonatomic,strong) KnowledgeDataManager *dataManager;
@end

@implementation TestMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    isWeiKeSelected = isBibeiSelected = NO;
    self.videoDownloadManager = [VideoDownloadManager shareInstance];
    self.videoDownloadManager.videoDownloadManagerDelegate = self;
    //knowledge download
    self.knowledgeDownLoadManager = [KnowledgeDownloadManager instance];
    self.knowledgeDownLoadManager.delegate = self;
    //knowledgeDataManager
    self.dataManager = [KnowledgeDataManager instance];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//click btn run method
- (IBAction)bibeibtn:(id)sender {
    isBibeiSelected = !isBibeiSelected;
    if (isBibeiSelected) {
        NSString *dataId = @"1057389eb0e4718c59916ff1ba2aa57a";
        [KnowledgeManager instance].delegate =self;
       
    }
    else {
        //暂停的代码
        [_biBeiBtn setBackgroundColor:[UIColor clearColor]];
        
    }
    
    
}




#pragma mark  cheacUpdate  according to dataId method----jiubaiti
- (IBAction)jiuBaiTibtn:(id)sender {
    }
#pragma mark checkUpdate --knowledgeManager delegate
- (void)knowledgeDownloadManagerWithProgress:(float)progress andDownloadItem:(KnowledgeDownloadItem *)downloadItem {
    if ([downloadItem.title isEqualToString:@"1ed2aa98e6defd695cb8e0140bac9a92"]) {
        _jiuBaiTiProgress.progress = progress;
    }
    if ([downloadItem.title isEqualToString:@"1057389eb0e4718c59916ff1ba2aa57a"]) {
        _bibeiProgress.progress = progress;
    }
}
- (void)knowledgeDownloadManagerIsSuccess:(BOOL)isSuccess andDownloadItem:(KnowledgeDownloadItem *)downloadItem {
    NSString *title = downloadItem.title;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"下载提示" message:title delegate:nil cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
    [alert show];
    
}

- (void)isShouldUpdateWithUpdateMessage:(NSString *)updateMessage {
    NSString *message = nil;
    if (updateMessage == nil || updateMessage.length <= 0) {
        message = @"您当前的版本信息已为最新版本，无需更新";
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alert show];
}

- (BOOL)returnPromptInformationToJSWithInformation:(NSString *)promptInfo {
    NSLog(@"是否需要更新的提示信息：%@",promptInfo);
    return YES;
}

- (BOOL)returnUpdatableDataVersionInfoArrayManager:(NSArray *)updatableDataVersionInfoArray {
    NSLog(@"需要更新的数组==%@",updatableDataVersionInfoArray);
    return YES;
}
#pragma mark 微课
- (IBAction)weikeBtn:(id)sender {
    isWeiKeSelected =!isWeiKeSelected;
    [_weiKeBtn setBackgroundColor:[UIColor orangeColor]];
    [_weiKeBtn setTitle:@"下载中..." forState:UIControlStateSelected];
    if (isWeiKeSelected) {
        NSString *urlStr = @"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4";
        NSURL *url=[NSURL URLWithString:urlStr];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docDir = [paths objectAtIndex:0];
        NSString *path=[NSString stringWithFormat:@"%@/downLoadVideo/%@",docDir,[url lastPathComponent]];
        [self.videoDownloadManager startDownloadWithTitle:@"下载视频" andDownloadUrl:url andSavePath:path andDesc:nil andDecodePassword:nil andItemId:@"weike"];
        NSLog(@"微课下载的视频地址 = %@",path);
    }
    else {
        [_weiKeBtn setBackgroundColor:[UIColor clearColor]];
        NSString *itemId = @"weike";
        [self.videoDownloadManager stopDownloadWithId:itemId];
    }
   
}

- (IBAction)backbtn:(id)sender {

    [self.navigationController popViewControllerAnimated:YES];
}

#pragma  mark video download manager
- (void)videoDownloadManagerWithDownLoadItem:(VideoDownloadItem *)videoDownloadItem didProgress:(float)progress
{
    LogDebug(@"download item, id %@, title %@, progress: %f", videoDownloadItem.itemId, videoDownloadItem.title, videoDownloadItem.downloadProgress);
    
    //代理方法中的参数是反向传过来的
    //首先判断在NS中是否存在titleID,若是存在则更新，反之则添加到NS中。
    NSString *progressStr=nil;
    progressStr=[NSString stringWithFormat:@"%f",progress];
    //将下载进度存储到数据库中
    
    if ([videoDownloadItem.itemId isEqualToString:@"weike"]) {
        _weiKeprogress.progress = progress;
        _weiKeLable.text = [NSString stringWithFormat:@"%2f",progress*100];
        
    }
    
    
    
}
- (void)videoDownloadManagerWithDownLoadItem:(VideoDownloadItem *)videoDownloadItem didFinshed:(BOOL)isSuccess response:(id)response
{
    //获取当前下载进度
    NSMutableDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:@"IADownLoadProgressDic"];
    float hadDownloadProgress = [[dic objectForKey:@"IADownLoadProgress"] floatValue];
    NSLog(@"下载完成后的进度是：%f",hadDownloadProgress);
    //获取当前网络状态
    DeviceStatusUtil *ds = [[DeviceStatusUtil alloc] init];
    NSString *netConnectStatus = [ds GetCurrntNet];
    if ([videoDownloadItem.itemId isEqualToString:@"weike"]) {
        if (hadDownloadProgress < 1.00) {
            if ([netConnectStatus isEqualToString:@"no connect"]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"下载提示" message:@"当前无网络连接，请检查您的网络" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [alert show];
            }
        }
        else {
            [self playVideo:videoDownloadItem.savePath];
        }
        
    }
}

#pragma mark knowledge downloadItem manager delegate
- (void)knowledgeDownloadItem:(KnowledgeDownloadItem *)downloadItem didFinish:(BOOL)success response:(id)response {
    
}

- (void)knowledgeDownloadItem:(KnowledgeDownloadItem *)downloadItem didProgress:(float)progress {
    
}

#pragma mark play video
//下载完成后播放视频
- (BOOL)playVideo:(NSString *)urlStr {
    
    BOOL isDir;
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:urlStr isDirectory:&isDir];
    if (!exist) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:@"没有检测到数据,请重新下载" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        return NO;
        
    }
    
    // 播放
    NSURL *url = [NSURL fileURLWithPath:urlStr];
    DirectionMPMoviePlayerViewController *playerViewController = [[DirectionMPMoviePlayerViewController alloc] initWithContentURL:url];
    playerViewController.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    playerViewController.view.frame = self.view.frame; // 全屏
    playerViewController.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    //    playerViewController.moviePlayer.movieSourceType=MPMovieSourceTypeFile;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallback:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:[playerViewController moviePlayer]];
    
    //---play movie---
    [[playerViewController moviePlayer] play];
    
    // 注: 用present会导致playerViewController中设置的transform不生效, 故转为push
    //    [self presentMoviePlayerViewControllerAnimated:playerViewController];
    [self.navigationController pushViewController:playerViewController animated:YES];
    return YES;
}

- (void)movieFinishedCallback:(NSNotification*) aNotification {
    MPMoviePlayerController *playerViewController = [aNotification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:playerViewController];
    [playerViewController stop];
    
    //    [self dismissMoviePlayerViewControllerAnimated];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark get able to update info
- (IBAction)arrowBtn:(id)sender {
    [KnowledgeManager instance].delegate = self;
    [[KnowledgeManager instance]getUpdateInfoFileFromServerAndUpdateDataBase];
//    [[KnowledgeManager instance] startCheckDataUpdate];
}

- (IBAction)newBookDownload:(id)sender {
    [[KnowledgeManager instance] startDownloadDataManagerWithDataId:@"0508ab9a966656501b9cb9f2d56d05a4"];
}
- (IBAction)updateWithDataId:(id)sender {
    
}
@end
