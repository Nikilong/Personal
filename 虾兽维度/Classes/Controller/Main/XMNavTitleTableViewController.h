//
//  XMNavTitleTableViewController.h
//  03 虾兽新闻客户端
//
//  Created by Niki on 17/3/25.
//  Copyright © 2017年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XMNavTitleTableViewControllerDelegate <NSObject>

@optional
- (void)navTitleTableViewControllerDidSelectChannel:(NSIndexPath *)indexPath;

@end

@interface XMNavTitleTableViewController : UITableViewController

@property (weak, nonatomic)  id<XMNavTitleTableViewControllerDelegate> delegate;

@end
