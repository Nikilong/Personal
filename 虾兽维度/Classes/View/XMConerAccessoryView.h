//
//  XMConerAccessoryView.h
//  accessoryTool - test
//
//  Created by Niki on 17/3/30.
//  Copyright © 2017年 Niki. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XMConerAccessoryViewDelegate <NSObject>

@optional
- (void)conerAccessoryViewDidClickPlantedButton:(UIButton *)button;

@end

@interface XMConerAccessoryView : UIView

@property (weak, nonatomic)  id<XMConerAccessoryViewDelegate> delegate;

+ (instancetype)conerAccessoryViewWithButtonWH:(CGFloat)btnWH radius:(CGFloat)radius imageArray:(NSArray *)backgroundImages borderWidth:(CGFloat)borderW tintColor:(UIColor *)tintColor;

@end
