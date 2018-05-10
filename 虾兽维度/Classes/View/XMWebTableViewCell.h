//
//  XMWebTableViewCell.h
//  03 虾兽新闻客户端
//
//  Created by admin on 17/2/28.
//  Copyright © 2017年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XMWebModel, XMWifiTransModel;

@interface XMWebTableViewCell : UITableViewCell

@property (nonatomic, strong) XMWebModel *model;
@property (nonatomic, strong) XMWifiTransModel *wifiModel;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
