//
//  XMToolBoxConfig.h
//  虾兽维度
//
//  Created by Niki on 18/3/10.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 作用:
    该类是为了定义工具箱的图标,名字,个数
 
 */

extern NSString *const ToolBox_kName;
extern NSString *const ToolBox_kType;
extern NSString *const ToolBox_kAuth;

typedef enum : NSUInteger {
    XMToolBoxTypeClipImg,           // 裁剪图片
    XMToolBoxTypeHiweb,             // hiweb
    XMToolBoxTypeTaiji,             // 易数
    XMToolBoxTypeWifiTransFiles,    // wifi传输文件
    XMToolBoxTypeDDD,
    XMToolBoxTypeEEE,
} XMToolBoxType;


typedef enum : NSUInteger {
    XMToolBoxAuthenTypeNeed,        // 需要指纹验证
    XMToolBoxAuthenTypeNone         // 不需要指纹验证
    
} XMToolBoxAuthenType;

@interface XMToolBoxConfig : NSObject

/** 要分享的平台 */
+ (NSArray *)toolBoxs;

@end
