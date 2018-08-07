//
//  XMPersonFilmCollectionVC.m
//  hiWeb
//
//  Created by Niki on 17/9/17.
//  Copyright © 2017年 excellence.com.cn. All rights reserved.
//

#import "XMPersonFilmCollectionVC.h"
#import "XMSingleFilmModle.h"
#import "XMShowCollectionViewCell.h"
#import "XMPersonDataUnit.h"
#import "XMHiwebViewController.h"

#import "UIImageView+WebCache.h"
#import "MBProgressHUD+NK.h"


@interface XMPersonFilmCollectionVC ()<UIGestureRecognizerDelegate,XMPersonFilmCollectionVCDelegate>

// 标记右划开始的位置
@property (nonatomic, assign)  CGFloat starX;

@property (weak, nonatomic)  UIImageView *backImgV;
@property (weak, nonatomic)  UIImageView *forwardImgV;

// 展示相框
@property (weak, nonatomic)  UIView *imageContent;
@property (weak, nonatomic)  UIImageView *imageV;

// 当前图片索引
@property (nonatomic, assign)  NSUInteger imageIndex;

// 封面containerView
@property (weak, nonatomic)  UIView *containerView;

// 是否是首个控制器
@property (nonatomic, assign)  BOOL isFirstVC;

// 是否首次显示
@property (nonatomic, assign)  BOOL isFirstLoad;



@end

@implementation XMPersonFilmCollectionVC

static NSString * const reuseIdentifier = @"Cell";

#pragma mark - set/get
-(void)setData:(NSArray *)data
{
    _data = data;
    [self.collectionView reloadData];
}

- (UIView *)imageContent
{
    if (!_imageContent)
    {
        UIView *content = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        content.backgroundColor = [UIColor blackColor];
        // 添加到导航条之上
//        [self.navigationController.view insertSubview:content aboveSubview:self.navigationController.navigationBar];
        [self.view addSubview:content];
        
        // 相框
        UIImageView *imageV = [[UIImageView alloc] initWithFrame:content.frame];
        imageV.contentMode = UIViewContentModeScaleAspectFit;
        imageV.userInteractionEnabled = YES;
        [content addSubview:imageV];
        
        // 双击退出手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap)];
        tap.numberOfTapsRequired = 2;
        tap.delegate = self;
        [content addGestureRecognizer:tap];
        
        
        //旋转
        UIRotationGestureRecognizer *rotaitonGest = [[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(rotationView:)];
        rotaitonGest.delegate =self;
        [imageV addGestureRecognizer:rotaitonGest];
        
        //捏合
        UIPinchGestureRecognizer *pinchGest = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchView:)];
        pinchGest.delegate = self;
        [imageV addGestureRecognizer:pinchGest];
        
        //拖拽
        UIPanGestureRecognizer *panGest = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panView:)];
        panGest.delegate = self;
        [imageV addGestureRecognizer:panGest];
        
//        //轻扫
//        UISwipeGestureRecognizer *nextGest = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(nextImage)];
//        nextGest.direction = UISwipeGestureRecognizerDirectionLeft;
//        nextGest.delegate = self;
//        [imageV addGestureRecognizer:nextGest];
//        UISwipeGestureRecognizer *preGest = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(preImage)];
//        preGest.direction = UISwipeGestureRecognizerDirectionRight;
//        preGest.delegate = self;
//        [imageV addGestureRecognizer:preGest];
        
        
        self.imageV = imageV;
        _imageContent = content;
    }
    return _imageContent;
}


