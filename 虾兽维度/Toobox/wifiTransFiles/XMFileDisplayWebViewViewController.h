//
//  XMFileDisplayWebViewViewController.h
//  虾兽维度
//
//  Created by Niki on 18/5/6.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XMWifiTransModel;

@interface XMFileDisplayWebViewViewController : UIViewController

- (void)loadLocalFileWithPath:(NSString *)fullPath;

@property (nonatomic, strong) XMWifiTransModel *wifiModel;

@end
