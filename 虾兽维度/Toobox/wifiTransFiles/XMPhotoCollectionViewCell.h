//
//  XMPhotoCollectionViewCell.h
//  虾兽维度
//
//  Created by Niki on 18/5/24.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XMWifiTransModel;

@interface XMPhotoCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) XMWifiTransModel *wifiModle;
@property (nonatomic, strong) UIScrollView *imgScroV;
@property (nonatomic, strong) UIImageView *imgV;

@end