- (UIView *)statusBar
{
    return [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    
    // Register cell classes
    [self.collectionView registerClass:[XMShowCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    // 初始化参数
    self.collectionView.backgroundColor = [UIColor grayColor];
    self.isFirstLoad = YES;
    
    // 初始化箭头
    [self initSearchMode];

    // 监听横竖屏
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    // 双指下滑呼出
    UISwipeGestureRecognizer *searchSwip = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showMoreDetail:)];
    searchSwip.numberOfTouchesRequired = 2;  // 设置需要2个手指向下滑
    // 必须要实现一个代理方法支持多手势,这时候3指下滑同时也会触发单指滚动tableview
    searchSwip.delegate = self;
    searchSwip.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:searchSwip];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIView *contentV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    // 展示更多演员信息
    UIButton *actBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    [actBtn setTitle:@"更多演员" forState:UIControlStateNormal];
    [actBtn addTarget:self action:@selector(showActors) forControlEvents:UIControlEventTouchUpInside];
    [actBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [contentV addSubview:actBtn];
    if(self.actorArr.count)
    {
        actBtn.hidden = NO;
    }else
    {
        actBtn.hidden = YES;
    }
    // 展示更多同类影片
    UIButton *moviBtn = [[UIButton alloc] initWithFrame:CGRectMake(100,0, 100, 44)];
    [moviBtn setTitle:@"同类影片" forState:UIControlStateNormal];
    [moviBtn addTarget:self action:@selector(showMoreRelateFilm) forControlEvents:UIControlEventTouchUpInside];
    [moviBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [contentV addSubview:moviBtn];
    if(self.relateFilmArr.count)
    {
        moviBtn.hidden = NO;
    }else
    {
        moviBtn.hidden = YES;
    }
    
    self.navigationItem.titleView = contentV;
    // 开启标题栏交互
    self.navigationItem.titleView.userInteractionEnabled = YES;
    

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    // 根据目前的控制器栈里面的XMHiwebViewController来判断是否是首个控制器
    NSUInteger count = 0;
    for (UIViewController *vc in self.navigationController.childViewControllers){
        if([vc isKindOfClass:[XMHiwebViewController class]]){
            count++;
        }
    }
    self.isFirstVC = (count > 1)? NO : YES;
    
    // 强制纠正y方向64的偏移,view的y会由0变64,同时collectionView的高度会减少64
    if (self.isFirstLoad && !self.detailMode){
        self.isFirstLoad = NO;
        CGRect tarF = self.view.frame;
        tarF.origin.y = 64;
        self.view.frame = tarF;
    
    }else{
        CGRect tarF = self.view.frame;
        tarF.origin.y = 0;
        self.view.frame = tarF;
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    [self statusBar].hidden = NO;
}

- (void)dealloc
{
    // 移除监听横竖屏
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    NSLog(@"collectionVC ----- dealloc");
}

#pragma mark - 导航栏时间

// 展示更多同类影片
- (void)showMoreRelateFilm
{
    UIAlertController *tips = [UIAlertController alertControllerWithTitle:@"相似影片" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    // 判断请求得到的内容是否为空
    if (!self.relateFilmArr.count)
    {
        [MBProgressHUD showMessage:@"无同类影片" toView:self.view];
        return;
    }
    for (NSUInteger i = 0; i < self.relateFilmArr.count; i++)
    {
        XMSingleFilmModle *model = self.relateFilmArr[i];
        __weak typeof(self) weakSelf = self;
        
        UIAlertAction *goAction = [UIAlertAction actionWithTitle:model.title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
//            [weakSelf.navigationController popViewControllerAnimated:YES];
            // 打开单个作品,新创建一个self 并用导航控制器push出来
            [weakSelf starRequestWithModle:model];
            
        }];
        [tips addAction:goAction];
    }
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [tips addAction:cancelAction];
    [self presentViewController:tips animated:YES completion:nil];
}

// 展示更多演员信息
- (void)showActors
{
    UIAlertController *tips = [UIAlertController alertControllerWithTitle:@"演员信息" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    // 判断请求得到的内容是否为空
    if (!self.actorArr.count)
    {
        [MBProgressHUD showMessage:@"无演员信息" toView:self.view];
        return;
    }
    for (NSUInteger i = 0; i < self.actorArr.count; i++)
    {
        XMSingleFilmModle *model = self.actorArr[i];
        __weak typeof(self) weakSelf = self;
        
        UIAlertAction *goAction = [UIAlertAction actionWithTitle:model.title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
        {
            XMHiwebViewController *vc = [[XMHiwebViewController alloc] init];
            vc.view.frame = weakSelf.view.bounds;
            vc.index = 1;
            vc.url = model.url;
            [vc starRequest];
            [weakSelf.navigationController pushViewController:vc animated:NO];
//            // 通知首页加载演员所有作品
//            if ([weakSelf.delegate respondsToSelector:@selector(loadOtherActor:)])
//            {
//                [weakSelf.delegate loadOtherActor:model];
//            }
////            [weakSelf.navigationController popViewControllerAnimated:YES];
        }];
        [tips addAction:goAction];
    }
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [tips addAction:cancelAction];
    [self presentViewController:tips animated:YES completion:nil];
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.data.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    XMShowCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.modle = self.data[indexPath.item];
    return cell;
}

//定义每个UICollectionViewCell 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cellSize;
}
//定义每个Section 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return self.cellInset;
}

//每个section中不同的行之间的行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 5;
}

// 选中了某一个作品,应该打开图片预览
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    XMSingleFilmModle *model = self.data[indexPath.item];
    if (self.detailMode) // 展示单个作品模式
    {
//        self.currentModel = model;
        // 记录当前图片索引
        self.imageIndex = indexPath.item;
        
        // 隐藏状态栏,显示相框
        [self statusBar].hidden = YES;
        self.imageContent.hidden = NO;
        self.navigationController.navigationBarHidden = YES;
        
        // 设置图片
        [self.imageV sd_setImageWithURL:[NSURL URLWithString:model.imgUrl]];
    }else // 所有作品
    {
        
        [self starRequestWithModle:model];
    }
}

