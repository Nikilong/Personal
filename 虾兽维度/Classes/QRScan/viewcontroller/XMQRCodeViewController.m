//
//  XMQRCodeViewController.m
//  虾兽维度
//
//  Created by Niki on 17/6/25.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "XMQRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "XMImageUtil.h"
#import "MBProgressHUD+NK.h"

#import "XMQRView.h"
#import "XMQRUtil.h"

#import <DKNightVersion/DKNightVersion.h>

@interface XMQRCodeViewController ()<
AVCaptureMetadataOutputObjectsDelegate,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate
>

/** 摄像头部件 */
@property (nonatomic, strong) AVCaptureSession *session;                    // 拍摄会话
@property (nonatomic, strong) AVCaptureDevice *device;                      // 实例化拍摄设备
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;     // 视频预览图层
@property (nonatomic, strong) AVCaptureMetadataOutput * output;             // 拍摄元数据输出

@property (nonatomic, strong) XMQRView *qrView;                             // 扫描半透明+扫描条

@end

@implementation XMQRCodeViewController


- (XMQRView *)qrView {
    if (!_qrView) {
        CGRect screenRect = [XMQRUtil screenBounds];
        _qrView = [[XMQRView alloc] initWithFrame:screenRect];
        _qrView.transparentArea = CGSizeMake(250, 250);
        _qrView.backgroundColor = [UIColor clearColor];
    }
    return _qrView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"扫描二维码";
    
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(dealAlbumPicture)];
    [leftBtn dk_setTintColorPicker:DKColorPickerWithColors(RGB(242, 242, 242), XMNavDarkBG)];
    [rightBtn dk_setTintColorPicker:DKColorPickerWithColors(RGB(242, 242, 242), XMNavDarkBG)];
    // 添加从相册中识别二维码
    self.navigationItem.rightBarButtonItem = rightBtn;
    self.navigationItem.leftBarButtonItem = leftBtn;
}


- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    if ([self canUseCamera]){
        // 开始扫描
        [self starScan];
        // 添加半透明及扫描框(虽然加了半透明改造,但此时扫描的有效区域是全屏)
        [self addQrView];
        // 限定扫描区域(矩形框)
        [self updateLayout];
        // 设置手电筒按钮
        [self setTorchButton];
    }else{
        UIAlertController *tips = [UIAlertController alertControllerWithTitle:@"错误" message:@"设备摄像头不可用" preferredStyle:UIAlertControllerStyleAlert];
        [tips addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action){
            // 因为是用导航栏push出来的,所以必须用导航栏pop掉
            [self.navigationController popViewControllerAnimated:YES];
        }]];
        
        [self presentViewController:tips animated:YES completion:nil];
        
    }
}

- (void)dealloc{
    NSLog(@"XMQRCodeViewController---%s",__func__);
}

#pragma mark - 判断摄像头是否可用
- (BOOL)canUseCamera{
    
    return ([AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] != nil);
}

#pragma mark - 调用摄像头扫码
- (void)starScan{
    
    // 1. 实例化拍摄设备
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // 2. 设置输入设备
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // 3. 设置元数据输出
    // 3.1 实例化拍摄元数据输出
    self.output = [[AVCaptureMetadataOutput alloc] init];
    // 3.3 设置输出数据代理
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // 4. 添加拍摄会话
    // 4.1 实例化拍摄会话
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    // 4.2 添加会话输入
    [session addInput:input];
    // 4.3 添加会话输出
    [session addOutput:self.output];
    // 4.3 设置输出数据类型，需要将元数据输出添加到会话后，才能指定元数据类型，否则会报错
    [self.output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeCode39Code]];
    
    self.session = session;
    
    // 5. 视频预览图层
    // 5.1 实例化预览图层, 传递_session是为了告诉图层将来显示什么内容
    AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    preview.frame = self.view.bounds;
    // 5.2 将图层插入当前视图
    [self.view.layer insertSublayer:preview atIndex:100];
    self.previewLayer = preview;
    
    // 6. 启动会话
    [_session startRunning];
    
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    // 会频繁的扫描，调用代理方法
    // 1. 如果扫描完成，停止会话
    [self.session stopRunning];
    self.session = nil;
    // 2. 删除预览图层
    [self.previewLayer removeFromSuperlayer];
    
    // 3. 设置界面显示扫描结果
    
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        // 先销毁当前控制器
        if(self.navigationController){
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        
        // 执行回调
        if(self.scanCallBack){
            self.scanCallBack(obj.stringValue);
        }
        
    }else{
        [MBProgressHUD showMessage:@"未能识别二维码" toView:self.view];
    }
}

