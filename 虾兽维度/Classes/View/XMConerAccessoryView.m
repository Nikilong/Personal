//
//  XMConerAccessoryView.m
//  accessoryTool - test
//
//  Created by Niki on 17/3/30.
//  Copyright © 2017年 Niki. All rights reserved.
//

#import "XMConerAccessoryView.h"

CGFloat const XMPlanetStarAngle = 2.5;

static NSMutableArray *_btnArr;
static CGFloat _radius;
static CGFloat _btnWH;

@interface XMConerAccessoryView()

@property (weak, nonatomic)  UIView *cover;
@property (weak, nonatomic)  UIButton *centerBtn;

@end

@implementation XMConerAccessoryView

- (UIView *)cover{
    if (!_cover){
        UIView *cover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        cover.backgroundColor = [UIColor clearColor];
        [self.superview insertSubview:cover belowSubview:self];
        cover.hidden = YES;
        _cover = cover;
        
        // 为蒙板添加事件
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideCover:)];
        [cover addGestureRecognizer:tap];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self  action:@selector(hideCover:)];
        [cover addGestureRecognizer:pan];
    }
    return _cover;
}

+ (void)initialize{
    [super initialize];

    if (!_btnArr){
        _btnArr = [NSMutableArray array];
    }
}

+ (instancetype)conerAccessoryViewWithButtonWH:(CGFloat)btnWH radius:(CGFloat)radius imageArray:(NSArray *)backgroundImages borderWidth:(CGFloat)borderW tintColor:(UIColor *)tintColor{
    // 0,存储传递进来的两个参数方便self的布局
    _radius = radius;
    _btnWH = btnWH;
    
    // 1，计算总的frame
    CGRect frame = CGRectMake(0, 0, btnWH + radius, btnWH + radius);
    
    // 2，创建一个对象
    XMConerAccessoryView *contentView = [[XMConerAccessoryView alloc] initWithFrame:frame];
    contentView.backgroundColor = [UIColor clearColor];
    
    // 3，取出有行星按钮的个数
    NSUInteger count = backgroundImages.count;

    // 4，设置旋转中心
    CGPoint center = CGPointMake(0.5 * btnWH, frame.size.height - 0.5 * btnWH);
    
    CGRect btnBounds = CGRectMake(0, 0, btnWH, btnWH );
    
    // 5，创建行星按钮
    for (int i = 0; i < count; i ++) {
        // 创建行星按钮
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.hidden = YES;
        [contentView addSubview:btn];
        [_btnArr addObject:btn];
        
        // 设置旋转
        btn.bounds = btnBounds;
        btn.layer.anchorPoint = CGPointMake(0.5, 0.5 + radius * 1.0 / btnWH);
        btn.layer.position = center;
        btn.layer.transform = CATransform3DMakeRotation(XMPlanetStarAngle, 0, 0, 1);
        // 圆形裁剪图片和设置颜色
        [btn setBackgroundColor:[UIColor blueColor]];
        btn.layer.cornerRadius = 0.5 * btnWH;
        btn.layer.masksToBounds = YES;
        btn.layer.borderWidth = borderW;
        btn.layer.borderColor = tintColor.CGColor;
        
        // 绑定角标和添加监听
        [btn setImage:[UIImage imageNamed:backgroundImages[i]] forState:UIControlStateNormal];
        btn.tag = i + 1;
        [btn addTarget:contentView action:@selector(acceoryButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    // 6，中心太阳按钮
    UIButton *centerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    centerBtn.layer.anchorPoint = CGPointMake(0.5, 0.5);
    centerBtn.layer.position = center;
    centerBtn.bounds = btnBounds;
    [contentView addSubview:centerBtn];
    [centerBtn setImage:[UIImage imageNamed:@"tabbar_add_highlighted"] forState:UIControlStateNormal];
    [centerBtn addTarget:contentView action:@selector(acceoryCenterButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    
    // 圆形裁剪图片和设置颜色
    centerBtn.layer.cornerRadius = 0.5 * btnWH;
    centerBtn.layer.masksToBounds = YES;
    centerBtn.backgroundColor = tintColor;

    return contentView;
}


- (void)acceoryButtonDidClick:(UIButton *)btn{
    [self hideCover:nil];
    // 通知代理
    if ([self.delegate respondsToSelector:@selector(conerAccessoryViewDidClickPlantedButton:)]){
        [_delegate conerAccessoryViewDidClickPlantedButton:btn];
    }
}

- (void)acceoryCenterButtonDidClick:(UIButton *)centerBtn{
    // 取反中心按钮的选择状态
    centerBtn.selected = !centerBtn.selected;
    
    NSTimeInterval duration = 0.5;
    // 将中心按钮旋转45度
    CGFloat centerAngel = centerBtn.selected ? -45 * M_PI / 180 : 45 * M_PI / 180;
    [UIView animateWithDuration:duration animations:^{
        centerBtn.layer.transform = CATransform3DRotate(centerBtn.layer.transform, centerAngel, 0, 0, 1);
    }];
    
    // 将每个行星按钮的角度转为弧度
    CGFloat angle = 90.0 / (_btnArr.count - 1) * M_PI / 180.0;
    
    // 此时按钮已经被点击，状态为选中状态，应该将行星按钮旋转上去
    if (centerBtn.isSelected){
        for (int i = 0; i < _btnArr.count; i++){
            UIButton *btn = _btnArr[i];
            btn.hidden = NO;
            [UIView animateWithDuration:duration animations:^{
                btn.layer.transform = CATransform3DMakeRotation(angle * i, 0, 0, 1);
            }];
        }
        self.cover.hidden = NO;
        // 在此储存centerBtn以备用
        self.centerBtn = centerBtn;
        
    }else{
        // 按钮未被选中，星星按钮隐藏在屏幕下方
        for (int i = 0; i < _btnArr.count; i++){
            UIButton *btn = _btnArr[i];
            [UIView animateWithDuration:duration animations:^{
                btn.layer.transform = CATransform3DMakeRotation(XMPlanetStarAngle, 0, 0, 1);
            }completion:^(BOOL finished) {
                btn.hidden = YES;
            }];
        }
        self.cover.hidden = YES;
    }
    
}

- (void)hideCover:(UIGestureRecognizer *)gest{
    // 防止pan手势多次触发
    if (gest.state == UIGestureRecognizerStateEnded || gest == nil){
        self.cover.hidden = YES;
        [self acceoryCenterButtonDidClick:self.centerBtn];
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    // 设置self的位置位于左下角
    CGFloat padding = 10;
    CGFloat conWH = _radius + _btnWH;
    CGFloat conY = [UIScreen mainScreen].bounds.size.height - conWH - padding - ((isIphoneX) ? 34 : 0);
    self.frame = CGRectMake(padding, conY, conWH, conWH);

}

@end
