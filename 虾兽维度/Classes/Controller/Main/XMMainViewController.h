//
//  XMMainViewController.h
//  虾兽维度
//
//  Created by Niki on 17/3/25.
//  Copyright © 2017年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMOpenWebmoduleProtocol.h"

@interface XMMainViewController : UIViewController <XMOpenWebmoduleProtocol>

/// 搜索框
- (void)callSearchView;
- (void)scanQRCode;

@end
