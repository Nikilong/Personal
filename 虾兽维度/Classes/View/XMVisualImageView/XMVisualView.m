//
//  XMVisualView.m
//  虾兽维度
//
//  Created by Niki on 18/8/19.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMVisualView.h"
#import "UIImageView+WebCache.h"
#import "XMImageUtil.h"

@interface XMVisualView()

@property (weak, nonatomic)  UIView *btnV;
@property (weak, nonatomic)  UIImageView *mainImgV;

@end

@implementation XMVisualView

/// 传入图片的URL,创建一个毛玻璃大图
+ (XMVisualView *)creatVisualImageViewWithImage:(id)image{
    
    return [self creatVisualImageViewWithImage:image imageSize:CGSizeZero blurEffectStyle:-1];
}

/// 传入图片的URL,创建一个毛玻璃大图
+ (XMVisualView *)creatVisualImageViewWithImage:(id)image imageSize:(CGSize)size blurEffectStyle:(UIBlurEffectStyle)blurStyle{
    
    XMVisualView *visualV = [[XMVisualView alloc] initWithFrame:CGRectMake(0, 0, XMScreenW, XMScreenH)];
    
    // 1.底部背景图片区域
    UIImageView *backgroundImgV = [[UIImageView alloc] initWithFrame:visualV.bounds];
    backgroundImgV.userInteractionEnabled = YES;
    [visualV addSubview:backgroundImgV];
    
    // 2.毛玻璃
    UIBlurEffect *blur;
    // 设置毛玻璃效果样式
    if(blurStyle >= 0){
        blur = [UIBlurEffect effectWithStyle:blurStyle];
    }else{
        blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    }
    UIVisualEffectView *effV = [[UIVisualEffectView alloc] initWithEffect:blur];
    effV.frame = visualV.bounds;
    
    // 3.相框
    // 设置主体图片大小
    CGRect mainImgVF;
    if(size.width > 0){
        mainImgVF = CGRectMake((XMScreenW - size.width) * 0.5, (XMScreenH - size.height) * 0.5, size.width, size.height);
    }else{
        mainImgVF = visualV.bounds;
    }
    UIImageView *mainImgV = [[UIImageView alloc] initWithFrame:mainImgVF];
    visualV.mainImgV = mainImgV;
    mainImgV.userInteractionEnabled = YES;
    mainImgV.contentMode = UIViewContentModeScaleAspectFit;
    
    // 4.底部保存图片按钮组
    UIView *btnV = [[UIView alloc] initWithFrame:CGRectMake(0, XMScreenH, XMScreenW, 88)];
    visualV.btnV = btnV;
    btnV.backgroundColor = [UIColor clearColor];
    btnV.hidden = YES;
    UIButton *saveToALbumBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, XMScreenW, 44)];
    saveToALbumBtn.tag = 0;
    saveToALbumBtn.backgroundColor = [UIColor lightGrayColor];
    [saveToALbumBtn addTarget:visualV action:@selector(saveBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [saveToALbumBtn setTitle:@"保存图片到系统相册" forState:UIControlStateNormal];
    [saveToALbumBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnV addSubview:saveToALbumBtn];
    
    UIView *lineV = [[UIView alloc] initWithFrame:CGRectMake(15, 44, XMScreenW - 30, 1)];
    lineV.backgroundColor = [UIColor whiteColor];
    [btnV addSubview:lineV];
    
    UIButton *saveToLocalBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 44, XMScreenW, 44)];
    saveToLocalBtn.tag = 1;
    saveToLocalBtn.backgroundColor = [UIColor lightGrayColor];
    [saveToLocalBtn addTarget:visualV action:@selector(saveBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [saveToLocalBtn setTitle:@"保存图片到本地缓存" forState:UIControlStateNormal];
    [saveToLocalBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnV addSubview:saveToLocalBtn];
    
    // 5.主窗口
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    // 依次添加视图
    [window addSubview:visualV];
    [visualV addSubview:effV];
    [effV.contentView addSubview:mainImgV];
    [effV.contentView addSubview:btnV];
    
    // 6.设置图片
    if([image isKindOfClass:[NSURL class]]){
        [mainImgV sd_setImageWithURL:image];
        [backgroundImgV sd_setImageWithURL:image];
    }else if([image isKindOfClass:[UIImage class]]){
        mainImgV.image = image;
        backgroundImgV.image = image;
    }
    
    // 7.手势类
    // 添加点击移除手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:visualV action:@selector(removeBigImage:)];
    [visualV addGestureRecognizer:tap];
    // 添加长按图片操作手势
    UILongPressGestureRecognizer *longP = [[UILongPressGestureRecognizer alloc] initWithTarget:visualV action:@selector(mainImageViewDidLongPress:)];
    [mainImgV addGestureRecognizer:longP];
    
    return visualV;
}

#pragma mark - 手势及点击方法
/// 取消大图
- (void)removeBigImage:(UITapGestureRecognizer *)tap{
    // 通知代理完成移除操作
    if([self.delegate respondsToSelector:@selector(visualViewWillRemoveFromSuperView)]){
        [self.delegate visualViewWillRemoveFromSuperView];
    }
    
    [tap.view removeFromSuperview];
}

/// 长按图片
- (void)mainImageViewDidLongPress:(UILongPressGestureRecognizer *)gest{
    if (gest.state == UIGestureRecognizerStateBegan){
        // 弹出按钮组
        self.btnV.hidden = NO;
        [UIView animateWithDuration:0.25f animations:^{
            self.btnV.transform = CGAffineTransformMakeTranslation(0, -88);
        }];
    }
}


/// 保存按钮点击事件
- (void)saveBtnDidClick:(UIButton *)btn{
    if(btn.tag == 0){
        // 保存到相册
        [XMImageUtil saveToAlbumWithImage:self.mainImgV.image];
    }else if (btn.tag == 1){
        // 保存到沙盒
        [XMImageUtil saveToLocalTempDirWithImage:self.mainImgV.image];
    }
}


@end
