//
//  XMWebMultiWindowCollectionViewController.h
//  虾兽维度
//
//  Created by Niki on 2018/8/21.
//  Copyright © 2018年 admin. All rights reserved.
//

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
