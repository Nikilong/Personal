//
//  XMBaseNavViewController.m
//  虾兽维度
//
//  Created by Niki on 2019/1/16.
//  Copyright © 2019年 admin. All rights reserved.
//

#import "XMBaseNavViewController.h"
#import <DKNightVersion/DKNightVersion.h>

@interface XMBaseNavViewController ()

@end

@implementation XMBaseNavViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 统一导航栏样式
    self.navigationBar.translucent = NO;
//    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBgGray"] forBarMetrics:UIBarMetricsDefault];
//    [self.navigationBar setTintColor:[UIColor whiteColor]];
    [self changeDrakModeNavbarStyle];
    
    // 状态栏白色字体
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.navigationBar.dk_barTintColorPicker =  DKColorPickerWithColors([UIColor whiteColor], [UIColor blackColor]);
    // 监听切换黑夜模式
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeDrakModeNavbarStyle) name:DKNightVersionThemeChangingNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [self changeDrakModeNavbarStyle];
}

/// 切换更多中护眼模式按钮的文字和图片
- (void)changeDrakModeNavbarStyle{
    if ([self.dk_manager.themeVersion isEqualToString:DKThemeVersionNight]) {  // 黑夜
        [self.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [self.navigationBar setTintColor:[UIColor blackColor]];
        
        // 导航栏标题栏样式
        self.navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:19],NSForegroundColorAttributeName:[UIColor grayColor]};
    }else{ // 白天
        [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBgGray"] forBarMetrics:UIBarMetricsDefault];
        [self.navigationBar setTintColor:[UIColor whiteColor]];
        // 导航栏标题栏样式
        self.navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:19],NSForegroundColorAttributeName:[UIColor whiteColor]};
        
        
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
