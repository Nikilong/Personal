//
//  XMWifiLeftTableViewController.m
//  虾兽维度
//
//  Created by Niki on 2018/5/8.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMWifiLeftTableViewController.h"
#import "XMWifiGroupTool.h"
#import "CommonHeader.h"

@interface XMWifiLeftTableViewController ()

@property (nonatomic, strong) NSMutableArray *groupNameArr;

@end

@implementation XMWifiLeftTableViewController

-(NSMutableArray *)groupNameArr
{
    _groupNameArr = [NSMutableArray arrayWithArray:[XMWifiGroupTool groupMessage]];
    return _groupNameArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? 1 :self.groupNameArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"wifiCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    cell.textLabel.text = (indexPath.section == 0) ? @"添加分组" : self.groupNameArr[indexPath.row];
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        __weak typeof(self) weakSelf = self;
        UIAlertController *tips = [UIAlertController alertControllerWithTitle:@"创建新文件夹" message:@"输入新名称" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action){
            // 当点击确定执行的块代码
            UITextField *textF = tips.textFields[0];
            [XMWifiGroupTool creatNewWifiFilesGroupWithName:textF.text];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [weakSelf.tableView reloadData];
            });
        }];
        
        [tips addAction:cancelAction];
        [tips addAction:okAction];
        [tips addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            
        }];
        [self presentViewController:tips animated:YES completion:nil];
    }else{
        if ([self.delegate respondsToSelector:@selector(leftWifiTableViewControllerDidSelectChannel:)]){
            [self.delegate leftWifiTableViewControllerDidSelectChannel:indexPath];
        }
    }
}


@end
