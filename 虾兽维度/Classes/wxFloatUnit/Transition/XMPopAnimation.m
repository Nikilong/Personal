//
//  XMPopAnimation.m
//  虾兽维度
//
//  Created by Niki on 2018/8/2.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMPopAnimation.h"
#import "AppDelegate.h"

#import "XMImageUtil.h"
#import "XMNavigationController.h"


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
    /*
     原理解释:实际上就是上一个控制器和当前控制器两个截图的联动(为了避免两者导航栏颜色差别或者一个有导航栏一个没有导航栏造成很挫的效果),
     注意点:
     1.一定要添加toViewController.view到containerView
     2.对于xcode9,两个截图要添加到navigationController.navigationBar,而且注意两者添加顺序
     3.对于xcode8,两个截图不能添加到navigationController.navigationBar,而是要添加到containerView,并且需要隐藏上一个导航栏,而且注意两者添加顺序
     */
    
    // 获取动画来自的那个控制器,即目前显示的最顶部的控制器
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    // 获取转场到的那个控制器,即上一个控制器
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    // 转场动画是两个控制器视图时间的动画，需要一个containerView来作为一个“舞台”，让动画执行。
    UIView *containerView = [transitionContext containerView];
    
    // 1.上一个控制器隐藏导航栏,并记录隐藏状态
    BOOL hideFlag = toViewController.navigationController.navigationBar.hidden;
    toViewController.navigationController.navigationBar.hidden = YES;
    
    // 2.(必要)添加上一个控制器视图到containerView
    [containerView addSubview:toViewController.view];
    
    // 3.先添加上一个控制器截图,并且设置左偏移一个距离,然后随着右滑跟着移动
    CGFloat toVCOffsetX = 100;
    XMNavigationController *nav = (XMNavigationController *)fromViewController.navigationController;
    UIImageView *fromVCShot = [[UIImageView alloc] initWithImage:nav.pushScreenShotArr.lastObject];
    fromVCShot.frame = CGRectMake(-toVCOffsetX, 0, XMScreenW, XMScreenH);
    [containerView addSubview:fromVCShot];
    UIView *cover = [[UIView alloc] initWithFrame:CGRectMake(0, 0, XMScreenW, XMScreenH)];
    cover.backgroundColor = [UIColor blackColor];
    cover.alpha = 0.3;
    [fromVCShot addSubview:cover];
    
    // 4.创建当前最顶部控制器的截图
    UIImageView *snapshotView = [[UIImageView alloc] initWithImage:[XMImageUtil screenShot]];
    snapshotView.frame = CGRectMake(0, 0, XMScreenW, XMScreenH);
    [containerView addSubview:snapshotView];
    
    // (非必须)截图添加左侧边阴影
    UIImageView *shawdowV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bodyShodow_L"]];
    shawdowV.frame = CGRectMake(-5, 0, 5, snapshotView.frame.size.height);
    [snapshotView addSubview:shawdowV];
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    // 执行动画，我们让fromVC的视图移动到屏幕最右侧
    [UIView animateWithDuration:duration animations:^{
        // 两张截图联动
        fromVCShot.frame = CGRectMake(0, 0, XMScreenW, XMScreenH);
        snapshotView.transform = CGAffineTransformMakeTranslation(XMScreenW, 0);
        cover.alpha = 0;
    }completion:^(BOOL finished) {
        // 恢复上一个控制器导航栏的状态
        toViewController.navigationController.navigationBar.hidden = hideFlag;
        // 移除截图
        [snapshotView removeFromSuperview];
        [fromVCShot removeFromSuperview];

        //一定要记得动画完成后执行此方法，让系统管理 navigation
        if ([transitionContext transitionWasCancelled]) {
            // 动画取消,没有pop掉顶部控制器
            [toViewController.view removeFromSuperview];
        }else{
            // 动画完成,pop掉顶部控制器
            // 移除最后一张截图
            [nav.pushScreenShotArr removeLastObject];
            
            // 清除app缓存的控制器
            AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
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
