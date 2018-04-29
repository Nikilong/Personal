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

+ (NSArray *)websWithDict:(NSDictionary *)dict refreshCount:(NSUInteger)count keyWordArray:(NSArray *)keyWordArr
{
    NSMutableArray *arrM = [NSMutableArray array];
    NSArray *arrOrigin = dict[@"data"][@"items"];
    NSUInteger originNum = arrOrigin.count;

    // 当没有加载够所需数据不结束循环
    for (int i = 0; arrM.count < count; i++)
    {
        // 防止越界,需要重新发送网络请求来获得json数据
        if (i == originNum) break;
        
        // 创建模型
        XMWebModel *model = [[XMWebModel alloc] init];
        
        model.ID = dict[@"data"][@"items"][i][@"id"];
        // 广告的id都是8位,通过id来过滤掉广告
        if (model.ID.integerValue < 99999999) continue;
        
        // 这个tag是分类,可用于过滤
        model.tags = dict[@"data"][@"articles"][model.ID][@"tags"];
        if (keyWordArr.count != 0)
        {
            if (![self filterArray:model.tags keyWordArray:keyWordArr])
            {
                continue;
            }
        }
        model.webURL = [NSURL URLWithString:XMWebURL(model.ID)];
        model.cmt_cnt = [dict[@"data"][@"articles"][model.ID][@"cmt_cnt"] unsignedIntegerValue];
        model.source = dict[@"data"][@"articles"][model.ID][@"source_name"];
//model.source = model.ID;
//        NSLog(@"%@",dict[@"data"][@"articles"][model.ID][@"dislike_infos"]);
        model.title =  dict[@"data"][@"articles"][model.ID][@"title"];
        // 过滤掉标题为空的新闻
        if (model.title.length == 0 || model.title == nil){
            continue;
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

/** 对新闻关键词过滤 */
+ (BOOL)filterArray:(NSArray *)arrOrigin keyWordArray:(NSArray *)arrKeyWord
{
    // 拼接新闻的tags
    NSMutableString *strM = [NSMutableString string];
    for (NSString *str in arrOrigin) {
        [strM appendString:str];
    }
    
    // 检查是否含有关键字
    for (NSString *kerWordStr in arrKeyWord) {
        if ([strM containsString:kerWordStr])
        {
            return YES;
        }
    }
    // 来到这里表示没有关键字
    return NO;
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
