//
//  XMDropView.m
//  伪博
//
//  Created by Niki on 17/3/9.
//  Copyright © 2017年 Niki. All rights reserved.
//

#import "XMDropView.h"
#import "UIView+Extension.h"

@interface XMDropView()

@property (weak, nonatomic)  UIImageView *container;

@end

@implementation XMDropView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
    
        // 设置container，根据图片限定宽度为217（没有内容时），并添加到XMDropView对象，必须在这里创建container，否则后面要用到container时可能container还没有被创建
        UIImageView *container = [[UIImageView alloc] init];
        container.userInteractionEnabled = YES;
        container.image = [UIImage imageNamed:@"popover_background"];
        container.width = 150;
        container.height = 150;
        self.container = container;
        [self addSubview:container];
    }
    return self;
    
}

-(void)setContentController:(UIViewController *)contentController{
    _contentController = contentController;
    self.content = _contentController.view;
}

- (void)setContent:(UIView *)content{
    _content = content;
    // 设置content内容居中
    CGFloat padding = 10;
    CGFloat maxWidth = self.container.width - 2 * padding;
    
    if (_content.width <= maxWidth){
        _content.x = (self.container.width - _content.width) * 0.5;
    }else{
        _content.x = padding;
        _content.width = maxWidth;
    }
    _content.y = 15;
    // 根据content设置container的高度
    self.container.height = content.height + 30;
    
    [self.container addSubview:_content];
}

+ (instancetype)dropView{
    return [[self alloc] init];
}

- (void)showFrom:(UIView *)view{
    // 1，获得当前的窗口
//    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;

    // 2，设置XMDropView对象的尺寸，消除背景颜色
    self.backgroundColor = [UIColor clearColor];
    [window addSubview:self];
    self.frame = window.bounds;
    
    // 3，转换坐标系，使XMDropView对象显示在按钮的正下方
    CGRect frame = [view convertRect:view.bounds toView:window];
    
    self.container.centerX = CGRectGetMidX(frame);
    self.container.y = CGRectGetMaxY(frame);
    
    // 4，通知代理，XMDropView对象显示完成
    if ([self.delegate respondsToSelector:@selector(dropViewDidShow:)]){
        [_delegate dropViewDidShow:self];
    }

}

- (void)dismiss{
    [self removeFromSuperview];

    // 通知代理，XMDropView对象已消失
    if ([self.delegate respondsToSelector:@selector(dropViewDidDismiss:)]){
        [_delegate dropViewDidDismiss:self];
    }
}


/** 移除XMDropView对象的实现由XMDropView对象自己控制 */
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self dismiss];
}


- (void)layoutSubviews{
    [super layoutSubviews];
}

@end
