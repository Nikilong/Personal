//
//  XMWifiLeftTableViewController.m
//  虾兽维度
//
//  Created by Niki on 2018/5/8.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMWifiLeftTableViewController.h"
#import "XMWifiGroupTool.h"
#import "XMWifiTransModel.h"
#import "MBProgressHUD+NK.h"

@interface XMWifiLeftTableViewController ()

@property (nonatomic, strong) NSMutableArray *groupNameArr;

@end

@implementation XMWifiLeftTableViewController

-(NSMutableArray *)groupNameArr
{
    if (!_groupNameArr){
        
        _groupNameArr = [NSMutableArray arrayWithArray:[XMWifiGroupTool groupNameDirsModels]];
    }
    return _groupNameArr;
}
- (void)refreshData{
     self.groupNameArr = [NSMutableArray arrayWithArray:[XMWifiGroupTool groupNameDirsModels]];
    [self.tableView reloadData];
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
        cell.textLabel.text = (indexPath.row == 0) ? @"添加分组" : @"备份文件";
    }else if (indexPath.section == 1){
        cell.textLabel.text = [XMWifiGroupTool nonDeleteGroupNames][indexPath.row];
    }else{
        XMWifiTransModel *model = self.groupNameArr[indexPath.row];
        cell.textLabel.text = model.groupName;
        cell.textLabel.textColor = model.isBackup ? [UIColor orangeColor] : [UIColor blackColor];
        // 添加长按操作手势
        UILongPressGestureRecognizer *longPre = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(editCell:)];
        [cell addGestureRecognizer:longPre];
    }
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 取消选中状态
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0){
        if(indexPath.row == 0){  // 创建新文件夹
            
            __weak typeof(self) weakSelf = self;
            UIAlertController *tips = [UIAlertController alertControllerWithTitle:@"创建新文件夹(不能超过6个字)" message:@"输入新名称" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action){
                // 当点击确定执行的块代码
                UITextField *textF = tips.textFields[0];
                UITextField *backF = tips.textFields[1];
                BOOL isBackup = (backF.text.length > 0 ) ? YES : NO;
                [XMWifiGroupTool creatNewWifiFilesGroupWithName:textF.text isBackup:isBackup];
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [weakSelf refreshData];
                });
            }];
            
            [tips addAction:cancelAction];
            [tips addAction:okAction];
            [tips addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = @"新文件夹名称";
            }];
            [tips addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = @"随便输入要备份,不输入不备份";
            }];
            [self presentViewController:tips animated:YES completion:nil];
        
        
        }else if(indexPath.row == 1){  // 刷新列表
            dispatch_async(dispatch_get_main_queue(), ^{
                MBProgressHUD *hud = [MBProgressHUD showLoadingViewInView:nil title:@"loading"];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    BOOL success = [XMWifiGroupTool zipBackUpDirs];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [hud hideAnimated:YES];
                        if (success){
                            [MBProgressHUD showSuccess];
                        }else{
                            [MBProgressHUD showMessage:@"失败" toView:nil];
                        }
                    });
                });
                
            });
            return;
            [self.groupNameArr removeAllObjects];
            self.groupNameArr = [NSMutableArray arrayWithArray:[XMWifiGroupTool updateGroupNameFile]];
            [self.tableView reloadData];
        }
    }else{

        NSString *groupName;
        if (indexPath.section == 1){
            groupName = [XMWifiGroupTool nonDeleteGroupNames][indexPath.row];
        }else if (indexPath.section == 2){
            XMWifiTransModel *model = self.groupNameArr[indexPath.row];
            groupName = model.groupName;
        }
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
            XMWifiTransModel *model = self.groupNameArr[indexPath.row];
            [self deleteGroupDir:model.groupName];
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

#pragma mark 长按cell操作
- (void)editCell:(UILongPressGestureRecognizer *)gest{
    if (gest.state != UIGestureRecognizerStateBegan) return;
    CGPoint point = [gest locationInView:self.tableView];
    NSIndexPath *index = [self.tableView indexPathForRowAtPoint:point];
    XMWifiTransModel *model =  self.groupNameArr[index.row];
    
    __weak typeof(self) weakSelf = self;
    UIAlertController *tips = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *deleAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action){
        [weakSelf deleteGroupDir:model.groupName];
    }];
    UIAlertAction *renameAction = [UIAlertAction actionWithTitle:@"重命名" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        [weakSelf renameGroupDir:model index:index.row];
    }];
    UIAlertAction *backupAction = [UIAlertAction actionWithTitle:( model.isBackup ? @"取消备份" : @"标记备份") style: UIAlertActionStyleDefault  handler:^(UIAlertAction * _Nonnull action){
        model.isBackup = !model.isBackup;
        [XMWifiGroupTool saveGroupMessageWithNewArray:weakSelf.groupNameArr];
        [weakSelf refreshData];
    }];
    
    [tips addAction:cancelAction];
    [tips addAction:deleAction];
    [tips addAction:renameAction];
    [tips addAction:backupAction];
    
    [self presentViewController:tips animated:YES completion:nil];
}

