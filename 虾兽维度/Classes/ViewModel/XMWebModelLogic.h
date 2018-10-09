//
//  XMWebModelLogic.h
//  虾兽维度
//
//  Created by Niki on 18/8/19.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMWebModel.h"

@interface XMWebModelLogic : NSObject

#pragma mark --- 用于home和main两个控制器
/// 将json的dict转换成数据模型
+ (NSArray *)websWithDict:(NSDictionary *)dict refreshCount:(NSUInteger)count keyWordArray:(NSArray *)keyWordArr channel:(NSString *)channel;

/// 读取对应频道的历史新闻
+ (NSArray *)unarchiveHistoryNewsArrayWithChannel:(NSString *)channel;

/// web的网址，需要拼接参数
+ (NSString *)appendWebURLByName:(NSString *)name;

/// 获取频道历史数据的更新时间
+ (NSString *)getHistoryNewUpdateTimeWithChannel:(NSString *)channel;

@end
