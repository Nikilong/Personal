//
//  XMProgressView.m
//  虾兽维度
//
//  Created by Niki on 2018/10/11.
//  Copyright © 2018年 excellence.com.cn. All rights reserved.
//

#import "XMProgressView.h"

@interface XMProgressView()

@property (weak, nonatomic)  UILabel *progressLab;              // 旋转动画
@property (weak, nonatomic)  UIActivityIndicatorView *actV;     // 进度条
@property (nonatomic, assign)  BOOL animating;


@end

@implementation XMProgressView

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        self.animating = NO;
    }
    return self;
}

+ (XMProgressView *)createProgressViewWithCenter:(CGPoint)center{
    // 因为UIActivityIndicatorViewStyleWhiteLarge时,指示动画是一个37 * 37的view,只能通过transform来放大,但是这是虚的,实际上frame并没有变大
    XMProgressView *progressV = [[XMProgressView alloc] initWithFrame:CGRectMake(center.x - 38.5, center.y - 37, 77, 74)];
    progressV.hidden = YES;
    
    // 指示在上面
    UIActivityIndicatorView *actV = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    actV.center = CGPointMake(38.5, 18.5);
    actV.transform = CGAffineTransformMakeScale(2.4, 2.4);
    progressV.actV = actV;
    [progressV addSubview:actV];
    [actV startAnimating];
    
    // 进度数字在中间
    UILabel *progressLab = [[UILabel alloc] init];
    progressV.progressLab = progressLab;
    progressLab.text = @"0%";
    progressLab.frame = CGRectMake(0, 0, 77, 37);
    progressLab.textAlignment = NSTextAlignmentCenter;
    progressLab.textColor = [UIColor whiteColor];
    progressLab.font = [UIFont systemFontOfSize:11];
    [progressV addSubview:progressLab];
    return progressV;
}

- (BOOL)isAnimate{
    return self.animating;
}

- (void)startAnimating{
    if(!self.animating){
        self.animating = YES;
        self.hidden = NO;
        [self.actV startAnimating];
    }else{
        self.progressLab.text = @"0%";
    }
    
}

- (void)stopAnimating{
    self.progressLab.text = @"100%";
    self.animating = NO;
    self.hidden = YES;
    [self.actV stopAnimating];
    self.progressLab.text = @"0%";
}

- (void)updateProgress:(float)progress{
    self.progressLab.text = [NSString stringWithFormat:@"%d%%",(int)(progress * 100)];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
