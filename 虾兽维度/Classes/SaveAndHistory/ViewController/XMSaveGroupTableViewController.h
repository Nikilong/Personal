//
//  XMSaveGroupTableViewController.h
//  虾兽维度
//
//  Created by Niki on 2018/10/2.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XMSaveGroupTableViewControllerDelegate <NSObject>

@optional
- (void)saveGroupTableViewControllerDidMove;

@end

@interface XMSaveGroupTableViewController : UITableViewController

@property (nonatomic, copy) NSArray<NSIndexPath *> *seleIndexArr;      // 所选择的indexPath数组
@property (nonatomic, copy) NSString *fromGroName;                     // 从哪个组移动过来的


@property (weak, nonatomic)  id<XMSaveGroupTableViewControllerDelegate> delegate;

@end