- (void)starRequestWithModle:(XMSingleFilmModle *)model
{
    if (!model.url){
        [MBProgressHUD showMessage:@"请求的url为空" toView:self.view];
        return;
    }
    // 开启网络加载提示
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSString *html;
    while (!html.length)
    {
        NSError *error;
        html = [NSString stringWithContentsOfURL:[NSURL URLWithString:model.url] encoding:NSUTF8StringEncoding error:&error];
        if (error.code == -999){
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            return;
        }
        
    }
    
    // 关闭网络加载提示
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
   
    NSArray *dataArr = [XMPersonDataUnit dealDatePicture:html];
    NSArray *actArr = [XMPersonDataUnit dealDateAcotr:html];
    NSArray *relateFilmArr = [XMPersonDataUnit dealRelateFilmArr:html];
    
    // 作品摘要信息
    XMSingleFilmModle *detatilModel = [XMPersonDataUnit dealDetail:html];
    
    // 新创建一个展示单个作品的详细信息的XMPersonFilmCollectionVC
    XMPersonFilmCollectionVC *vc = [[XMPersonFilmCollectionVC alloc] initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    vc.currentModel = detatilModel;
    vc.detailMode = YES;
    vc.delegate = self;
//    vc.delegate = self.parentViewController;
    vc.view.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    vc.cellSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    vc.cellInset = UIEdgeInsetsMake(0, 0, 0, 0);
    vc.data = dataArr;
    vc.actorArr = actArr;
    vc.relateFilmArr = relateFilmArr;
    
    // 用导航控制器push出来
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 横竖屏监听
- (void)deviceOrientationDidChange
{
    if(self.detailMode)
    {
        self.cellSize = [UIScreen mainScreen].bounds.size;
    }
    [self.collectionView reloadData];
}

#pragma mark - scrollerview delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self.parentViewController isKindOfClass:[XMHiwebViewController class]])
    {
        // 如果是展示所有作品,需要点击事件
        XMHiwebViewController *vc = (XMHiwebViewController *)self.parentViewController;
        vc.searchV.hidden = YES;
        [vc.searchV resignFirstResponder];
    }
}



#pragma mark - gesture delegate
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - 手势及触发方法

// 暂时单个作品的封面
- (void)showMoreDetail:(UISwipeGestureRecognizer *)swipe{
    
    [self.containerView removeFromSuperview];
    // 隐藏状态栏,显示相框
    [self statusBar].hidden = YES;
    self.navigationController.navigationBarHidden = YES;
    
    UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
    view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:view];
    self.containerView = view;
    
    CGFloat screenW = self.view.bounds.size.width;
    // 标题
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 74, screenW, 100)];
    lab.backgroundColor = [UIColor orangeColor];
    [view addSubview:lab];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.text = self.currentModel.title;
    lab.numberOfLines = 0;
    lab.font = [UIFont systemFontOfSize:17];
    lab.textColor = [UIColor blackColor];
    
    // 图片
    UIImageView *iamgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lab.frame) + 10, screenW, 400)];
    iamgV.backgroundColor = [UIColor grayColor];
    [iamgV sd_setImageWithURL:[NSURL URLWithString:self.currentModel.imgUrl]];
    [view addSubview:iamgV];
    iamgV.userInteractionEnabled = YES;
    // 点击图片放大
    UITapGestureRecognizer *tapToZoom = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(detailPicture)];
    [iamgV addGestureRecognizer:tapToZoom];
    
    // 介绍
    
    // 封面视图取消
    UISwipeGestureRecognizer *swipeToCance = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(removeTheView)];
    swipeToCance.direction = UISwipeGestureRecognizerDirectionDown;
    [view addGestureRecognizer:swipeToCance];
}

