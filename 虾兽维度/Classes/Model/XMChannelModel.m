//
//  XMChannelModel.m
//  虾兽维度
//
//  Created by Niki on 17/3/25.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "XMChannelModel.h"

@implementation XMChannelModel

#pragma mark - 归档
/** 读档 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]){
        self.channel = [aDecoder decodeObjectForKey:@"channel"];
        self.url = [aDecoder decodeObjectForKey:@"url"];
    }
    return self;
}

/** 存档 */
- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.channel forKey:@"channel"];
    [aCoder encodeObject:self.url forKey:@"url"];
    
}

@end
