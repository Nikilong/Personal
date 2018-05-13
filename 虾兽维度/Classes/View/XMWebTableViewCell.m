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
@property (weak, nonatomic) IBOutlet UILabel *number;
@property (weak, nonatomic) IBOutlet UILabel *pureTitle;
@property (weak, nonatomic) IBOutlet UILabel *commitCount;
@property (weak, nonatomic) IBOutlet UILabel *sourceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageV;

@end

@implementation XMWebTableViewCell


- (void)setWifiModel:(XMWifiTransModel *)wifiModel
{
    _wifiModel = wifiModel;
    
    // 显示大小标签
    if(wifiModel.size < 0.001){
        _publishTime.text = [NSString stringWithFormat:@"%.2f Byte",wifiModel.size * 1024.0 * 1024.0];
    }else if (wifiModel.size < 1){
        _publishTime.text = [NSString stringWithFormat:@"%.2fK",wifiModel.size  * 1024.0];
    }else{
        _publishTime.text = [NSString stringWithFormat:@"%.2fM",wifiModel.size];
    }
    // 设置图片
    if ([@"png|jpg|jpeg" containsString:wifiModel.fileName.pathExtension]){
        _imageV.hidden = NO;
        _pureTitle.hidden = YES;
        _title.hidden = NO;
        _imageV.image = [UIImage imageWithContentsOfFile:wifiModel.fullPath];
        // 设置标题
        if (wifiModel.prePath.length > 0){
            _title.text = [NSString stringWithFormat:@"%@--(%@)",wifiModel.pureFileName,[wifiModel.prePath substringToIndex:(wifiModel.prePath.length - 1)]];
        }else{
            _title.text = wifiModel.pureFileName;
        }
    }else{
        _imageV.hidden = YES;
        _pureTitle.hidden = NO;
        _title.hidden = YES;
        // 设置纯标题
        if (wifiModel.prePath.length > 0){
            _pureTitle.text = [NSString stringWithFormat:@"%@--(%@)",wifiModel.pureFileName,[wifiModel.prePath substringToIndex:(wifiModel.prePath.length - 1)]];
        }else{
            _pureTitle.text = wifiModel.pureFileName;
        }
    }
    
    // 隐藏不必要的标签
    _commitCount.hidden = YES;
    _sourceLabel.hidden = YES;
    _number.hidden = YES;

}

- (void)setModel:(XMWebModel *)model
{
    _model = model;
    _number.text = [NSString stringWithFormat:@"赞:%ld",model.index + 1];
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
        
    }else
    {
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
//        NSLog(@"---XMWebTableViewCell-----build cell====");
        cell = [[[NSBundle mainBundle] loadNibNamed:@"XMWebTableViewCell" owner:nil options:nil] lastObject];
    }
    
    return cell;
}

@end
