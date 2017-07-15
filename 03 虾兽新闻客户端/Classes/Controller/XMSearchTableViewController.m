//
//  XMSearchTableViewController.m
//  虾兽新闻客户端
//
//  Created by Niki on 17/7/15.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "XMSearchTableViewController.h"

#define kName @"name"
#define kEngine @"engine"

@interface XMSearchTableViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) NSString *selectEngine;
@property (nonatomic, strong) NSMutableArray *engineArr;

@property (weak, nonatomic)  UITextField *searchF;

@end

@implementation XMSearchTableViewController

#pragma mark - lazy
- (NSMutableArray *)engineArr
{
    if (!_engineArr)
    {
        _engineArr = [[NSMutableArray alloc] init];
        /*
         https://www.baidu.com/s?ie=UTF-8&wd=a11a
         http://cn.bing.com/search?q=a11a
         https://www.sogou.com/web?query=a11a
         */
        NSDictionary *bingDict = @{kName : @"必应",
                                   kEngine : @"https://www.baidu.com/s?ie=UTF-8&wd="
                                   };
        NSDictionary *baiduDict = @{kName : @"百毒",
                                   kEngine : @"http://cn.bing.com/search?q="
                                   };
        NSDictionary *sogouDict = @{kName : @"搜狗",
                                     kEngine : @"https://www.sogou.com/web?query="
                                     };
//        NSDictionary *googleDict = @{@"name" : @"谷歌",
//                                   @"engine" : @""
//                                   };
        [_engineArr addObject:bingDict];
        [_engineArr addObject:baiduDict];
        [_engineArr addObject:sogouDict];

    }
    return _engineArr;
}

#pragma mark - 系统默认
- (void)viewDidLoad {
    [super viewDidLoad];
    // 设置导航栏
    [self setNavItem];
    // 默认初始搜索引擎为必应
    self.selectEngine = @"http://cn.bing.com/search?q=";
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationItem.titleView becomeFirstResponder];
}

#pragma mark - 
- (void)setNavItem
{
    // 导航栏titleview
    UITextField *searchF = [[UITextField alloc] init];
    searchF.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 120, 32);
    searchF.delegate = self;
    searchF.placeholder = @"请输入要搜索的条件";
    searchF.background = [UIImage imageNamed:@"searchbar_textfield_background"];
    // 添加右边全部清除按钮
    searchF.clearButtonMode = UITextFieldViewModeWhileEditing;
    // 添加左边搜索框图片
    UIImageView *leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchbar_textfield_search_icon"]];
    // 设置图片居中
    leftView.contentMode = UIViewContentModeCenter;
    leftView.frame = CGRectMake(0, 0, 30, 30);
    searchF.leftView = leftView;
    searchF.leftViewMode = UITextFieldViewModeAlways;
    self.navigationItem.titleView = searchF;
    self.searchF = searchF;

    // 左侧取消按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancel)];
    
    // 右侧go按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"go" style:UIBarButtonItemStyleDone target:self action:@selector(go)];
}

- (void)go
{
    NSLog(@"%s",__func__);
    XMWebModel *model = [[XMWebModel alloc] init];
    NSString *webStr = [[NSString stringWithFormat:@"%@%@",self.selectEngine,self.searchF.text] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    model.webURL = [NSURL URLWithString:webStr];
    
    if ([self.delegate respondsToSelector:@selector(openWebmoduleRequest:)])
    {
        [self.delegate openWebmoduleRequest:model];
    }
    
    [self cancel];
}

- (void)cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - delegate
#pragma mark tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.engineArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    cell.textLabel.text = self.engineArr[indexPath.row][kName];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectEngine = self.engineArr[indexPath.row][kEngine];
    [self go];
}

#pragma mark textfield delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self go];
    return YES;
}

@end
