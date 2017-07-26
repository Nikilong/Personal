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

@property (nonatomic, strong) NSArray *channelArr;

@end

@implementation XMLeftTableViewController

-(NSArray *)channelArr
{
    if (!_channelArr)
    {
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return (section == 1) ? self.channelArr.count : 1;
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
            static NSString *ID = @"leftCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
            if (!cell)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
                // 修改选中状态的背景颜色
                cell.selectedBackgroundView = [[UIView alloc]  initWithFrame:cell.frame];
                cell.selectedBackgroundView.backgroundColor = [UIColor yellowColor];
            }
            XMChannelModel *model = self.channelArr[indexPath.row];
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
    return indexPath.section == 0 ? 120 : 44;
}

#pragma mark - 代理方法
/** 通知代理选中了某一个频道 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        if ([self.delegate respondsToSelector:@selector(leftTableViewControllerDidSelectChannel:)])
        {
            [_delegate leftTableViewControllerDidSelectChannel:indexPath];
        }
    }
}
@end
