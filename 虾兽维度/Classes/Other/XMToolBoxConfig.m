//
//  XMToolBoxConfig.m
//  虾兽维度
//
//  Created by Niki on 18/3/10.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMToolBoxConfig.h"

@implementation XMToolBoxConfig


/**
 要分享的平台
 */
+ (NSArray *)toolBoxs
{
    return @[
             @{ToolBox_kName:@"裁剪圆环头像",
               ToolBox_kType:@(XMToolBoxTypeClipImg),
               ToolBox_kAuth:@(XMToolBoxAuthenTypeNone)
               },
             @{ToolBox_kName:@"Hiweb",
               ToolBox_kType:@(XMToolBoxTypeHiweb),
               ToolBox_kAuth:@(XMToolBoxAuthenTypeNeed)
               },
             @{ToolBox_kName:@"易",
               ToolBox_kType:@(XMToolBoxTypeTaiji),
               ToolBox_kAuth:@(XMToolBoxAuthenTypeNeed)
               },
             @{ToolBox_kName:@"招租",
               ToolBox_kType:@(XMToolBoxTypeCCC),
               ToolBox_kAuth:@(XMToolBoxAuthenTypeNeed)
              },
             @{ToolBox_kName:@"更多",
               ToolBox_kType:@(XMToolBoxTypeCCC),
               ToolBox_kAuth:@(XMToolBoxAuthenTypeNone)
              }
             ];
}

@end
