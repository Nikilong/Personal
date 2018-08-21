//
//  XMFileManageTool.m
//  虾兽维度
//
//  Created by Niki on 2018/8/21.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMFileManageTool.h"
#include <sys/param.h>
#include <sys/mount.h>

@implementation XMFileManageTool

/// 检查文件的大小
+ (long long)fileSizeAtPath:(NSString *)filePath {
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]) {
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

/// 检查文件夹的大小
+ (float)folderSizeAtPath:(NSString *)folderPath {
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString *fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize;
}

/// 检查文件夹是否超过maxSize,超过就清理(删除)文件夹
+ (XMCheckFolderResult)checkAndClearFolder:(NSString *)path maxSize:(long long)maxSize{
    float currentSize = [self folderSizeAtPath:path];
    XMCheckFolderResult callbackResult;
    if (currentSize >= maxSize){
        BOOL result = [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        callbackResult = result ? XMCheckFolderResultClearSuccess : XMCheckFolderResultClearFailed;
    }else{
        callbackResult = XMCheckFolderResultUnless;
    }
    return callbackResult;
}

/// 获得手机剩余空间
+ (unsigned long long)freeDiskSpaceInBytes{
    struct statfs buf;
    unsigned long long freeSpace = -1;
    if (statfs("/var", &buf) >= 0) {
        freeSpace = (unsigned long long)(buf.f_bsize * buf.f_bavail);
    }
    return freeSpace;
}


@end
