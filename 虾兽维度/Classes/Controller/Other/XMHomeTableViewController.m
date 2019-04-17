//
//  XMHomeTableViewController.m
//  虾兽维度
//
//  Created by Niki on 17/3/24.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "XMHomeTableViewController.h"
#import "XMWebTableViewCell.h"
#import "XMChannelModelLogic.h"

#import "XMMainViewController.h"
#import "MBProgressHUD+NK.h"

#import "XMRefreshHeaderView.h"
#import "XMFreshView.h"
#import "XMWebModelLogic.h"
#import "XMDebugDefine.h"
#import "XMWKWebViewController.h"
#import "XMPhotoCollectionViewController.h"

CGFloat const XMRowHeight = 100;
CGFloat const XMRrfreshHeight = 64;

@interface XMHomeTableViewController () <
UITableViewDataSource,
UITableViewDelegate,
NSURLSessionDelegate,
UITabBarControllerDelegate>

// 保存每一条cell的新闻的url
@property (nonatomic, strong) NSMutableArray *webs;
// 最新加载的新闻
@property (nonatomic, strong) NSMutableArray *freshWebsArr;
// 历史新闻
@property (nonatomic, strong) NSMutableArray *historyNewsArr;
// 第一组headerView的标题
@property (nonatomic, copy) NSString *headerVTitle;


// 下拉刷新条幅
@property (nonatomic, weak) XMFreshView *headerRefreshV;
//// 下拉刷新组件
//@property (weak, nonatomic)  XMRefreshHeaderView *refreshHeader;

// 标记拖拽状态
//@property (nonatomic, assign) BOOL isDragging;

// 标记刷新状态
@property (nonatomic, assign) BOOL isRefreshing;

// 加载次数,防止多次连续加载
@property (nonatomic, assign)  NSUInteger loadCount;

@property (nonatomic, assign)  double preTabitemClickT;     // 上一次tabbar点击事件


@end

@implementation XMHomeTableViewController

#pragma mark - lazy

- (NSMutableArray *)webs{
    
    if (_webs == nil){
        _webs = [NSMutableArray array];
    }
    return _webs;
}

- (NSMutableArray *)freshWebsArr{
    
    if (_freshWebsArr == nil){
        _freshWebsArr = [NSMutableArray array];
    }
    return _freshWebsArr;
}

- (NSMutableArray *)historyNewsArr{
    
    if (_historyNewsArr == nil){
        XMChannelModel *model = [XMChannelModelLogic channels][self.currentChannel];
        _historyNewsArr = [NSMutableArray arrayWithArray:[XMWebModelLogic unarchiveHistoryNewsArrayWithChannel:model.channel]];
    }
    return _historyNewsArr;
}

- (NSString *)headerVTitle{
    if (!_headerVTitle){
        XMChannelModel *model = [XMChannelModelLogic channels][self.currentChannel];
        _headerVTitle = [XMWebModelLogic getHistoryNewUpdateTimeWithChannel:model.channel];
    }
    return _headerVTitle;
}

#pragma mark - 初始化

- (void)viewDidLoad {
    [super viewDidLoad];

    self.loadCount = 0;
    // 设置行高
    self.tableView.rowHeight = XMRowHeight;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    
    // 设置下拉刷新
#ifndef XMLauchAutoRefrehFobiden
    [self setRreflashControl];
#endif
    // 设置摇一摇刷新
    [UIApplication sharedApplication].applicationSupportsShakeToEdit = YES;
    [self becomeFirstResponder];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    // 已改为加载在contentView,所以打开webmodule时不会disappear
    [UIApplication sharedApplication].applicationSupportsShakeToEdit = NO;
    [self resignFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    // 监听tabbar的点击事件,以便于双击刷新
     self.navigationController.tabBarController.delegate = self;
}


#pragma mark - 摇一摇
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    [self nonePullFresh];
}

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - 消息横幅
- (void)setRefreshCount:(NSString *)content{
    
    // 只有在XMMainViewController控制器里面才需要刷新横幅
    if (![self.navigationController.childViewControllers.lastObject isKindOfClass:[XMMainViewController class]]) return;
    
    // 创建刷新消息横幅
    UILabel *countLabel = [[UILabel alloc] init];
    [self.navigationController.view insertSubview:countLabel belowSubview:self.navigationController.navigationBar];
    countLabel.textColor = [UIColor whiteColor];
    countLabel.font = [UIFont systemFontOfSize:13];
    CGFloat countLabelW = [UIScreen mainScreen].bounds.size.width;
    CGFloat countLabelH = 30;
    CGFloat countLabelX = 0;
    // 竖屏状态下,statusBar+navBAr=20+44=64,横屏状态下statusBar+navBAr=0+32=32,因此y的初始坐标需要在这基础上再减去countLabelH
    CGFloat countLabelY =  ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft || [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight ) ? 2 : (14 + XMStatusBarHeight);
    countLabel.frame = CGRectMake(countLabelX, countLabelY, countLabelW, countLabelH);
    countLabel.text = content;
    countLabel.textAlignment = NSTextAlignmentCenter;
    countLabel.backgroundColor = [UIColor grayColor];
    
    // 设置动画
    NSTimeInterval duration = 0.4;
    [UIView animateWithDuration:duration animations:^{
        countLabel.transform = CGAffineTransformMakeTranslation(0, countLabelH);
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 动画内嵌套动画
            [UIView animateWithDuration:duration animations:^{
                countLabel.transform = CGAffineTransformIdentity;
            }completion:^(BOOL finished) {
                // 完成后将横幅移除（销毁横幅）
                [countLabel removeFromSuperview];
            }];
        });
    }];
}

