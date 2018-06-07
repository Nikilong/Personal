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

@interface XMWebTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *publishTime;
@property (weak, nonatomic) IBOutlet UILabel *pureTitle;
@property (weak, nonatomic) IBOutlet UILabel *commitCount;
@property (weak, nonatomic) IBOutlet UILabel *sourceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageV;

@end

@implementation XMWebTableViewCell


- (void)setWifiModel:(XMWifiTransModel *)wifiModel
{
    _wifiModel = wifiModel;
    
    _imageV.hidden = NO;
    _title.hidden = NO;
    _commitCount.hidden = NO;
    // 隐藏不必要的标签
    _pureTitle.hidden = YES;
    
    // 显示创建时间
    _commitCount.text = wifiModel.createDateStr;
    // 显示大小标签
    _publishTime.text = wifiModel.sizeStr;
    
    // 视频音频显示时长
    if(wifiModel.fileType == fileTypeAudioName || wifiModel.fileType == fileTypeVideoName){
        _sourceLabel.hidden = NO;
        _sourceLabel.text = [NSString stringWithFormat:@"时长:%@",wifiModel.mediaLengthStr];
    }else{
        _sourceLabel.text = @"";
        _sourceLabel.hidden = YES;
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

- (void)setModel:(XMWebModel *)model
{
    _model = model;
    _publishTime.text = model.publishTime;
    _commitCount.text = [NSString stringWithFormat:@"评论：%zd",model.cmt_cnt];
    _sourceLabel.text = [NSString stringWithFormat:@"来自：%@", model.source];
    
    if (model.imageURL.absoluteString)
    {
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

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"webCell";
    
    XMWebTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"XMWebTableViewCell" owner:nil options:nil] lastObject];
    }
    
    return cell;
}

@end
