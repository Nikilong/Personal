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

+ (NSArray *)new_dealHomeDate:(NSString *)date;
+ (NSArray *)new_dealDatePicture:(NSString *)date;
+ (NSArray *)new_dealDateAcotr:(NSString *)date;
+ (NSArray *)new_dealDateUrl:(NSString *)date;
    
// 旧方法
+ (NSArray *)dealDate:(NSString *)date;
+ (NSArray *)dealDatePicture:(NSString *)date;
+ (NSArray *)dealDateAcotr:(NSString *)date;
+ (NSArray *)dealRelateFilmArr:(NSString *)date;
+ (XMSingleFilmModle *)dealDetail:(NSString *)date;

@end
