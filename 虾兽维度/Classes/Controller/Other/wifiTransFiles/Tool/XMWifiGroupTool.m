//
//  XMWifiGroupTool.m
//  虾兽维度
//
//  Created by Niki on 2018/5/8.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMWifiGroupTool.h"
#import "CommonHeader.h"
#import "XMWifiTransModel.h"

#define XMWifiGroupNameFileName @"XMWifiGroupName.wifign"
#define XMWifiGroupNameFilePath ([NSString stringWithFormat:@"%@/%@",XMWifiUploadDirPath,XMWifiGroupNameFileName])

@implementation XMWifiGroupTool

static NSString *defaultGroupName;
static NSString *currentGroupName;

+ (void)initialize{
    defaultGroupName = @"默认";
    currentGroupName = @"默认";
}

/// 返回所有文件夹的名称
+ (NSArray *)groupNames{
    //    NSString *path = [NSString stringWithFormat:@"%@/XMWifiGroupName.wifign",XMWifiUploadDirPath];
    if([[NSFileManager defaultManager] fileExistsAtPath:XMWifiGroupNameFilePath]){
        return [NSArray arrayWithContentsOfFile:XMWifiGroupNameFilePath];
    }else{
        // 初始化默认分组
        NSArray *defaultArr = @[(defaultGroupName),@"分组1",@"分组2",@"分组3"];
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

/// 创建一个新文件夹
+ (void)creatNewWifiFilesGroupWithName:(NSString *)name{
    NSString *newFilePath = [NSString stringWithFormat:@"%@/%@",XMWifiUploadDirPath,name];
    [self checkRootDirectry];
    if ([[NSFileManager defaultManager] createDirectoryAtPath:newFilePath withIntermediateDirectories:YES attributes:nil error:nil]){
        NSMutableArray *fileArr = [NSMutableArray arrayWithArray:[self groupNames]];
        [fileArr addObject:name];
        [self saveGroupMessageWithNewArray:fileArr];
    }
}

/// 删除一个新文件夹
+ (void)deleteWifiFilesGroupWithName:(NSString *)name{
    // 默认文件夹不能删除
    if([name isEqualToString:defaultGroupName]){
        return;
    }
    // 如果删除的文件夹是当前文件夹,则切换至默认文件夹
    if([name isEqualToString:currentGroupName]){
        [self upgradeCurrentGroupName:defaultGroupName];
    }
    NSMutableArray *arr = [NSMutableArray arrayWithContentsOfFile:XMWifiGroupNameFilePath];
    
    NSString *fullPath = [XMWifiUploadDirPath stringByAppendingPathComponent:name];
    // 删除整个文件夹目录
    if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath]){
        [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
    }
    
    // 更新文件夹列表
    for (NSString *ele in arr){
        if ([ele isEqualToString:name]){
            [arr removeObject:ele];
            break;
        }
    }
    [self saveGroupMessageWithNewArray:arr];
}

/// 将文件夹组写进沙盒
+ (void)saveGroupMessageWithNewArray:(NSArray *)newArr{
    [newArr writeToFile:XMWifiGroupNameFilePath atomically:YES];
}

/// 更新当前文件夹
+ (void)upgradeCurrentGroupName:(NSString *)name{
    currentGroupName = name;
    NSLog(@"%s",__func__);
}

/// 获取当前文件夹根路径
+ (NSString *)getCurrentGroupPath{
    return [NSString stringWithFormat:@"%@/%@",XMWifiUploadDirPath,currentGroupName];
}


/// 返回默认文件夹名称
+ (NSString *)getDefaultGroupName{
    return defaultGroupName;
}

/// 返回文件夹目录下的所有文件
+ (NSMutableArray *)getCurrentGroupFiles{
    NSString *groupFullPath = [self getCurrentGroupPath];
    if([[NSFileManager defaultManager] fileExistsAtPath:groupFullPath]){
        NSMutableArray *fileFilterArr = [NSMutableArray array];
        NSArray *fileArr = [[NSFileManager defaultManager] subpathsAtPath:groupFullPath];
//        BOOL dirFlag;
        NSDictionary *dict = @{};
        for (NSString *ele in fileArr) {
            if([ele containsString:@"DS_Store"]) continue;
            // todo 暂时保留文件夹
//            dirFlag = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&dirFlag];
//            if(dirFlag) continue;
            XMWifiTransModel *model = [[XMWifiTransModel alloc] init];
            dict = [[NSFileManager defaultManager] attributesOfItemAtPath:[NSString stringWithFormat:@"%@/%@",groupFullPath,ele] error:nil];
            model.fileName = ele;
            model.fullPath = [NSString stringWithFormat:@"%@/%@",groupFullPath,ele];
            model.size = dict.fileSize/1024.0/1024.0;
            [fileFilterArr addObject:model];
            
        }
        return fileFilterArr;
    }else{
        return nil;
    }
}

/// 检查根目录是否存在
+ (void)checkRootDirectry{
    if(![[NSFileManager defaultManager] fileExistsAtPath:XMWifiUploadDirPath]){
        [[NSFileManager defaultManager] createDirectoryAtPath:XMWifiUploadDirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

@end
