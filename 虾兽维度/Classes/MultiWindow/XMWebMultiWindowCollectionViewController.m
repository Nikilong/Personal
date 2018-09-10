//
//  XMWebMultiWindowCollectionViewController.m
//  虾兽维度
//
//  Created by Niki on 2018/8/21.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMWebMultiWindowCollectionViewController.h"
#import "XMWebMultiWindowCollectionViewCell.h"
#import "XMMutiWindowFlowLayout.h"

#import "XMVisualView.h"

#import "AppDelegate.h"
#import "XMWKWebViewController.h"
#import "XMImageUtil.h"

@interface XMWebMultiWindowCollectionViewController ()<UIGestureRecognizerDelegate>


@end

@implementation XMWebMultiWindowCollectionViewController

static NSString * const reuseIdentifier = @"XMMultiWindowCellIdentify";

- (NSMutableArray *)shotImageArr{
    if (!_shotImageArr){
        _shotImageArr = [NSMutableArray array];
//        for (NSUInteger i = 0; i < 10; i++) {
//            [_shotImageArr addObject:[NSNumber numberWithUnsignedInteger:i % 4]];
//        }
    }
    return _shotImageArr;
}

+ (XMWebMultiWindowCollectionViewController *)shareWebMultiWindowCollectionViewController{
    static XMWebMultiWindowCollectionViewController *webMultiVC = nil;
    static dispatch_once_t webMultiVCToken;
    dispatch_once(&webMultiVCToken, ^{
        // 初始化
        XMMutiWindowFlowLayout *layout = [[XMMutiWindowFlowLayout alloc] init];
        webMultiVC = [[XMWebMultiWindowCollectionViewController alloc] initWithCollectionViewLayout:layout];
        
        // 初始化添加截图
        AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        for (NSUInteger i = 0; i < app.webModuleStack.count; i++) {
            XMWKWebViewController *webmodule = app.webModuleStack[i];
            [webMultiVC.shotImageArr addObject:[XMImageUtil screenShotWithView:webmodule.view]];
            NSLog(@"initlize--add-- image");
        }

    });
    return webMultiVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Register cell classes
    [self.collectionView registerClass:[XMWebMultiWindowCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    self.collectionView.backgroundColor = [UIColor lightGrayColor];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panCell:)];
    pan.delegate = self;
    [self.view addGestureRecognizer:pan];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // 设置底部工具条
    [self setBottomToolBar];
    
    self.navigationController.navigationBar.hidden = YES;
    
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if(app.webModuleStack.count > self.shotImageArr.count){
        for (NSUInteger i = self.shotImageArr.count; i < app.webModuleStack.count; i++) {
            XMWKWebViewController *webmodule = app.webModuleStack[i];
            [self.shotImageArr addObject:[XMImageUtil screenShotWithView:webmodule.view]];
        }
        // 必须刷新
        [self.collectionView reloadData];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    if(app.webModuleStack.count == self.shotImageArr.count){
//        [self.shotImageArr removeLastObject];
//        XMWKWebViewController *webmodule = [app.webModuleStack lastObject];
//        [self.shotImageArr addObject:[XMImageUtil screenShotWithView:webmodule.view]];
//        // 必须刷新
//        [self.collectionView reloadData];
//    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 底部工具条以及点击事件
- (void)setBottomToolBar{
    CGFloat btnWH = 44;
    
    // 毛玻璃
    UIBlurEffect *eff = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effV = [[UIVisualEffectView alloc] initWithEffect:eff];
    effV.frame = CGRectMake(0, XMScreenH - btnWH - (isIphoneX ? 20 : 0), XMScreenW, btnWH + (isIphoneX ? 20 : 0));
    
    
    UIButton * privateBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, btnWH)];
    [privateBtn setTitle:@"无痕浏览" forState:UIControlStateNormal];
    [privateBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [privateBtn addTarget:self action:@selector(privateBrowser) forControlEvents:UIControlEventTouchUpInside];
    [effV.contentView addSubview:privateBtn];
    
    UIButton *newWindowBtn = [[UIButton alloc] initWithFrame:CGRectMake((XMScreenW - btnWH) * 0.5, 0, btnWH, btnWH)];
    [newWindowBtn setImage:[UIImage imageNamed:@"webview_new_white"] forState:UIControlStateNormal];
    [newWindowBtn addTarget:self action:@selector(openNewWebmodule) forControlEvents:UIControlEventTouchUpInside];
    [effV.contentView addSubview:newWindowBtn];
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(XMScreenW - 60, 0, 60, btnWH)];
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(diss) forControlEvents:UIControlEventTouchUpInside];
    [effV.contentView addSubview:backBtn];

    [self.view addSubview:effV];
}

