//
//  XMNavigationViewController.h
//  虾兽维度
//
//  Created by Niki on 2018/7/17.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XMNavigationController : UINavigationController

/// 暴露自定义的手势,用于处理手势冲突问题
@property (weak, nonatomic)  UIGestureRecognizer *customerPopGestureRecognizer;

@property (nonatomic, strong) NSMutableArray *pushScreenShotArr;

@end
