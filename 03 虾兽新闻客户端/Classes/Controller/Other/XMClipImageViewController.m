//
//  XMClipImageViewController.m
//  虾兽维度
//
//  Created by Niki on 18/3/4.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMClipImageViewController.h"

#import "CommonHeader.h"

@interface XMClipImageViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (weak, nonatomic)  UIImageView *photoView;
@property (weak, nonatomic)  UIButton *clipBtn;
@property (weak, nonatomic)  UIButton *saveBtn;
@property (weak, nonatomic)  UIButton *addBtn;
@property (weak, nonatomic)  UIView *btnContentV;
@property (nonatomic, strong) UIImage *seleImage;
@property (nonatomic, strong) UIImage *saveImage;

@end

@implementation XMClipImageViewController

#pragma mark - lazy
- (UIImageView *)photoView
{
    if (!_photoView)
    {
        CGFloat padding = 20;
        UIImageView *photoView = [[UIImageView alloc] initWithFrame:CGRectMake(padding, 3 * padding + 10, XMScreenW - 2 * padding, XMScreenW - 2 * padding)];
        _photoView = photoView;
        [self.view addSubview:photoView];
        photoView.backgroundColor = [UIColor grayColor];
        
    }
    return _photoView;
}

- (UIView *)btnContentV
{
    if (!_btnContentV)
    {
        UIView *btnContentV = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.photoView.frame) + 10, XMScreenW, 200)];
        _btnContentV = btnContentV;
        [self.view addSubview:btnContentV];
        
        CGFloat btnW = 100;
        CGFloat btnH = 44;
        CGFloat margin = 5;
        UIButton *addBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.5 * (XMScreenW - btnW), 0, btnW, btnH)];
        [btnContentV addSubview:addBtn];
        _addBtn = addBtn;
        [addBtn addTarget:self action:@selector(addImageFromUlbum) forControlEvents:UIControlEventTouchUpInside];
        [addBtn setTitle:@"添加图片" forState:UIControlStateNormal];
        [addBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [addBtn setBackgroundColor:[UIColor grayColor]];
        addBtn.layer.cornerRadius = 10;
        addBtn.clipsToBounds = YES;
        
        
        
        UIButton *clipBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.5 * (XMScreenW - btnW), CGRectGetMaxY(addBtn.frame) + margin, btnW, btnH)];
        [btnContentV addSubview:clipBtn];
        _clipBtn = clipBtn;
        [clipBtn addTarget:self action:@selector(photoDidClip:) forControlEvents:UIControlEventTouchUpInside];
        [clipBtn setTitle:@"裁剪图片" forState:UIControlStateNormal];
        [clipBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [clipBtn setBackgroundColor:[UIColor grayColor]];
        clipBtn.layer.cornerRadius = 10;
        clipBtn.clipsToBounds = YES;
        
        UIButton *saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.5 * (XMScreenW - btnW), CGRectGetMaxY(clipBtn.frame) + margin, btnW, btnH)];
        [btnContentV addSubview:saveBtn];
        _saveBtn = saveBtn;
        [saveBtn addTarget:self action:@selector(saveToAlbum) forControlEvents:UIControlEventTouchUpInside];
        [saveBtn setTitle:@"保存到相册" forState:UIControlStateNormal];
        [saveBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [saveBtn setBackgroundColor:[UIColor grayColor]];
        saveBtn.layer.cornerRadius = 10;
        saveBtn.clipsToBounds = YES;
    }
    return _btnContentV;
}

#pragma mark - 系统原生
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 初始化UI
    [self photoView];
    [self btnContentV];
    
}




#pragma mark - 按钮点击动作

/**
 保存裁剪后的照片到相册
 */
