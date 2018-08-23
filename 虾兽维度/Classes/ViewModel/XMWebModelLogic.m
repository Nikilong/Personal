//
//  XMWebModelLogic.m
//  虾兽维度
//
//  Created by Niki on 18/8/19.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMWebModelLogic.h"
#import "XMSavePathUnit.h"
#import "XMTimeTool.h"

NSString *const XMNewsSaveTimeDictKey = @"XMNewsSaveTimeDictKey";

@interface XMWebModelLogic()

@property (nonatomic, strong) NSMutableArray *arr;

@end

@implementation XMWebModelLogic

#pragma mark --- 用于home和main两个控制器
#pragma mark - model处理方法
/// web的网址，需要拼接参数
+ (NSString *)appendWebURLByName:(NSString *)name{
    return [NSString stringWithFormat:@"http://m.uczzd.cn/webview/news?app=uc-iflow&aid=%@&cid=100&zzd_from=uc-iflow&uc_param_str=dndsfrvesvntnwpfgicp&recoid=3902548323263252739&rd_type=reco&sp_gz=1",name];
}

+ (NSArray *)websWithDict:(NSDictionary *)dict refreshCount:(NSUInteger)count keyWordArray:(NSArray *)keyWordArr channel:(NSString *)channel{
    
    NSMutableArray *arrM = [NSMutableArray array];
    NSArray *arrOrigin = dict[@"data"][@"items"];
    NSUInteger originNum = arrOrigin.count;
    
    // 当没有加载够所需数据不结束循环
    for (int i = 0; arrM.count < count; i++){
        // 防止越界,需要重新发送网络请求来获得json数据
        if (i == originNum) break;
        
        // 创建模型
        XMWebModel *model = [[XMWebModel alloc] init];
        
        model.ID = dict[@"data"][@"items"][i][@"id"];
        // 广告的id都是8位,通过id来过滤掉广告
        if (model.ID.integerValue < 99999999) continue;
        
        // 这个tag是分类,可用于过滤
        model.tags = dict[@"data"][@"articles"][model.ID][@"tags"];
        if (keyWordArr.count != 0){
            if (![self filterArray:model.tags keyWordArray:keyWordArr]){
                continue;
            }
        }
        model.webURL = [NSURL URLWithString:[self appendWebURLByName:model.ID]];
        model.author_icon = [NSURL URLWithString:dict[@"data"][@"articles"][model.ID][@"wm_author"][@"author_icon"][@"url"]];
        model.cmt_cnt = [dict[@"data"][@"articles"][model.ID][@"cmt_cnt"] unsignedIntegerValue];
        model.source = dict[@"data"][@"articles"][model.ID][@"source_name"];
        //model.source = model.ID;
        //        NSLog(@"%@",dict[@"data"][@"articles"][model.ID][@"dislike_infos"]);
        model.title =  dict[@"data"][@"articles"][model.ID][@"title"];
        // 过滤掉标题为空的新闻
        if (model.title.length == 0 || model.title == nil){
            continue;
        }
        model.publishTime = [XMTimeTool getNewsPublishTime];
        NSArray *arr = dict[@"data"][@"articles"][model.ID][@"thumbnails"];
        // 没有图片的新闻要做一个判断
        if (arr.count){
            model.imageURL = [NSURL URLWithString:dict[@"data"][@"articles"][model.ID][@"thumbnails"][0][@"url"]];
        }
        
        [arrM addObject:model];
    }
    
    // 归档数据
    [self saveNewDatasArr:arrM channel:channel];
    
    return arrM;
}

/** 对新闻关键词过滤 */
+ (BOOL)filterArray:(NSArray *)arrOrigin keyWordArray:(NSArray *)arrKeyWord{
    // 拼接新闻的tags
    NSMutableString *strM = [NSMutableString string];
    for (NSString *str in arrOrigin) {
        [strM appendString:str];
    }
    
    // 检查是否含有关键字
    for (NSString *kerWordStr in arrKeyWord) {
        if ([strM containsString:kerWordStr]){
            return YES;
        }
    }
    // 来到这里表示没有关键字
    return NO;
}

#pragma mark - 归档存档

/// 将新的数据保存到归档
+ (void)saveNewDatasArr:(NSArray *)newArr channel:(NSString *)channel{
    NSMutableArray *oldArr = [NSMutableArray arrayWithArray:[self unarchiveHistoryNewsArrayWithChannel:channel]];
    NSMutableArray *hisArr = [NSMutableArray arrayWithArray:[newArr arrayByAddingObjectsFromArray:oldArr]];
    // 限定不超过30条
    while (hisArr.count > 30) {
        [hisArr removeLastObject];
    }
    [self archiveHistoryNewsArray:hisArr channel:channel];
    
    // 保存该频道的刷新时间
    [self updateHistoryNewSaveTimeWithChannel:channel];
}

/// 保存对应频道的历史新闻
+ (BOOL)archiveHistoryNewsArray:(NSArray *)arr channel:(NSString *)channel{
    // 每个频道对应单独的归档文件,减少系统内存负担
    return [NSKeyedArchiver archiveRootObject:arr toFile:[XMSavePathUnit getMainHistoryNewsPathWithChannel:channel]];
}

