//
//  XMWXFloatWindowIconConfig.h
//  虾兽维度
//
//  Created by Niki on 18/7/18.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UIViewController,UIButton;

/**
 该文件是根据控制器的类名(class),来提供对应的icon
 */
@interface XMWXFloatWindowIconConfig : NSObject

+ (void)setIconAndTitleByViewController:(UIViewController *)vc button:(UIButton *)btn;


@end
