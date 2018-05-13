//
//  XMLeftTableViewController.h
//  虾兽维度
//
//  Created by Niki on 17/3/25.
//  Copyright © 2017年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XMLeftTableViewControllerDelegate <NSObject>

@optional
- (void)leftTableViewControllerDidSelectChannel:(NSIndexPath *)indexPath;

@end

@interface XMLeftTableViewController : UITableViewController

@property (weak, nonatomic)  id<XMLeftTableViewControllerDelegate> delegate;

@end
