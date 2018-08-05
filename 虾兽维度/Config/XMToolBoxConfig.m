//
//  XMToolBoxConfig.m
//  虾兽维度
//
//  Created by Niki on 18/3/10.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMToolBoxConfig.h"

NSString *const ToolBox_kName = @"ToolBox_kName";
NSString *const ToolBox_kType = @"ToolBox_kType";
NSString *const ToolBox_kAuth = @"ToolBox_kAuth";
NSString *const touchIDKeyboardAuthenPassward = @"2236";    // 键盘验证的密码

@implementation XMToolBoxConfig


/**
 要分享的平台
 */
+ (NSArray *)toolBoxs
{
    return @[
             @{ToolBox_kName:@"Wifi传送文件",
               ToolBox_kType:@(XMToolBoxTypeWifiTransFiles),
               ToolBox_kAuth:@(XMToolBoxAuthenTypeNone)
               },
             @{ToolBox_kName:@"裁剪圆环头像",
               ToolBox_kType:@(XMToolBoxTypeClipImg),
               ToolBox_kAuth:@(XMToolBoxAuthenTypeNone)
               },
             @{ToolBox_kName:@"易",
               ToolBox_kType:@(XMToolBoxTypeTaiji),
               ToolBox_kAuth:@(XMToolBoxAuthenTypeNeed)
               },
             @{ToolBox_kName:@"更多",
               ToolBox_kType:@(XMToolBoxTypeDDD),
               ToolBox_kAuth:@(XMToolBoxAuthenTypeNone)
              }
             ];
}

@end
