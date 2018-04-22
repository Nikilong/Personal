//
//  XMChannelModel.h
//  03 虾兽新闻客户端
//
//  Created by Niki on 17/3/25.
//  Copyright © 2017年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMChannelModel : NSObject

@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *channel;
@property (nonatomic, strong) NSArray *tags;

// uc新闻频道
+ (NSArray *)channels;
// 特别频道
+ (NSArray *)specialChannels;

// 使用说明书
+ (NSString *)userGuild;

@end
