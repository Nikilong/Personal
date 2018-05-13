//
//  MBProgressHUD+NK.h
//  虾兽维度
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

/** 显示一张图标*/
+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view;

/** 显示一张样例图片*/
+ (void)show:(NSString *)text image:(UIImage *)image view:(UIView *)view;
@end
