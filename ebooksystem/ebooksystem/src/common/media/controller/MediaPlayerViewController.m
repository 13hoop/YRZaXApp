//
//  MediaPlayerViewController.m
//  ebooksystem
//
//  Created by zhenghao on 10/24/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "MediaPlayerViewController.h"

#import "MediaPlayer/MediaPlayer.h"


@interface MediaPlayerViewController ()

- (void)playUrl:(NSURL *)url;
- (void)playFile:(NSString *)filename;
- (void)movieFinishedCallback:(NSNotification*) aNotification;

@end

@implementation MediaPlayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self playUrl:self.url];
}

#pragma mark - play
- (void)playUrl:(NSURL *)url {
    MPMoviePlayerViewController *playerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallback:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:[playerViewController moviePlayer]];
    //-- add to view---
//    [self.view addSubview:playerViewController.view];
    
    //---play movie---
    MPMoviePlayerController *player = [playerViewController moviePlayer];
    [player play];
    
    [self presentMoviePlayerViewControllerAnimated:playerViewController];
}

- (void)playFile:(NSString *)filename {
    [super viewDidLoad];
//    NSString *urlStr = [[NSBundle mainBundle] pathForResource:@"TaylorSwift-LoveStory" ofType:@"mp4"];
    NSURL *url = [NSURL fileURLWithPath:filename];
    
    [self playUrl:url];
}

- (void)movieFinishedCallback:(NSNotification*) aNotification {
    MPMoviePlayerController *playerViewController = [aNotification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:playerViewController];
    [playerViewController stop];
    
    [self dismissMoviePlayerViewControllerAnimated];
//    [playerViewController.view removeFromSuperview];
//     [playerViewController dismissModalViewControllerAnimated:YES];
//    [self.view removeFromParentViewController];
//    [self.view removeFromSuperView];
//    [player autorelease];
    
    [self.navigationController popViewControllerAnimated:YES];
}

//     // UIApplicationDidEnterBackgroundNotification通知
//     - (void)appEnterBackground:(NSNotification*)notice
//    {
//        　　// 进入后台时记录当前播放时间
//        overlay_flags.playTimeWhenEnterBackground = _player.currentPlaybackTime;
//        [_player pause];
//    }
//     
//     // UIApplicationWillEnterForegroundNotification通知
//     - (void)appEnterForeground:(NSNotification*)notice
//    {
//        　　// 设置播放速率为正常速度，设置当前播放时间为进入后台时的时间
//        [_player setCurrentPlaybackRate:1.0];
//        [_player setCurrentPlaybackTime:overlay_flags.playTimeWhenEnterBackground];
//    }

///**
// @method 播放电影
// */
//-(void)playMovie:(NSString *)fileName{
//    //视频文件路径
//    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"mp4"];
//    //视频URL
//    NSURL *url = [NSURL fileURLWithPath:path];
//    //视频播放对象
//    MPMoviePlayerController *movie = [[MPMoviePlayerController alloc] initWithContentURL:url];
//    movie.controlStyle = MPMovieControlStyleFullscreen;
//    [movie.view setFrame:self.view.bounds];
//    movie.initialPlaybackTime = -1;
//    [self.view addSubview:movie.view];
//    // 注册一个播放结束的通知
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(myMovieFinishedCallback:)
//                                                 name:MPMoviePlayerPlaybackDidFinishNotification
//                                               object:movie];
//    [movie play];
//}
//
//#pragma mark -------------------视频播放结束委托--------------------
//
///*
// @method 当视频播放完毕释放对象
// */
//-(void)myMovieFinishedCallback:(NSNotification*)notify
//{
//    //视频播放对象
//    MPMoviePlayerController* theMovie = [notify object];
//    //销毁播放通知
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:MPMoviePlayerPlaybackDidFinishNotification
//                                                  object:theMovie];
//    [theMovie.view removeFromSuperview];
//    // 释放视频对象
////    [theMovie release];
//}


@end
