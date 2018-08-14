//
//  NSURLProtocol+WKWebview.h
//  虾兽维度
//
//  Created by Niki on 2018/8/14.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLProtocol (WKWebview)

/**
  该分类是为了wkwebview能够实现NSURLProtocol
 */
+ (void)wk_registerScheme:(NSString*)scheme;
+ (void)wk_unregisterScheme:(NSString*)scheme;

@end

