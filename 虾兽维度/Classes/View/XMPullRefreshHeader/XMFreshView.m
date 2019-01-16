//
//  XMFreshView.m
//  虾兽维度
//
//  Created by Niki on 2018/8/31.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMFreshView.h"

@interface XMFreshView()

@property (weak, nonatomic)  UITableView *sourceTableView;


@property (weak, nonatomic)  UILabel *timeLab;
@property (weak, nonatomic)  UIButton *tipBtn;

@property (nonatomic, assign)  BOOL isRefreshing;
@property (nonatomic, assign)  BOOL isDragging;


@end

@implementation XMFreshView

CGFloat const XMPullRrfreshHeight = 64;


+ (XMFreshView *)addHeaderFreshViewInTableView:(UITableView *)tableView hasTimeLable:(BOOL)hasTimeLable{
    XMFreshView *headerRefreshV = [[XMFreshView alloc] init];
    headerRefreshV.frame = CGRectMake(0, -(hasTimeLable ? 60 : 44), XMScreenW, (hasTimeLable ? 60 : 44));
    [tableView addSubview:headerRefreshV];
    headerRefreshV.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    headerRefreshV.sourceTableView = tableView;
    
    
    UIButton *tipBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    headerRefreshV.tipBtn = tipBtn;
    [tipBtn setTitle:@"下拉刷新" forState:UIControlStateNormal];
    [tipBtn setTitle:@"加载数据中..." forState:UIControlStateSelected];
    [tipBtn setTitle:@"松手可刷新" forState:UIControlStateDisabled];
    [tipBtn setImage:[UIImage imageNamed:@"shuaxin"] forState:UIControlStateSelected];
    [tipBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    tipBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    tipBtn.backgroundColor = [UIColor clearColor];
    [tipBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
    [headerRefreshV addSubview:tipBtn];
    return headerRefreshV;
}


#pragma mark -
#pragma mark - 刷新反馈
- (void)startLoading{
    // 当前正在刷新则返回避免连续刷新
    if(self.isRefreshing) return;
    // 固定下拉标签
    self.sourceTableView.contentInset = UIEdgeInsetsMake(self.frame.size.height, 0, 0, 0);
    self.isRefreshing = YES;
    // 0,设置下拉标题提示用户正在刷新
    self.tipBtn.enabled = YES;
    self.tipBtn.selected = YES;
    // 添加动画
    [self.tipBtn.imageView.layer addAnimation:[self addRotationAnimation] forKey:nil];
}

- (void)finishLoadingWithResult:(XMFreshResult)XMFreshResult{
    // 恢复刷新
    self.isRefreshing = NO;
    // 移除动画
    [self.tipBtn.imageView.layer removeAllAnimations];
    // 恢复标题
    self.tipBtn.selected = NO;
    
    // 结束刷新
    [UIView animateWithDuration:0.25 animations:^{
        self.sourceTableView.contentInset = UIEdgeInsetsZero;
    }completion:^(BOOL finished) {
        if(self.finishFreshBlock){
            self.finishFreshBlock();
        }
    }];
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

#pragma mark - 下拉反馈
- (void)tableViewWillBeginDragging{
    self.isDragging = YES;
}

- (void)tableViewDidEndDraggingWillDecelerate:(BOOL)decelerate{
    self.isDragging = NO;// 标记拖拽完毕
    // 判断是否触发刷新
    if (-self.sourceTableView.contentOffset.y > XMPullRrfreshHeight){
        // 刷新数据
        if(self.freshBlock){
            self.freshBlock();
        }
    }
}

- (void)tableViewDidScroller{
    if (self.isRefreshing) return;
    
    // 如果下拉到固定值修改标题提示用户
    if (-self.sourceTableView.contentOffset.y > XMPullRrfreshHeight && self.isDragging){
        self.tipBtn.enabled = NO;
    }else{
        self.tipBtn.enabled = YES;
    }
    
}
@end
