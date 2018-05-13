//
//  XMChannelModel.m
//  虾兽维度
//
//  Created by Niki on 17/3/25.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "XMChannelModel.h"

@implementation XMChannelModel

+ (NSArray *)channels
{
    return [self getChannelFromPlistName:@"web.plist"];
}

+ (NSArray *)specialChannels
{
    return [self getChannelFromPlistName:@"webSpecial.plist"];
}

+ (NSArray *)getChannelFromPlistName:(NSString *)name
{
    NSArray *channelArr = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:nil]];
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
@end
