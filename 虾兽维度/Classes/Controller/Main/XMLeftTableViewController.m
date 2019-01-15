//
//  XMLeftTableViewController.m
//  虾兽维度
//
//  Created by Niki on 17/3/25.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "XMLeftTableViewController.h"
#import "XMChannelModel.h"
#import "XMChannelModelLogic.h"
#import "XMLeftViewUserCell.h"
#import "MBProgressHUD+NK.h"
#import "XMHealthTool.h"

@interface XMLeftTableViewController ()

// 特别频道
@property (nonatomic, strong) NSArray *specialChannelArr;
@property (weak, nonatomic)  UIButton *addNewChannelBtn;

@end

@implementation XMLeftTableViewController

-(NSArray *)specialChannelArr{
    if (!_specialChannelArr){
        _specialChannelArr = [XMChannelModelLogic specialChannels];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section == 1 ? self.specialChannelArr.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 0){
        
        XMLeftViewUserCell *cell = [XMLeftViewUserCell cellWithTableView:tableView];
        if(!self.addNewChannelBtn){
            self.addNewChannelBtn = cell.addLeftNewChannelBtn;
            [self.addNewChannelBtn addTarget:self action:@selector(addNewChannel) forControlEvents:UIControlEventTouchUpInside];
        }
        return cell;
    }else{
        static NSString *ID = @"mainLeftChannelCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
            // 修改选中状态的背景颜色
            cell.selectedBackgroundView = [[UIView alloc]  initWithFrame:cell.frame];
            cell.selectedBackgroundView.backgroundColor = [UIColor darkGrayColor];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
            cell.textLabel.textColor = [UIColor grayColor];
        }
    
        if (indexPath.section == 1){
            XMChannelModel *model = self.specialChannelArr[indexPath.row];
            cell.textLabel.text = model.channel;
        }
        
        return cell;
    }
}

/** 自定义行高 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.section == 0 ? 100 : 44;
}


#pragma mark 编辑操作
/// iOS8必须实现这个方法才能侧滑编辑
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 1){
        __weak typeof(self) weakSelf = self;
        UITableViewRowAction *delAct = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            BOOL result = [XMChannelModelLogic specialChannelRemoveChannelAtIndex:indexPath.row];
            [MBProgressHUD showResult:result message:nil];
            weakSelf.specialChannelArr = nil;
            [weakSelf.tableView reloadData];
        }];
        UITableViewRowAction *renameAct = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"编辑" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            UIAlertController *tips = [UIAlertController alertControllerWithTitle:@"提示" message:@"输入网址和名称" preferredStyle:UIAlertControllerStyleAlert];
            XMChannelModel *model = self.specialChannelArr[indexPath.row];
            [tips addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.text = model.channel;
                textField.placeholder = @"请输入名称";
            }];
            [tips addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.text = model.url;
                textField.placeholder = @"请输入url地址";
            }];
            [tips addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf.tableView setEditing:NO animated:YES];
            }]];
            [tips addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action){
                NSString *name = tips.textFields[0].text;
                NSString *url = tips.textFields[1].text;
                BOOL result = [XMChannelModelLogic specialChannelRenameChannelName:name url:url index:indexPath.row];
                [MBProgressHUD showResult:result message:nil];
                weakSelf.specialChannelArr = nil;
                [weakSelf.tableView reloadData];
            }]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:tips animated:YES completion:nil];
            });
        }];
        return @[delAct,renameAct];
    }
    return @[];
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1){
        return YES;
    }else{
        return NO;
    }
}


/// 添加一个新的频道
- (void)addNewChannel{
    UIAlertController *tips = [UIAlertController alertControllerWithTitle:@"提示" message:@"输入网址和名称" preferredStyle:UIAlertControllerStyleAlert];

    __weak typeof(self) weakSelf = self;
    [tips addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入名称";
    }];
    [tips addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入url地址";
    }];
    [tips addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [tips addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action){
        NSString *name = tips.textFields[0].text;
        NSString *url = tips.textFields[1].text;
        BOOL result = [XMChannelModelLogic specialChannelAddNewChannelName:name url:url];
        [MBProgressHUD showResult:result message:nil];
        weakSelf.specialChannelArr = nil;
        [weakSelf.tableView reloadData];
    }]];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:tips animated:YES completion:nil];
    });
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

#pragma mark - 父类的通知方法
- (void)leftTableViewControllerWillShow{
    
    // 更新步数
    [[XMHealthTool shareHealthTool] getStepCountWithCompleteBlock:^(NSString *stepCountStr){
        dispatch_async(dispatch_get_main_queue(), ^{
            XMLeftViewUserCell *userCell = (XMLeftViewUserCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            userCell.stepCountLab.text = stepCountStr;
        });
    }];
    
    [UIView animateWithDuration:0.5 animations:^{
        
    }];
    
}

- (void)leftTableViewControllerDidShow{
    
}

- (void)leftTableViewControllerWillHide{
    
}
- (void)leftTableViewControllerDidHide{
    
}
@end
