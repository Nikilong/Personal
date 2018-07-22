//
//  XMRefreshHeaderView.h
//  虾兽维度
//
//  Created by Niki on 18/7/21.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XMRefreshHeaderView;

typedef void(^xmRefreshBlock)();
typedef void(^xmRefreshCallBackBlock)(XMRefreshHeaderView *);

@interface XMRefreshHeaderView : UIView

+ (XMRefreshHeaderView *)xm_addPullRefreshHeader:(UITableView *)tableView;


@property (nonatomic, copy) xmRefreshBlock tableViewShouldRefreshBlock;
@property (nonatomic, copy) xmRefreshCallBackBlock tableViewDidRefreshBlock;
@end
