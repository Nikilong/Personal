//
//  XMWifiGroupTool.m
//  虾兽维度
//
//  Created by Niki on 2018/5/8.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMWifiGroupTool.h"
#import "XMWifiTransModel.h"
#import "SSZipArchive.h"

@implementation XMWifiGroupTool

NSString * const defaultGroupName = @"默认";
NSString * const allFilesGroupName = @"所有";
NSString * const backupGroupName = @"备份";
NSString * const settingZipFilePre = @"config";

static NSString *currentGroupName = @"默认";

#pragma mark - 压缩解压类,备份类
#pragma mark 压缩
/// 压缩系统配置类文件,例如收藏网页文件,文件组名文件等
+ (BOOL)zipConfigFiles{
    // 先检查"备份"文件夹是否存在
    NSString *backupDirPath = [[XMSavePathUnit getWifiUploadDirPath] stringByAppendingPathComponent:backupGroupName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:backupDirPath]){
        [[NSFileManager defaultManager] createDirectoryAtPath:backupDirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    // 保存到"备份"文件夹 ..../备份/config_日期.zip
    NSString *zipPath = [NSString stringWithFormat:@"%@/%@_%@.zip",backupDirPath,settingZipFilePre,[self dateChangeToString:[NSDate date]]];
    NSArray *saveFilesPathArr =[XMSavePathUnit getSettingFilesPaths];
    // 压缩多个文件
    return [SSZipArchive createZipFileAtPath:zipPath withFilesAtPaths:saveFilesPathArr];
}

/// 压缩带有标记备份的文件夹
+ (BOOL)zipBackUpDirs{
    // 先检查"备份"文件夹是否存在
    NSString *backupDirPath = [[XMSavePathUnit getWifiUploadDirPath] stringByAppendingPathComponent:backupGroupName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:backupDirPath]){
        [[NSFileManager defaultManager] createDirectoryAtPath:backupDirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *zipPath = [NSString stringWithFormat:@"%@/dirs_%@.zip",backupDirPath,[self dateChangeToString:[NSDate date]]];
    NSString *tmpDirPatn = [[XMSavePathUnit getTmpPath] stringByAppendingPathComponent:@"backup"];
    // 备份前检查临时文件是否存在,没有就创建空文件夹,有就删除
    if ([[NSFileManager defaultManager] fileExistsAtPath:tmpDirPatn]){
        [[NSFileManager defaultManager] removeItemAtPath:tmpDirPatn error:nil];
    }
    [[NSFileManager defaultManager] createDirectoryAtPath:tmpDirPatn withIntermediateDirectories:YES attributes:nil error:nil];
    NSArray *fileArr = [self groupNameDirsModels];
    for(XMWifiTransModel *model in fileArr){
        if (model.isBackup){
            
            [[NSFileManager defaultManager] copyItemAtPath:[NSString stringWithFormat:@"%@/%@",[XMSavePathUnit getWifiUploadDirPath],model.groupName] toPath:[NSString stringWithFormat:@"%@/%@",tmpDirPatn,model.groupName]  error:nil];
        }
    }
    // 压缩多个文件
    BOOL success = [SSZipArchive createZipFileAtPath:zipPath withContentsOfDirectory:[XMSavePathUnit getTmpPath]];
    [[NSFileManager defaultManager] removeItemAtPath:tmpDirPatn error:nil];
    return success;
}

#pragma mark 解压
+ (BOOL)unzipFileAtPath:(NSString *)path{
    NSString *newPath = [path stringByDeletingPathExtension];
    return [SSZipArchive unzipFileAtPath:path toDestination:newPath];
}


/// 解压并同步本地配置文件
+ (BOOL)unzipSettingFilesAtPath:(NSString *)path{
    NSString *newPath = [[XMSavePathUnit getTmpPath] stringByAppendingPathComponent:@"setting"];
    NSFileManager *fileM = [NSFileManager defaultManager];
    // 确保文件夹是空的
    if (![fileM fileExistsAtPath:newPath]){
        [fileM createDirectoryAtPath:newPath withIntermediateDirectories:YES attributes:nil error:nil];
    }else{
        [fileM removeItemAtPath:newPath error:nil];
        [fileM createDirectoryAtPath:newPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if([SSZipArchive unzipFileAtPath:path toDestination:newPath]){
        NSArray *saveFilesPathArr =[XMSavePathUnit getSettingFilesPaths];
        BOOL result = YES;
        NSString *destPath = @""; // 移动的目标位置
        for (NSString *filePath in saveFilesPathArr){
            destPath = [newPath stringByAppendingPathComponent:[filePath lastPathComponent]];
            // 替换
            if (![fileM replaceItemAtURL:[NSURL fileURLWithPath:filePath] withItemAtURL:[NSURL fileURLWithPath:destPath] backupItemName:nil options:0 resultingItemURL:nil error:nil]){
                result = NO;
            }
            
        }
        // 移除tmp中的文件夹
        [fileM removeItemAtPath:newPath error:nil];
        return result;
    }
    return NO;
}

#pragma mark - 文件夹操作类
/// 返回所有(不可编辑)文件夹的名称
+ (NSArray *)nonDeleteGroupNames{
    return @[(defaultGroupName),(allFilesGroupName),(backupGroupName)];
}

/// 返回所有文件夹的名称
+ (NSArray *)groupNameDirsModels{
    if([[NSFileManager defaultManager] fileExistsAtPath:[XMSavePathUnit  getWifiGroupNameFilePath]]){
        return [NSKeyedUnarchiver unarchiveObjectWithFile:[XMSavePathUnit getWifiGroupNameFilePath]];
    }else{
        // 初始化默认分组
        NSArray *defaultArr = @[(defaultGroupName),(backupGroupName),@"分组1",@"分组2"];
        [self checkRootDirectry];
        NSMutableArray *dirModelArr = [NSMutableArray array];
        for (NSUInteger i = 0; i < defaultArr.count; i++) {
            NSString *fullDirPath =[NSString stringWithFormat:@"%@/%@",[XMSavePathUnit getWifiUploadDirPath],defaultArr[i]];
            if (![[NSFileManager defaultManager] fileExistsAtPath:fullDirPath]){
                [[NSFileManager defaultManager] createDirectoryAtPath:fullDirPath withIntermediateDirectories:YES attributes:nil error:nil];
            }
            if (i > 1){
                XMWifiTransModel *model = [[XMWifiTransModel alloc] init];
                model.groupName =defaultArr[i];
                model.isBackup = NO;
                [dirModelArr addObject:model];
            }
        }
        
        // 先创建文件
        [self saveGroupMessageWithNewArray:dirModelArr];
        return [self updateGroupNameFile];
    }
    return nil;
}


/// 创建一个新文件夹
+ (void)creatNewWifiFilesGroupWithName:(NSString *)name isBackup:(BOOL)isBackup{
    NSString *newFilePath = [NSString stringWithFormat:@"%@/%@",[XMSavePathUnit getWifiUploadDirPath],name];
    if ([[NSFileManager defaultManager] fileExistsAtPath:newFilePath]) return;
    [self checkRootDirectry];
    // 文件名不可用则跳过
    if (![self isGroupNameEnable:name]) return;
    if ([[NSFileManager defaultManager] createDirectoryAtPath:newFilePath withIntermediateDirectories:YES attributes:nil error:nil]){
        NSMutableArray *fileArr = [NSMutableArray arrayWithArray:[self groupNameDirsModels]];
        XMWifiTransModel *model = [[XMWifiTransModel alloc] init];
        model.groupName = name;
        model.isBackup = isBackup;
        [fileArr addObject:model];
        [self saveGroupMessageWithNewArray:fileArr];
    }
}

/// 删除一个新文件夹
+ (void)deleteWifiFilesGroupWithName:(NSString *)name{

    // 如果删除的文件夹是当前文件夹,则切换至默认文件夹
    if([name isEqualToString:currentGroupName]){
        [self upgradeCurrentGroupName:defaultGroupName];
    }
    NSMutableArray *arr = [NSMutableArray arrayWithArray:[self groupNameDirsModels]];
    
    NSString *fullPath = [[XMSavePathUnit getWifiUploadDirPath] stringByAppendingPathComponent:name];
    // 删除整个文件夹目录
    if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath]){
        [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
    }
    
    // 更新文件夹列表
    for (XMWifiTransModel *model in arr){
        if ([model.groupName isEqualToString:name]){
            [arr removeObject:model];
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
    NSString *markZipString = [NSString stringWithContentsOfFile:[XMSavePathUnit getWifiGroupMarkZipFilePath] encoding:NSUTF8StringEncoding error:nil];
    for (NSString *ele in allFileArr){
        if (![ele containsString:@"/"]){
            if([ele containsString:@"DS_Store"]) continue;
            if ([ele containsString:XMWifiGroupNameFileName]) continue;
            if ([ele containsString:XMWifiGroupMarkZipFileName]) continue;
            if ([ele containsString:defaultGroupName]) continue;
            if ([ele containsString:backupGroupName]) continue;
            XMWifiTransModel *model = [[XMWifiTransModel alloc] init];
            model.groupName = ele;
            model.isBackup = ([markZipString containsString:ele]) ? YES : NO;
            [dirsArr addObject:model];
        }
    }
    [self saveGroupMessageWithNewArray:dirsArr];
    return dirsArr;
}

/// 将文件夹组写进沙盒
+ (void)saveGroupMessageWithNewArray:(NSArray *)newArr{
    [NSKeyedArchiver archiveRootObject:newArr toFile:[XMSavePathUnit getWifiGroupNameFilePath]];
}

/// 当增加标记或者取消备份的标记,需要更新记录zip的文件
+ (void)updateZipMarkGroupName:(NSString *)name isMark:(BOOL)isMark{
    NSString *markZipStr = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:[XMSavePathUnit getWifiGroupMarkZipFilePath]] encoding:NSUTF8StringEncoding error:nil];
    // 根据新增或者取消,更新数据
    if (isMark){
        markZipStr = [NSString stringWithFormat:@"%@|%@",markZipStr,name];
    }else{
        markZipStr = [markZipStr stringByReplacingOccurrencesOfString:name withString:@""];
    }
    // 将删除那么之后的||替换成|
    markZipStr = [markZipStr stringByReplacingOccurrencesOfString:@"||" withString:@"|"];
    [markZipStr writeToFile:[XMSavePathUnit getWifiGroupMarkZipFilePath] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
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

/// 返回文件夹目录下的所有文件
+ (NSMutableArray *)getCurrentGroupFiles{
    NSString *groupFullPath = [self getCurrentGroupPath];
    BOOL isAllFile = NO;
    if([currentGroupName isEqualToString:allFilesGroupName]){
        isAllFile = YES;
    }
    // 如果文件夹路径存在,则让模型处理
    if([[NSFileManager defaultManager] fileExistsAtPath:groupFullPath]){
        return [XMWifiTransModel getFilesModelAtDirFullPath:groupFullPath isReturnAllFile:isAllFile];
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

/// 获取字符串的时间戳
+ (NSString *)dateChangeToString:(NSDate *)date{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    [formatter setDateFormat:@"YYYYMMdd_HH时mm分ss秒"];
//    NSDate *datenow = [NSDate date];
    //将nsdate按formatter格式转成nsstring
    NSString *currentTimeString = [formatter stringFromDate:date];
    return currentTimeString;
    
}

@end
