//
//  XMNavTitleTableViewController.m
//  虾兽维度
//
//  Created by Niki on 17/3/25.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "XMNavTitleTableViewController.h"
#import "XMChannelModel.h"
#import "XMTextTableViewCell.h"

@interface XMNavTitleTableViewController ()

// uc新闻频道
@property (nonatomic, strong) NSArray *channelArr;

@end

@implementation XMNavTitleTableViewController

- (NSArray *)channelArr{
    if (!_channelArr){
        _channelArr = [XMChannelModel channels];
    }
    return _channelArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 默认选中第一组第一行
    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:0 inSection:1];
    [self.tableView selectRowAtIndexPath:indexpath animated:YES scrollPosition:UITableViewScrollPositionNone];

}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.channelArr.count;
  
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    XMChannelModel *model = self.channelArr[indexPath.row];
    XMTextTableViewCell *cell = [XMTextTableViewCell textCellWithTableView:tableView];
    cell.textLabel.text = model.channel;
    return cell;
}

/** 自定义行高 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 35;
}

#pragma mark - 代理方法
/** 通知代理选中了某一个频道 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(navTitleTableViewControllerDidSelectChannel:)]){
        [self.delegate navTitleTableViewControllerDidSelectChannel:indexPath];
    }
}
@end
