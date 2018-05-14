//
//  XMShowCollectionViewCell.h
//  hiWeb
//
//  Created by Niki on 17/9/17.
//  Copyright © 2017年 excellence.com.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CellW 160
#define CellH 200

@class XMSingleFilmModle;

@interface XMShowCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) XMSingleFilmModle *modle;

+ (XMShowCollectionViewCell *)cellWithContentView:(UICollectionView *)collectionView ide:(NSString *)ide indexPath:(NSIndexPath *)indexP;

@end
