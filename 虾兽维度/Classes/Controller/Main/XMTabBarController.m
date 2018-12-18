//
//  XMTabBarController.m
//  虾兽维度
//
//  Created by Niki on 2018/10/17.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMTabBarController.h"

#import "XMNavigationController.h"
#import "XMMainViewController.h"
#import "XMMyTableViewController.h"

#import "XMTabBar.h"
#import "MBProgressHUD+NK.h"
#import "UIImageView+WebCache.h"
#import "XMWXVCFloatWindow.h"
#import "XMWXFloatWindowIconConfig.h"

// 3D-touch
#import "XMSaveWebsTableViewController.h"
#import "XMToolboxViewController.h"
#import "XMSearchTableViewController.h"
#import "XMQRCodeViewController.h"

// swift
//#import "虾兽维度-XMMetorMapViewController.swift"
#import "虾兽维度-Bridging-Header.h"
#import "虾兽维度-Swift.h"

@interface XMTabBarController ()<
XMTabBarDelegate,
XMOpenWebmoduleProtocol
>

@property (weak, nonatomic)  UIView *toolV;
@property (nonatomic, assign)  BOOL isShow;
@property (weak, nonatomic)  UIView *toolViewCover;  // 蒙板
@property (nonatomic, assign)  NSInteger toolBtnClickIndex;  // 更多工具栏点击的按钮的tag




@end

@implementation XMTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    XMTabBar *tabbarV = [[XMTabBar alloc] initWithFrame:CGRectMake(0, 0, XMScreenW, 49)];
    tabbarV.delegate = self;
    [self setValue:tabbarV forKeyPath:@"tabBar"];
    
    // 首页
    XMMainViewController *mainVC = [[XMMainViewController alloc] init];
    XMNavigationController *navMain = [[XMNavigationController alloc] initWithRootViewController:mainVC];
    [self setTabBarItem:mainVC.tabBarItem title:@"新闻" titleSize:13 titleFontName:@"HeiTi SC" selectedImage:@"tabbar_icon_news_highlight" selectedTitleColor:[UIColor redColor] normalImage:@"tabbar_icon_news_normal" normalTitleColor:[UIColor grayColor]];

    // 视频
    
    

    // 工具箱
    XMToolboxViewController *toolVC = [[XMToolboxViewController alloc] init];
    XMNavigationController *navTool = [[XMNavigationController alloc] initWithRootViewController:toolVC];
     [self setTabBarItem:toolVC.tabBarItem title:@"工具箱" titleSize:13 titleFontName:@"HeiTi SC" selectedImage:@"tabbar_icon_toolbox_highlight" selectedTitleColor:[UIColor redColor] normalImage:@"tabbar_icon_toolbox_normal" normalTitleColor:[UIColor grayColor]];


    // 我
//    XMMyTableViewController *myVC = [[XMMyTableViewController alloc] init];
//    XMNavigationController *navMy = [[XMNavigationController alloc] initWithRootViewController:myVC];
//    [self setTabBarItem:toolVC.tabBarItem title:@"我" titleSize:13 titleFontName:@"HeiTi SC" selectedImage:@"tabbar_icon_me_highlight" selectedTitleColor:[UIColor redColor] normalImage:@"tabbar_icon_me_normal" normalTitleColor:[UIColor grayColor]];

    self.viewControllers = @[navMain,navTool];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self toolV];
    
    
    // 在这个时候创建浮窗
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kCheckCreateFloatwindow];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [XMWXVCFloatWindow shareXMWXVCFloatWindow];
}

