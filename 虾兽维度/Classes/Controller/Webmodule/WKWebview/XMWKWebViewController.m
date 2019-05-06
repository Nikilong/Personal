//
//  XMWKWebViewController.m
//  虾兽维度
//
//  Created by admin on 18/8/14.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "XMWKWebViewController.h"
#import "XMWebModelLogic.h"
#import "XMSaveWebModelLogic.h"
#import "UIView+getPointColor.h"
#import "XMImageUtil.h"
#import "MBProgressHUD+NK.h"
#import "XMSavePathUnit.h"

#import "AppDelegate.h"
#import "XMRightBottomFloatView.h"
#import "XMWXVCFloatWindow.h"
#import "XMWXFloatWindowIconConfig.h"
#import "XMNavigationController.h"
#import "XMDropView.h"
#import "XMSearchTableViewController.h"
#import <WebKit/WebKit.h>
#import <ImageIO/ImageIO.h>
#import "NSURLProtocol+WKWebview.h"
#import "XMVisualView.h"
#import "XMPhotoCollectionViewController.h"
#import "XMWebMultiWindowCollectionViewController.h"
#import "XMMutiWindowFlowLayout.h"
#import "XMTabBarController.h"
#import "XMBaseNavViewController.h"
#import <AVKit/AVKit.h>

#import <DKNightVersion/DKNightVersion.h>

@interface XMWKWebViewController ()<
NSURLSessionDelegate,
UIGestureRecognizerDelegate,
UIScrollViewDelegate,
WKUIDelegate,
WKNavigationDelegate,
XMOpenWebmoduleProtocol,
XMVisualViewDelegate,
XMWebMultiWindowCollectionViewControllerDelegate>

/** 网页高度 */
//@property (nonatomic, assign) NSInteger webHeight;

/** 工具条 */
@property (nonatomic, strong) UIView *toolBar;
@property (weak, nonatomic)  UIButton *saveBtn;
@property (weak, nonatomic)  UIButton *toolBarBackBtn;
@property (weak, nonatomic)  UIButton *toolBarForwardBtn;
@property (weak, nonatomic)  UILabel *multiWindowCountLab;  // TODO:多窗口功能


/** 网页view */
@property (nonatomic, strong) WKWebView *wkWebview;
@property (weak, nonatomic)  UIView *containerV;
@property (weak, nonatomic)  UIView *navToolV;
@property (weak, nonatomic)  UILabel *navToolTitleLab;
@property (weak, nonatomic)  UIView *navToolBtnContentV;
@property (weak, nonatomic)  UIButton *navToolLeftBtn;
@property (weak, nonatomic)  UIButton *navToolRightBtn;

/// 进度条
@property (weak, nonatomic)  UIProgressView *progerssV;

/// 记录上一次的位置
@property (nonatomic, assign)  CGFloat lastContentY;

/// 记录是否在滚动
@property (nonatomic, assign)  BOOL isScroller;
/// 记录是否在拖拽
@property (nonatomic, assign)  BOOL isDrag;
/// 记录是否显示当前webmodule
@property (nonatomic, assign)  BOOL isShow;
/// 记录是否允许跳转到app store
@property (nonatomic, assign)  BOOL canOpenAppstore;

/** 记录最初的网络请求 */
@property (nonatomic, strong) NSURL *originURL;

/** 标价是否第一个打开的webmodule */
@property (nonatomic, assign, getter=isFirstWebmodule)  BOOL firstWebmodule;

/** searchMode模块 */
// 标记是否是searchMode
@property (nonatomic, assign, getter=isSearchMode)  BOOL searchMode;
@property (nonatomic, strong)  UIPanGestureRecognizer *panSearchMode;
@property (weak, nonatomic)  UIView *backForIconContainV;

// 记录图片点击手势
@property (weak, nonatomic)  UITapGestureRecognizer *tap;


// 防止多次加载
@property (nonatomic, assign)  BOOL canLoad;

// 标记右划开始的位置
@property (nonatomic, assign)  CGFloat starX;

// 导航栏右边功能栏
@property (nonatomic, strong) XMDropView *navRightDropV;
@property (weak, nonatomic)  UIButton *darkModeBtn;  // 更多护眼模式按钮

/** statusBar相关*/
// 状态栏
@property (nonatomic, strong) UIView *statusBar;
// 状态栏遮罩
@property (weak, nonatomic)  UIView *statusCover;

/// 图片组
@property (nonatomic, strong) NSArray *imageArr;
@property (nonatomic, strong) NSArray *imageRegArr;

@end

@implementation XMWKWebViewController


// 统计网络请求次数
static NSUInteger requestCount = 0;
#pragma mark 常量区

/// 前进后退箭头的宽高
static double backForwardImagVWH = 50.0;
/// 前进返回的不触发距离,超过这个距离才触发,防止和网页中的滚动手势冲突
static double backForwardSafeDistance = 80.0;

/// 截图的初始左偏移距离
- (double)getBackImageVStarX{
    return  [UIScreen mainScreen].bounds.size.width / 3;
}

///// 返回前进的滑动距离
//- (double)getSearchModePanDistance{
//    return 150;
//}

/// 底部tabbar高度
- (double)getBottomToolBarHeight{
    if(isIphoneX){
        return 65;
    }else{
        return 49;
    }
}

/// 导航栏及底部tabbar的背景颜色
- (UIColor *)getNavColor{
    return RGB(242, 242, 242);
}


#pragma mark - 初始化
- (WKWebView *)wkWebview{
    if (_wkWebview == nil){
        
        NSMutableString*javascript = [NSMutableString string];
        //禁止长按弹出
//        [javascript appendString:@"document.documentElement.style.webkitTouchCallout='none';"];
        //javascript 注入
        WKUserScript *noneSelectScript = [[WKUserScript alloc] initWithSource:javascript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        
        WKUserContentController *userContentController = [[WKUserContentController alloc] init];
        [userContentController addUserScript:noneSelectScript];

        WKWebViewConfiguration * configuration = [[WKWebViewConfiguration alloc]init];
        configuration.userContentController = userContentController;
        
        // y方向距离为导航栏初始高度44+状态栏高度
        _wkWebview = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, XMScreenW, XMScreenH - XMStatusBarHeight - 44) configuration:configuration];
        _wkWebview.UIDelegate = self;
        _wkWebview.scrollView.delegate = self;
        _wkWebview.navigationDelegate = self;
        _wkWebview.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.containerV insertSubview:_wkWebview belowSubview:self.navToolV];
        
//        // 开启左划右划返回
//        _wkWebview.allowsBackForwardNavigationGestures = YES;
        // 初始化标记,能够加载
        self.canLoad = YES;

        // 添加双击恢复缩放大小
        UITapGestureRecognizer *tapDouble = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapToScaleIdentity)];
        tapDouble.numberOfTapsRequired = 2;
        tapDouble.delegate = self;
        [_wkWebview addGestureRecognizer:tapDouble];

        // 添加双指滚到最上面或者最下面手势
        UISwipeGestureRecognizer *swipUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(doubleFingerSwipe:)];
        [_wkWebview addGestureRecognizer:swipUp];
        swipUp.delegate = self;
        swipUp.direction = UISwipeGestureRecognizerDirectionUp;
        swipUp.numberOfTouchesRequired = 2;
        UISwipeGestureRecognizer *swipDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(doubleFingerSwipe:)];
        [_wkWebview addGestureRecognizer:swipDown];
        swipDown.delegate = self;
        swipDown.direction = UISwipeGestureRecognizerDirectionDown;
        swipDown.numberOfTouchesRequired = 2;
        
        // 图片点击手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(webviewDidTap:)];
        tap.delegate = self;
        self.tap = tap;
        [_wkWebview addGestureRecognizer:tap];
        
    }
    return _wkWebview;
}

