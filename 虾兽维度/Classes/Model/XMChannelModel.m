//
//  XMChannelModel.m
//  虾兽维度
//
//  Created by Niki on 17/3/25.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "XMChannelModel.h"
#import "XMSavePathUnit.h"

@implementation XMChannelModel

#pragma mark 主页频道
+ (NSArray *)channels{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"web.plist" ofType:nil];
    return [self getChannelWithPath:path];
}


#pragma mark 左侧栏方法
+ (NSArray *)specialChannels{
    NSString *path = [XMSavePathUnit getMainLeftSaveChannelPath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]){
        NSArray *defaultArr = [self getChannelWithPath:[[NSBundle mainBundle] pathForResource:@"webSpecial.plist" ofType:nil]];
        [NSKeyedArchiver archiveRootObject:defaultArr toFile:[XMSavePathUnit getMainLeftSaveChannelPath]];
    }
    return [NSKeyedUnarchiver unarchiveObjectWithFile:path];
}

/// 左侧栏添加一条网址
+ (BOOL)specialChannelAddNewChannelName:(NSString *)name url:(NSString *)url{
    XMChannelModel *model = [[XMChannelModel alloc] init];
    model.channel = name;
    model.url = url;
    NSMutableArray *arr = [NSMutableArray arrayWithArray:[self unarchiveLeftChannelArray]];
    [arr addObject:model];
    return [self archiveLeftChannelArray:arr];
}

/// 左侧栏删除一条网址
+ (BOOL)specialChannelRemoveChannelAtIndex:(NSUInteger)index{
    NSMutableArray *oldArr = [NSMutableArray arrayWithArray:[self unarchiveLeftChannelArray]];
    [oldArr removeObjectAtIndex:index];
    return [self archiveLeftChannelArray:oldArr];
}

/// 左侧栏重命名或修改url
+ (BOOL)specialChannelRenameChannelName:(NSString *)name url:(NSString *)url index:(NSUInteger)index{
    NSMutableArray *oldArr = [NSMutableArray arrayWithArray:[self unarchiveLeftChannelArray]];
    XMChannelModel *model = oldArr[index];
    model.channel = name;
    model.url = url;
    return [self archiveLeftChannelArray:oldArr];
}

/// 保存左侧频道
+ (BOOL)archiveLeftChannelArray:(NSArray *)arr{
    return [NSKeyedArchiver archiveRootObject:arr toFile:[XMSavePathUnit getMainLeftSaveChannelPath]];
}

/// 读取左侧频道
+ (NSArray *)unarchiveLeftChannelArray{
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[XMSavePathUnit getMainLeftSaveChannelPath]];
}
#pragma mark 使用说明
/**
 使用说明
 */
+ (NSString *)userGuild{
    return @" "
    "使用说明(双击退出说明):\n"
    "1.主界面\n"
    "双指上划:打开珍藏  双指下划:打开搜索  三指下滑:打开地铁图\n"
    "2.WEB页面\n"
    "捏合:缩放页面  双击:恢复缩放  三击:回退页面(SearchMode才有效)  五次点击:关闭web页面  长按图片:弹出二维码识别/保存图片  长按文字:分享\n"
    "3.地铁图线路图\n"
    "单击:编辑模式切换  双击:放大/恢复  移动手势/缩放手势  \n"
    "4.hiWeb\n"
    "双指下划:查看封面  单指下划:退出查看封面  单击:查看单张图片  双击:退出查看单张图片  缩放/旋转/移动  \n";

}


#pragma mark 公用方法
+ (NSArray *)getChannelWithPath:(NSString *)path{
    NSArray *channelArr = [NSArray arrayWithContentsOfFile:path];
    NSMutableArray *arrM = [NSMutableArray array];
    for (NSDictionary *dict in channelArr) {
        XMChannelModel *model = [[XMChannelModel alloc] init];
        model.channel = dict[@"channel"];
        model.url = dict[@"url"];
        model.tags = dict[@"tags"];
        [arrM addObject:model];
    }
    return arrM;
}

#pragma mark - 归档
/** 读档 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]){
        self.channel = [aDecoder decodeObjectForKey:@"channel"];
        self.url = [aDecoder decodeObjectForKey:@"url"];
    }
    return self;
}

/** 存档 */
- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.channel forKey:@"channel"];
    [aCoder encodeObject:self.url forKey:@"url"];
    
}
@end
