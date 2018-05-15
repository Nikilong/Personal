//
//  XMWifiGroupTool.m
//  虾兽维度
//
//  Created by Niki on 2018/5/8.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMWifiGroupTool.h"
#import "XMWifiTransModel.h"


@implementation XMWifiGroupTool

static NSString *defaultGroupName = @"默认";
static NSString *currentGroupName = @"默认";
static NSString *allFilesGroupName = @"所有";

/// 返回所有(不可编辑)文件夹的名称
+ (NSArray *)nonDeleteGroupNames{
    return @[(defaultGroupName),(allFilesGroupName)];
}

/// 返回所有文件夹的名称
+ (NSArray *)groupNames{
    if([[NSFileManager defaultManager] fileExistsAtPath:[XMSavePathUnit  getWifiGroupNameFilePath]]){
        return [NSArray arrayWithContentsOfFile:[XMSavePathUnit getWifiGroupNameFilePath]];
    }else{
        // 初始化默认分组
        NSArray *defaultArr = @[(defaultGroupName),@"分组1",@"分组2",@"分组3"];
        [self checkRootDirectry];
        // 先创建文件,同时"所有"不需要创建分组,先写进文件
        [self saveGroupMessageWithNewArray:@[allFilesGroupName]];
        // 在沙盒创建默认的分组
        for (NSString *name in defaultArr){
            [self creatNewWifiFilesGroupWithName:name];
        }
        NSArray *dirsArr = [self updateGroupNameFile];
        // 将最终的结果保存
        [self saveGroupMessageWithNewArray:dirsArr];
        return dirsArr;
    }
    return nil;
}

/// 创建一个新文件夹
+ (void)creatNewWifiFilesGroupWithName:(NSString *)name{
    NSString *newFilePath = [NSString stringWithFormat:@"%@/%@",[XMSavePathUnit getWifiUploadDirPath],name];
    [self checkRootDirectry];
    // 文件名不可用则跳过
    if (![self isGroupNameEnable:name]) return;
    if ([[NSFileManager defaultManager] createDirectoryAtPath:newFilePath withIntermediateDirectories:YES attributes:nil error:nil]){
        NSMutableArray *fileArr = [NSMutableArray arrayWithArray:[self groupNames]];
        [fileArr addObject:name];
        [self saveGroupMessageWithNewArray:fileArr];
    }
}

/// 删除一个新文件夹
+ (void)deleteWifiFilesGroupWithName:(NSString *)name{
    // 如果删除的文件夹是当前文件夹,则切换至默认文件夹
    if([name isEqualToString:currentGroupName]){
        [self upgradeCurrentGroupName:defaultGroupName];
    }
    NSMutableArray *arr = [NSMutableArray arrayWithContentsOfFile:[XMSavePathUnit getWifiGroupNameFilePath]];
    
    NSString *fullPath = [[XMSavePathUnit getWifiUploadDirPath] stringByAppendingPathComponent:name];
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
    // 更新沙盒文件
    [self saveGroupMessageWithNewArray:arr];
}

