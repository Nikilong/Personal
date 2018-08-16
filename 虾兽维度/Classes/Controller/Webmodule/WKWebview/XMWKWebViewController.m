//
//  XMWKWebViewController.m
//  虾兽维度
//
//  Created by admin on 18/8/14.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "XMWKWebViewController.h"
#import "XMWebModelTool.h"
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
#import "NSURLProtocol+WKWebview.h"

@interface XMWKWebViewController ()<
NSURLSessionDelegate,
UIGestureRecognizerDelegate,
UIScrollViewDelegate,
WKUIDelegate,
WKNavigationDelegate,
XMOpenWebmoduleProtocol>

/** 网页高度 */
//@property (nonatomic, assign) NSInteger webHeight;

/** 工具条 */
@property (nonatomic, strong) UIView *toolBar;
@property (weak, nonatomic)  UIButton *saveBtn;
@property (weak, nonatomic)  UIButton *toolBarBackBtn;
@property (weak, nonatomic)  UIButton *toolBarForwardBtn;


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


// 防止多次加载
@property (nonatomic, assign)  BOOL canLoad;

// 标记右划开始的位置
@property (nonatomic, assign)  CGFloat starX;

// 导航栏右边功能栏
@property (nonatomic, strong) XMDropView *navRightDropV;

/** statusBar相关*/
// 状态栏
@property (nonatomic, strong) UIView *statusBar;
// 状态栏遮罩
@property (weak, nonatomic)  UIView *statusCover;

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

        WKWebViewConfiguration * configuration = [[WKWebViewConfiguration alloc]init];
        // y方向距离为导航栏初始高度44+状态栏高度
        _wkWebview = [[WKWebView alloc] initWithFrame:CGRectMake(0, 44 + XMStatusBarHeight, XMScreenW, XMScreenH - 24) configuration:configuration];
        _wkWebview.UIDelegate = self;
        _wkWebview.navigationDelegate = self;
        _wkWebview.scrollView.delegate = self;
        _wkWebview.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.containerV addSubview:_wkWebview];
        
//        // 开启左划右划返回
//        _wkWebview.allowsBackForwardNavigationGestures = YES;
        // 初始化标记,能够加载
        self.canLoad = YES;

        // 添加长按手势
        UILongPressGestureRecognizer *longP = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        longP.delegate = self;
        longP.minimumPressDuration = 0.25;
        [_wkWebview addGestureRecognizer:longP];

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
        
    }
    return _wkWebview;
}

