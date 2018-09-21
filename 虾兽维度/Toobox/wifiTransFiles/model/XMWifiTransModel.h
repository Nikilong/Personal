//
//  XMWifiTransModel.h
//  虾兽维度
//
//  Created by Niki on 18/5/6.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const fileTypeCodeName;       // 代码文件
extern NSString * const fileTypeImageName;      // 图片文件
extern NSString * const fileTypeVideoName;      // 视频文件
extern NSString * const fileTypeAudioName;      // 音频文件
extern NSString * const fileTypeSettingName;    // 配置文件
extern NSString * const fileTypeZipName;        // 压缩文件

@interface XMWifiTransModel : NSObject

//// 文件的属性
@property (nonatomic, copy) NSString *fileName;     // 文件名称,可能带组别的信息,带格式后缀,如111.png
@property (nonatomic, copy) NSString *pureFileName; // 真正的文件名称(名称+格式)
@property (nonatomic, copy) NSString *sizeStr;          // 文件大小,字符串
@property (nonatomic, assign) unsigned long long size;  // 文件大小,实际大小
@property (nonatomic, copy) NSString *fullPath;     // 全路径(root + '/' + fileName)
@property (nonatomic, copy) NSString *rootPath;     // 根路径
@property (nonatomic, copy) NSString *prePath;      // 相对WifiTransPort的路径(不包含文件名,例如WifiTransPort/默认/)
@property (nonatomic, copy) NSString *fileType;     // 文件类型
@property (nonatomic, assign) BOOL isDir;        // 是否是文件夹
@property (nonatomic, copy) NSString *createDateStr;   // 创建时间
@property (nonatomic, assign) unsigned long long createDateCount;   // 创建时间
@property (nonatomic, copy) NSString *mediaLengthStr;   // 时长(音频,视频类)


//// 文件夹的属性
@property (nonatomic, copy) NSString *groupName;    // 文件夹名称
@property (nonatomic, assign) BOOL isBackup;        // 是否备份


/// 根据文件夹的全路径获得文件模型
+ (NSMutableArray *)getFilesModelAtDirFullPath:(NSString *)groupFullPath isReturnAllFile:(BOOL)isAllFile;

@end
