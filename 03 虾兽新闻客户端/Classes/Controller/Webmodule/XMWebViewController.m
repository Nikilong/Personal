//
//  XMWebViewController.m
//  03 虾兽新闻客户端
//
//  Created by admin on 17/2/27.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "XMWebViewController.h"
#import "XMWebModelTool.h"
#import "MBProgressHUD+NK.h"

#define XMBackImageVStarX ([UIScreen mainScreen].bounds.size.width / (3))

@interface XMWebViewController ()<UIWebViewDelegate,NSURLSessionDelegate,UIGestureRecognizerDelegate>

/** 网页高度 */
@property (nonatomic, assign) NSInteger webHeight;

/** 工具条 */
@property (nonatomic, strong) UIView *toolBar;

/** 网页view */
@property (nonatomic, strong) UIWebView *web;

/** 记录当前的网络请求 */
@property (nonatomic, strong) NSURL *currentURL;

/** searchMode模块 */
// 标记是否是searchMode
@property (nonatomic, assign, getter=isSearchMode)  BOOL searchMode;
// 记录加载过的request
@property (nonatomic, strong) NSMutableArray *searchUrlArr;

// 标记右划开始的卫士
@property (nonatomic, assign)  CGFloat starX;

// 截图相框
@property (weak, nonatomic)  UIImageView *backImageV;
@end

@implementation XMWebViewController

- (UIWebView *)web
{
    if (_web == nil)
    {
        _web = [[UIWebView alloc] init];
        _web.frame = CGRectMake(0, -20, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height + 20);
        _web.delegate = self;
        [self.view addSubview:_web];
        
        // 添加长按手势
        UILongPressGestureRecognizer *longP = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
#warning note 这里需要设置长按反应时间<0.5将系统的长按覆盖掉
        longP.minimumPressDuration = 0.25;
        [_web addGestureRecognizer:longP];
        
        // 添加右划关闭当前webmodule手势
        UIPanGestureRecognizer *panTocCloseWebmodule = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panToCloseWebmodule:)];
        panTocCloseWebmodule.delegate = self;
        [_web addGestureRecognizer:panTocCloseWebmodule];
        
        //获取a标签的地址,但是有的使用div和span去做容器
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(aaa:)];
//        tap.delegate = self;
//        [self.web addGestureRecognizer:tap];
        
    }
    return _web; 
}
//获取a标签的地址,但是有的使用div和span去做容器
//- (void)aaa:(UITapGestureRecognizer *)tap{
//    if (tap.state == UIGestureRecognizerStateEnded)
//    {
//        CGPoint touchP = [tap locationInView:self.web];
////        NSString *string = [NSString stringWithFormat:@"var a =document.elementFromPoint(%f,%f).tagName;alert(a)",touchP.x,touchP.y];
//        NSString *string = @"var a=new Array();a= document.getElementsByTagName('DIV').childNodes;alert(a)";
//        NSString *str = [self.web stringByEvaluatingJavaScriptFromString:string];
//        NSLog(@"-----%@",str);
//    }
//}

- (NSMutableArray *)searchUrlArr
{
    if (!_searchUrlArr)
    {
        _searchUrlArr = [[NSMutableArray alloc] init];
    }
    return _searchUrlArr;
}

-(UIView *)toolBar
{
    if (!_toolBar)
    {
        CGFloat toolbarH = 35;
        UIView *toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - toolbarH, [UIScreen mainScreen].bounds.size.width, toolbarH)];
//        toolBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tool_background"]];
        toolBar.backgroundColor = [UIColor clearColor];
        _toolBar = toolBar;
        
        // 添加收藏按钮
        UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeContactAdd];
        [addBtn addTarget:self action:@selector(saveWeb) forControlEvents:UIControlEventTouchUpInside];
        [toolBar addSubview:addBtn];
        
        CGRect addBtnF = CGRectMake(0, 0, 35, 35);
        addBtn.frame = addBtnF;
        
        // 添加滚到最底部
        UIButton *downBtn = [[UIButton alloc] init];
        [downBtn setImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
        [downBtn addTarget:self action:@selector(webViewDidScrollToBottom) forControlEvents:UIControlEventTouchUpInside];
        [toolBar addSubview:downBtn];
        
        CGRect downBtnF = CGRectMake([UIScreen mainScreen].bounds.size.width - 35, 0, 35, 35);
        downBtn.frame = downBtnF;
        
    }
    return _toolBar;
}

