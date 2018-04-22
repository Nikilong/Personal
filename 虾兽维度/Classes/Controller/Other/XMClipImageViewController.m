//
//  XMClipImageViewController.m
//  虾兽维度
//
//  Created by Niki on 18/3/4.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMClipImageViewController.h"
#import "MBProgressHUD+NK.h"
#import "CommonHeader.h"

typedef enum : NSUInteger {
    BGReviewBtnTypeRing,
    BGReviewBtnTypeIMG,
} BGReviewBtnType;

@interface XMClipImageViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextFieldDelegate>

@property (weak, nonatomic)  UIImageView *photoView;    // 相框
@property (weak, nonatomic)  UIButton *clipBtn;         // 裁剪按钮
@property (weak, nonatomic)  UIButton *clipParBtn;      // 裁剪参数按钮
@property (weak, nonatomic)  UIButton *saveBtn;         // 保存到相册按钮
@property (weak, nonatomic)  UIButton *addBtn;          // 从像相册选择图片按钮
@property (weak, nonatomic)  UIButton *mirrorBtn;       // 镜像按钮
@property (weak, nonatomic)  UIView *btnContentV;       // 所有按钮的容器
@property (nonatomic, strong) UIImage *seleImage;       // 已选择的图片
@property (nonatomic, strong) UIImage *saveImage;       // 将要保存的图片

@property (nonatomic, strong) NSArray *mirrorArr;
@property (nonatomic, assign)  NSUInteger index;



/*  clipParV 相关参数 */
@property (weak, nonatomic)  UIView *clipParV;
@property (weak, nonatomic)  UITextField *ringParTF;
@property (weak, nonatomic)  UITextField *ringBGTF;
@property (weak, nonatomic)  UITextField *imgBGTF;


@property (assign, nonatomic) CGFloat ringWPer;
@property (strong, nonatomic) UIColor *ringColor;
@property (strong, nonatomic) UIColor *imgBGColor;
/*  clipParV 相关参数 */

// 手动添加照片
@property (nonatomic, assign)  BOOL manualMode;


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
        UIView *btnContentV = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.photoView.frame) + 10, XMScreenW, 250)];
        _btnContentV = btnContentV;
        [self.view addSubview:btnContentV];
        
        CGFloat btnW = 100;
        CGFloat btnH = 44;
        CGFloat margin = 5;
        
        // 初始化5个按钮
        self.addBtn = [self addButtonWithTitle:@"添加图片" selector:@selector(addImageFromUlbum) parentView:_btnContentV];
        self.addBtn.frame = CGRectMake(0.5 * (XMScreenW - btnW), 0, btnW, btnH);
        
        self.mirrorBtn = [self addButtonWithTitle:@"镜像图片" selector:@selector(mirrorImage) parentView:_btnContentV];
        self.mirrorBtn.frame = CGRectMake(0.5 * (XMScreenW - btnW), CGRectGetMaxY(self.addBtn.frame) + margin, btnW, btnH);
        
        self.clipParBtn = [self addButtonWithTitle:@"裁剪参数" selector:@selector(setClipParamers) parentView:_btnContentV];
        self.clipParBtn.frame = CGRectMake(0.5 * (XMScreenW - btnW), CGRectGetMaxY(self.mirrorBtn.frame) + margin, btnW, btnH);
        
        self.clipBtn = [self addButtonWithTitle:@"裁剪图片" selector:@selector(photoDidClip) parentView:_btnContentV];
        self.clipBtn.frame = CGRectMake(0.5 * (XMScreenW - btnW), CGRectGetMaxY(self.clipParBtn.frame) + margin, btnW, btnH);
        
        self.saveBtn = [self addButtonWithTitle:@"保存到相册" selector:@selector(saveToAlbum) parentView:_btnContentV];
        self.saveBtn.frame = CGRectMake(0.5 * (XMScreenW - btnW), CGRectGetMaxY(self.clipBtn.frame) + margin, btnW, btnH);
        
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

    // 初始化自动打开相册
    self.manualMode = NO;
    
    // 初始化镜像参数
    self.index = 0;
    [NSNumber numberWithInteger:UIImageOrientationUpMirrored];
    self.mirrorArr = @[[NSNumber numberWithInteger:UIImageOrientationUpMirrored],[NSNumber numberWithInteger:UIImageOrientationDownMirrored],[NSNumber numberWithInteger:UIImageOrientationLeftMirrored],[NSNumber numberWithInteger:UIImageOrientationRightMirrored]];
    
    // 初始化裁剪参数
    [self setDefaultClipParameters];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (!self.seleImage && !self.manualMode){
        
        // 延迟0.25秒执行
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            // 当没有图片的自动打开相册
            [self addImageFromUlbum];
        });
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    // 收起键盘
    [self.view endEditing:YES];
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
    
    
    // 将图片保存到手机相册
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIImage * image = [UIImage imageWithData:imagedata];
        
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    });
}

