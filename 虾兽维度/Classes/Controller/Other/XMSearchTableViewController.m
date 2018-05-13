//
//  XMSearchTableViewController.m
//  虾兽维度
//
//  Created by Niki on 17/7/15.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "XMSearchTableViewController.h"

#define kName @"name"
#define kEngine @"engine"

@interface XMSearchTableViewController ()<UITextFieldDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSString *selectEngine;
@property (nonatomic, strong) NSMutableArray *engineArr;

@property (weak, nonatomic)  UITextField *searchF;
    
@property (weak, nonatomic)  UITableViewCell *urlCell;

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
                                   kEngine : @"http://cn.bing.com/search?q="
                                   };
        NSDictionary *baiduDict = @{kName : @"百毒",
                                   kEngine : @"https://www.baidu.com/s?ie=UTF-8&wd="
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
    // 添加右划dismiss手势
    UISwipeGestureRecognizer *swip = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cancel)];
    swip.delegate = self;
    [self.tableView addGestureRecognizer:swip];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 自动弹出键盘
    [self.navigationItem.titleView becomeFirstResponder];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:self.searchF];
}
    
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"go" style:UIBarButtonItemStyleDone target:self action:@selector(goWithUrlFlag:)];
}

- (void)goWithUrlFlag:(BOOL)urlFlag
{
    // 收起键盘
    [self.searchF resignFirstResponder];
    
    // 传递web数据给webmodule
    XMWebModel *model = [[XMWebModel alloc] init];
    // 对于搜索内容为中文时,需要转码
    NSString *webStr;
    if (urlFlag){
        webStr = [self.searchF.text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }else{
        webStr = [[NSString stringWithFormat:@"%@%@",self.selectEngine,self.searchF.text] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    model.webURL = [NSURL URLWithString:webStr];
    
    // 先dismiss掉self,然后再通知代理去加载网页
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(openWebmoduleRequest:)])
        {
            [self.delegate openWebmoduleRequest:model];
        }
    }];
}

- (void)cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - delegate
#pragma mark tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return 2;
}
    
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? 1 : self.engineArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    if(indexPath.section == 0){
        cell.textLabel.text = @"前往URL:";
        self.urlCell = cell;
    }else{
    
        cell.textLabel.text = self.engineArr[indexPath.row][kName];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        [self goWithUrlFlag:YES];
    }else{
    
        // 改变频道
        self.selectEngine = self.engineArr[indexPath.row][kEngine];
        // 然后去搜索
        [self goWithUrlFlag:NO];
    }
}

#pragma mark textfield delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // 按下键盘的return去搜索
    [self goWithUrlFlag:NO];
    return YES;
}
    
#pragma mark - 监听textfield的输入
- (void)textFieldDidChangeNotification:(NSNotification *)noti{

    self.urlCell.textLabel.text = [NSString stringWithFormat:@"前往URL: %@",self.searchF.text];
}
    


@end
