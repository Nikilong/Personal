//
//  XMWifiLeftTableViewController.m
//  虾兽维度
//
//  Created by Niki on 2018/5/8.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMWifiLeftTableViewController.h"
#import "XMWifiGroupTool.h"

@interface XMWifiLeftTableViewController ()

@property (nonatomic, strong) NSMutableArray *groupNameArr;

@end

@implementation XMWifiLeftTableViewController

-(NSMutableArray *)groupNameArr
{
    _groupNameArr = [NSMutableArray arrayWithArray:[XMWifiGroupTool groupNames]];
    return _groupNameArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0){
        return 2;
    }else if(section == 1){
        return [XMWifiGroupTool nonDeleteGroupNames].count;
    }else{
        return self.groupNameArr.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"wifiCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    if (indexPath.section == 0){
        cell.textLabel.text = (indexPath.row == 0) ? @"添加分组" : @"刷新列表";
    }else if (indexPath.section == 1){
        cell.textLabel.text = [XMWifiGroupTool nonDeleteGroupNames][indexPath.row];
    }else{
        cell.textLabel.text = self.groupNameArr[indexPath.row];
    }
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        if(indexPath.row == 0){  // 创建新文件夹
            
            __weak typeof(self) weakSelf = self;
            UIAlertController *tips = [UIAlertController alertControllerWithTitle:@"创建新文件夹(不能超过6个字)" message:@"输入新名称" preferredStyle:UIAlertControllerStyleAlert];
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
        
        
        }else if(indexPath.row == 1){  // 刷新列表
            [self.groupNameArr removeAllObjects];
            self.groupNameArr = [NSMutableArray arrayWithArray:[XMWifiGroupTool updateGroupNameFile]];
            [self.tableView reloadData];
        }
    }else{
        NSString *groupName = (indexPath.section == 1) ? [XMWifiGroupTool nonDeleteGroupNames][indexPath.row] : self.groupNameArr[indexPath.row];
        if ([self.delegate respondsToSelector:@selector(leftWifiTableViewControllerDidSelectGroupName:)]){
            [self.delegate leftWifiTableViewControllerDidSelectGroupName:groupName];
        }
    }
}

#pragma mark 编辑操作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 2){
    
        if (editingStyle == UITableViewCellEditingStyleDelete){
            // 提取文件夹信息
            NSString *groupName = self.groupNameArr[indexPath.row];
            
            __weak typeof(self) weakSelf = self;
            UIAlertController *tips = [UIAlertController alertControllerWithTitle:@"警告" message:@"点击\"确定\"之后将会将该文件夹目录下面的所有文件删除" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action){

                [XMWifiGroupTool deleteWifiFilesGroupWithName:groupName];
                [weakSelf.tableView reloadData];
                if ([weakSelf.delegate respondsToSelector:@selector(leftWifiTableViewControllerDidDeleteGroupName:)]){
                    [weakSelf.delegate leftWifiTableViewControllerDidDeleteGroupName:groupName];
                }
            }];
            
            [tips addAction:cancelAction];
            [tips addAction:okAction];
            
            [self presentViewController:tips animated:YES completion:nil];
            
        }
    
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 2){
        return YES;
    }else{
        return NO;
    }
}



@end