/** 提示用户保存图片成功与否(系统必须实现的方法) */
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *msg = (error) ? @"保存图片到相册失败" : @"保存图片到相册成功";
    [MBProgressHUD showMessage:msg toView:self.view];
}


/**
 裁剪图片
 */
- (void)photoDidClip
{
    
    if (!self.seleImage){
        [MBProgressHUD showMessage:@"请先添加一张图片" toView:self.view];
        return;
    }
    // 可定义参数
    // 圆环的宽度系数
    CGFloat ringWPer = self.ringWPer;
    UIColor *ringColor = self.ringColor;
    UIColor *imgBGColor = self.imgBGColor;
  
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
    
    // 画一个背景矩形
    UIBezierPath *pathBack = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, circirW, circirW)];
    CGContextAddPath(ctx, pathBack.CGPath);
    [imgBGColor set];
    // 渲染
    CGContextFillPath(ctx);
    
    // 画大圆
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(margin, margin, circirW - 2 * margin, circirW - 2 * margin)];
    
    // 添加到上下文
    CGContextAddPath(ctx, path.CGPath);
    
    [ringColor set];
    
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


/**
 将图片镜像化
 */
- (void)mirrorImage{
    if (self.index > 3){
        self.index = 0;
    }
//    self.seleImage = [[UIImage alloc] initWithCGImage:self.seleImage.CGImage scale:1.0 orientation:[self.mirrorArr[self.index] integerValue]];
//    self.saveImage = self.seleImage;
//    self.photoView.image = self.seleImage;
    UIImage *image = [[UIImage alloc] initWithCGImage:self.seleImage.CGImage scale:1.0 orientation:[self.mirrorArr[self.index] integerValue]];
//    self.saveImage = self.seleImage;
    self.photoView.image = image;
    
    self.index++;
}

#pragma mark - 设置参数界面
/**
 设置裁剪参数
 */
