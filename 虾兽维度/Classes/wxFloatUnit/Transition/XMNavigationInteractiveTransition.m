//
//  XMNavigationInteractiveTransition.m
//  虾兽维度
//
//  Created by Niki on 2018/8/2.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMNavigationInteractiveTransition.h"
#import "XMPopAnimation.h"

#import "XMWXVCFloatWindow.h"
#import "XMRightBottomFloatView.h"
#import "AppDelegate.h"

#import "XMNavigationController.h"

@interface XMNavigationInteractiveTransition ()

@property (nonatomic, weak) XMNavigationController *vc;
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *interactivePopTransition;

@end

@implementation XMNavigationInteractiveTransition

static CGPoint blockPoint;
static double progress;

- (instancetype)initWithViewController:(UIViewController *)vc{
    self = [super init];
    if (self) {
        self.vc = (XMNavigationController *)vc;
        self.vc.delegate = self;
    }
    return self;
}

/// 全屏pop手势+屏幕左边沿手势方法
- (void)handleControllerPop:(UIPanGestureRecognizer *)recognizer {
    // interactivePopTransition就是我们说的方法2返回的对象，我们需要更新它的进度来控制Pop动画的流程，我们用手指在视图中的位置与视图宽度比例作为它的进度。
//    CGPoint blockPoint = [recognizer locationInView:[UIApplication sharedApplication].windows[0]];
    blockPoint = [recognizer locationInView:[UIApplication sharedApplication].windows[0]];
    progress = [recognizer translationInView:[UIApplication sharedApplication].windows[0]].x / XMScreenW;
    // (必须在前面禁止左划才可以注释这段)左边界设置,如果是先右滑再滑到最左边则取消动画,完成一次操作,必须cancel和设置为nil
//    if(progress < 0){
//        if(self.interactivePopTransition){
//            [self.interactivePopTransition cancelInteractiveTransition];
//            self.interactivePopTransition = nil;
//        }
//        return;
//    }

    // 稳定进度区间，让它在0.0（未完成）～1.0（已完成）之间
    progress = MIN(1.0, MAX(0.0, progress));
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if ([XMRightBottomFloatView shareRightBottomFloatView].rightBottomStartBlock) {
            [XMRightBottomFloatView shareRightBottomFloatView].rightBottomStartBlock(YES);
        }
        // 告诉控制器开始执行pop的动画,顶部控制器先保存到appdelegate中,防止被释放
        AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        app.tempVC = self.vc.childViewControllers.lastObject;
        // 手势开始，新建一个监控对象
        self.interactivePopTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
        [self.vc popViewControllerAnimated:YES];
    }else if (recognizer.state == UIGestureRecognizerStateChanged) {
        // 更新手势的完成进度
        [self.interactivePopTransition updateInteractiveTransition:progress];
        // 通知扇形区
        if ([XMRightBottomFloatView shareRightBottomFloatView].rightBottomChangeBlock) {
            [XMRightBottomFloatView shareRightBottomFloatView].rightBottomChangeBlock(blockPoint);
        }
    }else if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        AppDelegate *dele = (AppDelegate *)[UIApplication sharedApplication].delegate;
        // 手势结束时如果进度大于指定距离，那么就完成pop操作，否则重新来过。
        if([XMRightBottomFloatView shareRightBottomFloatView].isInArea){
            dele.floadVC = dele.tempVC;
            [self.interactivePopTransition finishInteractiveTransition];
        }else{
            if (progress > 0.3) {
                [self.interactivePopTransition finishInteractiveTransition];
            }
            else {
                [self.interactivePopTransition cancelInteractiveTransition];
            }
        }
        progress = 0;
        dele.tempVC = nil;
        self.interactivePopTransition = nil;
        
        // 通知浮窗
        if ([XMRightBottomFloatView shareRightBottomFloatView].rightBottomEndBlock) {
            [XMRightBottomFloatView shareRightBottomFloatView].rightBottomEndBlock(YES);
        }
    }else{
        [self.interactivePopTransition cancelInteractiveTransition];
        AppDelegate *dele = (AppDelegate *)[UIApplication sharedApplication].delegate;
        progress = 0;
        dele.tempVC = nil;
        self.interactivePopTransition = nil;
        
        if ([XMRightBottomFloatView shareRightBottomFloatView].rightBottomCancelOrFailBlock) {
            [XMRightBottomFloatView shareRightBottomFloatView].rightBottomCancelOrFailBlock();
        }
    }
    
}


- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    // 方法1中判断如果当前执行的是Pop操作，就返回我们自定义的Pop动画对象。
    if (operation == UINavigationControllerOperationPop){
        return [[XMPopAnimation alloc] init];
    }
    
    return nil;
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    
    // 方法2会传给你当前的动画对象animationController，判断如果是我们自定义的Pop动画对象，那么就返回interactivePopTransition来监控动画完成度。
    if([animationController isKindOfClass:[XMPopAnimation class]]){
        return self.interactivePopTransition;
    }
    
    return nil;
}

@end