- (UIView *)containerV{
    if (!_containerV){
        UIView *containerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        _containerV = containerV;
        [self.view addSubview:containerV];
        
        // 沉浸式导航栏
        UIView *navToolV = [[UIView alloc] initWithFrame:CGRectMake(0, XMStatusBarHeight, XMScreenW, 44)];
        self.navToolV = navToolV;
        [_containerV addSubview:navToolV];
        navToolV.backgroundColor = [self getNavColor];
        // 点击事件
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetNavFrame)];
        [navToolV addGestureRecognizer:tap];
        
        // 添加顶部的view,防止系统进入后台时隐藏statusbar造成的空隙
        UIView *topCover = [[UIView alloc] initWithFrame:CGRectMake(0, -XMStatusBarHeight, XMScreenW, XMStatusBarHeight)];
        [navToolV addSubview:topCover];
        topCover.backgroundColor = [self getNavColor];
        topCover.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
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
        UILabel *titleLab = [[UILabel alloc] init];
        [navToolV addSubview:titleLab];
        self.navToolTitleLab = titleLab;
        titleLab.textAlignment = NSTextAlignmentCenter;
        titleLab.textColor = [UIColor blackColor];
        // 要想用autolayout这个属性必须设置为NO
        titleLab.translatesAutoresizingMaskIntoConstraints = NO;
        // 垂直方向约束
        [_containerV addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[titleLab(>=0)]-0-|" options:0 metrics:nil views:@{@"titleLab":titleLab}]];
        // 水平方向约束
        [_containerV addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-44-[titleLab(>=0)]-44-|" options:0 metrics:nil views:@{@"titleLab":titleLab}]];
        
        UIView *btnContentV = [[UIView alloc] init];
        self.navToolBtnContentV = btnContentV;
        [navToolV addSubview:btnContentV];
        btnContentV.translatesAutoresizingMaskIntoConstraints = NO;
        // 垂直方向约束
        [navToolV addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[btnContentV(>=0)]-0-|" options:0 metrics:nil views:@{@"btnContentV":btnContentV}]];
        // 水平方向约束
        [navToolV addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[btnContentV(>=0)]-0-|" options:0 metrics:nil views:@{@"btnContentV":btnContentV}]];
        
        // 左边按钮
        UIButton *leftBtn = [[UIButton alloc] init];
        [btnContentV addSubview:leftBtn];
        self.navToolLeftBtn = leftBtn;
        [leftBtn setImage:[UIImage imageNamed:@"navTool_close"] forState:UIControlStateNormal];
        [leftBtn addTarget:self action:@selector(closeWebModule) forControlEvents:UIControlEventTouchUpInside];
        leftBtn.translatesAutoresizingMaskIntoConstraints = NO;
        // 垂直方向约束
        [btnContentV addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[leftBtn(>=0)]-0-|" options:0 metrics:nil views:@{@"leftBtn":leftBtn}]];
        // 水平方向约束
        [btnContentV addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[leftBtn(>=0)]" options:0 metrics:nil views:@{@"leftBtn":leftBtn}]];
        
        // 右边按钮
        UIButton *rightBtn = [[UIButton alloc] init];
        [btnContentV addSubview:rightBtn];
        self.navToolRightBtn = rightBtn;
        [rightBtn setImage:[UIImage imageNamed:@"navTool_more"] forState:UIControlStateNormal];
        [rightBtn addTarget:self action:@selector(callNavRightDropView) forControlEvents:UIControlEventTouchUpInside];
        rightBtn.translatesAutoresizingMaskIntoConstraints = NO;
        // 垂直方向约束
        [btnContentV addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[rightBtn(>=0)]-0-|" options:0 metrics:nil views:@{@"rightBtn":rightBtn}]];
        // 水平方向约束
        [btnContentV addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[rightBtn(>=0)]-10-|" options:0 metrics:nil views:@{@"rightBtn":rightBtn}]];
        
    }
    return _containerV;
}

- (UIView *)toolBar{
    if (!_toolBar){

        NSArray *tabbarBtnData = @[
       @{@"image": @"webview_goback",@"selectImage": @"webview_goback_disable",@"selector":@"webViewDidGoBack"},
       @{@"image": @"webview_goforward",@"selectImage": 
             @"webview_goforward_disable",@"selector":@"webViewDidGoForward"},
       @{@"image": @"webview_new",@"selectImage": @"",@"selector":@"openNewWebmodule"},
       @{@"image": @"shuaxin",@"selectImage": @"",@"selector":@"webViewDidFresh"},
       @{@"image": @"save_normal",@"selectImage": @"save_selected",@"disableImage": @"",@"selector":@"saveWeb:"},
                                   ];
        CGFloat toolbarW = [self getBottomToolBarHeight];
        CGFloat btnWH = 49;
        NSUInteger btnNumber = tabbarBtnData.count;
        CGFloat margin = (XMScreenW - btnNumber * btnWH) / ( btnNumber + 1);


        UIView *toolBar = [[UIView alloc] initWithFrame: CGRectMake(0, XMScreenH - toolbarW, XMScreenW, toolbarW)];
        toolBar.backgroundColor = [self getNavColor];
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
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetNavFrame)];
        [statusCover addGestureRecognizer:tap];
    }
    return _statusCover;
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
//    [self initlizeContainerView];
    
    /// wkwebview注册scheme,实现NSURLProtocol监听
//    [NSURLProtocol wk_registerScheme:@"http"];
//    [NSURLProtocol wk_registerScheme:@"https"];

    
    // 观察进度条
    [self.wkWebview addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    // 隐藏导航条
    self.navigationController.navigationBarHidden = YES;
    // 显示状态栏盖罩
    self.statusCover.hidden = NO;
    // 记录即将显示
    self.isShow = YES;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 当导航控制器栈顶控制器不是webmodule时,即将回到main界面或者save界面,恢复导航栏可见(此时self已经从导航控制器的栈中移除)
    if(![self.navigationController.childViewControllers.lastObject isKindOfClass:[XMWKWebViewController class]]){
        
        self.navigationController.navigationBarHidden = NO;
        // 恢复状态栏颜色,原来的为空 
        self.statusBar.backgroundColor = nil;
        [self.statusCover removeFromSuperview];
    }
    // 隐藏状态栏盖罩
    self.statusCover.hidden = YES;
    
    // 记录即将隐藏
    self.isShow = NO;
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


#pragma mark - 提供一个类方法让外界打开webmodule
+ (void)openWebmoduleWithModel:(XMWebModel *)model viewController:(UIViewController *)vc{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    // 先判断是否和上一个pop掉的webmodule的url相同,相同的话就不必再去重复加载
    if ([app.tempWebModuleVC.originURL.absoluteString isEqualToString:model.webURL.absoluteString]){
        [vc.navigationController pushViewController:app.tempWebModuleVC animated:YES];
    }else{
        app.tempWebModuleVC = nil;
        // 创建一个webmodule
        XMWKWebViewController *webVC = [[XMWKWebViewController alloc] init];
        app.tempWebModuleVC = webVC;
        webVC.model = model;
        webVC.view.frame = vc.view.bounds;
        // 压到导航控制器的栈顶
        [vc.navigationController pushViewController:webVC animated:YES];
    }
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
    
    // 滚动到顶部并且回复导航栏原来的样式,发生frame改变的自动加入到animate中,有动画效果
    [UIView animateWithDuration:0.25f animations:^{
        [self.wkWebview evaluateJavaScript:@"window.scrollTo(0,0);" completionHandler:nil];
        self.navToolV.frame = CGRectMake(0, XMStatusBarHeight, XMScreenW, 44);
        self.wkWebview.frame = CGRectMake(0, 44 + XMStatusBarHeight, XMScreenW, XMScreenH);
        self.navToolTitleLab.font = [UIFont systemFontOfSize:17];
    }completion:^(BOOL finished) {
        self.navToolBtnContentV.hidden = NO;
    }];
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

/** 保存网页 */
- (void)saveWeb:(UIButton *)button{

    if (button.isSelected){
        // 取消保存网站到本地
        [XMWebModelTool deleteWebURL:self.wkWebview.URL.absoluteString];
        // 提示用户取消保存网页成功
        [MBProgressHUD showSuccess:@"取消收藏成功"];
    }else{
        [self.wkWebview evaluateJavaScript:@"document.title" completionHandler:^(id _Nullable title, NSError * _Nullable error) {
            XMWebModel *model = [[XMWebModel alloc] init];
            // 保存的网站统一标记为searchMode
            model.searchMode = YES;
            model.webURL = [NSURL URLWithString:self.wkWebview.URL.absoluteString];
            model.title = title;
            // 保存网站到本地
            [XMWebModelTool saveWebModel:model];
            // 提示用户保存网页成功
            [MBProgressHUD showSuccess:@"收藏成功"];
        }];
    }
    // 取反选择状态
    button.selected = !button.isSelected;
}

/** 打开搜索框 */
- (void)openNewWebmodule{
    XMSearchTableViewController *searchVC = [[XMSearchTableViewController alloc] init];
    searchVC.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:searchVC];
    // 导航控制器只能present另外一个导航控制器,不能push
    [self presentViewController:nav animated:YES completion:nil];
}
//XMSearchTableViewController的代理方法,必须实现
- (void)openWebmoduleRequest:(XMWebModel *)webModel{
    [XMWKWebViewController openWebmoduleWithModel:webModel viewController:self];
}

#pragma mark 导航栏的点击事件
/**
 重设沉浸式导航栏原来的尺寸
 */
- (void)resetNavFrame{
    [UIView animateWithDuration:0.25f animations:^{
        self.navToolV.frame = CGRectMake(0, XMStatusBarHeight, XMScreenW, 44);
        self.wkWebview.frame = CGRectMake(0, 44 + XMStatusBarHeight, XMScreenW, XMScreenH);
        self.navToolTitleLab.font = [UIFont systemFontOfSize:17];
        self.toolBar.frame = CGRectMake(0, XMScreenH - [self getBottomToolBarHeight], XMScreenW, [self getBottomToolBarHeight]);
    }completion:^(BOOL finished) {
        self.navToolBtnContentV.hidden = NO;
        // 恢复导航栏盖罩
        self.statusCover.hidden = YES;
    }];
}

/** 将webmodule关闭掉 */
- (void)closeWebModule{
    
    self.navigationController.navigationBarHidden = NO;
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
        self.navRightDropV.hidden = NO;
    }else{
        
        // 整体
        UIView *containerV = [[UIView alloc] init];
        CGFloat btnW = 85;
        CGFloat btnH = 35;
        CGFloat padding = 5;       // 间隙
        NSUInteger colMaxNum = 1;      // 每行允许排列的图标个数
        
        // 工具箱按钮参数
        NSArray *moreBtnArr = @[@"分享",@"二维码",@"Safari",@"护眼模式"];
        NSArray *moreBtnImgArr = @[@"navMoreBtn_share",@"navMoreBtn_code",@"navMoreBtn_safari",@"navMoreBtn_mode"];
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
            [btn setTitle:moreBtnArr[i] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:moreBtnImgArr[i]] forState:UIControlStateNormal];
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
        
        // 创建dropview
        self.navRightDropV = [XMDropView dropView];
        self.navRightDropV.content = containerV;
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
            // 将当前的url的字符串转为二维码图片
            [self showQrImage:[XMImageUtil creatQRCodeImageWithString:self.wkWebview.URL.absoluteString size:XMScreenW * 0.7]];
            break;
        }
        case 2:{ // Safari
            [[UIApplication sharedApplication] openURL:self.wkWebview.URL];
            break;
        }
        case 99:{ //
            break;
        }
        default:
            break;
    }
}

/// 展示二维码图片
- (void)showQrImage:(UIImage *)image{
    // 隐藏浮窗
    if([XMWXFloatWindowIconConfig isSaveFloatVCInUserDefaults]){
        [XMWXVCFloatWindow shareXMWXVCFloatWindow].hidden = YES;
    }
    
    // 最底部
    UIView *contentV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, XMScreenW, XMScreenH)];
    contentV.backgroundColor = [UIColor clearColor];
    
    // 毛玻璃
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effV = [[UIVisualEffectView alloc] initWithEffect:blur];
    effV.frame = CGRectMake(0, 0, XMScreenW, XMScreenH);
    
    // 二维码图片
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(XMScreenW * 0.15, (XMScreenH - XMScreenW) * 0.5, XMScreenW * 0.7, XMScreenW * 0.7)];
    imageV.image = image;

    // 层级结构
    [self.view addSubview:contentV];
    [contentV addSubview:effV];
    [effV.contentView addSubview:imageV];
    
    // 添加点击移除手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeQriamge:)];
    [contentV addGestureRecognizer:tap];
}


