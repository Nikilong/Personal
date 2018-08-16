//
//  AppDelegate.h
//  虾兽维度
//
//  Created by admin on 17/2/27.
//  Copyright © 2017年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>


@class XMWKWebViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

// 强引用浮窗
@property (nonatomic, strong) UIViewController *floadVC;

// 临时保存当前最顶部控制器
@property (nonatomic, strong) UIViewController *tempVC;

// 保存上一个webmodule,防止重复加载上一个webmodule
@property (nonatomic, strong) XMWKWebViewController *tempWebModuleVC;

@end

