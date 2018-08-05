//
//  XMNavigationInteractiveTransition.h
//  虾兽维度
//
//  Created by Niki on 2018/8/2.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface XMNavigationInteractiveTransition : NSObject<UINavigationControllerDelegate>

- (instancetype)initWithViewController:(UIViewController *)vc;
//- (UIPercentDrivenInteractiveTransition *)interactivePopTransition;

/// 全屏pop手势
- (void)handleControllerPop:(UIPanGestureRecognizer *)recognizer;
/// 左侧屏pop手势
- (void)edgeDidPan:(UIScreenEdgePanGestureRecognizer *)gest;

@end
