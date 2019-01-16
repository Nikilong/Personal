//
//  XMSaveWebsTableViewController.m
//  虾兽维度
//
//  Created by Niki on 17/3/25.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "XMSaveWebsTableViewController.h"
#import "XMSaveWebModelLogic.h"
#import "XMSaveGroupTableViewController.h"
#import "XMWKWebViewController.h"
#import "MBProgressHUD+NK.h"
#import "XMBaseNavViewController.h"

typedef NS_ENUM(NSUInteger,XMSaveVCDataSource){
    XMSaveVCDataSourceSave,         // 收藏网页
    XMSaveVCDataSourceHistory,      // 历史浏览数据
};

@interface XMSaveWebsTableViewController ()<
XMSaveGroupTableViewControllerDelegate
>

@property (nonatomic, strong) NSArray *saveWebsArr;         // 收藏数组
@property (nonatomic, strong) NSArray *historyWebsArr;      // 历史数组
@property (nonatomic, assign)  XMSaveVCDataSource sourceType;

@property (weak, nonatomic)  UIButton *rightBarBtn;        // 新建分组/清除历史浏览记录按钮

@property (weak, nonatomic)  UIView *toolBar;
@property (weak, nonatomic)  UIView *editV;
@property (weak, nonatomic)  UIButton *toolBarDeleBtn;       // 工具条删除按钮
@property (weak, nonatomic)  UIButton *toolBarMoveBtn;       // 工具条移动按钮
@property (weak, nonatomic)  UIButton *toolBarSeleAllBtn;    // 工具条全选按钮
@property (weak, nonatomic)  UIButton *toolBarNewGroBtn;     // 工具条添加分组按钮
@property (nonatomic, assign)  BOOL isEditMode;


@end

@implementation XMSaveWebsTableViewController

- (NSArray *)saveWebsArr{
    if (!_saveWebsArr){
        if(self.passArr){
            _saveWebsArr = [self.passArr copy];
            self.passArr = nil;
        }else{
            _saveWebsArr = [[XMSaveWebModelLogic webModelsWithGroupName:self.groupName] copy];
        }
    }
    return _saveWebsArr;
}

- (NSArray *)historyWebsArr{
    if (!_historyWebsArr){
        _historyWebsArr = [XMSaveWebModelLogic getHistoryModelArray];
    }
    return _historyWebsArr;
}


- (UIView *)toolBar{
    if (!_toolBar){
        CGFloat toolH = 44;
        CGFloat margin = 10;
        CGFloat btnWH = 30;
        CGFloat btnY = (toolH - btnWH) * 0.5;
        UIView *toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, XMScreenH - toolH + (isIphoneX ? -24 : 0), XMScreenW, toolH + (isIphoneX ? 24 : 0))];
        toolBar.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0f];
        _toolBar = toolBar;
        [self.view.superview addSubview:toolBar];
        
        /***********编辑组*********/
        UIView *editV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, XMScreenW, toolH)];
        [toolBar addSubview:editV];
        self.editV = editV;
        editV.backgroundColor = [UIColor clearColor];
        editV.hidden = YES;
        
        // 全选/反选
        UIButton *allSelectBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        allSelectBtn.frame = CGRectMake(XMScreenW - toolH * 2 - margin, 0, toolH * 2, toolH);
        self.toolBarSeleAllBtn = allSelectBtn;
        [editV addSubview:allSelectBtn];
        [allSelectBtn addTarget:self action:@selector(selectAllCell:) forControlEvents:UIControlEventTouchUpInside];
        [allSelectBtn setTitle:@"全选所有" forState:UIControlStateNormal];
        [allSelectBtn setTitle:@"取消全选" forState:UIControlStateSelected];
        
        // 退出编辑
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        cancelBtn.frame = CGRectMake(CGRectGetMinX(allSelectBtn.frame) - margin - toolH, 0, toolH, toolH);
        [editV addSubview:cancelBtn];
        [cancelBtn addTarget:self action:@selector(cancelEdit) forControlEvents:UIControlEventTouchUpInside];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        
        // 删除按钮
        UIButton *deleBtn = [[UIButton alloc] initWithFrame:CGRectMake(margin, btnY, btnWH, btnWH)];
        self.toolBarDeleBtn = deleBtn;
        [editV addSubview:deleBtn];
        [deleBtn addTarget:self action:@selector(deleteSelectCell:) forControlEvents:UIControlEventTouchUpInside];
        [deleBtn setImage:[UIImage imageNamed:@"file_delete_disable"] forState:UIControlStateDisabled];
        [deleBtn setImage:[UIImage imageNamed:@"file_delete_able"] forState:UIControlStateNormal];
        deleBtn.enabled = NO;
        
        // 移动按钮
        UIButton *moveBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(deleBtn.frame) + 40, btnY, btnWH, btnWH)];
        self.toolBarMoveBtn = moveBtn;
        [editV addSubview:moveBtn];
        [moveBtn addTarget:self action:@selector(moveSelectCell:) forControlEvents:UIControlEventTouchUpInside];
        [moveBtn setImage:[UIImage imageNamed:@"file_move_disable"] forState:UIControlStateDisabled];
        [moveBtn setImage:[UIImage imageNamed:@"file_move_able"] forState:UIControlStateNormal];
        moveBtn.enabled = NO;
        
        /***********编辑组*********/
        // 新建分组
        UIButton *newGroup = [UIButton buttonWithType:UIButtonTypeSystem];
        self.toolBarNewGroBtn = newGroup;
        newGroup.frame = CGRectMake(XMScreenW - toolH * 2 - margin, 0, toolH * 2, toolH);
        [toolBar addSubview:newGroup];
        [newGroup addTarget:self action:@selector(addNewSaveGroup) forControlEvents:UIControlEventTouchUpInside];
        [newGroup setTitle:@"新建分组" forState:UIControlStateNormal];
    }
    return _toolBar;
}

