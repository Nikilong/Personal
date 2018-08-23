//
//  XMWXVCFloatWindow.m
//  虾兽维度
//
//  Created by Niki on 2018/7/17.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMWXVCFloatWindow.h"
#import "XMRightBottomFloatView.h"

#import "AppDelegate.h"
#import "XMNavigationController.h"

#import "MBProgressHUD+NK.h"
#import "XMWXFloatWindowIconConfig.h"

@interface XMWXVCFloatWindow()

@property (weak, nonatomic)  UIButton *coverBtn;
@property (weak, nonatomic)  UIImageView *leftImgV;
@property (weak, nonatomic)  UIImageView *rightImgV;

@end

@implementation XMWXVCFloatWindow

static double viewWH = 60.f;
static double padding = 10.0f;


+ (XMWXVCFloatWindow *)shareXMWXVCFloatWindow{
    static XMWXVCFloatWindow *wxVCFloatWindow = nil;
    static dispatch_once_t wxVCFloatWindowToken;
    dispatch_once(&wxVCFloatWindowToken, ^{
        CGRect startF;
        // 根据用户偏好设置保存的位置初始化浮窗位置
        NSString *saveFrameStr = [[NSUserDefaults standardUserDefaults] valueForKey:wxfloatFrameStringKey];
        if(saveFrameStr.length > 0){
            CGRect saveF = CGRectFromString(saveFrameStr);
//            startF = CGRectMake(saveF.origin.x, saveF.origin.y, viewWH * 2, viewWH);
            if(CGRectGetMidX(saveF) < 0.5 * XMScreenW){
            
                startF = CGRectMake(-1.5 * viewWH, saveF.origin.y, viewWH * 2, viewWH);
            }else{
                 startF = CGRectMake(XMScreenW -0.5 * viewWH, saveF.origin.y, viewWH * 2, viewWH);
            }
        }else{
            startF = CGRectMake(XMScreenW - 1.5 * viewWH - padding, 200, viewWH  * 2, viewWH);
        }
        wxVCFloatWindow = [[XMWXVCFloatWindow alloc] initWithFrame:startF];
        UIView *middleV = [[UIView alloc] initWithFrame:CGRectMake(viewWH * 0.5, 0, viewWH, viewWH)];
        [wxVCFloatWindow addSubview:middleV];
        // 浮窗插入到扇形区域的上面
        if([XMRightBottomFloatView shareRightBottomFloatView]){
            [[UIApplication sharedApplication].windows[0] insertSubview:wxVCFloatWindow aboveSubview:[XMRightBottomFloatView shareRightBottomFloatView]];
        }else{
            [[UIApplication sharedApplication].windows[0] addSubview:wxVCFloatWindow];
        }
        middleV.layer.cornerRadius = viewWH * 0.5;
        middleV.layer.masksToBounds = YES;
        middleV.backgroundColor = [UIColor grayColor];
        wxVCFloatWindow.hidden = YES;
        
        // 初始化成员变量
        wxVCFloatWindow.recordFlag = YES;
        wxVCFloatWindow.preFrame = startF;
        // 设置透明度
//        wxVCFloatWindow.alpha = 0.7;
        
        // 子控件
        UIImageView *leftImgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, viewWH * 0.5, viewWH)];
        leftImgV.image = [UIImage imageNamed:@"float_icon_hide_right"];
        leftImgV.hidden = YES;
        wxVCFloatWindow.leftImgV = leftImgV;
        [wxVCFloatWindow addSubview:leftImgV];
        
        UIImageView *rightImgV = [[UIImageView alloc] initWithFrame:CGRectMake( viewWH * 1.5, 0, viewWH * 0.5, viewWH)];
        rightImgV.image = [UIImage imageNamed:@"float_icon_hide_left"];
        rightImgV.hidden = YES;
        wxVCFloatWindow.rightImgV = rightImgV;
        [wxVCFloatWindow addSubview:rightImgV];
        
        
//        CGFloat btnWH = viewWH;
        CGFloat btnWH = viewWH - padding;
//        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(padding * 0.5 + viewWH * 0.5, padding * 0.5,btnWH, btnWH)];
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(padding * 0.5,  padding * 0.5,btnWH, btnWH)];
        wxVCFloatWindow.coverBtn = btn;
        btn.layer.cornerRadius = btnWH * 0.5;
        btn.layer.masksToBounds = YES;
