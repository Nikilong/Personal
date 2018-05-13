//
//  XMPersonDataUnit.m
//  hiWeb
//
//  Created by Niki on 17/9/17.
//  Copyright © 2017年 excellence.com.cn. All rights reserved.
//

#import "XMPersonDataUnit.h"
#import "XMSingleFilmModle.h"

static NSString *homUrl;
@implementation XMPersonDataUnit
    
// 返回homeurl
+ (NSString *)checkHomeUrl{
    if (homUrl){
        return homUrl;
    }else{
        homUrl = [NSString stringWithContentsOfFile:XMHiwebHomeUrlPath encoding:NSUTF8StringEncoding error:nil];
        return homUrl;
    }
}

#pragma mark - 处理数据
// 处理个人所有作品
+ (NSArray *)dealDate:(NSString *)date
{
//    NSLog(@"-----------begin-----------");
    // 去除头部信息
    NSArray *arrCutHeader = [date componentsSeparatedByString:@"<div class=\"alert alert-success alert-common\">"];
    NSString *strCutHeader = [arrCutHeader lastObject];
    arrCutHeader = nil;
    // 去除尾部多余信息
    NSArray *arrCutTail = [strCutHeader componentsSeparatedByString:@"<script language=\"JavaScript\">"];
    NSString *dataStr = [arrCutTail firstObject];
    
    // 在提取终极哪有用的信息,第一项为演员信息
    NSMutableArray *arr = [NSMutableArray arrayWithArray:[dataStr componentsSeparatedByString:@"<div class=\"item\">"]];
    [arr removeObjectAtIndex:0];
    [arr removeObjectAtIndex:0];
    
    NSString *url;
    NSString *title;
    NSString *image;
    NSArray *midArr;
    NSMutableArray *resultArr = [NSMutableArray array];
    
    for (NSString *str in arr)
    {
        NSArray *itemArr = [str componentsSeparatedByString:@"\n"];
        XMSingleFilmModle *model = [[XMSingleFilmModle alloc] init];
        for (NSString *item in itemArr)
        {
            if ([item containsString:[NSString stringWithFormat:@"href=\"%@/",[self checkHomeUrl]]])
            {
                url = [self regularUrl:item paternString:@"https" index:3];
                model.url = url;
//                NSLog(@"url is %@",url);
            }
            if ([item containsString:@"src=\"https://pics.javcdn.pw/thumb"] || [item containsString:@"src=\"https://pics.dmm.co.jp/"] || [item containsString:@"src=\"http://pics.dmm.co.jp/"] )
            {
                midArr = [item componentsSeparatedByString:@"title="];
                title = [[self regularUrl:midArr[1] paternString:@"\"" index:2] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                image = [self regularUrl:midArr[0] paternString:@"http" index:2];
                model.imgUrl = image;
                model.title = title;
                
//                NSLog(@"image is %@",image);
//                NSLog(@"title is %@",title);
            }
//
        }
        [resultArr addObject:model];
    }

//    NSLog(@"-----------end-----------");
    return resultArr;
}



// 获取演员列表
+ (NSArray *)dealDateAcotr:(NSString *)date
{
//    NSLog(@"-----------begin-----------");
    // 去除头部信息
    NSArray *arrCutHeader = [date componentsSeparatedByString:@"<div id=\"star-div\">"];
    NSString *strCutHeader = [arrCutHeader lastObject];
    arrCutHeader = nil;
    // 去除尾部多余信息
    NSArray *arrCutTail = [strCutHeader componentsSeparatedByString:@"style=\"position:relative\""];
    NSString *dataStr = [arrCutTail firstObject];
    
    // 在提取终极哪有用的信息,第一项为演员信息
    NSMutableArray *arr = [NSMutableArray arrayWithArray:[dataStr componentsSeparatedByString:@"class=\"avatar-box\""]];
    if (arr.count == 1) return nil;
    // 去除演员的个人信息数据,可以留待以后发展
    [arr removeObjectAtIndex:0];

    
    NSString *url;
    NSString *title;
    NSString *image;
    NSArray *midArr;
    NSMutableArray *resultArr = [NSMutableArray array];
//    [resultArr removeObjectAtIndex:0];
    
    for (NSString *str in arr)
    {
        NSArray *itemArr = [str componentsSeparatedByString:@"\n"];
        XMSingleFilmModle *model = [[XMSingleFilmModle alloc] init];
        for (NSString *item in itemArr)
        {
            if ([item containsString:[NSString stringWithFormat:@"href=\"%@/",[self checkHomeUrl]]])
            {
                url = [self regularUrl:item paternString:@"https" index:3];
                model.url = url;
//                                NSLog(@"url is %@",url);
            }
            if ([item containsString:@"src=\"https://pics.javcdn.pw/"] || [item containsString:@"src=\"https://pics.dmm.co.jp/"] || [item containsString:@"src=\"http://pics.dmm.co.jp/"] )
            {
                midArr = [item componentsSeparatedByString:@"title="];
                title = [[self regularUrl:midArr[1] paternString:@"\"" index:2] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                image = [self regularUrl:midArr[0] paternString:@"http" index:2];
                model.imgUrl = image;
                model.title = title;
                
//                                NSLog(@"image is %@",image);
//                                NSLog(@"title is %@",title);
            }
            //
        }
        [resultArr addObject:model];
    }
    
//    NSLog(@"-----------end-----------");
    return resultArr;

}

// 处理单个作品所有图片
+ (NSArray *)dealDatePicture:(NSString *)date
{
    NSLog(@"-----------begin-----------");
    // 去除头部信息
    NSArray *arrCutHeader = [date componentsSeparatedByString:@"<div id=\"sample-waterfall\">"];
    NSString *strCutHeader = [arrCutHeader lastObject];
    arrCutHeader = nil;
    // 去除尾部多余信息
    NSArray *arrCutTail = [strCutHeader componentsSeparatedByString:@"<div class=\"clearfix\">"];
    NSString *dataStr = [arrCutTail firstObject];
    
    // 在提取终极哪有用的信息,第一项为演员信息
    NSMutableArray *arr = [NSMutableArray arrayWithArray:[dataStr componentsSeparatedByString:@">"]];
    
    NSString *imgURL;
    NSMutableArray *imgArr = [NSMutableArray array];
    for (NSString *str in arr)
    {
        if ([str containsString:@"href=\"https://pics.dmm.co.jp/"])
        {
            XMSingleFilmModle *model = [[XMSingleFilmModle alloc] init];
            imgURL = [self regularUrl:str paternString:@"https" index:1];
            model.imgUrl = imgURL;
            model.title = nil;
            [imgArr addObject:model];
//            NSLog(@"iamgURL is %@",imgURL);
        }else if ([str containsString:@"src=\"https://pics.dmm.co.jp/"])
        {
//            // 这种情况图片和标题混在一块
//            imgURL = [self regularUrl:[str componentsSeparatedByString:@"title="][0] paternString:@"https" index:2];
//            
//            XMSingleFilmModle *lastModel = [imgArr lastObject];
//            if (![imgURL isEqualToString:lastModel.imgUrl])
//            {
//                XMSingleFilmModle *model = [[XMSingleFilmModle alloc] init];
//                model.imgUrl = imgURL;
//                model.title = nil;
//                [imgArr addObject:model];
//    //           NSLog(@"iamgURL is %@",imgURL);
//            }
        }
    }
    
//    NSLog(@"-----------end-----------");
    return imgArr;
}


// 处理单个影片中的同类影片
+ (NSArray *)dealRelateFilmArr:(NSString *)date
{
    NSLog(@"-----------begin-----------");
    // 去除头部信息
    NSArray *arrCutHeader = [date componentsSeparatedByString:@"<div id=\"related-waterfall\" class=\"mb20\">"];
    NSString *strCutHeader = [arrCutHeader lastObject];
    arrCutHeader = nil;
    // 去除尾部多余信息
    NSArray *arrCutTail = [strCutHeader componentsSeparatedByString:@"<script>"];
    NSString *dataStr = [arrCutTail firstObject];
    
    // 在提取终极哪有用的信息,第一项为演员信息
    NSMutableArray *arr = [NSMutableArray arrayWithArray:[dataStr componentsSeparatedByString:@"<div class=\"photo-info\""]];
    // 当数组只有一个值,表示没有相关的影片
    if (arr.count == 1) return nil;
    // 去掉最后的空白数据
    [arr removeLastObject];
    
    NSString *url;
    NSString *title;
    NSString *image;
    NSArray *midArr;
    NSMutableArray *resultArr = [NSMutableArray array];
    
    for (NSString *str in arr)
    {
        NSArray *itemArr = [str componentsSeparatedByString:@"\n"];
        XMSingleFilmModle *model = [[XMSingleFilmModle alloc] init];
        for (NSString *item in itemArr)
        {
            
            if ([item containsString:@"<img src="])
            {
                image = [self regularUrl:item paternString:@"https" index:3];
                model.imgUrl = image;
//                                NSLog(@"image is %@",image);
            }
            // 同类作品中,标题和url混在一块
            if ([item containsString:@"class=\"movie-box\""] )
            {
                midArr = [item componentsSeparatedByString:@"class=\"movie-box\""];
        
                title = [[self regularUrl:midArr[0] paternString:@"\"" index:2] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                
                NSString *ssss = [midArr[1] componentsSeparatedByString:@"style="][0];
                url = [self regularUrl:ssss paternString:@"http" index:2];
                model.url = url;
                model.title = title;
                
//                                NSLog(@"url is %@",url);
//                                NSLog(@"title is %@",title);
            }
            //
        }
        [resultArr addObject:model];
    }
    
//    NSLog(@"-----------end-----------");
    return resultArr;
}


// 处理单个影片中封面的标题/大图/及其他相关信息
+ (XMSingleFilmModle *)dealDetail:(NSString *)date
{
    // 去除头部信息
    NSArray *arrCutHeader = [date componentsSeparatedByString:@"<div class=\"container\">"];
    NSString *strCutHeader = [arrCutHeader lastObject];
    arrCutHeader = nil;
    // 去除尾部多余信息
    NSArray *arrCutTail = [strCutHeader componentsSeparatedByString:@"<div class=\"col-md-3 info\">"];
    NSString *dataStr = [arrCutTail firstObject];
    
    NSString *image;

    XMSingleFilmModle *model = [[XMSingleFilmModle alloc] init];
    NSArray *itemArr = [dataStr componentsSeparatedByString:@">"];
    for (NSString *item in itemArr)
    {
        
        if ([item containsString:@"href"])
        {
            image = [self regularUrl:item paternString:@"https" index:1];
            model.imgUrl = image;
        }
        
        if ([item containsString:@"</h3"])
        {
            model.title = [item substringWithRange:NSMakeRange(0, item.length - 4)];
        }
    }

    return model;
}


// 对筛选出来的网址进行处理
+ (NSString *)regularUrl:(NSString *)str paternString:(NSString *)parStr index:(NSUInteger )index
{
    NSRange range = [str rangeOfString:parStr];
    return [str substringWithRange:NSMakeRange(range.location, str.length - range.location - index)];
}


// 正则提取url
+ (NSArray *)new_dealDateUrl:(NSString *)date logFlag:(BOOL)flag{
    NSString *reguStrUrl = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    return [self regularWithString:date regular:reguStrUrl logFlag:flag];
}
    
// 正则表达式过滤
+ (NSArray *)regularWithString:(NSString *)str regular:(NSString *)reguStr logFlag:(BOOL) flag{
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:reguStr options: NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray *arrayOfAllMatches = [regex matchesInString:str options:0 range:NSMakeRange(0, [str length])];
    
    NSMutableArray *resultArr = [NSMutableArray array];
    for (NSTextCheckingResult *match in arrayOfAllMatches){
        
        NSString* substringForMatch = [str substringWithRange:match.range];
        [resultArr addObject:substringForMatch];
        if (flag){
            NSLog(@"%@",substringForMatch);
            
        }
    }
    NSLog(@"一共有:%zd个结果",arrayOfAllMatches.count);
    return resultArr;
    
}

@end
