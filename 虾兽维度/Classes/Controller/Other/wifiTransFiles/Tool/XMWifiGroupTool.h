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
/// 删除一个新文件夹
+ (void)deleteWifiFilesGroupWithName:(NSString *)name;
/// 返回所有文件夹的名称
+ (NSArray *)groupNames;
/// 返回默认文件夹名称
+ (NSString *)getDefaultGroupName;
/// 更新当前文件夹
+ (void)upgradeCurrentGroupName:(NSString *)name;


/// 获取当前文件夹根路径
+ (NSString *)getCurrentGroupPath;

/// 返回当前文件夹目录下的所有文件
+ (NSMutableArray *)getCurrentGroupFiles;

// 检查能否删除该文件
+ (BOOL)canDeleteFileAtPath:(NSString *)path;
@end
