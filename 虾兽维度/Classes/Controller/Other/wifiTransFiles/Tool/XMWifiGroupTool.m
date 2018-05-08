//
//  XMWifiGroupTool.m
//  虾兽维度
//
//  Created by Niki on 2018/5/8.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMWifiGroupTool.h"
#import "CommonHeader.h"

#define XMWifiGroupNameFileName @"XMWifiGroupName.wifign"
#define XMWifiGroupNameFilePath ([NSString stringWithFormat:@"%@/%@",XMWifiUploadDirPath,XMWifiGroupNameFileName])

@implementation XMWifiGroupTool
/// 创建一个新文件夹
+ (void)creatNewWifiFilesGroupWithName:(NSString *)name{
    NSString *newFilePath = [NSString stringWithFormat:@"%@/%@",XMWifiUploadDirPath,name];
    [self checkRootDirectry];
    if ([[NSFileManager defaultManager] createDirectoryAtPath:newFilePath withIntermediateDirectories:YES attributes:nil error:nil]){
        NSMutableArray *fileArr = [NSMutableArray arrayWithArray:[self groupMessage]];
        [fileArr addObject:name];
        [self saveGroupMessageWithNewArray:fileArr];
    }
}

/// 返回所有文件夹的名称
+ (NSArray *)groupMessage{
//    NSString *path = [NSString stringWithFormat:@"%@/XMWifiGroupName.wifign",XMWifiUploadDirPath];
    if([[NSFileManager defaultManager] fileExistsAtPath:XMWifiGroupNameFilePath]){
        return [NSArray arrayWithContentsOfFile:XMWifiGroupNameFilePath];
    }else{
        // 初始化默认分组
        NSArray *defaultArr = @[@"默认",@"分组1",@"分组2",@"分组3"];
        [self checkRootDirectry];
        [self saveGroupMessageWithNewArray:defaultArr];
        // 在沙盒创建默认的分组
        for (NSString *name in defaultArr){
            [self creatNewWifiFilesGroupWithName:name];
        }
        return defaultArr;
    }
    return nil;
}

/// 将文件夹组写进沙盒
+ (void)saveGroupMessageWithNewArray:(NSArray *)newArr{
    [newArr writeToFile:XMWifiGroupNameFilePath atomically:YES];
}

/// 检查根目录是否存在
+ (void)checkRootDirectry{
    if(![[NSFileManager defaultManager] fileExistsAtPath:XMWifiUploadDirPath]){
        [[NSFileManager defaultManager] createDirectoryAtPath:XMWifiUploadDirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

@end
