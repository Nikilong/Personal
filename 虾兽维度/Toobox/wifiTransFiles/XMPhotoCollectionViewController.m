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

@interface XMPhotoCollectionViewController ()<UIScrollViewDelegate,UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic)  UILabel *titLab;
@property (weak, nonatomic)  NSTimer *timer;
@property (nonatomic, assign)  double timeInterval;


@end

@implementation XMPhotoCollectionViewController

static NSString * const reuseIdentifier = @"XMPhotoCell";

- (UILabel *)titLab
{
    if (!_titLab)
    {
        // 添加标题栏
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, XMScreenW, 30)];
        [self.view addSubview:lab];
        _titLab = lab;
        lab.textAlignment = NSTextAlignmentCenter;
        lab.backgroundColor = [UIColor clearColor];
        lab.textColor = [UIColor whiteColor];
    }
    return _titLab;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerClass:[XMPhotoCollectionViewCell class]
            forCellWithReuseIdentifier:reuseIdentifier];
    //设置collectionview的初始化属性,惯性,偏移
    self.collectionView.delegate = self;
    self.collectionView.decelerationRate = 0;
    self.collectionView.contentOffset = CGPointMake(XMScreenW * self.selectImgIndex, self.collectionView.contentOffset.y);
    
    // 初始化参数
    self.timeInterval = 2.0f;

    // 添加点击手势(单点隐藏/显示导航栏)
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapCollectionView:)];
    [self.collectionView addGestureRecognizer:tap];
    // 添加点击手势(双击放大/复原)
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDoubleTapCollectionView:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.collectionView addGestureRecognizer:doubleTap];
    
    [tap requireGestureRecognizerToFail:doubleTap];
    
    // 设置导航栏按钮
    UIBarButtonItem *beginBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(beginTimer)];
    UIBarButtonItem *stopBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(stopTimer)];
    UIBarButtonItem *timeSettingBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(setTimeInterval)];
    self.navigationItem.rightBarButtonItems = @[stopBtn,beginBtn,timeSettingBtn];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 禁用左侧返回手势
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 恢复左侧返回手势,显示导航栏
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 定时器与幻灯片播放
/// 开启定时器
- (void)beginTimer{
    NSTimer *timer = [NSTimer timerWithTimeInterval:(self.timeInterval)?self.timeInterval:2.0f target:self selector:@selector(displayImages) userInfo:nil repeats:YES];
    self.timer = timer;
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    
}

/// 关闭定时器
- (void)stopTimer{
    [self.timer invalidate];
}

/// 设置幻灯片播放时间间隔
- (void)setTimeInterval{
    UIAlertController *tips = [UIAlertController alertControllerWithTitle:@"提示" message:@"输入幻灯片播放时间间隔(单位:秒)" preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    [tips addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [tips addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textF = tips.textFields[0];
        weakSelf.timeInterval = textF.text.doubleValue;
    }]];
    [tips addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField){
        textField.placeholder = @"2";
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

#pragma mark - 手势
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

/// 单击事件
- (void)didTapCollectionView:(UITapGestureRecognizer *)tap{
    if (tap.state == UIGestureRecognizerStateEnded){
        self.navigationController.navigationBar.hidden = !self.navigationController.navigationBar.isHidden;
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
    cell.wifiModle = self.photoModelArr[indexPath.row];
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
    return 0;
}

#pragma mark - UIScrollerviewDelegate
// 正在滚动
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSUInteger currentP = scrollView.contentOffset.x / XMScreenW + 1.5;
    self.navigationItem.title = [NSString stringWithFormat:@"%zd/%zd",currentP,self.photoModelArr.count];
    self.titLab.text = [NSString stringWithFormat:@"%zd/%zd",currentP,self.photoModelArr.count];
//    NSLog(@"%@",NSStringFromCGPoint(scrollView.contentOffset));
}

/// 拖拽滚动结束
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    NSUInteger currentP = scrollView.contentOffset.x / XMScreenW + 0.5;
    [self.collectionView setContentOffset:CGPointMake(currentP * XMScreenW, self.collectionView.contentOffset.y) animated:YES];
}

/// 惯性滚动结束
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSUInteger currentP = scrollView.contentOffset.x / XMScreenW + 0.5;
    [self.collectionView setContentOffset:CGPointMake(currentP * XMScreenW, self.collectionView.contentOffset.y) animated:YES];
}

@end
