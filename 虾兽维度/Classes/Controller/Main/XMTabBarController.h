//
//  XMTabBarController.h
//  虾兽维度
//
//  Created by Niki on 2018/10/17.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XMTabBarController : UITabBarController

/** 公开让3Dtouch快速打开 */
- (void)callSearch;
- (void)callScanQRCode;
- (void)callToolbox;
- (void)callSave;

@end
