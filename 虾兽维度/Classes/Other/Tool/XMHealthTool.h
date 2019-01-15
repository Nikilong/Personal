//
//  XMHealthTool.h
//  虾兽维度
//
//  Created by Niki on 2019/1/15.
//  Copyright © 2019年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface XMHealthTool : NSObject

/// 获取步数
- (void)getStepCountWithCompleteBlock:(void (^)(NSString *))block;

+ (instancetype)shareHealthTool;

@end
