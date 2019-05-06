//
//  XMDarkNightCell.m
//  虾兽维度
//
//  Created by Niki on 2019/4/26.
//  Copyright © 2019年 admin. All rights reserved.
//

#import "XMDarkNightCell.h"
#import <DKNightVersion/DKNightVersion.h>

@implementation XMDarkNightCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setFrame:(CGRect)frame{
    frame.origin.y += 1;
    frame.size.height -= 1;
    [super setFrame:frame];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        self.contentView.dk_backgroundColorPicker = DKColorPickerWithKey(HIGHLIGHTED);
    } else {
        self.contentView.dk_backgroundColorPicker = DKColorPickerWithKey(BG);
    }
}

@end
