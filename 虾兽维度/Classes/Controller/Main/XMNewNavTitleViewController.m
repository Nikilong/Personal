//
//  XMNewNavTitleViewController.m
//  虾兽维度
//
//  Created by Niki on 18/7/22.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMNewNavTitleViewController.h"
#import "XMChannelModel.h"


@interface XMNewNavTitleViewController ()

// uc新闻频道
@property (nonatomic, strong) NSArray *channelArr;

@end

@implementation XMNewNavTitleViewController

- (NSArray *)channelArr{
    if (!_channelArr){
        _channelArr = [XMChannelModel channels];
    }
    return _channelArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 创建按钮组
    [self creatChannelBtns];
}

- (void)creatChannelBtns{
    UIView *containerV = [[UIView alloc] init];
    containerV.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:containerV];
    // 3.键盘整体
    CGFloat btnW = 60;
    CGFloat btnH = 44;
    CGFloat padding = 10;       // 间隙
    NSUInteger colMaxNum = 3;      // 每行允许排列的图标个数
    
    // 工具箱按钮参数
    NSUInteger btnNum = self.channelArr.count;
    
    // 添加按钮
    CGFloat btnX;
    CGFloat btnY;
    for (int i = 0; i < btnNum; i++){
        btnX = padding + btnW * (i % colMaxNum);
        btnY = padding + btnH * (i / colMaxNum);
        // 工具箱按钮
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(btnX, btnY, btnW, btnH)];
        [containerV addSubview:btn];
        btn.tag = i;
        [btn setTitle:@"忘记密码" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(channelBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
}

#pragma mark - 代理方法
/** 通知代理选中了某一个频道 */
- (void)channelBtnDidClick:(UIButton *)btn{
    if ([self.delegate respondsToSelector:@selector(navTitleViewControllerDidSelectChannel:)]){
        [self.delegate navTitleViewControllerDidSelectChannel:btn.tag];
    }
}
@end