- (void)setClipParamers{
    // 隐藏导航栏,防止误点击
    self.navigationController.navigationBar.hidden = YES;
    
    // 大容器
    UIView *clipParV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, XMScreenW, XMScreenH)];
    clipParV.backgroundColor = [UIColor whiteColor];
    self.clipParV = clipParV;
    [self.view addSubview:clipParV];
    
    CGFloat marginX = 20;
    CGFloat marginY = 30;
    CGFloat padding = 10;
    CGFloat bgBtnW = 120;
    CGFloat bgBtnH = 44;
    
    // 环系数标签
    UILabel *ringLabel = [self addLabelWithTitlt:@"环宽度系数"];
    ringLabel.frame = CGRectMake(marginX, marginY, 220, 44);
    [clipParV addSubview:ringLabel];
    
    // 环系数输入框(与环系数标签同高)
    CGFloat ringPaTFW = 120;
    UITextField *ringPaTF = [self addTextFieldWithPlaceholder:@" 默认0.02"];
    ringPaTF.frame = CGRectMake((XMScreenW - marginX - ringPaTFW), CGRectGetMinY(ringLabel.frame), ringPaTFW, 44);
    [clipParV addSubview:ringPaTF];
    self.ringParTF = ringPaTF;
    ringPaTF.delegate = self;
    
    // 环背景颜色标签
    UILabel *ringBGLabel = [self addLabelWithTitlt:@"圆环颜色ARGB"];
    ringBGLabel.frame = CGRectMake(marginX, CGRectGetMaxY(ringLabel.frame) + marginY, 220, 44);
    [clipParV addSubview:ringBGLabel];
    
    // 环背景颜色预览按钮
    UIButton *ringBGBtn = [self addButtonWithTitle:@"预览" selector:@selector(changeClipParViewColor:) parentView:clipParV];
    ringBGBtn.tag = BGReviewBtnTypeRing;
    ringBGBtn.frame = CGRectMake((XMScreenW - marginX - bgBtnW), CGRectGetMinY(ringBGLabel.frame), bgBtnW, bgBtnH);
    
    // 环背景颜色输入框
    UITextField *ringBGTF = [self addTextFieldWithPlaceholder:@" 格式A-R-G-B,例如 1-255-255-255"];
    ringBGTF.frame = CGRectMake(marginX, CGRectGetMaxY(ringBGLabel.frame) + padding, 330, 44);
    [clipParV addSubview:ringBGTF];
    self.ringBGTF = ringBGTF;
    ringBGTF.delegate = self;
    
    // 图片背景颜色标签
    UILabel *imgBGLabel = [self addLabelWithTitlt:@"图片背景颜色ARGB"];
    imgBGLabel.frame = CGRectMake(marginX, CGRectGetMaxY(ringBGTF.frame) + marginY, 220, 44);
    [clipParV addSubview:imgBGLabel];
    
    // 图片背景颜色预览按钮
    UIButton *imgBGBtn = [self addButtonWithTitle:@"预览" selector:@selector(changeClipParViewColor:) parentView:clipParV];
    imgBGBtn.tag = BGReviewBtnTypeIMG;
    imgBGBtn.frame = CGRectMake((XMScreenW - marginX - bgBtnW), CGRectGetMinY(imgBGLabel.frame), bgBtnW, bgBtnH);
    
    // 图片背景颜色输入框
    UITextField *imgBGTF = [self addTextFieldWithPlaceholder:@" 格式A-R-G-B,例如 1-255-255-255"];
    imgBGTF.frame = CGRectMake(marginX, CGRectGetMaxY(imgBGLabel.frame) + padding, 330, 44);
    [clipParV addSubview:imgBGTF];
    self.imgBGTF = imgBGTF;
    imgBGTF.delegate = self;
    
    CGFloat btnW = 180;
    CGFloat btnH = 50;
    CGFloat bigBtnPadding = (XMScreenW - btnW) * 0.5;
    // 保存参数按钮
    UIButton *parSaveBtn = [self addButtonWithTitle:@"保存" selector:@selector(saveClipParameter) parentView:clipParV];
    [parSaveBtn setBackgroundColor:[UIColor orangeColor]];
    parSaveBtn.frame = CGRectMake(bigBtnPadding, CGRectGetMaxY(imgBGTF.frame) + marginY, btnW, btnH);
    
    // 取消保存参数按钮
    UIButton *parCanceltn = [self addButtonWithTitle:@"取消" selector:@selector(removeClipParametersView) parentView:clipParV];
    [parCanceltn setBackgroundColor:[UIColor orangeColor]];
    parCanceltn.frame = CGRectMake(bigBtnPadding, CGRectGetMaxY(parSaveBtn.frame) + padding, btnW, btnH);
    
    // 恢复默认参数按钮
    UIButton *defaultBtn = [self addButtonWithTitle:@"重置参数" selector:@selector(setDefaultClipParameters) parentView:clipParV];
    [defaultBtn setBackgroundColor:[UIColor orangeColor]];
    defaultBtn.frame = CGRectMake(bigBtnPadding,CGRectGetMaxY(parCanceltn.frame) + padding, btnW, btnH);
    
}

// 颜色预览按钮点击事件
- (void)changeClipParViewColor:(UIButton *)btn{
    // 收起键盘
    [self.view endEditing:YES];
    
    NSString *colStr = @"";
    if (btn.tag == BGReviewBtnTypeRing){
        colStr = self.ringBGTF.text;
    }else if (btn.tag == BGReviewBtnTypeIMG){
        colStr = self.imgBGTF.text;
    }
    if (!colStr.length){
        [self showError];
        return;
    }
    
    UIColor *reColor = [self changeToARGBFromString:colStr];
    if (reColor){
        self.clipParV.backgroundColor = reColor;
    }
}