/// 添加扫描框
- (void)addQrView{
    [self.view addSubview:self.qrView];
}

/// 限定扫描的有效区域
- (void)updateLayout {
    
    self.qrView.center = CGPointMake([XMQRUtil screenBounds].size.width / 2, [XMQRUtil screenBounds].size.height / 2 - 44);
    
    //修正扫描区域
    CGFloat screenHeight = self.view.frame.size.height;
    CGFloat screenWidth = self.view.frame.size.width;
    CGRect cropRect = CGRectMake((screenWidth - self.qrView.transparentArea.width) / 2,(screenHeight - self.qrView.transparentArea.height) / 2, self.qrView.transparentArea.width, self.qrView.transparentArea.height);
    
    [self.output setRectOfInterest:CGRectMake(cropRect.origin.y / screenHeight, cropRect.origin.x / screenWidth, cropRect.size.height / screenHeight, cropRect.size.width / screenWidth)];
}

/// 闪光灯按钮
- (void)setTorchButton{
    if(self.device.hasTorch){
        CGFloat btnWH = 80;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake((XMScreenW - btnWH) * 0.5, XMScreenH - btnWH * 2.5, btnWH, btnWH);
        [button setBackgroundColor:[UIColor clearColor]];
        [button setImage:[UIImage imageNamed:@"light_off"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"light_on"] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(flashlight:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
}

///闪光灯点击事件
- (void)flashlight:(UIButton *)btn{
    btn.selected = !btn.isSelected;
    //如果闪光灯正在使用 则关闭
    if (self.device.torchMode == AVCaptureTorchModeOn) {
        
        [self.device lockForConfiguration:nil];
        [self.device setTorchMode:AVCaptureTorchModeOff];
        [self.device unlockForConfiguration];
        
    }else if (self.device.torchMode == AVCaptureTorchModeOff){
        
        //锁定闪光灯
        [self.device lockForConfiguration:nil];
        //打开闪光灯
        [self.device setTorchMode:AVCaptureTorchModeOn];
        //解除锁定
        [self.device unlockForConfiguration];
    }
}

// '相册'按钮点击事件
- (void)dealAlbumPicture{
    // 1.判断相册是否可以打开
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) return;
    // 2. 创建图片选择控制器
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    // 3. 设置打开照片相册类型(显示所有相簿)
    ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    // 4.设置代理
    ipc.delegate = self;
    // 5.modal出这个控制器
    [self presentViewController:ipc animated:YES completion:nil];

    
}

/// 退出按钮
- (void)dismiss{
    if(self.navigationController){
        [self.navigationController popViewControllerAnimated:YES];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- <UIImagePickerControllerDelegate>
// 获取相册中的图片并识别图片中的二维码
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    // 销毁控制器
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    // 停止扫描,释放控制器
    [self.session stopRunning];
    
    // 解析选中的图片的二维码信息
    NSString *scanResult = [XMImageUtil detectorQRCodeImage:info[UIImagePickerControllerOriginalImage]];
    if(scanResult.length > 0){
//        [self dealResult:scanResult];
        if (self.scanCallBack){
            self.scanCallBack(scanResult);
        }
    }else{
        [MBProgressHUD showMessage:@"未能识别二维码" toView:self.view];
    }
}

//当用户取消选取时调用
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    // 先dismiss相册
    [picker dismissViewControllerAnimated:YES completion:nil];
}


@end
