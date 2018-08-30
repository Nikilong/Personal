//
//  XMPhotoCollectionViewController.m
//  虾兽维度
//
//  Created by Niki on 2018/5/22.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMPhotoCollectionViewController.h"
#import "XMWifiTransModel.h"
#import "XMPhotoCollectionViewCell.h"
#import "MBProgressHUD+NK.h"
#import "XMImageUtil.h"
#import "UIImageView+WebCache.h"
#import "XMNavigationController.h"


@interface XMPhotoCollectionViewController ()<UIScrollViewDelegate,UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate>

@property (weak, nonatomic)  UILabel *titLab;
@property (weak, nonatomic)  NSTimer *timer;
@property (nonatomic, assign)  double timeInterval;
@property (nonatomic, assign)  double gifTimeInterval;
@property (weak, nonatomic)  UIButton *timerBtn;

@property (nonatomic, assign)  int imageIndex;
    
/**拖拽图片退出浏览的相关变量**/
@property (strong, nonatomic)  UIImageView *panBgImgV;    // 背景截图相框
@property (weak, nonatomic)  XMPhotoCollectionViewCell *currentCell;  // 当前拖拽的cell
@property (nonatomic, assign)  CGPoint starP;  // 拖拽图片开始的坐标点
@property (nonatomic, assign)  CGSize startSize;  // 拖拽开始图片的尺寸
@property (nonatomic, assign)  double starT;

/**拖拽图片退出浏览的相关变量**/

@property (weak, nonatomic)  UIView *topToolBar;
@property (weak, nonatomic)  UIView *bottomToolBar;


@end

@implementation XMPhotoCollectionViewController

static NSString * const reuseIdentifier = @"XMPhotoCell";
static double panToDismissDistance = 130.0f;  // 向下滑动退出图片预览的距离

- (UIImageView *)panBgImgV{
    if (!_panBgImgV){
        _panBgImgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, -XMStatusBarHeight, XMScreenW, XMScreenH)];
        _panBgImgV.hidden = YES;
    }
    return _panBgImgV;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerClass:[XMPhotoCollectionViewCell class]
            forCellWithReuseIdentifier:reuseIdentifier];
    //设置collectionview的初始化属性,惯性,偏移
    self.collectionView.delegate = self;
    self.collectionView.decelerationRate = 0.1;
    self.collectionView.contentOffset = CGPointMake(XMScreenW * self.selectImgIndex, self.collectionView.contentOffset.y);
    
    // 初始化参数
    self.timeInterval = 1.0f;
    self.gifTimeInterval = 1 / 12.5f;

    // 添加图片手势
    [self addImageGesture];
    
    // 设置工具按钮
    [self setToolKit];
}
    
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 禁用左侧返回手势,导航栏隐藏,采用白色主题的状态栏
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.navigationController.navigationBar.hidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // 截图
    [self.panBgImgV setImage:[XMImageUtil screenShot]];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    // 在这里插入背景图片
    [self.collectionView insertSubview:self.panBgImgV atIndex:0];

}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 导航栏显示,采用黑色主题的状态栏
    self.navigationController.navigationBar.hidden = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    // 移除定时器
    [self stopTimer];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    NSLog(@"XMPhotoCollectionViewController----%s",__func__);
}


