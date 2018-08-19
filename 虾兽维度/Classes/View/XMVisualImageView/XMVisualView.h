//
//  XMVisualView.h
//  虾兽维度
//
//  Created by Niki on 18/8/19.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XMVisualViewDelegate <NSObject>

@optional

- (void)visualViewWillRemoveFromSuperView;

@end

@interface XMVisualView : UIView

@property (weak, nonatomic)  id<XMVisualViewDelegate> delegate;

+ (XMVisualView *)creatVisualImageViewWithImage:(id)image;
+ (XMVisualView *)creatVisualImageViewWithImage:(id)image imageSize:(CGSize)size blurEffectStyle:(UIBlurEffectStyle)blurStyle;

@end
