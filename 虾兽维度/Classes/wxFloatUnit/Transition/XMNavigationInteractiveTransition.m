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

// 记录栈顶控制器,以方便添加到浮窗
@property (nonatomic, strong) UIViewController *lastVC;
@end

@implementation XMNavigationInteractiveTransition

- (instancetype)initWithViewController:(UIViewController *)vc{
    self = [super init];
    if (self) {
        self.vc = (XMNavigationController *)vc;
        self.vc.delegate = self;
    }
    return self;
}

/// 全屏pop手势
- (void)handleControllerPop:(UIPanGestureRecognizer *)recognizer {
    // interactivePopTransition就是我们说的方法2返回的对象，我们需要更新它的进度来控制Pop动画的流程，我们用手指在视图中的位置与视图宽度比例作为它的进度。
    CGFloat progress = [recognizer translationInView:[UIApplication sharedApplication].windows[0]].x / XMScreenW;
//    NSLog(@"%.2f",progress);
    // 左边界设置,如果是先右滑再滑到最左边则取消动画,完成一次操作,必须cancel和设置为nil
    if(progress < 0){
        if(self.interactivePopTransition){
            [self.interactivePopTransition cancelInteractiveTransition];
            self.interactivePopTransition = nil;
        }
        return;
    }

    // 稳定进度区间，让它在0.0（未完成）～1.0（已完成）之间
    progress = MIN(1.0, MAX(0.0, progress));
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        // 手势开始，新建一个监控对象
        self.interactivePopTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
        // 告诉控制器开始执行pop的动画
        [self.vc popViewControllerAnimated:YES];
    }else if (recognizer.state == UIGestureRecognizerStateChanged) {
         // 更新手势的完成进度
        [self.interactivePopTransition updateInteractiveTransition:progress];
    }else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        
     // 手势结束时如果进度大于一半，那么就完成pop操作，否则重新来过。
        if (progress > 0.3) {
            [self.interactivePopTransition finishInteractiveTransition];
        }else {
            [self.interactivePopTransition cancelInteractiveTransition];
        }
        
        self.interactivePopTransition = nil;
    }
    
}


/// 屏幕左边沿手势方法
- (void)edgeDidPan:(UIScreenEdgePanGestureRecognizer *)gest{

    CGFloat progress = [gest translationInView:[UIApplication sharedApplication].windows[0]].x / XMScreenW;
    // 稳定进度区间，让它在0.0（未完成）～1.0（已完成）之间
    progress = MIN(1.0, MAX(0.0, progress));
    
    CGPoint blockPoint = [gest locationInView:[UIApplication sharedApplication].windows[0]];
    //    CGPoint point = [gest translationInView:[UIApplication sharedApplication].windows[0]];
    if (gest.state == UIGestureRecognizerStateBegan) {
        
        if ([XMRightBottomFloatView shareRightBottomFloatView].rightBottomStartBlock) {
            [XMRightBottomFloatView shareRightBottomFloatView].rightBottomStartBlock(YES);
        }
        // 手势开始，新建一个监控对象
        self.interactivePopTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
        // 告诉控制器开始执行pop的动画
//        self.lastVC = self.vc.childViewControllers.lastObject;
        AppDelegate *app = [UIApplication sharedApplication].delegate;
        app.tempVC = self.vc.childViewControllers.lastObject;
        [self.vc popViewControllerAnimated:YES];
        
        
    }else if (gest.state == UIGestureRecognizerStateChanged) {
        [self.interactivePopTransition updateInteractiveTransition:progress];

        if ([XMRightBottomFloatView shareRightBottomFloatView].rightBottomChangeBlock) {
            [XMRightBottomFloatView shareRightBottomFloatView].rightBottomChangeBlock(blockPoint);
        }
        
        
    }else if (gest.state == UIGestureRecognizerStateEnded) {
        // 手势结束时如果进度大于一半，那么就完成pop操作，否则重新来过。
        if([XMRightBottomFloatView shareRightBottomFloatView].isInArea){
            AppDelegate *dele = (AppDelegate *)[UIApplication sharedApplication].delegate;
            dele.floadVC = self.lastVC;
            [self.interactivePopTransition finishInteractiveTransition];
        }else{
            if (progress > 0.3) {
                [self.interactivePopTransition finishInteractiveTransition];
            }
            else {
                [self.interactivePopTransition cancelInteractiveTransition];
            }
        }
//        self.lastVC = nil;
        self.interactivePopTransition = nil;
        
        // 通知浮窗
        if ([XMRightBottomFloatView shareRightBottomFloatView].rightBottomEndBlock) {
            [XMRightBottomFloatView shareRightBottomFloatView].rightBottomEndBlock(YES);
        }
        
    }else{
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