/// 读取对应频道的历史新闻
+ (NSArray *)unarchiveHistoryNewsArrayWithChannel:(NSString *)channel{
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[XMSavePathUnit getMainHistoryNewsPathWithChannel:channel]];
}


/// 更新历史数据的更新时间
+ (void)updateHistoryNewSaveTimeWithChannel:(NSString *)channel{
    // 取出旧数据
    //    NSString *saveTime = [XMTimeTool dateChangeToString:[NSDate date] formatString:nil];
    double timeCount = [[NSDate date] timeIntervalSince1970];
    NSMutableDictionary *dictM = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] valueForKey:XMNewsSaveTimeDictKey]];
    dictM[channel] = [NSNumber numberWithDouble:timeCount];
    
    // NSDictionary可以存档,但是NSMutableDictionary不可以存档
    NSDictionary *dict = [NSDictionary dictionaryWithDictionary:dictM];
    
    // 记录保存时间
    [[NSUserDefaults standardUserDefaults] setValue:dict forKey:XMNewsSaveTimeDictKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/// 获取频道历史数据的更新时间
+ (NSString *)getHistoryNewUpdateTimeWithChannel:(NSString *)channel{
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] valueForKey:XMNewsSaveTimeDictKey];
    double saveTime = [dict[channel] doubleValue];
    return [XMTimeTool oldTimeCountChangToString:saveTime];
}

#pragma mark --- 用于wkwebmodule和saveWebmodule

static NSMutableArray *_saveWebModelArr;

+ (void)initialize{
    [super initialize];
    
    //  在这里创建一个全局变量
    _saveWebModelArr = (NSMutableArray *)[NSKeyedUnarchiver unarchiveObjectWithFile:[XMSavePathUnit getSaveWebModelArchicerPath]];
    if (!_saveWebModelArr)
    {
        _saveWebModelArr = [NSMutableArray array];
    }
}

+ (void)saveWebModel:(XMWebModel *)webModel{
    
    //  将最新使用的表情插到数组的前面
    [_saveWebModelArr insertObject:webModel atIndex:0];
    //  将表情数组保存进沙盒
    [NSKeyedArchiver archiveRootObject:_saveWebModelArr toFile:[XMSavePathUnit getSaveWebModelArchicerPath]];
}

/// 判断该网址是否已经保存
+ (BOOL)isWebURLHaveSave:(NSString *)url{
    for (XMWebModel *model in _saveWebModelArr) {
        if ([model.webURL.absoluteString isEqualToString:url]){
            return YES;
        }
    }
    return NO;
}

/// 根据url来删除
+ (void)deleteWebURL:(NSString *)url{
    NSInteger index = -1;
    XMWebModel *model;
    for (NSUInteger i = 0; i < _saveWebModelArr.count; i++) {
        model = _saveWebModelArr[i];
        if ([model.webURL.absoluteString isEqualToString:url]){
            index = i;
            break;
        }
    }
    if (index >= 0){
        [_saveWebModelArr removeObjectAtIndex:index];
        //  将表情数组保存进沙盒
        [NSKeyedArchiver archiveRootObject:_saveWebModelArr toFile:[XMSavePathUnit getSaveWebModelArchicerPath]];
    }
}

/// 根据索引,该方法用于侧滑删除,不用遍历数组
+ (void)deleteWebModelAtIndex:(NSUInteger)index{
    //  将最新使用的表情插到数组的前面
    [_saveWebModelArr removeObjectAtIndex:index];
    //  将表情数组保存进沙盒
    [NSKeyedArchiver archiveRootObject:_saveWebModelArr toFile:[XMSavePathUnit getSaveWebModelArchicerPath]];
}

+ (NSArray<XMWebModel *> *)webModels{
    return _saveWebModelArr;
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
+ (NSArray<XMWebModel *> *)getHistoryModelArray{
    NSMutableArray *webmodelArr = [NSMutableArray array];
    NSArray *saveArr = [self getHistoryUrlArray];
    // 将字典转为模型数组
    for (NSDictionary *dict in saveArr) {
        XMWebModel *model = [[XMWebModel alloc] init];
        model.title = dict[@"title"];
        model.webURL = [NSURL URLWithString:dict[@"url"]];
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
+ (NSArray<XMWebModel *> *)searchForKeywordInWebData:(NSString *)keyworld{
    NSMutableArray *resultArr = [NSMutableArray array];
    // 书签中寻找
    NSArray *saveArr = [self webModels];
    for (XMWebModel *model in saveArr) {
        if([model.title containsString:keyworld]){
            [resultArr addObject:model];
        }else if([model.webURL.absoluteString containsString:keyworld]){
            [resultArr addObject:model];
        }
    }
    // 历史浏览记录中查找
    NSArray *historyArr = [self getHistoryModelArray];
    for (XMWebModel *model in historyArr) {
        if([model.title containsString:keyworld]){
            [resultArr addObject:model];
        }else if([model.webURL.absoluteString containsString:keyworld]){
            [resultArr addObject:model];
        }
    }
    return resultArr;
}

@end
