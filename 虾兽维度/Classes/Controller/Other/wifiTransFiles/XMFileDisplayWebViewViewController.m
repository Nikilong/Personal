//
//  XMFileDisplayWebViewViewController.m
//  虾兽维度
//
//  Created by Niki on 18/5/6.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMFileDisplayWebViewViewController.h"
//#import <WebKit/WebKit.h>

@interface XMFileDisplayWebViewViewController ()

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

    [self.view addSubview:self.displayWebview];
    
}


/// 加载本地文件
- (void)loadLocalFileWithPath:(NSString *)fullPath{
    [self.displayWebview loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:fullPath]]];
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