#pragma mark - 快速滚动到顶部和底部
// 悬浮按钮的方法实现(滚到底部)
- (void)downToBottom{
    
    CGFloat botY = XMRowHeight * self.webs.count - [UIScreen mainScreen].bounds.size.height ;
    [self.tableView setContentOffset:CGPointMake(0, botY) animated:YES];
}

// 悬浮按钮的方法实现(滚到最顶部)
- (void)upToTop{
    [self.tableView setContentOffset:CGPointZero animated:YES];
}



#pragma mark -  设置下拉刷新
- (void)setRreflashControl{
    self.headerRefreshV = [XMFreshView addHeaderFreshViewInTableView:self.tableView hasTimeLable:NO];
    __weak typeof(self) weakSelf = self;
    self.headerRefreshV.freshBlock = ^(){
        [weakSelf refresh];
    };
    self.headerRefreshV.finishFreshBlock = ^(){
        [weakSelf upToTop];
    };

    // 开始刷新
    [self refresh];
    
}

#pragma mark - 监听tabbarItem的点击事件
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    if(viewController.childViewControllers.count > 0 && [viewController.childViewControllers[0] isKindOfClass:[XMMainViewController class]]){
        // 0.5s内连续点击当做是刷新事件,否则滚到最顶部
        double currentT = [NSDate date].timeIntervalSince1970;
        if(currentT - self.preTabitemClickT < 0.5){
            [self nonePullFresh];
        }else{
            [self upToTop];
        }
        self.preTabitemClickT = currentT;
    }
    return YES;
}

#pragma mark 监听scroller的滚动
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [self.headerRefreshV tableViewDidScroller];
}

/// 开始拖拽,做标记
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.headerRefreshV tableViewWillBeginDragging];
}

/// 结束拖拽,处理事件
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self.headerRefreshV tableViewDidEndDraggingWillDecelerate:decelerate];
}

#pragma mark - 频道切换
- (void)setCurrentChannel:(NSUInteger)currentChannel{
    
    _currentChannel = currentChannel;
    
    // 刷新一波新闻
    [self nonePullFresh];
}

#pragma mark - peek 预览
/// 通过peek点,创建一个3d预览界面
- (instancetype)webmoduleWithTouchPoint:(CGPoint )point{
    // 这里面有两组数据,所以需要加上tableview的contentOffset
    NSIndexPath *indexP = [self.tableView indexPathForRowAtPoint:CGPointMake(point.x, point.y  + self.tableView.contentOffset.y)];
    XMWebModel *model;
    if(indexP){
        if(indexP.section == 0){
            model = self.webs[indexP.row];
        }else{
            model = self.historyNewsArr[indexP.row];
        }
        XMWebTableViewCell *cell = (XMWebTableViewCell *)[self.tableView cellForRowAtIndexPath:indexP];
        
        // 转换坐标系
        CGPoint touchP = [self.tableView convertPoint:point toView:nil];
        touchP.y += self.tableView.contentOffset.y;
        CGRect imgR = [cell.imageV convertRect:cell.imageV.bounds toView:nil];

        BOOL inImgV = CGRectContainsPoint(imgR, touchP);
        // 打开图片预览或者新闻预览
        if(inImgV && model.images.count > 0){
            UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
            layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            XMPhotoCollectionViewController *photoVC = [[XMPhotoCollectionViewController alloc] initWithCollectionViewLayout:layout];
            photoVC.sourceType = XMPhotoDisplayImageSourceTypeWebURL;
            photoVC.photoModelArr = [model.images copy];
            photoVC.collectionView.contentSize = CGSizeMake(XMScreenW * model.images.count, XMScreenH);
            [photoVC beginTimer];
            return photoVC;
        }else{
            XMWKWebViewController *webmodule = (XMWKWebViewController *)[XMWKWebViewController webmoduleWithURL:model.webURL.absoluteString isSearchMode:YES];
            webmodule.peekMode = YES;
            return webmodule;
        }
    }else{
        return nil;
    }
    
}

