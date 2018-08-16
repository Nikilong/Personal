//
//  XMWXFloatWindowIconConfig.m
//  虾兽维度
//
//  Created by Niki on 18/7/18.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMWXFloatWindowIconConfig.h"
//#import "XMWebViewController.h"
#import "XMWKWebViewController.h"
#import "XMSavePathUnit.h"

/// 浮窗保存vc的类名(key)
NSString *const wxfloatVCKey = @"wxfloatVCKey";
/// 浮窗位置的frame的string(key)
NSString *const wxfloatFrameStringKey = @"wxfloatFrameStringKey";
/// 浮窗保存vc的类参数(key)
NSString *const wxfloatVCParamsKey = @"wxfloatVCParamsKey";
// params下的image的key
NSString *const wxfloatVCParamsImageKey = @"wxfloatVCParamsImageKey";
// params下的title的key
NSString *const wxfloatVCParamsTitleKey = @"wxfloatVCParamsTitleKey";


@implementation XMWXFloatWindowIconConfig

/// 偏好设置里面是否存有控制器
+ (BOOL)isSaveFloatVCInUserDefaults{
    NSString *saveVCName = [[NSUserDefaults standardUserDefaults] valueForKey:wxfloatVCKey];
    if(saveVCName.length > 0){
        return YES;
    }else{
        return NO;
    }
    
}

/// 清空存档数据
+ (void)removeBackupData{
    
    [[NSFileManager defaultManager] removeItemAtPath:[XMSavePathUnit getFloatWindowWebmodelArchivePath] error:nil];
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:wxfloatVCKey];
    [[NSUserDefaults standardUserDefaults] setValue:@{} forKey:wxfloatVCParamsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

/// 根据vc的类型设置浮窗的图片或标题,以及存档
+ (void)setIconAndTitleByViewController:(UIViewController *)vc button:(UIButton *)btn{

    if ([vc isKindOfClass:[XMWKWebViewController class]]){
        [self setAndBackupWebViewController:(XMWKWebViewController *)vc Button:btn];
    }else{
        [self setAndBackupNormalVC:vc button:btn];
    }
}

/// 设置XMWebViewController类型的vc的浮窗图片或标题,以及归档XMWebViewController对应的webmodel模型
+ (void)setAndBackupWebViewController:(XMWKWebViewController *)webVC Button:(UIButton *)btn{
    // 对于webview,需要网络加载封面图片,所以需要特殊处理
    // 清空图片和标题
    [btn setTitle:@"" forState:UIControlStateNormal];
    [btn setImage:nil forState:UIControlStateNormal];
    
    // 先保存类名
    [[NSUserDefaults standardUserDefaults] setValue:NSStringFromClass([XMWKWebViewController class]) forKey:wxfloatVCKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    __block XMWebModel *model = webVC.model;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block UIImage *webCoverImg = [UIImage imageWithData:[NSData dataWithContentsOfURL:model.author_icon]];
        if(!webCoverImg){
            NSString *html = [NSString stringWithContentsOfURL:webVC.model.webURL encoding:NSUTF8StringEncoding error:nil];
            NSArray *arr = [html componentsSeparatedByString:@"author_icon"];
            if(arr.count > 1){
                NSString *iconStr = arr.lastObject;
                NSArray *arr2 = [iconStr componentsSeparatedByString:@"}"];
                if(arr2.count >1){
                    NSString *finalStr = arr2[0];
                    NSArray *finalArr = [finalStr componentsSeparatedByString:@"\""];
                    NSString *iconURL = @"";
                    for (NSString *ele in finalArr){
                        if([ele containsString:@"http"]){
                            iconURL = ele;
                        }
                    }
                    if(iconURL.length > 0){
                        model.author_icon = [NSURL URLWithString:iconURL];
                        webCoverImg = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:iconURL]]];
                    }
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            // 有头像设置头像,没有头像就去发布者的首个字符,都没有则设置默认图片
            NSString *title = @"";
            if(!webCoverImg){
                if(model.source.length > 1){
                    [btn setTitle:[model.source substringToIndex:1] forState:UIControlStateNormal];
                    title = [model.source substringToIndex:1];
                }else{
                    webCoverImg = [UIImage imageNamed:@"wxFloatWindowIcon_7"];
                    [btn setImage:webCoverImg forState:UIControlStateNormal];
                }
            }else{
                [btn setImage:webCoverImg forState:UIControlStateNormal];
            }
            
            // 保存图片或标题到偏好设置中
            NSData *imgData = UIImageJPEGRepresentation(webCoverImg, 0.5);
            NSDictionary *params = @{
                                     wxfloatVCParamsImageKey:imgData? imgData : @"",
                                     wxfloatVCParamsTitleKey:title
                                     };
            [[NSUserDefaults standardUserDefaults] setValue:params forKey:wxfloatVCParamsKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            // 数据模型单独归档
            [NSKeyedArchiver archiveRootObject:model toFile:[XMSavePathUnit getFloatWindowWebmodelArchivePath]];
        });
    });
}

