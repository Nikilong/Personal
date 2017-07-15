//
//  XMQRCodeViewController.m
//  虾兽新闻客户端
//
//  Created by Niki on 17/6/25.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "XMQRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>

#define EX_SCREEN_WIDTH (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1 ? (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height) : [[UIScreen mainScreen] bounds].size.width)

#define EX_SCREEN_HEIGHT (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1 ? (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? [[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width) : [[UIScreen mainScreen] bounds].size.height)

@interface XMQRCodeViewController ()<AVCaptureMetadataOutputObjectsDelegate>

/** 摄像头部件 */
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation XMQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self canUseCamera])
    {
        [self starScan];
    }else
    {
        UIAlertController *tips = [UIAlertController alertControllerWithTitle:@"错误" message:@"设备摄像头不可用" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action){
            
            // 因为是用导航栏push出来的,所以必须用导航栏pop掉
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [tips addAction:cancelAction];
        
        [self presentViewController:tips animated:YES completion:nil];
        
    }
}

#pragma mark - 判断摄像头是否可用
- (BOOL)canUseCamera
{
    return ([AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] != nil);
}

#pragma mark - 调用摄像头扫码
- (void)starScan
{
    // 1. 实例化拍摄设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // 2. 设置输入设备
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    
    // 3. 设置元数据输出
    // 3.1 实例化拍摄元数据输出
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    // 3.3 设置输出数据代理
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // 4. 添加拍摄会话
    // 4.1 实例化拍摄会话
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    // 4.2 添加会话输入
    [session addInput:input];
    // 4.3 添加会话输出
    [session addOutput:output];
    // 4.3 设置输出数据类型，需要将元数据输出添加到会话后，才能指定元数据类型，否则会报错
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeCode39Code]];
    
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

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    
    // 会频繁的扫描，调用代理方法
    // 1. 如果扫描完成，停止会话
    [self.session stopRunning];
    // 2. 删除预览图层
    [self.previewLayer removeFromSuperlayer];
    
//    NSLog(@"%@", metadataObjects);
    // 3. 设置界面显示扫描结果
    
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        // 提示：如果需要对url或者名片等信息进行扫描，可以在此进行扩展！

        UIAlertController *tips = [UIAlertController alertControllerWithTitle:@"扫描结果" message:obj.stringValue preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action){
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }];

        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"复制内容" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action){
            // 将textview的text添加到系统的剪切板
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:obj.stringValue];
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        UIAlertAction *openURLAction = [UIAlertAction actionWithTitle:@"前往" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action){
            // 当点击确定执行的块代码
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"QRCodeShouldOpenWebNotitificaiton" object:nil];
            XMWebModel *model = [[XMWebModel alloc] init];
            model.webURL = [NSURL URLWithString:obj.stringValue];
            
            if ([self.delegate respondsToSelector:@selector(openWebmoduleRequest:)])
            {
                [self.delegate openWebmoduleRequest:model];
            }
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [tips addAction:cancelAction];
        [tips addAction:okAction];
        [tips addAction:openURLAction];
        
        [self presentViewController:tips animated:YES completion:nil];
    }
}




@end
