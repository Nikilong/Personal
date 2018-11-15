//
//  XMMainViewController.m
//  虾兽维度
//
//  Created by Niki on 17/3/25.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "XMMainViewController.h"
#import "XMHomeTableViewController.h"
#import "XMLeftTableViewController.h"
#import "XMNavTitleTableViewController.h"
//#import "XMWebViewController.h"
#import "XMWKWebViewController.h"
#import "XMChannelModelLogic.h"
#import "XMLeftViewUserCell.h"
#import "XMConerAccessoryView.h"
#import "XMQRCodeViewController.h"
#import "XMSearchTableViewController.h"
#import "XMDropView.h"

#import "AppDelegate.h"

#import "UIImageView+WebCache.h"
#import "MBProgressHUD+NK.h"


@interface XMMainViewController ()<
XMLeftTableViewControllerDelegate,
XMNavTitleTableViewControllerDelegate,
XMConerAccessoryViewDelegate,
XMDropViewDelegate,
UIGestureRecognizerDelegate,
UITraitEnvironment>

/** 强引用左侧边栏窗口 */
@property (nonatomic, strong) XMLeftTableViewController *leftVC;
@property (weak, nonatomic)  UIView *leftContentView;
@property (weak, nonatomic)  UITextView *guildView;
/** 强引用主新闻窗口 */
@property (nonatomic, strong) XMHomeTableViewController *homeVC;

@property (nonatomic, strong) XMDropView *dropView;
@property (nonatomic, strong) XMNavTitleTableViewController *navTitleVC;

/** 蒙板 */
@property (weak, nonatomic)  UIView *cover;

/** 是否以searchMode打开webmodule */
@property (nonatomic, assign)  BOOL searchMode;


@end

@implementation XMMainViewController

static double leftViewAnimateTime = 0.25;

#pragma mark - lazy

- (XMHomeTableViewController *)homeVC{
    if (!_homeVC){
        _homeVC = [[XMHomeTableViewController alloc] init];
        _homeVC.delegate = self;
    }
    return _homeVC;
}

- (UIView *)cover{
    if (!_cover){
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
    
    //默认采用searchmode
    self.searchMode = YES;
    
    // 添加主新闻窗口
    [self addHomeVC];
    
    // 添加左侧边栏
    [self addLeftVC];
    
    // 设置导航栏标题
    [self setNavTitle:@"推荐"];
    
    // 创建左下角辅助按钮
//    [self addCornerAccessoryView];
    
    // 创建导航栏按钮
    [self addNavButton];
    
    // 添加手势
    [self addGesture];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self hideLeftView];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addCornerAccessoryView{
    // 设置conerAccessoryView的子按钮
    CGFloat radius = 65;
    CGFloat btnWH = 30;
    CGFloat borderW = 5;
    UIColor *tintColor = [UIColor colorWithRed:70/255.0 green:139/255.0 blue:255/255.0 alpha:1.0];
    NSArray *imageArr = @[@"love-white",@"lajitong",@"more"];
    XMConerAccessoryView *conerAccessoryView = [XMConerAccessoryView conerAccessoryViewWithButtonWH:btnWH radius:radius imageArray:imageArr borderWidth:borderW tintColor:tintColor];
    conerAccessoryView.delegate = self;
    conerAccessoryView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:conerAccessoryView];
}

/** 添加手势*/
- (void)addGesture{
    // 左侧抽屉手势
    UISwipeGestureRecognizer *swip = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showLeftView)];
    [self.view addGestureRecognizer:swip];
    
}

/** 设置导航栏扫描二维码和搜索按钮 */
- (void)addNavButton{
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"scan"] landscapeImagePhone:nil style:UIBarButtonItemStyleDone target:self action:@selector(scanQRCode)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(callSearchView)];
}

