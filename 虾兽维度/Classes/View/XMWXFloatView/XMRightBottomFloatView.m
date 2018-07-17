//
//  XMRightBottomFloatView.m
//  虾兽维度
//
//  Created by Niki on 2018/7/17.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMRightBottomFloatView.h"
#import "XMWXVCFloatWindow.h"

#import "AppDelegate.h"

@interface XMRightBottomFloatView()

// 提示按钮
@property (weak, nonatomic)  UIButton *tipBtn;

@end


@implementation XMRightBottomFloatView

+ (XMRightBottomFloatView *)shareRightBottomFloatView{
    static XMRightBottomFloatView *rightBottomFloatView = nil;
    static dispatch_once_t rightBottomtoken;
    dispatch_once(&rightBottomtoken, ^{
        if (rightBottomFloatView == nil){
            CGFloat viewWH = XMScreenW * 0.8;
            rightBottomFloatView = [[XMRightBottomFloatView alloc] initWithFrame:CGRectMake(XMScreenW, XMScreenH, viewWH, viewWH)];
            rightBottomFloatView.layer.cornerRadius = viewWH * 0.5;
            rightBottomFloatView.layer.masksToBounds = YES;
            [[UIApplication sharedApplication].windows[0] addSubview:rightBottomFloatView];
            rightBottomFloatView.hidden = YES;
            rightBottomFloatView.addMode = YES;
            
            // 子控件
            UIButton *tipBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            rightBottomFloatView.tipBtn = tipBtn;
            tipBtn.hidden = YES;
            tipBtn.frame = CGRectMake(viewWH * 0.5 - 100, viewWH * 0.5 - 100, 100, 100);
            [rightBottomFloatView addSubview:tipBtn];
            
            // 手势的处理block
            rightBottomFloatView.rightBottomStartBlock = ^(BOOL isAddMode){
                rightBottomFloatView.hidden = NO;
                rightBottomFloatView.addMode = isAddMode;
                if (isAddMode){  // 增加视图是黑色背景
                    rightBottomFloatView.backgroundColor = RGB(48, 48, 48);
                    [rightBottomFloatView.tipBtn setImage:[UIImage imageNamed:@"Knob_OFF"] forState:UIControlStateNormal];
                }else{ // 删除视图是红色背景
                    rightBottomFloatView.backgroundColor = RGB(255, 83, 89);
                    [rightBottomFloatView.tipBtn setImage:[UIImage imageNamed:@"Knob_ON"] forState:UIControlStateNormal];
                }
            };
            rightBottomFloatView.rightBottomEndBlock = ^(){
                if (!rightBottomFloatView.tipBtn.isHidden){
                    if(rightBottomFloatView.addMode){
                        NSLog(@"()())()())save !!!!!!");
//                        [XMWXVCFloatWindow shareXMWXVCFloatWindow].wxFloatWindowDidAddBlock();
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [XMWXVCFloatWindow shareXMWXVCFloatWindow].hidden = NO;
                            //
                            AppDelegate *dele = (AppDelegate *)[UIApplication sharedApplication].delegate;
                            UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
                            
                            dele.floadVC = [rootVC.childViewControllers lastObject];
                        });

                    }else{
                        NSLog(@"()())()())delete !!!!!!");
                        [XMWXVCFloatWindow shareXMWXVCFloatWindow].wxFloatWindowDidRemoveBlock();
                    }
                }
                rightBottomFloatView.hidden = YES;
                rightBottomFloatView.frame = CGRectMake(XMScreenW, XMScreenH, viewWH, viewWH);
            };
            
            // 添加是触发的x距离
            CGFloat startX = 100.f;
            rightBottomFloatView.rightBottomChangeBlock = ^(CGPoint point){
//                NSLog(@"--%.2f",point.x);
                if (rightBottomFloatView.addMode){ // 添加触发
                    if (point.x > startX){
                        // 伸出或缩进
                        if (rightBottomFloatView.frame.origin.x > XMScreenW - viewWH * 0.5){
                            CGFloat vX = XMScreenW - ( point.x - startX );
                            CGFloat vY = XMScreenH - ( point.x - startX );
                            rightBottomFloatView.frame = CGRectMake(vX, vY, viewWH, viewWH);
                            
                        }else{
                            // 防止伸出最大化时左划卡死不缩小,收缩1个单位
                            if ( point.x < XMScreenW - viewWH * 0.5){
                                rightBottomFloatView.frame = CGRectMake(XMScreenW - viewWH * 0.5 + 1, XMScreenH - viewWH * 0.5 + 1, viewWH, viewWH);
                            }
                        }
                    }
                }else{  // 移除触发
                    CGFloat distance = sqrt(pow(([XMWXVCFloatWindow shareXMWXVCFloatWindow].preFrame.origin.x - point.x),2) + pow(([XMWXVCFloatWindow shareXMWXVCFloatWindow].preFrame.origin.y - point.y),2));
                    // 伸出或缩进,根据与一开始的位置的距离来决定
                    if (distance <= viewWH * 0.5){
                        rightBottomFloatView.frame = CGRectMake(XMScreenW - distance, XMScreenH - distance, viewWH, viewWH);
                    }else{
                        rightBottomFloatView.frame = CGRectMake(XMScreenW - viewWH * 0.5, XMScreenH - viewWH * 0.5, viewWH, viewWH);
                    }
                }
                
                // 根据当前触点的位置判断是否进入了扇形区域
                if(pow((XMScreenW - point.x),2) + pow((XMScreenH - point.y),2) <= pow((XMScreenW - CGRectGetMaxX(rightBottomFloatView.frame)),2)){
                    // 只有首次显示tipBtn的时候才需要震动+显示,防止重复震动
                    if (rightBottomFloatView.tipBtn.isHidden){
                        rightBottomFloatView.tipBtn.hidden = NO;
                        // 震动提醒
                        UIImpactFeedbackGenerator *feed = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
                        [feed impactOccurred];
                        // 通知浮窗
                        [XMWXVCFloatWindow shareXMWXVCFloatWindow].wxFloatWindowWillRemoveBlock();
                    }
                    
                }else if(pow((XMScreenW - point.x),2) + pow((XMScreenH - point.y),2) > pow((XMScreenW - CGRectGetMaxX(rightBottomFloatView.frame)),2)){
                    rightBottomFloatView.tipBtn.hidden = YES;
                    // 通知浮窗
                    [XMWXVCFloatWindow shareXMWXVCFloatWindow].wxFloatWindowCancelRemoveBlock();
                }
            };
        }
        
    });
    return rightBottomFloatView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark - XMNavigationControllerEdgePanGestureDelegate


@end
