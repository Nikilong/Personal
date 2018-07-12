//
//  XMShowCollectionViewCell.m
//  hiWeb
//
//  Created by Niki on 17/9/17.
//  Copyright © 2017年 excellence.com.cn. All rights reserved.
//

#import "XMShowCollectionViewCell.h"
#import "XMSingleFilmModle.h"
#import "UIImageView+WebCache.h"

double const CellW = 160.0;
double const CellH = 200.0;

@interface XMShowCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *imagV;
@property (weak, nonatomic) IBOutlet UILabel *lab;

@end

@implementation XMShowCollectionViewCell


- (instancetype)initWithFrame:(CGRect)frame{
    
    if(self = [super initWithFrame:frame]){
        
        self = [[NSBundle mainBundle] loadNibNamed:@"XMShowCollectionViewCell" owner:self options:nil][0];

    }
    return self;
}

- (void)setModle:(XMSingleFilmModle *)modle{
    
    _modle = modle;
    if (modle.title){
        
        self.lab.hidden = NO;
        self.lab.text = modle.title;
    }else{
        self.lab.hidden = YES;
    }
    self.imagV.contentMode = UIViewContentModeScaleAspectFit;
    [self.imagV sd_setImageWithURL:[NSURL URLWithString:modle.imgUrl] placeholderImage:[UIImage imageNamed:@"iconTaskUnAttention"]];
}


+ (XMShowCollectionViewCell *)cellWithContentView:(UICollectionView *)collectionView ide:(NSString *)ide indexPath:(NSIndexPath *)indexP{
    
    XMShowCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ide forIndexPath:indexP];
    if (!cell){
        cell = [[NSBundle mainBundle] loadNibNamed:@"XMShowCollectionViewCell" owner:self options:nil][0];
    }

    return cell;
}


@end
