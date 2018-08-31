//
//  XMFreshView.h
//  虾兽维度
//
//  Created by Niki on 2018/8/31.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    XMFreshResultSuccess,
    XMFreshResultFail,
}XMFreshResult;

typedef void(^XMFreshBlock)();

@interface XMFreshView : UIView

@property (nonatomic, copy) XMFreshBlock freshBlock;
@property (nonatomic, copy) XMFreshBlock finishFreshBlock;

+ (XMFreshView *)addHeaderFreshViewInTableView:(UITableView *)tableView hasTimeLable:(BOOL)hasTimeLable;

- (void)tableViewWillBeginDragging;
- (void)tableViewDidEndDraggingWillDecelerate:(BOOL)decelerate;
- (void)tableViewDidScroller;

- (void)startLoading;
- (void)finishLoadingWithResult:(XMFreshResult)XMFreshResult;

@end