- (void)saveToAlbum
{
    //png格式
    //    NSData *imagedata = UIImagePNGRepresentation(self.saveImage);
    //JEPG格式
    NSData *imagedata = UIImageJPEGRepresentation(self.saveImage,0.5);
    
    //    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    //    NSString *documentsDirectory=[paths objectAtIndex:0];
    //
    //
    //    NSString *savedImagePath=[documentsDirectory stringByAppendingPathComponent:@"saveFore.png"];
    //
    //    [imagedata writeToFile:savedImagePath atomically:YES];
    //
    //    NSLog(@"%@",savedImagePath);
    
    // 将图片保存到手机相册
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIImage * image = [UIImage imageWithData:imagedata];
        
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    });
}

/** 提示用户保存图片成功与否(系统必须实现的方法) */
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *ale= [[UIAlertView alloc] initWithTitle:@"提示" message:@"保存图片到相册失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"", nil];
        [ale show];
        //        [MBProgressHUD showMessage:@"保存失败" toView:self.view];
    }else{
        UIAlertView *ale= [[UIAlertView alloc] initWithTitle:@"提示" message:@"保存图片到相册成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [ale show];
        
        //        [MBProgressHUD showMessage:@"保存成功" toView:self.view];
    }
}

/**
 裁剪图片
 */
- (void)photoDidClip:(id)sender
{
    // 可定义参数
    // 圆环的宽度系数
    CGFloat ringWPer = 0.02;
    UIColor *borderColor = [UIColor grayColor] ;
    UIColor *backgroundColor = [UIColor whiteColor];
  
    // 1.加载旧的图片
    CGFloat borderW = self.seleImage.size.width * ringWPer;
    self.photoView.image = self.seleImage;
    
    // 新的图片尺寸
    CGFloat imageW = self.seleImage.size.width + 2 * borderW;
    CGFloat imageH = self.seleImage.size.height + 2 * borderW;
    
    // 设置新的图片尺寸
    CGFloat margin = 5;
    CGFloat circirW = (imageW > imageH ? imageH : imageW) + margin * 2;
    
    // 开启上下文
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(circirW, circirW), NO, 0.0);
    
    // 获取当前上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // 画一个黑色的背景矩形
    UIBezierPath *pathBack = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, circirW, circirW)];
    CGContextAddPath(ctx, pathBack.CGPath);
    [backgroundColor set];
    // 渲染
    CGContextFillPath(ctx);
    
    // 画大圆
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(margin, margin, circirW - 2 * margin, circirW - 2 * margin)];
    
    // 添加到上下文
    CGContextAddPath(ctx, path.CGPath);
    
    [borderColor set];
    
    // 渲染
    CGContextFillPath(ctx);
    
    CGRect clipR = CGRectMake(borderW + margin, borderW + margin, self.seleImage.size.width, self.seleImage.size.height);
    
    // 画圆：正切于旧图片的圆
    UIBezierPath *clipPath = [UIBezierPath bezierPathWithOvalInRect:clipR];
    
    // 设置裁剪区域
    [clipPath addClip];
    
    
    // 画图片
    [self.seleImage drawAtPoint:CGPointMake(borderW + margin, borderW + margin)];
    
    // 获取新的图片
    self.saveImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 关闭上下文
    UIGraphicsEndImageContext();

    
    // 更新相框相册
    self.photoView.image = self.saveImage;
}

/**
 从相册中选择图片
 */
- (void)addImageFromUlbum{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.view.backgroundColor = [UIColor orangeColor];
    UIImagePickerControllerSourceType sourcheType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.sourceType = sourcheType;
    picker.delegate = self;
    picker.allowsEditing = YES;
    
    [self.navigationController presentViewController:picker animated:YES completion:nil];
    
}

#pragma mark - UIImagePickerControllerDelegate
//当用户取消选取时调用
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    // 先dismiss相册
    [picker dismissViewControllerAnimated:YES completion:nil];
}


//当用户选取完成后调用
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // 先dismiss相册
    [picker dismissViewControllerAnimated:YES completion:nil];

    // 将用户选择并且编辑过的照片取得并更新相框
    self.seleImage = [info objectForKey:UIImagePickerControllerEditedImage];
    self.photoView.image = self.seleImage;
}
@end
