//
//  XMSavePathUnit.m
//  虾兽维度
//
//  Created by Niki on 18/5/15.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMSavePathUnit.h"

/// wifi模块
/// wifi传输的保存沙盒路径(主路径)
NSString * const XMWifiMainDirName = @"WifiTransPort";
NSString * const XMWifiGroupNameFileName = @"XMWifiGroupName.wifign";  // 分组的model归档文件名
NSString * const XMWifiGroupMarkZipFileName = @"XMWifiGroupZipMark.wifign";  // 需要备份的文件夹的文件名

@implementation XMSavePathUnit

/// app的documents路径
+ (NSString *)getDocumentsPath{
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
}

/// app的tmp路径
+ (NSString *)getTmpPath{
    return NSTemporaryDirectory();
}

/// web模块收藏网页的文件保存路径
+ (NSString *)getSaveWebModelArchicerPath{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"webModel.archiver"];
}

/// web模块浏览历史记录的文件保存路径
+ (NSString *)getWebModelHistoryUrlArchicerPath{
    return [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"webHistory.archiver"];
}

/// 浮窗webModle的归档文件路径
+ (NSString *)getFloatWindowWebmodelArchivePath{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"WXfloatWebModel.archiver"];
}

/// hiweb主页路径
+ (NSString *)getHiwebHomeUrlPath{
    return [[self getDocumentsPath] stringByAppendingPathComponent:@"hiweb.homeurl"];
}

/// wifi传输的图片缓存保存沙盒路径
+ (NSString *)getWifiImageTempDirPath{
    return [[self getWifiUploadDirPath] stringByAppendingPathComponent:@"ImgTemp"];
}

/// wifi传输的保存沙盒路径
+ (NSString *)getWifiUploadDirPath{
    return [NSString stringWithFormat:@"%@/%@",[self getDocumentsPath],XMWifiMainDirName];
}


/// wifi传输需要压缩备份的组名列表保存路径
+ (NSString *)getWifiGroupMarkZipFilePath{
    return [NSString stringWithFormat:@"%@/%@",[self getWifiUploadDirPath],XMWifiGroupMarkZipFileName];
}

/// wifi传输组名列表保存路径
+ (NSString *)getWifiGroupNameFilePath{
    return [NSString stringWithFormat:@"%@/%@",[self getWifiUploadDirPath],XMWifiGroupNameFileName];
}


/// 主页频道文件的保存路径
+ (NSString *)getMainLeftSaveChannelPath{
    NSString *dirPath = [NSString stringWithFormat:@"%@/MainLeftChannel",[self getDocumentsPath]];
    if(![[NSFileManager defaultManager] fileExistsAtPath:dirPath]){
        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [NSString stringWithFormat:@"%@/XMMainLeftChannel.archiver",dirPath];
}

/// 主页历史新闻存档路径,不同的channel的文件不一样
+ (NSString *)getMainHistoryNewsPathWithChannel:(NSString *)channel{
    NSString *dirPath = [NSString stringWithFormat:@"%@/HistoryNews",[self getDocumentsPath]];
    if(![[NSFileManager defaultManager] fileExistsAtPath:dirPath]){
        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [NSString stringWithFormat:@"%@/XMHistoryNews-%@.archiver",dirPath,channel];
}

/// webmodule的网络下载的gif的本地缓存路径
+ (NSString *)getWebmoduleGifTempDirectory{
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"gifTemp"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:rootPath]){
        [[NSFileManager defaultManager] createDirectoryAtPath:rootPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return rootPath;
}

/// 返回一个数组,包含所有配置类文件的全路径
+ (NSArray *)getSettingFilesPaths{
    return @[[self getHiwebHomeUrlPath],[self getWifiGroupNameFilePath],[self getSaveWebModelArchicerPath],[self getWifiGroupMarkZipFilePath],[self getMainLeftSaveChannelPath]];
}

@end
