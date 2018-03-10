//
//  XMTouchIDViewController.m
//  虾兽维度
//
//  Created by Niki on 18/3/10.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMToolboxViewController.h"

#import <LocalAuthentication/LocalAuthentication.h>
#import "XMMainViewController.h"
#import "MBProgressHUD+NK.h"
#import "XMButton.h"

@interface XMToolboxViewController ()

// 工具箱面板整体
@property (strong, nonatomic)  UIView *toolView;

// 标记工具箱面板是否弹出
@property (nonatomic, assign)  BOOL flat;

@end

@implementation XMToolboxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [self loadAuthentication];
    // 添加toolView,并且传递按钮的点击方法
    [self initToolView];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 显示工具箱菜单整体
    [self showToolView:YES caller:nil];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // 添加点击取消手势
    UITapGestureRecognizer *tapToCancel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelTool)];
    [self.view addGestureRecognizer:tapToCancel];
    
}

#pragma mark - 工具箱面板整体
#pragma mark 创建工具箱面板
/** 初始化工具箱面板 */
- (void)initToolView
{
    CGFloat btnWH = 58;         // 工具箱按钮宽高,根据bundle下toolBixIcons文件夹的图标确定
    CGFloat btnLabelH = 20;     // 工具箱按钮标签高度
    CGFloat padding = 10;       // 间隙
    NSUInteger colMaxNum = 4;      // 每行允许排列的图标个数
    
    // 工具箱菜单栏整体
    UIView *toolView = [[UIView alloc] init];
    [self.view addSubview:toolView];
    toolView.backgroundColor = [UIColor clearColor];
    self.toolView = toolView;
    
    // 工具箱按钮参数(根据需求只开放微信好友和朋友圈和facebook)
    NSArray *btnParams = [XMToolBoxConfig toolBoxs];
    NSUInteger btnNum = btnParams.count;
    
    // 工具箱按钮菜单栏,ipad限制为宽度为400
    CGFloat toolMenuVW = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? [UIScreen mainScreen].bounds.size.width : 400;
    CGFloat toolBtnMarginX;
    CGFloat toolBtnMarginY;
    if (btnNum < colMaxNum)  // 图标小于每行最大数时居中显示
    {
        toolBtnMarginX = (toolMenuVW - btnNum * btnWH) / (btnNum + 1);
        toolBtnMarginY = 2 * padding;
    }else
    {
        toolBtnMarginX = (toolMenuVW - colMaxNum * btnWH) / (colMaxNum + 1);
        toolBtnMarginY = toolBtnMarginX;
    }
    CGFloat toolMenuVH = (btnWH + btnLabelH + padding) * ((btnNum + colMaxNum - 1) / colMaxNum) + 2 * toolBtnMarginY - padding;
    CGFloat toolMenuX = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 0 : ([UIScreen mainScreen].bounds.size.width - toolMenuVW) * 0.5;
    
    UIView *toolMenuV = [[UIView alloc] initWithFrame:CGRectMake(toolMenuX, 0, toolMenuVW, toolMenuVH)];
    [toolView addSubview:toolMenuV];
    toolMenuV.backgroundColor = [UIColor whiteColor];
    
    // 添加按钮
    CGFloat btnX;
    CGFloat btnY;
    for (int i = 0; i < btnNum; i++)
    {
        NSDictionary *dict = btnParams[i];
        btnX = toolBtnMarginX + (btnWH + toolBtnMarginX) * (i % colMaxNum);
        btnY = toolBtnMarginY + (btnWH + btnLabelH + padding) * (i / colMaxNum);
        // 工具箱按钮
        XMButton *btn = [[XMButton alloc] initWithFrame:CGRectMake(btnX, btnY, btnWH, btnWH)];
        [toolMenuV addSubview:btn];
    
        btn.tag = [dict[ToolBox_kType] integerValue];
        btn.authentication = [dict[ToolBox_kAuth] integerValue];
        UIImage *iconImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"tool_icon_%zd.png",btn.tag] ofType:nil]];
        [btn setImage:iconImage forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(toolButtonDidClick:) forControlEvents:UIControlEventTouchDown];
        
        // 按钮下标签
        UILabel *btnL = [[UILabel alloc] initWithFrame:CGRectMake(btnX - 0.5 * toolBtnMarginX, CGRectGetMaxY(btn.frame), btnWH + toolBtnMarginX, btnLabelH)];
        btnL.numberOfLines = 0;
        btnL.lineBreakMode = NSLineBreakByWordWrapping;
        btnL.text = dict[ToolBox_kName];
        btnL.tintColor = [UIColor blackColor];
        btnL.textAlignment = NSTextAlignmentCenter;
        btnL.font = [UIFont systemFontOfSize:11];
        [toolMenuV addSubview:btnL];
    }
    
    CGFloat toolViewH = CGRectGetMaxY(toolMenuV.frame) - CGRectGetMinY(toolMenuV.frame);
    toolView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, toolViewH);
}

