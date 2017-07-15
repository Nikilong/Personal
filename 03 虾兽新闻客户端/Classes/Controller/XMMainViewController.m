//
//  XMMainViewController.m
//  03 虾兽新闻客户端
//
//  Created by Niki on 17/3/25.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "XMMainViewController.h"
#import "XMHomeTableViewController.h"
#import "XMLeftTableViewController.h"
#import "XMWebViewController.h"
#import "XMChannelModel.h"
#import "XMLeftViewUserCell.h"
#import "XMFloatWindow.h"
#import "XMConerAccessoryView.h"
#import "XMSaveWebsTableViewController.h"
#import "XMQRCodeViewController.h"
#import "XMSearchTableViewController.h"

#import "UIImageView+WebCache.h"
#import "MBProgressHUD+NK.h"

#define XMScreenW [UIScreen mainScreen].bounds.size.width
#define XMScreenH [UIScreen mainScreen].bounds.size.height

@interface XMMainViewController ()<
XMLeftTableViewControllerDelegate,
XMFloatWindowDelegate,
XMConerAccessoryViewDelegate,
UIGestureRecognizerDelegate>

/** 强引用左侧边栏窗口 */
@property (nonatomic, strong) XMLeftTableViewController *leftVC;
@property (weak, nonatomic)  UIView *leftContentView;
/** 强引用主新闻窗口 */
@property (nonatomic, strong) XMHomeTableViewController *homeVC;
/** 强引用保存新闻窗口 */
@property (nonatomic, strong) XMSaveWebsTableViewController *saveVC;
/** 强引用打开的webmodule */
@property (weak, nonatomic)  UIView *topWebContentView;
@property (nonatomic, strong) NSMutableArray *webContentArr;
@property (nonatomic, strong) NSMutableArray *webVCArr;
@property (nonatomic, assign, getter=iscanCreateNewWebmodule)  BOOL canCreateNewWebmodule;


/** 记录当前webmodule的contentView位置 */
@property (nonatomic, assign)  CGFloat starX;
@property (nonatomic, assign)  CGFloat rightContentViewX;
@property (nonatomic, strong) NSString *currentURL;

/** 蒙板 */
@property (weak, nonatomic)  UIView *cover;

@property (nonatomic, strong) XMFloatWindow *floatWindow;
@property (nonatomic, assign) BOOL isNeedFloatWindow;



@end

@implementation XMMainViewController

#pragma mark - lazy

-(XMHomeTableViewController *)homeVC
{
    if (!_homeVC)
    {
        _homeVC = [[XMHomeTableViewController alloc] init];
        _homeVC.delegate = self;
    }
    return _homeVC;
}

- (XMSaveWebsTableViewController *)saveVC
{
    if (!_saveVC)
    {
        _saveVC = [[XMSaveWebsTableViewController alloc] init];
        _saveVC.delegate = self;
    }
    return _saveVC;
}

- (NSMutableArray *)webContentArr
{
    if (!_webContentArr)
    {
        _webContentArr = [[NSMutableArray alloc] init];
    }
    return _webContentArr;
}

-(NSMutableArray *)webVCArr
{
    if (!_webVCArr)
    {
        _webVCArr = [[NSMutableArray alloc] init];
    }
    return _webVCArr;
}

- (UIView *)cover
{
    if (!_cover)
    {
        UIView *cover = [[UIView alloc] initWithFrame:CGRectMake(XMLeftViewTotalW, 0, XMScreenW - XMLeftViewTotalW, XMScreenH)];
        cover.backgroundColor = [UIColor clearColor];
        [self.view addSubview:cover];
        _cover = cover;
        
        // 添加手势点击和拖，触发蒙板隐藏左侧边栏
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideLeftView)];
        [cover addGestureRecognizer:tap];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self  action:@selector(hideLeftView)];
        [cover addGestureRecognizer:pan];
        
    }
    return _cover;
}

