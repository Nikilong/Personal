//
//  XMImageUtil.m
//  iExWebClient
//
//  Created by Niki on 2018/1/30.
//  Copyright © 2018年 excellence. All rights reserved.
//

#import "XMImageUtil.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "MBProgressHUD+NK.h"
#import <ImageIO/ImageIO.h>
#import "XMWifiGroupTool.h"
#import "XMTimeTool.h"

@implementation XMImageUtil

/**--------- 截图 ---------*/
/// 屏幕截图
+ (UIImage *)screenShot{

    UIGraphicsBeginImageContextWithOptions([UIScreen mainScreen].bounds.size, YES, [UIScreen mainScreen].scale);
    
    //    UIView *snapshotView = [fromViewController.view snapshotViewAfterScreenUpdates:NO];

    // 这样重绘才可以完整将导航栏的所有图层绘出
//    [[UIApplication sharedApplication].keyWindow drawViewHierarchyInRect:CGRectMake(0, 0,XMScreenW, XMScreenH) afterScreenUpdates:NO];
    [[UIApplication sharedApplication].keyWindow.rootViewController.view drawViewHierarchyInRect:CGRectMake(0, 0,XMScreenW, XMScreenH) afterScreenUpdates:NO];

    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

/// 将view转为截图
+ (UIImage *)screenShotWithView:(UIView *)shotView{
    
    UIGraphicsBeginImageContextWithOptions([UIScreen mainScreen].bounds.size, YES, [UIScreen mainScreen].scale);
    
    //    UIView *snapshotView = [fromViewController.view snapshotViewAfterScreenUpdates:NO];
    
    // 这样重绘才可以完整将导航栏的所有图层绘出
    //    [[UIApplication sharedApplication].keyWindow drawViewHierarchyInRect:CGRectMake(0, 0,XMScreenW, XMScreenH) afterScreenUpdates:NO];
    [shotView drawViewHierarchyInRect:CGRectMake(0, 0,XMScreenW, XMScreenH) afterScreenUpdates:NO];
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

/**--------- 二维码图片 ---------*/
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

/** 将字符串转为二维码图片 */
+ (UIImage *)creatQRCodeImageWithString:(NSString *)text size:(CGFloat)imgWH{
    //1. 实例化二维码滤镜
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 2. 恢复滤镜的默认属性
    [filter setDefaults];
    // 3. 将字符串转换成NSData
    NSString *urlStr = text;
    NSData *data = [urlStr dataUsingEncoding:NSUTF8StringEncoding];
    // 4. 通过KVO设置滤镜inputMessage数据
    [filter setValue:data forKey:@"inputMessage"];
    // 5. 获得滤镜输出的图像
    CIImage *outputImage = [filter outputImage];
    return [self createNonInterpolatedUIImageFormCIImage:outputImage size:imgWH];
}

// 重绘生成更加高清的二维码图片
+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image size:(CGFloat)size{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer:@YES}];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

// 将图片大小转换成256左右的像素,提高识别速度和准确度
+ (UIImage *)changeTo256Image:(UIImage *)selectImage{
    
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


/**--------- 相册信息 ---------*/
/// 获得压缩图
+ (UIImage *)thumbImageWithAsset:(ALAsset *)asset{
    return [UIImage imageWithCGImage:[asset thumbnail]];
}

/// 获得原始图
+ (UIImage *)originImageWithAsset:(ALAsset *)asset{
    return [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
}

/// 获得图片的正式名称
+ (NSString *)imageNameWithAsset:(ALAsset *)asset{
    ALAssetRepresentation *representation = [asset defaultRepresentation];
    return [representation filename];
    
}


/**--------- gif相关方法 ---------*/
/**
 判断相册中的照片是否gif图片
 @param asset 相册
 */
+ (BOOL)isGifWithAsset:(ALAsset *)asset{
    // kUTTypeGIF实际上是 @"com.compuserve.gif"
    ALAssetRepresentation *re = [asset representationForUTI:(__bridge NSString *)kUTTypeGIF];
    
    return (re)? YES : NO;
}

/// 将相册中的gif图片转为data
+ (NSData *)changeGifToDataWithAsset:(ALAsset *)asset{
    ALAssetRepresentation *re = [asset representationForUTI:(__bridge NSString *)kUTTypeGIF];;
    long long size = re.size;
    uint8_t *buffer = malloc(size);
    NSError *error;
    NSUInteger bytes = [re getBytes:buffer fromOffset:0 length:size error:&error];
    NSData *data = [NSData dataWithBytes:buffer length:bytes];
    free(buffer);
    return data;
}

/// 将网页的gif图片保存到本地
+ (void)saveGifToAlbumWithURL:(NSString *)url{
    // 请求网络图片并写入本地
    NSError *error;
    NSData *gifData;
    if([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"]){
        gifData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url] options:NSDataReadingUncached error:&error];
    }else{
        gifData = [NSData dataWithContentsOfFile:url];
    }
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    NSDictionary *metadata = @{@"UTI":@"com.compuserve.gif"};
    [library writeImageDataToSavedPhotosAlbum:gifData metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error) {
        [MBProgressHUD showResult:(error? NO:YES) message:nil];
    }] ;
}

/// 将gif分解为图片组
+ (NSArray *)seprateGifAtPath:(NSString *)path{
    
    NSURL *gifImageUrl = [NSURL fileURLWithPath:path];
    //获取Gif图的原数据
    CGImageSourceRef gifSource = CGImageSourceCreateWithURL((CFURLRef)gifImageUrl, NULL);
    
    //获取Gif图有多少帧
    size_t gifcount = CGImageSourceGetCount(gifSource);
    NSMutableArray *imageS = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < gifcount; i++) {
        //由数据源gifSource生成一张CGImageRef类型的图片
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(gifSource, i, NULL);
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        [imageS addObject:image];
        CGImageRelease(imageRef);
    }
    //得到图片数组
    return imageS;
}

