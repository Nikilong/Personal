//
//  XMWebTableViewCell.m
//  虾兽维度
//
//  Created by admin on 17/2/28.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "XMWebTableViewCell.h"
#import "XMWebModel.h"
#import "XMWifiTransModel.h"
#import "UIImageView+WebCache.h"
#import "XMVisualView.h"

#import <DKNightVersion/DKNightVersion.h>

@interface XMWebTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *publishTime;
@property (weak, nonatomic) IBOutlet UILabel *pureTitle;
@property (weak, nonatomic) IBOutlet UILabel *commitCount;
@property (weak, nonatomic) IBOutlet UILabel *sourceLabel;


@end

@implementation XMWebTableViewCell


- (void)setFrame:(CGRect)frame{
    frame.origin.y += 1;
    frame.size.height -= 1;
    [super setFrame:frame];
}


- (void)setWifiModel:(XMWifiTransModel *)wifiModel{
    _wifiModel = wifiModel;
    
    _imageV.hidden = NO;
    _title.hidden = NO;
    _commitCount.hidden = NO;
    // 隐藏不必要的标签
    _pureTitle.hidden = YES;
    
    // 显示创建时间
    _sourceLabel.text = wifiModel.createDateStr;
    // 显示大小标签
    _publishTime.text = wifiModel.sizeStr;
    
    // 视频音频显示时长
    if(wifiModel.fileType == fileTypeAudioName || wifiModel.fileType == fileTypeVideoName){
        _commitCount.hidden = NO;
        _commitCount.text = [NSString stringWithFormat:@"时长:%@",wifiModel.mediaLengthStr];
    }else{
        _commitCount.text = @"";
        _commitCount.hidden = YES;
    }
    
    // 设置标题
    if (wifiModel.prePath.length > 0){
        _title.text = [NSString stringWithFormat:@"%@--(%@)",wifiModel.pureFileName,[wifiModel.prePath substringToIndex:(wifiModel.prePath.length - 1)]];
    }else{
        _title.text = wifiModel.pureFileName;
    }
    // 设置图片
    if ([wifiModel.fileType isEqualToString:@"image"]){
        _imageV.contentMode = UIViewContentModeScaleAspectFill;
        _imageV.image = [UIImage imageWithContentsOfFile:wifiModel.fullPath];
    }else{
        _imageV.contentMode = UIViewContentModeScaleAspectFit;
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"MISFileType.bundle/icon_%@", wifiModel.fileType]];
        if (!image){
            image = [UIImage imageNamed:@"MISFileType.bundle/icon_unknown"];
        }
        _imageV.image = image;
    }

}

- (void)setModel:(XMWebModel *)model{
    _model = model;
    _publishTime.text = model.publishTime;
    if(model.cmt_cnt == 0){
        _commitCount.hidden = YES;
    }else{
        _commitCount.hidden = NO;
        _commitCount.text = [NSString stringWithFormat:@"%zd评论",model.cmt_cnt];
    }
    _sourceLabel.text = [NSString stringWithFormat:@"%@", model.source];
    
    if (model.imageURL.absoluteString){
        _title.hidden = NO;
        _imageV.hidden = NO;
        _pureTitle.hidden = YES;
        _title.text = model.title;
        
        [_imageV sd_setImageWithURL:model.imageURL placeholderImage:[UIImage imageNamed:@"placehoder"]];
        
    }else{
        _title.hidden = YES;
        _imageV.hidden = YES;
        _pureTitle.hidden = NO;
        _pureTitle.text = model.title;
    }
}

+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *ID = @"webCell";
    
    XMWebTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"XMWebTableViewCell" owner:nil options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:cell action:@selector(tapToShowBigImage)];
        [cell.imageV addGestureRecognizer:tap];
        cell.imageV.userInteractionEnabled = YES;
    }
    
    return cell;
}


/// 展示大图
- (void)tapToShowBigImage{
    if (self.model){
        XMVisualView *viV = [XMVisualView creatVisualImageViewWithImage:self.model.imageURL];
        // 添加一个动画效果
        viV.alpha = 0;
        [UIView animateWithDuration:0.25 animations:^{
            viV.alpha = 1;
        }];
    }
}

///// 取消大图
//- (void)removeBigImage:(UITapGestureRecognizer *)tap{
//    [tap.view removeFromSuperview];
//}
//
//{
//    // 底部手势区域
//    UIView *containV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, XMScreenW, XMScreenH)];
//    containV.backgroundColor = [UIColor clearColor];
//    
//    // 毛玻璃
//    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
//    UIVisualEffectView *effV = [[UIVisualEffectView alloc] initWithEffect:blur];
//    effV.frame = containV.bounds;
//    
//    // 相框
//    UIImageView *imgV = [[UIImageView alloc] initWithFrame:containV.bounds];
//    imgV.userInteractionEnabled = YES;
//    imgV.contentMode = UIViewContentModeScaleAspectFit;
//    [imgV sd_setImageWithURL:self.model.imageURL];
//    
//    // 主窗口
//    UIWindow *window = [UIApplication sharedApplication].keyWindow;
//    
//    // 依次添加视图
//    [containV addSubview:effV];
//    [effV.contentView addSubview:imgV];
//    [window addSubview:containV];
//    
//    // 添加点击移除手势
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeBigImage:)];
//    [containV addGestureRecognizer:tap];
//}

@end
