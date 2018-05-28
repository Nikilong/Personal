//
//  ViewController.m
//  hiWeb
//
//  Created by Niki on 17/9/16.
//  Copyright © 2017年 excellence.com.cn. All rights reserved.
//

#import "XMHiwebViewController.h"
#import "XMPersonDataUnit.h"
#import "XMPersonFilmCollectionVC.h"
#import "XMSingleFilmModle.h"

#import "UIImageView+WebCache.h"
#import "MBProgressHUD+NK.h"

@interface XMHiwebViewController ()<UITextFieldDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) XMPersonFilmCollectionVC *personCollectListVC;

// 记录首页
@property (copy, nonatomic) NSString *homeUrl;

// 导航栏标题栏
@property (weak, nonatomic)  UILabel *navTitleLab;

@end

@implementation XMHiwebViewController

#pragma mark - lazy

- (XMPersonFilmCollectionVC *)personCollectListVC
{
    if (!_personCollectListVC)
    {
        _personCollectListVC = [[XMPersonFilmCollectionVC alloc] initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
        _personCollectListVC.cellSize = CGSizeMake(130, 200);
        _personCollectListVC.cellInset = UIEdgeInsetsMake(10, 10, 0, 10);
        _personCollectListVC.detailMode = NO;
        [self addChildViewController:_personCollectListVC];
        [self.view addSubview:_personCollectListVC.view];
        _personCollectListVC.view.frame = CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    }
    return _personCollectListVC;
}

- (UITextField *)searchV
{
    if (!_searchV)
    {
        // 导航栏contentview
        UITextField *searchF = [[UITextField alloc] init];
        searchF.frame = CGRectMake(10, 64, [UIScreen mainScreen].bounds.size.width - 20, 32);
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
        
        [self.view addSubview:searchF];
        searchF.hidden = YES;
        _searchV = searchF;
    }
    return _searchV;
}

#pragma mark - 系统原生
- (void)viewDidLoad {
    [super viewDidLoad];

    // 初始化导航栏
    [self setNavBar];
    // 开始加载
    self.index = 1;
//    self.url = @"https://www.javbus2.com/star/n4r";
//    self.url = @"https://www.javbus2.com/page";
//    self.url = @"https://www.javbus2.pw/search/abp";
    self.homeUrl = [NSString stringWithContentsOfFile:[XMSavePathUnit getHiwebHomeUrlPath] encoding:NSUTF8StringEncoding error:nil];
    if (self.homeUrl){
        self.url = [NSString stringWithFormat:@"%@/search/abp",self.homeUrl];
        // 开始加载数据
        [self starRequest];
    }else{
        [self getNewHomeUrl];
    }
    

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}
    
- (void)setNavBar{
    CGFloat btnWH = 30;
    CGFloat btnY = (44 - btnWH ) * 0.5;
    // 设置左右导航栏的功能键
    UIView *leftContenV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 44 * 3, 44)];
    // 上一页
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [backBtn setTitle:@"上页" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    // 清缓存
    //    UIButton *clearBtn = [[UIButton alloc] initWithFrame:CGRectMake(44, 0, 44, 44)];
    //    [clearBtn setImage:[UIImage imageNamed:@"iconDelete"] forState:UIControlStateNormal];
    //    [clearBtn addTarget:self action:@selector(clear) forControlEvents:UIControlEventTouchUpInside];
    // 获取最新的地址
    UIButton *homeUrlBtn = [[UIButton alloc] initWithFrame:CGRectMake(44, btnY, btnWH, btnWH)];
    [homeUrlBtn setImage:[UIImage imageNamed:@"iconSetting"] forState:UIControlStateNormal];
    [homeUrlBtn addTarget:self action:@selector(getNewHomeUrl) forControlEvents:UIControlEventTouchUpInside];
    
    // 退出模块
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(88, btnY, btnWH, btnWH)];
    [closeBtn setImage:[UIImage imageNamed:@"iconOffline"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeCurrentViewController) forControlEvents:UIControlEventTouchUpInside];
    
    [leftContenV addSubview:backBtn];
    //    [leftContenV addSubview:clearBtn];
    [leftContenV addSubview:homeUrlBtn];
    [leftContenV addSubview:closeBtn];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftContenV];;
    
    
    UIView *rightContenV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 44 * 3, 44)];
    // 下一页
    UIButton *forwardBtn = [[UIButton alloc] initWithFrame:CGRectMake(88, 0, 44, 44)];
    [forwardBtn setTitle:@"下页" forState:UIControlStateNormal];
    [forwardBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [forwardBtn addTarget:self action:@selector(forward) forControlEvents:UIControlEventTouchUpInside];
    // 搜索按钮
    UIButton *searchBtn = [[UIButton alloc] initWithFrame:CGRectMake(44, btnY, btnWH, btnWH)];
    [searchBtn setImage:[UIImage imageNamed:@"iconSearch"] forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(search) forControlEvents:UIControlEventTouchUpInside];
    // 重载
    UIButton *reloadBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, btnY, btnWH, btnWH)];
    [reloadBtn setImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
    [reloadBtn addTarget:self action:@selector(starRequest) forControlEvents:UIControlEventTouchUpInside];
    
    [rightContenV addSubview:forwardBtn];
    [rightContenV addSubview:searchBtn];
    [rightContenV addSubview:reloadBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightContenV];
    
    // 导航栏标题栏添加标标题
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpToPage)];
    UILabel *navTitleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    self.navTitleLab = navTitleLab;
    navTitleLab.numberOfLines = 0;
    navTitleLab.textAlignment = NSTextAlignmentCenter;
    [navTitleLab addGestureRecognizer: tap];
    self.navigationItem.titleView = navTitleLab;
    self.navigationItem.titleView.userInteractionEnabled = YES;

}



