//
//  XMWifiGroupTool.h
//  虾兽维度
//
//  Created by Niki on 2018/5/8.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMWifiGroupTool : NSObject

/// 创建一个新文件夹
+ (void)creatNewWifiFilesGroupWithName:(NSString *)name;

/// 返回所以文件夹的名称
+ (NSArray *)groupMessage;

@end
