//
//  EXQRCodeImageDetectorUtil.h
//  iExWebClient
//
//  Created by Niki on 2018/1/30.
//  Copyright © 2018年 excellence. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EXQRCodeImageDetectorUtil : NSObject

/** 解析图片中的二维码信息 */
+ (NSString *)detectorQRCodeImage:(UIImage *)selectImage;

@end
