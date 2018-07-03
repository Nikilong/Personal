//
//  XMWebViewController.m
//  虾兽维度
//
//  Created by admin on 17/2/27.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "XMWebViewController.h"
#import "XMWebModelTool.h"
#import "UIView+getPointColor.h"
#import "XMImageUtil.h"
#import "MBProgressHUD+NK.h"
#import "XMImageUtil.h"
#import "XMSavePathUnit.h"

@interface XMWebViewController ()<UIWebViewDelegate,NSURLSessionDelegate,UIGestureRecognizerDelegate>

/** 网页高度 */
//@property (nonatomic, assign) NSInteger webHeight;

/** 工具条 */
@property (nonatomic, strong) UIView *toolBar;
@property (weak, nonatomic)  UIButton *saveBtn;
@property (nonatomic, strong) NSMutableArray *toolBarArr;  // 应该隐藏的工具栏按钮

/** 网页view */
@property (nonatomic, strong) UIWebView *web;

/** 记录最初的网络请求 */
@property (nonatomic, strong) NSURL *originURL;

/** 标价是否第一个打开的webmodule */
@property (nonatomic, assign, getter=isFirstWebmodule)  BOOL firstWebmodule;

/** searchMode模块 */
// 标记是否是searchMode
@property (nonatomic, assign, getter=isSearchMode)  BOOL searchMode;
@property (nonatomic, strong)  UIPanGestureRecognizer *panSearchMode;
@property (weak, nonatomic)  UIImageView *backImgV;
@property (weak, nonatomic)  UIImageView *forwardImgV;


// 防止多次加载
@property (nonatomic, assign)  BOOL canLoad;

// 标记右划开始的位置
@property (nonatomic, assign)  CGFloat starX;
@property (weak, nonatomic)  UIPanGestureRecognizer *panToCloseWebmodule;

// 截图相框
@property (weak, nonatomic)  UIImageView *backImageV;

/** statusBar相关*/
// 网页导航栏颜色
@property (nonatomic, strong) UIColor *webNavColor;
// 状态栏
@property (nonatomic, strong) UIView *statusBar;
// 状态栏遮罩
@property (weak, nonatomic)  UIView *statusCover;
@end

@implementation XMWebViewController

#pragma mark 常量区
- (double)getBackImageVStarX{
    return  [UIScreen mainScreen].bounds.size.width / 3;
}

- (double)getSearchModePanDistance{
    return 150;
}


#pragma mark - 初始化
- (UIWebView *)web
{
    if (_web == nil)
    {
        _web = [[UIWebView alloc] init];
        _web.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        _web.delegate = self;
        _web.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:_web];
        
        // 初始化标记,能够加载
        self.canLoad = YES;
        
//        _web.scalesPageToFit = YES;
////        _web.userInteractionEnabled = YES;
//        _web.multipleTouchEnabled = YES;
        
        // 添加长按手势
        UILongPressGestureRecognizer *longP = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
#warning note 这里需要设置长按反应时间<0.5将系统的长按覆盖掉
        longP.minimumPressDuration = 0.25;
        [_web addGestureRecognizer:longP];
        
        // 添加右划关闭当前webmodule手势
        UIPanGestureRecognizer *panToCloseWebmodule = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panToCloseWebmodule:)];
        panToCloseWebmodule.delegate = self;
        self.panToCloseWebmodule = panToCloseWebmodule;
        [_web addGestureRecognizer:panToCloseWebmodule];
        
        // 添加五次点击closeWebmodule
        UITapGestureRecognizer *tapRemove = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeWebModule)];
        tapRemove.numberOfTapsRequired = 5;
        tapRemove.delegate = self;
        [self.web addGestureRecognizer:tapRemove];
        
        // 添加双击恢复缩放大小
        UITapGestureRecognizer *tapDouble = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapToScaleIdentity)];
        tapDouble.numberOfTapsRequired = 2;
        tapDouble.delegate = self;
        [self.web addGestureRecognizer:tapDouble];
        
//        // 添加双指滚到最上面或者最下面手势
//        UISwipeGestureRecognizer *swip = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(scroll:)];
//        [_web addGestureRecognizer:swip];
//        swip.delegate = self;
//        swip.numberOfTouchesRequired = 2;
    }
    return _web; 
}

