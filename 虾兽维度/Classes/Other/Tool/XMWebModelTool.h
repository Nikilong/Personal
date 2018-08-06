//
//  XMWebModelTool.h
//  虾兽维度
//
//  Created by Niki on 17/3/25.
//  Copyright © 2017年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMWebModel.h"

@interface XMWebModelTool : NSObject

/// 判断该网址是否已经保存
+ (BOOL)isWebURLHaveSave:(NSString *)url;
/// 保存网址
+ (void)saveWebModel:(XMWebModel *)webModel;
/// 删除已保存网址
+ (void)deleteWebURL:(NSString *)url;
+ (void)deleteWebModelAtIndex:(NSUInteger)index;
/// 已保存网址列表
+ (NSArray *)webModels;

@end
