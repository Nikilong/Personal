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


@end
