//
//  MBProgressHUD+NK.h
//  03 虾兽新闻客户端
//
//  Created by Niki on 17/3/31.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (NK)

/** 创建一个进度条，仅仅是延时作用，实际不作任何操作 */
+ (void)showProgressInView:(UIView *)view mode:(MBProgressHUDMode)mode duration:(NSTimeInterval)duration title:(NSString *)title;

/** 显示消息 */
+ (void)showMessage:(NSString *)text toView:(UIView *)view;
+ (void)showSuccess:(NSString *)success toView:(UIView *)view;

@end
