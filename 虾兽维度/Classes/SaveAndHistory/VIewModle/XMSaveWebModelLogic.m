//
//  XMSaveWebModelLogic.m
//  虾兽维度
//
//  Created by Niki on 2018/9/27.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMSaveWebModelLogic.h"
#import <UIKit/UIKit.h>


#import "XMWebModel.h"

@implementation XMSaveWebModelLogic


static NSMutableArray *_saveWebModelArr;
NSString *const XMSavewebsDefaultGroupName = @"收藏";

+ (void)initialize{
    [super initialize];
    
    if (!_saveWebModelArr){
        _saveWebModelArr = [NSMutableArray array];
    }
    if([[NSFileManager defaultManager] fileExistsAtPath:[XMSavePathUnit getSaveWebModelNewArchicerPath]]){ // 新
        _saveWebModelArr = [self unarchiveSaveWebmodel];
    }else if([[NSFileManager defaultManager] fileExistsAtPath:[XMSavePathUnit getSaveWebModelArchicerPath]]){  // 旧
        // 旧的plist文件为XMWebModel,全部转为XMSaveWebModel,且统一归纳到default分组(实际上default分组并不像其他组那样存在一个XMSaveWebModel)
        NSArray *arr = [[NSKeyedUnarchiver unarchiveObjectWithFile:[XMSavePathUnit getSaveWebModelArchicerPath]] copy];
        if(arr.count > 0){
            for (XMWebModel *model in arr) {
                XMSaveWebModel *modelNew = [[XMSaveWebModel alloc] init];
                modelNew.url = model.webURL.absoluteString;
                modelNew.title = model.title;
                modelNew.isGroup = NO;
                modelNew.groupName = XMSavewebsDefaultGroupName;
                [_saveWebModelArr addObject:modelNew];
            }
        }
        //  将表情数组保存进沙盒
        [self archiveSaveWebmodel];
    }
    
}

+ (NSMutableArray<XMSaveWebModel *> *)webModelsWithGroupName:(NSString *)groName{
    NSMutableArray *groArr = [NSMutableArray array];
    for (XMSaveWebModel *model in _saveWebModelArr) {
        // 默认加载所有分组和未分组的标签,进入某个分组之后不加载组
        if([groName isEqualToString:XMSavewebsDefaultGroupName]){
            if(model.isGroup){
                [groArr addObject:model];
            }else if ([model.groupName isEqualToString:groName]){
                [groArr addObject:model];
            }
        }else{
            if(!model.isGroup && [model.groupName isEqualToString:groName]){
                [groArr addObject:model];
            }
        }
    }
    return groArr;
}

+ (NSArray<NSString *> *)webModelsGroups{
    NSMutableArray *groArr = [NSMutableArray array];
    // 添加"收藏"分组
    XMSaveWebModel *model = [[XMSaveWebModel alloc] init];
    model.isGroup = YES;
    model.groupName = XMSavewebsDefaultGroupName;
    [groArr addObject:model];
    
    // 添加其他的分组
    for (XMSaveWebModel *model in _saveWebModelArr) {
        if(model.isGroup){
            [groArr addObject:model];
        }
    }
    return [groArr copy];
}

/// 将网页数组保存进沙盒
+ (BOOL)archiveSaveWebmodel{
//    return NO;
    return [NSKeyedArchiver archiveRootObject:_saveWebModelArr toFile:[XMSavePathUnit getSaveWebModelNewArchicerPath]];
}

/// 从沙盒读取保存的网页
+ (instancetype)unarchiveSaveWebmodel{
    return [[NSKeyedUnarchiver unarchiveObjectWithFile:[XMSavePathUnit getSaveWebModelNewArchicerPath]] mutableCopy];
}

/// 保存网址
+ (void)saveWebUrl:(NSString *)url title:(NSString *)title{
    XMSaveWebModel *model = [[XMSaveWebModel alloc] init];
    model.url = url;
    model.title = title;
    model.groupName = XMSavewebsDefaultGroupName;
    model.isGroup = NO;
    //  将最新使用的表情插到数组的前面
    [_saveWebModelArr insertObject:model atIndex:0];
    //  将表情数组保存进沙盒
    [self archiveSaveWebmodel];
}

/// 判断该网址是否已经保存
+ (BOOL)isWebURLHaveSave:(NSString *)url{
    for (XMSaveWebModel *model in _saveWebModelArr) {
        if ([model.url isEqualToString:url]){
            return YES;
        }
    }
    return NO;
}

/// 根据url来删除
+ (void)deleteWebURL:(NSString *)url{
    NSInteger index = -1;
    for (NSUInteger i = 0; i < _saveWebModelArr.count; i++) {
        XMSaveWebModel *model = _saveWebModelArr[i];
        if ([model.url isEqualToString:url]){
            index = i;
            break;
        }
    }
    if (index >= 0){
        [_saveWebModelArr removeObjectAtIndex:index];
    }
    //  将表情数组保存进沙盒
    [self archiveSaveWebmodel];
}

