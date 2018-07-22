//
//  XMRefreshHeaderView.m
//  虾兽维度
//
//  Created by Niki on 18/7/21.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMRefreshHeaderView.h"
#import "XMWifiGroupTool.h"

@interface XMRefreshHeaderView()<UIScrollViewDelegate>

@property (weak, nonatomic)  UILabel *timeLab;
@property (weak, nonatomic)  UILabel *tipLab;
@property (nonatomic, assign)  BOOL isDragging;
@property (nonatomic, assign)  BOOL isRefreshing;

@property (weak, nonatomic)  UITableView *tableView;


@end

@implementation XMRefreshHeaderView

//CGFloat const XMRrfreshHeight = 120;
//
///*
//// Only override drawRect: if you perform custom drawing.
//// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect {
//    // Drawing code
//}
//*/
//
//+ (XMRefreshHeaderView *)xm_addPullRefreshHeader:(UITableView *)tableView{
//    XMRefreshHeaderView *contentView = [[XMRefreshHeaderView alloc] initWithFrame:CGRectMake(0, -44, XMScreenW, 44)];
//    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    [tableView addSubview:contentView];
////    contentView.backgroundColor = [UIColor orangeColor];
//    
//    // 初始化参数
//    contentView.hidden = YES;
//    contentView.tableView = tableView;
//    contentView.isDragging = NO;
//    contentView.isRefreshing = NO;
//    contentView.tableViewDidRefreshBlock = ^(XMRefreshHeaderView *headerV){
//        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//        //设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
//        [formatter setDateFormat:@"YYYY/MM/dd HH:mm:ss"];
//        //将nsdate按formatter格式转成nsstring
//        NSString *currentTimeString = [formatter stringFromDate:[NSDate date]];
//        NSString *timeStr = [NSString stringWithFormat:@"上次更新时间: %@",currentTimeString];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            headerV.timeLab.text = timeStr;
//        });
//        
//    };
//    
//    UILabel *tipLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, XMScreenW, 20)];
//    contentView.tipLab = tipLab;
//    [contentView addSubview:tipLab];
//    tipLab.text = @"下拉刷新";
//    tipLab.font = [UIFont systemFontOfSize:13];
//    tipLab.textColor = [UIColor grayColor];
//    tipLab.textAlignment = NSTextAlignmentCenter;
//    
//    UILabel *timeLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, XMScreenW, 20)];
//    contentView.timeLab = timeLab;
//    [contentView addSubview:timeLab];
//    timeLab.font = [UIFont systemFontOfSize:13];
//    timeLab.textColor = [UIColor grayColor];
////    timeLab.text = @"上次更新时间:2018/08/09 15:20:34";
//    timeLab.textAlignment = NSTextAlignmentCenter;
//    
//    
//    // 监听tableView下拉
////    tableView.delegate = contentView;
//    return contentView;
//}
//
//
//#pragma mark 监听scroller的滚动
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    
//    if (self.isRefreshing) return;
//    
//    CGFloat tableViewOffet = -self.tableView.contentOffset.y;
//    
//    if (tableViewOffet > 64){
//        // 取消下拉横幅隐藏
//        self.hidden = NO;
//    }else if (tableViewOffet == 64){
//        // 隐藏刷新
//        self.hidden = YES;
//    }
//    
//    // 如果下拉到固定值修改标题提示用户
//    if (tableViewOffet > XMRrfreshHeight && self.isDragging){
//        self.tipLab.text = @"松开刷新";
//    }else{
//        self.tipLab.text = @"加载数据中...";
//    }
//}
//
///**
// 开始拖拽,做标记
// */
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
//    self.isDragging = YES;
//}
///**
// 结束拖拽,处理事件
// */
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
//    // 标记拖拽完毕
//    self.isDragging = NO;
//    // 判断是否触发刷新
//    if (-self.tableView.contentOffset.y > XMRrfreshHeight){
//        // 固定下拉标签
//        [UIView animateWithDuration:0.5f animations:^{
//            self.tableView.contentInset = UIEdgeInsetsMake(XMRrfreshHeight, 0, 0, 0);
//        }];
//        // 刷新数据
//        if (self.tableViewShouldRefreshBlock){
//            self.tableViewShouldRefreshBlock();
//        }
//    }
//    
//}

@end