- (UIView *)containerV{
    if (!_containerV){
        UIView *containerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        _containerV = containerV;
        [self.view addSubview:containerV];
        
        // 沉浸式导航栏
        UIView *navToolV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, XMScreenW, 2)];
        self.navToolV = navToolV;
        [_containerV addSubview:navToolV];
        navToolV.backgroundColor = [UIColor clearColor];
        
        // 进度条
        UIProgressView *progressV = [[UIProgressView alloc] init];
        self.progerssV = progressV;
        progressV.progressTintColor = [UIColor orangeColor];
        [navToolV addSubview:progressV];
        progressV.translatesAutoresizingMaskIntoConstraints = NO;
        // 垂直方向约束
        [navToolV addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[progressV(2)]-0-|" options:0 metrics:nil views:@{@"progressV":progressV}]];
        // 水平方向约束
        [navToolV addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[progressV(>=0)]-0-|" options:0 metrics:nil views:@{@"progressV":progressV}]];

        // 标题栏
        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, XMScreenW - 88, 44)];
        self.navToolTitleLab = titleLab;
        titleLab.textAlignment = NSTextAlignmentCenter;
        titleLab.font = [UIFont systemFontOfSize:15];
        titleLab.textColor = [UIColor whiteColor];
        self.navigationItem.titleView = titleLab;
        titleLab.userInteractionEnabled = YES;
        self.navigationItem.titleView.userInteractionEnabled = YES;
        // 点击事件
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(naVTitleLabDidClick)];
        [titleLab addGestureRecognizer:tap];
        
        
        // 左边按钮
        UIButton *leftBtn = [[UIButton alloc] init];
        self.navToolLeftBtn = leftBtn;
        [leftBtn setImage:[UIImage imageNamed:@"navTool_close_white"] forState:UIControlStateNormal];
        [leftBtn addTarget:self action:@selector(closeWebModule) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
        
        // 右边按钮
        UIButton *rightBtn = [[UIButton alloc] init];
        self.navToolRightBtn = rightBtn;
        [rightBtn setImage:[UIImage imageNamed:@"navTool_more_white"] forState:UIControlStateNormal];
        [rightBtn addTarget:self action:@selector(callNavRightDropView) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    }
    return _containerV;
}

- (UIView *)toolBar{
    if (!_toolBar){
        // TODO:多窗口功能 @{@"image": @"webview_multiwindow",@"selectImage": @"",@"selector":@"openMultiWindowViewController"}
        NSArray *tabbarBtnData = @[
       @{@"image": @"webview_goback",@"selectImage": @"webview_goback_disable",@"selector":@"webViewDidGoBack"},
       @{@"image": @"webview_goforward",@"selectImage": 
             @"webview_goforward_disable",@"selector":@"webViewDidGoForward"},
       @{@"image": @"webview_new",@"selectImage": @"",@"selector":@"openNewModule:"},
       @{@"image": @"shuaxin",@"selectImage": @"",@"selector":@"webViewDidFresh"},
       @{@"image": @"save_normal",@"selectImage": @"save_selected",@"disableImage": @"",@"selector":@"saveWeb:"},
                                   ];
        CGFloat toolbarW = [self getBottomToolBarHeight];
        CGFloat btnWH = 49;
        NSUInteger btnNumber = tabbarBtnData.count;
        CGFloat margin = (XMScreenW - btnNumber * btnWH) / ( btnNumber + 1);

        UIView *toolBar = [[UIView alloc] initWithFrame: CGRectMake(0,XMScreenH - toolbarW - XMStatusBarHeight - 44, XMScreenW, toolbarW)];
//        toolBar.backgroundColor = [self getNavColor];
        toolBar.dk_backgroundColorPicker = DKColorPickerWithColors([self getNavColor], XMNavDarkBG);
        _toolBar = toolBar;
        _toolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;

        for (NSUInteger i = 0; i < btnNumber; i++) {
            UIButton *btn = [[UIButton alloc] init];
            [btn addTarget:self action:NSSelectorFromString(tabbarBtnData[i][@"selector"]) forControlEvents:UIControlEventTouchUpInside];
            [btn setImage:[UIImage imageNamed:tabbarBtnData[i][@"image"]] forState:UIControlStateNormal];
            if (![tabbarBtnData[i][@"selectImage"] isEqualToString:@""]){
                [btn setImage:[UIImage imageNamed:tabbarBtnData[i][@"selectImage"]] forState:UIControlStateSelected];
            }
            [toolBar addSubview:btn];
            btn.frame = CGRectMake(margin + i * ( margin + btnWH ), 0, btnWH, btnWH);
            if(i == 0){
                self.toolBarBackBtn = btn;
                self.toolBarBackBtn.selected = YES;
            }else if (i == 1){
                self.toolBarForwardBtn = btn;
                self.toolBarForwardBtn.selected = YES;
//            }else if (i == 2){  // TODO:多窗口功能
//                UILabel *lab = [[UILabel alloc] initWithFrame:btn.bounds];
//                self.multiWindowCountLab = lab;
//                lab.textAlignment = NSTextAlignmentCenter;
//                lab.font = [UIFont systemFontOfSize:9];
//                lab.textColor = [UIColor grayColor];
//                [btn addSubview:lab];
//                
//                // 添加长按手势
//                UILongPressGestureRecognizer *longP = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(multipWindowDidLongPress:)];
//                [btn addGestureRecognizer:longP];
            }else if (i == 4){
                self.saveBtn = btn;
            }
        }

    }
    return _toolBar;
}


- (UIView *)statusBar{
    if (!_statusBar){
        _statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    }
    return _statusBar;
}

- (UIView *)statusCover{
    if (!_statusCover){
        UIView *statusCover = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, XMStatusBarHeight)];
        statusCover.backgroundColor = nil;
        statusCover.hidden = YES;
        [self.statusBar addSubview:statusCover];
        _statusCover = statusCover;
        
        // 点击事件
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(webViewDidScrollToTop)];
        [statusCover addGestureRecognizer:tap];
    }
    return _statusCover;
}

- (NSArray *)imageArr{
    if (!_imageArr) {
        _imageArr = [NSArray array];
    }
    return _imageArr;
}

- (NSArray *)imageRegArr{
    if (!_imageRegArr) {
        _imageRegArr = [NSArray array];
    }
    return _imageRegArr;
}