/// 添加一个收藏分组
+ (void)addSaveGroupWithName:(NSString *)name{
    XMSaveWebModel *model = [[XMSaveWebModel alloc] init];
    model.groupName = name;
    model.isGroup = YES;
    [_saveWebModelArr insertObject:model atIndex:0];
    [self archiveSaveWebmodel];
}

/// 删除一个收藏分组
+ (void)deleteSaveGroupWithName:(NSString *)name{
    
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for (NSUInteger i = 0; i < _saveWebModelArr.count; i++) {
        XMSaveWebModel *model = _saveWebModelArr[i];
        if([model.groupName isEqualToString:name]){
            [indexSet addIndex:i];
        }
    }
    
    [_saveWebModelArr removeObjectsAtIndexes:indexSet];
    [self archiveSaveWebmodel];
}

/// 修改收藏分组名称
+ (void)renameSaveGroupWithNewname:(NSString *)newName oldName:(NSString *)oldName{
    for (XMSaveWebModel *model in _saveWebModelArr) {
        if([model.groupName isEqualToString:oldName]){
            model.groupName = newName;
        }
    }
    [self archiveSaveWebmodel];
}

/// 移动标签到某个组,(saveArr包含了所有选择的indexPath)
+ (void)moveSavemodels:(NSArray<NSIndexPath *> *)saveArr fromGroup:(NSString *)fromGroName toGroup:(NSString *)toGroName{
    NSMutableArray *froArr = [self webModelsWithGroupName:fromGroName];
    for (NSIndexPath *indexP in saveArr){
        XMSaveWebModel *model = froArr[indexP.row];
        model.groupName = toGroName;
    }
    
    [self archiveSaveWebmodel];
}

#pragma mark 浏览历史
/// 保存浏览历史
+ (void)saveHistoryUrl:(NSString *)url title:(NSString *)title{
    // 读取旧数据
    NSMutableArray *oldArr = [NSMutableArray arrayWithArray:[self getHistoryUrlArray]];
    [oldArr insertObject:@{@"url":url,@"title":title} atIndex:0];
    // 暂时设定为保存100条记录
    if(oldArr.count > 100){
        [oldArr removeLastObject];
    }
    
    // 保存新数据
    NSArray *newArr = [NSArray arrayWithArray:oldArr];
    [NSKeyedArchiver archiveRootObject:newArr toFile:[XMSavePathUnit getWebModelHistoryUrlArchicerPath]];
    
}

/// 获取浏览历史的model数据
+ (NSArray<XMSaveWebModel *> *)getHistoryModelArray{
    NSMutableArray *webmodelArr = [NSMutableArray array];
    NSArray *saveArr = [self getHistoryUrlArray];
    // 将字典转为模型数组
    for (NSDictionary *dict in saveArr) {
        XMSaveWebModel *model = [[XMSaveWebModel alloc] init];
        model.title = dict[@"title"];
        model.url = dict[@"url"];
        [webmodelArr addObject:model];
    }
    return webmodelArr;
}

/// 获取浏览历史
+ (NSArray<NSDictionary *> *)getHistoryUrlArray{
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[XMSavePathUnit getWebModelHistoryUrlArchicerPath]];
}

/// 根据索引,该方法用于侧滑删除,不用遍历数组,删除某条历史记录
+ (void)deleteWebModelHistoryAtIndex:(NSUInteger)index{
    // 读取旧数据
    NSMutableArray *oldArr = [NSMutableArray arrayWithArray:[self getHistoryUrlArray]];
    [oldArr removeObjectAtIndex:index];
    // 保存新数据
    [NSKeyedArchiver archiveRootObject:oldArr toFile:[XMSavePathUnit getWebModelHistoryUrlArchicerPath]];
}

/// 批量删除历史记录
+ (void)deleteWebModelHistoryWithNumber:(NSUInteger)count{
    // 读取旧数据
    NSMutableArray *oldArr = [NSMutableArray arrayWithArray:[self getHistoryUrlArray]];
    if(count > oldArr.count){
        oldArr = [NSMutableArray array];
    }else{
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, count)];
        [oldArr removeObjectsAtIndexes:indexSet];
    }
    // 保存新数据
    [NSKeyedArchiver archiveRootObject:oldArr toFile:[XMSavePathUnit getWebModelHistoryUrlArchicerPath]];
}

/// 从历史记录或者书签中搜索是否有关键字
+ (NSArray<XMSaveWebModel *> *)searchForKeywordInWebData:(NSString *)keyworld{
    NSMutableArray *resultArr = [NSMutableArray array];
    // 书签中寻找
    for (XMSaveWebModel *model in _saveWebModelArr) {
        if([model.title containsString:keyworld]){
            [resultArr addObject:model];
        }else if([model.url containsString:keyworld]){
            [resultArr addObject:model];
        }
    }
    // 历史浏览记录中查找
    NSArray *historyArr = [self getHistoryModelArray];
    for (XMSaveWebModel *model in historyArr) {
        if([model.title containsString:keyworld]){
            [resultArr addObject:model];
        }else if([model.url containsString:keyworld]){
            [resultArr addObject:model];
        }
    }
    return resultArr;
}


@end
