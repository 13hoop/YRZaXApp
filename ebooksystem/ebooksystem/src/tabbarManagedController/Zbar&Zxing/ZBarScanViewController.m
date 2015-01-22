//
//  ZBarScanViewController.m
//  ebooksystem
//
//  Created by wanghaoyu on 15/1/11.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import "ZBarScanViewController.h"
#import "Config.h"
@interface ZBarScanViewController ()<ZBarReaderViewDelegate,UIImagePickerControllerDelegate>
{
    NSTimer * timer;
    int num;
    BOOL upOrdown;

}

@property (nonatomic,strong) ZBarReaderView *zbarReaderView;
@property (nonatomic,strong) UIImageView *line;
@end

@implementation ZBarScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    num = 0;
    upOrdown = NO;
    [self initZbarReaderView];
    [self createCustomView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
 H:
    ZBar使用的注意事项如下
 */

//初始化并打开ZbarReaderView
- (void)initZbarReaderView {
    self.zbarReaderView = [[ZBarReaderView alloc] init];
    self.zbarReaderView.frame = CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height-44);
    //遵守代理方法
//    self.zbarReaderView.readerDelegate = self;
    //遵守代理方法
    self.zbarReaderView.readerDelegate = self;
    //（1）关闭闪关灯
    self.zbarReaderView.torchMode = 0;
    [self.zbarReaderView setAllowsPinchZoom:YES];
    //（2）设置扫描区域
    CGRect scanRect = CGRectMake(60, CGRectGetMidY(self.zbarReaderView.frame)- 126, 200, 200);
    
    //处理模拟器--真机不需要设置
    if (TARGET_IPHONE_SIMULATOR) {
        ZBarCameraSimulator *cameraSim = [[ZBarCameraSimulator alloc] initWithViewController:self];
        cameraSim.readerView = self.zbarReaderView;
    }
    //（3）将Zbar定义的readerView控件加入到
    [self.view addSubview:self.zbarReaderView];
    //扫描区域计算不准确就会出错。
    //（4）扫描区域计算,扫描区域是百分数，所以在下面单独封装一个方法来
//    self.zbarReaderView.scanCrop =[self getScanCrop:scanRect readerViewBounds:self.zbarReaderView.bounds];;
    self.zbarReaderView.scanCrop = CGRectMake(0.1, 0.2, 0.8, 0.8);
    //（5）开始扫描
    [self.zbarReaderView start];
//    [self.zbarReaderView.captureReader captureFrame];
}


//两个参数，第一个参数是自定义的readerView扫描区域的大小，第二个参数是自定义的readerView的大小。
- (CGRect)getScanCrop:(CGRect)rect readerViewBounds:(CGRect)readerViewBounds {
    CGFloat x,y,width,height;
    x = rect.origin.x / readerViewBounds.size.width;//这连个参数要设置成0，所以模width，而不是模x
    y = rect.origin.y /readerViewBounds.size.height;
    width = rect.size.width / readerViewBounds.size.width;
    height = rect.size.height /readerViewBounds.size.height;
    NSLog(@"%f%f%f%f",x,y,width,height);
    return CGRectMake(x, y, width, height);
}

//Zbar的代理方法，这个方法在扫描到内容时会调用。
- (void)readerView:(ZBarReaderView *)readerView didReadSymbols:(ZBarSymbolSet *)symbols fromImage:(UIImage *)image {
    NSString *codeData = [[NSString alloc] init];;
    for (ZBarSymbol *sym in symbols) {
        codeData = sym.data;
        break;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"扫描结果" message:codeData delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    [self.zbarReaderView stop];
    
}

#pragma mark 自定义扫描界面
-(void)createCustomView {
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 280, 40)];
    label.text = @"请将扫描的二维码至于下面的框内\n谢谢！";
    label.textColor = [UIColor whiteColor];
    label.textAlignment = 1;
    label.lineBreakMode = 0;
    label.numberOfLines = 2;
    label.backgroundColor = [UIColor clearColor];
    [self.zbarReaderView addSubview:label];
    //自定义操作2--添加一个扫描框
    NSString *path=[[[Config instance] drawableConfig] getImageFullPath:@"pick_bg.png"];
    UIImage *image = [UIImage imageNamed:path];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(20, 80, 280, 280);
    [self.zbarReaderView addSubview:imageView];
    //
    NSString *pathLine=[[[Config instance] drawableConfig] getImageFullPath:@"line.png"];
    UIImage *imageLine = [UIImage imageNamed:pathLine];
    self.line = [[UIImageView alloc] initWithImage:imageLine];
    [self.zbarReaderView addSubview:self.line];
    timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
    

}
-(void)animation1
{
    if (upOrdown == NO) {
        num ++;
        _line.frame = CGRectMake(30, 10+2*num, 220, 2);
        if (2*num == 260) {
            upOrdown = YES;
        }
    }
    else {
        num --;
        _line.frame = CGRectMake(30, 10+2*num, 220, 2);
        if (num == 0) {
            upOrdown = NO;
        }
    }
    
    
}

////相机打开就会调用这个方法
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [timer invalidate];
    // 得到条形码结果
    id<NSFastEnumeration> results =
    [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        break;
    //获得到条形码
    //NSString *dataNum=symbol.data;
    //扫描界面退出
    NSLog(@"%@",symbol.data);
    [picker dismissModalViewControllerAnimated: YES];
    
}



@end