- (instancetype)init{
    if(self = [super init]){
        self.sourceType = XMSaveVCDataSourceSave;
        self.isEditMode = NO;
        self.groupName = XMSavewebsDefaultGroupName;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 设置导航栏
    [self setNavView];
    
    // 设置刷新控件
    [self setRefreshKit];
    
    self.tableView.separatorInset = UIEdgeInsetsMake(0, -100, 0, 0);
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // 防止在收藏界面打开了webmodule,然后取消收藏,造成列表显示不正确
    if(self.sourceType == XMSaveVCDataSourceSave){
        NSArray *arr = [XMSaveWebModelLogic webModelsWithGroupName:self.groupName];
        if(arr.count != self.saveWebsArr.count){
            self.saveWebsArr = nil;
            [self.tableView reloadData];
        }
    }else{
        NSArray *arr = [XMSaveWebModelLogic getHistoryModelArray];
        if(arr.count != self.historyWebsArr.count){
            self.historyWebsArr = nil;
            [self.tableView reloadData];
        }
    }
    // 防止底部bar遮挡cell
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    // 设置底部tabar
    self.toolBar.hidden = (self.sourceType == XMSaveVCDataSourceHistory);
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.toolBar removeFromSuperview];
    [self cancelEdit];
}

#pragma mark - 刷新控件以及刷新方法
// 创建刷新控件
- (void)setRefreshKit{
    // 创建控件,添加触发方法
    UIRefreshControl *fre = [[UIRefreshControl alloc] init];
    [fre addTarget:self action:@selector(pullTorefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:fre];
    
    // 手动设置加载动画,实际上并没有加载任何方法
    [fre beginRefreshing];
    
    // 必须手动触发刷新
    [self pullTorefresh:fre];

}

// 刷新方法
- (void)pullTorefresh:(UIRefreshControl *)fre{
    // 结束刷新动画
    [fre endRefreshing];
    
    if(self.sourceType == XMSaveVCDataSourceSave){
        self.saveWebsArr = nil;
    }else if(self.sourceType == XMSaveVCDataSourceHistory){
        self.historyWebsArr = nil;
    }
    
    [self.tableView reloadData];
}

#pragma mark - 创建导航栏及导航栏按钮点击事件
// 设置导航栏
- (void)setNavView{
    UISegmentedControl *seg = [[UISegmentedControl alloc] initWithItems:@[@"收藏",@"历史"]];
    seg.frame = CGRectMake(0, 0, 150, 30);
    seg.selectedSegmentIndex = 0;
    [seg addTarget:self action:@selector(segmentedButtonDidClick:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = seg;
    
    UIButton *leftBarBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    [leftBarBtn setTitle:@"返回" forState:UIControlStateNormal];
    [leftBarBtn setTitleColor:RGB(42, 122, 252) forState:UIControlStateNormal];
    [leftBarBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarBtn];
    
    UIButton *rightBarBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    [rightBarBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [rightBarBtn setTitleColor:RGB(42, 122, 252) forState:UIControlStateNormal];
    [rightBarBtn addTarget:self action:@selector(rightBarbuttonDidClick) forControlEvents:UIControlEventTouchUpInside];
    self.rightBarBtn = rightBarBtn;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarBtn];
}

/// 导航栏切换按钮点击事件
- (void)segmentedButtonDidClick:(UISegmentedControl *)sender{
    [self cancelEdit];
    if(sender.selectedSegmentIndex == 0){           // 收藏
        self.sourceType = XMSaveVCDataSourceSave;
        self.saveWebsArr = nil;
        self.toolBar.hidden = NO;
        [self.rightBarBtn setTitle:@"编辑" forState:UIControlStateNormal];
    }else if(sender.selectedSegmentIndex == 1){     // 历史
        self.sourceType = XMSaveVCDataSourceHistory;
        self.historyWebsArr = nil;
        self.toolBar.hidden = YES;
        [self.rightBarBtn setTitle:@"清除" forState:UIControlStateNormal];
    }
    [self.tableView reloadData];
}

/// 退出按钮
- (void)dismiss{
    if(self.navigationController){
        [self.navigationController popViewControllerAnimated:YES];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

/// 编辑/清理浏览记录
- (void)rightBarbuttonDidClick{
    if(self.sourceType == XMSaveVCDataSourceSave){ // 编辑
        if(self.tableView.isEditing){
            [self cancelEdit];
        }else{
            [self beginEdit];
        }
        
    }else if(self.sourceType == XMSaveVCDataSourceHistory){ // 清除记录
        UIAlertController *tips = [UIAlertController alertControllerWithTitle:@"提示" message:@"最多保存100条历史记录" preferredStyle:UIAlertControllerStyleActionSheet];
        __weak typeof(self) weakSelf = self;
        [tips addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [tips addAction:[UIAlertAction actionWithTitle:@"清除最近10条记录" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action){
            [weakSelf deleteRecentHistoryRecordWithNumber:10];
        }]];
        [tips addAction:[UIAlertAction actionWithTitle:@"清除最近50条记录" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action){
            [weakSelf deleteRecentHistoryRecordWithNumber:50];
        }]];
        [tips addAction:[UIAlertAction actionWithTitle:@"清除所有记录" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action){
            [weakSelf deleteRecentHistoryRecordWithNumber:1000];
        }]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:tips animated:YES completion:nil];
        });
    }
}

/// 批量删除历史记录
- (void)deleteRecentHistoryRecordWithNumber:(NSUInteger)number{
    self.historyWebsArr = nil;
    [XMSaveWebModelLogic deleteWebModelHistoryWithNumber:number];
    [self.tableView reloadData];
}

#pragma mark - 底部bar及点击事件
/// 新建分组
- (void)addNewSaveGroup{
    UIAlertController *tips = [UIAlertController alertControllerWithTitle:nil message:@"输入新建的分组名称" preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    [tips addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"组名";
    }];
    [tips addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [tips addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        NSString *name = tips.textFields[0].text;
        [XMSaveWebModelLogic addSaveGroupWithName:name];
        weakSelf.saveWebsArr = nil;
        [weakSelf.tableView reloadData];
    }]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:tips animated:YES completion:nil];
    });
}

