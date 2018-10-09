//
//  XMQRUtil.h
//  虾兽维度
//
//  Created by Niki on 2018/10/9.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface XMQRUtil : NSObject

+ (CGRect)screenBounds;
+ (AVCaptureVideoOrientation) videoOrientationFromCurrentDeviceOrientation;

@end