/** 设置导航栏标题 */
- (void)setNavTitle:(NSString *)channel{
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    
    // 注意:标题决定了下面的两个range需要同步调整,这里说的标题统计指"虾兽新闻端",共5个字,当有改动时需要同步调整titleCount
    int titleCount = 5;
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"虾兽新闻端\n%@",channel]];
    // 设置第一行样式
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[NSFontAttributeName] = [UIFont boldSystemFontOfSize:17];
    [str setAttributes:dict range:NSMakeRange(0, titleCount)];
    
    // 设置频道的样式
    NSMutableDictionary *dictChannel = [NSMutableDictionary dictionary];
    dictChannel[NSFontAttributeName] = [UIFont systemFontOfSize:13];
    dictChannel[NSForegroundColorAttributeName] = [UIColor lightGrayColor];
    [str setAttributes:dictChannel range:NSMakeRange(titleCount + 1, channel.length)];
    label.attributedText = str;
    self.navigationItem.titleView = label;

    // 添加点击事件
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(callDropView:)];
    tap.delegate = self;
    [label addGestureRecognizer:tap];
    self.navigationItem.titleView.userInteractionEnabled = YES;
}

/** 添加主新闻窗口 */
- (void)addHomeVC{
    
    // 创建主新闻窗口
    UIView *homeContentView = self.homeVC.tableView;
    homeContentView.frame = CGRectMake(0, 0, XMScreenW, XMScreenH);
    // homevc成为self的childviewcontroller
    [self.view addSubview:homeContentView];
    [self addChildViewController:_homeVC];
}

/**  添加左侧边栏*/
-(void)addLeftVC{
    
    // 创建左侧边栏容器
    UIView *leftContentView = [[UIView alloc] initWithFrame:CGRectMake(-XMLeftViewTotalW, 0, XMLeftViewTotalW, XMScreenH)];
    leftContentView.backgroundColor = [UIColor grayColor];
    self.leftContentView = leftContentView;
    self.leftContentView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    // 创建左侧边栏
    self.leftVC = [[XMLeftTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    self.leftVC.delegate = self;
    self.leftVC.view.frame = CGRectMake(XMLeftViewPadding, 40, XMLeftViewTotalW - 2 *XMLeftViewPadding, XMScreenH - XMLeftViewPadding - XMStatusBarHeight);
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
- (void)scanQRCode{
    
    XMQRCodeViewController *qrVC = [[XMQRCodeViewController alloc] init];
//    qrVC.delegate = self;
    __weak typeof(self) weakSelf = self;
    qrVC.scanCallBack = ^(NSString *result){
            
        UIAlertController *tips = [UIAlertController alertControllerWithTitle:@"扫描结果" message:result preferredStyle:UIAlertControllerStyleAlert];
        
        [tips addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [tips addAction:[UIAlertAction actionWithTitle:@"复制内容" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
            // 将textview的text添加到系统的剪切板
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:result];
        }]];
        [tips addAction:[UIAlertAction actionWithTitle:@"用Safari打开" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
            // 用Safari打开
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:result]];
        }]];
        [tips addAction:[UIAlertAction actionWithTitle:@"前往" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
            // 当点击确定执行的块代码
            XMWebModel *model = [[XMWebModel alloc] init];
            model.webURL = [NSURL URLWithString:result];
            [weakSelf openWebmoduleRequest:model];
        }]];
        
        [weakSelf presentViewController:tips animated:YES completion:nil];

    };
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
    titleLab.text = @"扫描二维码";
    qrVC.navigationItem.titleView = titleLab;
    [self.navigationController pushViewController:qrVC animated:YES];
}

/** 搜索框 */
- (void)callSearchView{
    
    XMSearchTableViewController *searchVC = [[XMSearchTableViewController alloc] init];
    searchVC.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:searchVC];
    // 导航控制器只能present另外一个导航控制器,不能push
    [self presentViewController:nav animated:YES completion:^{
        self.homeVC.tableView.scrollEnabled = YES;
    }];
}

