//
//  XMSaveWebModel.m
//  虾兽维度
//
//  Created by Niki on 2018/9/27.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMSaveWebModel.h"

@interface XMSaveWebModel()<NSCoding>

@end

@implementation XMSaveWebModel

#pragma mark - NSCoding
/** 读档 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]){
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.url = [aDecoder decodeObjectForKey:@"url"];
        self.groupName = [aDecoder decodeObjectForKey:@"groupName"];
        self.isGroup = [aDecoder decodeBoolForKey:@"isGroup"];
    }
    return self;
}

/** 存档 */
- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.url forKey:@"url"];
    [aCoder encodeObject:self.groupName forKey:@"groupName"];
    [aCoder encodeBool:self.isGroup forKey:@"isGroup"];
}

@end