- (void)setModel:(XMWebModel *)model
{
    _model = model;
    // 初始化参数
    self.currentURL = model.webURL;
    self.searchMode = model.searchMode;
    // 为searchmode添加左划返回手势
    if (self.searchMode)
    {
        UISwipeGestureRecognizer *swip = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backToPreviosURL)];
        swip.direction = UISwipeGestureRecognizerDirectionLeft;
        swip.delegate = self;
        [self.web addGestureRecognizer:swip];
    }
    // 传递模型
    [self.web loadRequest:[NSURLRequest requestWithURL:model.webURL]];
    [self.view addSubview:self.toolBar];
}

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 截图
    UIGraphicsBeginImageContextWithOptions([UIScreen mainScreen].bounds.size, YES, [UIScreen mainScreen].scale);
    [[UIApplication sharedApplication].keyWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    // 将截图放到底部的图片框上,否则会出现黑底
    UIImageView *backImageV = [[UIImageView alloc] initWithImage:img];
    backImageV.frame = CGRectMake(-XMBackImageVStarX, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    self.backImageV = backImageV;
#warning 核心代码,需要把图片加到这上面,如果加到self.view上面会在pop之后闪一下黑色
    [self.navigationController.view.superview insertSubview:backImageV belowSubview:self.navigationController.view];
    
    // 必须先截图再截屏.否则会没有导航条
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // 当导航控制器栈顶控制器不是webmodule时,即将回到main界面或者save界面,恢复导航栏可见(此时self已经从导航控制器的栈中移除)
    if(![self.navigationController.childViewControllers.lastObject isKindOfClass:[XMWebViewController class]])
    {
        self.navigationController.navigationBarHidden = NO;
    }
}


- (void)dealloc
{
    NSLog(@"XMWebViewController-----------dealloc");
}

#pragma mark - 提供一个类方法让外界打开webmodule
+ (void)openWebmoduleWithModel:(XMWebModel *)model viewController:(UIViewController *)vc
{
    // 创建一个webmodule
    XMWebViewController *webVC = [[XMWebViewController alloc] init];
    webVC.model = model;
    webVC.view.frame = vc.view.bounds;
    // 压到导航控制器的栈顶
    [vc.navigationController pushViewController:webVC animated:YES];
}

#pragma mark - 右划关闭webmodule
- (void)panToCloseWebmodule:(UIPanGestureRecognizer *)pan
{
    
    if (self.navigationController.childViewControllers.count == 1) return;
    // 手势加载web上面,web随着手的滑动而滑动,需要参考一个不懂的坐标,需要转换坐标系
    CGFloat currentX = [self.web convertPoint:[pan locationInView:self.web] toView:self.view].x;
    switch (pan.state) {
        case UIGestureRecognizerStateBegan: // 拖拽开始
            // 记录一开始的触点,
            self.starX = [self.web convertPoint:[pan locationInView:self.web] toView:self.view].x;
            break;
            
        case UIGestureRecognizerStateChanged: // 拖拽改变
        {
            if (currentX < self.starX) return;
            // 一开始web在最左边,因此直接加上滑动距离即可
            self.web.transform = CGAffineTransformMakeTranslation(currentX - self.starX, 0);
            // 同时让toolbar跟着移动
            self.toolBar.transform = CGAffineTransformMakeTranslation(currentX - self.starX, 0);;
            // 同时让backImageV跟着移动
            self.backImageV.transform = CGAffineTransformMakeTranslation((currentX - self.starX) * XMBackImageVStarX / [UIScreen mainScreen].bounds.size.width, 0);
            // 同时将透明度随着距离改变(效果不好,多开webmodule会由于上层变透明会看到上上层)
          //self.backImageV.alpha = (currentX / [UIScreen mainScreen].bounds.size.width)* 2/3 + 0.33;
            break;
        }
        case UIGestureRecognizerStateEnded: // 拖拽结束
        {
            // 拖拽距离超过rightContentView的相对位置0.3时决定弹回还是隐藏
            [self showRightContentView:self.web.frame.origin.x < [UIScreen mainScreen].bounds.size.width * 0.3];
            break;
        }
        default:
            break;
    }
}

- (void)showRightContentView:(BOOL)canShow
{
    CGFloat duration = 0.30f;
    if (canShow) // 显示
    {
        // 恢复成一开始最左边的位置
        [UIView animateWithDuration:duration animations:^{
            // web backImageV toolBar 三个要联动
            self.web.transform = CGAffineTransformIdentity;
            self.backImageV.transform = CGAffineTransformIdentity;
            self.toolBar.transform = CGAffineTransformIdentity;
        }];
    }else
    {
        // 将webmodule关闭掉
        [UIView animateWithDuration:duration animations:^{
            // web backImageV toolBar 三个要联动
            self.web.transform = CGAffineTransformMakeTranslation([UIScreen mainScreen].bounds.size.width, 0);
            self.toolBar.transform = CGAffineTransformMakeTranslation([UIScreen mainScreen].bounds.size.width, 0);
            self.backImageV.transform = CGAffineTransformMakeTranslation(XMBackImageVStarX, 0);
        }completion:^(BOOL finished) {
            // 移除背景相框
            [self.backImageV removeFromSuperview];
            // 移到最右边结束时pop掉当前vc
#warning note 这里必须关闭动画效果,不然会有重复的pop效果
            [self.navigationController popViewControllerAnimated:NO];
        }];
    }
}


#pragma mark - ViewControllerDelegate的代理方法

- (void)webViewDidScrollToBottom
{
    // 利用scrollview滚动的方法滚到最底部,原生的带有动画效果
    [self.web.scrollView setContentOffset:CGPointMake(0, self.webHeight) animated:YES];
}

- (void)webViewDidScrollToTop
{
    [self.web stringByEvaluatingJavaScriptFromString:@"window.scrollTo(0,0);"];
}


#pragma mark - 保存网页按钮
- (void)saveWeb
{
    // 保存网站到本地
    [XMWebModelTool saveWebModel:self.model];
    // 提示用户保存网页成功
    [MBProgressHUD showSuccess:@"已成功添加到收藏夹" toView:self.web];
}

#pragma mark - 长按保存网页图片/弹出分享
- (void)longPress:(UILongPressGestureRecognizer *)longP
{
    if (longP.state == UIGestureRecognizerStateBegan)
    {
        CGPoint touchPoint = [longP locationInView:self.web];
        
#warning note 这两句代码是关键,当点击到图片时,urlToSave即为点击图片的url,当点击文字返回值为空
        NSString *imgURL = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", touchPoint.x, touchPoint.y];
        NSString *urlToSave = [self.web stringByEvaluatingJavaScriptFromString:imgURL];
        
        if (urlToSave.length) // 有地址证明长按了图片区域
        {
            [self showActionSheet:urlToSave];
        }else // 没有返回地址就是长按了文字区域
        {
            [self showShareVC];
        }
    
    };
    
}

/**
 长按网页上的文字触发分享
 */
- (void)showShareVC
{
    return;
    // 取出分享参数
    NSURL *url = self.model.webURL;
    NSString *title = self.model.title;
    NSArray *params = @[url,title];
    
    // 创建分享菜单,这里分享为全部平台,可通过设置excludedActivityTypes属性排除不要的平台
    UIActivityViewController *actVC = [[UIActivityViewController alloc] initWithActivityItems:params applicationActivities:nil];
    
    // 弹出分享菜单
    [self presentViewController:actVC animated:YES completion:nil];

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

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *urlString = request.URL.absoluteString;
    // 点击一个网络连接时,会多次触发该代理方法,要对网络请求进行过滤
    if (!self.searchMode && ![urlString isEqualToString:self.currentURL.absoluteString] && ![urlString isEqualToString:@"about:blank"] && ![urlString containsString:@"ucbrowser://"] && ![urlString containsString:@"webview/static/"] && ![urlString containsString:@"m.sp.uczzd.cn"] && ![urlString containsString:@"/app"] && ![urlString containsString:@".js"])
    {
        NSLog(@"=======%@",self.currentURL.absoluteString);
        NSLog(@"=======%@",urlString);
        XMWebModel *model = [[XMWebModel alloc] init];
        model.webURL = request.URL;
        
        // 调用方法打开新的webmodule
        [XMWebViewController openWebmoduleWithModel:model viewController:self];

        // 打开一个新的webmodule,原网站保持原来的url申请
        return NO;
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {

    self.model.title = [self.web stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.webHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"] intValue];
    // 当请求不一样的时候添加进数组保存起来
    if (![self.searchUrlArr.lastObject isEqual:webView.request])
    {
        [self.searchUrlArr addObject:webView.request];
    }
    //    NSString *currentURL = [webView stringByEvaluatingJavaScriptFromString:@"document.location.href"];
    //    NSString *urlString = webView.request.URL.absoluteString;
//    NSLog(@"=======%@",urlString);
//    NSLog(@"=======%@",currentURL);
    
}

#pragma mark - searchMode的返回处理
/** 左划swipe手势触发的方法 */
- (void)backToPreviosURL
{
    // 返回到根页面应该屏蔽手势
    if (self.searchUrlArr.count == 1) return;
    // 取出上一个url请求在发送申请
    [self.searchUrlArr removeLastObject];
    [self.web loadRequest:self.searchUrlArr.lastObject];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    // 当触发swipe手势时,可能会触发pan手势等手势
    if ([gestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]])
    {
        // swip根据state会触发两次,或者会同时触发pan手势,这都是可以的
        if ([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] || [otherGestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]])
        {
            return YES;
        }
        // 当web页面有滚动图片时,还会触发一个页面的类似于pan的手势,此时应该屏蔽swipe手势
        return NO;
    }
 
    // 当滑动手势伴随着其他手势,例如图片滑动等手势时,禁止右划关闭webmodule
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
    {
        if (otherGestureRecognizer)
        {
            return NO;
        }
    }
    return YES;
    
}

@end
