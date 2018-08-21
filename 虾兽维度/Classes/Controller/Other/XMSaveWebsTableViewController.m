//
//  XMSaveWebsTableViewController.m
//  虾兽维度
//
//  Created by Niki on 17/3/25.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "XMSaveWebsTableViewController.h"
#import "XMWebModelLogic.h"

typedef enum{
    XMSaveVCDataSourceSave,
    XMSaveVCDataSourceHistory,
} XMSaveVCDataSource;

@interface XMSaveWebsTableViewController ()

@property (nonatomic, strong) NSArray *saveWebsArr;         // 收藏数组
@property (nonatomic, strong) NSArray *historyWebsArr;      // 历史数组
@property (nonatomic, assign)  XMSaveVCDataSource sourceType;

@property (weak, nonatomic)  UIButton *clearBtn;


@end

@implementation XMSaveWebsTableViewController

- (NSArray *)saveWebsArr{
    if (!_saveWebsArr){
        _saveWebsArr = [XMWebModelLogic webModels];
    }
    return _saveWebsArr;
}

- (NSArray *)historyWebsArr{
    if (!_historyWebsArr){
        _historyWebsArr = [XMWebModelLogic getHistoryUrlArray];
    }
    return _historyWebsArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sourceType = XMSaveVCDataSourceSave;
    
    // 设置导航栏
    [self setNavView];
    
    // 设置刷新控件
    [self setRefreshKit];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

#pragma mark - 刷新空间以及刷新方法
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
    
    UIButton *clearBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    [clearBtn setTitle:@"清除记录" forState:UIControlStateNormal];
    [clearBtn setTitleColor:RGB(42, 122, 252) forState:UIControlStateNormal];
    [clearBtn addTarget:self action:@selector(clearHistoryRecord) forControlEvents:UIControlEventTouchUpInside];
    self.clearBtn = clearBtn;
    self.clearBtn.hidden = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:clearBtn];
}

/// 导航栏切换按钮点击事件
- (void)segmentedButtonDidClick:(UISegmentedControl *)sender{
    if(sender.selectedSegmentIndex == 0){           // 收藏
        self.sourceType = XMSaveVCDataSourceSave;
        self.saveWebsArr = nil;
        self.clearBtn.hidden = YES;
    }else if(sender.selectedSegmentIndex == 1){     // 历史
        self.clearBtn.hidden = NO;
        self.historyWebsArr = nil;
        self.sourceType = XMSaveVCDataSourceHistory;
    }
    [self.tableView reloadData];
}

/// 清理浏览记录
- (void)clearHistoryRecord{
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

/// 批量删除历史记录
- (void)deleteRecentHistoryRecordWithNumber:(NSUInteger)number{
    self.historyWebsArr = nil;
    [XMWebModelLogic deleteWebModelHistoryWithNumber:number];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return (self.sourceType == XMSaveVCDataSourceSave) ? self.saveWebsArr.count : self.historyWebsArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"saveCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell){
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    if (self.sourceType == XMSaveVCDataSourceSave){
        XMWebModel *model = self.saveWebsArr[indexPath.row];
        cell.textLabel.text = model.title;
        cell.detailTextLabel.text = model.webURL.absoluteString;
    }else if (self.sourceType == XMSaveVCDataSourceHistory){
        cell.textLabel.text = self.historyWebsArr[indexPath.row][@"title"];
        cell.detailTextLabel.text = self.historyWebsArr[indexPath.row][@"url"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // 取出对应的模型
    XMWebModel *model;
    if (self.sourceType == XMSaveVCDataSourceSave){
        model = self.saveWebsArr[indexPath.row];
    }else if (self.sourceType == XMSaveVCDataSourceHistory){
        model = [[XMWebModel alloc] init];
        model.webURL = [NSURL URLWithString:self.historyWebsArr[indexPath.row][@"url"]];
    }
    
//    // 因为webmodule是push出来的,必须先pop掉当前控制器
//    [self.navigationController popViewControllerAnimated:YES];

    // 通知代理发送网络请求
    if ([self.delegate respondsToSelector:@selector(openWebmoduleRequest:)]){
        [self.delegate openWebmoduleRequest:model];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.sourceType == XMSaveVCDataSourceSave){
        [XMWebModelLogic deleteWebModelAtIndex:indexPath.row];
    }else if (self.sourceType == XMSaveVCDataSourceHistory){
        self.historyWebsArr = nil;
        [XMWebModelLogic deleteWebModelHistoryAtIndex:indexPath.row];
    }
    
    // 重新加载数据
    [self.tableView reloadData];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

@end
