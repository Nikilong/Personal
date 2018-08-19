//
//  XMTimeTool.m
//  虾兽维度
//
//  Created by Niki on 2018/8/17.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMTimeTool.h"
#import <AVFoundation/AVFoundation.h>

@implementation XMTimeTool

// 获取系统当前时间作为发布时间,格式: x时x分x秒
+ (NSString *)getNewsPublishTime{
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    //组合元素（时分秒）
    NSDateComponents *components = [calendar components:kCFCalendarUnitHour|kCFCalendarUnitMinute|NSCalendarUnitSecond  fromDate:[NSDate date]];
    NSString *time = [NSString stringWithFormat:@"%ld时%ld分%ld秒",components.hour,components.minute,components.second];
    
    return time;
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

/// 将旧的保存时间和当前时间作比较,得出相对时长的描述,例如"刚刚","x分钟前","x小时前"
+ (NSString *)oldTimeCountChangToString:(NSTimeInterval)saveTime{
    double minisTime = [[NSDate date] timeIntervalSince1970] - saveTime;
    NSString *text = @"";
    if(minisTime < 60){
        // 一分钟之内,按"刚刚"
        text = @"刚刚";
    }else if(minisTime < 3600){
        // 一小时之内,按分钟算
        int mininus = minisTime / 60;
        text = [NSString stringWithFormat:@"%d分钟前",mininus];
    }else if(minisTime < 21600){
        // 一天之内,按小时算
        int days = minisTime / 3600;
        text = [NSString stringWithFormat:@"%d小时前",days];
    }else if(minisTime < 2592000){
        // 30天内
        int days = minisTime / 86400;
        text = [NSString stringWithFormat:@"%d天前",days];
    }else{
        text =  [XMTimeTool dateChangeToString:[NSDate date] formatString:nil];
    }
    
    return text;
}

/// 将日期转为字符串类型时间戳,需要传入转换格式,如果是nil则采用默认"YYYY-MM-dd HH:mm:ss:"
+ (NSString *)dateChangeToString:(NSDate *)date formatString:(NSString *)formatStr{
    if (!formatStr){
        formatStr = @"YYYY-MM-dd HH:mm:ss";
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    [formatter setDateFormat:formatStr];
    //将nsdate按formatter格式转成nsstring
    NSString *currentTimeString = [formatter stringFromDate:date];
    return currentTimeString;
    
}

@end
