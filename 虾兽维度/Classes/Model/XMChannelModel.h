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


@end
