//
//  XMTextTableViewCell.m
//  虾兽维度
//
//  Created by Niki on 17/8/20.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "XMTextTableViewCell.h"

@implementation XMTextTableViewCell

+ (XMTextTableViewCell *)textCellWithTableView:(UITableView *)tableView{
    static NSString *ID = @"navTitleCell";
    XMTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell){
        cell = [[XMTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        
        // 修改选中状态的背景颜色
        cell.selectedBackgroundView = [[UIView alloc]  initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = [UIColor yellowColor];
        
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
