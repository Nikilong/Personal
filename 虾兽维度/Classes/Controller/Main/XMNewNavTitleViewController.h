//
//  XMNewNavTitleViewController.h
//  虾兽维度
//
//  Created by Niki on 18/7/22.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XMNewNavTitleViewControllerDelegate <NSObject>

@optional
- (void)navTitleViewControllerDidSelectChannel:(NSUInteger)index;

@end

@interface XMNewNavTitleViewController : UIViewController

@property (weak, nonatomic)  id<XMNewNavTitleViewControllerDelegate> delegate;

@end




