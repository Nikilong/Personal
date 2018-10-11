//
//  XMProgressView.h
//  虾兽维度
//
//  Created by Niki on 2018/10/11.
//  Copyright © 2018年 excellence.com.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XMProgressView : UIView

/// 快速创建一个实例
+ (XMProgressView *)createProgressViewWithCenter:(CGPoint)center;

/// 开始动画
- (void)startAnimating;

/// 停止动画
- (void)stopAnimating;

/// 更新进度
- (void)updateProgress:(float)progress;

/// 是否在进行动画
- (BOOL)isAnimate;

@end
