//
//  XMWebTableViewCell.m
//  03 虾兽新闻客户端
//
//  Created by admin on 17/2/28.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "XMWebTableViewCell.h"
#import "XMWebModel.h"
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
