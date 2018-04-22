//
//  XMLeftViewUserCell.m
//  03 虾兽新闻客户端
//
//  Created by Niki on 17/3/25.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "XMLeftViewUserCell.h"


@implementation XMLeftViewUserCell

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"leftUserCell";
    XMLeftViewUserCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"XMLeftViewUserCell" owner:nil options:nil] lastObject];
    }
    return cell;
}

@end
