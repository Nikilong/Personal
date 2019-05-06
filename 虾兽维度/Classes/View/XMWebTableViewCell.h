//
//  XMWebTableViewCell.h
//  虾兽维度
//
//  Created by admin on 17/2/28.
//  Copyright © 2017年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMDarkNightCell.h"

@class XMWebModel, XMWifiTransModel;

@interface XMWebTableViewCell : XMDarkNightCell

@property (nonatomic, strong) XMWebModel *model;
@property (nonatomic, strong) XMWifiTransModel *wifiModel;
@property (weak, nonatomic) IBOutlet UIImageView *imageV;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