/// 全选/取消全选所有cell
- (void)selectAllCell:(UIButton *)btn{
    btn.selected = !btn.selected;
    if (btn.selected){
        // 全选状态
        if (self.saveWebsArr.count == 0) return;
        for (NSInteger i = 0; i < self.saveWebsArr.count; i++) {
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
        }
        self.toolBarDeleBtn.enabled = YES;
        self.toolBarMoveBtn.enabled = YES;
    }else{
        // 取消全选状态
        NSArray *seleArr = [self.tableView indexPathsForSelectedRows];
        for (NSIndexPath *indexPath in seleArr){
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        self.toolBarDeleBtn.enabled = NO;
        self.toolBarMoveBtn.enabled = NO;
    }
}

/// 移动所选的cell
- (void)moveSelectCell:(UIButton *)btn{
    NSArray *groArr = [XMSaveWebModelLogic webModelsGroups];
    if(groArr.count <= 0){
        [MBProgressHUD showResult:NO message:@"当前没有创建分组"];
        return;
    }
    NSArray *seleArr = [self.tableView indexPathsForSelectedRows];
    
    // 另外嵌入一个nav,然后present出来
    XMSaveGroupTableViewController *groVC = [[XMSaveGroupTableViewController alloc] init];
    groVC.fromGroName = self.groupName;
    groVC.seleIndexArr = [seleArr copy];
    groVC.delegate = self;
    XMBaseNavViewController *nav = [[XMBaseNavViewController alloc] initWithRootViewController:groVC];
    [self presentViewController:nav animated:YES completion:nil];
}


/// 删除所选的cell
- (void)deleteSelectCell:(UIButton *)btn{
    btn.enabled = NO;
    self.toolBar.userInteractionEnabled = NO;
    NSArray *seleArr = [self.tableView indexPathsForSelectedRows];
    // 先对数组进行降序处理,将indexPath.row最大(即最底下的数据先删除),防止序号紊乱
    NSArray *sortArr = [self sortArray:seleArr];
    if (seleArr.count > 0){
        for (NSIndexPath *indexPath in sortArr){
            XMSaveWebModel *model = self.saveWebsArr[indexPath.row];
            [XMSaveWebModelLogic deleteWebURL:model.url];
        }
        self.saveWebsArr = nil;
        [self.tableView reloadData];
    }
    self.toolBar.userInteractionEnabled = YES;
}

/// 退出编辑模式
- (void)cancelEdit{
    [self.rightBarBtn setTitle:@"编辑" forState:UIControlStateNormal];
    self.isEditMode = NO;
    self.editV.hidden = YES;
    self.toolBarNewGroBtn.hidden = NO;
    self.toolBarSeleAllBtn.selected = NO;
    self.toolBarDeleBtn.enabled = NO;
    self.toolBarMoveBtn.enabled = NO;
    [self.tableView setEditing:NO animated:YES];
    if(self.sourceType == XMSaveVCDataSourceHistory){
        self.toolBar.hidden = NO;
    }
}

/// 进入编辑模式
- (void)beginEdit{
    [self.rightBarBtn setTitle:@"完成" forState:UIControlStateNormal];
    self.isEditMode = YES;
    self.editV.hidden = NO;
    self.toolBarNewGroBtn.hidden = YES;
    self.toolBarSeleAllBtn.selected = NO;
    self.toolBarDeleBtn.enabled = NO;
    self.toolBarMoveBtn.enabled = NO;
    [self.tableView setEditing:YES animated:YES];
    if(self.sourceType == XMSaveVCDataSourceHistory){
        self.toolBar.hidden = YES;
    }
}


/// 数组降序,即arr[0]的数值最大
- (NSArray *)sortArray:(NSArray *)arr{
    NSComparator comp = ^(NSIndexPath *obj1,NSIndexPath *obj2){
        if (obj1.row > obj2.row){
            return (NSComparisonResult)NSOrderedAscending;
        }
        if (obj1.row < obj2.row){
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
    };
    return [arr sortedArrayUsingComparator:comp];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return (self.sourceType == XMSaveVCDataSourceSave) ? self.saveWebsArr.count : self.historyWebsArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"saveCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:13];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:9];
    }
    XMSaveWebModel *model;
    if (self.sourceType == XMSaveVCDataSourceSave){
        model = self.saveWebsArr[indexPath.row];
    }else if (self.sourceType == XMSaveVCDataSourceHistory){
        model = self.historyWebsArr[indexPath.row];
    }
    if(model.isGroup){
        cell.imageView.image = [UIImage imageNamed:@"icon_file_manager"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = model.groupName;
        cell.detailTextLabel.text = @"";
    }else{
        cell.imageView.image = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.text = model.title;
        cell.detailTextLabel.text = model.url;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(self.tableView.isEditing){
        // 编辑模式下,启用删除,移动按钮
        self.toolBarDeleBtn.enabled = YES;
        self.toolBarMoveBtn.enabled = YES;
        if ([tableView indexPathsForSelectedRows].count == self.saveWebsArr.count){
            self.toolBarSeleAllBtn.selected = YES;
        }
        return;
        
    }else{
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        // 取出对应的模型
        XMSaveWebModel *model;
        if (self.sourceType == XMSaveVCDataSourceSave){
            model = self.saveWebsArr[indexPath.row];
            if(model.isGroup){
                XMSaveWebsTableViewController *saveVC = [[XMSaveWebsTableViewController alloc] init];
                saveVC.passArr = [[XMSaveWebModelLogic webModelsWithGroupName:model.groupName] copy];
                saveVC.groupName = model.groupName;
                [self.navigationController pushViewController:saveVC animated:YES];
                self.navigationItem.title = model.groupName;
                
                return;
            }
        }else if (self.sourceType == XMSaveVCDataSourceHistory){
            model = self.historyWebsArr[indexPath.row];
        }
        // 打开一个webmodule
        XMWKWebViewController *webmodule = (XMWKWebViewController *)[XMWKWebViewController webmoduleWithURL:model.url isSearchMode:YES];
        [self.navigationController pushViewController:webmodule animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.isEditing){
        // 编辑模式下如果没有选中按钮则删除和移动按钮不可用
        if([tableView indexPathsForSelectedRows].count ==  0){
            self.toolBarDeleBtn.enabled = NO;
            self.toolBarMoveBtn.enabled = NO;
            self.toolBarSeleAllBtn.selected = NO;
        }
    }
    
}

#pragma mark 编辑操作
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

// 侧滑和编辑模式下的动作组
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.sourceType == XMSaveVCDataSourceSave){
        // 分组可侧滑删除,编辑模式下则无动作
        XMSaveWebModel *model = self.saveWebsArr[indexPath.row];
        if(model.isGroup){
            if(self.isEditMode){
                return UITableViewCellEditingStyleNone;
            }
        }
    }
    if(self.isEditMode){
        return UITableViewCellEditingStyleDelete|UITableViewCellEditingStyleInsert;
    }else{
        return UITableViewCellEditingStyleDelete;
    }
}

// 侧滑的动作组
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak typeof(self) weakSelf = self;
    if(self.sourceType == XMSaveVCDataSourceSave){ // 收藏
        XMSaveWebModel *model = self.saveWebsArr[indexPath.row];
        if(model.isGroup){
            NSUInteger tabCount = [XMSaveWebModelLogic webModelsWithGroupName:model.groupName].count;
            UITableViewRowAction *editAct = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"改名" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
                UIAlertController *tips = [UIAlertController alertControllerWithTitle:@"输入新组名" message:nil preferredStyle:UIAlertControllerStyleAlert];
                [tips addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    [weakSelf.tableView setEditing:NO animated:YES];
                }]];
                [tips addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
                    [XMSaveWebModelLogic renameSaveGroupWithNewname:tips.textFields[0].text oldName:model.groupName];
                    [weakSelf.tableView reloadData];
                    
                }]];
                [tips addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                    textField.text = model.groupName;
                }];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf presentViewController:tips animated:YES completion:nil];
                });
            }];
            UITableViewRowAction *deleAct = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:[NSString stringWithFormat:@"删除(%zd)",tabCount] handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
                UIAlertController *tips = [UIAlertController alertControllerWithTitle:@"警告" message:[NSString stringWithFormat:@"按下确定将会删除该分组以及里面%zd个标签",tabCount] preferredStyle:UIAlertControllerStyleAlert];
                [tips addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    [weakSelf.tableView setEditing:NO animated:YES];
                }]];
                [tips addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
                    [XMSaveWebModelLogic deleteSaveGroupWithName:model.groupName];
                    weakSelf.saveWebsArr = nil;
                    [weakSelf.tableView reloadData];
                    
                }]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf presentViewController:tips animated:YES completion:nil];
                });
                
            }];
            return @[deleAct,editAct];
            
        }else{
            return @[[UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
                XMSaveWebModel *model = weakSelf.saveWebsArr[indexPath.row];
                [XMSaveWebModelLogic deleteWebURL:model.url];
                weakSelf.saveWebsArr = nil;
                // 重新加载数据
                [weakSelf.tableView reloadData];

            }]];
        }
    }else{ // 历史
        UITableViewRowAction *deleAct = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            [XMSaveWebModelLogic deleteWebModelHistoryAtIndex:indexPath.row];
            weakSelf.historyWebsArr = nil;
            // 重新加载数据
            [weakSelf.tableView reloadData];
        }];
        
        XMSaveWebModel *model = self.historyWebsArr[indexPath.row];
        BOOL isSave = [XMSaveWebModelLogic isWebURLHaveSave:model.url];
        UITableViewRowAction *markAct = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:isSave ? @"取消收藏" : @"收藏" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            if(isSave){
                [XMSaveWebModelLogic deleteWebURL:model.url];
            }else{
                [XMSaveWebModelLogic saveWebUrl:model.url title:model.title];
            }
            weakSelf.historyWebsArr = nil;
            // 重新加载数据
            [weakSelf.tableView reloadData];
        }];
        
        return @[deleAct,markAct];
    }
    
    
}

// 必须实现才能实现侧滑
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{

}

#pragma mark - XMSaveGroupTableViewControllerDelegate
- (void)saveGroupTableViewControllerDidMove{
    [self cancelEdit];
    self.saveWebsArr = nil;
    [self.tableView reloadData];
}
@end