- (void)setModel:(XMWebModel *)model{
    
    _model = model;
    // 初始化参数
    self.originURL = model.webURL;
    self.searchMode = model.searchMode;
    self.firstWebmodule = model.isFirstRequest;
    // 传递模型
    [self.wkWebview loadRequest:[NSURLRequest requestWithURL:model.webURL]];
    // 为searchmode添加左划返回手势
    if (self.searchMode){
        [self initSearchMode];
    }
    // 在此处添加底部工具条
    [self.containerV addSubview:self.toolBar];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化参数
    self.lastContentY = 0;
    self.isShow = NO;
    self.peekMode = NO;
//    [self initlizeContainerView];
    
    /// wkwebview注册scheme,实现NSURLProtocol监听
//    [NSURLProtocol wk_registerScheme:@"http"];
//    [NSURLProtocol wk_registerScheme:@"https"];
    
    // 播放视频不受静音按键控制
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    // 观察进度条
    [self.wkWebview addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];

    // 显示状态栏盖罩
    self.statusCover.hidden = NO;
    // 记录即将显示
    self.isShow = YES;
    // 检查是否已经保存该网址(防止appdelte的直接打开时检测不到)
    self.saveBtn.selected = [XMSaveWebModelLogic isWebURLHaveSave:self.wkWebview.URL.absoluteString];
    
//    // TODO:设置窗口数字
//    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    self.multiWindowCountLab.text = [NSString stringWithFormat:@"%ld",app.webModuleStack.count];
    
    // 监听退出全屏
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitFullScreen:) name:UIWindowDidBecomeHiddenNotification object:nil];
    
    // 设置peek模式的toolbar位置
    self.toolBar.hidden = self.peekMode;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self markScrollDidEnd];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 当导航控制器栈顶控制器不是webmodule时,即将回到main界面或者save界面,恢复导航栏可见(此时self已经从导航控制器的栈中移除)
    if(![self.navigationController.childViewControllers.lastObject isKindOfClass:[XMWKWebViewController class]]){
        
        // 恢复状态栏颜色,原来的为空
        self.statusBar.backgroundColor = nil;
        [self.statusCover removeFromSuperview];
    }
    // 隐藏状态栏盖罩
    self.statusCover.hidden = YES;
    
    // 记录即将隐藏
    self.isShow = NO;
    
    // 移除全屏监听
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIWindowDidBecomeHiddenNotification object:nil];
}


- (void)dealloc{
    self.wkWebview.UIDelegate = nil;
    self.wkWebview.navigationDelegate = nil;
    self.wkWebview.scrollView.delegate = nil;
    
    [self.wkWebview removeObserver:self forKeyPath:@"estimatedProgress"];

    // 取消加载指示
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSLog(@"XMWebViewController-----------dealloc");
}

//- (void)initlizeContainerView{
//
//}

#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.progerssV.progress = self.wkWebview.estimatedProgress;
        if (self.progerssV.progress == 1){
            [UIView animateWithDuration:0.25f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                     self.progerssV.transform = CGAffineTransformMakeScale(1.0f, 1.4f);
                 }completion:^(BOOL finished){
                     self.progerssV.hidden = YES;
                 }];
        }
    }
}


#pragma mark - 提供一个类方法让外界创建webmodule
+ (UIViewController *)webmoduleWithModel:(XMWebModel *)model{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    // 如果module为空,则返回上一个缓存的webmodule
    if(model == nil){
        if(app.tempWebModuleVC){
            app.tempWebModuleVC.peekMode = NO;
            return app.tempWebModuleVC;
        }
        return  nil;
    }
    
    // 先判断是否和上一个pop掉的webmodule的url相同,相同的话就不必再去重复加载
    if ([app.tempWebModuleVC.originURL.absoluteString isEqualToString:model.webURL.absoluteString]){
        app.tempWebModuleVC.peekMode = NO;
        return app.tempWebModuleVC;
    }else{
        app.tempWebModuleVC = nil;
        // 创建一个webmodule
        XMWKWebViewController *webVC = [[XMWKWebViewController alloc] init];
        app.tempWebModuleVC = webVC;
        webVC.model = model;
        //        webVC.view.frame = vc.view.bounds;
        return webVC;
    }
}
+ (UIViewController *)webmoduleWithURL:(NSString *)url isSearchMode:(BOOL)searchMode{
    XMWebModel *model = [[XMWebModel alloc] init];
    model.searchMode = searchMode;
    model.webURL = [NSURL URLWithString:url];
    return [self webmoduleWithModel:model];
}

#pragma mark - peek预览的按钮事件
- (NSArray<id<UIPreviewActionItem>> *)previewActionItems{
    __weak typeof(self) weakSelf = self;
    // 收藏/取消收藏按钮
    BOOL isSave = [XMSaveWebModelLogic isWebURLHaveSave:self.model.webURL.absoluteString];
    UIPreviewAction * saveAct = [[UIPreviewAction alloc] init];
    if(isSave){
        saveAct = [UIPreviewAction actionWithTitle:@"取消收藏" style:UIPreviewActionStyleDestructive handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
            btn.selected = YES;
            [weakSelf saveWeb:btn];
        }];
    }else{
        saveAct = [UIPreviewAction actionWithTitle:@"收藏" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
            [weakSelf saveWeb:nil];
        }];
    }
    return @[saveAct];
}

#pragma mark - toolbar和导航栏 点击事件

/** web滚到最底部*/
- (void)webViewDidScrollToBottom{
    
    // 获取网页高度
    __weak typeof(self) weakSelf = self;
    [self.wkWebview evaluateJavaScript:@"document.body.offsetHeight" completionHandler:^(id _Nullable height, NSError * _Nullable error) {
        CGFloat webHeight = [height doubleValue];
        // 利用scrollview滚动的方法滚到最底部,原生的带有动画效果
        [weakSelf.wkWebview.scrollView setContentOffset:CGPointMake(0, webHeight - [UIScreen mainScreen].bounds.size.height) animated:YES];
    }];
    
    
}

/** web滚到顶部 */
- (void)webViewDidScrollToTop{
    [self toggleBottomBar:YES];
    [self.wkWebview.scrollView setContentOffset:CGPointZero animated:YES];
}

/** web重新加载 */
- (void)webViewDidFresh{
    [self.wkWebview reload];
}

/** web后退 */
- (void)webViewDidGoBack{
    if([self.wkWebview canGoBack]){
        [self.wkWebview goBack];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.toolBarForwardBtn.selected = !self.wkWebview.canGoForward;
            self.toolBarBackBtn.selected = !self.wkWebview.canGoBack;
        });
    }
}

/** web前进 */
- (void)webViewDidGoForward{
    if([self.wkWebview canGoForward]){
        [self.wkWebview goForward];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.toolBarForwardBtn.selected = !self.wkWebview.canGoForward;
            self.toolBarBackBtn.selected = !self.wkWebview.canGoBack;
        });
    }
}

/// 底部tabbar显示隐藏切换
- (void)toggleBottomBar:(BOOL)show{
    if(show &&  CGRectGetMaxY(self.toolBar.frame) == XMScreenH + [self getBottomToolBarHeight] - XMStatusBarHeight - 44){ //显示toolbar
        [UIView animateWithDuration:0.25f animations:^{
            self.toolBar.frame = CGRectMake(0, CGRectGetMinY(self.toolBar.frame) - [self getBottomToolBarHeight], XMScreenW, [self getBottomToolBarHeight]);
        }];
    }else if(show == NO && CGRectGetMaxY(self.toolBar.frame) == XMScreenH - XMStatusBarHeight - 44){
        [UIView animateWithDuration:0.25f animations:^{
            self.toolBar.frame = CGRectMake(0, CGRectGetMinY(self.toolBar.frame) + [self getBottomToolBarHeight], XMScreenW, [self getBottomToolBarHeight]);
        }];
    }
}

