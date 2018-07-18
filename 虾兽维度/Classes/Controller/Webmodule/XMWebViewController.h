//
//  XMWebViewController.h
//  虾兽维度
//
//  Created by admin on 17/2/27.
//  Copyright © 2017年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMWebModel.h"

//@class XMWebModel;

@interface XMWebViewController : UIViewController

@property (nonatomic, strong) XMWebModel *model;

/** 提供一个类方法让外界打开webmodule */
+ (void)openWebmoduleWithModel:(XMWebModel *)model viewController:(UIViewController *)vc;

/** 提供方法让外界滚动web页面到底部和顶部 */
- (void)webViewDidScrollToBottom;
- (void)webViewDidScrollToTop;

@end
