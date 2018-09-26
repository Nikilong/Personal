//
//  XMPhotoCollectionViewController.h
//  虾兽维度
//
//  Created by Niki on 2018/5/22.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 图片的来源
typedef NS_ENUM(NSUInteger,XMPhotoDisplayImageSourceType){
    XMPhotoDisplayImageSourceTypeLocalPath,     // 本地文件
    XMPhotoDisplayImageSourceTypeWebURL,        // 网页url的string
};

@interface XMPhotoCollectionViewController : UICollectionViewController

@property (nonatomic, strong) NSArray *photoModelArr;
@property (nonatomic, assign)  NSInteger selectImgIndex;

// 被点击的cell的相框的位置,用于拖拽图片退出的结束动画
@property (nonatomic, assign)  CGRect clickImageF;
// 被点击的cell的高度,用于拖拽图片退出的结束动画
@property (nonatomic, assign)  CGFloat clickCellH;

// 图片来源
@property (nonatomic, assign)  XMPhotoDisplayImageSourceType sourceType;



@end