// 移除单个作品封面视图
- (void)removeTheView
{
    [self.containerView removeFromSuperview];
    // 隐藏状态栏
    [self statusBar].hidden = NO;
    self.navigationController.navigationBarHidden = NO;
}

// 显示单个作品封面
- (void)detailPicture{
    // 隐藏状态栏,显示相框
    [self statusBar].hidden = YES;
    self.imageContent.hidden = NO;
    self.navigationController.navigationBarHidden = YES;
    // 设置图片
    [self.imageV sd_setImageWithURL:[NSURL URLWithString:self.currentModel.imgUrl]];
}

#pragma mark 图片手势
- (void)preImage
{
//    self.imageV.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
//    [self.view setNeedsLayout];
    self.imageV.transform = CGAffineTransformIdentity;
    [self.view setNeedsLayout];
    if (self.imageIndex == 0) return;
    self.imageIndex--;
    
    XMSingleFilmModle *model = self.data[self.imageIndex];
    [self.imageV sd_setImageWithURL:[NSURL URLWithString:model.imgUrl]];
}

- (void)nextImage
{
//    self.imageV.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    self.imageV.transform = CGAffineTransformIdentity;
    [self.view setNeedsLayout];

    if (self.imageIndex == self.data.count - 1) return;
    self.imageIndex++;
    
    XMSingleFilmModle *model = self.data[self.imageIndex];
    [self.imageV sd_setImageWithURL:[NSURL URLWithString:model.imgUrl]];
}

-(void)rotationView:(UIRotationGestureRecognizer *)rotationGest{
    
    //旋转角度
    //旋转的角度也一个累加的过程
//    NSLog(@"旋转角度 %f",rotationGest.rotation);
    
    // 设置图片的旋转
    self.imageV.transform = CGAffineTransformRotate(self.imageV.transform, rotationGest.rotation);
    
    // 清除 "旋转角度" 的累
    rotationGest.rotation = 0;
    
}

-(void)pinchView:(UIPinchGestureRecognizer *)pinchGest{
    //设置图片缩放
    
    self.imageV.transform = CGAffineTransformScale(self.imageV.transform, pinchGest.scale, pinchGest.scale);
    
    // 还源
    pinchGest.scale = 1;
}