#pragma mark - uitableview 的基本实现
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(self.historyNewsArr.count > 0){
        // 必须返回一个不为空的标题才会显示headerview
        return section == 1 ? @"历史新闻" : @"";
    }else{
        return @"";
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 1){
        return 35;
    }else{
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section == 1){
        // 标题栏
        UIView *headerV  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, XMScreenW, 35)];
        headerV.backgroundColor = RGB(242, 242, 242);
        
        UILabel *titleLab = [[UILabel alloc] initWithFrame:headerV.bounds];
        titleLab.textAlignment = NSTextAlignmentCenter;
        titleLab.textColor = [UIColor darkGrayColor];
        [headerV addSubview:titleLab];
        
        // 设置字体样式
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@看到了这里，点击刷新",self.headerVTitle]];
        // 设置第一行样式
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSFontAttributeName] = [UIFont boldSystemFontOfSize:13];
        [str setAttributes:dict range:NSMakeRange(0, str.length - 5)];
        
        // 设置"点击刷新"的样式
        NSMutableDictionary *dictChannel = [NSMutableDictionary dictionary];
        dictChannel[NSFontAttributeName] = [UIFont boldSystemFontOfSize:13];
        dictChannel[NSForegroundColorAttributeName] = [UIColor darkGrayColor];
        [str setAttributes:dictChannel range:NSMakeRange(str.length - 4, 4)];
        titleLab.attributedText = str;
        
        // 添加点击刷新的手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nonePullFresh)];
        [headerV addGestureRecognizer:tap];
    
        return headerV;
    }else{
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        v.backgroundColor = [UIColor redColor];
        return nil;
    }
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return (self.historyNewsArr.count > 0) ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.historyNewsArr.count > 0){
        return section == 0 ? self.webs.count : self.historyNewsArr.count;
    }else{
        return self.webs.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //取得cell
    XMWebTableViewCell *cell = [XMWebTableViewCell cellWithTableView:tableView];
    
    //设置cell的其他信息
    XMWebModel *model;
    if(indexPath.section == 0){
        model = self.webs[indexPath.row];
    }else if(indexPath.section == 1){
        model = self.historyNewsArr[indexPath.row];
    }
    cell.model = model;

    return cell;
}

/// 根据选中哪一行播放相关的新闻
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 取出对应的模型
    XMWebModel *model;
    if(indexPath.section == 0){
        model = self.webs[indexPath.row];
    }else if(indexPath.section == 1){
        model = self.historyNewsArr[indexPath.row];
    }

    // 通知代理发送网络请求
    if ([self.delegate respondsToSelector:@selector(openWebmoduleRequest:)]){
        [self.delegate openWebmoduleRequest:model];
    }
}

#pragma mark - 刷新表格数据

/// 非手动下拉刷新触发的刷新
- (void)nonePullFresh{
    // 先模拟下拉一个高度
    [self.tableView setContentOffset:CGPointMake(0, -self.headerRefreshV.frame.size.height) animated:YES];
    // 在强制刷新
    [self refresh];
}

/// 刷新
- (void)refresh{
    
    // 当前正在刷新则返回避免连续刷新
    if(self.isRefreshing) return;
    self.isRefreshing = YES;
    // 开启网络加载
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [self.headerRefreshV startLoading];
    
    // 1,创建session
    NSURLSessionConfiguration *cfg = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:cfg];
    
    // 2,创建url
    // 取出当前频道
    XMChannelModel *model = [XMChannelModelLogic channels][self.currentChannel];
    NSURL *idUrl = [NSURL URLWithString:model.url];
    
    __weak typeof(self) weakSelf = self;
    // 3,创建一个下载任务，类型为NSURLSessionDataTask
    NSURLSessionDataTask *task = [session dataTaskWithURL:idUrl  completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
        
            if (!error){
                // 5,创建session网络请求结束后
                // 解析json数据
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                // 根据dict更新数据
                [weakSelf dealJsonDataWithDict:dict];
            }else{
                
                // 6，回到主线程设置cell的信息
                [weakSelf backToMainQueueWithMessage:@"加载失败"];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                // 关闭网络加载
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            });
        
      }];
    
    // 4,开始任务（异步）
    [task resume];
    
}

// 设置刷新转动动画
- (CABasicAnimation *)addRotationAnimation{
    
    CABasicAnimation *anim = [CABasicAnimation animation];
    anim.keyPath = @"transform.rotation";
    anim.toValue = @(M_PI * 2);
    // 设置动画时长
    anim.duration = 0.5;
    // 重复动画的次数
    anim.repeatCount = MAXFLOAT;
    return anim;
}

