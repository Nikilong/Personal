//
//  XMWebModel.m
//  03 虾兽新闻客户端
//
//  Created by admin on 17/2/28.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "XMWebModel.h"

@interface XMWebModel()<NSCoding>

@property (nonatomic, strong) NSMutableArray *arr;

@end

@implementation XMWebModel

+ (NSArray *)websWithDict:(NSDictionary *)dict refreshCount:(NSUInteger)count
{
    NSMutableArray *arrM = [NSMutableArray array];

    for (int i = 0; i < count; i++)
    {
        XMWebModel *model = [[XMWebModel alloc] init];
        
        model.ID = dict[@"data"][@"items"][i][@"id"];
        model.webURL = [NSURL URLWithString:XMWebURL(model.ID)];
        model.cmt_cnt = [dict[@"data"][@"articles"][model.ID][@"cmt_cnt"] unsignedIntegerValue];
        model.source = dict[@"data"][@"articles"][model.ID][@"source_name"];
        
        NSString *title = dict[@"data"][@"articles"][model.ID][@"title"];
        if (title)
        {
            model.title = title;
        }else
        {
            model.title = @"文章已经被删除！！";
        }
        model.publishTime = [model getCurrentTime];
        NSArray *arr = dict[@"data"][@"articles"][model.ID][@"thumbnails"];
        // 没有图片的新闻要做一个判断
        if (arr.count)
        {
            model.imageURL = [NSURL URLWithString:dict[@"data"][@"articles"][model.ID][@"thumbnails"][0][@"url"]];
        }
        
        [arrM addObject:model];
    }
    return arrM;
}

// 获取系统当前时间作为发布时间
- (NSString *)getCurrentTime
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    //组合元素（时分秒）
    NSDateComponents *components = [calendar components:kCFCalendarUnitHour|kCFCalendarUnitMinute|NSCalendarUnitSecond  fromDate:[NSDate date]];
    NSString *time = [NSString stringWithFormat:@"%ld时%ld分%ld秒",components.hour,components.minute,components.second];
    
    return time;
}


/** 归档 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        self.imageURL = [aDecoder decodeObjectForKey:@"imageURL"];
        self.ID = [aDecoder decodeObjectForKey:@"ID"];
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.webURL = [aDecoder decodeObjectForKey:@"webURL"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.imageURL forKey:@"imageURL"];
    [aCoder encodeObject:self.ID forKey:@"ID"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.webURL forKey:@"webURL"];
    
}

@end
