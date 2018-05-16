//
//  XMSavePathUnit.h
//  虾兽维度
//
//  Created by Niki on 18/5/15.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const XMWifiMainDirName;
extern NSString *const XMWifiGroupNameFileName;

@interface XMSavePathUnit : NSObject

/// app的documents路径
+ (NSString *)getDocumentsPath;
/// app的tmp路径
+ (NSString *)getTmpPath;

/// web模块收藏网页的文件保存路径
+ (NSString *)getSaveWebModelArchicerPath;

/// hiweb主页路径
+ (NSString *)getHiwebHomeUrlPath;

/// wifi传输的保存沙盒路径
+ (NSString *)getWifiUploadDirPath;
/// wifi传输组名列表保存路径
+ (NSString *)getWifiGroupNameFilePath;

@end
