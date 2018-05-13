//
//  XMFloatWindow.h
//  虾兽维度
//
//  Created by Niki on 17/3/27.
//  Copyright © 2017年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XMFloatWindow;

@protocol XMFloatWindowDelegate <NSObject>

@optional
- (void)floatWindowDidClickRefreshButton:(XMFloatWindow *)floatWindow;
- (void)floatWindowDidClickUpToTopButton:(XMFloatWindow *)floatWindow;
- (void)floatWindowDidClickDownToBottomButton:(XMFloatWindow *)floatWindow;

@end

@interface XMFloatWindow : UIWindow

@property (nonatomic, assign)  BOOL isShowRefreshButton;


@property (weak, nonatomic)  id<XMFloatWindowDelegate> delegate;

+ (instancetype)floatWindow;

@end
