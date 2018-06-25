//
//  ZLPhotoPickerAssetsViewController.h
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-12.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//


// 回调
typedef void(^callBackBlock)(id obj);

#import <UIKit/UIKit.h>
#import "ZLPhotoPickerCommon.h"
#import "ZLPhotoPickerGroupViewController.h"

@class ZLPhotoPickerGroup;

@interface ZLPhotoPickerAssetsViewController : UIViewController

@property (strong,nonatomic) ZLPhotoPickerGroupViewController *groupVc;
@property (nonatomic , strong) ZLPhotoPickerGroup *assetsGroup;
@property (nonatomic , assign) NSInteger minCount;
// 需要记录选中的值的数据
@property (strong,nonatomic) NSArray *selectPickerAssets;

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com