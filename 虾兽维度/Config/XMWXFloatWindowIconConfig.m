//
//  XMWXFloatWindowIconConfig.m
//  虾兽维度
//
//  Created by Niki on 18/7/18.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMWXFloatWindowIconConfig.h"
#import "XMWebViewController.h"

@implementation XMWXFloatWindowIconConfig

+ (void)setIconAndTitleByViewController:(UIViewController *)vc button:(UIButton *)btn{
    UIImage *coverImg = nil;
    if ([vc isKindOfClass:[XMWebViewController class]]){
        XMWebViewController *realVC = (XMWebViewController *)vc;
        coverImg = [UIImage imageWithData:[NSData dataWithContentsOfURL:realVC.model.author_icon]];
        if(!coverImg){
            if(realVC.model.source.length > 1){
                [btn setTitle:[realVC.model.source substringToIndex:1] forState:UIControlStateNormal];
            }else{
                coverImg = [UIImage imageNamed:@"wxFloatWindowIcon_7"];
            }
        }
    }else if([vc isKindOfClass:NSClassFromString(@"XMWifiTransFileViewController")] || [vc isKindOfClass:NSClassFromString(@"XMPhotoCollectionViewController")] || [vc isKindOfClass:NSClassFromString(@"XMFileDisplayWebViewViewController")] || [vc isKindOfClass:NSClassFromString(@"HJVideoPlayerController")]){ // wifi传输文件
        coverImg = [UIImage imageNamed:@"wxFloatWindowIcon_3"];
    }else if([vc isKindOfClass:NSClassFromString(@"XMClipImageViewController")]){ // 裁剪图片
        coverImg = [UIImage imageNamed:@"wxFloatWindowIcon_2"];
        
    }else if([vc isKindOfClass:NSClassFromString(@"XMHiwebViewController")] || [vc isKindOfClass:NSClassFromString(@"XMPersonFilmCollectionVC")]){ // hiweb
        coverImg = [UIImage imageNamed:@"wxFloatWindowIcon_4"];
    }else if([vc isKindOfClass:NSClassFromString(@"XMSaveWebsTableViewController")]){ // 收藏
        coverImg = [UIImage imageNamed:@"wxFloatWindowIcon_6"];
    }else if([NSStringFromClass([vc class]) containsString:@"XMMetorMapViewController"]){ // 地铁图
        coverImg = [UIImage imageNamed:@"wxFloatWindowIcon_8"];
    }else if([vc isKindOfClass:NSClassFromString(@"")]){ //
        coverImg = [UIImage imageNamed:@"wxFloatWindowIcon_"];
    }else{ // 默认
        coverImg = [UIImage imageNamed:@"wxFloatWindowIcon_default"];
    }
    
    if (coverImg){
        [btn setTitle:@"" forState:UIControlStateNormal];
        [btn setImage:coverImg forState:UIControlStateNormal];
    }
}


@end