#pragma mark - 初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 添加主新闻窗口
    [self addHomeVC];
    
    // 添加左侧边栏
    [self addLeftVC];
    
    // 设置导航栏标题
    [self setNavTitle:@"推荐"];
    
    // 创建悬浮按钮
//    [self addFloatView];
    
    // 创建左下角辅助按钮
    [self addCornerAccessoryView];
    
    // 创建导航栏按钮
    [self addNavButton];
    
    // 初始化时还没有webmodule,因此可以创建
    self.canCreateNewWebmodule = YES;
    
    // 添加手势
    // 左侧抽屉手势
    UISwipeGestureRecognizer *swip = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showLeftView)];
    [self.view addGestureRecognizer:swip];
    // 搜索快捷手势
    UISwipeGestureRecognizer *searchSwip = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(search:)];
    searchSwip.numberOfTouchesRequired = 3;  // 设置需要3个手指向下滑
    // 必须要实现一个代理方法支持多手势,这时候3指下滑同时也会触发单指滚动tableview
    searchSwip.delegate = self;
    searchSwip.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:searchSwip];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    [self clearCache];
}

- (void)addCornerAccessoryView
{
    // 设置conerAccessoryView的子按钮
    CGFloat radius = 65;
    CGFloat btnWH = 30;
    CGFloat borderW = 5;
    UIColor *tintColor = [UIColor colorWithRed:70/255.0 green:139/255.0 blue:255/255.0 alpha:1.0];
    NSArray *imageArr = @[@"love-white",@"lajitong",@"more"];
    XMConerAccessoryView *conerAccessoryView = [XMConerAccessoryView conerAccessoryViewWithButtonWH:btnWH radius:radius imageArray:imageArr borderWidth:borderW tintColor:tintColor];
    conerAccessoryView.delegate = self;
    
    [self.view addSubview:conerAccessoryView];
}

/** 添加悬浮辅助按钮*/
- (void)addFloatView
{
    self.floatWindow = [XMFloatWindow floatWindow];
    _floatWindow.delegate = self;
    _floatWindow.backgroundColor = [UIColor clearColor];
    _floatWindow.frame = CGRectMake(10, 300, 30, 90);
    
    _isNeedFloatWindow = YES;
}

/** 设置导航栏扫描二维码和搜索按钮 */
- (void)addNavButton
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(scan)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(search:)];
}

/** 设置导航栏标题 */
- (void)setNavTitle:(NSString *)channel
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"虾兽新闻客户端\n%@",channel]];
    // 设置第一行样式
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[NSFontAttributeName] = [UIFont boldSystemFontOfSize:17];
    [str setAttributes:dict range:NSMakeRange(0, 7)];
    
    // 设置频道的样式
    NSMutableDictionary *dictChannel = [NSMutableDictionary dictionary];
    dictChannel[NSFontAttributeName] = [UIFont systemFontOfSize:13];
    dictChannel[NSForegroundColorAttributeName] = [UIColor orangeColor];
    [str setAttributes:dictChannel range:NSMakeRange(8, channel.length)];
    label.attributedText = str;
    self.navigationItem.titleView = label;
    
    // 标题添加双击回到主界面样式手势
    UITapGestureRecognizer *homeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backTap)];
    homeTap.numberOfTapsRequired = 2;  // 双击打开
    [self.navigationItem.titleView addGestureRecognizer:homeTap];
    // 导航条默认不支持交互事件,必须开启
    self.navigationItem.titleView.userInteractionEnabled = YES;
}

/** 添加主新闻窗口 */
- (void)addHomeVC
{
    // 创建主新闻窗口
    UIView *homeContentView = self.homeVC.tableView;
    homeContentView.frame = CGRectMake(0, 0, XMScreenW, XMScreenH);
    // homevc成为self的childviewcontroller
    [self.view addSubview:homeContentView];
    [self addChildViewController:_homeVC];
}