//        [wxVCFloatWindow addSubview:btn];
        [middleV addSubview:btn];
        btn.backgroundColor = [UIColor whiteColor];
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [btn addTarget:wxVCFloatWindow action:@selector(openFloatViewController:) forControlEvents:UIControlEventTouchUpInside];
        
        // 从缓存中恢复图片或标题
        [XMWXFloatWindowIconConfig setBackupImageOrTitlt:btn];
        
        // 添加手势
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:wxVCFloatWindow action:@selector(pan:)];
        [middleV addGestureRecognizer:pan];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:wxVCFloatWindow action:@selector(tap:)];
        [wxVCFloatWindow addGestureRecognizer:tap];
        
//        [tap requireGestureRecognizerToFail:pan];
        
        // 手动触发一下点击
        [wxVCFloatWindow tap:nil];

        
        /**block函数**/
        // 完成添加
        wxVCFloatWindow.wxFloatWindowDidAddBlock = ^(){
            dispatch_async(dispatch_get_main_queue(), ^{
                // 显示浮窗
                [XMWXVCFloatWindow shareXMWXVCFloatWindow].hidden = NO;
                
                //
                [[XMWXVCFloatWindow shareXMWXVCFloatWindow] tap:nil];
                
                AppDelegate *dele = (AppDelegate *)[UIApplication sharedApplication].delegate;
                
                // 设置封面或标题
                [XMWXFloatWindowIconConfig setIconAndTitleByViewController:dele.floadVC button:[XMWXVCFloatWindow shareXMWXVCFloatWindow].coverBtn];
            });
        };
        // 完成移除
        wxVCFloatWindow.wxFloatWindowDidRemoveBlock = ^(){
            [XMWXVCFloatWindow shareXMWXVCFloatWindow].hidden = YES;
            [XMWXVCFloatWindow shareXMWXVCFloatWindow].frame = [XMWXVCFloatWindow shareXMWXVCFloatWindow].preFrame;
            
            // 移除浮窗归档的数据
            [XMWXFloatWindowIconConfig removeBackupData];
            
        };
        // 即将移除
        wxVCFloatWindow.wxFloatWindowWillRemoveBlock = ^(){
            // 进入了扇形区域不需要记录
            [XMWXVCFloatWindow shareXMWXVCFloatWindow].recordFlag = NO;
        };
        // 取消移除
        wxVCFloatWindow.wxFloatWindowCancelRemoveBlock = ^(){
            // 扇形区域之外需要记录位置
            [XMWXVCFloatWindow shareXMWXVCFloatWindow].recordFlag = YES;
        };
    });
    return wxVCFloatWindow;
}

// 点击事件
- (void)openFloatViewController:(UIButton *)btn{
    // push保存的页面
    AppDelegate *dele = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if([[UIApplication sharedApplication].keyWindow.rootViewController isKindOfClass:[XMNavigationController class]]){
        dispatch_async(dispatch_get_main_queue(), ^{
            XMNavigationController *nav = (XMNavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
            if ([nav.childViewControllers.lastObject isEqual:dele.floadVC]){
                [MBProgressHUD showFailed:@"当前浮窗已显示"];
            }else{
                [nav pushViewController:dele.floadVC animated:YES];
            }
        });
    }
}

/// 点击手势
- (void)tap:(UITapGestureRecognizer *)tap{
    self.leftImgV.hidden = YES;
    self.rightImgV.hidden = YES;
    NSLog(@"%s",__func__);
    BOOL isLeft = self.frame.origin.x < 0;
    // 先伸出来,然后全部缩回去,再把imgv探出来,所以需要三个距离,嵌套三个动画
    CGFloat showDistance = viewWH + padding;
    CGFloat hideDistance = viewWH * 1.5 + padding;
    CGFloat bounceDistance = viewWH * 0.5;
    // 从屏幕左边或者右边伸出来
    [UIView animateWithDuration:0.5f animations:^{
        self.frame = CGRectMake(self.frame.origin.x + (isLeft ? showDistance : -showDistance), self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    }completion:^(BOOL finished) {
        // 3s之后缩回去
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.5f animations:^{
                self.frame = CGRectMake(self.frame.origin.x - (isLeft ? hideDistance : -hideDistance), self.frame.origin.y, self.frame.size.width, self.frame.size.height);
            }completion:^(BOOL finished) {
                self.leftImgV.hidden = isLeft;
                self.rightImgV.hidden = !isLeft;
                NSLog(@"(9090)%s",__func__);
                // 然后再探头出来
                [UIView animateWithDuration:2.0f animations:^{
                    self.frame = CGRectMake(self.frame.origin.x + (isLeft ? bounceDistance : -bounceDistance), self.frame.origin.y, self.frame.size.width, self.frame.size.height);
                }];
            }];
        });
    }];
}

