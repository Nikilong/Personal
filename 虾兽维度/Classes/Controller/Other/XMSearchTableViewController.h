//
//  XMSearchTableViewController.h
//  虾兽维度
//
//  Created by Niki on 17/7/15.
//  Copyright © 2017年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMOpenWebmoduleProtocol.h"

@interface XMSearchTableViewController : UITableViewController

@property (weak, nonatomic)  id<XMOpenWebmoduleProtocol> delegate;

@end
