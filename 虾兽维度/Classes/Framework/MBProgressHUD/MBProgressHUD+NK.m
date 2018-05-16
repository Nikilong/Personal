//
//  MBProgressHUD+NK.m
//  虾兽维度
//
//  Created by Niki on 17/3/31.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "MBProgressHUD+NK.h"

@implementation MBProgressHUD (NK)

#pragma mark 显示进度条
+ (void)showProgressInView:(UIView *)view mode:(MBProgressHUDMode)mode duration:(NSTimeInterval)duration title:(NSString *)title
{
    if (view == nil){
        view = [UIApplication sharedApplication].keyWindow;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    // Set the bar determinate mode to show task progress.
    hud.mode = mode;
    hud.label.text = NSLocalizedString(title, @"HUD loading title");
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        // Do something useful in the background and update the HUD periodically.
        float progress = 0.0f;
        while (progress < 1.0f) {
            progress += 0.01f;
            dispatch_async(dispatch_get_main_queue(), ^{
                // Instead we could have also passed a reference to the HUD
                // to the HUD to myProgressTask as a method parameter.
                [MBProgressHUD HUDForView:view].progress = progress;
            });
            // 设置执行时间
            usleep(duration * 10000);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            // Set an image view with a checkmark.
            [self show:@"完成" icon:@"Checkmark.png" view:view];
            
            [hud hideAnimated:YES];
        });
    });
   
}

#pragma mark 显示加载动画
+ (MBProgressHUD *)showLoadingViewInView:(UIView *)view title:(NSString *)title
{
    if (view == nil){
        view = [UIApplication sharedApplication].keyWindow;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    // Set the bar determinate mode to show task progress.
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.label.text = NSLocalizedString(title, @"HUD loading title");
    return hud;
}

#pragma mark 显示信息
+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view
{
    if (view == nil){
        view = [UIApplication sharedApplication].keyWindow;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    
    // Set the custom view mode to show any view.
    hud.mode = MBProgressHUDModeCustomView;
    // Set an image view with a checkmark.
    if (icon)
    {
        UIImage *image = [[UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", icon]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        hud.customView = [[UIImageView alloc] initWithImage:image];
    }
    // Looks a bit nicer if we make it square.
    hud.square = YES;
    // Optional label text.
    hud.label.text = NSLocalizedString(text, @"HUD done title");
    
    [hud hideAnimated:YES afterDelay:1.f];

}

+ (void)show:(NSString *)text image:(UIImage *)image view:(UIView *)view
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    
    // Set the custom view mode to show any view.
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [[UIImageView alloc] initWithImage:image];
    // Looks a bit nicer if we make it square.
//    hud.square = YES;
    // Optional label text.
//    hud.label.text = NSLocalizedString(text, @"HUD done title");
    hud.detailsLabel.text = NSLocalizedString(text, @"HUD done title");
    
    [hud hideAnimated:YES afterDelay:1.f];
    
}

+ (void)showSuccess
{
    [self show:@"成功" icon:@"Checkmark.png" view:nil];
}

+ (void)showFailed
{
    [self show:@"失败" icon:@"UNCheckmark.png" view:nil];
}

+ (void)showMessage:(NSString *)text toView:(UIView *)view
{
    [self show:text icon:nil view:view];
}


@end
