//
//  XMWebViewController.m
//  03 虾兽新闻客户端
//
//  Created by admin on 17/2/27.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "XMWebViewController.h"

@interface XMWebViewController ()



@end

@implementation XMWebViewController

- (UIWebView *)web
{
    if (_web == nil)
    {
        _web = [[UIWebView alloc] init];
        _web.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    }
    return _web;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UISwipeGestureRecognizer *swip = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(back)];
    swip.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swip];
}

- (void)back
{
    [self dismissViewControllerAnimated:self completion:nil];
}


@end