/// 设置及备份普通类型的vc的浮窗图片
+ (void)setAndBackupNormalVC:(UIViewController *)vc button:(UIButton *)btn{
    NSString *imgName = @"";
     if([vc isKindOfClass:NSClassFromString(@"XMWifiTransFileViewController")] || [vc isKindOfClass:NSClassFromString(@"XMPhotoCollectionViewController")] || [vc isKindOfClass:NSClassFromString(@"XMFileDisplayWebViewViewController")] || [vc isKindOfClass:NSClassFromString(@"HJVideoPlayerController")]){ // wifi传输文件
        imgName = @"wxFloatWindowIcon_3";
    }else if([vc isKindOfClass:NSClassFromString(@"XMClipImageViewController")]){ // 裁剪图片
        imgName = @"wxFloatWindowIcon_2";
        
    }else if([vc isKindOfClass:NSClassFromString(@"XMHiwebViewController")] || [vc isKindOfClass:NSClassFromString(@"XMPersonFilmCollectionVC")]){ // hiweb
        imgName = @"wxFloatWindowIcon_4";
    }else if([vc isKindOfClass:NSClassFromString(@"XMSaveWebsTableViewController")]){ // 收藏
        imgName = @"wxFloatWindowIcon_6";
    }else if([NSStringFromClass([vc class]) containsString:@"XMMetorMapViewController"]){ // 地铁图
        imgName = @"wxFloatWindowIcon_8";
    }else if([vc isKindOfClass:NSClassFromString(@"XMQRCodeViewController")]){ // 扫描二维码
        imgName = @"wxFloatWindowIcon_9";
    }else if([vc isKindOfClass:NSClassFromString(@"")]){ //
        imgName = @"wxFloatWindowIcon_";
    }else{ // 默认
        imgName = @"wxFloatWindowIcon_default";
    }
    
    [btn setTitle:@"" forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    
    // 保存到偏好设置,只需要保存图片名称
    NSDictionary *params = @{
                             wxfloatVCParamsImageKey:imgName,
                             wxfloatVCParamsTitleKey:@""
                             };
    [[NSUserDefaults standardUserDefaults] setValue:NSStringFromClass([vc class]) forKey:wxfloatVCKey];
    [[NSUserDefaults standardUserDefaults] setValue:params forKey:wxfloatVCParamsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

/// 从偏好设置中恢复图片或标题
+ (void)setBackupImageOrTitlt:(UIButton *)btn{
    NSDictionary *params = [[NSUserDefaults standardUserDefaults] valueForKey:wxfloatVCParamsKey];
    // 防止清除浮窗后空数据造成闪退
    if(params.allKeys.count == 0) return;
    
    id imgMsg = params[wxfloatVCParamsImageKey];
    UIImage *realImage = nil;
    // 可能是NSData,也可能是NSString
    if ([imgMsg isKindOfClass:[NSData class]]){
        realImage = [UIImage imageWithData:imgMsg];
    }else if([imgMsg isKindOfClass:[NSString class]]){
        NSString *imgName = (NSString *)imgMsg;
        if(imgName.length > 0){
            realImage = [UIImage imageNamed:imgMsg];
        }
    }
    
    // 没有图片肯定会有标题
    if (realImage){
        [btn setImage:realImage forState:UIControlStateNormal];
    }else{
        [btn setTitle:params[wxfloatVCParamsTitleKey] forState:UIControlStateNormal];
    }

}
@end