-(void)panView:(UIPanGestureRecognizer *)panGest{
    
    //拖拽的距离(距离是一个累加)
    CGPoint trans = [panGest translationInView:panGest.view];
    //    NSLog(@"%@",NSStringFromCGPoint(trans));
//    if (panGest.state == UIGestureRecognizerStateEnded)
//    {
//        if (self.imageV.frame.origin.x > 0)
//        {
//            [self preImage];
//        }
//        if (CGRectGetMaxX(self.imageV.frame) < [UIScreen mainScreen].bounds.size.width)
//        {
//            [self nextImage];
//        }
//    
//    }
    //设置图片移动
    CGPoint center =  self.imageV.center;
    center.x += trans.x;
    center.y += trans.y;
    self.imageV.center = center;
    
    //清除累加的距离
    [panGest setTranslation:CGPointZero inView:panGest.view];
}
/** 双击退出 */
- (void)doubleTap{
    self.navigationController.navigationBarHidden = NO;
    [self statusBar].hidden = NO;
    [self.imageContent removeFromSuperview];
    [self.imageV removeFromSuperview];
    
}

#pragma mark collection 手势
/** 返回手势 */
- (void)panToBackForward:(UIGestureRecognizer *)gesture{
    
    if ([gesture isKindOfClass:[UIPanGestureRecognizer class]]){
        // 如果是pan手势,需要根据左划还是右划决定返回还是向前
        switch (gesture.state) {
            case UIGestureRecognizerStateBegan:{
                self.starX = [gesture locationInView:self.view].x;
                break;
            }
            case UIGestureRecognizerStateChanged:{
                if (self.detailMode) return;
                CGFloat panShift = [gesture locationInView:self.view].x - self.starX;
                // 超过左右箭头的大小则不再移动箭头
                if (panShift > self.backImgV.frame.size.width + 10 || -panShift > self.forwardImgV.frame.size.width + 10) return;
                // 根据左划或者右划移动箭头
                if (panShift > 0 && self.isFirstVC == NO)
                {
                    self.backImgV.hidden = NO;
                    self.backImgV.transform = CGAffineTransformMakeTranslation(panShift, 0);
                }else if(panShift < 0 )
                {
//                    self.forwardImgV.hidden = NO;
//                    self.forwardImgV.transform = CGAffineTransformMakeTranslation(panShift, 0);
                }
                break;
            }
            case UIGestureRecognizerStateEnded:{
                if (self.detailMode) return;
                CGFloat panShift = [gesture locationInView:self.view].x - self.starX;
                // 右划且滑动距离大于50,表示应该返回,反之左划并且距离大于50表示向前,并复位左右两个箭头
                if (panShift > 100){
                    self.backImgV.transform = CGAffineTransformIdentity;
                    // 如果是最后一一个XMHiwebViewController,那么向左滑不能退出模块
                    if(!self.isFirstVC){
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                    NSLog(@"back");
                    
                }else if(panShift < -100){
                    self.forwardImgV.transform = CGAffineTransformIdentity;
                    NSLog(@"forward");

                }
                
                // 手势结束之后隐藏两边箭头
                self.backImgV.hidden = YES;
                self.forwardImgV.hidden = YES;
                break;
            }
            default:
                break;
        }
    }
}

/**  初始化两边箭头和手势 */
- (void)initSearchMode
{
    // 添加左右两个箭头
    CGFloat imgVWH = 50;
    UIImageView *backImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iconBack"]];
    backImgV.frame = CGRectMake(-imgVWH, CGRectGetMidY([UIScreen mainScreen].bounds), imgVWH, imgVWH);
    backImgV.hidden = YES;
    self.backImgV = backImgV;
    self.backImgV.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:backImgV];
    UIImageView *forwardImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iconForward"]];
    forwardImgV.frame = CGRectMake(CGRectGetMaxX([UIScreen mainScreen].bounds), CGRectGetMidY([UIScreen mainScreen].bounds), imgVWH, imgVWH);
    forwardImgV.hidden = YES;
    self.forwardImgV = forwardImgV;
    self.forwardImgV.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self.view addSubview:forwardImgV];
    
    // 为添加前进后退手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panToBackForward:)];
    pan.delegate = self;
    [self.view addGestureRecognizer:pan];
    
    
    // 添加双击页面手势(待定)
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(aaa)];
    tap.numberOfTapsRequired = 2;
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
}

// 双击页面触发
- (void)aaa
{
    NSLog(@"%s",__func__);
}

@end
