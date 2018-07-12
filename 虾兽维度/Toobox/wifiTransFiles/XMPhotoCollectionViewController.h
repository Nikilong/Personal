//
//  XMPhotoCollectionViewController.h
//  虾兽维度
//
//  Created by Niki on 2018/5/22.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XMPhotoCollectionViewController : UICollectionViewController

@property (nonatomic, strong) NSArray *photoModelArr;
@property (nonatomic, assign)  UIEdgeInsets cellInset;   //分别为上、左、下、右
@property (nonatomic, assign)  CGSize cellSize;
@property (nonatomic, assign)  NSInteger selectImgIndex;

// 被点击的cell的相框的位置,用于拖拽图片退出的结束动画
@property (nonatomic, assign)  CGRect clickImageF;
// 被点击的cell的高度,用于拖拽图片退出的结束动画
@property (nonatomic, assign)  CGFloat clickCellH;


@end
