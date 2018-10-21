//
//  XMTabBar.h
//  虾兽维度
//
//  Created by Niki on 2018/10/18.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XMTabBarDelegate <NSObject>

@optional
- (void)tabBarMidButtonDidClick;

@end

@interface XMTabBar : UITabBar

@property (weak, nonatomic)  id<XMTabBarDelegate> delegate;

@end
