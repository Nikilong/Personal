//
//  XMSaveWebModelLogic.h
//  虾兽维度
//
//  Created by Niki on 2018/9/27.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMSaveWebModel.h"

extern NSString *const XMSavewebsDefaultGroupName;

@interface XMSaveWebModelLogic : NSObject

#pragma mark --- 用于wkwebmodule和saveWebmodule
/// 判断该网址是否已经保存
+ (BOOL)isWebURLHaveSave:(NSString *)url;
/// 保存网址
+ (void)saveWebUrl:(NSString *)url title:(NSString *)title;
/// 删除已保存网址
+ (void)deleteWebURL:(NSString *)url;
/// 已保存网址列表
+ (NSMutableArray<XMSaveWebModel *> *)webModelsWithGroupName:(NSString *)groName;
/// 已保存网址文件夹列表
+ (NSArray<NSString *> *)webModelsGroups;
/// 添加一个收藏分组
+ (void)addSaveGroupWithName:(NSString *)name;
/// 删除一个收藏分组
+ (void)deleteSaveGroupWithName:(NSString *)name;
/// 修改收藏分组名称
+ (void)renameSaveGroupWithNewname:(NSString *)newName oldName:(NSString *)oldName;
/// 移动标签到某个组
+ (void)moveSavemodels:(NSArray<NSIndexPath *> *)saveArr fromGroup:(NSString *)fromGroName toGroup:(NSString *)toGroName;


/// 保存浏览历史
+ (void)saveHistoryUrl:(NSString *)url title:(NSString *)title;
/// 获取浏览历史的model数据
+ (NSArray<XMSaveWebModel *> *)getHistoryModelArray;
/// 根据索引,该方法用于侧滑删除,不用遍历数组,删除某条历史记录
+ (void)deleteWebModelHistoryAtIndex:(NSUInteger)index;
/// 批量删除历史记录
+ (void)deleteWebModelHistoryWithNumber:(NSUInteger)count;

/// 从历史记录或者书签中搜索是否有关键字
+ (NSArray<XMSaveWebModel *> *)searchForKeywordInWebData:(NSString *)keyworld;

@end
