//
//  XMWXFloatWindowIconConfig.h
//  虾兽维度
//
//  Created by Niki on 18/7/18.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UIViewController,UIButton;

/// 偏好设置保存的类名,如果没有,则为""
extern NSString *const wxfloatVCKey;
extern NSString *const wxfloatFrameStringKey;

/**
 该文件是根据控制器的类名(class),来提供对应的icon或者标题,另外归档浮窗的数据,方便重启app的时候恢复浮窗
 */
@interface XMWXFloatWindowIconConfig : NSObject

+ (void)setIconAndTitleByViewController:(UIViewController *)vc button:(UIButton *)btn;

+ (void)removeBackupData;

+ (void)setBackupImageOrTitlt:(UIButton *)btn;

/// 偏好设置里面是否存有控制器
+ (BOOL)isSaveFloatVCInUserDefaults;

@end
