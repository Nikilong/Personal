//
//  XMWifiGroupTool.h
//  虾兽维度
//
//  Created by Niki on 2018/5/8.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMWifiGroupTool : NSObject

extern NSString * const defaultGroupName;
extern NSString * const allFilesGroupName;

/**  文件夹操作方法 */
/// 创建一个新文件夹
+ (void)creatNewWifiFilesGroupWithName:(NSString *)name isBackup:(BOOL)isBackup;
/// 删除一个新文件夹
+ (void)deleteWifiFilesGroupWithName:(NSString *)name;
/// 返回所有(可编辑)文件夹的名称
+ (NSArray *)groupNameDirsModels;
/// 返回所有(不可编辑)文件夹的名称
+ (NSArray *)nonDeleteGroupNames;
/// 更新XMWifiGroupName.wifign文件
+ (NSArray *)updateGroupNameFile;
/// 返回默认文件夹名称
//+ (NSString *)getDefaultGroupName;
/// 更新当前文件夹
+ (void)upgradeCurrentGroupName:(NSString *)name;

/// 获取当前文件夹根路径
+ (NSString *)getCurrentGroupPath;

/// 返回当前文件夹目录下的所有文件
+ (NSMutableArray *)getCurrentGroupFiles;

/// 将文件夹组写进沙盒
+ (void)saveGroupMessageWithNewArray:(NSArray *)newArr;

/**  单文件操作方法 */


/**  检查类方法 */
// 检查能否删除该文件
+ (BOOL)canDeleteFileAtPath:(NSString *)path;

/**  压缩解压类,备份类 */
/// 压缩带有标记备份的文件夹
+ (BOOL)zipBackUpDirs;
/// 压缩系统配置类文件,例如收藏网页文件,文件组民文件等
+ (BOOL)zipConfigFiles;
@end
