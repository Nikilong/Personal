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
    
    // 改为显示加载的所有数据
    for (int i = 0; i < arrOrigin.count; i++){
////         当没有加载够所需数据不结束循环
//    for (int i = 0; arrM.count < count; i++){
        // 防止越界,需要重新发送网络请求来获得json数据
        if (i == originNum) break;
        
        // 创建模型
        XMWebModel *model = [[XMWebModel alloc] init];
        
        model.ID = dict[@"data"][@"items"][i][@"id"];
        
        model.source = dict[@"data"][@"articles"][model.ID][@"source_name"];
        //model.source = model.ID;
        
        NSLog(@"%@",dict[@"data"][@"articles"][model.ID][@"op_mark"]);
        
        // 过滤广告
        if([self checkAdvertisement:dict[@"data"][@"articles"][model.ID][@"op_mark"] source:model.source]) continue;
        
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
        //        NSLog(@"%@",dict[@"data"][@"articles"][model.ID][@"dislike_infos"]);
        model.title =  dict[@"data"][@"articles"][model.ID][@"title"];
        // 过滤掉标题为空的新闻
        if (model.title.length == 0 || model.title == nil){
            continue;
        }
        model.publishTime = [XMTimeTool getNewsPublishTime];
        // 新闻封面,没有图片的新闻要做一个判断
        NSArray *arr = dict[@"data"][@"articles"][model.ID][@"thumbnails"];
        if (arr.count){
            model.imageURL = [NSURL URLWithString:dict[@"data"][@"articles"][model.ID][@"thumbnails"][0][@"url"]];
        }
        
        // 新闻图片组
        NSArray *imgsArr = dict[@"data"][@"articles"][model.ID][@"images"];
        if (imgsArr.count) {
            NSMutableArray *imgArrM = [NSMutableArray array];
            for (NSUInteger i = 0; i < imgsArr.count; i++) {
                [imgArrM addObject:imgsArr[i][@"url"]];
            }
            model.images = [imgArrM copy];
        }
        
        [arrM addObject:model];
    }
    
    // 归档数据
    [self saveNewDatasArr:arrM channel:channel];
    
    return arrM;
}

+ (BOOL)checkAdvertisement:(NSString *)mark  source:(NSString *)source{
//    // 广告的id都是8位,通过id来过滤掉广告
//    if (ID.integerValue < 99999999) return YES;
    if ([mark isEqualToString:@"广告"]) return YES;
    if ([source isEqualToString:@"淘宝精选"]) return YES;
    return NO;
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

@end