/// 设置工具按钮
- (void)setToolKit{
    
    CGFloat toolBarH = 44;
    CGFloat btnWH = 44;
    
    // 底部工具条的容器
    UIView *topToolBar = [[UIView alloc] initWithFrame:CGRectMake(0, XMStatusBarHeight, XMScreenW, btnWH)];
    [self.view addSubview:topToolBar];
    self.topToolBar = topToolBar;
    topToolBar.backgroundColor = [UIColor clearColor];
    // 退出按钮(左上角)
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(3, 0, btnWH, btnWH)];
    [backBtn setImage:[UIImage imageNamed:@"navTool_close_white"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
    [topToolBar addSubview:backBtn];
    
    // 底部工具条的容器
    UIView *bottomToolV = [[UIView alloc] initWithFrame:CGRectMake(0, XMScreenH - toolBarH -  (isIphoneX ? 20 : 0), XMScreenW, toolBarH + (isIphoneX ? 20 : 0))];
    [self.view addSubview:bottomToolV];
    self.bottomToolBar = bottomToolV;
    
    // 页数标题(底部靠左)
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(10, -8, 100, 60)];
    [bottomToolV addSubview:lab];
    self.titLab = lab;
    lab.textAlignment = NSTextAlignmentLeft;
    lab.textColor = [UIColor whiteColor];
    
    // gif帧数按钮(底部靠右)
    UIButton *gifTimeBtn = [[UIButton alloc] initWithFrame:CGRectMake(XMScreenW - 60, 0, 60, btnWH)];
    [gifTimeBtn setTitle:@"12.5帧" forState:UIControlStateNormal];
    [gifTimeBtn addTarget:self action:@selector(changeGifTimeInterval:) forControlEvents:UIControlEventTouchUpInside];
    [bottomToolV addSubview:gifTimeBtn];
    
    // 幻灯片间隔按钮(底部靠右)
    UIButton *timeSettingBtn = [[UIButton alloc] initWithFrame:CGRectMake(XMScreenW - 120, 0, 60, btnWH)];
    [timeSettingBtn setTitle:@"1.0s" forState:UIControlStateNormal];
    [timeSettingBtn addTarget:self action:@selector(changeTimeInterval:) forControlEvents:UIControlEventTouchUpInside];
    [bottomToolV addSubview:timeSettingBtn];
    
    // 播放按钮(底部居中显示)
    UIButton *timerBtn = [[UIButton alloc] initWithFrame:CGRectMake((XMScreenW - btnWH) * 0.5 , 0, btnWH, btnWH)];
    self.timerBtn = timerBtn;
    [timerBtn addTarget:self action:@selector(toggleTimer:) forControlEvents:UIControlEventTouchUpInside];
    [timerBtn setImage:[UIImage imageNamed:@"btn_play"] forState:UIControlStateNormal];
    [timerBtn setImage:[UIImage imageNamed:@"btn_pause"] forState:UIControlStateSelected];
    [bottomToolV addSubview:timerBtn];
    
}
    
- (void)addImageGesture{

    // 添加点击手势(双击放大/复原)
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDoubleTapCollectionView:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.collectionView addGestureRecognizer:doubleTap];
    
    // 单点,退出图片
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureToDismiss:)];
    [self.collectionView addGestureRecognizer:tap];
    
    // 双击手势失效才允许单击手势执行
    [tap requireGestureRecognizerToFail:doubleTap];
    
    
    // 向下滑动,退出照片
    UIPanGestureRecognizer *cancelPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panToDismiss:)];
    [self.collectionView addGestureRecognizer:cancelPan];
    
    // 向下轻扫,退出
//    UISwipeGestureRecognizer *swipeD = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gestureToDismiss:)];
//    swipeD.delegate = self;
//    swipeD.direction = UISwipeGestureRecognizerDirectionDown;
//    [self.collectionView addGestureRecognizer:swipeD];
    
    // 向右轻扫,上一张图片
    UISwipeGestureRecognizer *swipeR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(preImage:)];
    swipeR.delegate = self;
    swipeR.direction = UISwipeGestureRecognizerDirectionRight;
    [self.collectionView addGestureRecognizer:swipeR];
    
    // 向左轻扫,下一张图片
    UISwipeGestureRecognizer *swipeL = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(nextImage:)];
    swipeL.delegate = self;
    swipeL.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.collectionView addGestureRecognizer:swipeL];
    
    // 上一张,下一张手势的优先级高
    [cancelPan requireGestureRecognizerToFail:swipeR];
    [cancelPan requireGestureRecognizerToFail:swipeL];
}

#pragma mark - 工具按钮点击事件
#pragma mark 定时器与幻灯片播放