-(UIView *)toolBar
{
    if (!_toolBar)
    {
        // 初始化数组
        self.toolBarArr = [NSMutableArray array];
        
        CGFloat toolbarW = 35;
        UIView *toolBar = [[UIView alloc] init];
        toolBar.backgroundColor = [UIColor clearColor];
        toolBar.alpha = 0.7;
        _toolBar = toolBar;
        
        // 添加滚到最顶部
        UIButton *upBtn = [[UIButton alloc] init];
        upBtn.hidden = YES;
        [upBtn setImage:[UIImage imageNamed:@"up"] forState:UIControlStateNormal];
        [upBtn addTarget:self action:@selector(webViewDidScrollToTop) forControlEvents:UIControlEventTouchUpInside];
        [toolBar addSubview:upBtn];
        CGRect upBtnF = CGRectMake(0, 0, toolbarW, toolbarW);
        upBtn.frame = upBtnF;
        [self.toolBarArr addObject:upBtn];
        // 添加滚到最底部
        UIButton *downBtn = [[UIButton alloc] init];
        downBtn.hidden = YES;
        [downBtn setImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
        [downBtn addTarget:self action:@selector(webViewDidScrollToBottom) forControlEvents:UIControlEventTouchUpInside];
        [toolBar addSubview:downBtn];
        CGRect downBtnF = CGRectMake(0, CGRectGetMaxY(upBtnF) + 10, toolbarW, toolbarW);
        downBtn.frame = downBtnF;
        [self.toolBarArr addObject:downBtn];
        // 添加滚到最顶部
        UIButton *freshBtn = [[UIButton alloc] init];
        freshBtn.hidden = YES;
        [freshBtn setImage:[UIImage imageNamed:@"shuaxin"] forState:UIControlStateNormal];
        [freshBtn addTarget:self action:@selector(webViewDidFresh) forControlEvents:UIControlEventTouchUpInside];
        [toolBar addSubview:freshBtn];
        CGRect freshBtnF = CGRectMake(0, CGRectGetMaxY(downBtnF) + 10, toolbarW, toolbarW);
        freshBtn.frame = freshBtnF;
        [self.toolBarArr addObject:freshBtn];
        // 添加收藏按钮
        UIButton *addBtn = [[UIButton alloc] init];
        addBtn.hidden = YES;
        self.saveBtn = addBtn;
        [addBtn addTarget:self action:@selector(saveWeb:) forControlEvents:UIControlEventTouchUpInside];
        [addBtn setImage:[UIImage imageNamed:@"save_normal"] forState:UIControlStateNormal];
        [addBtn setImage:[UIImage imageNamed:@"save_selected"] forState:UIControlStateSelected];
        [toolBar addSubview:addBtn];
        CGRect addBtnF = CGRectMake(0, CGRectGetMaxY(freshBtnF) + 10, toolbarW, toolbarW);
        addBtn.frame = addBtnF;
        [self.toolBarArr addObject:addBtn];
        // 添加强制关闭webmodule按钮
        UIButton *backBtn = [[UIButton alloc] init];
        backBtn.hidden = YES;
        [backBtn setImage:[UIImage imageNamed:@"clear"] forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(closeWebModule) forControlEvents:UIControlEventTouchUpInside];
        [toolBar addSubview:backBtn];
        CGRect backBtnF = CGRectMake(0, CGRectGetMaxY(addBtnF) + 10, toolbarW, toolbarW);
        backBtn.frame = backBtnF;
        [self.toolBarArr addObject:backBtn];
        
        
        // 隐藏/显示toolbar的其他按钮
        UIButton *showHideBtn = [UIButton buttonWithType:UIButtonTypeContactAdd];
        showHideBtn.selected = YES;
        [showHideBtn addTarget:self action:@selector(showHideToolBarButton:) forControlEvents:UIControlEventTouchUpInside];
        [toolBar addSubview:showHideBtn];
        CGRect showHideBtnF = CGRectMake(0, CGRectGetMaxY(backBtnF) + 10, toolbarW, toolbarW);
        showHideBtn.frame = showHideBtnF;
        
        // 计算toolbar居中
        CGFloat toolbarH = CGRectGetMaxY(showHideBtnF);
        CGFloat toolBarY = [UIScreen mainScreen].bounds.size.height - toolbarH - 50;
        _toolBar.frame = CGRectMake(20, toolBarY, toolbarW, toolbarH);
        
        _toolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    }
    return _toolBar;
}


- (UIView *)statusBar
{
    if (!_statusBar)
    {
        _statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    }
    return _statusBar;
}
- (UIView *)statusCover
{
    if (!_statusCover)
    {
        UIView *statusCover = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20)];
        statusCover.backgroundColor = self.webNavColor;
        statusCover.hidden = YES;
        [self.statusBar addSubview:statusCover];
        _statusCover = statusCover;
    }
    return _statusCover;
}