/** 保存网页 */
- (void)saveWeb:(UIButton *)button{

    if (button.isSelected){
        // 取消保存网站到本地
        [XMSaveWebModelLogic deleteWebURL:self.wkWebview.URL.absoluteString];
        // 提示用户取消保存网页成功
        [MBProgressHUD showSuccess:@"取消收藏成功"];
    }else{
        [self.wkWebview evaluateJavaScript:@"document.title" completionHandler:^(id _Nullable title, NSError * _Nullable error) {
            // 保存网站到本地
            [XMSaveWebModelLogic saveWebUrl:self.wkWebview.URL.absoluteString title:title];
            // 提示用户保存网页成功
            [MBProgressHUD showSuccess:@"收藏成功"];
        }];
    }
    // 取反选择状态
    button.selected = !button.isSelected;
}

/** 打开多窗口切换 */
- (void)openMultiWindowViewController{
    
    XMWebMultiWindowCollectionViewController *multiVC = [XMWebMultiWindowCollectionViewController shareWebMultiWindowCollectionViewController];
    multiVC.delegate = self;
    
    // 每次打开检查多窗口的截图和缓存栈的保存数目是否一致,否则需要更新多窗口的截图组
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    if(app.webModuleStack.count > multiVC.shotImageArr.count){
//        for (NSUInteger i = multiVC.shotImageArr.count; i < app.webModuleStack.count; i++) {
//            XMWKWebViewController *webmodule = app.webModuleStack[i];
//            [multiVC.shotImageArr addObject:[XMImageUtil screenShotWithView:webmodule.view]];
//        }
//        // 必须刷新
//        [multiVC.collectionView reloadData];
//    }
//    if(app.webModuleStack.count > multiVC.shotImageArr.count){
//        for (NSUInteger i = multiVC.shotImageArr.count; i < app.webModuleStack.count; i++) {
//            XMWKWebViewController *webmodule = app.webModuleStack[i];
//            [multiVC.shotImageArr addObject:[XMImageUtil screenShotWithView:webmodule.view]];
//        }
//        // 必须刷新
//        [multiVC.collectionView reloadData];
//    }else if(app.webModuleStack.count == multiVC.shotImageArr.count){
//        [multiVC.shotImageArr removeLastObject];
//        XMWKWebViewController *webmodule = [app.webModuleStack lastObject];
//        [multiVC.shotImageArr addObject:[XMImageUtil screenShotWithView:webmodule.view]];
//        // 必须刷新
//        [multiVC.collectionView reloadData];
//    }
    
    [self presentViewController:multiVC animated:YES completion:nil];
}

// 长按多窗口操作
- (void)multipWindowDidLongPress:(UILongPressGestureRecognizer *)gest{
    UIAlertController *tips = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) weakSelf = self;
    [tips addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [tips addAction:[UIAlertAction actionWithTitle:@"关闭所有标签" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        app.webModuleStack = nil;
        XMWebMultiWindowCollectionViewController *muliVC =[XMWebMultiWindowCollectionViewController shareWebMultiWindowCollectionViewController];
        muliVC.shotImageArr = nil;
        [muliVC.collectionView reloadData];
    }]];
    [tips addAction:[UIAlertAction actionWithTitle:@"新建一个标签" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        [weakSelf openNewModule:NO];
    }]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:tips animated:YES completion:nil];
    });

}

#pragma mark 导航栏的点击事件
/// 标题点击事件
- (void)naVTitleLabDidClick{
    [self openNewModule:YES];
}

/** 将webmodule关闭掉 */
- (void)closeWebModule{
    
    // 恢复状态栏颜色,原来的为空
    self.statusBar.backgroundColor = nil;
    [self.statusCover removeFromSuperview];
    if (![XMRightBottomFloatView shareRightBottomFloatView].isInArea){
        [self.navigationController popViewControllerAnimated:YES];
    }
}

/** 导航栏右边更多的dropview*/
- (void)callNavRightDropView{
    if (self.navRightDropV){
        [self changeDrakModeButtonStyle];   // 转换按钮图标和文字
        self.navRightDropV.hidden = NO;
    }else{
        
        // 整体
        UIView *containerV = [[UIView alloc] init];
        CGFloat btnW = 85;
        CGFloat btnH = 35;
        CGFloat padding = 5;       // 间隙
        NSUInteger colMaxNum = 1;      // 每行允许排列的图标个数
        
        // 工具箱按钮参数
        NSArray *moreBtnArr = @[@"分享",@"二维码",@"Safari",@"白天模式",@"浏览模式"];
        NSArray *moreBtnImgArr = @[@"navMoreBtn_share",@"navMoreBtn_code",@"navMoreBtn_safari",@"navMoreBtn_mode",@"navMoreBtn_searchMode"];
        NSUInteger btnNum = moreBtnArr.count;
        
        // 添加按钮
        CGFloat btnX;
        CGFloat btnY;
        for (int i = 0; i < btnNum; i++){
            btnX = padding + ( btnW + padding ) * (i % colMaxNum);
            btnY = padding + btnH * (i / colMaxNum);
            // 工具箱按钮
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(btnX, btnY, btnW, btnH)];
            [containerV addSubview:btn];
            btn.tag = i;
            btn.titleLabel.font = [UIFont systemFontOfSize:13];
            btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;  // 左对齐
            btn.titleEdgeInsets = UIEdgeInsetsMake(0, 7, 0, 0);
            [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            if(i != 3){
                [btn setTitle:moreBtnArr[i] forState:UIControlStateNormal];
                [btn setImage:[UIImage imageNamed:moreBtnImgArr[i]] forState:UIControlStateNormal];
            }else{
                self.darkModeBtn = btn;
                [self changeDrakModeButtonStyle];
            }
            [btn addTarget:self action:@selector(navRightMoreBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
            // 添加分割线
            if(i < btnNum - 1){
                UIView *lineV = [[UIView alloc] initWithFrame:CGRectMake(padding, CGRectGetMaxY(btn.frame), btnW, 1)];
                [containerV addSubview:lineV];
                lineV.backgroundColor = [UIColor grayColor];
            }
        }
        // 计算总的尺寸,x方向有间距,y方向无间距
        containerV.frame = CGRectMake(0, 0, padding + (padding + btnW) * (colMaxNum - 0),  btnH * ( (btnNum + colMaxNum - 1) / colMaxNum ));
        containerV.dk_backgroundColorPicker = DKColorPickerWithColors([UIColor whiteColor], XMNavDarkBG);
        
        // 创建dropview
        self.navRightDropV = [XMDropView dropView];
        self.navRightDropV.content = containerV;
        containerV.superview.dk_backgroundColorPicker = DKColorPickerWithColors([UIColor whiteColor], XMNavDarkBG);
        // 新创建的dropview指向titleview
        [self.navRightDropV showFrom:self.navToolRightBtn];
    }
}

/// 导航栏右边更多按钮点击事件
- (void)navRightMoreBtnDidClick:(UIButton *)btn{
    self.navRightDropV.hidden = YES;
    switch (btn.tag) {
        case 0:{ // 分享
            [self showShareVC];
            break;
        }
        case 1:{  // 生成当前网页的二维码
            NSString *url = self.wkWebview.URL.absoluteString ? self.wkWebview.URL.absoluteString : self.model.webURL.absoluteString;
            if(url){
                // 将当前的url的字符串转为二维码图片
                [self showQrImage:[XMImageUtil creatQRCodeImageWithString:url size:XMScreenW * 0.7]];
            }else{
                [MBProgressHUD showFailed:@"网址为空"];
            }
            break;
        }
        case 2:{ // Safari
            [[UIApplication sharedApplication] openURL:self.wkWebview.URL];
            break;
        }
        case 3:{ // 护眼模式
            if ([self.dk_manager.themeVersion isEqualToString:DKThemeVersionNight]) {
                [self.dk_manager dawnComing];
            } else {
                [self.dk_manager nightFalling];
            }
            [self changeDrakModeButtonStyle];   // 转换按钮图标和文字
            break;
        }
        case 4:{ // 浏览模式切换
            self.searchMode = !self.searchMode;
            if (self.searchMode){
                [self initSearchMode];
            }else{
                [self removeSearchMode];
            }
            [MBProgressHUD showMessage:self.searchMode ? @"已关闭新窗口模式" : @"已打开新窗口模式" ];
            break;
        }
        case 99:{ //
            break;
        }
        default:
            break;
    }
}


/// 切换更多中护眼模式按钮的文字和图片
- (void)changeDrakModeButtonStyle{
    if ([self.dk_manager.themeVersion isEqualToString:DKThemeVersionNight]) {
        [self.darkModeBtn setTitle:@"白天模式" forState:UIControlStateNormal];
        [self.darkModeBtn setImage:[UIImage imageNamed:@"navMoreBtn_mode_sun"] forState:UIControlStateNormal];
        
    }else{
        [self.darkModeBtn setTitle:@"夜间模式" forState:UIControlStateNormal];
        [self.darkModeBtn setImage:[UIImage imageNamed:@"navMoreBtn_mode"] forState:UIControlStateNormal];
    }
    
}


/// 展示二维码图片
- (void)showQrImage:(UIImage *)image{
    // 隐藏浮窗
    if([XMWXFloatWindowIconConfig isSaveFloatVCInUserDefaults]){
        [XMWXVCFloatWindow shareXMWXVCFloatWindow].hidden = YES;
    }
    
    // 创建二维码图片展示框
    XMVisualView *visualView = [XMVisualView creatVisualImageViewWithImage:image imageSize:CGSizeMake(XMScreenW * 0.7, XMScreenW * 0.7) blurEffectStyle:0];
    visualView.delegate = self;
    
}


/// 弹出分享菜单
- (void)showShareVC{
    
    __weak typeof(self) weakSelf = self;
    [self.wkWebview evaluateJavaScript:@"document.title" completionHandler:^(id _Nullable title, NSError * _Nullable error) {
        // 取出分享参数
        NSURL *url = [NSURL URLWithString:self.wkWebview.URL.absoluteString];
        if(!url){
            url = [NSURL URLWithString:@""];
        }
        if(!title){
            title = @"";
        }
        NSArray *params = @[url,title];
        
        // 创建分享菜单,这里分享为全部平台,可通过设置excludedActivityTypes属性排除不要的平台
        UIActivityViewController *actVC = [[UIActivityViewController alloc] initWithActivityItems:params applicationActivities:nil];
        
        // 弹出分享菜单
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf presentViewController:actVC animated:YES completion:nil];
        });
    }];
    
}


