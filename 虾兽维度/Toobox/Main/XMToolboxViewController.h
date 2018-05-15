//
//  XMToolboxViewController.h
//  虾兽维度
//
//  Created by Niki on 18/3/10.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMToolBoxConfig.h"

extern double const XMToolBoxViewAnimationTime;

typedef void(^touchIDCallbackBlock)(BOOL);
@protocol XMToolBoxViewControllerDelegate <NSObject>

- (void)toolboxButtonDidClick:(UIButton *)btn;

@end

@interface XMToolboxViewController : UIViewController

// 蒙板
@property (weak, nonatomic)  UIView *toolBoxViewCover;

@property (weak, nonatomic)  id<XMToolBoxViewControllerDelegate> delegate;

@property (nonatomic, copy) touchIDCallbackBlock callbackBlock;

@end