/// 删除
- (void)deleteGroupDir:(NSString *)groupName{
    __weak typeof(self) weakSelf = self;
    UIAlertController *tips = [UIAlertController alertControllerWithTitle:@"警告" message:@"点击\"确定\"之后将会将该文件夹目录下面的所有文件删除" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action){
        
        [XMWifiGroupTool deleteWifiFilesGroupWithName:groupName];
        [weakSelf refreshData];
        if ([weakSelf.delegate respondsToSelector:@selector(leftWifiTableViewControllerDidDeleteGroupName:)]){
            [weakSelf.delegate leftWifiTableViewControllerDidDeleteGroupName:groupName];
        }
    }];
    
    [tips addAction:cancelAction];
    [tips addAction:okAction];
    
    [self presentViewController:tips animated:YES completion:nil];
}

/// 重命名
- (void)renameGroupDir:(XMWifiTransModel *)model index:(NSUInteger)index{
    UIAlertController *tips = [UIAlertController alertControllerWithTitle:@"重命名" message:@"输入新的名称" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    __weak typeof(self) weakSelf = self;
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action){
        
        // 获得输入内容
        UITextField *textF = tips.textFields[0];
        
        NSString *oldFullPath = [[XMSavePathUnit getWifiUploadDirPath] stringByAppendingPathComponent:model.groupName];
        NSString *newFullPath = [[XMSavePathUnit getWifiUploadDirPath] stringByAppendingPathComponent:textF.text];
        // 重命名,自己覆盖自己
        NSError *error;
        if ([[NSFileManager defaultManager] moveItemAtPath:oldFullPath toPath:newFullPath error:&error]){
            // 替换groupNameArr数组,并且保存到本地归档,再通知父控制器刷新数据
            XMWifiTransModel *newModel = [[XMWifiTransModel alloc] init];
            newModel.groupName = textF.text;
            newModel.isBackup = model.isBackup;
            [weakSelf.groupNameArr replaceObjectAtIndex:index withObject:newModel];
            [XMWifiGroupTool saveGroupMessageWithNewArray:weakSelf.groupNameArr];
            [weakSelf refreshData];
            if ([weakSelf.delegate respondsToSelector:@selector(leftWifiTableViewControllerDidSelectGroupName:)]){
                [weakSelf.delegate leftWifiTableViewControllerDidSelectGroupName:newModel.groupName];
            }
        }else{
            [MBProgressHUD showMessage:@"名称已存在" toView:[UIApplication sharedApplication].keyWindow];
        }
        
    }];
    
    [tips addAction:cancelAction];
    [tips addAction:okAction];
    [tips addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = model.groupName;
    }];
    [self presentViewController:tips animated:YES completion:nil];
}


@end
