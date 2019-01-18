//
//  XMBaseNavViewController.m
//  虾兽维度
//
//  Created by Niki on 2019/1/16.
//  Copyright © 2019年 admin. All rights reserved.
//

#import "XMBaseNavViewController.h"

@interface XMBaseNavViewController ()

@end

@implementation XMBaseNavViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 统一导航栏样式
    self.navigationBar.translucent = NO;
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBgGray"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setTintColor:[UIColor whiteColor]];
    
    
    // 导航栏标题栏样式
    self.navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:19],NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    // 状态栏白色字体
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
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
