//
//  XMChannelModel.h
//  虾兽维度
//
//  Created by Niki on 17/3/25.
//  Copyright © 2017年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMChannelModel : NSObject<NSCoding>

@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *channel;
@property (nonatomic, strong) NSArray *tags;

// uc新闻频道
+ (NSArray *)channels;
// 特别频道
+ (NSArray *)specialChannels;

// 左侧栏添加一个新url
+ (BOOL)specialChannelAddNewChannelName:(NSString *)name url:(NSString *)url;
/// 左侧栏删除一条网址
+ (BOOL)specialChannelRemoveChannelAtIndex:(NSUInteger )index;
/// 左侧栏重命名或修改url
+ (BOOL)specialChannelRenameChannelName:(NSString *)name url:(NSString *)url index:(NSUInteger)index;


// 使用说明书
+ (NSString *)userGuild;

@end
