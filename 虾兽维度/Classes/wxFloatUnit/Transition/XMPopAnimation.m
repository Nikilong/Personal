//
//  XMPopAnimation.m
//  虾兽维度
//
//  Created by Niki on 2018/8/2.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMPopAnimation.h"
#import "AppDelegate.h"


@interface XMPopAnimation ()

@property (nonatomic, strong) id <UIViewControllerContextTransitioning> transitionContext;
@end

@implementation XMPopAnimation

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    //这个方法返回动画执行的时间
    return 0.25;
}

/// transitionContext你可以看作是一个工具，用来获取一系列动画执行相关的对象，并且通知系统动画是否完成等功能。
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    // 获取动画来自的那个控制器,即目前显示的最顶部的控制器
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    // 获取转场到的那个控制器,即上一个控制器
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    // 转场动画是两个控制器视图时间的动画，需要一个containerView来作为一个“舞台”，让动画执行。
    UIView *containerView = [transitionContext containerView];
    
    // 上一个控制器先左偏移一个距离,然后随着右滑跟着移动
    CGFloat toVCOffsetX = 100;
    CGRect toVCF = toViewController.view.frame;
    toVCF.origin.x = -toVCOffsetX;
    toViewController.view.frame = toVCF;
    [containerView addSubview:toViewController.view];
    
    // 创建截图，并把imageView隐藏，造成使用户以为移动的就是 imageView 的假象
    UIView *snapshotView = [fromViewController.view snapshotViewAfterScreenUpdates:NO];
    snapshotView.frame = [containerView convertRect:fromViewController.view.frame fromView:fromViewController.view];
    
    // tableview等需要额外向下调整一定距离
    if ([fromViewController.class isSubclassOfClass:UITableViewController.class]){
        CGRect tarF = snapshotView.frame;
        tarF.origin.y -= 44 + XMStatusBarHeight;
        snapshotView.frame = tarF;
    }
    [containerView addSubview:snapshotView];
    
    // 截图添加左侧边阴影
    UIImageView *shawdowV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bodyShodow_L"]];
    shawdowV.frame = CGRectMake(-5, 0, 5, snapshotView.frame.size.height);
    [snapshotView addSubview:shawdowV];
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    // 执行动画，我们让fromVC的视图移动到屏幕最右侧
    [UIView animateWithDuration:duration animations:^{
        toViewController.view.frame = CGRectMake(0, 0, XMScreenW, XMScreenH);
        snapshotView.transform = CGAffineTransformMakeTranslation(XMScreenW, 0);
    }completion:^(BOOL finished) {
        // 移除截图
        [snapshotView removeFromSuperview];

        //一定要记得动画完成后执行此方法，让系统管理 navigation
        if ([transitionContext transitionWasCancelled]) {
            [toViewController.view removeFromSuperview];
        }else{
            AppDelegate *app = [UIApplication sharedApplication].delegate;
            app.tempVC = nil;
        }
        // 当你的动画执行完成，这个方法必须要调用，否则系统会认为你的其余任何操作都在动画执行过程中。
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
    
    //    _transitionContext = transitionContext;
    //----------------pop动画一-------------------------//
    /*
     [UIView beginAnimations:@"View Flip" context:nil];
     [UIView setAnimationDuration:duration];
     [UIView setAnimationDelegate:self];
     [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:containerView cache:YES];
     [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:)];
     [UIView commitAnimations];//提交UIView动画
     [containerView exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
     */
    //----------------pop动画二-------------------------//
    /*
     CATransition *tr = [CATransition animation];
     tr.type = @"cube";
     tr.subtype = @"fromLeft";
     tr.duration = duration;
     tr.removedOnCompletion = NO;
     tr.fillMode = kCAFillModeForwards;
     tr.delegate = self;
     [containerView.layer addAnimation:tr forKey:nil];
     [containerView exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
     */
}

- (void)animationDidStop:(CATransition *)anim finished:(BOOL)flag {
    [self.transitionContext completeTransition:!self.transitionContext.transitionWasCancelled];
}
@end
