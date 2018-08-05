//
//  UIScreenEdgePanGestureRecognizer+UIScreenEdgePanGestureRecognizer_hook.m
//  虾兽维度
//
//  Created by Niki on 2018/8/2.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "UIScreenEdgePanGestureRecognizer+UIScreenEdgePanGestureRecognizer_hook.h"
#import "RSSwizzle.h"

@implementation UIScreenEdgePanGestureRecognizer (UIScreenEdgePanGestureRecognizer_hook)

//+(void)load{
//    
//    SEL selector = NSSelectorFromString(@"handleNavigationTransition:");
//    [RSSwizzle swizzleInstanceMethod:selector inClass:NSClassFromString(@"NavigationInteractiveTransition") newImpFactory:^id(RSSwizzleInfo *swizzleInfo) {
//        return ^(__unsafe_unretained id self, UIScreenEdgePanGestureRecognizer*gesture ){
//            
//            NSLog(@"!!!%s",__func__);
//            
//            void (*originalIMP)(__unsafe_unretained id, SEL, UIScreenEdgePanGestureRecognizer *);
//            originalIMP = (__typeof(originalIMP))[swizzleInfo getOriginalImplementation];
//            originalIMP(self,selector,gesture);
//            
//        };
//    } mode:RSSwizzleModeAlways key:NULL];
//    
////        SEL selector = NSSelectorFromString(@"setEdges:");
////        [RSSwizzle swizzleInstanceMethod:selector inClass:[self class] newImpFactory:^id(RSSwizzleInfo *swizzleInfo) {
////            return ^(__unsafe_unretained id self, UIRectEdge edge ){
////
////                NSLog(@"!!!%s",__func__);
////
////                void (*originalIMP)(__unsafe_unretained id, SEL, UIRectEdge);
////                originalIMP = (__typeof(originalIMP))[swizzleInfo getOriginalImplementation];
////                originalIMP(self,selector,edge);
////
////            };
////        } mode:RSSwizzleModeAlways key:NULL];
//    
//}


@end