- (void)setModel:(XMWebModel *)model
{
    _model = model;
    // 初始化参数
    self.originURL = model.webURL;
    self.searchMode = model.searchMode;
    self.firstWebmodule = model.isFirstRequest;
    // 传递模型
    [self.web loadRequest:[NSURLRequest requestWithURL:model.webURL]];
    // 为searchmode添加左划返回手势
    if (self.searchMode)
    {
        [self initSearchMode];
    }
    [self.view addSubview:self.toolBar];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSUserDefaults standardUserDefaults] setInteger:2 forKey: @"WebKitCacheModelPreferenceKey"];
    //这里是调用的私有api，
    //把WevView类的cacheModel设置成WebCacheModelPrimaryWebBrowser，
    //因为这个上架被拒绝的人可不在少数，这里需要进行特殊处理。
    id webView = [self.web valueForKeyPath:@"_internal.browserView._webView"];
    id preferences = [webView valueForKey:@"preferences"];
    [preferences performSelector:@selector(_postCacheModelChangedNotification)];
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
    if (!self.backImageV)
    {
        UIImageView *backImageV = [[UIImageView alloc] initWithImage:img];
        backImageV.frame = CGRectMake(-[self getBackImageVStarX], 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        _backImageV = backImageV;
    
#warning 核心代码,需要把图片加到这上面,如果加到self.view上面会在pop之后闪一下黑色
        [self.navigationController.view.superview insertSubview:self.backImageV belowSubview:self.navigationController.view];
    }
    
    // 必须先截图再截屏.否则会没有导航条
    self.navigationController.navigationBarHidden = YES;
    self.statusBar.backgroundColor = self.webNavColor;
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // 当导航控制器栈顶控制器不是webmodule时,即将回到main界面或者save界面,恢复导航栏可见(此时self已经从导航控制器的栈中移除)
    if(![self.navigationController.childViewControllers.lastObject isKindOfClass:[XMWebViewController class]])
    {
        self.navigationController.navigationBarHidden = NO;
        // 恢复状态栏颜色,原来的为空
        self.statusBar.backgroundColor = nil;
        [self.statusCover removeFromSuperview];
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

#pragma mark - toolbar 点击事件

/** web滚到最底部*/
- (void)webViewDidScrollToBottom
{
    // 获取网页高度
    CGFloat webHeight = [[self.web stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"] doubleValue];
    
    // 利用scrollview滚动的方法滚到最底部,原生的带有动画效果
    [self.web.scrollView setContentOffset:CGPointMake(0, webHeight - [UIScreen mainScreen].bounds.size.height) animated:YES];
}

/** web滚到顶部 */
- (void)webViewDidScrollToTop
{
    [self.web stringByEvaluatingJavaScriptFromString:@"window.scrollTo(0,0);"];
}

/** web重新加载 */
- (void)webViewDidFresh
{
    [self.web reload];
}

/** 临时方法,将webmodule关闭掉 */
- (void)closeWebModule
{
    self.navigationController.navigationBarHidden = NO;
    // 恢复状态栏颜色,原来的为空
    self.statusBar.backgroundColor = nil;
    [self.statusCover removeFromSuperview];
    [self.navigationController popViewControllerAnimated:YES];
}

/** 保存网页 */
- (void)saveWeb:(UIButton *)button
{
    // 取反选择状态
    button.selected = !button.isSelected;
#warning undo 重复收藏该网页,以及searchMode下的切换
    if (button.isSelected)
    {
        XMWebModel *model = [[XMWebModel alloc] init];
        // 保存的网站需要取消searchMode标记
        model.searchMode = NO;
        model.webURL = [NSURL URLWithString:self.web.request.URL.absoluteString];
        model.title =  [self.web stringByEvaluatingJavaScriptFromString:@"document.title"];
        // 保存网站到本地
        [XMWebModelTool saveWebModel:model];
        // 提示用户保存网页成功
        [MBProgressHUD showSuccess];
    }
}


/**
 显示/隐藏toolbar的其他按钮
 */
- (void)showHideToolBarButton:(UIButton *)btn{
    // 按钮状态取反,然后设置toolbar其他按钮的隐藏与否
    btn.selected = !btn.selected;
    for (UIButton *toolBtn in self.toolBarArr) {
        toolBtn.hidden = btn.selected;
    }
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
    // 取出分享参数
    NSURL *url = self.model.webURL ? self.model.webURL : [NSURL URLWithString:@""];
    NSString *title = self.model.title ? self.model.title : @"";
    NSArray *params = @[url,title];
    
    // 创建分享菜单,这里分享为全部平台,可通过设置excludedActivityTypes属性排除不要的平台
    UIActivityViewController *actVC = [[UIActivityViewController alloc] initWithActivityItems:params applicationActivities:nil];
    
    // 弹出分享菜单
    [self presentViewController:actVC animated:YES completion:nil];

}

/**
 长按网页上的图片触发弹框
 */
- (void)showActionSheet:(NSString *)imageUrl{
    __weak typeof(self) weakSelf= self;
    UIAlertController *tips = [[UIAlertController alloc] init];
    [tips addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [tips addAction:[UIAlertAction actionWithTitle:@"保存图片到本地相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        // 当点击确定执行的块代码
        [XMImageUtil savePictrue:imageUrl path:nil callBackViewController:weakSelf];
    }]];
    [tips addAction:[UIAlertAction actionWithTitle:@"保存图片到本地缓存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        NSString *path = [XMSavePathUnit getWifiImageTempDirPath];
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]){
            [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil];
        }
        [XMImageUtil savePictrue:imageUrl path:path callBackViewController:weakSelf];
    }]];
    
    // 判断是否含有二维码
    NSString *qrMsg = [XMImageUtil detectorQRCodeImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]]];
    if(qrMsg){
        UIAlertAction *qrAction = [UIAlertAction actionWithTitle:@"识别图中二维码" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
            // 当点击确定执行的块代码
            XMWebModel *model = [[XMWebModel alloc] init];
            model.webURL = [NSURL URLWithString:qrMsg];
            if(self.navigationController){
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [XMWebViewController openWebmoduleWithModel:model viewController:self];
            }

        }];
        
        [tips addAction:qrAction];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self presentViewController:tips animated:YES completion:nil];
    });
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
    NSLog(@"=======%@",request.URL.absoluteString);
    // 开启网络加载
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    // 过滤名单
    if([request.URL.absoluteString containsString:@".js"] || [request.URL.absoluteString containsString:@"eclick.baidu.com"] || [request.URL.absoluteString containsString:@"pos.baidu.com"])
    {
        // 关闭网络加载
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        return NO;
    }
    // 当处于searchMode模式或者还没有加载完成网页的时候允许加载网页
    if (self.searchMode) // 必须先判断是否是searchMode
    {
        return YES;
    }else if(self.canLoad || [request.URL.absoluteString containsString:@"//feed.baidu.com"] || [request.URL.absoluteString containsString:@"//m.baidu.com/feed/data/videoland"] )
    {
        // 百度新闻或者视频的逻辑是先m.baidu.com/...一个网站,此时需要新开一个webmodule,然后在新开的webmodule任由其加载即可,百度的图集(http//feed.baidu.com/..),视频(http://m.baidu.com/feed/data/videoland/..)
        return YES;
    }else
    {
//        NSLog(@"=======%@",self.originURL.absoluteString);
        // 加载完成之后如果下一个网络请求不一样就是点击了新的网页,同时需要保证链接能打开
        if (![self.originURL.absoluteString isEqualToString:request.URL.absoluteString] && [[UIApplication sharedApplication] canOpenURL:request.URL])
        {
            XMWebModel *model = [[XMWebModel alloc] init];
            model.webURL = request.URL;
            
            // 调用方法打开新的webmodule
            [XMWebViewController openWebmoduleWithModel:model viewController:self];
        }
        // 关闭网络加载
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        // 当网页完成加载之后,禁止再重新加载
        return NO;
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    // 关闭网络加载
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    // 设置statusBar随页面的颜色改变
    self.webNavColor = [webView colorOfPoint:CGPointMake(10, 21)];
    self.statusBar.backgroundColor = self.webNavColor;
    // 禁止完成加载之后再去加载网页
    self.canLoad = NO;
    // 加载完成之后判断是否需要添加searchMode的pan手势
    if(self.web.canGoBack || self.web.canGoForward)
    {
        [self.web addGestureRecognizer:self.panSearchMode];
    }
    if (self.isSearchMode){
        self.saveBtn.selected = NO;
    }
    
    // 设置网页自动缩放,user-scalable为NO即可禁止缩放
    NSString *injectionJSString =@"var script = document.createElement('meta');"
    "script.name = 'viewport';"
    "script.content=\"width=device-width, initial-scale=1.0,maximum-scale=3.0, minimum-scale=1.0, user-scalable=yes\";"
    "document.getElementsByTagName('head')[0].appendChild(script);";
    
    [self.web stringByEvaluatingJavaScriptFromString:injectionJSString];
    

    
}

