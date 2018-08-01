//
//  XMLeftViewUserCell.m
//  虾兽维度
//
//  Created by Niki on 17/3/25.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "XMLeftViewUserCell.h"

@interface XMLeftViewUserCell()

@property (weak, nonatomic) IBOutlet UILabel *versionLab;


@end


@implementation XMLeftViewUserCell

+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *ID = @"leftUserCell";
    XMLeftViewUserCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"XMLeftViewUserCell" owner:nil options:nil] lastObject];
        
        NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
        NSString *versionStr = infoDict[@"CFBundleVersion"];
        cell.versionLab.text = [NSString stringWithFormat:@"V%@",versionStr];
    }
    return cell;
}

@end
