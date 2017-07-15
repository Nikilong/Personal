//
//  XMOpenWebmoduleProtocol.h
//  虾兽新闻客户端
//
//  Created by Niki on 17/7/15.
//  Copyright © 2017年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMWebModel.h"

@class XMWebModel;

@protocol XMOpenWebmoduleProtocol <NSObject>

@optional
- (void)openWebmoduleRequest:(XMWebModel *)webModel;

@end
