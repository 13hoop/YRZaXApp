//
//  ScanQRCodeViewController.m
//  ebooksystem
//
//  Created by wanghaoyu on 15/1/13.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import "ScanQRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "Config.h"
#import "ScanQRCodeTabViewController.h"
#import "ScanResultInfoViewController.h"

#define scanAreaWidthAndHeight 240
#define scanAreaImageWidthAndHeight 300
#define line_x (self.view.frame.size.width - 195)/2
#define shadowAlphaValue 0.4
@interface ScanQRCodeViewController ()<AVCaptureMetadataOutputObjectsDelegate>
{
    int num;
    BOOL upOrdown;
    NSTimer * timer;
    
}
/*使用tabbar退出时：
    session需要关掉
    定时器需要关掉
 */
@property (nonatomic,strong) AVCaptureDevice *device;
@property (nonatomic,strong) AVCaptureDeviceInput *input;
@property (nonatomic,strong) AVCaptureMetadataOutput *output;
@property (nonatomic,strong) AVCaptureSession *session;
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *preview;
@property (nonatomic,strong) UIImageView *line;

@property (nonatomic,assign) BOOL transiting;
@end

@implementation ScanQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //设置导航条
    self.navigationController.navigationBarHidden = YES;
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    [self makeUI];
    [self readQRCode];
//    self.navigationController.navigationBarHidden = YES;
    NSLog(@"%@",self.navigationController.viewControllers);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:TRUE];
    self.tabBarController.tabBar.hidden = YES;
    
}

- (void)viewWillDisappear:(BOOL)animated {
    //退出时将tabbar的hidden设置为NO
    self.tabBarController.tabBar.hidden = NO;
    
    //退出时将定时器关掉，否则会导致内存溢出
    [timer invalidate];
    timer = nil;
    
}

#pragma mark make UI
- (void)makeUI {
    //创建扫描框的样式
    
//    UILabel * labIntroudction= [[UILabel alloc] initWithFrame:CGRectMake(15, 40, 290, 50)];
//    labIntroudction.backgroundColor = [UIColor clearColor];
//    labIntroudction.numberOfLines=2;
//    labIntroudction.textColor=[UIColor whiteColor];
//    labIntroudction.text=@"将二维码图像置于矩形方框内，离手机摄像头10CM左右，系统会自动识别。";
//    [self.view addSubview:labIntroudction];
//    
//    
//    UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake((self.view.frame.size.width-scanAreaImageWidthAndHeight)/2, 100, scanAreaImageWidthAndHeight, scanAreaImageWidthAndHeight)];
//    NSString *path=[[[Config instance] drawableConfig] getImageFullPath:@"pick_bg.png"];
//    UIImage *image = [UIImage imageNamed:path];
//    imageView.image = image;
//    [self.view addSubview:imageView];
    
    upOrdown = NO;
    num =0;
    //适配6，6p---375*667 414*736
    _line = [[UIImageView alloc] initWithFrame:CGRectMake(line_x, 110, 195, 6)];
    
    NSString *pathLine=[[[Config instance] drawableConfig] getImageFullPath:@"ScanLine.png"];
    UIImage *imageLine = [UIImage imageNamed:pathLine];
    _line.image = imageLine;
    [self.view addSubview:_line];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
}

-(void)animation1
{
    if (upOrdown == NO) {
        num ++;
        _line.frame = CGRectMake(line_x, 110+2*num, 195, 6);
//        NSLog(@"aaaaa===%d",num);
        if (2*num == 196) {
            upOrdown = YES;
        }
    }
    else {
        /*
        需要向上走的动画时解开这个注释
        num --;
        _line.frame = CGRectMake(line_x, 110+2*num, 240, 2);
        if (num == 0) {
            upOrdown = NO;
        }
         */
        num = 0;
        _line.frame = CGRectMake(line_x, 110+2*num, 240, 2);
        if (num == 0) {
            upOrdown = NO;
        }
    }
    
}

#pragma mark read QRCode
- (void)readQRCode {
    //devide
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //input
    NSError *inputError = nil;
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&inputError];
    if (inputError) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:inputError.localizedDescription delegate:nil cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
        [alert show];
    }
    //output
    self.output = [[AVCaptureMetadataOutput alloc] init];
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //session
    self.session = [[AVCaptureSession alloc] init];
    //默认的值是AVCaptureSessionPresetHigh，设置这个值为了获取高质量的输出显示
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    if ([self.session canAddOutput:self.output]) {
        [self.session addOutput:self.output];
    }
    self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    //preview
    self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;//设置图层的属性
