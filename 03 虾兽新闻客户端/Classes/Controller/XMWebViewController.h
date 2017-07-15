//
//  XMWebViewController.h
//  03 虾兽新闻客户端
//
//  Created by admin on 17/2/27.
//  Copyright © 2017年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMOpenWebmoduleProtocol.h"

@interface XMWebViewController : UIViewController

@property (nonatomic, strong) XMWebModel *model;

@property (weak, nonatomic)  id<XMOpenWebmoduleProtocol> delegate;

- (void)webViewDidScrollToBottom;
- (void)webViewDidScrollToTop;

@end