/// 开启/关闭定时
- (void)toggleTimer:(UIButton *)btn{
    // 只有一张图片不用播放
    if(self.photoModelArr.count == 1){
        [MBProgressHUD showMessage:@"只有一张图片"];
        return;
    }
    if (self.timer){
        [self stopTimer];
    }else{
        [self beginTimer];
    }
}
/// 开启定时器
- (void)beginTimer{
    if (!self.timer){
        self.timerBtn.selected = YES;
        NSTimer *timer = [NSTimer timerWithTimeInterval:self.timeInterval target:self selector:@selector(displayImages) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        self.timer = timer;
    }
}

/// 关闭定时器
- (void)stopTimer{
    if(self.timer){
        self.timerBtn.selected = NO;
        [self.timer invalidate];
        self.timer = nil;
    }
}
    
/// 设置幻灯片播放时间间隔
- (void)changeTimeInterval:(UIButton *)btn{
    [self stopTimer];
    UIAlertController *tips = [UIAlertController alertControllerWithTitle:@"提示" message:@"输入幻灯片播放时间间隔(单位:秒)" preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    [tips addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [tips addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textF = tips.textFields[0];
        weakSelf.timeInterval = (textF.text.doubleValue && textF.text.doubleValue >= 0.5 ) ? textF.text.doubleValue : 2.0;
        [btn setTitle:[NSString stringWithFormat:@"%.1fs",weakSelf.timeInterval] forState:UIControlStateNormal];
    }]];
    [tips addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField){
        textField.clearButtonMode = UITextFieldViewModeAlways;
        textField.placeholder = @"最少0.5s,建议1s以上";
    }];
    
    [self presentViewController:tips animated:YES completion:nil];
}

/// 开始播放幻灯片
- (void)displayImages{
    NSUInteger index = self.collectionView.contentOffset.x / XMScreenW + 1;
    if (index < self.photoModelArr.count){
        
        [self.collectionView setContentOffset:CGPointMake(XMScreenW * index, self.collectionView.contentOffset.y) animated:YES];
    }else{
        [self.collectionView setContentOffset:CGPointMake(0, self.collectionView.contentOffset.y) animated:YES];
    }
    
}

#pragma mark 其他
/// 更新当前页面的索引标题
- (void)updatePageTitleWithIndex:(NSUInteger)index{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%zd/%zd",index,self.photoModelArr.count]];
    // 设置当前页样式
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[NSFontAttributeName] = [UIFont systemFontOfSize:30];
    [str setAttributes:dict range:NSMakeRange(0, [NSString stringWithFormat:@"%zd",index].length)];
    
    self.titLab.attributedText = str;
}

/// 设置gif每秒播放的帧数
- (void)changeGifTimeInterval:(UIButton *)btn{
    [self stopTimer];
    UIAlertController *tips = [UIAlertController alertControllerWithTitle:@"提示" message:@"每秒播放的帧数" preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    [tips addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [tips addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textF = tips.textFields[0];
        if(textF.text.integerValue > 0 ){

            weakSelf.gifTimeInterval = 1.0 / textF.text.integerValue;
            [btn setTitle:[NSString stringWithFormat:@"%ld帧",textF.text.integerValue] forState:UIControlStateNormal];
            [weakSelf.collectionView reloadData];
        }
    }]];
    [tips addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField){
        textField.clearButtonMode = UITextFieldViewModeAlways;
        textField.placeholder = @"默认每秒12.5帧";
    }];
    
    [self presentViewController:tips animated:YES completion:nil];
}