/// 平移手势
- (void)pan:(UIPanGestureRecognizer *)pan{
    
    if(pan.state == UIGestureRecognizerStateChanged){
        // 跟随手指移动
//        CGPoint point = [pan translationInView:[UIApplication sharedApplication].windows[0]];
        CGPoint abPoint = [pan locationInView:[UIApplication sharedApplication].windows[0]];
        
        // 控制浮窗和顶部(20)和底部(20)的边距
//        if((self.frame.origin.y > XMScreenH - viewWH - 20 && point.y >0) || (self.frame.origin.y < 20  && point.y < 0)){
//            point.y = 0;
//        }
//        self.transform = CGAffineTransformTranslate(self.transform, point.x, point.y);
//        [pan setTranslation:CGPointZero inView:[UIApplication sharedApplication].windows[0]];
        self.frame = CGRectMake(abPoint.x - viewWH, abPoint.y - 0.5 * viewWH, 2 * viewWH, viewWH);
        
        // 通知左下角窗口联动
        [XMRightBottomFloatView shareRightBottomFloatView].rightBottomChangeBlock(abPoint);
        
    }else if (pan.state == UIGestureRecognizerStateBegan){
        // 通知左下角窗口联动
        [XMRightBottomFloatView shareRightBottomFloatView].rightBottomStartBlock(NO);
        
    }else if (pan.state == UIGestureRecognizerStateEnded){
        
        // 通知左下角窗口联动
        [XMRightBottomFloatView shareRightBottomFloatView].rightBottomEndBlock();
        
        // 吸附在屏幕边沿
        CGRect tarF = self.frame;
        BOOL isLeft = CGRectGetMidX(tarF) < XMScreenW * 0.5;
        if (isLeft){
//            tarF.origin.x = padding;
            tarF.origin.x = -0.5 * viewWH + padding;
        }else{
//            tarF.origin.x = XMScreenW - padding - viewWH;
            tarF.origin.x = XMScreenW - 1.5 * viewWH - padding;
        }
        // 添加动画
        [UIView animateWithDuration:0.25f animations:^{
            self.frame = tarF;
        }completion:^(BOOL finished) {
//            self.leftImgV.hidden = isLeft;
//            self.rightImgV.hidden = !isLeft;
            CGFloat hideDistance = viewWH * 1.5 + padding;
            CGFloat bounceDistance = viewWH * 0.5;
            // 3s之后缩回去
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.5f animations:^{
                    self.frame = CGRectMake(self.frame.origin.x - (isLeft ? hideDistance : -hideDistance), self.frame.origin.y, self.frame.size.width, self.frame.size.height);
                }completion:^(BOOL finished) {
                    self.leftImgV.hidden = isLeft;
                    self.rightImgV.hidden = !isLeft;
                    NSLog(@"(1)()%s",__func__);
                    // 然后再探头出来
                    [UIView animateWithDuration:2.0f animations:^{
                        self.frame = CGRectMake(self.frame.origin.x + (isLeft ? bounceDistance : -bounceDistance), self.frame.origin.y, self.frame.size.width, self.frame.size.height);
                    }];
                }];
            });
        }];
        // 判断是否需要记录前一个位置,默认一直记录,当拖到扇形区域才不需要记录
        if(self.recordFlag){
            self.preFrame = tarF;
            NSString *frameStr = NSStringFromCGRect(tarF);
            [[NSUserDefaults standardUserDefaults] setValue:frameStr forKey:wxfloatFrameStringKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
    }
}

@end
