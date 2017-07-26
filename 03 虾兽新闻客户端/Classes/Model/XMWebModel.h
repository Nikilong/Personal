//
//  XMWebModel.h
//  03 虾兽新闻客户端
//
//  Created by admin on 17/2/28.
//  Copyright © 2017年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

// web的网址，需要拼接参数
#define XMWebURL(name) [NSString stringWithFormat:@"http://m.uczzd.cn/webview/news?app=uc-iflow&aid=%@&cid=100&zzd_from=uc-iflow&uc_param_str=dndsfrvesvntnwpfgicp&recoid=3902548323263252739&rd_type=reco&sp_gz=1",(name)]

@interface XMWebModel : NSObject

@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) NSURL *webURL;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, copy) NSString *publishTime;
/** 是否搜索模式,搜索模式下只会打开一个webModule */
@property (nonatomic, assign, getter=isSearchMode)  BOOL searchMode;


/** 评论数*/
@property (nonatomic, assign)  NSUInteger cmt_cnt;

@property (nonatomic, copy) NSString *source;

+ (NSArray *)websWithDict:(NSDictionary *)dict refreshCount:(NSUInteger)count;

@end
