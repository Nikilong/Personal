//
//  XMTimeTool.h
//  虾兽维度
//
//  Created by Niki on 2018/8/17.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMTimeTool : NSObject

/// 获取系统当前时间作为发布时间,格式: x时x分x秒
+ (NSString *)getNewsPublishTime;

/// 获取音频视频类时长
+ (NSString *)getMediaLengthString:(NSString *)path;

/// 将旧的保存时间和当前时间作比较,得出相对时长的描述,例如"刚刚","x分钟前","x小时前"
+ (NSString *)oldTimeCountChangToString:(NSTimeInterval)saveTime;

/// 将日期转为字符串类型时间戳,需要传入转换格式,如果是nil则采用默认"YYYY-MM-dd HH:mm:ss:"
+ (NSString *)dateChangeToString:(NSDate *)date formatString:(NSString *)formatStr;

@end
