//
//  XMWebMultiWindowCollectionViewCell.m
//  虾兽维度
//
//  Created by Niki on 2018/8/21.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMWebMultiWindowCollectionViewCell.h"

@interface XMWebMultiWindowCollectionViewCell()

@property (weak, nonatomic)  UIImageView *backImgV;
//@property (weak, nonatomic)  UILabel  *lab;

@end


@implementation XMWebMultiWindowCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        UIImageView *backImgV = [[UIImageView alloc] init];
        backImgV.frame = self.bounds;
        backImgV.contentMode = UIViewContentModeScaleAspectFit;
        backImgV.clipsToBounds = YES;
        self.backImgV = backImgV;
        [self.contentView addSubview:backImgV];
        self.contentView.backgroundColor = XMRandomColor;
        
//        UILabel *lab= [[UILabel alloc] initWithFrame:CGRectMake(0, 0, XMScreenW, 100)];
//        lab.backgroundColor = [UIColor blackColor];
//        lab.textAlignment = NSTextAlignmentCenter;
//        lab.textColor = [UIColor orangeColor];
//        lab.font = [UIFont systemFontOfSize:50];
//        [backImgV addSubview:lab];
//        self.lab = lab;
        
    }
    return self;
}

- (void)setBackgroundImage:(UIImage *)image{
    self.backImgV.image = image;
}

//- (void)setIndex:(NSUInteger )index{
//    self.backImgV.image = [UIImage imageNamed:[NSString stringWithFormat:@"%lu",(unsigned long)index]];
//    self.lab.text = [NSString stringWithFormat:@"%lu",(unsigned long)index];
//}

@end
