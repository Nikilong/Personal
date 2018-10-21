//
//  XMWKWebViewController.h
//  虾兽维度
//
//  Created by admin on 18/8/14.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMWebModel.h"

//@class XMWebModel;
/**
    关于手势问题:
    1.当searchMode模式下,因为有前进后退手势,会和全屏pop手势冲突,所以能够返回的情况下,禁用全屏pop手势
    2.当searchMode模式下,前进到某个页面,想要加入浮窗时,需要用到左侧pop手势,这时候需要防止前进后退和左侧pop手势冲突,所以需要设置在左侧30区域内,前进后退手势无效
    3.综上,需要左侧pop手势和全屏pop手势
 */

@interface XMWKWebViewController : UIViewController

@property (nonatomic, strong) XMWebModel *model;

/** 提供一个类方法创建webmodule */
+ (UIViewController *)webmoduleWithModel:(XMWebModel *)model;
+ (UIViewController *)webmoduleWithURL:(NSString *)url isSearchMode:(BOOL)searchMode;

/** 将webmodule关闭掉 */
- (void)closeWebModule;


/** 提供方法让外界滚动web页面到底部和顶部 */
- (void)webViewDidScrollToBottom;
- (void)webViewDidScrollToTop;

@end