#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            break;
        case 1:
            // 点击了确定按钮,读取当前的输入(序号为0),并且判断输入是否有效
            if([[alertView textFieldAtIndex:0].text integerValue]){
                self.index = [[alertView textFieldAtIndex:0].text integerValue];
                [self starRequest];
            }else{
                [MBProgressHUD showMessage:@"无效的输入,请输入数字" toView:self.view];
            }
            break;
        default:
            break;
    }
}


#pragma mark - 处理数据
/**
 跳转到某一页
 */
- (void)jumpToPage{
    UIAlertView *ale = [[UIAlertView alloc] initWithTitle:@"跳页" message:@"输入要跳转到的页数" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    ale.alertViewStyle = UIAlertViewStylePlainTextInput;
    [ale show];
}

// 前进
- (void)back
{
    self.index--;
    [self starRequest];
}

// 后退
- (void)forward
{
    self.index++;
    [self starRequest];
}

// 清理缓存
- (void)clear
{
    // 清除用sd下载的cell头像（主要）  Library/Caches/default/com.hackemist.SDWebImageCache.default
    [[[SDWebImageManager sharedManager] imageCache] clearDiskOnCompletion:nil];
    
    // 可有可无
    [[[SDWebImageManager sharedManager] imageCache] clearMemory];
    
    // 不过这里要特别注意一下，在IOS7中你会发现使用这两个方法缓存总清除不干净，即使断网下还是会有数据。这是因为在IOS7中，缓存机制做了修改，使用上述两个方法只清除了SDWebImage的缓存，没有清除系统的缓存，所以我们可以在清除缓存的代理中额外添加以下：
    
    // 清除uiwebview的图片缓存（系统方法） Library/Caches/Apple.343--------
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    // 显示清理进度条
    [MBProgressHUD showProgressInView:self.navigationController.view mode:MBProgressHUDModeDeterminateHorizontalBar duration:2 title:@"正在清理缓存中。。。。"];

}
    
// 获得最新的地址
- (void)getNewHomeUrl{
    //https://announce.javbus2.pw/website.php
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error;
        NSString *html = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"https://announce.javbus2.pw/website.php"] encoding:NSUTF8StringEncoding error:&error];
        if (!error){
            // 对html的网页进行提取,并利用NSSet去重
            NSSet *urlSet = [NSSet setWithArray:[XMPersonDataUnit new_dealDateUrl:html logFlag:NO]];
            NSArray *urlArr = urlSet.allObjects;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // 弹出底部按钮来做选项
                UIAlertController *tips = [UIAlertController alertControllerWithTitle:@"提示" message:@"重新设定主页url" preferredStyle:UIAlertControllerStyleActionSheet];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                [tips addAction:cancelAction];
                
                __weak typeof(self) weakSelf = self;
                for (int i = 0; i < urlArr.count; i++) {
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:urlArr[i] style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action){
                        weakSelf.homeUrl = urlArr[i];
                        weakSelf.url = [NSString stringWithFormat:@"%@/search/abp",urlArr[i]];
                        [urlArr[i] writeToFile:[XMSavePathUnit getHiwebHomeUrlPath] atomically:YES encoding:NSUTF8StringEncoding error:nil];
                        
                        [weakSelf starRequest];
                        
                    }];
                    
                    [tips addAction:okAction];
                    
                }
                
                [self presentViewController:tips animated:YES completion:nil];
                NSLog(@"---");
            });
            
        }
        
    });

}

// 搜索
- (void)search
{
    self.searchV.hidden = !self.searchV.hidden;
    if (!self.searchV.hidden)
    {
        self.searchV.text = @"";
        [self.searchV becomeFirstResponder];
    }else
    {
        [self.searchV resignFirstResponder];
    }
}
    
// 退出当前模块
- (void)closeCurrentViewController{
    [self.navigationController popViewControllerAnimated:YES];
}


// 开始网络请求
- (void)starRequest
{
    // 通过url获取网页的内容
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%zd",self.url,self.index]];
    
    // 对url的有效性进行判断
    if (![[UIApplication sharedApplication] canOpenURL:url])
    {
        [MBProgressHUD showMessage:@"无效的url" toView:self.view];
        return;
    }

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    // 异步去加载网络请求
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSError *error;
        NSString *html = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
        if (error.code == -999){
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            return;
        }
        // 回到主线程更新ui
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            // 判断请求得到的内容是否为空
            if (!html.length)
            {
                [MBProgressHUD showMessage:@"无相关内容" toView:self.view];
                return;
            }
            
            // 显示当前页数
            self.navTitleLab.text = [NSString stringWithFormat:@"第%zd页",self.index];
            
            // 如果有数据则解析数据
            NSArray *dataArr = [XMPersonDataUnit dealDate:html];
            self.personCollectListVC.data = dataArr;
//            self.personCollectListVC.detailMode = NO;
            
        }];
    });
    
}



#pragma mark - uitextfield delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // 隐藏搜索框并且收起键盘
    [self.searchV resignFirstResponder];
    self.searchV.hidden = YES;

    // 没有内容时不进行搜索
    if (textField.text.length == 0) return NO;
    
    // 拼接搜索内容并且对中文进行转码
    self.url = [[NSString stringWithFormat:@"%@/search/%@",self.homeUrl,textField.text] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    // 重置索引为第一页
    self.index = 1;
    // 发起网络请求
    [self starRequest];
    
    return YES;
}


@end
