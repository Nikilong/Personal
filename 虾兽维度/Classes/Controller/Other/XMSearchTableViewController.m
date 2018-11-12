//
//  XMSearchTableViewController.m
//  虾兽维度
//
//  Created by Niki on 17/7/15.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "XMSearchTableViewController.h"
#import "XMWKWebViewController.h"
#import "XMSaveWebModelLogic.h"
#import "XMVisualView.h"
#import "XMImageUtil.h"

static NSString *const kImageName = @"imageName";
static NSString *const kEngine = @"engine";

@interface XMSearchTableViewController ()<UITextFieldDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSString *selectEngine;
@property (nonatomic, strong) NSMutableArray *engineArr;
@property (nonatomic, strong) NSArray *searchResultArr;

@property (weak, nonatomic)  UITextField *searchF;

@property (nonatomic, assign)  NSUInteger searchBtnWH;


@end

@implementation XMSearchTableViewController

#pragma mark - lazy
- (NSMutableArray *)engineArr{
    
    if (!_engineArr){
        _engineArr = [[NSMutableArray alloc] init];
        /*
         https://www.baidu.com/s?ie=UTF-8&wd=a11a
         http://cn.bing.com/search?q=a11a
         https://www.sogou.com/web?query=a11a
         */
        NSDictionary *bingDict = @{kImageName : @"icon_bing",
                                   kEngine : @"http://cn.bing.com/search?q="
                                   };
        NSDictionary *baiduDict = @{kImageName : @"icon_baidu",
                                    kEngine : @"https://www.baidu.com/s?ie=UTF-8&wd="
                                   };
        NSDictionary *sogouDict = @{kImageName : @"icon_sogou",
                                    kEngine : @"https://www.sogou.com/web?query="
                                     };
        NSDictionary *googleDict = @{kImageName : @"icon_google",
                                     kEngine : @"https://www.google.com/search?q="
                                   };
        [_engineArr addObject:bingDict];
        [_engineArr addObject:baiduDict];
        [_engineArr addObject:sogouDict];
        [_engineArr addObject:googleDict];

    }
    return _engineArr;
}

- (NSArray *)searchResultArr{
    if (!_searchResultArr){
        _searchResultArr = [NSArray array];
    }
    return _searchResultArr;
}

- (void)setPassUrl:(NSString *)passUrl{
    _passUrl = passUrl;
    
    // 设置输入框和cell的内容
    self.searchF.text = passUrl;
    [self textFieldDidChangeNotification:nil];
    
    // 全选并且移动光标到首位(先移动光标到首位,再全选所有)
    UITextRange *range = self.searchF.selectedTextRange;
    UITextPosition *start = [self.searchF positionFromPosition:range.start inDirection:UITextLayoutDirectionLeft offset:self.searchF.text.length];
    // 控制光标在开始的位置
    if (start) {
        [self.searchF setSelectedTextRange:[self.searchF textRangeFromPosition:start toPosition:start]];
    }
    // 全选
    [self.searchF selectAll:self];
    
}

#pragma mark - 系统默认
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置搜索引擎按钮宽高
    self.searchBtnWH = 70;
    // 设置导航栏
    [self setNavItem];
    // 默认初始搜索引擎为必应
    self.selectEngine = @"https://www.baidu.com/s?ie=UTF-8&wd=";
//    self.selectEngine = @"http://cn.bing.com/search?q=";
    // 添加右划dismiss手势
    UISwipeGestureRecognizer *swip = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cancel)];
    swip.delegate = self;
    [self.tableView addGestureRecognizer:swip];
    
}

- (void)viewWillAppear:(BOOL)animated{
    
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
- (void)setNavItem{
    
    // 导航栏titleview
    UITextField *searchF = [[UITextField alloc] init];
    searchF.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 60, 32);
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

    // 右侧取消按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancel)];
}

- (void)goWithUrlFlag:(BOOL)urlFlag{
    
    // 如果该url和初始传递的url一样,并且是进行网页跳转时,直接dismiss掉
    if([self.searchF.text isEqualToString:self.passUrl] && urlFlag){
        [self cancel];
    }else{
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
        model.searchMode = YES;
        
        // 先dismiss掉self,然后再通知代理去加载网页
        [self dismissViewControllerAnimated:YES completion:^{
            if ([self.delegate respondsToSelector:@selector(openWebmoduleRequest:)]){
                [self.delegate openWebmoduleRequest:model];
            }
        }];
    }
}

