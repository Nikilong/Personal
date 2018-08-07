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

-(NSMutableArray *)groupNameArr{
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
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 5;
}

// xcode9和ios11需要实现这个才能设置footer高度
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] init];
}
// xcode9和ios11需要实现这个才能设置header高度
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return (section == 0) ? 20 : 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        return 100;
    }else if (indexPath.section == 1){
        return 44;
    }else{
        return 30;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 || section == 1){
        return 1;
    }else{
        return self.groupNameArr.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"wifiCell";
    UITableViewCell *cell;
    NSString *nonReuseID;
    if (indexPath.section == 2){
        
        cell = [tableView dequeueReusableCellWithIdentifier:nonReuseID];
        if (!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
            cell.textLabel.textColor = [UIColor grayColor];
            
            // 添加长按操作手势
            UILongPressGestureRecognizer *longPre = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(editCell:)];
            [cell addGestureRecognizer:longPre];

        }

        XMWifiTransModel *model = self.groupNameArr[indexPath.row];
        cell.textLabel.text = model.groupName;
        cell.textLabel.textColor = model.isBackup ? [UIColor orangeColor] : [UIColor grayColor];

    }else{
        if (indexPath.section == 0){
            nonReuseID = @"wifiSectionOneCell";
        }else if (indexPath.section == 1){
            nonReuseID = @"wifiSectionTwoCell";
        }
        
        cell = [tableView dequeueReusableCellWithIdentifier:nonReuseID];
        if (!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nonReuseID];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            if (indexPath.section == 0){
                [cell.contentView addSubview:[self setSectionOneCustomView]];
            }else if (indexPath.section == 1){
                [cell.contentView addSubview:[self setSectionTwoCustomView]];
            }
        }
    }
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 2){
        // 取消选中状态
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
        XMWifiTransModel *model = self.groupNameArr[indexPath.row];
        NSString *groupName = model.groupName;
        if ([self.delegate respondsToSelector:@selector(leftWifiTableViewControllerDidSelectGroupName:)]){
            [self.delegate leftWifiTableViewControllerDidSelectGroupName:groupName];
        }
    }
}

#pragma mark 第一组和第二组的按钮创建以及点击方法
/// 左侧栏第一组自定义按钮
- (UIView *)setSectionOneCustomView{
    UIView *contentV = [[UIView alloc] init];
    // 每一行排3个按钮
    NSUInteger colMax = 3;
    CGFloat btnWH = ( XMWifiLeftViewTotalW - (colMax + 3) * XMLeftViewPadding ) / colMax;
    // 创建分组
    UIButton *creatGroupBtn = [self addSystemButtonWithImageName:@"dir_add" selector:@selector(creatNewGroup) parentView:contentV];
    creatGroupBtn.frame = CGRectMake(XMLeftViewPadding, XMLeftViewPadding, btnWH, btnWH);
    // 刷新组列表
    UIButton *refreshGroupBtn = [self addSystemButtonWithImageName:@"dir_fresh" selector:@selector(refreshGroupData) parentView:contentV];
    refreshGroupBtn.frame = CGRectMake(CGRectGetMaxX(creatGroupBtn.frame) + XMLeftViewPadding, XMLeftViewPadding, btnWH, btnWH);
    // 备份配置文件
    UIButton *backFileBtn = [self addSystemButtonWithImageName:@"setting_backup" selector:@selector(backupConfigFiles) parentView:contentV];
    backFileBtn.frame = CGRectMake(CGRectGetMaxX(refreshGroupBtn.frame) + XMLeftViewPadding, XMLeftViewPadding, btnWH, btnWH);
    // 备份文件夹
    UIButton *backDirBtn = [self addSystemButtonWithImageName:@"dir_backup" selector:@selector(backupDirFiles) parentView:contentV];
    backDirBtn.frame = CGRectMake(XMLeftViewPadding, CGRectGetMaxY(backFileBtn.frame) + XMLeftViewPadding, btnWH, btnWH);
    // 最后根据按钮的个数和行数计算contentV的高度
    contentV.frame = CGRectMake(0, 0, XMWifiLeftViewTotalW, CGRectGetMaxY(backDirBtn.frame) + 3 * XMLeftViewPadding);
    return contentV;
}

