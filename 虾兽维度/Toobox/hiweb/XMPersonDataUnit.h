//
//  XMPersonDataUnit.h
//  hiWeb
//
//  Created by Niki on 17/9/17.
//  Copyright © 2017年 excellence.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XMSingleFilmModle;

@interface XMPersonDataUnit : NSObject

+ (NSArray *)dealDate:(NSString *)date;
+ (NSArray *)dealDatePicture:(NSString *)date;
+ (NSArray *)dealDateAcotr:(NSString *)date;
+ (NSArray *)dealRelateFilmArr:(NSString *)date;
// 正则获得url
+ (NSArray *)new_dealDateUrl:(NSString *)date logFlag:(BOOL)flag;
+ (XMSingleFilmModle *)dealDetail:(NSString *)date;

@end
