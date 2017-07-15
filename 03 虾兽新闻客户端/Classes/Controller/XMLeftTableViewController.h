//
//  XMLeftTableViewController.h
//  03 虾兽新闻客户端
//
//  Created by Niki on 17/3/25.
//  Copyright © 2017年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#define XMLeftViewTotalW 200
#define XMLeftViewPadding 10

@protocol XMLeftTableViewControllerDelegate <NSObject>

@optional
- (void)leftTableViewControllerDidSelectChannel:(NSIndexPath *)indexPath;

@end

@interface XMLeftTableViewController : UITableViewController

@property (weak, nonatomic)  id<XMLeftTableViewControllerDelegate> delegate;

@end
