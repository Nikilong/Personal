//
//  XMWifiTransModel.m
//  虾兽维度
//
//  Created by Niki on 18/5/6.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMWifiTransModel.h"

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

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.groupName forKey:@"groupName"];
    [aCoder encodeBool:self.isBackup forKey:@"isBackup"];
}

@end
