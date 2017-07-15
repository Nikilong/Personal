//
//  XMWebViewController.m
//  03 虾兽新闻客户端
//
//  Created by admin on 17/2/27.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "XMWebViewController.h"
#import "XMWebModelTool.h"
#import "MBProgressHUD.h"
#import "MBProgressHUD+NK.h"

@interface XMWebViewController ()<UIWebViewDelegate,NSURLSessionDelegate,UIGestureRecognizerDelegate>

/** 网页高度 */
@property (nonatomic, assign) NSInteger webHeight;

/** 工具条 */
@property (nonatomic, strong) UIView *toolBar;

/** 网页view */
@property (nonatomic, strong) UIWebView *web;

/** 记录当前的网络请求 */
@property (nonatomic, strong) NSURL *currentURL;

@property (nonatomic, assign)  BOOL hasOpenNewWebmodule;


@end

@implementation XMWebViewController

- (UIWebView *)web
{
    if (_web == nil)
    {
        _web = [[UIWebView alloc] init];
        _web.frame = self.view.bounds;
        _web.delegate = self;
        [self.view addSubview:_web];
        
        // 添加长按手势
        UILongPressGestureRecognizer *longP = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
#warning note 这里需要设置长按反应时间<0.5将系统的长按覆盖掉
        longP.minimumPressDuration = 0.25;
        [_web addGestureRecognizer:longP];
        
    }
    return _web; 
}

-(UIView *)toolBar
{
    if (!_toolBar)
    {
        CGFloat toolbarH = 35;
        UIView *toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - toolbarH - 64, [UIScreen mainScreen].bounds.size.width, toolbarH)];
//        toolBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tool_background"]];
        toolBar.backgroundColor = [UIColor clearColor];
        _toolBar = toolBar;
        
        // 添加收藏按钮
        UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeContactAdd];
        [addBtn addTarget:self action:@selector(saveWeb) forControlEvents:UIControlEventTouchUpInside];
        [toolBar addSubview:addBtn];
        
        CGRect frame = CGRectMake(170, 0, 35, 35);
        addBtn.frame = frame;
    }
    return _toolBar;
}

- (void)setModel:(XMWebModel *)model
{
    _model = model;
    // 初始化参数
    self.hasOpenNewWebmodule = NO;
    self.currentURL = model.webURL;
    
    // 传递模型
    [self.web loadRequest:[NSURLRequest requestWithURL:model.webURL]];
    [self.view addSubview:self.toolBar];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)dealloc
{
    NSLog(@"XMWebViewController-----------dealloc");
}

#pragma mark - ViewControllerDelegate的代理方法

- (void)webViewDidScrollToBottom
{
    [_web stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.scrollTo(0,%ld);",_webHeight ]];
}

- (void)webViewDidScrollToTop
{
    [_web stringByEvaluatingJavaScriptFromString:@"window.scrollTo(0,0);"];
}


#pragma mark - 保存网页按钮
- (void)saveWeb
{
    // 保存网站到本地
    [XMWebModelTool saveWebModel:self.model];
    // 提示用户保存网页成功
    [MBProgressHUD showSuccess:@"已成功添加到收藏夹" toView:self.web];
}

#pragma mark - 长按保存网页图片
- (void)longPress:(UILongPressGestureRecognizer *)longP
{
    if (longP.state == UIGestureRecognizerStateBegan)
    {
        CGPoint touchPoint = [longP locationInView:self.web];
        
#warning note 这两句代码是关键,当点击到图片时,urlToSave即为点击图片的url,当点击文字返回值为空
        NSString *imgURL = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", touchPoint.x, touchPoint.y];
        NSString *urlToSave = [self.web stringByEvaluatingJavaScriptFromString:imgURL];
        
        if (urlToSave.length)
        {
            [self showActionSheet:urlToSave];
        }
    
    };
    
}


/**
 长按网页上的图片触发弹框
 */
- (void)showActionSheet:(NSString *)imageUrl
{
    UIAlertController *tips = [[UIAlertController alloc] init];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    //    UIAlertActionStyleDestructive：红色的按钮
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"保存图片到本地相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        // 当点击确定执行的块代码
        [self savePictrue:imageUrl];
    }];
    
    [tips addAction:cancelAction];
    [tips addAction:okAction];
    
    [self presentViewController:tips animated:YES completion:nil];
}

/**
 点击了保存图片的按钮
 */
- (void)savePictrue:(NSString *)imageUrl
{
    // 对于网页上的图片,需要发起一个网络请求
    NSURL *url = [NSURL URLWithString:imageUrl];
    
    NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue new]];
    
    NSURLRequest *imgRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30.0];
    
    NSURLSessionDownloadTask  *task = [session downloadTaskWithRequest:imgRequest completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            return ;
        }
        
        NSData * imageData = [NSData dataWithContentsOfURL:location];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIImage * image = [UIImage imageWithData:imageData];
            
#warning note 保存相片到本地的方法,头文件写着必须实现一个@selector(image:didFinishSavingWithError:contextInfo:),此外,还需要设置info.plist的一个key
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        });   
    }];
    
    [task resume];
}

/** 提示用户保存图片成功与否(系统必须实现的方法) */
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        [MBProgressHUD showMessage:@"保存失败" toView:self.view];
    }else{
        [MBProgressHUD showMessage:@"保存成功" toView:self.view];
    }
}

#pragma mark - delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
//    NSString *urlString = request.URL.absoluteString;
//    // 点击一个网络连接时,会多次触发该代理方法,要对网络请求进行过滤
//    if ( ![urlString isEqualToString:self.currentURL.absoluteString] && ![urlString isEqualToString:@"about:blank"] && ![urlString containsString:@"ucbrowser://"] && ![urlString containsString:@"webview/static/"] && ![urlString containsString:@"m.sp.uczzd.cn"])
//    {
//        NSLog(@"=======%@",self.currentURL.absoluteString);
//        NSLog(@"=======%@",urlString);
//        XMWebModel *model = [[XMWebModel alloc] init];
//        model.webURL = request.URL;
//        // 通知代理发送网络请求
//        if ([self.delegate respondsToSelector:@selector(openWebmoduleRequest:)])
//        {
//            [_delegate openWebmoduleRequest:model];
//        }
//        // 打开一个新的webmodule,原网站保持原来的url申请
//        return NO;
//    }

//    if (self.hasOpenNewWebmodule) return NO;
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSString *urlString = webView.request.URL.absoluteString;
    if ([urlString isEqualToString:@""]) return;
    if ( ![webView.request.URL.absoluteString isEqualToString:self.currentURL.absoluteString])
    {
        // 标记已经打开了新的页面
        self.hasOpenNewWebmodule = YES;
        NSLog(@"=======%@",self.currentURL.absoluteString);
        NSLog(@"=======%@",webView.request.URL.absoluteString);
        XMWebModel *model = [[XMWebModel alloc] init];
        model.webURL = webView.request.URL;
        // 通知代理发送网络请求
        if ([self.delegate respondsToSelector:@selector(openWebmoduleRequest:)])
        {
            [_delegate openWebmoduleRequest:model];
        }
    }
}

@end
