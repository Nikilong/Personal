//
//  XMHomeTableViewController.h
//  虾兽维度
//
//  Created by Niki on 17/3/24.
//  Copyright © 2017年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMOpenWebmoduleProtocol.h"
@interface XMHomeTableViewController : UITableViewController

/**  记录当前频道 */
@property (nonatomic, assign) NSUInteger currentChannel;

@property (weak, nonatomic)  id<XMOpenWebmoduleProtocol> delegate;

- (void)downToBottom;
- (void)upToTop;
- (void)refresh;

@end
