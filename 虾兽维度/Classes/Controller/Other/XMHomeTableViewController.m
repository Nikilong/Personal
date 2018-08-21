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
#import "XMWebModelLogic.h"
#import "XMDebugDefine.h"

CGFloat const XMRowHeight = 100;
CGFloat const XMRrfreshHeight = 100;

@interface XMHomeTableViewController () <UITableViewDataSource,UITableViewDelegate,NSURLSessionDelegate>

// 保存每一条cell的新闻的url
@property (nonatomic, strong) NSMutableArray *webs;
// 最新加载的新闻
@property (nonatomic, strong) NSMutableArray *freshWebsArr;
// 历史新闻
@property (nonatomic, strong) NSMutableArray *historyNewsArr;
// 第一组headerView的标题
@property (nonatomic, copy) NSString *headerVTitle;


// 下拉刷新条幅
@property (nonatomic, weak) UIButton *headerRefreshV;
// 下拉刷新组件
@property (weak, nonatomic)  XMRefreshHeaderView *refreshHeader;

// 标记拖拽状态
@property (nonatomic, assign) BOOL isDragging;

// 标记刷新状态
@property (nonatomic, assign) BOOL isRefreshing;

// 加载次数,防止多次连续加载
@property (nonatomic, assign)  NSUInteger loadCount;

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


#pragma mark - 摇一摇
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    
    [self refresh];
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
        // 动画内嵌套动画
        [UIView animateWithDuration:duration animations:^{
            countLabel.transform = CGAffineTransformIdentity;
        }completion:^(BOOL finished) {
            // 完成后将横幅移除（销毁横幅）
            [countLabel removeFromSuperview];
        }];
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
    
    [self.tableView setContentOffset:CGPointMake(0, -(XMStatusBarHeight + 44)) animated:YES];
}