/// 无痕浏览
- (void)privateBrowser{
    NSLog(@"%s",__func__);
    self.shotImageArr = nil;
    [self.collectionView reloadData];
}

/// 打开新窗口
- (void)openNewWebmodule{
    if([self.delegate respondsToSelector:@selector(webMultiWindowCollectionViewControllerCallForNewSearchModule:)]){
        [self.delegate webMultiWindowCollectionViewControllerCallForNewSearchModule:self];
    }
}

/// 返回
- (void)diss{
    if(self.navigationController){
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
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

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.shotImageArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    XMWebMultiWindowCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
//    if(!cell){
//        cell = [[XMWebMultiWindowCollectionViewCell alloc] init];
//    }
//    NSLog(@"%lu--%lu",indexPath.row,indexPath.item);
//    [cell setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",self.shotImageArr[indexPath.item % 4]]]];
    [cell setBackgroundImage:self.shotImageArr[indexPath.item]];
//    [cell setIndex:indexPath.row];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%ld",(long)indexPath.item);
    
}


#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]){
        // 将pan手势变为侧滑的手势,当y方向移动大于x方向移动,则认为侧滑手势不应该响应,此外,velocity的政府还能用于判别方向
        CGPoint velocity = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:self.collectionView];
        if(fabs(velocity.x) > fabs(velocity.y)){
            return YES;
        }else{
            return NO;
        }
    }
    return YES;
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

#pragma mark - 手势方法
- (void)panCell:(UIPanGestureRecognizer *)pan{
    if(pan.state == UIGestureRecognizerStateChanged){
        CGPoint currentP = [pan locationInView:self.collectionView];
        XMMutiWindowFlowLayout *layout = (XMMutiWindowFlowLayout *)self.collectionViewLayout;
        layout.panCellCurrentP = currentP;
        
        [layout invalidateLayout];
        
    }else if(pan.state == UIGestureRecognizerStateBegan){
        // 禁止滚动
        self.collectionView.scrollEnabled = NO;
        CGPoint touchP = [pan locationInView:self.collectionView];
        NSIndexPath *indexP = [self.collectionView indexPathForItemAtPoint:touchP];
        NSLog(@"()())%ld",indexP.item);
        
        XMMutiWindowFlowLayout *layout = (XMMutiWindowFlowLayout *)self.collectionViewLayout;
        layout.panCellStarP = touchP;
        layout.panCellIndex = indexP.item;
    }else{
        XMMutiWindowFlowLayout *layout = (XMMutiWindowFlowLayout *)self.collectionViewLayout;
        if(layout.panCellStarP.x - layout.panCellCurrentP.x > self.collectionView.frame.size.width * 0.25 && layout.panCellIndex < self.shotImageArr.count){
            NSIndexPath *delIndexP = [NSIndexPath indexPathForItem:layout.panCellIndex inSection:0];
            layout.panCellIndex = MAXFLOAT;
            
            AppDelegate *app =(AppDelegate *) [UIApplication sharedApplication].delegate;
            XMWKWebViewController *delVC =app.webModuleStack[delIndexP.item];
            [delVC closeWebModule];
            [app.webModuleStack removeObjectAtIndex:delIndexP.item];
            delVC = nil;
            [self.shotImageArr removeObjectAtIndex:delIndexP.item];
            [self.collectionView deleteItemsAtIndexPaths:@[delIndexP]];
            
//            [self.collectionView reloadData];
        }else{
            
            
            layout.panCellIndex = MAXFLOAT;
            [self.collectionView performBatchUpdates:^{
            } completion:^(BOOL finished) {
                // 在这里回复允许滚动
//                self.collectionView.scrollEnabled = YES;
            }];
        }
        self.collectionView.scrollEnabled = YES;
    }
}

@end