#pragma mark - 长按保存网页图片
- (void)longPress:(UILongPressGestureRecognizer *)longP{
    
    if (longP.state == UIGestureRecognizerStateBegan){
        CGPoint touchPoint = [longP locationInView:self.wkWebview];
        NSString *imgURL = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", touchPoint.x, touchPoint.y];
        __weak typeof(self) weakSelf = self;
        [self.wkWebview evaluateJavaScript:imgURL completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            NSString *urlToSave = (NSString *)result;
            if (urlToSave.length){
                // 有地址证明长按了图片区域
                [weakSelf showActionSheet:urlToSave];
            }
        }];

    };
    
}

/**
 长按网页上的图片触发弹框
 */
- (void)showActionSheet:(NSString *)imageUrl{
    __weak typeof(self) weakSelf= self;
    UIAlertController *tips = [[UIAlertController alloc] init];
    [tips addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    if(self.imageRegArr.count > 0){
        [tips addAction:[UIAlertAction actionWithTitle:@"图片模式" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
            // 找出点击的图片的序号
            NSUInteger index = weakSelf.imageRegArr.count;
            for (NSUInteger i = 0; i < weakSelf.imageRegArr.count; i++) {
                NSString *eleUrl = weakSelf.imageRegArr[i];
                // 警告:目前发现uc点击得到的地址包含从网页提取的地址,此处可能有隐患
                if([imageUrl containsString:eleUrl]){
                    index = i;
                    break;
                }
            }
//            if(index != weakSelf.imageRegArr.count){
                [weakSelf callPhotoDisplayViewcontrollerWithIndex:index];
//            }
        }]];
    }
    [tips addAction:[UIAlertAction actionWithTitle:@"分享图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        UIImage *shareImg = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]] scale:1.0f];
        // 创建分享菜单,这里分享为全部平台,可通过设置excludedActivityTypes属性排除不要的平台
        UIActivityViewController *actVC = [[UIActivityViewController alloc] initWithActivityItems:@[shareImg] applicationActivities:nil];
        // 弹出分享菜单
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf presentViewController:actVC animated:YES completion:nil];
        });
    }]];
    [tips addAction:[UIAlertAction actionWithTitle:@"新窗口打开" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        XMWebModel *model = [[XMWebModel alloc] init];
        model.webURL = [NSURL URLWithString:imageUrl];
        [weakSelf openWebmoduleRequest:model];
    }]];
    [tips addAction:[UIAlertAction actionWithTitle:@"复制图片地址" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setString:imageUrl];
    }]];
    [tips addAction:[UIAlertAction actionWithTitle:@"保存图片到系统相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        [XMImageUtil savePictrue:imageUrl path:nil callBackViewController:weakSelf];
    }]];
    [tips addAction:[UIAlertAction actionWithTitle:@"保存图片到本地缓存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        [XMImageUtil saveToLocalTempDirPicture:imageUrl];
    }]];
    // 判断是否含有二维码
    NSString *qrMsg = [XMImageUtil detectorQRCodeImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]]];
    if(qrMsg){
        [tips addAction:[UIAlertAction actionWithTitle:@"识别图中二维码" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
            // 当点击确定执行的块代码
            if(self.navigationController){
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                XMWebModel *model = [[XMWebModel alloc] init];
                model.webURL = [NSURL URLWithString:qrMsg];
                XMWKWebViewController *webmodule = (XMWKWebViewController *)[XMWKWebViewController webmoduleWithModel:model];
                [self.navigationController pushViewController:webmodule animated:YES];
            }
            
        }]];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self presentViewController:tips animated:YES completion:nil];
    });
}


/** 提示用户保存图片成功与否(系统必须实现的方法) */
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    [MBProgressHUD showResult:error ? NO :YES message:error ? @"保存失败" : @"保存成功"];
}

#pragma mark - XMWebMultiWindowCollectionViewControllerDelegate
- (void)webMultiWindowCollectionViewControllerCallForNewSearchModule:(XMWebMultiWindowCollectionViewController *)multiVC{
    
    [multiVC dismissViewControllerAnimated:YES completion:nil];
    
    [self openNewModule:NO];
}

