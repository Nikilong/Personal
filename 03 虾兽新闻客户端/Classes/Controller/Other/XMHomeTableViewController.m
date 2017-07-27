//
//  XMHomeTableViewController.m
//  03 虾兽新闻客户端
//
//  Created by Niki on 17/3/24.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "XMHomeTableViewController.h"
#import "XMWebTableViewCell.h"
#import "XMChannelModel.h"

#import "XMMainViewController.h"

#define XMRowHeight 100
#define XMRrfreshHeight 100

@interface XMHomeTableViewController () <UITableViewDataSource,UITableViewDelegate,NSURLSessionDelegate>

// 保存每一条cell的新闻的url
@property (nonatomic, strong) NSMutableArray *webs;

// 下拉刷新条幅
@property (nonatomic, weak) UIButton *headerRefreshV;
// 标记拖拽状态
@property (nonatomic, assign) BOOL isDragging;

// 标记刷新状态
@property (nonatomic, assign) BOOL isRefreshing;

@end

@implementation XMHomeTableViewController

#pragma mark - lazy

- (NSMutableArray *)webs
{
    if (_webs == nil)
    {
        _webs = [NSMutableArray array];
    }
    return _webs;
}


#pragma mark - 初始化

- (void)viewDidLoad {
    [super viewDidLoad];

    // 设置行高
    self.tableView.rowHeight = XMRowHeight;
    
    // 设置下拉刷新
    [self setRreflashControl];
    
    // 设置摇一摇刷新
    [UIApplication sharedApplication].applicationSupportsShakeToEdit = YES;
    [self becomeFirstResponder];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // 已改为加载在contentView,所以打开webmodule时不会disappear
    [UIApplication sharedApplication].applicationSupportsShakeToEdit = NO;
    [self resignFirstResponder];
}


