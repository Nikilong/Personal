//
//  ZLAssets.h
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 15-1-3.
//  Copyright (c) 2015年 com.zixue101.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ZLPhotoAssets : NSObject

@property (strong,nonatomic) ALAsset *asset;
/**
 *  缩略图
 */
- (UIImage *)thumbImage;

/**
 *  缩略图(高清版)
 */
- (UIImage *)aspectRatioThumbnail;

/**
 *  原图
 */
- (UIImage *)originImage;
    
/// 源文件的名称
- (NSString *)imageName;

/// 是否是gif
- (BOOL)isGif;


@end