/// 左侧栏第二组自定义按钮
- (UIView *)setSectionTwoCustomView{
    UIView *contentV = [[UIView alloc] init];
    // 每一行排3个按钮,加上2条分割线
    NSUInteger colMax = 3;
    CGFloat btnWH = ( XMWifiLeftViewTotalW - 2 * XMLeftViewPadding ) / colMax - 2;
    
    NSArray *groupNames = [XMWifiGroupTool nonDeleteGroupNames];
    for (NSUInteger i = 0; i< groupNames.count; i++) {
        UIButton *btn = [self addButtonWithTitle:groupNames[i] selector:@selector(sectionTwoBtnDidClick:) parentView:contentV];
        btn.tag = i;
        btn.frame = CGRectMake(i * btnWH + i, 0, btnWH, btnWH);
        // 添加分割线
        if(i < groupNames.count - 1){
            UIView *lineV = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(btn.frame), 0, 1, btnWH)];
            lineV.backgroundColor = [UIColor grayColor];
            [contentV addSubview:lineV];
        }
    }
    contentV.frame = CGRectMake(0, 0, XMWifiLeftViewTotalW, btnWH + 2 * XMLeftViewPadding);
    return contentV;
}

/// 第二组按钮点击事件
- (void)sectionTwoBtnDidClick:(UIButton *)btn{
    NSArray *groupNames = [XMWifiGroupTool nonDeleteGroupNames];
    NSString *groupName = groupNames[btn.tag];
    if ([self.delegate respondsToSelector:@selector(leftWifiTableViewControllerDidSelectGroupName:)]){
        [self.delegate leftWifiTableViewControllerDidSelectGroupName:groupName];
    }
    
}

/// 创建分组
- (void)creatNewGroup{
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
        textField.clearButtonMode = UITextFieldViewModeAlways;
        textField.placeholder = @"新文件夹名称";
    }];
    [tips addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.clearButtonMode = UITextFieldViewModeAlways;
        textField.placeholder = @"随便输入要备份,不输入不备份";
    }];
    [self presentViewController:tips animated:YES completion:nil];
}

/// 刷新数据
- (void)refreshGroupData{
    [XMWifiGroupTool updateGroupNameFile];
    [self refreshData];
}


/// 备份设置文件
- (void)backupConfigFiles{
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showLoadingViewInView:nil title:@"loading"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BOOL success = [XMWifiGroupTool zipConfigFiles];
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:YES];
                [MBProgressHUD showResult:success message:nil];
            });
        });
        
    });
}

/// 备份标记的文件夹
- (void)backupDirFiles{
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showLoadingViewInView:nil title:@"loading"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BOOL success = [XMWifiGroupTool zipBackUpDirs];
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:YES];
                [MBProgressHUD showResult:success message:nil];
            });
        });
        
    });
}

- (UIButton *)addButtonWithTitle:(NSString *)title selector:(SEL)selctror parentView:(UIView *)parentView{
    UIButton *btn = [[UIButton alloc] init];
    [parentView addSubview:btn];
    [btn addTarget:self action:selctror forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    return btn;
}

- (UIButton *)addSystemButtonWithImageName:(NSString *)imageName selector:(SEL)selctror parentView:(UIView *)parentView{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [parentView addSubview:btn];
    [btn addTarget:self action:selctror forControlEvents:UIControlEventTouchUpInside];
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    return btn;
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

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
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
        // 更新文件的model归档
        [XMWifiGroupTool saveGroupMessageWithNewArray:weakSelf.groupNameArr];
        // 更新保存标记的文件
        [XMWifiGroupTool updateZipMarkGroupName:model.groupName isMark:model.isBackup];
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
        textField.clearButtonMode = UITextFieldViewModeAlways;
        textField.text = model.groupName;
    }];
    [self presentViewController:tips animated:YES completion:nil];
}


@end
