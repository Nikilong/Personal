//
//  XMLeftViewUserCell.h
//  虾兽维度
//
//  Created by Niki on 17/3/25.
//  Copyright © 2017年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const XMSwitchFloatButtonNotification;

@class XMLeftViewUserCell;

@interface XMLeftViewUserCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property (weak, nonatomic) IBOutlet UIButton *addLeftNewChannelBtn;

@end
