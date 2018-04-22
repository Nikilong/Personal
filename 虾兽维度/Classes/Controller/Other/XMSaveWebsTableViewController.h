//
//  XMSaveWebsTableViewController.h
//  03 虾兽新闻客户端
//
//  Created by Niki on 17/3/25.
//  Copyright © 2017年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMOpenWebmoduleProtocol.h"

@interface XMSaveWebsTableViewController : UITableViewController

@property (weak, nonatomic)  id<XMOpenWebmoduleProtocol> delegate;

@end
