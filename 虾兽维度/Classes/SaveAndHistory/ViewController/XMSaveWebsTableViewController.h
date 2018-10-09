//
//  XMSaveWebsTableViewController.h
//  虾兽维度
//
//  Created by Niki on 17/3/25.
//  Copyright © 2017年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMOpenWebmoduleProtocol.h"

@interface XMSaveWebsTableViewController : UITableViewController

@property (weak, nonatomic)  id<XMOpenWebmoduleProtocol> delegate;

@property (nonatomic, copy) NSArray *passArr;
@property (nonatomic, copy) NSString *groupName;


@end