/// 移除二维码图片
- (void)removeQriamge:(UITapGestureRecognizer *)gest{
    [gest.view removeFromSuperview];
    // 显示浮窗
    if([XMWXFloatWindowIconConfig isSaveFloatVCInUserDefaults]){
        [XMWXVCFloatWindow shareXMWXVCFloatWindow].hidden = NO;
    }
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
    [tips addAction:[UIAlertAction actionWithTitle:@"保存图片到系统相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        [XMImageUtil savePictrue:imageUrl path:nil callBackViewController:weakSelf];
    }]];
    [tips addAction:[UIAlertAction actionWithTitle:@"保存图片到本地缓存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        NSString *path = [XMSavePathUnit getWifiImageTempDirPath];
        // 确保文件文件夹以及上一级文件夹存在
        if (![[NSFileManager defaultManager] fileExistsAtPath:[XMSavePathUnit getWifiUploadDirPath]]){
            [[NSFileManager defaultManager] createDirectoryAtPath:[XMSavePathUnit getWifiUploadDirPath] withIntermediateDirectories:NO attributes:nil error:nil];
        }
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]){
            [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil];
        }
        [XMImageUtil savePictrue:imageUrl path:path callBackViewController:weakSelf];
    }]];
    
    // 判断是否含有二维码
    NSString *qrMsg = [XMImageUtil detectorQRCodeImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]]];
    if(qrMsg){
        [tips addAction:[UIAlertAction actionWithTitle:@"识别图中二维码" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
            // 当点击确定执行的块代码
            XMWebModel *model = [[XMWebModel alloc] init];
            model.webURL = [NSURL URLWithString:qrMsg];
            if(self.navigationController){
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [XMWKWebViewController openWebmoduleWithModel:model viewController:self];
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
            [XMWKWebViewController openWebmoduleWithModel:model viewController:self];
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
    //    NSString *title = [self.wkWebview evaluateJavaScript:@"document.title"];
    __weak typeof(self) weakSelf = self;
    [self.wkWebview evaluateJavaScript:@"document.title" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSString *title = (NSString *)result;
        if(title.length > 0 && ![title isEqualToString:weakSelf.navToolTitleLab.text]){
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.navToolTitleLab.text = title;
            });
        }
    }];
    // 判断该网页是否已经保存
    self.saveBtn.selected = [XMWebModelTool isWebURLHaveSave:self.wkWebview.URL.absoluteString];
    
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
        if(requestCount > 0 && [UIApplication sharedApplication].isNetworkActivityIndicatorVisible == NO){
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        }
    });
}

