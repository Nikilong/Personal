//
//  XMWXVCFloatWindow.h
//  虾兽维度
//
//  Created by Niki on 2018/7/17.
//  Copyright © 2018年 admin. All rights reserved.
//

/**
 该文件的作用是提供一个圆形的浮窗,以保存viewcontroller
 */

#import <UIKit/UIKit.h>

typedef void(^xmWXVCFloatWindowWillRemove)();
typedef void(^xmWXVCFloatWindowDidRemove)();
typedef void(^xmWXVCFloatWindowCancelRemove)();
typedef void(^xmWXVCFloatWindowDidAdd)();

@interface XMWXVCFloatWindow : UIView

+ (XMWXVCFloatWindow *)shareXMWXVCFloatWindow;

@property (nonatomic, copy)xmWXVCFloatWindowWillRemove wxFloatWindowWillRemoveBlock;
@property (nonatomic, copy)xmWXVCFloatWindowDidRemove wxFloatWindowDidRemoveBlock;
@property (nonatomic, copy)xmWXVCFloatWindowCancelRemove wxFloatWindowCancelRemoveBlock;
@property (nonatomic, copy)xmWXVCFloatWindowDidAdd wxFloatWindowDidAddBlock;

@property (nonatomic, assign)  BOOL recordFlag;
@property (nonatomic, assign)  CGRect preFrame;

@end