- (void)cancel{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - delegate
#pragma mark tableview delegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *title = @"";
    if(section == 1){
        title = @"搜索";
    }else if (section == 2){
        title = @"书签或浏览历史";
    }
    return title;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    if (section == 0){
//        return [[UIView alloc] init];
//    }else{
//        return [[UIView alloc] initWithFrame:CGRectMake(0, 0, XMScreenW, 25)];
//    }
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.section == 1 ? self.searchBtnWH : 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.searchResultArr.count > 0 ? 3 : 2;
}
    
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 2){
        return self.searchResultArr.count;
    }else if(section == 0){
        return 3;
    }else{
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if(indexPath.section == 0){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"searchCellOne"];
        if(indexPath.row == 0){
            cell.textLabel.text = [NSString stringWithFormat:@"前往URL: %@",self.searchF.text];
        }else if(indexPath.row == 1){
            cell.textLabel.text = @"生成二维码图片";
        }else if(indexPath.row == 2){
            cell.textLabel.text = @"生成二维码图片并分享";
        }
    }else if(indexPath.section == 1){
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"searchCellTwo"];
        [self setSearchBtnInCell:cell];
        
    }else if(indexPath.section == 2){
        static NSString *ID = @"searchCellThree";
        cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:13];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:9];
        }
        XMSaveWebModel *model = self.searchResultArr[indexPath.row];
        cell.textLabel.text = model.title;
        cell.detailTextLabel.text = model.url;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 收起键盘
    [self.searchF resignFirstResponder];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section == 0){
        if(indexPath.row == 0){
            [self goWithUrlFlag:YES];
        }else if(indexPath.row == 1){
            CGFloat imageWH = XMScreenW * 0.7;
            UIImage *image = [XMImageUtil creatQRCodeImageWithString:self.searchF.text size:imageWH];
            [XMVisualView creatVisualImageViewWithImage:image imageSize:CGSizeMake(imageWH, imageWH) blurEffectStyle:0];
        }else if(indexPath.row == 2){
            CGFloat imageWH = XMScreenW * 0.7;
            UIImage *image = [XMImageUtil creatQRCodeImageWithString:self.searchF.text size:imageWH];
            // 创建分享菜单,这里分享为全部平台,可通过设置excludedActivityTypes属性排除不要的平台
            UIActivityViewController *actVC = [[UIActivityViewController alloc] initWithActivityItems:@[image] applicationActivities:nil];
            // 弹出分享菜单
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:actVC animated:YES completion:nil];
            });
            
        }
    }else if(indexPath.section == 2){
        XMSaveWebModel *model = self.searchResultArr[indexPath.row];
        BOOL canOpenNewWebmodule = ![model.url isEqualToString:self.passUrl];
        [self dismissViewControllerAnimated:YES completion:^{
            if (canOpenNewWebmodule){
                XMWKWebViewController *webmodule = (XMWKWebViewController *)[XMWKWebViewController webmoduleWithURL:model.url isSearchMode:NO];
                [self.navigationController pushViewController:webmodule animated:YES];
            }
        }];
    
    }
}

/// 第1组,搜索引擎组UI设置
- (void)setSearchBtnInCell:(UITableViewCell *)cell{
    NSUInteger btnCount = self.engineArr.count;
    CGFloat margin = (XMScreenW - self.searchBtnWH * btnCount) / (btnCount + 1);
    CGFloat btnX = 0;
    for (NSUInteger i = 0; i < btnCount; i++) {
        btnX = margin + (margin + self.searchBtnWH) * i;
        btnX = margin + (margin + self.searchBtnWH) * i;
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(btnX , 0, self.searchBtnWH, self.searchBtnWH)];
        btn.tag = i;
        [cell.contentView addSubview:btn];
        [btn setImage:[UIImage imageNamed:self.engineArr[i][kImageName]] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(searchEngineBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
}

/// 搜索引擎点击事件
- (void)searchEngineBtnDidClick:(UIButton *)btn{
    // 收起键盘
    [self.searchF resignFirstResponder];
    // 改变频道
    self.selectEngine = self.engineArr[btn.tag][kEngine];
    // 然后去搜索
    [self goWithUrlFlag:NO];
    
}

#pragma mark - textfield delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    // 按下键盘的return去搜索,如果包含http或者https开头,默认打开网址
    if([textField.text hasPrefix:@"http://"] || [textField.text hasPrefix:@"https://"]){
        [self goWithUrlFlag:YES];
    }else{
        [self goWithUrlFlag:NO];
    }
    return YES;
}
    
#pragma mark - 监听textfield的输入
- (void)textFieldDidChangeNotification:(NSNotification *)noti{
    
    NSArray *result = [XMSaveWebModelLogic searchForKeywordInWebData:self.searchF.text];
    self.searchResultArr = nil;
    if(result.count > 0){
        self.searchResultArr = result;
    }
    [self.tableView reloadData];
}



@end
