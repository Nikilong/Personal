//
//  XMWebMultiWindowCollectionViewController.h
//  虾兽维度
//
//  Created by Niki on 2018/8/21.
//  Copyright © 2018年 admin. All rights reserved.
//


/**
    todo:
    目前已实现多个截图的展示及动画效果,但是对于多窗口切换,应该要严格控制webmodule的打开和关闭逻辑,已
    经对应的截图时机,否则会造成很混乱的效果,参考苹果自带的safari浏览器和uc浏览器的处理即应用场景,以后
    有机会再添加
 
 */

#import <UIKit/UIKit.h>
@class XMMutiWindowFlowLayout,XMWebMultiWindowCollectionViewController;

@protocol XMWebMultiWindowCollectionViewControllerDelegate <NSObject>

@optional
- (void)webMultiWindowCollectionViewControllerCallForNewSearchModule:(XMWebMultiWindowCollectionViewController *)multiVC;

@end

@interface XMWebMultiWindowCollectionViewController : UICollectionViewController

@property (nonatomic, strong) NSMutableArray *shotImageArr;

@property (weak, nonatomic)  id<XMWebMultiWindowCollectionViewControllerDelegate> delegate;

+ (XMWebMultiWindowCollectionViewController *)shareWebMultiWindowCollectionViewController;

@end
