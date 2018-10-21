//
//  XMToolboxModel.m
//  虾兽维度
//
//  Created by Niki on 2018/10/19.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMToolboxModel.h"

NSString *const touchIDKeyboardAuthenPassward = @"2236";    // 键盘验证的密码

@implementation XMToolboxModel

+ (NSArray<XMToolboxModel *> *)toolboxModels{
    NSArray *sourceArr = @[
                 @{@"title":@"Wifi传送文件",
                   @"type":@(XMToolBoxTypeWifiTransFiles),
                   @"authenType":@(XMToolBoxAuthenTypeNeed),
                   @"image":@"tool_icon_0.png",
                   },
                 @{@"title":@"裁剪圆环头像",
                   @"type":@(XMToolBoxTypeClipImg),
                   @"authenType":@(XMToolBoxAuthenTypeNone),
                   @"image":@"tool_icon_1.png",
                   },
//                 @{@"title":@"易",
//                   @"type":@(XMToolBoxTypeTaiji),
//                   @"authenType":@(XMToolBoxAuthenTypeNeed)
//                   },
//                 @{@"title":@"更多",
//                   @"type":@(XMToolBoxTypeDDD),
//                   @"authenType":@(XMToolBoxAuthenTypeNone)
//                   }
                 ];
    NSMutableArray *arrM = [NSMutableArray array];
    for (NSUInteger i = 0; i < sourceArr.count; i++) {
        NSDictionary *dict = sourceArr[i];
        XMToolboxModel *model = [[XMToolboxModel alloc] init];
        model.title = dict[@"title"];
        model.image = dict[@"image"];
        model.tag = i;
        model.type = [dict[@"type"] integerValue];
        model.authenType = [dict[@"authenType"] integerValue];
        [arrM addObject:model];
    }
    return [arrM copy];
}


@end
