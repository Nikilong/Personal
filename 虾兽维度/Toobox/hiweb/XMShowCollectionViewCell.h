//
//  XMShowCollectionViewCell.h
//  hiWeb
//
//  Created by Niki on 17/9/17.
//  Copyright © 2017年 excellence.com.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

extern double const CellW;
extern double const CellH;

@class XMSingleFilmModle;

@interface XMShowCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) XMSingleFilmModle *modle;

+ (XMShowCollectionViewCell *)cellWithContentView:(UICollectionView *)collectionView ide:(NSString *)ide indexPath:(NSIndexPath *)indexP;

@end
