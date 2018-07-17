//
//  XMNavigationViewController.m
//  虾兽维度
//
//  Created by Niki on 2018/7/17.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMNavigationController.h"
#import "XMRightBottomFloatView.h"

@interface XMNavigationController()<UINavigationBarDelegate,UINavigationControllerDelegate,UIGestureRecognizerDelegate>

@end

@implementation XMNavigationController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    // 添加自定义的右滑pop手势
//    self.interactivePopGestureRecognizer.enabled = NO;
    UIScreenEdgePanGestureRecognizer *edge = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(edgeDidPan:)];
    edge.edges = UIRectEdgeLeft;
    edge.delegate = self;
    [self.view addGestureRecognizer:edge];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
//    self.interactivePopGestureRecognizer.enabled = YES;
    [super pushViewController:viewController animated:animated];
    
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated{
    
//    self.interactivePopGestureRecognizer.enabled = YES;
    
    return [super popViewControllerAnimated:animated];
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

- (void)edgeDidPan:(UIScreenEdgePanGestureRecognizer *)gest{
//    CGFloat progress = [gest locationInView:self.view].x / XMScreenW;
    CGPoint point = [gest locationInView:[UIApplication sharedApplication].windows[0]];
    if (gest.state == UIGestureRecognizerStateBegan) {
//        NSLog(@"start");
        if ([XMRightBottomFloatView shareRightBottomFloatView].rightBottomStartBlock) {
            [XMRightBottomFloatView shareRightBottomFloatView].rightBottomStartBlock(YES);
        }
    }else if (gest.state == UIGestureRecognizerStateChanged) {
//        NSLog(@"change--%.2f",progress);
//        if (progress > 0.2){
//            if (self.delegate && [self.delegate respondsToSelector:@selector(didEndPanGesture)]) {
//                [self.delegate didChangePanGesture:point];
//            }
//        }
        if ([XMRightBottomFloatView shareRightBottomFloatView].rightBottomChangeBlock) {
            [XMRightBottomFloatView shareRightBottomFloatView].rightBottomChangeBlock(point);
        }
    }else if (gest.state == UIGestureRecognizerStateEnded) {
//        NSLog(@"end");
        if ([XMRightBottomFloatView shareRightBottomFloatView].rightBottomEndBlock) {
            [XMRightBottomFloatView shareRightBottomFloatView].rightBottomEndBlock(YES);
        }
    }
    
}




//- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
//    [super willsh];
//}

//- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end