#pragma mark - uigestureDelegate
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

#pragma mark - 手势
#pragma mark 右划关闭webmodule
- (void)panToCloseWebmodule:(UIPanGestureRecognizer *)pan
{
    // 手势加载web上面,web随着手的滑动而滑动,需要参考一个不懂的坐标,需要转换坐标系
    CGFloat currentX = [self.web convertPoint:[pan locationInView:self.web] toView:self.view].x;
    switch (pan.state) {
        case UIGestureRecognizerStateBegan: // 拖拽开始
            // 记录一开始的触点,
            self.starX = [self.web convertPoint:[pan locationInView:self.web] toView:self.view].x;
            if (self.isFirstWebmodule)
            {
                // 修改状态栏颜色
                self.statusBar.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0];
                self.statusCover.hidden = NO;
            }
            break;
            
        case UIGestureRecognizerStateChanged: // 拖拽改变
        {
            if (currentX < self.starX)
            {
                if (self.searchMode && self.web.canGoForward)
                {
                    self.forwardImgV.hidden = NO;
                    // 防止过多移动右箭头
                    if (self.starX - currentX > self.forwardImgV.frame.size.width + 10) return;
                    self.forwardImgV.transform = CGAffineTransformMakeTranslation(currentX - self.starX, 0);
                }
                break;
                
            }
            // 一开始web在最左边,因此直接加上滑动距离即可
            self.web.transform = CGAffineTransformMakeTranslation(currentX - self.starX, 0);
            // 同时让toolbar  backImageV  statusCover跟着移动
            self.toolBar.transform = CGAffineTransformMakeTranslation(currentX - self.starX, 0);;
            self.backImageV.transform = CGAffineTransformMakeTranslation((currentX - self.starX) * [self getBackImageVStarX] / [UIScreen mainScreen].bounds.size.width, 0);
            if (self.isFirstWebmodule)
            {
                self.statusCover.transform = CGAffineTransformMakeTranslation(currentX - self.starX, 0);;
            }
            // 同时将透明度随着距离改变(效果不好,多开webmodule会由于上层变透明会看到上上层)
            //self.backImageV.alpha = (currentX / [UIScreen mainScreen].bounds.size.width)* 2/3 + 0.33;
            break;
        }
        case UIGestureRecognizerStateEnded: // 拖拽结束
        {
            if(self.searchMode)
            {
                if(![self.web canGoBack] && self.starX - currentX > [self getSearchModePanDistance])
                {
                    self.forwardImgV.transform = CGAffineTransformIdentity;
                    self.forwardImgV.hidden = YES;
                    [self.web goForward];
                }
            }
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
            if (self.isFirstWebmodule)
            {
                // 修改状态栏颜色
                self.statusBar.backgroundColor = self.webNavColor;
                self.statusCover.transform = CGAffineTransformIdentity;
                self.statusCover.hidden = YES;
            }
        }];
    }else
    {
        // 将webmodule关闭掉
        [UIView animateWithDuration:duration animations:^{
            // web backImageV toolBar 三个要联动
            self.web.transform = CGAffineTransformMakeTranslation([UIScreen mainScreen].bounds.size.width, 0);
            self.toolBar.transform = CGAffineTransformMakeTranslation([UIScreen mainScreen].bounds.size.width, 0);
            self.backImageV.transform = CGAffineTransformMakeTranslation([self getBackImageVStarX], 0);
            if (self.isFirstWebmodule)
            {
                self.statusCover.transform = CGAffineTransformMakeTranslation([UIScreen mainScreen].bounds.size.width, 0);
            }
        }completion:^(BOOL finished) {
            if (self.isFirstWebmodule)
            {
                self.statusCover.hidden = YES;
            }
            // 移除背景相框
            [self.backImageV removeFromSuperview];
            // 移到最右边结束时pop掉当前vc
#warning note 这里必须关闭动画效果,不然会有重复的pop效果
            [self.navigationController popViewControllerAnimated:NO];
        }];
    }
}