#pragma mark - 摇一摇
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    [self refresh];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - 消息横幅
- (void)setRefreshCount:(NSString *)content
{
    // 只有在XMMainViewController控制器里面才需要刷新横幅
    if (![self.navigationController.childViewControllers.lastObject isKindOfClass:[XMMainViewController class]]) return;
    UILabel *countLabel = [[UILabel alloc] init];
    [self.navigationController.view insertSubview:countLabel belowSubview:self.navigationController.navigationBar];
    CGFloat countLabelW = [UIScreen mainScreen].bounds.size.width;
    CGFloat countLabelH = 30;
    CGFloat countLabelX = 0;
    CGFloat countLabelY = 34;
    countLabel.frame = CGRectMake(countLabelX, countLabelY, countLabelW, countLabelH);
    countLabel.text = content;
    countLabel.textAlignment = NSTextAlignmentCenter;
    countLabel.backgroundColor = [UIColor orangeColor];
    
    // 设置动画
    NSTimeInterval duration = 0.4;
    [UIView animateWithDuration:duration animations:^{
        countLabel.transform = CGAffineTransformMakeTranslation(0, countLabelY);
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

#pragma mark - 频道切换
- (void)setCurrentChannel:(NSUInteger)currentChannel
{
    _currentChannel = currentChannel;
    
    // 清空当前频道的新闻
    self.webs = nil;
    
    // 刷新一波新闻
    [self refresh];
}

#pragma mark - 快速滚动到顶部和底部
// 悬浮按钮的方法实现(滚到底部)
- (void)downToBottom
{
    
    CGFloat botY = XMRowHeight * self.webs.count - [UIScreen mainScreen].bounds.size.height ;
    [self.tableView setContentOffset:CGPointMake(0, botY) animated:YES];
}

// 悬浮按钮的方法实现(滚到最顶部)
- (void)upToTop
{
    [self.tableView setContentOffset:CGPointMake(0, -64) animated:YES];
}



#pragma mark -  设置下拉刷新
- (void)setRreflashControl
{
    UIButton *headerRefreshV = [[UIButton alloc] initWithFrame:CGRectMake(0, -44, 375, 44)];
    self.headerRefreshV = headerRefreshV;
    headerRefreshV.hidden = YES;
    
    [headerRefreshV setTitle:@"下拉刷新" forState:UIControlStateNormal];
    [headerRefreshV setTitle:@"刷新...." forState:UIControlStateSelected];
    [headerRefreshV setImage:[UIImage imageNamed:@"shuaxin"] forState:UIControlStateSelected];
    [headerRefreshV setTitle:@"松手可刷新" forState:UIControlStateDisabled];
    
    [headerRefreshV setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    headerRefreshV.backgroundColor = [UIColor clearColor];
    [self.view addSubview:headerRefreshV];

    // 设置tableview下拉并且刷新
    self.isRefreshing = NO;
    self.tableView.contentInset = UIEdgeInsetsMake(self.headerRefreshV.frame.size.height, 0, 0, 0);
    [self refresh];
    
}

#pragma mark 监听scroller的滚动
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_isRefreshing) return;
    
    CGFloat tableViewOffet = -self.tableView.contentOffset.y;
    
    if (tableViewOffet > 64)
    {
        // 取消下拉横幅隐藏
        _headerRefreshV.hidden = NO;
    }else if (tableViewOffet == 64)
    {
        // 隐藏刷新
        self.headerRefreshV.hidden = YES;
    }
    
    // 如果下拉到固定值修改标题提示用户
    if (tableViewOffet > XMRrfreshHeight && _isDragging)
    {
        _headerRefreshV.enabled = NO;
    }

}

/**
 开始拖拽,做标记
 */
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _isDragging = YES;
}
/**
 结束拖拽,处理事件
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // 标记拖拽完毕
    _isDragging = NO;
    // 判断是否触发刷新
    if (-self.tableView.contentOffset.y > XMRrfreshHeight)
    {
        // 固定下拉标签
        self.tableView.contentInset = UIEdgeInsetsMake(XMRrfreshHeight, 0, 0, 0);
        // 刷新数据
        [self refresh];
    }
    
}

#pragma mark - uitableview 的基本实现
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.webs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //取得cell
    XMWebTableViewCell *cell = [XMWebTableViewCell cellWithTableView:tableView];
    
    //设置cell的其他信息
    XMWebModel *model = self.webs[indexPath.row];
    cell.model = model;

    return cell;
}

// 根据选中哪一行播放相关的新闻
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 隐藏刷新按钮
//    self.btnRefresh.hidden = YES;
    // 取出对应的模型
    XMWebModel *model = self.webs[indexPath.row];

    // 通知代理发送网络请求
    if ([self.delegate respondsToSelector:@selector(openWebmoduleRequest:)])
    {
        [_delegate openWebmoduleRequest:model];
    }
}

#pragma mark - 刷新表格数据
- (void)refresh
{
    //---------------旧的刷新动画---------------
    // 不允许连续多次点击刷新按钮
//    self.btnRefresh.userInteractionEnabled = NO;
    // 0,创建动画，刷新按钮旋转
//    [self addRotationAnimation];
    //----------------------------------------
    
    _isRefreshing = YES;
    // 0,设置下拉标题提示用户正在刷新
    _headerRefreshV.enabled = YES;
    _headerRefreshV.selected = YES;
    // 添加动画
    [_headerRefreshV.imageView.layer addAnimation:[self addRotationAnimation] forKey:nil];
    
    // 1,创建session
    NSURLSessionConfiguration *cfg = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:cfg];
    
    // 2,创建url
    // 取出当前频道
    XMChannelModel *model = [XMChannelModel channels][_currentChannel];
    NSURL *idUrl = [NSURL URLWithString:model.url];
    
    // 3,创建一个下载任务，类型为NSURLSessionDataTask
    NSURLSessionDataTask *task = [session dataTaskWithURL:idUrl  completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
      {
          _isRefreshing = NO;

          if (!error)
          {
              // 5,创建session网络请求结束后
              // 解析json数据
              NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
              // 根据dict更新数据
              [self dealJsonDataWithDict:dict];
          }else
          {
              // 6，回到主线程设置cell的信息
              [self backToMainQueueWithMessage:@"加载失败"];
          }
          
      }];
    
    // 4,开始任务（异步）
    [task resume];
}

// 设置刷新转动动画
- (CABasicAnimation *)addRotationAnimation
{
    CABasicAnimation *anim = [CABasicAnimation animation];
    anim.keyPath = @"transform.rotation";
    anim.toValue = @(M_PI * 2);
    // 设置动画时长
    anim.duration = 0.5;
    // 重复动画的次数
    anim.repeatCount = MAXFLOAT;
//    [self.btnRefresh.layer addAnimation:anim forKey:nil];
    return anim;
}

// 根据dict更新数据
- (void)dealJsonDataWithDict:(NSDictionary *)dict
{
    NSMutableArray *arrM = [NSMutableArray array];
    NSUInteger refreshCount = 6;
    arrM = (NSMutableArray *)[XMWebModel websWithDict:dict refreshCount:refreshCount];
    // 拼接新刷新的数据到最前面
    if (self.webs.count)
    {
        [arrM addObjectsFromArray:self.webs];
    }
    self.webs = arrM;
    
    if (self.webs.count > 30)
    {
        for (int i = 0; i < refreshCount;i++) {
            [self.webs removeLastObject];
        }
    }
    // 6，回到主线程设置cell的信息
    [self backToMainQueueWithMessage:[NSString stringWithFormat:@"成功加载%ld条新闻",arrM.count]];
    
    // 清空中转数组
    arrM = nil;
}

// 回到主线程
- (void)backToMainQueueWithMessage:(NSString *)message
{
#warning note 必须回到主线程设置参数
    // 6，回到主线程设置cell的信息
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        // 结束刷新
        [UIView animateWithDuration:0.25 animations:^{
            self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
        }completion:^(BOOL finished) {
            // 移除动画
            [_headerRefreshV.imageView.layer removeAllAnimations];
            // 隐藏刷新
            self.headerRefreshV.hidden = YES;
            // 恢复标题
            _headerRefreshV.selected = NO;
            
            // 滚到最顶部
            [self upToTop];
        }];
        
        
        // 结束旋转动画
//        [self.btnRefresh.layer removeAllAnimations];
        
        // 恢复按钮的可操作
//        self.btnRefresh.userInteractionEnabled = YES;
        
        // 提示用户刷新成功
        [self setRefreshCount:message];
        
        // 刷新表格
        [self.tableView reloadData];
    }];
}

@end