/// 打开一个新的webmodule
- (void)openNewModule:(BOOL)isPassUrl{

    XMSearchTableViewController *searchVC = [[XMSearchTableViewController alloc] init];
    searchVC.delegate = self;
    XMBaseNavViewController *nav = [[XMBaseNavViewController alloc] initWithRootViewController:searchVC];
    [self presentViewController:nav animated:YES completion:^{
        if(isPassUrl){
            searchVC.passUrl = self.wkWebview.URL.absoluteString;
        }
    }];
}

#pragma mark - XMOpenWebmoduleProtocol
- (void)openWebmoduleWithURL:(NSString *)url isSearchMode:(BOOL)searchMode{
    XMWebModel *model = [[XMWebModel alloc] init];
    model.webURL = [NSURL URLWithString:url];
    model.searchMode = searchMode;
    [self openWebmoduleRequest:model];
}

//XMSearchTableViewController的代理方法,必须实现
- (void)openWebmoduleRequest:(XMWebModel *)webModel{
    XMWKWebViewController *webmodule = (XMWKWebViewController *)[XMWKWebViewController webmoduleWithModel:webModel];
    [self.navigationController pushViewController:webmodule animated:YES];
}

#pragma mark - WKUIDelegate
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    // wkWebView 点击链接无反应,多半是因为网页中有target="_blank" 在新窗口打开链接,而你有没有实现createWebViewWithConfiguration
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
//    NSLog(@"--%@---",navigationAction.request.URL.absoluteString);
    // 是否在过滤名单
    if ([self shoudlFilterRequest:navigationAction.request.URL.absoluteString] == NO){
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    // 过滤uc跳转
    if([navigationAction.request.URL.absoluteString containsString:@"ucbrowser://"]){
        decisionHandler(WKNavigationActionPolicyCancel);
        return;

    }
    
    // 防止拉起appstore
    if([navigationAction.request.URL.absoluteString containsString:@"https://itunes.apple.com/cn/app"]){
        UIAlertController *tips = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否允许跳转到App Store" preferredStyle:UIAlertControllerStyleAlert];
        __weak typeof(self) weakSelf = self;
        [tips addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            weakSelf.canOpenAppstore = NO;
            [weakSelf.wkWebview goBack];
        }]];
        [tips addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action){
            weakSelf.canOpenAppstore = YES;
            [weakSelf.wkWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:navigationAction.request.URL.absoluteString]]];
        }]];
        
        [self presentViewController:tips animated:YES completion:nil];
        if(!self.canOpenAppstore){
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    // 当处于searchMode模式或者还没有加载完成网页的时候允许加载网页
    if (!self.searchMode){
        // 必须先判断是否是searchMode
        // 加载完成之后如果下一个网络请求不一样就是点击了新的网页,同时需要保证链接能打开
        if (![self.originURL.absoluteString isEqualToString:navigationAction.request.URL.absoluteString] && [[UIApplication sharedApplication] canOpenURL:navigationAction.request.URL]){
            XMWebModel *model = [[XMWebModel alloc] init];
            model.webURL = navigationAction.request.URL;
            
            // NSLog(@"webmodule====%@",navigationAction.request.URL.absoluteString);
            // 调用方法打开新的webmodule
            XMWKWebViewController *webmodule = (XMWKWebViewController *)[XMWKWebViewController webmoduleWithModel:model];
            [self.navigationController pushViewController:webmodule animated:YES];
            // 当网页完成加载之后,禁止再重新加载
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
//    NSLog(@"webView开始加载,%@",webView.URL.absoluteString);
    // 新增一个网络请求
    [self startNewWebRequestCount];
    self.progerssV.hidden = NO;
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
//    NSLog(@"webview开始收到响应");
    decisionHandler(WKNavigationResponsePolicyAllow);
}

//-----------------显示开始加载html CSS js 和图片资源等（JS引擎单线程顺序执行）---------------

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {

}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
//    NSLog(@"webview结束加载内容");
    
    // 禁止完成加载之后再去加载网页
    self.canLoad = NO;
    
    // 判定全屏pop手势是否禁用以及前进后退两个箭头,需要在两个地方做判定,因为有时候后退不发起网络请求
    XMNavigationController *nav = (XMNavigationController *)self.navigationController;
    nav.customerPopGestureRecognizer.enabled = !self.wkWebview.canGoBack;
    self.toolBarForwardBtn.selected = !self.wkWebview.canGoForward;
    self.toolBarBackBtn.selected = !self.wkWebview.canGoBack;
    
    // 设置网页标题
    __weak typeof(self) weakSelf = self;
    [self.wkWebview evaluateJavaScript:@"document.title" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSString *title = (NSString *)result;
        // 添加进浏览历史
        [XMSaveWebModelLogic saveHistoryUrl:weakSelf.wkWebview.URL.absoluteString title:title];
        // 设置标题
        if(title.length > 0 && ![title isEqualToString:weakSelf.navToolTitleLab.text]){
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.navToolTitleLab.text = title;
            });
        }
    }];
    // 判断该网页是否已经保存
    self.saveBtn.selected = [XMSaveWebModelLogic isWebURLHaveSave:self.wkWebview.URL.absoluteString];
    
    
    // 记录网页高度
    //    self.webHeight = [[self.wkWebview evaluateJavaScript:@"document.body.offsetHeight"] doubleValue];
    
    // 设置网页自动缩放,user-scalable为NO即可禁止缩放
    NSString *injectionJSString =@"var script = document.createElement('meta');"
    "script.name = 'viewport';"
    "script.content=\"width=device-width, initial-scale=1.0,maximum-scale=3.0, minimum-scale=1.0, user-scalable=yes\";"
    "document.getElementsByTagName('head')[0].appendChild(script);";
    
    [self.wkWebview evaluateJavaScript:injectionJSString completionHandler:nil];
    
    // 删除广告节点
    [self webDidRemoveNode];
    
    // 检查是否可以图片模式
    [self checkImagesMode];
    
    // 完成一个网络加载
    [self finishNewWebRequestCount];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
//    NSLog(@"webview加载失败");
    [self finishNewWebRequestCount];
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
//    NSLog(@"开始重定向的函数");
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler{

    self.progerssV.hidden = YES;
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
}

#pragma mark 过滤规则+网络指示
/// 新增一个网络加载
- (void)startNewWebRequestCount{
    requestCount++;
    // 开启网络加载标志
    dispatch_async(dispatch_get_main_queue(), ^{
        if([UIApplication sharedApplication].isNetworkActivityIndicatorVisible == NO){
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        }
    });
}

/// 完成一个网络加载(成功或者失败)
- (void)finishNewWebRequestCount{
    requestCount--;
    // 关闭网络加载标志
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if([UIApplication sharedApplication].isNetworkActivityIndicatorVisible == YES){
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
    });
}

- (BOOL)shoudlFilterRequest:(NSString *)urlStr{
    // 加载过滤plist名单
    NSArray *filterArr = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"webFilterList.plist" ofType:nil]];
    
    for(NSString *keyWord in filterArr){
        if([urlStr containsString:keyWord]){
            return NO;
        }
    }
    return YES;
}