/**  添加左侧边栏*/
-(void)addLeftVC
{
    // 创建左侧边栏容器
    UIView *leftContentView = [[UIView alloc] initWithFrame:CGRectMake(-XMLeftViewTotalW, 0, XMLeftViewTotalW, XMScreenH)];
    leftContentView.backgroundColor = [UIColor grayColor];
    self.leftContentView = leftContentView;
    
    // 创建左侧边栏
    self.leftVC = [[XMLeftTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    self.leftVC.delegate = self;
    self.leftVC.view.frame = CGRectMake(XMLeftViewPadding, XMLeftViewPadding, XMLeftViewTotalW - 2 *XMLeftViewPadding, XMScreenH - 2 *XMLeftViewPadding);
    [self.leftContentView addSubview:self.leftVC.view];
    
    // 添加到导航条之上
    [self.navigationController.view insertSubview:self.leftContentView aboveSubview:self.navigationController.navigationBar];
    
    // 左侧边栏添加左划取消手势
    UISwipeGestureRecognizer *swip = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideLeftView)];
    swip.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.leftVC.tableView addGestureRecognizer:swip];
}


#pragma mark - 点击事件与手势
#pragma mark 导航栏
/** QRcode */
- (void)scan
{
    XMQRCodeViewController *qrVC = [[XMQRCodeViewController alloc] init];
    qrVC.delegate = self;
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
    titleLab.text = @"扫描二维码";
    qrVC.navigationItem.titleView = titleLab;
    [self.navigationController pushViewController:qrVC animated:YES];
}

/** 搜索框*/
- (void)search:(UISwipeGestureRecognizer *)swip
{
    XMSearchTableViewController *searchVC = [[XMSearchTableViewController alloc] init];
    searchVC.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:searchVC];
    [self presentViewController:nav animated:YES completion:nil];
}

/** 双击titleview返回 */
- (void)backTap
{
    [self showRightContentView:NO];
}


#pragma mark 左侧栏
#warning note 1，这里用到navigationController，若这时候leftVC是self的childviewcontroller，则会冲突，系统建议navigationController是leftVC的父控制器。2，在这里插入蒙板最准确，在init里面可能不准确
/** 显示左侧边栏 */
- (void)showLeftView
{
    // 隐藏悬浮按钮
    _floatWindow.hidden = YES;
    
    // 显示蒙板
    self.cover.hidden = NO;
    
    // 添加到导航栏的上面
    [self.navigationController.view insertSubview:self.cover aboveSubview:self.navigationController.navigationBar];
    
    // 设置动画弹出左侧边栏
    [UIView animateWithDuration:0.5 animations:^{
        self.leftContentView.transform = CGAffineTransformMakeTranslation(XMLeftViewTotalW, 0);
    }];

}

/** 隐藏左侧边栏 */
- (void)hideLeftView
{
    // 隐藏蒙板
    self.cover.hidden = YES;
    
    [UIView animateWithDuration:0.5 animations:^{
        // 恢复到最左边的位置
        self.leftContentView.transform = CGAffineTransformIdentity;
        
    }completion:^(BOOL finished) {
        // 左侧边栏移除之后再显示悬浮按钮
        if (!_isNeedFloatWindow) return;
        self.floatWindow.hidden = NO;
    }];
}

