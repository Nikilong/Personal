//
//  XMSaveGroupTableViewController.m
//  虾兽维度
//
//  Created by Niki on 2018/10/2.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMSaveGroupTableViewController.h"
#import "XMSaveWebModel.h"
#import "XMSaveWebModelLogic.h"
#import <DKNightVersion/DKNightVersion.h>
#import "XMDarkNightCell.h"

@interface XMSaveGroupTableViewController ()

@property (nonatomic, copy) NSArray *dataArr;

@end

@implementation XMSaveGroupTableViewController
- (NSArray *)dataArr{
    if (!_dataArr){
        _dataArr = [XMSaveWebModelLogic webModelsGroups];
    }
    return _dataArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self setNav];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // 偏移距离为导航栏(44)+状态栏(20或44)+标签(44)高度
    if([UIDevice currentDevice].systemVersion.integerValue >= 11){
        self.tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
    }else{
        self.tableView.contentInset = UIEdgeInsetsMake(XMStatusBarHeight + 44 + 44, 0, 0, 0);
    }
    // 分割线偏移设置
    self.tableView.separatorInset = UIEdgeInsetsMake(0, -100, 0, 0);
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    // 去掉cell之间的间隔线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.dk_backgroundColorPicker = DKColorPickerWithColors(RGB(242, 242, 242), XMNavDarkBG);
    self.tableView.dk_separatorColorPicker = DKColorPickerWithKey(SEP);
}

- (void)setNav{
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 44, XMScreenW, 44)];
    lab.backgroundColor = [UIColor whiteColor];
    lab.text = [NSString stringWithFormat:@"      已选%zd个标签",self.seleIndexArr.count];
    lab.textColor = [UIColor blackColor];
    lab.textAlignment = NSTextAlignmentLeft;
    [self.navigationController.navigationBar addSubview:lab];
    
    self.navigationItem.title = @"移动至";
    
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    [leftBtn dk_setTintColorPicker:DKColorPickerWithColors(RGB(242, 242, 242), XMNavDarkBG)];
    self.navigationItem.leftBarButtonItem = leftBtn;
}

- (void)dismiss{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//    return 0;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"saveGroupCell";
    XMDarkNightCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell){
        cell = [[XMDarkNightCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
    }
    XMSaveWebModel *model = self.dataArr[indexPath.row];
    // 根路径采用蓝色文件夹
    if([model.groupName isEqualToString:XMSavewebsDefaultGroupName]){
        cell.imageView.image = [UIImage imageNamed:@"icon_file_manager_root"];
    }else{
        cell.imageView.image = [UIImage imageNamed:@"icon_file_manager"];
    }
    cell.textLabel.text = model.groupName;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 移动
    XMSaveWebModel *model = self.dataArr[indexPath.row];
    if(![self.fromGroName isEqualToString:model.groupName]){
        // 只有前后不一样的组才需要移动
        [XMSaveWebModelLogic moveSavemodels:self.seleIndexArr fromGroup:self.fromGroName toGroup:model.groupName];
    }
    
    if([self.delegate respondsToSelector:@selector(saveGroupTableViewControllerDidMove)]){
        [self.delegate saveGroupTableViewControllerDidMove];
    }
    [self dismiss];
}
@end
