//
//  XMFloatWindow.m
//  虾兽维度
//
//  Created by Niki on 17/3/27.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "XMFloatWindow.h"

@interface XMFloatWindow()

@property (weak, nonatomic)  UIButton *refreshBtn;

@end

@implementation XMFloatWindow

- (void)setIsShowRefreshButton:(BOOL)isShowRefreshButton{
    _isShowRefreshButton = isShowRefreshButton;
    _refreshBtn.hidden = !isShowRefreshButton;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        // 创建刷新按钮
        UIButton *btnRefresh = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnRefresh setBackgroundImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
        [btnRefresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventTouchDown];
        _refreshBtn = btnRefresh;
        
        
        // 滚到最顶按钮
        UIButton *btnTop = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnTop setBackgroundImage:[UIImage imageNamed:@"up_normal"] forState:UIControlStateNormal];
        [btnTop setBackgroundImage:[UIImage imageNamed:@"up"] forState:UIControlStateHighlighted];
        [btnTop addTarget:self action:@selector(upToTop) forControlEvents:UIControlEventTouchDown];
        
        // 滚到底部按钮
        UIButton *btnDown = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnDown setBackgroundImage:[UIImage imageNamed:@"down_normal"] forState:UIControlStateNormal];
        [btnDown setBackgroundImage:[UIImage imageNamed:@"down"] forState:UIControlStateHighlighted];
        [btnDown addTarget:self action:@selector(downToBottom) forControlEvents:UIControlEventTouchDown];
        
        self.hidden = NO;
        [self addSubview:btnTop];
        [self addSubview:btnRefresh];
        [self addSubview:btnDown];

    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat btnW = self.bounds.size.width;
    CGFloat btnH = self.bounds.size.height / 3;
    CGFloat btnY = 0;
    for (int i = 0; i < 3; i++) {
        UIButton *btn = self.subviews[i];
        btnY = i * btnH;
        btn.frame = CGRectMake(0, btnY, btnW, btnH);
    }
}

+ (instancetype)floatWindow{
    return [[self alloc] init];
}

#pragma mark - 
- (void)refresh{
    if ([self.delegate respondsToSelector:@selector(floatWindowDidClickRefreshButton:)]){
        [_delegate floatWindowDidClickRefreshButton:self];
    }
}

- (void)upToTop{
    if ([self.delegate respondsToSelector:@selector(floatWindowDidClickUpToTopButton:)]){
        [_delegate floatWindowDidClickUpToTopButton:self];
    }
}

- (void)downToBottom{
    if ([self.delegate respondsToSelector:@selector(floatWindowDidClickDownToBottomButton:)]){
        [_delegate floatWindowDidClickDownToBottomButton:self];
    }
}

@end