#pragma mark 右侧webmodule栏
/** 显示或者隐藏右侧webmodule容器 */
- (void)showRightContentView:(BOOL)isShow
{
    CGFloat duration = 0.5f;
    if (isShow) // 显示
    {
        [UIView animateWithDuration:duration animations:^{
            self.topWebContentView.transform = CGAffineTransformMakeTranslation(-XMScreenW, 0);
        }completion:^(BOOL finished) {
            // 当只有一个webmodule且该webmodule显示时,点击webmodule上面的链接,应该可以再重新创建一个webmodule,所以应该设置canCreateNewWebmodule
            if (self.webVCArr.count == 1)
            {
                self.canCreateNewWebmodule = YES;
            }
        }];
    }else
    {
        [UIView animateWithDuration:duration animations:^{
            self.topWebContentView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            // 当只有一个webmodule时,只需要隐藏不需要销毁,因此可以避免加载同一个网站时重新加载
            if (self.webContentArr.count == 1)
            {
                // 只有一个webmodule并且隐藏时,在主界面,不需要重新创建webmodule
                self.canCreateNewWebmodule = NO;
                return;
            }
            // 当打开多个webmodule时移除最上面的webmodule
            UIView *topContentView = [self.webContentArr lastObject];
            [topContentView removeFromSuperview];
            [self.webContentArr removeLastObject];
            [self.webVCArr removeLastObject];
            // 重新标记最上面的webmodule
            self.topWebContentView = [self.webContentArr lastObject];
        }];
    }
}


/** 右划返回webmodule*/
- (void)panToCloseWebmodule:(UIPanGestureRecognizer *)pan
{
    // 手势加载rightContentView上面,需要转换坐标系
    CGFloat currentX = [self.topWebContentView convertPoint:[pan locationInView:self.topWebContentView] toView:self.view].x;
    switch (pan.state) {
        case UIGestureRecognizerStateBegan: // 拖拽开始
            // 记录一开始的触点,
            self.starX = [self.topWebContentView convertPoint:[pan locationInView:self.topWebContentView] toView:self.view].x;
            break;
            
        case UIGestureRecognizerStateChanged: // 拖拽改变
        {
            if (currentX < self.starX) return;
            // 由于一开始rightContentView的x坐标为XMScreenW(藏在最右边),因此transform都是以XMScreenW作为原点,因此需要减去XMScreenW
            self.topWebContentView.transform = CGAffineTransformMakeTranslation(currentX - self.starX - XMScreenW, 0);
            break;
        }
        case UIGestureRecognizerStateEnded: // 拖拽结束
        {
            // 拖拽距离超过rightContentView的相对位置0.3时决定弹回还是隐藏
            [self showRightContentView:self.topWebContentView.frame.origin.x < XMScreenW * 0.3];
            break;
        }
        default:
            break;
    }
}
#pragma 请求网络申请- delegate
/**   请求网络申请*/
- (void)openWebmoduleRequest:(XMWebModel *)webModel
{
    // 隐藏刷新按钮
    self.floatWindow.isShowRefreshButton = NO;
    
    // 当第一次请求时或者两次请求不一样是应该创建webmodule
    if (self.currentURL == nil || ![self.currentURL isEqualToString:webModel.webURL.absoluteString] )
    {
        self.currentURL = webModel.webURL.absoluteString;
    
        // 区分开点击主界面的浏览行为和点击网站链接的行为
        if (self.iscanCreateNewWebmodule)
        {
            // 创建右侧边栏容器
            UIView *rightContentView = [[UIView alloc] initWithFrame:CGRectMake(XMScreenW, 64, XMScreenW, XMScreenH - 64)];
            [self.view addSubview:rightContentView];
            
            // 标记最顶部的rightContentView
            self.topWebContentView = rightContentView;
            
            // 创建webmodule的控制器
            XMWebViewController *webVC = [[XMWebViewController alloc] init];
            webVC.delegate = self;
            [rightContentView addSubview:webVC.view];
            // 必须把webVC加到数组强引用,不然会销毁
            [self.webVCArr addObject:webVC];
            
            // 添加右划关闭当前webmodule手势
            UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panToCloseWebmodule:)];
            [rightContentView addGestureRecognizer:pan];
            [self.webContentArr addObject:rightContentView];
            
            // 传递模型
            webVC.model = webModel;
        }else  // 在主界面浏览新闻时只需要一个webmodule,并且设置url即可
        {
            XMWebViewController *webVC = [self.webVCArr lastObject];
            webVC.model = webModel;
        }
    }

    // 每次网络请求都应该显示webmodule
    [self showRightContentView:YES];
    
}


