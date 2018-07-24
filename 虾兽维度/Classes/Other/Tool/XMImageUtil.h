//
//  XMImageUtil.h
//  iExWebClient
//
//  Created by Niki on 2018/1/30.
//  Copyright © 2018年 excellence. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ALAsset;

@interface XMImageUtil : NSObject


///通过url保存网络的图片或者gif到本地或者相册
+ (void)savePictrue:(NSString *)imageUrl path:(NSString *)path callBackViewController:(UIViewController *)vc;

/**--------- 相册信息 ---------*/
/// 获得压缩图
+ (UIImage *)thumbImageWithAsset:(ALAsset *)asset;
/// 获得原始图
+ (UIImage *)originImageWithAsset:(ALAsset *)asset;
/// 获得图片的正式名称
+ (NSString *)imageNameWithAsset:(ALAsset *)asset;

/**--------- gif图片 ---------*/
/// 是否是gif
+ (BOOL)isGifWithAsset:(ALAsset *)asset;

/// 将gif转为data
+ (NSData *)changeGifToDataWithAsset:(ALAsset *)asset;

/// 将gif保存到相册
+ (void)saveGifToAlbumWithURL:(NSString *)url;

/// 

/// 将gif分解为图片组
+ (NSArray *)seprateGifAtPath:(NSString *)path;

/**--------- 二维码图片 ---------*/
/** 解析图片中的二维码信息 */
+ (NSString *)detectorQRCodeImage:(UIImage *)selectImage;
/** 将字符串转为二维码图片 */
+ (UIImage *)creatQRCodeImageWithString:(NSString *)text size:(CGFloat)imgWH;

/**--------- 截图 ---------*/
/// 屏幕截图
+ (UIImage *)screenShot;


@end