/// 退出
- (void)dismiss:(UIBarButtonItem *)btn{
    if(self.navigationController){
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - 手势
    
/// 上一张图片,右滑
- (void)preImage:(UISwipeGestureRecognizer *)gest{
    if (gest.state == UIGestureRecognizerStateEnded){
        if(self.imageIndex > 0){
            self.imageIndex--;
            [self.collectionView setContentOffset:CGPointMake(self.imageIndex * XMScreenW, self.collectionView.contentOffset.y) animated:YES];
        }
    }
}

/// 下一张图片,左划
- (void)nextImage:(UISwipeGestureRecognizer *)gest{
    if (gest.state == UIGestureRecognizerStateEnded){
        if(self.imageIndex < (self.photoModelArr.count - 1)){
            self.imageIndex++;
            [self.collectionView setContentOffset:CGPointMake(self.imageIndex * XMScreenW, self.collectionView.contentOffset.y) animated:YES];
        }
    }
}

/// 图片手势直接退出浏览
- (void)gestureToDismiss:(UIGestureRecognizer *)gest{
    
    CGFloat duration = 0.5f;
    // 当时swipe和tap手势触发的时候,需要设置背景相框位置/透明度/隐藏
    NSIndexPath *index = [self prepareToResponeGesture:gest];
    if(self.panBgImgV.hidden){
        self.panBgImgV.alpha = 0;
        self.panBgImgV.hidden = NO;
        duration = 0.8f;
    }
    
    // 缩放一半
    [UIView animateWithDuration:duration animations:^{
        // 如果指定了需要消失的终点,则移到终点,否则采取沿着y中心线向下边缩小边移动
        if(self.clickImageF.size.width > 0){
            // 缩放到原来的cell的图片位置,x坐标就是原来图片cell的x,y坐标是原来的坐标减去图片切换造成的位置差 * cell的高度再加上self.collectionView的y偏移高度32,最后缩放的宽固定是cell的相框的高度,最后缩放的高度根据比例缩放
            CGFloat finalX = self.clickImageF.origin.x;
//            CGFloat finalY = self.clickImageF.origin.y + self.currentCell.frame.origin.y  - (self.selectImgIndex - index.row) * self.clickCellH + ((self.navigationController.navigationBar.isHidden) ? 0 : (XMStatusBarHeight + 44));
            CGFloat finalY = self.clickImageF.origin.y + self.currentCell.frame.origin.y  - (self.selectImgIndex - index.row) * self.clickCellH;
            CGFloat finalW = self.clickImageF.size.width;
            CGFloat finalH = self.currentCell.imgV.frame.size.height * self.clickImageF.size.width / self.currentCell.imgV.frame.size.width;
            self.currentCell.imgV.frame = CGRectMake( finalX, finalY, finalW , finalH);
        }else{
            self.currentCell.imgV.frame = CGRectMake(CGRectGetMidX(self.currentCell.imgV.frame) - 50, XMScreenH, 100 , 100);
        }
        
        self.panBgImgV.alpha = 1;
    }completion:^(BOOL finished) {
        if(finished){
            // 由于popViewControllerAnimated为NO,需要手动移除最后一张截图
            XMNavigationController *nav = (XMNavigationController *)self.navigationController;
            [nav.pushScreenShotArr removeLastObject];
            [self.navigationController popViewControllerAnimated:NO];
        }
    }];
}

/// 拖拽图片退出浏览
-(void)panToDismiss:(UIPanGestureRecognizer *)pan{
    if(pan.state == UIGestureRecognizerStateChanged){
        
        CGPoint currentP = [pan locationInView:self.collectionView];
        // 一开始的触点的y值与底部的距离作为总距离,越接近底部,ratio越大
        CGFloat ratio = (currentP.y - self.starP.y) / (XMScreenH - self.starP.y);
        // 拖到一开始往上的位置时
        if(currentP.y > self.starP.y){
            // 越靠近底部,截图应该更加清晰,alpha也应该越大,即透明度是0->1
            self.panBgImgV.alpha = ratio;
            self.panBgImgV.hidden = NO;
        }else{
            self.panBgImgV.alpha = 1;
            self.panBgImgV.hidden = YES;
        }
        
        // 图片则和截图的alpha相反,越接近底部,图片应该越小,即是1->0,因此取反得到实际的缩放系数,另外限制缩放比例在0.4-1之间
        ratio = 1 - ratio;
        if (ratio < 0.4){
            ratio = 0.4;
        }else if (ratio > 1){
            ratio = 1;
        }
        /*
         X方向:
         图片需要边移动边缩小,因此,以屏幕左边沿为参考点,最终的结果应该是下面的公式:
         {当前触点与屏幕左边的距离(currentP.x - XMScreenW * self.imageIndex)} - {相片缩小造成的坐标调整(0.5 * self.startSize.width * ratio)} - {一开始的触点与图片中心的距离 * 缩放系数((self.starP.x - XMScreenW * 0.5) * ratio)}
         注意:由于触点相对于collectionView,必须减去XMScreenW * self.imageIndex才是相对于屏幕左边的距离,同理,self.starP也必须减去这个距离(这个在begin的方法里已经减去)
         Y方向:
         同x方向,不过y没有不需要减去cell序号造成的影响,除非改为垂直滚动
         */
        CGFloat moveX = (currentP.x - XMScreenW * self.imageIndex) - 0.5 * self.startSize.width * ratio - (self.starP.x - XMScreenW * 0.5) * ratio;
        CGFloat moveY = currentP.y - 0.5 * self.startSize.height * ratio - (self.starP.y - XMScreenH * 0.5) * ratio;
        
        // 边缩小边移动
        self.currentCell.imgV.frame = CGRectMake(moveX, moveY, self.startSize.width * ratio, self.startSize.height * ratio);
    }
    
    if(pan.state == UIGestureRecognizerStateBegan){
        // 记录手势开始时间
        self.starT = [[NSDate date] timeIntervalSince1970];
        // 手势开始前准备工作
        [self prepareToResponeGesture:pan];
    }
    
    if(pan.state == UIGestureRecognizerStateEnded){
        // 必须第一时间记录结束的时间来算时间间隔
        CGFloat gestTime = [[NSDate date] timeIntervalSince1970] - self.starT;
        // 手势动作过快(<0.05s),则直接退出,并且将工具条隐藏,工具条隐藏动画早晨的隐藏
        if(gestTime < 0.06){
            self.topToolBar.hidden = YES;
            self.bottomToolBar.hidden = YES;
            [self gestureToDismiss:pan];
            return;
        }
        CGFloat endY = [pan locationInView:self.collectionView].y;
        // 如果手势超过退出距离,则退出
        if(endY - self.starP.y > panToDismissDistance){
            [self gestureToDismiss:pan];
        }else{
            self.panBgImgV.hidden = YES;
            // 回弹添加动画,防止手势过快造成震动
            [UIView animateWithDuration:0.2f animations:^{
                self.currentCell.imgV.frame = CGRectMake(0, XMScreenH * 0.5 - self.startSize.height * 0.5, self.startSize.width, self.startSize.height);
            }completion:^(BOOL finished) {
                // 显示工具条
                [self showToolBar];
            }];
        }
    }
}


// 手势开始前的准备工作
- (NSIndexPath *)prepareToResponeGesture:(UIGestureRecognizer *)gest{
    // 停止幻灯片
    [self stopTimer];
    // 隐藏工具条
    [self hideToolBar];
    // 背景截图放在self.collectionView,需要随着图片滑动来调整x坐标,保持在当前图片的正下方
    CGRect tarF = self.panBgImgV.frame;
    tarF.origin.x = XMScreenW * self.imageIndex;
    self.panBgImgV.frame = tarF;
    
    // 因为参考点是collectionView,所以每一个cell的x都不一样,实际上需要参考的是与屏幕左边的距离,因此需要减去(XMScreenW * self.imageIndex),y则一样
    CGPoint absP = [gest locationInView:self.collectionView];
    self.starP = CGPointMake(absP.x - XMScreenW * self.imageIndex, absP.y);
    
    // 找出当前拖拽的cell
    NSIndexPath *index = [self.collectionView indexPathForItemAtPoint:[gest locationInView:self.collectionView]];
    XMPhotoCollectionViewCell *cell = (XMPhotoCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:index];
    self.currentCell = cell;
    self.startSize = cell.imgV.frame.size;

    return index;
}

/// 显示上下工具条
- (void)showToolBar{
    self.topToolBar.hidden = NO;
    self.bottomToolBar.hidden = NO;
    [UIView animateWithDuration:0.25f animations:^{
        self.topToolBar.transform = CGAffineTransformIdentity;
        self.bottomToolBar.transform = CGAffineTransformIdentity;
    }];
}

/// 隐藏上下工具条
- (void)hideToolBar{
    [UIView animateWithDuration:0.25f animations:^{
        self.topToolBar.transform = CGAffineTransformMakeTranslation(0, -CGRectGetMaxY(self.topToolBar.frame));
        self.bottomToolBar.transform = CGAffineTransformMakeTranslation(0, self.bottomToolBar.frame.size.height);
    }completion:^(BOOL finished) {
        if(finished){
            self.topToolBar.hidden = YES;
            self.bottomToolBar.hidden = YES;
        }
    }];
}
    
/// 双击事件
- (void)didDoubleTapCollectionView:(UITapGestureRecognizer *)tap{
    if (tap.state == UIGestureRecognizerStateEnded){
        // 隐藏导航栏
        self.navigationController.navigationBar.hidden = YES;
        // 先确定tap所在的cell
        CGPoint point = [tap locationInView:self.collectionView];
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
        XMPhotoCollectionViewCell *cell = (XMPhotoCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        
        // 1.先确定scrollerview的consize
        BOOL isExpand = cell.imgScroV.contentSize.width > XMScreenW;  // 目前是否是放大状态
        if (isExpand){
            cell.imgScroV.contentSize = [cell getImgOriginSize];
        }else{
            // 放大系数
            CGFloat scale = 3;
            cell.imgScroV.contentSize = CGSizeMake(cell.imgScroV.contentSize.width * scale, cell.imgScroV.contentSize.height * scale);
        }
        
        // 2.再根据scrollerview的consize去调整UIImageView的坐标
        CGFloat offsetX = (cell.imgScroV.bounds.size.width > cell.imgScroV.contentSize.width)? (cell.imgScroV.bounds.size.width - cell.imgScroV.contentSize.width) * 0.5 : 0.0;
        
        CGFloat offsetY = (cell.imgScroV.bounds.size.height > cell.imgScroV.contentSize.height)?(cell.imgScroV.bounds.size.height - cell.imgScroV.contentSize.height) * 0.5 : 0.0;
        
        cell.imgV.frame = CGRectMake(offsetX, offsetY, cell.imgScroV.contentSize.width, cell.imgScroV.contentSize.height);

        // 3.调整scrollerview的contenoffset
        if(!isExpand){
            cell.imgScroV.contentOffset = CGPointMake((cell.imgScroV.contentSize.width - XMScreenW) * 0.5, (cell.imgScroV.contentSize.height - XMScreenH) * 0.5);
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
//#warning Incomplete implementation, return the number of sections
//    return 0;
//}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photoModelArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    XMPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    if(!cell){
        cell = [[XMPhotoCollectionViewCell alloc] init];
    }
    cell.gifPerTime = self.gifTimeInterval;
    // 区分从本地加载图片还是从网路加载图片
    if(self.sourceType == XMPhotoDisplayImageSourceTypeWebURL){
        [cell setDisplayImage:self.photoModelArr[indexPath.row]];
    }else if (self.sourceType == XMPhotoDisplayImageSourceTypeLocalPath){
        cell.wifiModle = self.photoModelArr[indexPath.row];
    }
    return cell;
}
    



#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/
#pragma mark ---- UICollectionViewDelegateFlowLayout
//定义每个UICollectionViewCell 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(XMScreenW, XMScreenH);
}
//定义每个Section 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

//每个section中不同的行之间的行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    
    return 0;
}

#pragma mark - UIScrollerviewDelegate
// 正在滚动
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSUInteger currentP = scrollView.contentOffset.x / XMScreenW + 1.5;
    self.imageIndex = (int)currentP - 1;
    
    [self updatePageTitleWithIndex:currentP];
}

 //拖拽滚动结束
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    NSUInteger currentP = scrollView.contentOffset.x / XMScreenW + 0.5;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView setContentOffset:CGPointMake(currentP * XMScreenW, self.collectionView.contentOffset.y) animated:YES];
    });

}

/// 惯性滚动结束
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    
//    NSUInteger currentP = scrollView.contentOffset.x / XMScreenW + 0.5;
//    [self.collectionView setContentOffset:CGPointMake(currentP * XMScreenW, self.collectionView.contentOffset.y) animated:NO];
//}


@end
