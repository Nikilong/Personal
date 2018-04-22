//
//  XMNavWebViewController.m
//  虾兽新闻客户端
//
//  Created by Niki on 17/7/24.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "XMNavWebViewController.h"
#import "XMWebViewController.h"
#import "XMWebModel.h"

@interface XMNavWebViewController ()<UIGestureRecognizerDelegate>

@property (strong, nonatomic)UIPanGestureRecognizer *panGestureRecognizer;
@property (strong, nonatomic)UIImageView *backView;

@property (strong, nonatomic)NSMutableArray *backImgs;
@property (assign) CGPoint panBeginPoint;
@property (assign) CGPoint panEndPoint;

@end

@implementation XMNavWebViewController

//- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        //initlization
//    }
//    return self;
//}

- (void)loadView{
    [super loadView];
    
    [self initilization];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadBaseUI];
}

- (void)initilization{
    self.backImgs = [[NSMutableArray alloc] init];
}

- (void)loadBaseUI{
    //原生方法无效
    self.interactivePopGestureRecognizer.enabled = NO;
    
    //设置手势
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizerAction:)];
    self.panGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:self.panGestureRecognizer];
}

#pragma mark- public method
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    //截图
    UIGraphicsBeginImageContextWithOptions([UIScreen mainScreen].bounds.size, YES, 1.0);
    [[UIApplication sharedApplication].keyWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.backImgs addObject:img];
    
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated{
    [_backImgs removeLastObject];
    
    return [super popViewControllerAnimated:animated];
}

#pragma mark- private method
- (void)panGestureRecognizerAction:(UIPanGestureRecognizer*)panGestureRecognizer{
    if ([self.viewControllers count] == 1) {
        return ;
    }
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"滑动开始");
        //存放滑动开始的位置
        self.panBeginPoint = [panGestureRecognizer locationInView:[UIApplication sharedApplication].keyWindow];
        //插入图片
        [self insertLastViewFromSuperView:self.view.superview];
        
    }else if(panGestureRecognizer.state == UIGestureRecognizerStateEnded){
        NSLog(@"滑动结束");
        //存放数据
        self.panEndPoint = [panGestureRecognizer locationInView:[UIApplication sharedApplication].keyWindow];
        
        if ((_panEndPoint.x - _panBeginPoint.x) > 50) {
            [UIView animateWithDuration:0.3 animations:^{
                [self moveNavigationViewWithLenght:[UIScreen mainScreen].bounds.size.width];
            } completion:^(BOOL finished) {
                [self removeLastViewFromSuperView];
                [self moveNavigationViewWithLenght:0];
                [self popViewControllerAnimated:NO];
            }];
            
            
        }else{
            [UIView animateWithDuration:0.3 animations:^{
                [self moveNavigationViewWithLenght:0];
            }];
        }
    }else{
        //添加移动效果
        CGFloat panLength = ([panGestureRecognizer locationInView:[UIApplication sharedApplication].keyWindow].x - _panBeginPoint.x);
        if (panLength > 0) {
            [self moveNavigationViewWithLenght:panLength];
        }
    }
    
}

/**
 *  移动视图界面
 *
 *  @param lenght 移动的长度
 */
- (void)moveNavigationViewWithLenght:(CGFloat)lenght{
    
    //图片位置设置
    self.view.frame = CGRectMake(lenght, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    //图片动态阴影
    _backView.alpha = (lenght/[UIScreen mainScreen].bounds.size.width)*2/3 + 0.33;
}

/**
 *  插图上一级图片
 *
 *  @param superView 图片的superView
 */
- (void)insertLastViewFromSuperView:(UIView *)superView{
    //插入上一级视图背景
    if (_backView == nil) {
        _backView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _backView.image = [_backImgs lastObject];;
    }
    [self.view.superview insertSubview:_backView belowSubview:self.view];
}

/**
 *  移除上一级图片
 */
- (void)removeLastViewFromSuperView{
    [_backView removeFromSuperview];
    _backView = nil;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end