#pragma mark 弹出或隐藏
/** 隐藏或者隐藏工具箱面板整体 */
- (void)showToolView:(BOOL)result caller:(UIButton *)button
{
    if(result) // 显示工具箱菜单
    {
        // 菜单栏整体上升
        [UIView animateWithDuration:XMToolBoxViewAnimationTime animations:^{
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            {
                // iphone在最底下显示工具箱菜单
                self.toolView.transform = CGAffineTransformMakeTranslation(0, -self.toolView.frame.size.height);
            }else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                // ipad显示在屏幕中央
                self.toolView.transform = CGAffineTransformMakeTranslation(0, -( [UIScreen mainScreen].bounds.size.height + self.toolView.frame.size.height ) * 0.5);
            }
        }];
        
    }else{ // 隐藏工具箱菜单
        [UIView animateWithDuration:XMToolBoxViewAnimationTime animations:^{
            self.toolBoxViewCover.alpha = 0.0;
            self.toolView.transform = CGAffineTransformIdentity;
        }completion:^(BOOL finished) {
            // 移除蒙板
            [self.toolBoxViewCover removeFromSuperview];
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        
    }
}
#pragma mark 点击事件

/**  取消工具箱 */
- (void)cancelTool
{
    [self showToolView:NO caller:nil];
}

- (void)toolButtonDidClick:(XMButton *)btn{
    
    if (btn.authentication){
        __weak typeof(self) weakSelf = self;
        self.callbackBlock = ^(BOOL result){
            if(result && [weakSelf.delegate respondsToSelector:@selector(toolboxButtonDidClick:)]){
                [weakSelf.delegate toolboxButtonDidClick:btn];
            }
        };
        [self loadAuthentication];
    }else{
    
        if ([self.delegate respondsToSelector:@selector(toolboxButtonDidClick:)]){
            [self.delegate toolboxButtonDidClick:btn];
        }
    }

    [self showToolView:NO caller:btn];
}


#pragma mark - 指纹验证
/**
 * 指纹登录验证
 */
- (void)loadAuthentication
{
    LAContext *context = [[LAContext alloc] init]; //这个属性是设置指纹输入失败之后的弹出框的选项
    
    context.localizedFallbackTitle = @"再试";
    
    NSError *error = nil;
    NSString* result = @"需要验证您的touch ID";
    //首先使用canEvaluatePolicy 判断设备支持状态
    
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        
        //支持指纹验证
        __weak typeof(self) weakSelf = self;
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:result reply:^(BOOL success, NSError *error) {
            
            if (success) {
                //验证成功，主线程处理UI
                NSLog(@"验证成功");
                dispatch_async(dispatch_get_main_queue(), ^{
//                    [MBProgressHUD showMessage:@"验证成功" toView:weakSelf.view];
                    self.callbackBlock(YES);
                });
            }else{
                NSLog(@"%@",error.localizedDescription);
                switch (error.code) {
                        
                    case LAErrorSystemCancel:{
                        NSLog(@"Authentication was cancelled by the system");
                        //切换到其他APP，系统取消验证Touch ID
                        
                        break;
                    }
                    case LAErrorUserCancel:{
                        NSLog(@"Authentication was cancelled by the user");
                        //用户取消验证Touch ID
                        
                        break;
                    }
                    case LAErrorUserFallback:{
                        // 点击"再试"
                        NSLog(@"User selected to enter custom password");
                        
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            
                            //用户选择其他验证方式，切换主线程处理
                            
                        }];
                        
                        break;
                    }
                    default:{
                        // 指纹不对
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            
                            //其他情况，切换主线程处理
                            
                            
                        }];
                        
                        break;
                        
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD showMessage:@"验证出错34" toView:self.view];
                    weakSelf.callbackBlock(NO);
//                    [self.navigationController popViewControllerAnimated:YES];
                });
                
            }
            
        }];
        
    }else{
        
        //不支持指纹识别，LOG出错误详情
        switch (error.code) {
            case LAErrorTouchIDNotEnrolled: {
                
                NSLog(@"TouchID is not enrolled");
                
                break;
            }
            case LAErrorPasscodeNotSet:{
                
                NSLog(@"A passcode has not been set");
                
                break;
                
            }
            default:{
                // 超过六次将会被锁
                NSLog(@"TouchID not available");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD showMessage:@"错误超过六次" toView:self.view];
                });
                
                break;
            }
                
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            NSLog(@"%@",error.localizedDescription);
            [MBProgressHUD showMessage:@"验证出错12" toView:self.view];
            self.callbackBlock(NO);
        });
        
    }
    
}

@end
