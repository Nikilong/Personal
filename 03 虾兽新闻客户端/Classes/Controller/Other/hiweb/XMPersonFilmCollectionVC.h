//
//  XMPersonFilmCollectionVC.h
//  hiWeb
//
//  Created by Niki on 17/9/17.
//  Copyright © 2017年 excellence.com.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XMSingleFilmModle;

@protocol XMPersonFilmCollectionVCDelegate <NSObject>

// 加载所有的作品
- (void)loadOtherActor:(XMSingleFilmModle *)model;

@end

@interface XMPersonFilmCollectionVC : UICollectionViewController

@property (nonatomic, strong) NSArray *data;  // 图片信息
@property (nonatomic, assign)  UIEdgeInsets cellInset;   //分别为上、左、下、右
@property (nonatomic, assign)  CGSize cellSize;

@property (nonatomic, strong) NSArray *actorArr;   // 演员列表
@property (nonatomic, strong) NSArray *relateFilmArr;  // 同类型电影列表
@property (nonatomic, assign)  BOOL detailMode;  // yes表示打开了单个作品


// 记录当前作品
@property (nonatomic, strong) XMSingleFilmModle *currentModel;

@property (weak, nonatomic)  id<XMPersonFilmCollectionVCDelegate> delegate;

@end