/// 移除广告节点
- (void)webDidRemoveNode{
    
    // 必须样式执行,因为广告是要一段时间才动态加载出来
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // uc全屏广告屏蔽:该广告div的class以"FloatLayer__floatlayer"开头
        [self.wkWebview evaluateJavaScript:@"$(\"div[class^='FloatLayer__floatlayer']\")[0].remove()" completionHandler:nil];
        //    uc底部轮播条的class为:slider__sdk__wrapper sdk__sharepage __web-inspector-hide-
        [self.wkWebview evaluateJavaScript:@"var deleteNode =document.getElementsByClassName('sdk__sharepage')[0];document.body.removeChild(deleteNode)" completionHandler:nil];
//        // uc"大家都在看"屏蔽,因为需要打开uc链接,base__wrapper__开头
//        [self.wkWebview evaluateJavaScript:@"var floatDiv =$(\"div[class^='base__wrapper']\")[0].remove()"];
        
        // 必应首页底部广告栏id=TopApp// BottomAppPro
        [self.wkWebview evaluateJavaScript:@"document.body.removeChild(document.getElementById('BottomAppPro'))" completionHandler:nil];
        // 百度新闻底部广告 id=oTLzC class= first-card-body
        [self.wkWebview evaluateJavaScript:@"document.body.removeChild(document.getElementsByClassName('first-card-main')[0])" completionHandler:nil];
    });
    
}

/// 检查是否有图片组,有图片组禁用网页原生弹框
- (void)checkImagesMode{
    __weak typeof(self) weakSelf = self;
    [self.wkWebview evaluateJavaScript:@"function xmGetImagesUrl(){var imageList = xissJsonData.images;var imageURLList = new Array();for (i=0;i<imageList.length;i++){imageURLList.push(imageList[i].url);};return imageURLList;};xmGetImagesUrl();" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSArray  *imageArr = [NSArray arrayWithArray:result];
        if(imageArr.count > 0){
            weakSelf.imageArr = [imageArr copy];
            [self addCustomerLongPress];
        }else{
            // TODO:正则表达式提取所有图片的url,效果不理想,先屏蔽
            [weakSelf.wkWebview evaluateJavaScript:@"document.documentElement.innerHTML" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                if(result){
                    [self addCustomerLongPress];
                    [weakSelf getImageurlFromHtml:result];
                }
            }];
        }
    }];
    
}

/// 添加自定义弹框
- (void)addCustomerLongPress{
    [self.wkWebview evaluateJavaScript:@"document.documentElement.style.webkitTouchCallout='none';" completionHandler:nil];
    // 添加长按手势
    UILongPressGestureRecognizer *longP = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    longP.delegate = self;
    //        longP.minimumPressDuration = 0.25;
    [self.wkWebview addGestureRecognizer:longP];
    
    [self.tap requireGestureRecognizerToFail:longP];
}


/// 提取所有图片的url
- (void)getImageurlFromHtml:(NSString *)webString{
    // 网页内容为空时返回
    if(webString == nil) return;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableArray * imageurlArray = [NSMutableArray array];
        //标签匹配
        NSString *parten = @"<img(.*?)>";
        NSError* error = NULL;
        NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:parten options:0 error:&error];
        
        NSArray* match = [reg matchesInString:webString options:0 range:NSMakeRange(0, [webString length] - 1)];
        
        for (NSTextCheckingResult * result in match) {
            
            //过去数组中的标签
            NSRange range = [result range];
            NSString * subString = [webString substringWithRange:range];
            
            
            //从图片中的标签中提取ImageURL
            NSRegularExpression *subReg = [NSRegularExpression regularExpressionWithPattern:@"(http|https)://(.*?)\"" options:0 error:NULL];
            NSArray* match = [subReg matchesInString:subString options:0 range:NSMakeRange(0, [subString length] - 1)];
            if(match.count > 0){
                NSTextCheckingResult * subRes = match[0];
                NSRange subRange = [subRes range];
                subRange.length = subRange.length -1;
                NSString * imagekUrl = [subString substringWithRange:subRange];
                
//                NSLog(@"%@",imagekUrl);
//                CGSize imgSize = [self getImageSizeWithURL:imagekUrl];
//                if(imgSize.width > 50 && imgSize.height > 50){
                    //将提取出的图片URL添加到图片数组中
                    [imageurlArray addObject:imagekUrl];
//                }
                
            }
        }
        // 去重
        imageurlArray = [imageurlArray valueForKeyPath:@"@distinctUnionOfObjects.self"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //NSLog(@"----图片模式开启");
            self.imageRegArr = [imageurlArray copy];
        });
    });
}

/**
 *  根据图片url获取图片尺寸
 */
- (CGSize)getImageSizeWithURL:(id)URL{
    NSURL * url = nil;
    if ([URL isKindOfClass:[NSURL class]]) {
        url = URL;
    }
    if ([URL isKindOfClass:[NSString class]]) {
        url = [NSURL URLWithString:URL];
    }
    if (!URL) {
        return CGSizeZero;
    }
    CGImageSourceRef imageSourceRef = CGImageSourceCreateWithURL((CFURLRef)url, NULL);
    CGFloat width = 0, height = 0;
    if (imageSourceRef) {
        CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSourceRef, 0, NULL);
        if (imageProperties != NULL) {
            CFNumberRef widthNumberRef = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelWidth);
            if (widthNumberRef != NULL) {
                CFNumberGetValue(widthNumberRef, kCFNumberFloat64Type, &width);
            }
            CFNumberRef heightNumberRef = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight);
            if (heightNumberRef != NULL) {
                CFNumberGetValue(heightNumberRef, kCFNumberFloat64Type, &height);
            }
            CFRelease(imageProperties);
        }
        CFRelease(imageSourceRef);
    }
    return CGSizeMake(width, height);
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y < 0 || self.isDrag == NO){
        // 到达最顶部和最底部,触发弹簧效果时,需要实时更新最后的y偏移,但是不能改变view的frame
        self.lastContentY = scrollView.contentOffset.y;
        return;
    }
    self.isScroller = YES;
    
    //toobar移动方案二,避免一直修改toolbar的frame,减少性能损耗
    if(scrollView.contentOffset.y > self.lastContentY){
        // 上滑隐藏toolbar
        [self toggleBottomBar:NO];
    }else if(scrollView.contentOffset.y < self.lastContentY){
        // 下滑显示toolbar
        [self toggleBottomBar:YES];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.isDrag = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    self.isDrag = NO;
    if(!decelerate){
        // 如果decelerate==NO,那么不走这个方法 - (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
        [self markScrollDidEnd];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self markScrollDidEnd];
}
    
/// 标记滚动结束
- (void)markScrollDidEnd{
    self.isScroller = NO;
}
    
#pragma mark - XMVisualViewDelegate
- (void)visualViewWillRemoveFromSuperView{
    // 显示浮窗
    if([XMWXFloatWindowIconConfig isSaveFloatVCInUserDefaults]){
        [XMWXVCFloatWindow shareXMWXVCFloatWindow].hidden = NO;
    }
}

#pragma mark - 横竖全屏退出视频
- (void)exitFullScreen:(NSNotification *)noti{
    /// 退出横屏时需要保持状态栏可见
    [UIApplication sharedApplication].statusBarHidden = NO;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    // 当触发swipe手势时,可能会触发pan手势等手势
    if ([gestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]]){
        // swip只会触发一次,或者会同时触发pan手势,这都是可以的
        if ([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] || [otherGestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]]){
            return YES;
        }
        // 当web页面有滚动图片时,还会触发一个页面的类似于pan的手势,此时应该屏蔽swipe手势
        return NO;
    }
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")]){
        return NO;
    }
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    
    // 前进返回手势在左侧30以内不触发,防止与侧边pop手势冲突
    if([gestureRecognizer isEqual:self.panSearchMode]){
        if([gestureRecognizer locationInView:self.view].x < 30){
            return NO;
        }
    }
    return YES;
}


