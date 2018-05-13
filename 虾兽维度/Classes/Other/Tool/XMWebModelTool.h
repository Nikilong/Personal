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

+ (void)saveWebModel:(XMWebModel *)webModel;
+ (void)deleteWebModelAtIndex:(NSUInteger)index;
+ (NSArray *)webModels;

@end