/// 完成一个网络加载(成功或者失败)
- (void)finishNewWebRequestCount{
    requestCount--;
    // 关闭网络加载标志
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(requestCount == 0 && [UIApplication sharedApplication].isNetworkActivityIndicatorVisible == YES){
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

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{

    if (scrollView.contentOffset.y < 0 || self.isDrag == NO){
        // 到达最顶部和最底部,触发弹簧效果时,需要实时更新最后的y偏移,但是不能改变view的frame
        self.lastContentY = scrollView.contentOffset.y;
        return;
    }
    
    // 向上滚动contentOffset.y为正数且增大
    CGRect tarF = self.navToolV.frame;
    tarF.size.height -= scrollView.contentOffset.y - self.lastContentY;
    // 控制导航栏的最大高度和最小高度,20和44修改要慎重,因为多处地方耦合,需要修改其他地方
    if (tarF.size.height < 20){
        tarF.size.height = 20;
    }
    if (tarF.size.height > 44){
        tarF.size.height = 44;
        
        // 导航栏最大化的时候移除导航栏盖罩
        if(self.statusCover.hidden == NO){
            self.statusCover.hidden = YES;
        }
    }else{
        // 导航栏非最大化的时候添加状态栏盖罩
        if(self.statusCover.hidden){
            self.statusCover.hidden = NO;
        }
    }
    // 根据导航栏高度决定是否显示两侧按钮
    if (tarF.size.height > 30){
        self.navToolBtnContentV.hidden = NO;
    }else{
        self.navToolBtnContentV.hidden = YES;
    }

    // 调整导航条高度
    self.navToolV.frame = tarF;
    /**
     //toobar移动方案一
     // 底部toobar联动,根据导航条的变化范围(20 ~ 44)去等比例调整伸出的高度([self getBottomToolBarHeight])
     CGFloat toolBarY = XMScreenH - [self getBottomToolBarHeight] * ( tarF.size.height - 20) / 24;
     self.toolBar.frame = CGRectMake(0, toolBarY, XMScreenW, [self getBottomToolBarHeight]);
     
     */
    //toobar移动方案二,避免一直修改toolbar的frame,减少性能损耗
    if(scrollView.contentOffset.y > self.lastContentY && CGRectGetMaxY(self.toolBar.frame) == XMScreenH){
        // 上滑隐藏toolbar
        [UIView animateWithDuration:0.25f animations:^{
            self.toolBar.frame = CGRectMake(0, XMScreenH, XMScreenW, [self getBottomToolBarHeight]);
        }];
    }else if(scrollView.contentOffset.y < self.lastContentY && CGRectGetMaxY(self.toolBar.frame) == XMScreenH + [self getBottomToolBarHeight]){
        // 下滑显示toolbar
        [UIView animateWithDuration:0.25f animations:^{
            self.toolBar.frame = CGRectMake(0, XMScreenH - [self getBottomToolBarHeight], XMScreenW, [self getBottomToolBarHeight]);
        }];
    }
    
    // 调整web的y
    CGRect webF = self.wkWebview.frame;
    webF.origin.y = CGRectGetMaxY(tarF);
    webF.size.height = XMScreenH - CGRectGetMaxY(tarF);
    self.wkWebview.frame = webF;
    
    // 调整字体大小
    CGFloat fontSize = (17.0 * tarF.size.height / 44.0 > 10 ) ? 17.0 * tarF.size.height / 44.0 : 10;
    self.navToolTitleLab.font = [UIFont systemFontOfSize:fontSize];

    // 更新lastContentY
    self.lastContentY = scrollView.contentOffset.y;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.isDrag = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    self.isDrag = NO;
}


#pragma mark - uigestureDelegate
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

@end