// 根据dict更新数据
- (void)dealJsonDataWithDict:(NSDictionary *)dict{
    /// --1.更新数据前准备
    // 根据屏幕高度除以每个cell高度(100)去请求个数,适应不同的屏幕
    NSUInteger refreshCount = (NSUInteger)(XMScreenH / 100);
    // 取出当前频道
    XMChannelModel *model = [XMChannelModelLogic channels][self.currentChannel];
    
    // 先保存上一次刷新时间
    self.headerVTitle = [XMWebModelLogic getHistoryNewUpdateTimeWithChannel:model.channel];
    // 先清空并加载历史数据,防止最新加载的数据同时在第0组和第1组展示
//    NSUInteger oldHisNewsCount = self.historyNewsArr.count;
    self.historyNewsArr = nil;
    [self historyNewsArr];
    
    
//    // 告知系统第1组的数据变化
//    [self.tableView beginUpdates];
//
//    if (oldHisNewsCount > 0 && !self.historyNewsArr.count){
//        // 原本有历史组,新切换的频道没有历史组,需删除一个组
//        [self.tableView deleteSections:[[NSIndexSet alloc] initWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
//    }else if (!(oldHisNewsCount > 0) && self.historyNewsArr.count > 0){
//        // 原本没有历史组,新切换的频道有历史组,需增加一个组
//        [self.tableView insertSections:[[NSIndexSet alloc] initWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
//    }
//
//    // 历史数据组,必须保持cell的个数统一,需要作出相应的insert或者delete
//    if (oldHisNewsCount > 0 && self.historyNewsArr.count > 0){
//        if (self.historyNewsArr.count > oldHisNewsCount){
//            // 新数组大于旧数组,需要增加对应的cell空位
//            NSUInteger newMinisOldCount = self.historyNewsArr.count - oldHisNewsCount;
//            NSMutableArray *arr = [NSMutableArray array];
//            for (int i = 0; i < newMinisOldCount; i++) {
//                [arr addObject:[NSIndexPath indexPathForRow:oldHisNewsCount + i inSection:1]];
//            }
//            [self.tableView insertRowsAtIndexPaths:arr withRowAnimation:UITableViewRowAnimationFade];
//        }else{
//            // 新数组长度小于旧数据,这需要删除多余的旧cell
//            NSUInteger newMinisOldCount = oldHisNewsCount - self.historyNewsArr.count;
//            for (int i = 1; i < newMinisOldCount + 1; i++) {
//                [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:oldHisNewsCount - i inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
//            }
//        }
//    
//    }
//
//    [self.tableView endUpdates];
    
    //    if ([model.channel isEqualToString:@"时尚"]){
    //        [self.freshWebsArr addObjectsFromArray:[XMWebModel websWithDict:dict refreshCount:refreshCount keyWordArray:model.tags]];
    //    }else if ([model.channel isEqualToString:@"段子"]){
    //        [self.freshWebsArr addObjectsFromArray:[XMWebModel websWithDict:dict refreshCount:refreshCount keyWordArray:nil]];
    //    }else{
    //        [self.freshWebsArr addObjectsFromArray:[XMWebModel websWithDict:dict refreshCount:refreshCount keyWordArray:nil]];
    //    }
    
    
    /// --2.更新数据源
    [self.freshWebsArr addObjectsFromArray:[XMWebModelLogic websWithDict:dict refreshCount:refreshCount keyWordArray:nil channel:model.channel]];
    // 未加载够足够新闻再次请求加载数据
    if (self.freshWebsArr.count < refreshCount){
        // 防止死循环无限加载数据
        self.loadCount++;
        sleep(3);
        if(self.loadCount < 3){
            [self refresh];
        }else{
            self.loadCount = 0;
        }
    }
    NSUInteger acturallyCount = self.freshWebsArr.count;
    /* 转码打印json数据,用于分析数据
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
//    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    NSLog(@"这是全部数据%@",jsonStr);
     */
    // 清空第0组数据
    self.webs = nil;
    self.webs = [NSMutableArray arrayWithArray:self.freshWebsArr];
    // 清空中转数组
    self.freshWebsArr = nil;
    
    /// --3.更新tableview的cell数据
    // 6，回到主线程设置cell的信息
    [self backToMainQueueWithMessage:[NSString stringWithFormat:@"成功加载%zd条新闻",acturallyCount]];
}

// 回到主线程
- (void)backToMainQueueWithMessage:(NSString *)message{
    
    // 6，回到主线程设置cell的信息
    __weak typeof(self) weakSelf = self;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        // 结束刷新
        [weakSelf.headerRefreshV finishLoadingWithResult:XMFreshResultSuccess];
        
        // 提示用户刷新成功
        [weakSelf setRefreshCount:message];
        
        // 刷新表格
        [weakSelf.tableView reloadData];
//        [weakSelf.tableView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        
        // 标记刷新结束
        weakSelf.isRefreshing = NO;
    }];
}

@end