/// 将图片(url的string)保存到沙盒本地文件
+ (void)saveToLocalTempDirPicture:(NSString *)imageUrl{
    NSString *path = [XMSavePathUnit getWifiImageTempDirPath];
    // 确保文件文件夹以及上一级文件夹存在
    if (![[NSFileManager defaultManager] fileExistsAtPath:[XMSavePathUnit getWifiUploadDirPath]]){
        [[NSFileManager defaultManager] createDirectoryAtPath:[XMSavePathUnit getWifiUploadDirPath] withIntermediateDirectories:NO attributes:nil error:nil];
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]){
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil];
    }
    [self savePictrue:imageUrl path:path callBackViewController:nil];
}

/// 将图片(UIImage)保存到沙盒本地文件
+ (void)saveToLocalTempDirWithImage:(UIImage *)image{
    NSString *path = [XMSavePathUnit getWifiImageTempDirPath];
    // 确保文件文件夹以及上一级文件夹存在
    if (![[NSFileManager defaultManager] fileExistsAtPath:[XMSavePathUnit getWifiUploadDirPath]]){
        [[NSFileManager defaultManager] createDirectoryAtPath:[XMSavePathUnit getWifiUploadDirPath] withIntermediateDirectories:NO attributes:nil error:nil];
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]){
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    // 拼接文件名
    NSString *filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",[XMTimeTool dateChangeToString:[NSDate date] formatString:@"YYYYMMdd_HH时mm分ss秒"]]];
    
    // 转为NSData保存
    NSData *data = UIImageJPEGRepresentation(image, 0.7);
    BOOL result = [data writeToFile:filePath atomically:YES];
    [MBProgressHUD showResult:result message:nil];
}

/// 将图片(UIImage)保存到设备相册
+ (void)saveToAlbumWithImage:(UIImage *)image{
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    //要保存到本地相册,控制器必须实现@selector(image:didFinishSavingWithError:contextInfo:),目前指定到XMNavigationController
    if([vc isKindOfClass:NSClassFromString(@"XMNavigationController")]){
        UIImageWriteToSavedPhotosAlbum(image, vc, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    }else{
        [MBProgressHUD showFailed:@"未知原因"];
    }
}


/**
 通过url保存网络的图片或者gif到本地或者相册
  */
+ (void)savePictrue:(NSString *)imageUrl path:(NSString *)path callBackViewController:(UIViewController *)vc{
    
    // 对于网页上的图片,需要发起一个网络请求
    NSURL *url = [NSURL URLWithString:imageUrl];
    
    NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:[NSOperationQueue new]];
    
    NSURLRequest *imgRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30.0];
    
    NSURLSessionDownloadTask  *task = [session downloadTaskWithRequest:imgRequest completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            return ;
        }
        NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
        NSDictionary *resDict = [res allHeaderFields];
//        NSLog(@"---%@",resDict);
        NSString *extent = [[[resDict[@"Content-Type"] componentsSeparatedByString:@"/"] lastObject] lowercaseString];
        NSData * imageData = [NSData dataWithContentsOfURL:location];
        if(path){
            // 如果path存在,那么保存到本地
            NSString *filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",[XMTimeTool dateChangeToString:[NSDate date] formatString:@"YYYYMMdd_HH时mm分ss秒"],extent]];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                BOOL result = [imageData writeToFile:filePath atomically:YES];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD showResult:result message:nil];
                });
                
            });
            
        }else{
            // path为nil,则保存到相册
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([extent isEqualToString:@"gif"]){
                    [self saveGifToAlbumWithURL:imageUrl];
                    
                }else if([extent isEqualToString:@"jpeg"]){
                    UIImage * image = [UIImage imageWithData:imageData];
                    
#warning note 保存相片到本地的方法,头文件写着必须实现一个@selector(image:didFinishSavingWithError:contextInfo:),此外,还需要设置info.plist的一个key
                    UIImageWriteToSavedPhotosAlbum(image, vc, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
                }
            });
        }
        
    }];
    
    [task resume];
}

@end
