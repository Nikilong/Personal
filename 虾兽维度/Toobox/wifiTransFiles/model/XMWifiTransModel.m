//
//  XMWifiTransModel.m
//  虾兽维度
//
//  Created by Niki on 18/5/6.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMWifiTransModel.h"
#import "XMWifiGroupTool.h"
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>
#import <UIKit/UIKit.h>

NSString * const fileTypeCodeName = @"code";
NSString * const fileTypeImageName = @"image";
NSString * const fileTypeVideoName = @"video";
NSString * const fileTypeAudioName = @"audio";
NSString * const fileTypeSettingName = @"setting";
NSString * const fileTypeZipName = @"zip";


@interface XMWifiTransModel()<NSCoding>


@end

@implementation XMWifiTransModel

/** 归档 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        self.groupName = [aDecoder decodeObjectForKey:@"groupName"];
        self.isBackup = [aDecoder decodeBoolForKey:@"isBackup"];
        
    }
    return self;
}

/// 解析
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.groupName forKey:@"groupName"];
    [aCoder encodeBool:self.isBackup forKey:@"isBackup"];
}


/// 根据文件夹的全路径获得文件模型
+ (NSMutableArray *)getFilesModelAtDirFullPath:(NSString *)groupFullPath isReturnAllFile:(BOOL)isAllFile{

    NSMutableArray *fileFilterArr = [NSMutableArray array];
    NSArray *fileArr = [[NSFileManager defaultManager] subpathsAtPath:groupFullPath];
    NSDictionary *dict = @{};
    BOOL dirFlag = NO;
    for (NSString *ele in fileArr) {
        if([ele containsString:@"DS_Store"]) continue;
        // "所有"要过滤空文件夹 isAllFile = yes
        [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@",groupFullPath,ele] isDirectory:&dirFlag];
        if (isAllFile && dirFlag){
            continue;
        }
        
        // 转换为模型
        XMWifiTransModel *model = [[XMWifiTransModel alloc] init];
        dict = [[NSFileManager defaultManager] attributesOfItemAtPath:[NSString stringWithFormat:@"%@/%@",groupFullPath,ele] error:nil];
        model.isDir = dirFlag;
        model.fileName = ele;
        model.pureFileName = [ele lastPathComponent];
        model.prePath = [model.fileName stringByReplacingOccurrencesOfString:model.pureFileName withString:@""];
        model.rootPath = groupFullPath;
        model.fullPath = [NSString stringWithFormat:@"%@/%@",groupFullPath,ele];
        model.size = dict.fileSize;
        model.createDateStr = [XMWifiGroupTool dateChangeToString:dict.fileCreationDate];
        model.createDateCount = dict.fileCreationDate.timeIntervalSince1970;
        // 文件大小
        if(dict.fileSize < 1024){
            model.sizeStr = [NSString stringWithFormat:@"%.2llu Byte",dict.fileSize];
        }else if (dict.fileSize < 1024 * 1024){
            model.sizeStr = [NSString stringWithFormat:@"%.2fK",dict.fileSize / 1024.0];
        }else{
            model.sizeStr = [NSString stringWithFormat:@"%.2fM",dict.fileSize / 1024.0 / 1024.0];
        }

        if (model.isDir){
            model.fileType = @"folder";
        }else{
        
            NSString *exten = [model.fileName.pathExtension lowercaseString];
            // 注意格式的被包含关系,如.mp3文件包含.m和.mp3格式
            if ([@"py|sh|h|m|c|o|js|json|xml" containsString:exten]){
                model.fileType = fileTypeCodeName;
            }else if ([@"png|jpg|jpeg|gif|bmp|tiff|pcx|tga|exif|fpx|svg|psd|cdr|pcd|dxf|ufo|eps|ai|raw|wmf|webp|heic" containsString:exten]){
                model.fileType = fileTypeImageName;
                if ([exten isEqualToString:@"gif"]){
                    model.gifImageArr = [self seprateGifAtPath:model.fullPath];
                }
                
            }else if ([@"avi|wmv|mpeg|mp4|mov|mkv|flv|f4v|m4v|rmvb|rm|3gp|dat|ts|mts|vob" containsString:exten]){
                model.fileType = fileTypeVideoName;
                model.mediaLengthStr = [self getMediaLengthString:model.fullPath];
            }else if ([@"mp3|wav|wma|ape|rm|vqf|ogg|asf|mp3pro|real|module|midi" containsString:exten]){
                model.fileType = fileTypeAudioName;
                model.mediaLengthStr = [self getMediaLengthString:model.fullPath];
            }else if ([@"homeurl|archiver|wifign" containsString:exten]){
                model.fileType = fileTypeSettingName;
            }else if ([@"zip|rar" containsString:exten]){
                model.fileType = fileTypeZipName;
                //            }else if ([@"||" containsString:exten]){
            }else{
                model.fileType = model.fileName.pathExtension;
            }
        }
        
        [fileFilterArr addObject:model];
        
    }
    return fileFilterArr;
}
    
/// 将gif分解为图片组
+ (NSArray *)seprateGifAtPath:(NSString *)path{
    
    NSURL *gifImageUrl = [NSURL fileURLWithPath:path];
    //获取Gif图的原数据
    CGImageSourceRef gifSource = CGImageSourceCreateWithURL((CFURLRef)gifImageUrl, NULL);
    
    //获取Gif图有多少帧
    size_t gifcount = CGImageSourceGetCount(gifSource);
    NSMutableArray *imageS = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < gifcount; i++) {
        //由数据源gifSource生成一张CGImageRef类型的图片
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(gifSource, i, NULL);
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        [imageS addObject:image];
        CGImageRelease(imageRef);
    }
    //得到图片数组
    return imageS;
}



/// 获取音频视频类时长
+ (NSString *)getMediaLengthString:(NSString *)path{
    NSURL *url = [NSURL fileURLWithPath:path];
//    NSDictionary *opts = [NSDictionary dictionaryWithObject:@(NO) forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:url options:nil]; // 初始化视频媒体文件
    NSUInteger second = 0;
    second = urlAsset.duration.value / urlAsset.duration.timescale; // 获取视频总时长,单位秒
    NSString *string = @"";
    if(second == 0){
        string = @"未知";
    }else if(second < 60){
        string = [NSString stringWithFormat:@"%zd秒",second];
    }else if(second < 3600){
        string = [NSString stringWithFormat:@"%ld分%zd秒",second/60,second%60];
    }else{
        NSUInteger hourC = second/3600;
        NSUInteger miniC = (second - hourC * 3600) / 60;
        NSUInteger secC = (second - hourC * 3600) % 60;
        string = [NSString stringWithFormat:@"%ld时%ld分%zd秒",hourC,miniC,secC];
    }
    return string;
}

@end
