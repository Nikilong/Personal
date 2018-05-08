//
//  XMFileDisplayWebViewViewController.m
//  虾兽维度
//
//  Created by Niki on 18/5/6.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMFileDisplayWebViewViewController.h"
//#import <WebKit/WebKit.h>

@interface XMFileDisplayWebViewViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIWebView *displayWebview;

@end

@implementation XMFileDisplayWebViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // todo 要使用wkwebview来播放视频,未解决
//    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
//    config.allowsInlineMediaPlayback = YES;
//    config.allowsPictureInPictureMediaPlayback = YES;
//    
//    self.displayWebview = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    self.displayWebview = [[UIWebView alloc] initWithFrame:self.view.bounds];
    // 实现缩放
    self.displayWebview.scalesPageToFit = YES;
    [self.view addSubview:self.displayWebview];
    
    // 增加点击手势隐藏或显示导航栏
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showNavBar:)];
    tap.delegate = self;
    [self.displayWebview addGestureRecognizer:tap];
    
}

/// 隐藏或显示导航栏
- (void)showNavBar:(UITapGestureRecognizer *)gest{
    if (gest.state == UIGestureRecognizerStateEnded){
        self.navigationController.navigationBarHidden = !self.navigationController.navigationBarHidden;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;

}

/// 加载本地文件
- (void)loadLocalFileWithPath:(NSString *)fullPath{
    [self.displayWebview loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:fullPath]]];
}



@end