#pragma mark - 代理方法
/** 选中频道的代理方法 */
- (void)leftTableViewControllerDidSelectChannel:(NSIndexPath *)indexPath
{
    // 切换频道
    self.homeVC.currentChannel = indexPath.row;
    
    // 隐藏左侧边栏
    [self hideLeftView];
    
    // 设置导航栏显示当前频道
    XMChannelModel *model = [XMChannelModel channels][indexPath.row];
    [self setNavTitle:model.channel];
}

#pragma mark floatView - delegate
/** web滚到最顶部和最底部功能 */
//- (void)floatWindowDidClickDownToBottomButton:(XMFloatWindow *)floatWindow
//{
//    UIViewController *topVC = self.navigationController.visibleViewController;
//
//    if ([topVC isKindOfClass:[XMWebViewController class]])
//    {
//        [self.webVC webViewDidScrollToBottom];
//    }else
//    {
//        [self.homeVC downToBottom];
//    }
//}
//
//- (void)floatWindowDidClickUpToTopButton:(XMFloatWindow *)floatWindow
//{
//    UIViewController *topVC = self.navigationController.visibleViewController;
//    if ([topVC isKindOfClass:[XMWebViewController class]])
//    {
//        [self.webVC webViewDidScrollToTop];
//    }else
//    {
//        [self.homeVC upToTop];
//    }
//}

//- (void)floatWindowDidClickRefreshButton:(XMFloatWindow *)floatWindow
//{
//    [self.homeVC refresh];
//}


#pragma mark conerAccessoryView - delegate
- (void)conerAccessoryViewDidClickPlantedButton:(UIButton *)button
{
    switch (button.tag) {
        case 1: // 打开珍藏
            
            [self callSaveViewController];
            break;
            
        case 2: // 删除缓存
            
            [self clearCache];
            break;
            
        case 3: // 取消隐藏/显示悬浮按钮
            
            if (button.selected) // 默认是显示，当点击按钮被选择即表示要隐藏悬浮按钮
            {
                _isNeedFloatWindow = YES;
                _floatWindow.hidden = NO;
                button.selected = NO;
            }else
            {
                _isNeedFloatWindow = NO;
                _floatWindow.hidden = YES;
                button.selected = YES;
            }
            break;
#warning undo case 4 打开搜索
            
        default:
            break;
    }
}

/**  清除缓存*/
- (void)clearCache
{
    // 清除用sd下载的cell头像（主要）  Library/Caches/default/com.hackemist.SDWebImageCache.default
    [[[SDWebImageManager sharedManager] imageCache] clearDiskOnCompletion:nil];
    
    // 可有可无
    [[[SDWebImageManager sharedManager] imageCache] clearMemory];
    
    // 不过这里要特别注意一下，在IOS7中你会发现使用这两个方法缓存总清除不干净，即使断网下还是会有数据。这是因为在IOS7中，缓存机制做了修改，使用上述两个方法只清除了SDWebImage的缓存，没有清除系统的缓存，所以我们可以在清除缓存的代理中额外添加以下：
    
    // 清除uiwebview的图片缓存（系统方法） Library/Caches/Apple.343--------
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    // 显示清理进度条
    [MBProgressHUD showProgressInView:self.navigationController.view mode:MBProgressHUDModeDeterminateHorizontalBar duration:2 title:@"正在清理缓存中。。。。"];
   
}

/**  打开珍藏VC*/
- (void)callSaveViewController
{
    // 隐藏左侧边栏
    [self hideLeftView];
    
    // 隐藏中间刷新按钮
    _floatWindow.isShowRefreshButton = NO;
    
    // 用导航控制器push，可以使得控制器保持在栈顶
    [self.navigationController pushViewController:self.saveVC animated:YES];
    self.navigationItem.title = @"首页";
}

#pragma mark UIGestureRecognizer delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}
@end