/** 导航栏titleview的dropview*/
- (void)callDropView:(UITapGestureRecognizer *)gest{
    if (self.dropView){
        self.dropView.hidden = NO;
    }else{
        /*
         // 方案一
        // 创建频道tableview
        self.navTitleVC = [[XMNavTitleTableViewController alloc] initWithStyle:UITableViewStylePlain];
        CGFloat cellHeight = 35;
        self.navTitleVC.cellHeight = cellHeight;
        CGFloat height = [XMChannelModel channels].count * cellHeight;
        if (height + 64 > XMScreenH){
            height = XMScreenH - 64;
        }
        self.navTitleVC.tableView.frame = CGRectMake(0, 0, 100, height);
        self.navTitleVC.view.backgroundColor = [UIColor clearColor];
        self.navTitleVC.delegate = self;

        // 创建dropview
        self.dropView = [XMDropView dropView];
        self.dropView.contentController = self.navTitleVC;
        self.dropView.delegate = self;
        // 新创建的dropview指向titleview
        [self.dropView showFrom:self.navigationItem.titleView];
         
         */
        
        // 整体
        UIView *containerV = [[UIView alloc] init];
        CGFloat btnW = 44;
        CGFloat btnH = 35;
        CGFloat padding = 5;       // 间隙
        NSUInteger colMaxNum = 7;      // 每行允许排列的图标个数
        
        // 工具箱按钮参数
        NSUInteger btnNum = [XMChannelModelLogic channels].count;
        
        // 添加按钮
        CGFloat btnX;
        CGFloat btnY;
        for (int i = 0; i < btnNum; i++){
            btnX = padding + ( btnW + padding ) * (i % colMaxNum);
            btnY = padding + btnH * (i / colMaxNum);
            
            XMChannelModel *model = [XMChannelModelLogic channels][i];
            // 工具箱按钮
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(btnX, btnY, btnW, btnH)];
            [containerV addSubview:btn];
            btn.tag = i;
            btn.titleLabel.font = [UIFont systemFontOfSize:13];
            [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            [btn setTitle:model.channel forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(channelBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        }
        // 计算总的尺寸,x方向有间距,y方向无间距
        containerV.frame = CGRectMake(0, 0, padding + (padding + btnW) * (colMaxNum - 0),  btnH * ( (btnNum + colMaxNum - 1) / colMaxNum ));
        
        // 创建dropview
        self.dropView = [XMDropView dropView];
        self.dropView.content = containerV;
        self.dropView.delegate = self;
        // 新创建的dropview指向titleview
        [self.dropView showFrom:self.navigationItem.titleView];
    }
}

#pragma mark 左侧栏
#warning note 1，这里用到navigationController，若这时候leftVC是self的childviewcontroller，则会冲突，系统建议navigationController是leftVC的父控制器。2，在这里插入蒙板最准确，在init里面可能不准确
/** 显示左侧边栏 */
- (void)showLeftView{
    // 显示蒙板
    self.cover.hidden = NO;
    
    // 添加到导航栏的上面
    [self.navigationController.view insertSubview:self.cover aboveSubview:self.navigationController.navigationBar];
    // 添加到导航条之上
    [self.navigationController.view insertSubview:self.leftContentView aboveSubview:self.navigationController.navigationBar];
    
    // 设置动画弹出左侧边栏
    [UIView animateWithDuration:0.5 animations:^{
        self.leftContentView.transform = CGAffineTransformMakeTranslation(XMLeftViewTotalW, 0);
    }];

}

/** 隐藏左侧边栏 */
- (void)hideLeftView{
    // 隐藏蒙板
    self.cover.hidden = YES;
    
    [UIView animateWithDuration:leftViewAnimateTime animations:^{
        // 恢复到最左边的位置
        self.leftContentView.transform = CGAffineTransformIdentity;
        
    }];
}

#pragma mark - 代理方法
#pragma 请求网络申请 delegate

///// 请求网络申请
//- (void)openWebmoduleWithURL:(NSString *)url isSearchMode:(BOOL)searchMode{
//    XMWebModel *model = [[XMWebModel alloc] init];
//    model.webURL = [NSURL URLWithString:url];
//    model.searchMode = searchMode;
//    [self openWebmoduleRequest:model];
//}

/// 请求网络申请
- (void)openWebmoduleRequest:(XMWebModel *)webModel{    
    // 标记第一个webmodule
    webModel.firstRequest = YES;
    // 调用webmodule的类方法
//    [XMWKWebViewController openWebmoduleWithModel:webModel viewController:self];
    XMWKWebViewController *webmodule = (XMWKWebViewController *)[XMWKWebViewController webmoduleWithModel:webModel];
    [self.navigationController pushViewController:webmodule animated:YES];
}

#pragma mark leftTableViewController delegate
/** 左侧选择频道的代理方法 */
- (void)leftTableViewControllerDidSelectChannel:(NSIndexPath *)indexPath{
    // 隐藏左侧边栏
    [self hideLeftView];
    
    /// 保持待侧边栏收起再动作,防止push时截图出现截图
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(leftViewAnimateTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (indexPath.section == 0){
            // 创建说明文档
            [self createGuildView];
            
        }else if(indexPath.section == 1){
            // 将specialChannel以webmodule打开,serchMode模式
            XMChannelModel *specialModel = [XMChannelModelLogic specialChannels][indexPath.row];
            XMWebModel *model = [[XMWebModel alloc] init];
            model.searchMode = YES;
            model.webURL = [NSURL URLWithString:specialModel.url];
            [self openWebmoduleRequest:model];
        }
    });
    
}

/**
 创建说明书
 */
- (void)createGuildView{
    UITextView *guildView = [[UITextView alloc] initWithFrame:CGRectMake(0, 64, XMScreenW, XMScreenH - 64)];
    self.guildView = guildView;
    [self.view insertSubview:guildView aboveSubview:self.homeVC.view];
    guildView.text = [XMChannelModelLogic userGuild];
    guildView.textColor = [UIColor orangeColor];
    guildView.font = [UIFont systemFontOfSize:20];
    guildView.editable = NO;

    // 双击退出手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap)];
    tap.numberOfTapsRequired = 2;
    tap.delegate = self;
    [guildView addGestureRecognizer:tap];
}

/**
 双击关闭说明书
 */
- (void)doubleTap{
    [self.guildView removeFromSuperview];
}

#pragma mark navTitleTableViewController delegate
/** (旧)导航栏titleview中选择uc频道的代理方法 */
- (void)navTitleTableViewControllerDidSelectChannel:(NSIndexPath *)indexPath{
    // 将dropview dismiss掉
    [self.dropView dismiss];
    // 切换频道
    self.homeVC.currentChannel = indexPath.row;
    // 设置导航栏显示当前频道
    XMChannelModel *model = [XMChannelModelLogic channels][indexPath.row];
    [self setNavTitle:model.channel];
}

/** (新)导航栏titleview中选择uc频道的代理方法 */
- (void)channelBtnDidClick:(UIButton *)btn{
    // 将dropview隐藏,防止重复创建
    self.dropView.hidden = YES;
    // 切换频道
    self.homeVC.currentChannel = btn.tag;
    // 设置导航栏显示当前频道
    XMChannelModel *model = [XMChannelModelLogic channels][btn.tag];
    [self setNavTitle:model.channel];
}



#pragma mark conerAccessoryView - delegate
//- (void)conerAccessoryViewDidClickPlantedButton:(UIButton *)button{
//    switch (button.tag) {
//        case 1: // 打开珍藏
//
//            [self callSaveViewController];
//            break;
//
//        case 2: // 删除缓存
//
//            [self clearCache];
//            break;
//
//        case 3: // searchmode
//            self.searchMode = !self.searchMode;
//            if(self.searchMode){
//                [MBProgressHUD showMessage:@"已打开searchMode" toView:self.view];
//            }else{
//                [MBProgressHUD showMessage:@"已关闭searchMode" toView:self.view];
//            }
//            break;
//
//        default:
//            break;
//    }
//}
//
/////**  清除缓存*/
////- (void)clearCache{
////    // 清除用sd下载的cell头像（主要）  Library/Caches/default/com.hackemist.SDWebImageCache.default
////    [[[SDWebImageManager sharedManager] imageCache] clearDiskOnCompletion:nil];
////
////    // 可有可无
////    [[[SDWebImageManager sharedManager] imageCache] clearMemory];
////
////    // 不过这里要特别注意一下，在IOS7中你会发现使用这两个方法缓存总清除不干净，即使断网下还是会有数据。这是因为在IOS7中，缓存机制做了修改，使用上述两个方法只清除了SDWebImage的缓存，没有清除系统的缓存，所以我们可以在清除缓存的代理中额外添加以下：
////
////    // 清除uiwebview的图片缓存（系统方法） Library/Caches/Apple.343--------
////    [[NSURLCache sharedURLCache] removeAllCachedResponses];
////
////    // 显示清理进度条
////    [MBProgressHUD showProgressInView:self.navigationController.view mode:MBProgressHUDModeDeterminateHorizontalBar duration:2 title:@"正在清理缓存中。。。。"];
////
////}
//

#pragma mark UIGestureRecognizer delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return YES;
}

@end
