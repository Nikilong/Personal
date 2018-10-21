//
//  XMToolboxViewController.h
//  虾兽维度
//
//  Created by Niki on 18/3/10.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

extern double const XMToolBoxViewAnimationTime;

typedef void(^touchIDCallbackBlock)(BOOL);

@interface XMToolboxViewController : UITableViewController

@property (nonatomic, copy) touchIDCallbackBlock callbackBlock;

@end
