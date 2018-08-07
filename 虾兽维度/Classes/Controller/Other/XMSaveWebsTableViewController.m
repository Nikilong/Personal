//
//  XMSaveWebsTableViewController.m
//  虾兽维度
//
//  Created by Niki on 17/3/25.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "XMSaveWebsTableViewController.h"
#import "XMWebModelTool.h"

@interface XMSaveWebsTableViewController ()

@property (nonatomic, strong) NSArray *saveWebsArr;

@end

@implementation XMSaveWebsTableViewController

- (NSArray *)saveWebsArr{
    if (!_saveWebsArr){
        _saveWebsArr = [XMWebModelTool webModels];
    }
    return _saveWebsArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.saveWebsArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"saveCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell){
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    XMWebModel *model = _saveWebsArr[indexPath.row];
    cell.textLabel.text = model.title;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // 取出对应的模型
    XMWebModel *model = self.saveWebsArr[indexPath.row];
    
//    // 因为webmodule是push出来的,必须先pop掉当前控制器
//    [self.navigationController popViewControllerAnimated:YES];

    // 通知代理发送网络请求
    if ([self.delegate respondsToSelector:@selector(openWebmoduleRequest:)]){
        [_delegate openWebmoduleRequest:model];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [XMWebModelTool deleteWebModelAtIndex:indexPath.row];
    
    // 重新加载数据
    [self.tableView reloadData];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

@end
