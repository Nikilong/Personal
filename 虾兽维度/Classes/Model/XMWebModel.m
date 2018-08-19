//
//  XMWebModel.m
//  虾兽维度
//
//  Created by admin on 17/2/28.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "XMWebModel.h"

@interface XMWebModel()<NSCoding>

@end

@implementation XMWebModel

#pragma mark - NSCoding
/** 读档 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]){
        self.imageURL = [aDecoder decodeObjectForKey:@"imageURL"];
        self.ID = [aDecoder decodeObjectForKey:@"ID"];
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.webURL = [aDecoder decodeObjectForKey:@"webURL"];
        self.source = [aDecoder decodeObjectForKey:@"source"];
        self.cmt_cnt = [[aDecoder decodeObjectForKey:@"source"] integerValue];
        self.publishTime = [aDecoder decodeObjectForKey:@"publishTime"];
        self.author_icon = [aDecoder decodeObjectForKey:@"author_icon"];
        self.searchMode = [aDecoder decodeBoolForKey:@"searchMode"];
    }
    return self;
}

/** 存档 */
- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.imageURL forKey:@"imageURL"];
    [aCoder encodeObject:self.ID forKey:@"ID"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.webURL forKey:@"webURL"];
    [aCoder encodeObject:self.source forKey:@"source"];
    [aCoder encodeObject:@(self.cmt_cnt) forKey:@"cmt_cnt"];
    [aCoder encodeObject:self.publishTime forKey:@"publishTime"];
    [aCoder encodeObject:self.author_icon forKey:@"author_icon"];
    [aCoder encodeBool:self.isSearchMode forKey:@"searchMode"];
    
}

@end
