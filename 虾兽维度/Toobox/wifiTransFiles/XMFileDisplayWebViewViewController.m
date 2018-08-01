//
//  XMFileDisplayWebViewViewController.m
//  虾兽维度
//
//  Created by Niki on 18/5/6.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMFileDisplayWebViewViewController.h"
#import <WebKit/WebKit.h>
#import "XMWifiTransModel.h"
#import "MBProgressHUD+NK.h"

#import "AppDelegate.h"
#import "AppDelegate+HJVideoRotation.h"

@interface XMFileDisplayWebViewViewController ()<UIGestureRecognizerDelegate,UIWebViewDelegate,UIScrollViewDelegate>

@property (nonatomic, strong) UIWebView *displayWebview;
//@property (nonatomic, strong) WKWebView *wkdisplayWebview;
@property (nonatomic, assign)  BOOL isCodeMode;


@end

@implementation XMFileDisplayWebViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 初始化参数
    self.isCodeMode = NO;
    
    // todo 要使用wkwebview来播放视频,未解决
//    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
//    config.allowsInlineMediaPlayback = YES;
//    config.allowsPictureInPictureMediaPlayback = YES;
//    self.wkdisplayWebview = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
//    [self.view addSubview:self.wkdisplayWebview];
    
    self.displayWebview = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.displayWebview.delegate = self;
    self.displayWebview.scrollView.delegate = self;
    // 实现缩放
    self.displayWebview.scalesPageToFit = YES;
    self.displayWebview.autoresizingMask = UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.displayWebview];
    
    
    
    // 增加点击手势隐藏或显示导航栏
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showNavBar:)];
    tap.delegate = self;
    [self.displayWebview addGestureRecognizer:tap];
//    [self.wkdisplayWebview addGestureRecognizer:tap];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareFile)];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(self.isCodeMode){
        // 隐藏导航栏
        self.navigationController.navigationBarHidden = YES;
        // 横屏
        //允许屏幕旋转
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        delegate.orientationMask = UIInterfaceOrientationMaskLandscape;
        // 设置方向
        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    [self.displayWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@""]]];
//    [self.wkdisplayWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@""]]];
    
    //关闭屏幕旋转
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.orientationMask = UIInterfaceOrientationMaskPortrait;
    NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
}

- (void)dealloc{

    NSLog(@"XMFileDisplayWebViewViewController-----%s",__func__);
}

/// 分享文件
- (void)shareFile{
    NSString *title = self.wifiModel.fileName;
    NSURL *url = [NSURL fileURLWithPath:self.wifiModel.fullPath];
    NSArray *params = @[title,url];
    UIActivityViewController *shareVC = [[UIActivityViewController alloc] initWithActivityItems:params applicationActivities:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:shareVC animated:YES completion:nil];
    });
    
}

/// 隐藏或显示导航栏
- (void)showNavBar:(UITapGestureRecognizer *)gest{
    if (gest.state == UIGestureRecognizerStateEnded){
        self.navigationController.navigationBarHidden = !self.navigationController.navigationBarHidden;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;

}

/// 加载本地文件
- (void)loadLocalFileWithPath:(NSString *)fullPath{
    if ([self.wifiModel.fileType isEqualToString:fileTypeCodeName] || [fullPath.pathExtension isEqualToString:@"txt"]){
        self.isCodeMode = YES;
        NSString *textStr = [self getCodeStringOfFile:fullPath];
        if (textStr) {
            //将解码的贴到webview上
            [self displayCodeWithCodeString:textStr];
           
        }else{
            [MBProgressHUD showMessage:@"解码出错"];
        }
    
    }else{
        [self.displayWebview loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:fullPath]]];
    }
}

/// 读取文件转为字符串
- (NSString *)getCodeStringOfFile:(NSString *)path{
    NSData *fileData = [NSData dataWithContentsOfFile:path];
    NSString *textStr = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    
    //按gbk的方式解码；
    if (!textStr) {
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        textStr = [[NSString alloc] initWithData:fileData encoding:enc];
        //            textStr = [[NSString alloc] initWithData:fileData encoding:0x80000632];
    }
    
    // txt文档还需要替换<和>
    if([path.pathExtension isEqualToString:@"txt"]){
        //将解码的贴到webview上
        textStr = [textStr stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
        textStr = [textStr stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
    }
    return textStr;
}

/// 将代码嵌入code.html并且展示
- (void)displayCodeWithCodeString:(NSString *)codeStr{
    // html/css/js文件必须放在同一个主目录下面
    // 将模板里面的内容替换成为要展示的内容,代码必须放在<pre><code>  </code></pre>之间才能显示
    NSString * htmlStr = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"code" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
    htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"-%@-" withString:codeStr];
    
    NSURL *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];    // 通过baseURL的方式加载的HTML// 可以在HTML内通过相对目录的方式加载js,css,img等文件
    [self.displayWebview loadHTMLString:htmlStr baseURL:baseURL];
}



#pragma mark - UIWebviewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView{
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (!self.navigationController.navigationBar.hidden){
        self.navigationController.navigationBar.hidden = YES;
    }
}

@end
