//
//  UIViewController+hook.m
//  虾兽维度
//
//  Created by Niki on 2018/8/2.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "UIViewController+hook.h"
#import "RSSwizzle.h"


@implementation UIViewController (hook)

//+(void)load{
//        //- (void)viewWillAppear:(BOOL)animated
//    SEL selector = NSSelectorFromString(@"viewWillAppear:");
//    [RSSwizzle swizzleInstanceMethod:selector inClass:[self class] newImpFactory:^id(RSSwizzleInfo *swizzleInfo) {
//        return ^(__unsafe_unretained id self, BOOL animate ){
//            
//            NSLog(@"!!!%s",__func__);
//            
//            void (*originalIMP)(__unsafe_unretained id, SEL, BOOL);
//            originalIMP = (__typeof(originalIMP))[swizzleInfo getOriginalImplementation];
//            originalIMP(self,selector,animate);
//            
//        };
//    } mode:RSSwizzleModeAlways key:NULL];
//    
//}

@end