//    self.preview.frame = CGRectMake((self.view.frame.size.width-scanAreaWidthAndHeight)/2, 110,scanAreaWidthAndHeight,scanAreaWidthAndHeight);
    self.preview.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64);
    //制作阴影
    [self makeShadow];
    [self.view.layer insertSublayer:self.preview atIndex:0];
    //start
    [self.session startRunning];

}
//制作阴影
- (void)makeShadow {
    //自定义导航栏
    UIView *navgationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    navgationView.backgroundColor = [UIColor blackColor];
    navgationView.userInteractionEnabled = YES;
    [self.view addSubview:navgationView];
    //create 返回箭头
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10,(64-25)/2, 16, 25)];
    UIImage *image = [UIImage imageNamed:[[[Config instance] drawableConfig] getImageFullPath:@"backNew.png"]];
    imageView.image = image;
    [navgationView addSubview:imageView];
    //create 返回按钮,宽度设置的较大，保证返回的操作足够流畅
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 64)];
    [backButton addTarget:self action:@selector(backToFrontPage) forControlEvents:UIControlEventTouchUpInside];
    //
    [navgationView addSubview:backButton];
    //create title
    UILabel *textLable = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 160)/2, 0, 160, 64)];
    textLable.text = @"扫描二维码";
    [textLable setTextAlignment:UITextAlignmentCenter];
    textLable.textColor = [UIColor whiteColor];
    [textLable setFont:[UIFont fontWithName:@"Courier" size:23.0f]];
    [navgationView addSubview:textLable];
    
    
    
    //make shadow
    
    //up
    UIView  *upView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 44)];
    upView.backgroundColor = [UIColor blackColor];
    upView.alpha = shadowAlphaValue;
    [self.view addSubview:upView];
    //left    暂定扫描区域的宽度是201*201 ---正方形
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 64+44, (self.view.frame.size.width-201)/2, 201)];
    leftView.backgroundColor = [UIColor blackColor];
    leftView.alpha = shadowAlphaValue;
    [self.view addSubview:leftView];
    //right
    float rightView_x =201 + (self.view.frame.size.width-201)/2;
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(rightView_x, 64+44, (self.view.frame.size.width-201)/2, 201)];
    rightView.backgroundColor = [UIColor blackColor];
    rightView.alpha = shadowAlphaValue;
    [self.view addSubview:rightView];
    NSLog(@"%f",rightView_x);
    //down
    UIView *downView = [[UIView alloc] initWithFrame:CGRectMake(0, 64+44+201, self.view.frame.size.width, self.view.frame.size.height - 44 - 64+44+201)];
    downView.backgroundColor = [UIColor blackColor];
    downView.alpha = shadowAlphaValue;
    [self.view addSubview:downView];
    //中间的imageView
    UIImageView *scanImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-201)/2, 64+44, 201, 201)];
    UIImage *scanAreaImage = [UIImage imageNamed:[[[Config instance] drawableConfig] getImageFullPath:@"Scan.png"]];
    scanImageView.image = scanAreaImage;
    [self.view addSubview:scanImageView];
    
    
//    tip lable
    UILabel *tipLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, self.view.frame.size.width, 20)];
    tipLable.text = @"将二维码放入框内，即可自动扫描";
    tipLable.font = [UIFont systemFontOfSize:15];
    [tipLable setTextAlignment:NSTextAlignmentCenter];
    tipLable.textColor = [UIColor whiteColor];
    [downView addSubview:tipLable];
    
}

#pragma mark output delegate method
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    //读取到二维码后的操作都在这里面进行
    
    NSString *stringValue;
    if (metadataObjects.count > 0) {
        //机器可读的编码对象
        AVMetadataMachineReadableCodeObject *metaObject = [metadataObjects objectAtIndex:0];
        stringValue = metaObject.stringValue;
    }
    //stop
    [self stopReadQRCode];
    [timer invalidate];
    
    
    //get url
    NSString *URLString = [self getUrlFromString:stringValue];
    
    //通过代理将扫描结果传出来
    [self.scanDelegate getScanInfo:URLString];
    //在跳转到落地页之前，进行判断（普通字符串，其他的URL，书中二维码对应的URL），分别作不同处理，防止程序crash
    
    //非URL
    if (URLString.length <= 0 || URLString == nil) {
        
        NSMutableArray *controllers = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
        //移除最后一个view controller
        [controllers removeLastObject];
        ScanResultInfoViewController *scanhaoyu = [[ScanResultInfoViewController alloc] init];
        scanhaoyu.scanContext = stringValue;
        [controllers addObject:scanhaoyu];
        [self.navigationController setViewControllers:controllers];
        

    }
    //URL
    else {
        if (![URLString hasPrefix:@"http://zaxue100.com"]) {
            
            //不是以http://zaxue100.com为前缀的URL，则直接在浏览器打开
            NSMutableArray *controllerNew = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
            //移除最后一个view controller
            [controllerNew removeLastObject];
            ScanResultInfoViewController *scanResult = [[ScanResultInfoViewController alloc] init];
            scanResult.urlString = URLString;
            [controllerNew addObject:scanResult];
            [self.navigationController setViewControllers:controllerNew];
            
        }
    else {
        //将扫描得到的结果传到落地页中
        //A->B->C,当前页面时B,进到C中，使用pop返回到A的解决办法：
        //获取当前navigation controller中的所有view controller
        NSMutableArray *controllers = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
        //移除最后一个view controller
        [controllers removeLastObject];
        //实例化新的controller
        ScanQRCodeTabViewController *scanTabView = [[ScanQRCodeTabViewController alloc] init];
        scanTabView.scanInfoStr = URLString;
        [controllers addObject:scanTabView];
        //设置新的controller集合
        [self.navigationController setViewControllers:controllers];
    }
    
    }
    
}

- (void)stopReadQRCode {
    [self.session stopRunning];
    self.session = nil;
    [self.preview removeFromSuperlayer];
}

//判断是否为http链接的正则表达式
- (NSString*)getUrlFromString:(NSString*)str {
    
    NSError *error;
    //http+:[^\\s]* 这是检测网址的正则表达式.（1）首先实例化正则表达式实例
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"http+:[^\\s]*" options:0 error:&error];//筛选
    
    if (regex != nil) {//（2）根据生成的正则实例匹配指定的字符串
        NSTextCheckingResult *firstMatch = [regex firstMatchInString:str options:0 range:NSMakeRange(0, [str length])];
        
        if (firstMatch) {//（3）截取需要的数据（也就是http链接）
            NSRange resultRange = [firstMatch rangeAtIndex:0];
            //从urlString中截取数据
            NSString *result1 = [str substringWithRange:resultRange];
            NSLog(@"正则表达后的结果%@   ----需要在后面主动加.com",result1);
            return result1;
            
        }
    }
    return nil;
    
    
}

#pragma mark  custom navigationbar method
- (void)backToFrontPage {
    [self.navigationController popViewControllerAnimated:YES];
}







@end