#pragma mark -  设置下拉刷新
- (void)setRreflashControl{
    
    UIButton *headerRefreshV = [[UIButton alloc] initWithFrame:CGRectMake(0, -44, [UIScreen mainScreen].bounds.size.width, 44)];
    self.headerRefreshV = headerRefreshV;
    self.headerRefreshV.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    headerRefreshV.hidden = YES;
    
    [headerRefreshV setTitle:@"下拉刷新" forState:UIControlStateNormal];
    [headerRefreshV setTitle:@"加载数据中..." forState:UIControlStateSelected];
    [headerRefreshV setImage:[UIImage imageNamed:@"shuaxin"] forState:UIControlStateSelected];
    [headerRefreshV setTitle:@"松手可刷新" forState:UIControlStateDisabled];
    
    [headerRefreshV setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    headerRefreshV.titleLabel.font = [UIFont systemFontOfSize:13];
    headerRefreshV.backgroundColor = [UIColor clearColor];
    [headerRefreshV setImageEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
    [self.view addSubview:headerRefreshV];
    
//    XMRefreshHeaderView *refreshHeader = [XMRefreshHeaderView xm_addPullRefreshHeader:self.tableView];
//    self.refreshHeader = refreshHeader;
//    __weak typeof(self) weakSelf = self;
//    refreshHeader.tableViewShouldRefreshBlock = ^(){
//        [weakSelf refresh];
//    };
    

    // 设置tableview下拉并且刷新
    self.isRefreshing = NO;
    self.tableView.contentInset = UIEdgeInsetsMake(self.headerRefreshV.frame.size.height, 0, 0, 0);
    [self refresh];
    
}

#pragma mark 监听scroller的滚动
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (_isRefreshing) return;
    
    CGFloat tableViewOffet = -self.tableView.contentOffset.y;
    
    if (tableViewOffet > 44 + XMStatusBarHeight){
        // 取消下拉横幅隐藏
        self.headerRefreshV.hidden = NO;
    }else if (tableViewOffet == 44 + XMStatusBarHeight){
        // 隐藏刷新
        self.headerRefreshV.hidden = YES;
    }
    
    // 如果下拉到固定值修改标题提示用户
    if (tableViewOffet > XMRrfreshHeight && _isDragging){
        self.headerRefreshV.enabled = NO;
    }else{
        self.headerRefreshV.enabled = YES;
    }

}

/**
 开始拖拽,做标记
 */
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    _isDragging = YES;
}
/**
 结束拖拽,处理事件
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    // 标记拖拽完毕
    _isDragging = NO;
    // 判断是否触发刷新
    if (-self.tableView.contentOffset.y > XMRrfreshHeight){
        // 固定下拉标签
        self.tableView.contentInset = UIEdgeInsetsMake(XMRrfreshHeight, 0, 0, 0);
        // 刷新数据
        [self refresh];
    }
    
}

#pragma mark - 频道切换
- (void)setCurrentChannel:(NSUInteger)currentChannel{
    
    _currentChannel = currentChannel;
    
    // 刷新一波新闻
    [self refresh];
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section == 1){
        // 标题栏
        UIView *headerV  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, XMScreenW, 25)];
        headerV.backgroundColor = RGB(242, 242, 242);
        
        UILabel *titleLab = [[UILabel alloc] initWithFrame:headerV.bounds];
        titleLab.textAlignment = NSTextAlignmentCenter;
        titleLab.textColor = [UIColor grayColor];
        [headerV addSubview:titleLab];
        
        // 设置字体样式
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@看到了这里，点击刷新",self.headerVTitle]];
        // 设置第一行样式
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSFontAttributeName] = [UIFont boldSystemFontOfSize:11];
        [str setAttributes:dict range:NSMakeRange(0, str.length - 5)];
        
        // 设置"点击刷新"的样式
        NSMutableDictionary *dictChannel = [NSMutableDictionary dictionary];
        dictChannel[NSFontAttributeName] = [UIFont boldSystemFontOfSize:11];
        dictChannel[NSForegroundColorAttributeName] = RGB(48, 107, 255);
        [str setAttributes:dictChannel range:NSMakeRange(str.length - 4, 4)];
        titleLab.attributedText = str;
        
        // 添加点击刷新的手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(refresh)];
        [headerV addGestureRecognizer:tap];
    
        return headerV;
    }else{
        return [[UIView alloc] init];
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

// 根据选中哪一行播放相关的新闻
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
- (void)refresh{
    
    // 当前正在刷新则返回避免连续刷新
    if(self.isRefreshing) return;
    // 设置tableview的下拉偏移
    [self.tableView setContentOffset:CGPointMake(0, -XMRrfreshHeight)];
    // 开启网络加载
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    self.isRefreshing = YES;
    // 0,设置下拉标题提示用户正在刷新
    self.headerRefreshV.enabled = YES;
    self.headerRefreshV.selected = YES;
    // 添加动画
    [self.headerRefreshV.imageView.layer addAnimation:[self addRotationAnimation] forKey:nil];
    
    // 1,创建session
    NSURLSessionConfiguration *cfg = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:cfg];
    
    // 2,创建url
    // 取出当前频道
    XMChannelModel *model = [XMChannelModelLogic channels][self.currentChannel];
    NSURL *idUrl = [NSURL URLWithString:model.url];
    
    // 3,创建一个下载任务，类型为NSURLSessionDataTask
    NSURLSessionDataTask *task = [session dataTaskWithURL:idUrl  completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
            
            // 通知刷新组件结束刷新
            // self.refreshHeader.tableViewDidRefreshBlock(self.refreshHeader);^{
        
            if (!error){
                // 5,创建session网络请求结束后
                // 解析json数据
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                // 根据dict更新数据
                [self dealJsonDataWithDict:dict];
            }else{
                
                // 6，回到主线程设置cell的信息
                [self backToMainQueueWithMessage:@"加载失败"];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                // 关闭网络加载
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                // 恢复刷新
                self.isRefreshing = NO;
                // 移除动画
                [self.headerRefreshV.imageView.layer removeAllAnimations];
                // 隐藏刷新
                self.headerRefreshV.hidden = YES;
                // 恢复标题
                self.headerRefreshV.selected = NO;
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
    NSUInteger oldHisNewsCount = self.historyNewsArr.count;
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
        [UIView animateWithDuration:0.25 animations:^{
            weakSelf.tableView.contentInset = UIEdgeInsetsMake(44 + XMStatusBarHeight, 0, 0, 0);
        }completion:^(BOOL finished) {
            // 滚到最顶部
            [weakSelf upToTop];
        }];
        
        // 提示用户刷新成功
        [weakSelf setRefreshCount:message];
        
        // 刷新表格
        [weakSelf.tableView reloadData];
//        [weakSelf.tableView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }];
}

@end
