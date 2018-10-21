//
//  XMNavigationViewController.m
//  虾兽维度
//
//  Created by Niki on 2018/7/17.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMNavigationController.h"
#import "XMRightBottomFloatView.h"
#import "XMWXVCFloatWindow.h"
#import "XMWXFloatWindowIconConfig.h"
#import "XMImageUtil.h"
#import "XMNavigationInteractiveTransition.h"
#import "MBProgressHUD+NK.h"


@interface XMNavigationController()<
UIGestureRecognizerDelegate,
UINavigationControllerDelegate>

@property (nonatomic, strong) XMNavigationInteractiveTransition *navT;

@end

@implementation XMNavigationController

- (void)viewDidLoad{
    [super viewDidLoad];

    UIGestureRecognizer *gesture = self.interactivePopGestureRecognizer;
    gesture.enabled = NO;
    UIView *gestureView = gesture.view;
    
    // 利用集中的动画的类去处理两个手势
    self.navT = [[XMNavigationInteractiveTransition alloc] initWithViewController:self];
    
    // 设置全屏pop手势
    UIPanGestureRecognizer *popRecognizer = [[UIPanGestureRecognizer alloc] init];
    popRecognizer.delegate = self;
    popRecognizer.maximumNumberOfTouches = 1;
    self.customerPopGestureRecognizer = popRecognizer;
    [gestureView addGestureRecognizer:popRecognizer];
    
    
    // 设置左侧pop和添加浮窗手势
    UIScreenEdgePanGestureRecognizer *edge = [[UIScreenEdgePanGestureRecognizer alloc] init];
//    self.customerPopGestureRecognizer = edge;
    edge.edges = UIRectEdgeLeft;
    edge.delegate = self;
    [gestureView addGestureRecognizer:edge];

    // 添加手势
    [popRecognizer addTarget:self.navT action:@selector(handleControllerPop:)];
    [edge addTarget:self.navT action:@selector(handleControllerPop:)];
    
    // 设置优先级
    [gesture requireGestureRecognizerToFail:edge];
//
//     // 注意:一旦设置这个所有自定义的pop动画将会失效
//    self.delegate = self;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    BOOL isHomeVC = [NSStringFromClass([viewController class]) isEqualToString:@"XMMainViewController"];
    // 添加截图
    if (!self.pushScreenShotArr){
        self.pushScreenShotArr = [NSMutableArray array];
    }
    // 统一在这里添加截图,但是移除截图根据popViewControllerAnimated:是否为yes,如果是yes,由XMPopAnimation统一移除截图,如果是NO,由该设置为NO的控制器移除截图
    if(!isHomeVC){
        [self.pushScreenShotArr addObject:[XMImageUtil screenShot]];
    }
    
    [super pushViewController:viewController animated:animated];

    // 隐藏tabbar
    self.tabBarController.tabBar.hidden = YES;
    
    // 根据偏好设置是否有缓存,以及是否应该在该控制器显示,这两个因素去考虑是否显示浮窗
    if([[NSUserDefaults standardUserDefaults] boolForKey:kCheckCreateFloatwindow]){
        if([XMWXFloatWindowIconConfig isSaveFloatVCInUserDefaults]){
            if ([self shoudHideFloatWindowInViewController:viewController]){
                [XMWXVCFloatWindow shareXMWXVCFloatWindow].hidden = YES;
            }else{
                [XMWXVCFloatWindow shareXMWXVCFloatWindow].hidden = NO;
            }
        }
    }
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated{
    UIViewController *viewController = [super popViewControllerAnimated:animated];
    // 默认pop掉之后,如果存有浮窗,都应该显示浮窗
    if([XMWXFloatWindowIconConfig isSaveFloatVCInUserDefaults]){
        [XMWXVCFloatWindow shareXMWXVCFloatWindow].hidden = NO;
    }

    return viewController;
}


#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]){
        if ([(UIPanGestureRecognizer *)gestureRecognizer velocityInView:self.view].x < 0){
            return NO;
        }
    }
    // 这里有两个条件不允许手势执行，1、当前控制器为根控制器；2、如果这个push、pop动画正在执行（私有属性）
    return self.viewControllers.count != 1 && ![[self valueForKey:@"_isTransitioning"] boolValue];
}


