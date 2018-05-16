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

static NSString *currentGroupName = @"默认";
static NSString *backupGroupName = @"备份";

#pragma mark - 压缩解压类,备份类
/// 压缩系统配置类文件,例如收藏网页文件,文件组民文件等
+ (BOOL)zipConfigFiles{
    NSString *zipPath = [NSString stringWithFormat:@"%@/%@/config_%@.zip",[XMSavePathUnit getWifiUploadDirPath],backupGroupName,[self getNowTimeTimestamp]];
    NSArray *saveFilesPathArr =@[[XMSavePathUnit getHiwebHomeUrlPath],[XMSavePathUnit getWifiGroupNameFilePath],[XMSavePathUnit getSaveWebModelArchicerPath]];
    // 压缩多个文件
    return [SSZipArchive createZipFileAtPath:zipPath withFilesAtPaths:saveFilesPathArr];
}

/// 压缩带有标记备份的文件夹
+ (BOOL)zipBackUpDirs{
    NSString *zipPath = [NSString stringWithFormat:@"%@/%@/dirs_%@.zip",[XMSavePathUnit getWifiUploadDirPath],backupGroupName,[self getNowTimeTimestamp]];
    NSString *tmpDirPatn = [NSString stringWithFormat:@"%@/backup",[XMSavePathUnit getTmpPath]];
    // 备份前检查临时文件是否存在,没有就创建空文件夹,有就删除
    if (![[NSFileManager defaultManager] fileExistsAtPath:tmpDirPatn]){
        [[NSFileManager defaultManager] createDirectoryAtPath:tmpDirPatn withIntermediateDirectories:YES attributes:nil error:nil];
    }else{
        [[NSFileManager defaultManager] removeItemAtPath:tmpDirPatn error:nil];
    }
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


#pragma mark - 文件夹操作类
/// 返回所有(不可编辑)文件夹的名称
+ (NSArray *)nonDeleteGroupNames{
    return @[(defaultGroupName),(allFilesGroupName),(backupGroupName)];
}

/// 返回所有文件夹的名称
+ (NSArray *)groupNameDirsModels{
    if([[NSFileManager defaultManager] fileExistsAtPath:[XMSavePathUnit  getWifiGroupNameFilePath]]){
        return [NSKeyedUnarchiver unarchiveObjectWithFile:[XMSavePathUnit getWifiGroupNameFilePath]];
//        return [NSArray arrayWithContentsOfFile:[XMSavePathUnit getWifiGroupNameFilePath]];
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
        // 在沙盒创建默认的分组
//        for (NSString *name in defaultArr){
//            [self creatNewWifiFilesGroupWithName:name isBackup:NO];
//            XMWifiTransModel *model = [[XMWifiTransModel alloc] init];
//            model.groupName = name;
//            model.isBackup = YES;
//            [dirModelArr addObject:model];
//        }
//        NSArray *dirsArr = [self updateGroupNameFile];
        // 将最终的结果保存
//        [self saveGroupMessageWithNewArray:dirsArr];
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
    for (NSString *ele in allFileArr){
        if (![ele containsString:@"/"]){
            if([ele containsString:@"DS_Store"]) continue;
            if ([ele containsString:XMWifiGroupNameFileName]) continue;
            if ([ele containsString:defaultGroupName]) continue;
            if ([ele containsString:backupGroupName]) continue;
            XMWifiTransModel *model = [[XMWifiTransModel alloc] init];
            model.groupName = ele;
            model.isBackup = NO;
            [dirsArr addObject:model];
        }
    }
//    [self saveGroupMessageWithNewArray:dirsArr];
    [self saveGroupMessageWithNewArray:dirsArr];
    return dirsArr;
}

/// 将文件夹组写进沙盒
+ (void)saveGroupMessageWithNewArray:(NSArray *)newArr{
//    [newArr writeToFile:[XMSavePathUnit getWifiGroupNameFilePath] atomically:YES];
    [NSKeyedArchiver archiveRootObject:newArr toFile:[XMSavePathUnit getWifiGroupNameFilePath]];
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

/// 获取时间戳
+ (NSString *)getNowTimeTimestamp{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    [formatter setDateFormat:@"YYYY-MM-dd_HH:mm:ss"];
    NSDate *datenow = [NSDate date];
    //将nsdate按formatter格式转成nsstring
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    return currentTimeString;
    
}

@end
