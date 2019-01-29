//
//  XMWebModel.h
//  虾兽维度
//
//  Created by admin on 17/2/28.
//  Copyright © 2017年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMWebModel : NSObject

@property (nonatomic, copy) NSString *ID;           // 发布者id
@property (nonatomic, copy) NSString *title;        // 新闻标题
@property (nonatomic, strong) NSURL *imageURL;      // 首张图片url
@property (nonatomic, strong) NSArray *images;      // 所有图片url
@property (nonatomic, strong) NSURL *webURL;        // 新闻url
@property (nonatomic, strong) NSURL *author_icon;   // 作者的封面
@property (nonatomic, assign) NSInteger index;      // 索引
@property (nonatomic, copy) NSString *publishTime;  // 发布时间
@property (nonatomic, copy) NSArray *tags;          // 标签(用于过滤)
@property (nonatomic, assign)  NSUInteger cmt_cnt;  // 评论数
@property (nonatomic, copy) NSString *source;       // 来源

/** 是否搜索模式,搜索模式下只会打开一个webModule */
@property (nonatomic, assign, getter=isSearchMode)  BOOL searchMode;
/** 是否从main发送的网络请求,即是否第一个webmodule的标记 */
@property (nonatomic, assign, getter=isFirstRequest)  BOOL firstRequest;

@end
