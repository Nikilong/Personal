//
//  XMTabBar.m
//  虾兽维度
//
//  Created by Niki on 2018/10/18.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMTabBar.h"
@interface XMTabBar()

@property (weak, nonatomic)  UIButton *midBtn;  // 中心按钮

@end

@implementation XMTabBar


- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        UIButton *btn = [[UIButton alloc] init];
        [btn setImage:[UIImage imageNamed:@"tabbar_icon_news_middle"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(tabbarButtonDidClick:) forControlEvents:UIControlEventTouchDown];
        self.midBtn = btn;
        [self addSubview:btn];
    }
    return self;
}


- (void)tabbarButtonDidClick:(UIButton *)btn{
    if([self.delegate respondsToSelector:@selector(tabBarMidButtonDidClick)]){
        [self.delegate tabBarMidButtonDidClick];
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat buttonY = 0;
    CGFloat buttonW = XMScreenW / 3;
    CGFloat buttonH = self.frame.size.height;

    int index = 0;
    for (UIView *button in self.subviews) {
        if ([button isKindOfClass:NSClassFromString(@"UITabBarButton")]){
            // 计算按钮的x值,0为中间button的序号-1,共3个按钮,则为0,共5个按钮,则为1
            CGFloat buttonX = buttonW * ((index > 0)?(index + 1):index);
            button.frame = CGRectMake( buttonX, buttonY, buttonW, buttonH);
            index++;
        }
    }

    self.midBtn.frame = CGRectMake((XMScreenW - buttonW) * 0.5, 0, buttonW, buttonH);
    [self bringSubviewToFront:self.midBtn];
}


@end