- (void)setTabBarItem:(UITabBarItem *)tabbarItem
                title:(NSString *)title
            titleSize:(CGFloat)size
        titleFontName:(NSString *)fontName
        selectedImage:(NSString *)selectedImage
   selectedTitleColor:(UIColor *)selectColor
          normalImage:(NSString *)unselectedImage
     normalTitleColor:(UIColor *)unselectColor{
    
    //设置图片
    tabbarItem = [tabbarItem initWithTitle:title image:[[UIImage imageNamed:unselectedImage]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:selectedImage]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    // 未选中字体颜色
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:unselectColor,NSFontAttributeName:[UIFont fontWithName:fontName size:size]} forState:UIControlStateNormal];
    
    // 选中字体颜色
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:selectColor,NSFontAttributeName:[UIFont fontWithName:fontName size:size]} forState:UIControlStateSelected];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 3Dtouch事件
- (void)callSearch{
    // 跳转到新闻tab
    self.selectedIndex = 0;
    XMMainViewController *mainVC = (XMMainViewController *)self.selectedViewController.childViewControllers[0];
    [mainVC callSearchView];
    
}
- (void)callScanQRCode{
    
    self.selectedIndex = 0;
    XMMainViewController *mainVC = (XMMainViewController *)self.selectedViewController.childViewControllers[0];
    [mainVC scanQRCode];

}
- (void)callToolbox{
    // 直接跳转到toolbox的tabbar
    self.selectedIndex = 1;

}
- (void)callSave{

    XMSaveWebsTableViewController *saveVC  = [[XMSaveWebsTableViewController alloc] init];
    XMNavigationController *nav = (XMNavigationController *)self.selectedViewController;
    [nav pushViewController:saveVC animated:YES];

}

#pragma mark - XMTabBarDelegate
/// 隐藏或者隐藏工具箱面板整体
- (void)tabBarMidButtonDidClick{
    self.isShow = !self.isShow;
    if(self.isShow){// 显示工具箱菜单
        self.toolBtnClickIndex = -1;  // 清空点击的按钮
        self.toolViewCover.hidden = NO;
        [UIView animateWithDuration:XMToolBoxViewAnimationTime animations:^{
            self.toolViewCover.alpha = 0.3;
            self.toolV.transform = CGAffineTransformMakeTranslation(0, -self.toolV.frame.size.height);
        }];
        
    }else{ // 隐藏工具箱菜单
        [UIView animateWithDuration:XMToolBoxViewAnimationTime animations:^{
            self.toolV.transform = CGAffineTransformIdentity;
            self.toolViewCover.alpha = 0;
        }completion:^(BOOL finished) {
            if(finished){
                self.toolViewCover.hidden = YES;
                if(self.toolBtnClickIndex >= 0){
                    // 收起菜单栏再进行下一步操作,以免影响截图
                    [self toolButtonDidClickAction];
                }
            }
        }];
        
    }
}