//
///// 屏幕左边沿手势方法
//- (void)edgeDidPan:(UIScreenEdgePanGestureRecognizer *)gest{
//    // 禁止手势响应的vc列表
//    if([self.childViewControllers.lastObject isKindOfClass:NSClassFromString(@"XMMainViewController")]){
//        return;
//    }
//    
//    float progress = [gest translationInView:[UIApplication sharedApplication].windows[0]].x / XMScreenW;
//
//    CGPoint blockPoint = [gest locationInView:[UIApplication sharedApplication].windows[0]];
//    CGPoint point = [gest translationInView:[UIApplication sharedApplication].windows[0]];
//    if (gest.state == UIGestureRecognizerStateBegan) {
////        self.view.subviews[0].userInteractionEnabled = NO;
//
//        // 记录浮窗是否隐藏
////        BOOL middleFlag = [XMWXVCFloatWindow shareXMWXVCFloatWindow].isHidden;
////        BOOL navBarFlag = self.navigationBar.isHidden;
////        self.navigationBar.hidden = YES;
////        [XMWXVCFloatWindow shareXMWXVCFloatWindow].hidden = YES;
////        UIImage *image = [XMImageUtil screenShot];
////        [XMWXVCFloatWindow shareXMWXVCFloatWindow].hidden = middleFlag;
////        self.navigationBar.hidden = navBarFlag;
////        [self popViewControllerAnimated:YES];
////        self.percentDrivenTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
//        
//        if ([XMRightBottomFloatView shareRightBottomFloatView].rightBottomStartBlock) {
//            [XMRightBottomFloatView shareRightBottomFloatView].rightBottomStartBlock(YES);
//        }
//        
//
//        // 将当前控制器截图,这是覆盖在最上面的控制器的视图,防止上面的手势动作
////        UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, XMScreenW, XMScreenH)];
////        [self.childViewControllers.lastObject.view.superview addSubview:imgV];
////        imgV.image = image;
////        self.screenshotTopImgV = imgV;
//        
//    }else if (gest.state == UIGestureRecognizerStateChanged) {
//        [self.percentDrivenTransition updateInteractiveTransition:progress];
//        
//        if ([XMRightBottomFloatView shareRightBottomFloatView].rightBottomChangeBlock) {
//            [XMRightBottomFloatView shareRightBottomFloatView].rightBottomChangeBlock(blockPoint);
//        }
//        
////        NSLog(@"%.2f",blockPoint.x);
//        // 防止过多向左移动视图
//        if(self.childViewControllers.lastObject.view.frame.origin.x < 0 && point.x < 0){
//            [gest setTranslation:CGPointZero inView:[UIApplication sharedApplication].windows[0]];
//            return;
//        }
//        //        self.navigationBar.transform = CGAffineTransformTranslate(self.navigationBar.transform, point.x, 0);
//        //        self.view.subviews[0].subviews[0].transform =  CGAffineTransformTranslate(self.view.subviews[0].subviews[0].transform, point.x, 0);
//        self.navigationBar.alpha = 1 - blockPoint.x / XMScreenW;
//        // 将当前最上面的控制器视图移动
//        self.childViewControllers.lastObject.view.transform = CGAffineTransformTranslate(self.childViewControllers.lastObject.view.transform, point.x, 0);
//        // 两张截图联动
//        self.screenshotImgV.transform = CGAffineTransformTranslate(self.screenshotImgV.transform, point.x * 100/(XMScreenW), 0);
//        self.screenshotTopImgV.transform = CGAffineTransformTranslate(self.screenshotTopImgV.transform, point.x, 0);
//
//        // 重置移动距离
//        [gest setTranslation:CGPointZero inView:[UIApplication sharedApplication].windows[0]];
//        
//    }else if (gest.state == UIGestureRecognizerStateEnded) {
//        self.childViewControllers.lastObject.view.userInteractionEnabled = YES;
////        self.view.subviews[0].userInteractionEnabled = YES;
//
//        
////        if(progress > 0.5){
////            [self.percentDrivenTransition finishInteractiveTransition];
////        }else{
////            [self.percentDrivenTransition cancelInteractiveTransition];
////        }
////        self.percentDrivenTransition = nil;
//        
//        // 这个需要用到isInArea,需要在rightBottomEndBlock实现之前运行
//        if(self.childViewControllers.lastObject.view.frame.origin.x > 100){
//            if(![XMRightBottomFloatView shareRightBottomFloatView].isInArea){
//                [self popViewControllerAnimated:NO];
//            }
//        }
//        if ([XMRightBottomFloatView shareRightBottomFloatView].rightBottomEndBlock) {
//            [XMRightBottomFloatView shareRightBottomFloatView].rightBottomEndBlock(YES);
//        }
//        
////        [UIView animateWithDuration:0.25 animations:^{
//            // 恢复所有移动的视图
//            self.childViewControllers.lastObject.view.transform = CGAffineTransformIdentity;
//            self.navigationBar.alpha = 1;
//            self.screenshotTopImgV.transform = CGAffineTransformIdentity;
//            self.screenshotImgV.transform = CGAffineTransformIdentity;
////        }completion:^(BOOL finished) {
////        }];
//        [self.screenshotTopImgV removeFromSuperview];
//        
//    }else{
//        if ([XMRightBottomFloatView shareRightBottomFloatView].rightBottomCancelOrFailBlock) {
//            [XMRightBottomFloatView shareRightBottomFloatView].rightBottomCancelOrFailBlock();
//        }
//    }
//    
//}
//
////- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
////
////    if ([animationController isKindOfClass:[FloatingPopTransition class]]) {
////        return self.percentDrivenTransition;
////    }
////    else {
////        return nil;
////    }
////
////}
////
////- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
////    if (operation == UINavigationControllerOperationPop) {
////        return [FloatingPopTransition new];
////    }
////    else {
////        return nil;
////    }
////}
//
//#pragma mark - UIGestureRecognizerDelegate
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
////    NSLog(@"%@--%@",NSStringFromClass([gestureRecognizer class]),NSStringFromClass([otherGestureRecognizer class]));
////    if ([otherGestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]){
////        return NO;
////    }
////    if ([gestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]){
////        return YES;
////    }
//
//    return YES;
//}
//
////- (void)viewWillAppear:(BOOL)animated{
////    [super viewWillAppear:animated];
////    
////    // 重置状态栏的颜色
////    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
////    statusBar.backgroundColor = nil;
////}
//
////- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
////    [super pushViewController:viewController animated:animated];
////    
////}
////
////- (UIViewController *)popViewControllerAnimated:(BOOL)animated{
////    return [super popViewControllerAnimated:animated];
////    
////}
//
////- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
////    [super willsh];
////}
//
////- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
//
//

#pragma mark - 判断类方法
// 判断该控制器是否需要隐藏浮窗
- (BOOL)shoudHideFloatWindowInViewController:(UIViewController *)viewController{
    return [@"XMFileDisplayWebViewViewController|XMPhotoCollectionViewController|HJVideoPlayerController" containsString:NSStringFromClass([viewController class])];
}


#pragma mark - 保存照片到设备相册实现方法
/** 提示用户保存图片成功与否(系统必须实现的方法) */
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    NSString *msg = (error) ? @"保存到相册失败" : @"保存到相册成功";
    [MBProgressHUD showMessage:msg toView:nil];
}
@end
