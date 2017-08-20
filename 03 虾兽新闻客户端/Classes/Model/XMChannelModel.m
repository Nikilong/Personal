//
//  XMChannelModel.m
//  03 虾兽新闻客户端
//
//  Created by Niki on 17/3/25.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "XMChannelModel.h"

@implementation XMChannelModel

+ (NSArray *)channels
{
    return [self getChannelFromPlistName:@"web.plist"];
}

+ (NSArray *)specialChannels
{
    return [self getChannelFromPlistName:@"webSpecial.plist"];
}

+ (NSArray *)getChannelFromPlistName:(NSString *)name
{
    NSArray *channelArr = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:nil]];
    NSMutableArray *arrM = [NSMutableArray array];
    for (NSDictionary *dict in channelArr) {
        XMChannelModel *model = [[XMChannelModel alloc] init];
        model.channel = dict[@"channel"];
        model.url = dict[@"url"];
        model.tags = dict[@"tags"];
        [arrM addObject:model];
    }
    return arrM;
}
@end
