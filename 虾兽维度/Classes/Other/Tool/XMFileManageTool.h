//
//  XMFileManageTool.h
//  虾兽维度
//
//  Created by Niki on 2018/8/21.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    XMCheckFolderResultClearSuccess,    // 超过最大容量并删除成功
    XMCheckFolderResultClearFailed,     // 超过最大容量但是删除失败
    XMCheckFolderResultUnless           // 没有达到最大容量
}XMCheckFolderResult;

@interface XMFileManageTool : NSObject

/// 检查文件的大小
+ (long long)fileSizeAtPath:(NSString *)filePath;

/// 检查文件夹的大小
+ (float)folderSizeAtPath:(NSString *)folderPath;

/// 获得手机剩余空间
+ (unsigned long long)freeDiskSpaceInBytes;

/// 检查文件夹是否超过maxSize,超过就清理(删除)文件夹
+ (XMCheckFolderResult)checkAndClearFolder:(NSString *)path maxSize:(long long)maxSize;

@end
