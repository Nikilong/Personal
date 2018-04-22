//
//  XMDropView.h
//  伪博
//
//  Created by Niki on 17/3/9.
//  Copyright © 2017年 Niki. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XMDropView;

@protocol XMDropViewDelegate <NSObject>

@optional
- (void)dropViewDidDismiss:(XMDropView *)dropView;
- (void)dropViewDidShow:(XMDropView *)dropView;

@end

@interface XMDropView : UIView

/** 可以传一个控制器进来*/
@property (nonatomic, strong) UIViewController *contentController;

/** 可以传一个view进来*/
@property (nonatomic, strong) UIView *content;


@property (weak, nonatomic)  id<XMDropViewDelegate> delegate;

+ (instancetype)dropView;
- (void)showFrom:(UIView *)view;
- (void)dismiss;

@end
