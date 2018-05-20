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
NSString * const XMWifiGroupNameFileName = @"XMWifiGroupName.wifign";

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

/// wifi传输的保存沙盒路径
+ (NSString *)getWifiUploadDirPath{
    return [NSString stringWithFormat:@"%@/%@",[self getDocumentsPath],XMWifiMainDirName];
}


/// wifi传输组名列表保存路径
+ (NSString *)getWifiGroupNameFilePath{
    return [NSString stringWithFormat:@"%@/%@",[self getWifiUploadDirPath],XMWifiGroupNameFileName];
}

@end
