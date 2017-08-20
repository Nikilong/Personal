//
//  XMLeftTableViewController.m
//  03 虾兽新闻客户端
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

-(NSArray *)specialChannelArr
{
    if (!_specialChannelArr)
    {
        _specialChannelArr = [XMChannelModel specialChannels];
    }
    return _specialChannelArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 默认选中第一组第一行
    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:0 inSection:1];
    [self.tableView selectRowAtIndexPath:indexpath animated:YES scrollPosition:UITableViewScrollPositionNone];

}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 1 ? self.specialChannelArr.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 0:
        {
            XMLeftViewUserCell *cell = [XMLeftViewUserCell cellWithTableView:tableView];
            return cell;
            break;
        }
        case 1:
        {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
            
            // 修改选中状态的背景颜色
            cell.selectedBackgroundView = [[UIView alloc]  initWithFrame:cell.frame];
            cell.selectedBackgroundView.backgroundColor = [UIColor yellowColor];
            
            XMChannelModel *model = self.specialChannelArr[indexPath.row];
            cell.textLabel.text = model.channel;
            
            return cell;
            break;
        }
        default:
            return nil;
            break;
    }
}

/** 自定义行高 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == 0 ? 100 : 44;
}

#pragma mark - 代理方法
/** 通知代理选中了某一个频道 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != 0)
    {
        if ([self.delegate respondsToSelector:@selector(leftTableViewControllerDidSelectChannel:)])
        {
            [self.delegate leftTableViewControllerDidSelectChannel:indexPath];
        }
    }
}
@end