/**
 双击恢复正常缩放
 */
- (void)doubleTapToScaleIdentity{
    self.web.transform = CGAffineTransformIdentity;
}

#pragma mark - searchMode的返回处理
/** searchMode下手势触发的方法 */
- (void)panToBackForward:(UIGestureRecognizer *)gesture
{
    if ([gesture isKindOfClass:[UIPanGestureRecognizer class]])
    {
        // 如果是pan手势,需要根据左划还是右划决定返回还是向前
        switch (gesture.state) {
            case UIGestureRecognizerStateBegan:
            {
                self.starX = [gesture locationInView:self.web].x;
                break;
            }
            case UIGestureRecognizerStateChanged:
            {
                CGFloat panShift = [gesture locationInView:self.web].x - self.starX;
                // 超过左右箭头的大小则不再移动箭头
                if (panShift > self.backImgV.frame.size.width + 10 || -panShift > self.forwardImgV.frame.size.width + 10) return;
                // 根据左划或者右划移动箭头
                if (panShift > 0 && self.web.canGoBack)
                {
                    self.backImgV.hidden = NO;
                    self.backImgV.transform = CGAffineTransformMakeTranslation(panShift, 0);
                }else if(panShift < 0 && self.web.canGoForward)
                {
                    self.forwardImgV.hidden = NO;
                    self.forwardImgV.transform = CGAffineTransformMakeTranslation(panShift, 0);
                }
                break;
            }
            case UIGestureRecognizerStateEnded:
            {
                CGFloat panShift = [gesture locationInView:self.web].x - self.starX;
                // 右划且滑动距离大于50,表示应该返回,反之左划并且距离大于50表示向前,并复位左右两个箭头
                if (panShift > [self getSearchModePanDistance])
                {
                    self.backImgV.transform = CGAffineTransformIdentity;
                    [self.web goBack];
                    // 检测是否最后一页,移除searchMode下的pan手势
                    if (!self.web.canGoBack)
                    {
                        [self.web removeGestureRecognizer:self.panSearchMode];
                    }
                    
                }else if(panShift < -[self getSearchModePanDistance])
                {
                    self.forwardImgV.transform = CGAffineTransformIdentity;
                    [self.web goForward];
                }
                
                // 手势结束之后隐藏两边箭头
                self.backImgV.hidden = YES;
                self.forwardImgV.hidden = YES;
                break;
            }
            default:{
                self.forwardImgV.transform = CGAffineTransformIdentity;
                self.backImageV.transform = CGAffineTransformIdentity;
                self.forwardImgV.hidden = YES;
                self.backImageV.hidden = YES;
                
            }
                break;
        }
    }else  // 双击返回手势
    {
        if(gesture.state == UIGestureRecognizerStateEnded)
        {
            [self.web goBack];
        }
    }
}

/**  searchMode下初始化 */
- (void)initSearchMode
{
    // 添加左右两个箭头
    CGFloat imgVWH = 50;
    UIImageView *backImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchMode_back"]];
    backImgV.frame = CGRectMake(-imgVWH, CGRectGetMidY([UIScreen mainScreen].bounds), imgVWH, imgVWH);
    backImgV.hidden = YES;
    self.backImgV = backImgV;
    self.backImgV.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.web addSubview:backImgV];
    UIImageView *forwardImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchMode_forward"]];
    forwardImgV.frame = CGRectMake(CGRectGetMaxX([UIScreen mainScreen].bounds), CGRectGetMidY([UIScreen mainScreen].bounds), imgVWH, imgVWH);
    forwardImgV.hidden = YES;
    self.forwardImgV = forwardImgV;
    self.forwardImgV.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self.web addSubview:forwardImgV];
    
    // 为searchmode添加前进后退手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panToBackForward:)];
    pan.delegate = self;
    self.panSearchMode = pan;
    
    // 添加3击页面返回手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(panToBackForward:)];
    tap.numberOfTapsRequired = 3;
    tap.delegate = self;
    [self.web addGestureRecognizer:tap];

}

@end