#pragma mark - 手势

#pragma mark 点击手势
- (void)webviewDidTap:(UITapGestureRecognizer *)tap{
    // 没有图片组直接返回
    if(self.imageArr.count <= 0) return;
    
    // 滚动中不能点击
    if(self.isScroller) return;
    
    CGPoint touchPoint = [tap locationInView:self.wkWebview];
    NSString *imgURL = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", touchPoint.x, touchPoint.y];
    __weak typeof(self) weakSelf = self;
    [self.wkWebview evaluateJavaScript:imgURL completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSString *urlToSave = (NSString *)result;
        // 有地址证明长按了图片区域
        if (urlToSave.length > 0){
            // 找出点击的图片的序号
            NSUInteger index = self.imageArr.count;
            for (NSUInteger i = 0; i < self.imageArr.count; i++) {
                NSString *eleUrl = self.imageArr[i];
                // 警告:目前发现uc点击得到的地址包含从网页提取的地址,此处可能有隐患
                if([urlToSave containsString:eleUrl]){
                    index = i;
                    break;
                }
            }
            if(index != self.imageArr.count){
                [weakSelf callPhotoDisplayViewcontrollerWithIndex:index];
            }
        }
    }];
}

- (void)callPhotoDisplayViewcontrollerWithIndex:(NSUInteger)index{
    if(self.isScroller) return;
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    XMPhotoCollectionViewController *photoVC = [[XMPhotoCollectionViewController alloc] initWithCollectionViewLayout:layout];
    photoVC.sourceType = XMPhotoDisplayImageSourceTypeWebURL;
    if(self.imageArr.count > 0){
        photoVC.photoModelArr = [self.imageArr copy];
    }else if(self.imageRegArr.count > 0){
        photoVC.photoModelArr = [self.imageRegArr copy];
    }
    photoVC.selectImgIndex = index;
    photoVC.collectionView.contentSize = CGSizeMake(XMScreenW * self.imageArr.count, XMScreenH);
    [self.navigationController pushViewController:photoVC animated:YES];
}

#pragma mark 右划关闭webmodule
/**
 双击恢复正常缩放
 */
- (void)doubleTapToScaleIdentity{
    self.wkWebview.transform = CGAffineTransformIdentity;
}


/**
 双指向上或向下轻扫触发滚动到最底部和最底部
 */
- (void)doubleFingerSwipe:(UISwipeGestureRecognizer *)gest{
    // 延时执行滚动,防止触发swipe手势时,scrollerview同时在滚动造成滚动冲突
    if (gest.direction == UISwipeGestureRecognizerDirectionUp){
        [MBProgressHUD showMessage:@"下滚到底部"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self webViewDidScrollToBottom];
        });
    }else if (gest.direction == UISwipeGestureRecognizerDirectionDown){
        [MBProgressHUD showMessage:@"上滚到顶部"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self webViewDidScrollToTop];
        });
    }
}

#pragma mark - searchMode的返回处理
/** searchMode下手势触发的方法 */
- (void)panToBackForward:(UIPanGestureRecognizer *)gesture{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:{
            
            self.starX = [gesture locationInView:self.wkWebview].x;
            break;
        }
        case UIGestureRecognizerStateChanged:{
            CGFloat panShift = [gesture locationInView:self.wkWebview].x - self.starX;

            // 根据左划或者右划移动箭头
            if (panShift > backForwardSafeDistance && self.wkWebview.canGoBack){
                // 向右滑
                self.backForIconContainV.hidden = NO;
                self.backForIconContainV.transform = CGAffineTransformMakeTranslation(panShift - backForwardSafeDistance > backForwardImagVWH ? backForwardImagVWH : (panShift - backForwardSafeDistance) , 0);
                
            }else if(panShift < -backForwardSafeDistance && self.wkWebview.canGoForward){
                // 向左滑
                self.backForIconContainV.hidden = NO;
                self.backForIconContainV.transform = CGAffineTransformMakeTranslation((-panShift - backForwardSafeDistance) > backForwardImagVWH ? -backForwardImagVWH : (panShift + backForwardSafeDistance), 0);
            }
            break;
        }
        case UIGestureRecognizerStateEnded:{
            CGFloat panShift = [gesture locationInView:self.wkWebview].x - self.starX;
            // 右划且滑动距离大于50,表示应该返回,反之左划并且距离大于50表示向前,并复位左右两个箭头
            if (panShift - backForwardSafeDistance > backForwardImagVWH){
                [self.wkWebview goBack];
            }else if(-panShift - backForwardSafeDistance > backForwardImagVWH){
                [self.wkWebview goForward];
            }
            
            // 手势结束之后隐藏两边箭头
            self.backForIconContainV.transform = CGAffineTransformIdentity;
            self.backForIconContainV.hidden = YES;
            
            // todo:检测是否最后一页,防止重定向,暂时延时判断,移除searchMode下的pan手势
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // 返回前进手势判断
                self.panSearchMode.enabled = (self.wkWebview.canGoForward || self.wkWebview.canGoBack);
                // toolbar返回前进箭头
                self.toolBarForwardBtn.selected = !self.wkWebview.canGoForward;
                self.toolBarBackBtn.selected = !self.wkWebview.canGoBack;
                // 只要能返回,就要禁用全屏pop手势
                XMNavigationController *nav = (XMNavigationController *)self.navigationController;
                nav.customerPopGestureRecognizer.enabled = !self.wkWebview.canGoBack;
            });
            
            break;
        }
        default:{
            // cancel或者failed则复位两边箭头
            self.backForIconContainV.transform = CGAffineTransformIdentity;
            self.backForIconContainV.hidden = YES;
            
            break;
        }
    }
}

/**  searchMode下初始化 */
- (void)initSearchMode{
    // 添加左右两个箭头
    UIView *backForIconContainV = [[UIView alloc] initWithFrame:CGRectMake(-backForwardImagVWH, CGRectGetMidY([UIScreen mainScreen].bounds), backForwardImagVWH * 2 + XMScreenW, backForwardImagVWH)];
    self.backForIconContainV = backForIconContainV;
    [self.containerV addSubview:backForIconContainV];
    backForIconContainV.backgroundColor = [UIColor clearColor];
    backForIconContainV.hidden = YES;
    //    self.backImgV.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    UIImageView *backImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchMode_back"]];
    backImgV.frame = CGRectMake(0, 0, backForwardImagVWH, backForwardImagVWH);
    [backForIconContainV addSubview:backImgV];
    UIImageView *forwardImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchMode_forward"]];
    forwardImgV.frame = CGRectMake(XMScreenW + backForwardImagVWH, 0, backForwardImagVWH, backForwardImagVWH);
    [backForIconContainV addSubview:forwardImgV];
    
    // 为searchmode添加前进后退手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panToBackForward:)];
    pan.delegate = self;
    self.panSearchMode = pan;
    [self.wkWebview addGestureRecognizer:pan];

}
    
/// 取消searchMode
- (void)removeSearchMode{
    [self.wkWebview removeGestureRecognizer:self.panSearchMode];
    [self.backForIconContainV removeFromSuperview];
}

@end
