//
//  ZLAssets.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 15-1-3.
//  Copyright (c) 2015年 com.zixue101.www. All rights reserved.
//

#import "ZLPhotoAssets.h"
#import <MobileCoreServices/UTCoreTypes.h>

@implementation ZLPhotoAssets

- (UIImage *)thumbImage{
    return [UIImage imageWithCGImage:[self.asset thumbnail]];
}

- (UIImage *)aspectRatioThumbnail{
    return [UIImage imageWithCGImage:[self.asset aspectRatioThumbnail]];
}

- (UIImage *)originImage{
    return [UIImage imageWithCGImage:[[self.asset defaultRepresentation] fullScreenImage]];
}
    
- (NSString *)imageName{
    ALAssetRepresentation *representation = [self.asset defaultRepresentation];
    return [representation filename];

}
    
- (BOOL)isGif{

    // kUTTypeGIF实际上是 @"com.compuserve.gif"
    ALAssetRepresentation *re = [self.asset representationForUTI:(__bridge NSString *)kUTTypeGIF];
    
    return (re)? YES : NO;
}
    

@end

