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

/// 返回一个数组,包含所有配置类文件的全路径
+ (NSArray *)getSettingFilesPaths{
    return @[[self getHiwebHomeUrlPath],[self getWifiGroupNameFilePath],[self getSaveWebModelArchicerPath],[self getWifiGroupMarkZipFilePath]];
}

@end
