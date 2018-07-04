//
//  XMTouchIDKeyboardViewController.h
//  虾兽维度
//
//  Created by Niki on 18/3/11.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XMTouchIDKeyboardViewControllerDelegate <NSObject>

- (void)touchIDKeyboardViewControllerDidDismiss;

- (void)touchIDKeyboardViewAuthenSuccess;

- (void)touchIDKeyboardViewControllerAskForTouchID;

@end

@interface XMTouchIDKeyboardViewController : UIViewController

@property (weak, nonatomic)  id<XMTouchIDKeyboardViewControllerDelegate> delegate;
@property (nonatomic, assign)  BOOL showTouchIdBtn;


@end
