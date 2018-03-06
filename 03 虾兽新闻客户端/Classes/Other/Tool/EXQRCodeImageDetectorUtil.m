//
//  EXQRCodeImageDetectorUtil.m
//  iExWebClient
//
//  Created by Niki on 2018/1/30.
//  Copyright © 2018年 excellence. All rights reserved.
//

#import "EXQRCodeImageDetectorUtil.h"

@implementation EXQRCodeImageDetectorUtil

// 识别图片二维码
+ (NSString *)detectorQRCodeImage:(UIImage *)selectImage{
    // 设置图片,测试中发现256左右的图片识别率高
    UIImage *qrImage = [self changeTo256Image:selectImage];
    
    // 解析图片中的二维码
    CIDetector*detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    NSData* imageData =UIImagePNGRepresentation(qrImage);
    CIImage* ciImage = [CIImage imageWithData:imageData];
    NSArray* features = [detector featuresInImage:ciImage];
    
    if(features.count > 0){
        
        CIQRCodeFeature* feature = [features objectAtIndex:0];
        return feature.messageString;
        
    }else{
        return nil;
    }
}

// 将图片大小转换成256左右的像素,提高识别速度和准确度
+ (UIImage *)changeTo256Image:(UIImage *)selectImage
{
    float actualHeight = selectImage.size.height;
    float actualWidth = selectImage.size.width;
    float newWidth =0;
    float newHeight =0;
    if(actualWidth > actualHeight) {
        //宽图
        newHeight = 256.0f;
        newWidth = actualWidth / actualHeight * newHeight;
    }else{
        //长图
        newWidth = 256.0f;
        newHeight = actualHeight / actualWidth * newWidth;
    }
    CGRect rect = CGRectMake(0.0, 0.0, newWidth, newHeight);
    UIGraphicsBeginImageContext(rect.size);
    [selectImage drawInRect:rect];
    selectImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return selectImage;
}



@end
