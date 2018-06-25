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
    
- (NSData *)changeGifToData{
    ALAssetRepresentation *re = [self.asset representationForUTI:(__bridge NSString *)kUTTypeGIF];;
    long long size = re.size;
    uint8_t *buffer = malloc(size);
    NSError *error;
    NSUInteger bytes = [re getBytes:buffer fromOffset:0 length:size error:&error];
    NSData *data = [NSData dataWithBytes:buffer length:bytes];
    free(buffer);
    return data;
}

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com