#pragma mark - 更多栏
- (UIView *)toolV{
    if (!_toolV){
        // 添加蒙板
        UIView *cover = [[UIView alloc] initWithFrame:CGRectMake(0, - XMStatusBarHeight, XMScreenW, XMScreenH + XMStatusBarHeight)];
        self.toolViewCover = cover;
        cover.hidden = YES;
        cover.alpha = 0.0;
        cover.backgroundColor = [UIColor blackColor];
        [self.view addSubview:cover];
        // 添加点击取消手势
        UITapGestureRecognizer *tapToCancel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tabBarMidButtonDidClick)];
        [cover addGestureRecognizer:tapToCancel];
        
        
        CGFloat btnWH = 44;         // 工具箱按钮宽高,根据bundle下toolBixIcons文件夹的图标确定
        CGFloat btnLabelH = 20;     // 工具箱按钮标签高度
        CGFloat padding = 10;       // 间隙
        NSUInteger colMaxNum = 6;   // 每行允许排列的图标个数
        
        // 工具箱菜单栏整体
        UIView *toolView = [[UIView alloc] init];
        [self.view addSubview:toolView];
        toolView.backgroundColor = [UIColor clearColor];
        self.toolV = toolView;
        
        // 工具箱按钮参数
        NSArray *btnParams = @[@{@"title":@"收藏/历史",@"image":@"icon_tabbar_edit"},
                               @{@"title":@"夜间模式",@"image":@"icon_tabbar_edit"},
                               @{@"title":@"清理缓存",@"image":@"icon_tabbar_edit"},
                               @{@"title":@"地铁图",@"image":@"icon_tabbar_edit"},
                               ];
        NSUInteger btnNum = btnParams.count;
        
        // 工具箱按钮菜单栏
        CGFloat toolMenuVW =XMScreenW;
        CGFloat toolBtnMarginX;
        CGFloat toolBtnMarginY;
        if (btnNum < colMaxNum){
            // 图标小于每行最大数时居中显示
            toolBtnMarginX = (toolMenuVW - btnNum * btnWH) / (btnNum + 1);
            toolBtnMarginY = 2 * padding;
        }else{
            toolBtnMarginX = (toolMenuVW - colMaxNum * btnWH) / (colMaxNum + 1);
            toolBtnMarginY = toolBtnMarginX;
        }
        CGFloat toolMenuVH = (btnWH + btnLabelH + padding) * ((btnNum + colMaxNum - 1) / colMaxNum) + 2 * toolBtnMarginY - padding;
        CGFloat toolMenuX = 0;
        
        UIView *toolMenuV = [[UIView alloc] initWithFrame:CGRectMake(toolMenuX, 0, toolMenuVW, toolMenuVH)];
        [toolView addSubview:toolMenuV];
        toolMenuV.backgroundColor = [UIColor whiteColor];
        
        // 添加按钮
        CGFloat btnX;
        CGFloat btnY;
        for (int i = 0; i < btnNum; i++){
            NSDictionary *dict = btnParams[i];
            btnX = toolBtnMarginX + (btnWH + toolBtnMarginX) * (i % colMaxNum);
            btnY = toolBtnMarginY + (btnWH + btnLabelH + padding) * (i / colMaxNum);
            // 工具箱按钮
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(btnX, btnY, btnWH, btnWH)];
            [toolMenuV addSubview:btn];
            
            btn.tag = i;
            [btn setImage:[UIImage imageNamed:dict[@"image"]] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(toolButtonDidClick:) forControlEvents:UIControlEventTouchDown];
            
            // 按钮下标签
            UILabel *btnL = [[UILabel alloc] initWithFrame:CGRectMake(btnX - 0.5 * toolBtnMarginX, CGRectGetMaxY(btn.frame), btnWH + toolBtnMarginX, btnLabelH)];
            btnL.numberOfLines = 0;
            btnL.lineBreakMode = NSLineBreakByWordWrapping;
            btnL.text = dict[@"title"];
            btnL.tintColor = [UIColor blackColor];
            btnL.textAlignment = NSTextAlignmentCenter;
            btnL.font = [UIFont systemFontOfSize:11];
            [toolMenuV addSubview:btnL];
        }
        
        CGFloat toolViewH = CGRectGetMaxY(toolMenuV.frame) - CGRectGetMinY(toolMenuV.frame);
        toolView.frame = CGRectMake(0, XMScreenH, XMScreenW, toolViewH);
    }
    return _toolV;
}

/// 工具条点击事件
- (void)toolButtonDidClick:(UIButton *)btn{
    self.toolBtnClickIndex = btn.tag;
    // 收起工具条,需要等到工具条收起再进行下一步动作,以免影响截图
    [self tabBarMidButtonDidClick];
}

/// 收起菜单栏再响应按钮的点击动作
- (void)toolButtonDidClickAction{
    switch (self.toolBtnClickIndex) {
        case 0:{ // 保存历史
            XMSaveWebsTableViewController *saveVC = [[XMSaveWebsTableViewController alloc] init];
            saveVC.delegate = self;
            XMNavigationController *nav = (XMNavigationController *)self.selectedViewController;
            [nav pushViewController:saveVC animated:YES];
            
            break;
        }case 1:{ // 夜间模式
            
            break;
        }case 2:{ // 清理缓存
            [self clearCache];
            break;
        }case 3:{ // 地铁图
            XMMetorMapViewController *maVC  = [[XMMetorMapViewController alloc] init];
            XMNavigationController *nav = (XMNavigationController *)self.selectedViewController;
            [nav pushViewController:maVC animated:YES];
            break;
            
        }default:{
            break;
        }
    }
    // 复位点击按钮索引
    self.toolBtnClickIndex = -1;
}

/// 清除缓存
- (void)clearCache{
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
@end
