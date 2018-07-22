//
//  XMNavigationViewController.m
//  虾兽维度
//
//  Created by Niki on 2018/7/17.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMNavigationController.h"
#import "XMRightBottomFloatView.h"

@interface XMNavigationController()<UIGestureRecognizerDelegate>

@end

@implementation XMNavigationController

-(void)viewDidLoad{
    [super viewDidLoad];

    // 禁用原生的左侧边右滑pop手势
    self.interactivePopGestureRecognizer.enabled = NO;
    // 添加自定义的右滑pop手势
    UIScreenEdgePanGestureRecognizer *edge = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(edgeDidPan:)];
    self.customerPopGestureRecognizer = edge;
    edge.edges = UIRectEdgeLeft;
    edge.delegate = self;
    [self.view addGestureRecognizer:edge];
}

/// 屏幕左边沿手势方法
- (void)edgeDidPan:(UIScreenEdgePanGestureRecognizer *)gest{
    // 禁止手势响应的vc列表
    if([self.childViewControllers.lastObject isKindOfClass:NSClassFromString(@"XMMainViewController")]){
        return;
    }
    CGPoint point = [gest locationInView:[UIApplication sharedApplication].windows[0]];
    if (gest.state == UIGestureRecognizerStateBegan) {
        if ([XMRightBottomFloatView shareRightBottomFloatView].rightBottomStartBlock) {
            [XMRightBottomFloatView shareRightBottomFloatView].rightBottomStartBlock(YES);
        }
    }else if (gest.state == UIGestureRecognizerStateChanged) {
        if ([XMRightBottomFloatView shareRightBottomFloatView].rightBottomChangeBlock) {
            [XMRightBottomFloatView shareRightBottomFloatView].rightBottomChangeBlock(point);
        }
    }else if (gest.state == UIGestureRecognizerStateEnded) {
        if ([XMRightBottomFloatView shareRightBottomFloatView].rightBottomEndBlock) {
            [XMRightBottomFloatView shareRightBottomFloatView].rightBottomEndBlock(YES);
        }
    }else{
        if ([XMRightBottomFloatView shareRightBottomFloatView].rightBottomCancelOrFailBlock) {
            [XMRightBottomFloatView shareRightBottomFloatView].rightBottomCancelOrFailBlock();
        }
    }
    
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

//- (void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//    
//    // 重置状态栏的颜色
//    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
//    statusBar.backgroundColor = nil;
//}

//- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
//    [super pushViewController:viewController animated:animated];
//    
//}
//
//- (UIViewController *)popViewControllerAnimated:(BOOL)animated{
//    return [super popViewControllerAnimated:animated];
//    
//}

//- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
//    [super willsh];
//}

//- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end
