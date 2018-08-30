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

/// 下面两个参数用于决定动画的执行,因为一整个动画耗时较长,中间可能会发生pan手势,pan时需要停掉动画,动画还在进行也不能重复动画
@property (nonatomic, assign)  BOOL isPan;      // 是否在拖拽
@property (nonatomic, assign)  BOOL isAnimate;  // 是否正在动画


@end

@implementation XMWXVCFloatWindow

static double viewWH = 60.f;
static double padding = 10.0f;


+ (XMWXVCFloatWindow *)shareXMWXVCFloatWindow{
    static XMWXVCFloatWindow *wxVCFloatWindow = nil;
    static dispatch_once_t wxVCFloatWindowToken;
    dispatch_once(&wxVCFloatWindowToken, ^{
        CGRect startF;
        // 根据用户偏好设置保存的位置初始化浮窗位置,记录位置btn距离屏幕边沿padding的距离
        NSString *saveFrameStr = [[NSUserDefaults standardUserDefaults] valueForKey:wxfloatFrameStringKey];
        if(saveFrameStr.length > 0){
            startF = CGRectFromString(saveFrameStr);
        }else{
            startF = CGRectMake(XMScreenW - 0.5 * viewWH, 200, viewWH  * 2, viewWH);
        }
        wxVCFloatWindow = [[XMWXVCFloatWindow alloc] initWithFrame:startF];
        
        // 浮窗插入到扇形区域的上面
        if([XMRightBottomFloatView shareRightBottomFloatView]){
            [[UIApplication sharedApplication].windows[0] insertSubview:wxVCFloatWindow aboveSubview:[XMRightBottomFloatView shareRightBottomFloatView]];
        }else{
            [[UIApplication sharedApplication].windows[0] addSubview:wxVCFloatWindow];
        }
        
        // 初始化成员变量
        wxVCFloatWindow.hidden = YES;
        wxVCFloatWindow.recordFlag = YES;
        wxVCFloatWindow.preFrame = startF;
        
        // 子控件
        // 1.左侧图片
        UIImageView *leftImgV = [[UIImageView alloc] initWithFrame:CGRectMake(viewWH * 0.15, 0, viewWH * 0.35, viewWH * 0.7)];
        leftImgV.image = [UIImage imageNamed:@"float_icon_hide_right"];
        leftImgV.hidden = YES;
        wxVCFloatWindow.leftImgV = leftImgV;
        [wxVCFloatWindow addSubview:leftImgV];
        // 2.右侧图片
        UIImageView *rightImgV = [[UIImageView alloc] initWithFrame:CGRectMake( viewWH * 1.5, 0, viewWH * 0.35, viewWH * 0.7)];
        rightImgV.image = [UIImage imageNamed:@"float_icon_hide_left"];
        rightImgV.hidden = YES;
        wxVCFloatWindow.rightImgV = rightImgV;
        [wxVCFloatWindow addSubview:rightImgV];
        
        // 3.中间模块
        // 3.1中间按钮背景
        UIView *middleV = [[UIView alloc] initWithFrame:CGRectMake(viewWH * 0.5, 0, viewWH, viewWH)];
        [wxVCFloatWindow addSubview:middleV];
        middleV.layer.cornerRadius = viewWH * 0.5;
        middleV.layer.masksToBounds = YES;
        middleV.backgroundColor = [UIColor grayColor];
        // 3.2中间按钮
        CGFloat btnWH = viewWH - padding;
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(padding * 0.5,  padding * 0.5,btnWH, btnWH)];
        wxVCFloatWindow.coverBtn = btn;
        btn.layer.cornerRadius = btnWH * 0.5;
        btn.layer.masksToBounds = YES;
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
        
        // 手动触发一下点击
        [wxVCFloatWindow showFlowWindowAnimate];
        
        /**block函数**/
        // 完成添加
        wxVCFloatWindow.wxFloatWindowDidAddBlock = ^(){
            dispatch_async(dispatch_get_main_queue(), ^{
                // 显示浮窗
                [XMWXVCFloatWindow shareXMWXVCFloatWindow].hidden = NO;
                
                // 展示浮窗动画
                [[XMWXVCFloatWindow shareXMWXVCFloatWindow]  showFlowWindowAnimate];
                
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

/// 伸出动画
- (void)showFlowWindowAnimate{
    if(self.isPan || self.isAnimate) return;
    
    self.leftImgV.hidden = YES;
    self.rightImgV.hidden = YES;

    BOOL isLeft = CGRectGetMidX(self.frame) < XMScreenW * 0.5;
    CGFloat finalX = isLeft ? (-0.5 * viewWH + padding) : (XMScreenW - 1.5 * viewWH - padding);
    self.isAnimate = YES;
    // 从屏幕左边或者右边伸出来
    [UIView animateWithDuration:0.5f animations:^{
        self.frame = CGRectMake(finalX, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    }completion:^(BOOL finished) {
        self.isAnimate = NO;
        if(!self.isPan && finished) {
            [self hideFlowWindowAnimate];
        }
    }];
    
    
}

/// 隐藏并探头动画
- (void)hideFlowWindowAnimate{
    if(self.isPan || self.isAnimate) return;
    // 3s之后缩回去
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        BOOL isLeft =CGRectGetMidX(self.frame) < XMScreenW * 0.5;
        // 先全部缩回去,再把imgv探出来
        CGFloat HideX = isLeft ? (-2 * viewWH)  : XMScreenW;
        if(self.isPan || self.isAnimate) return;
        self.isAnimate = YES;
        [UIView animateWithDuration:0.5f animations:^{
            self.frame = CGRectMake(HideX , self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        }completion:^(BOOL finished) {
            self.isAnimate = NO;
            if(self.isPan || self.isAnimate) return;
            if(finished){
                self.leftImgV.hidden = isLeft;
                self.rightImgV.hidden = !isLeft;
                BOOL isStillLeft =CGRectGetMidX(self.frame) < XMScreenW * 0.5;
                CGFloat finalX = isStillLeft ? (-1.5 * viewWH)  : (XMScreenW - viewWH * 0.5);
                self.isAnimate = YES;
                // 然后再探头出来
                [UIView animateWithDuration:2.0f animations:^{
                    self.frame = CGRectMake(finalX, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
                }completion:^(BOOL finished) {
                    self.isAnimate = NO;
                }];
            }
        }];
    });
    
}

/// 点击手势
- (void)tap:(UITapGestureRecognizer *)tap{
    [self showFlowWindowAnimate];
}

/// 平移手势
- (void)pan:(UIPanGestureRecognizer *)pan{
    
    if(pan.state == UIGestureRecognizerStateChanged){
        // 跟随手指(手指为btn的中心)移动
        CGPoint abPoint = [pan locationInView:[UIApplication sharedApplication].windows[0]];
        
        // 控制浮窗和顶部(40)和底部(20)的边距
        if(abPoint.y + 0.5 * viewWH > XMScreenH - 20 ){
            // 底部距离
            abPoint.y = XMScreenH - 0.5 * viewWH - 20;
        }else if(abPoint.y - 0.5 * viewWH < 40){
            // 顶部距离
            abPoint.y = 40 + 0.5 * viewWH;
        }
        self.frame = CGRectMake(abPoint.x - viewWH, abPoint.y - 0.5 * viewWH, 2 * viewWH, viewWH);
        
        // 通知左下角窗口联动
        [XMRightBottomFloatView shareRightBottomFloatView].rightBottomChangeBlock(abPoint);
        
    }else if (pan.state == UIGestureRecognizerStateBegan){
        self.isPan = YES;
        // 通知左下角窗口联动
        [XMRightBottomFloatView shareRightBottomFloatView].rightBottomStartBlock(NO);
        
    }else{
        self.isPan = NO;
        // 通知左下角窗口联动
        [XMRightBottomFloatView shareRightBottomFloatView].rightBottomEndBlock();
        
        // 吸附在屏幕边沿
        CGRect tarF = self.frame;
        BOOL isLeft = CGRectGetMidX(tarF) < XMScreenW * 0.5;
        if (isLeft){
            tarF.origin.x = -0.5 * viewWH + padding;
        }else{
            tarF.origin.x = XMScreenW - 1.5 * viewWH - padding;
        }
        // 添加动画
        [UIView animateWithDuration:0.25f animations:^{
            self.frame = tarF;
        }completion:^(BOOL finished) {
            
            // 判断是否需要记录前一个位置,默认一直记录,当拖到扇形区域才不需要记录
            if(self.recordFlag){
                self.preFrame = tarF;
                NSString *frameStr = NSStringFromCGRect(tarF);
                [[NSUserDefaults standardUserDefaults] setValue:frameStr forKey:wxfloatFrameStringKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            // 隐藏
            [self hideFlowWindowAnimate];
        }];
        
    }
}

@end