// 将字符串转为ARGB颜色
- (UIColor *)changeToARGBFromString:(NSString *)text{
    NSArray *array = [text componentsSeparatedByString:@"-"];
    if (array.count != 4) {
        [self showError];
        return nil;
    }
    
    double valueA = [array[0] doubleValue];
    if (!valueA || valueA >= 0.0 || valueA <= 1.0){
        valueA = 1.0;
    }
    NSUInteger valueR = 0;
    NSUInteger valueG = 0;
    NSUInteger valueB = 0;
    NSUInteger valueCu = 0;
    for (NSUInteger i = 1; i < array.count; i++) {
        valueCu = [array[i] integerValue];
        if (!valueCu)
        {
            [self showError];
            return nil;
        }
        if (i == 1){
            valueR = (valueCu > 255) ? 255 : valueCu;
        }else if (i == 2){
            valueG = (valueCu > 255) ? 255 : valueCu;
        }else if (i == 3){
            valueB = (valueCu > 255) ? 255 : valueCu;
        }
    }
    
    return [UIColor colorWithRed:valueR/255.0 green:valueG/255.0 blue:valueB/255.0 alpha:valueA];
}

// 设置参数界面取消按钮事件
- (void)saveClipParameter{
    if (self.ringParTF.text.length > 0){
        if ([self.ringParTF.text doubleValue] > 0 && [self.ringParTF.text doubleValue] < 1){
            self.ringWPer =  [self.ringParTF.text doubleValue];
        }else{
            [self showError];
        }
    }
    if (self.ringBGTF.text.length > 0){
        
        self.ringColor = [self changeToARGBFromString:self.ringBGTF.text];
    }
    if (self.imgBGTF.text.length > 0){
        
        self.imgBGColor = [self changeToARGBFromString:self.imgBGTF.text];
    }
    
    [self removeClipParametersView];
    
    // 确定保存之后应该自动显示剪切结果
    [self photoDidClip];
}

// 单独抽出移除和恢复导航栏可见
- (void)removeClipParametersView{
    
    [self.clipParV removeFromSuperview];
    self.navigationController.navigationBar.hidden = NO;
}

// 设置默认参数
- (void)setDefaultClipParameters{
    self.ringWPer = 0.02;
    self.ringColor = [UIColor grayColor];
    self.imgBGColor = [UIColor whiteColor];
    [self removeClipParametersView];
}

// 提示不合法输入
- (void)showError{
    [MBProgressHUD showMessage:@"不合法输入" toView:self.view];
}

#pragma mark - 标准化控件
// 返回标准化TextField
- (UITextField *)addTextFieldWithPlaceholder:(NSString *)placeholder{
    
    UITextField *textF = [[UITextField alloc] init];
    textF.placeholder = placeholder;
    textF.leftView = [[UIView alloc] initWithFrame:CGRectMake(5, 0, 5, 0)];
    textF.leftViewMode = UITextFieldViewModeAlways;
    textF.clearButtonMode = UITextFieldViewModeAlways;
    
    textF.layer.borderWidth = 1;
    textF.layer.cornerRadius = 5;
    textF.layer.borderColor = [UIColor colorWithRed:223/255.0 green:223/255.0 blue:223/255.0 alpha:1].CGColor;
    return textF;
}

// 返回标准化lable
- (UILabel *)addLabelWithTitlt:(NSString *)title{
    UILabel *detailsLabel = [[UILabel alloc] init];
    detailsLabel.adjustsFontSizeToFitWidth = NO;
    detailsLabel.textAlignment = NSTextAlignmentLeft;
    detailsLabel.textColor = [UIColor blackColor];
    detailsLabel.numberOfLines = 0;
    detailsLabel.font = [UIFont boldSystemFontOfSize:17];
    detailsLabel.opaque = NO;
    detailsLabel.backgroundColor = [UIColor clearColor];
    detailsLabel.text = title;
    return detailsLabel;
    
    
}

// 返回标准化button
- (UIButton *)addButtonWithTitle:(NSString *)title selector:(SEL)selector parentView:(UIView *)parView{
    UIButton *btn = [[UIButton alloc] init];
    [parView addSubview:btn];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor grayColor]];
    btn.layer.cornerRadius = 10;
    btn.clipsToBounds = YES;
    return btn;
    
}


#pragma mark - UIImagePickerControllerDelegate
//当用户取消选取时调用
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    // 用户自动取消表示是需要手动添加照片
    self.manualMode = YES;
    
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

#pragma mark - UITextfieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
@end
