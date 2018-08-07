//
//  XMLeftTableViewController.m
//  虾兽维度
//
//  Created by Niki on 17/3/25.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "XMLeftTableViewController.h"
#import "XMChannelModel.h"
#import "XMLeftViewUserCell.h"

@interface XMLeftTableViewController ()

// 特别频道
@property (nonatomic, strong) NSArray *specialChannelArr;

@end

@implementation XMLeftTableViewController

-(NSArray *)specialChannelArr{
    if (!_specialChannelArr){
        _specialChannelArr = [XMChannelModel specialChannels];
    }
    return _specialChannelArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}


#pragma mark - Table view data source
// xcode9和ios11需要实现这个才能设置footer高度
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] init];
}
// xcode9和ios11需要实现这个才能设置header高度
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return (section == 0) ? 20 : 10;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section == 1 ? self.specialChannelArr.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 0){
        
        XMLeftViewUserCell *cell = [XMLeftViewUserCell cellWithTableView:tableView];
        return cell;
    }else{
        
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        
        // 修改选中状态的背景颜色
        cell.selectedBackgroundView = [[UIView alloc]  initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = [UIColor darkGrayColor];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
        cell.textLabel.textColor = [UIColor grayColor];
        if (indexPath.section == 1){
            XMChannelModel *model = self.specialChannelArr[indexPath.row];
            cell.textLabel.text = model.channel;
        }else if (indexPath.section == 2){
            cell.textLabel.text = @"工具箱";
        }
        
        return cell;
    }
}

/** 自定义行高 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.section == 0 ? 100 : 44;
}

#pragma mark - 代理方法
/** 通知代理选中了某一个频道 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 取消选中状态
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(leftTableViewControllerDidSelectChannel:)]){
        [self.delegate leftTableViewControllerDidSelectChannel:indexPath];
    }
}
@end