/// 更新XMWifiGroupName.wifign文件
+ (NSArray *)updateGroupNameFile{
    // 如果"默认"文件夹不存在,则创建默认文件夹
    if(![[NSFileManager defaultManager] fileExistsAtPath:[[XMSavePathUnit getWifiUploadDirPath] stringByAppendingPathComponent:defaultGroupName]]){
        [[NSFileManager defaultManager] createDirectoryAtPath:[[XMSavePathUnit getWifiUploadDirPath] stringByAppendingPathComponent:defaultGroupName] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    // 遍历文件夹WifiTransPort,找出已经存在的其他文件夹
    NSArray *allFileArr =  [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:[XMSavePathUnit getWifiUploadDirPath] error:nil];
    NSMutableArray *dirsArr = [NSMutableArray array];
    for (NSString *ele in allFileArr){
        if (![ele containsString:@"/"]){
            if([ele containsString:@"DS_Store"]) continue;
            if ([ele containsString:XMWifiGroupNameFileName]) continue;
            if ([ele containsString:defaultGroupName]) continue;
            [dirsArr addObject:ele];
        }
    }
    [self saveGroupMessageWithNewArray:dirsArr];
    return dirsArr;
}

/// 将文件夹组写进沙盒
+ (void)saveGroupMessageWithNewArray:(NSArray *)newArr{
    [newArr writeToFile:[XMSavePathUnit getWifiGroupNameFilePath] atomically:YES];
}

/// 更新当前文件夹
+ (void)upgradeCurrentGroupName:(NSString *)name{
    currentGroupName = name;
    NSLog(@"%s",__func__);
}

/// 获取当前文件夹根路径
+ (NSString *)getCurrentGroupPath{
    // 如果当前目录是"所有",则切换至documents文件夹
    if ([currentGroupName isEqualToString:allFilesGroupName]){
        return [XMSavePathUnit getDocumentsPath];
    }else{
        return [NSString stringWithFormat:@"%@/%@",[XMSavePathUnit getWifiUploadDirPath],currentGroupName];
    }
}


/// 返回默认文件夹名称
+ (NSString *)getDefaultGroupName{
    return defaultGroupName;
}

/// 返回文件夹目录下的所有文件
+ (NSMutableArray *)getCurrentGroupFiles{
    NSString *groupFullPath = [self getCurrentGroupPath];
    BOOL isAllFile = NO;
    if([currentGroupName isEqualToString:allFilesGroupName]){
        isAllFile = YES;
    }
    
    if([[NSFileManager defaultManager] fileExistsAtPath:groupFullPath]){
        NSMutableArray *fileFilterArr = [NSMutableArray array];
        NSArray *fileArr = [[NSFileManager defaultManager] subpathsAtPath:groupFullPath];
        BOOL dirFlag;
        NSDictionary *dict = @{};
        for (NSString *ele in fileArr) {
            if([ele containsString:@"DS_Store"]) continue;
            // "所有"要过滤空文件夹
            if (isAllFile){
                dirFlag = NO;
                [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@",groupFullPath,ele] isDirectory:&dirFlag];
                if(dirFlag ) continue;
            }
            // 转换为模型
            XMWifiTransModel *model = [[XMWifiTransModel alloc] init];
            dict = [[NSFileManager defaultManager] attributesOfItemAtPath:[NSString stringWithFormat:@"%@/%@",groupFullPath,ele] error:nil];
            model.fileName = ele;
            model.pureFileName = [[ele componentsSeparatedByString:@"/"] lastObject];
            model.prePath = [model.fileName stringByReplacingOccurrencesOfString:model.pureFileName withString:@""];
            model.rootPath = groupFullPath;
            model.fullPath = [NSString stringWithFormat:@"%@/%@",groupFullPath,ele];
            model.size = dict.fileSize/1024.0/1024.0;
            [fileFilterArr addObject:model];
            
        }
        return fileFilterArr;
    }else{
        return nil;
    }
}

#pragma mark - 判断方法
/// 检查根目录是否存在
+ (void)checkRootDirectry{
    if(![[NSFileManager defaultManager] fileExistsAtPath:[XMSavePathUnit getWifiUploadDirPath]]){
        [[NSFileManager defaultManager] createDirectoryAtPath:[XMSavePathUnit getWifiUploadDirPath] withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

// 检查能否删除该文件
+ (BOOL)canDeleteFileAtPath:(NSString *)path{
    // todo  增加一个管理员权限,输入密码之类的
    if([path containsString:XMWifiMainDirName]){
        return YES;
    }else{
        return NO;
    }
    
}

// 检查文件名是否可用
+ (BOOL)isGroupNameEnable:(NSString *)name{
    // 关键词列表,以|隔开
    NSString *forbiStr = @"所有|关键词";
    if([forbiStr containsString:name]){
        return NO;
    }
    if (name.length > 6){
        return NO;
    }
    return YES;
}

@end
