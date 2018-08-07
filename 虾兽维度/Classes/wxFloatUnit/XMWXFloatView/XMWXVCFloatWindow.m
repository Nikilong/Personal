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
            startF = CGRectMake(saveF.origin.x, saveF.origin.y, viewWH, viewWH);
        }else{
            startF = CGRectMake(XMScreenW - viewWH - padding, 200, viewWH, viewWH);
        }
        wxVCFloatWindow = [[XMWXVCFloatWindow alloc] initWithFrame:startF];
        // 浮窗插入到扇形区域的上面
        if([XMRightBottomFloatView shareRightBottomFloatView]){
            [[UIApplication sharedApplication].windows[0] insertSubview:wxVCFloatWindow aboveSubview:[XMRightBottomFloatView shareRightBottomFloatView]];
        }else{
            [[UIApplication sharedApplication].windows[0] addSubview:wxVCFloatWindow];
        }
        wxVCFloatWindow.layer.cornerRadius = viewWH * 0.5;
        wxVCFloatWindow.layer.masksToBounds = YES;
        wxVCFloatWindow.hidden = YES;
        wxVCFloatWindow.backgroundColor = [UIColor grayColor];
        // 初始化成员变量
        wxVCFloatWindow.recordFlag = YES;
        wxVCFloatWindow.preFrame = startF;
        // 设置透明度
        wxVCFloatWindow.alpha = 0.7;
        
        // 子控件
        CGFloat btnWH = viewWH - padding;
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(padding * 0.5, padding * 0.5,btnWH, btnWH)];
        wxVCFloatWindow.coverBtn = btn;
        btn.layer.cornerRadius = btnWH * 0.5;
        btn.layer.masksToBounds = YES;
        [wxVCFloatWindow addSubview:btn];
        btn.backgroundColor = [UIColor whiteColor];
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [btn addTarget:wxVCFloatWindow action:@selector(openFloatViewController:) forControlEvents:UIControlEventTouchUpInside];
        
        // 从缓存中恢复图片或标题
        [XMWXFloatWindowIconConfig setBackupImageOrTitlt:btn];
        
        // 添加手势
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:wxVCFloatWindow action:@selector(pan:)];
        [wxVCFloatWindow addGestureRecognizer:pan];
        
        /**block函数**/
        // 完成添加
        wxVCFloatWindow.wxFloatWindowDidAddBlock = ^(){
            dispatch_async(dispatch_get_main_queue(), ^{
                // 显示浮窗
                [XMWXVCFloatWindow shareXMWXVCFloatWindow].hidden = NO;
                
                AppDelegate *dele = (AppDelegate *)[UIApplication sharedApplication].delegate;
//                // 将当前页面保存到appdelegate
//                XMNavigationController *rootVC = (XMNavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
////                UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
//                dele.floadVC = [rootVC.childViewControllers lastObject];
                
                // 设置封面或标题
                [XMWXFloatWindowIconConfig setIconAndTitleByViewController:dele.floadVC button:[XMWXVCFloatWindow shareXMWXVCFloatWindow].coverBtn];
//                // 将当前页面pop掉
//                [rootVC popViewControllerAnimated:NO];
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
//                [UIView animateWithDuration:0.25 animations:^{
//                    dele.floadVC.view.frame =CGRectMake(0, 0, XMScreenW, XMScreenH);
//                }];
            }
        });
    }
}


/// 平移手势
- (void)pan:(UIPanGestureRecognizer *)pan{
    
    if(pan.state == UIGestureRecognizerStateChanged){
        // 跟随手指移动
        CGPoint point = [pan translationInView:[UIApplication sharedApplication].windows[0]];
        
        // 控制浮窗和顶部(20)和底部(20)的边距
        if((self.frame.origin.y > XMScreenH - viewWH - 20 && point.y >0) || (self.frame.origin.y < 20  && point.y < 0)){
            point.y = 0;
        }
        self.transform = CGAffineTransformTranslate(self.transform, point.x, point.y);
        [pan setTranslation:CGPointZero inView:[UIApplication sharedApplication].windows[0]];
        
        // 通知左下角窗口联动
        CGPoint abPoint = [pan locationInView:[UIApplication sharedApplication].windows[0]];
        [XMRightBottomFloatView shareRightBottomFloatView].rightBottomChangeBlock(abPoint);
        
    }else if (pan.state == UIGestureRecognizerStateBegan){
        // 恢复透明度为1
        self.alpha = 1;
        // 通知左下角窗口联动
        [XMRightBottomFloatView shareRightBottomFloatView].rightBottomStartBlock(NO);
        
    }else if (pan.state == UIGestureRecognizerStateEnded){
        
        // 通知左下角窗口联动
        [XMRightBottomFloatView shareRightBottomFloatView].rightBottomEndBlock();
        
        // 吸附在屏幕边沿
        CGRect tarF = self.frame;
        if (tarF.origin.x < XMScreenW * 0.5){
            tarF.origin.x = padding;
        }else{
            tarF.origin.x = XMScreenW - padding - viewWH;
        }
        // 添加动画
        [UIView animateWithDuration:0.25f animations:^{
            self.frame = tarF;
            self.alpha = 0.7;
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
