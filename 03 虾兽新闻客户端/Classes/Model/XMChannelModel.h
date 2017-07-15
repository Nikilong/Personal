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

+ (NSArray *)channels;

@end
