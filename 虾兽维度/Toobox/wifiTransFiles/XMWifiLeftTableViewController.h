//
//  XMWifiLeftTableViewController.h
//  虾兽维度
//
//  Created by Niki on 2018/5/8.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XMWifiLeftTableViewControllerDelegate <NSObject>

@optional
- (void)leftWifiTableViewControllerDidSelectGroupName:(NSString *)groupName;
- (void)leftWifiTableViewControllerDidDeleteGroupName:(NSString *)groupName;

@end

@interface XMWifiLeftTableViewController : UITableViewController

@property (weak, nonatomic)  id<XMWifiLeftTableViewControllerDelegate> delegate;

@end
