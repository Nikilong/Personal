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


#pragma mark --- 用于wkwebmodule和saveWebmodule
/// 判断该网址是否已经保存
+ (BOOL)isWebURLHaveSave:(NSString *)url;
/// 保存网址
+ (void)saveWebModel:(XMWebModel *)webModel;
/// 删除已保存网址
+ (void)deleteWebURL:(NSString *)url;
+ (void)deleteWebModelAtIndex:(NSUInteger)index;
/// 已保存网址列表
+ (NSArray *)webModels;


/// 保存浏览历史
+ (void)saveHistoryUrl:(NSString *)url title:(NSString *)title;
/// 获取浏览历史
+ (NSArray *)getHistoryUrlArray;
/// 根据索引,该方法用于侧滑删除,不用遍历数组,删除某条历史记录
+ (void)deleteWebModelHistoryAtIndex:(NSUInteger)index;
/// 批量删除历史记录
+ (void)deleteWebModelHistoryWithNumber:(NSUInteger)count;

@end
