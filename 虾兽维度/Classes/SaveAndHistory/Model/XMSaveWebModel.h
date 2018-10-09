//
//  XMSaveWebModel.h
//  虾兽维度
//
//  Created by Niki on 2018/9/27.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMSaveWebModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *url;

@property (nonatomic, copy) NSString *groupName; //组别/默认为最外边的@"收藏"
@property (nonatomic, assign)  BOOL isGroup;

@end
