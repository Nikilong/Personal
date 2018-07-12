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
#import "XMButton.h"

#import "XMTouchIDKeyboardViewController.h"
#import "MBProgressHUD+NK.h"

static NSString * const kAuthenCallBackNotificaiton = @"kAuthenCallBackNotificaiton";
double const XMToolBoxViewAnimationTime = 0.2;

typedef enum : NSUInteger {
    AuthenResultTypeSuccess,    //验证成功
    AuthenResultTypeFail,       //验证失败
    AuthenResultTypeUnsupport   //touchID不可用或者被锁或者未设置
} AuthenResultType;


@interface XMToolboxViewController ()<XMTouchIDKeyboardViewControllerDelegate>

// 工具箱面板整体
@property (strong, nonatomic)  UIView *toolView;

// 标记工具箱面板是否弹出
@property (nonatomic, assign)  BOOL flat;

// 记录当前点击的toolBox按钮
@property (weak, nonatomic)  XMButton *clickBtn;

@end

@implementation XMToolboxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 添加toolView,并且传递按钮的点击方法
    [self initToolView];

    // 观察指纹登录通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticationCallBack:) name:kAuthenCallBackNotificaiton object:self];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
      
    // 显示工具箱菜单整体
    [self showToolView:YES caller:nil dismiss:NO];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    // 添加点击取消手势
    UITapGestureRecognizer *tapToCancel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelTool)];
    [self.view addGestureRecognizer:tapToCancel];
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(aaa)];
    swipe.direction = UISwipeGestureRecognizerDirectionUp;
    swipe.numberOfTouchesRequired = 3;
    [self.view addGestureRecognizer:swipe];
    [tapToCancel requireGestureRecognizerToFail:swipe];
}

- (void)dealloc{
    // 移除指纹登录通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAuthenCallBackNotificaiton object:self];
}

#pragma mark - 工具箱面板整体
#pragma mark 创建工具箱面板
/** 初始化工具箱面板 */
- (void)initToolView
{
    CGFloat btnWH = 58;         // 工具箱按钮宽高,根据bundle下toolBixIcons文件夹的图标确定
    CGFloat btnLabelH = 20;     // 工具箱按钮标签高度
    CGFloat padding = 10;       // 间隙
    NSUInteger colMaxNum = 4;   // 每行允许排列的图标个数
    
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
        btn.authentication = ([dict[ToolBox_kAuth] integerValue] == XMToolBoxAuthenTypeNeed) ? YES : NO;
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

- (void)aaa{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"test" object:nil];
    [self cancelTool];
}

#pragma mark 弹出或隐藏
/** 隐藏或者隐藏工具箱面板整体 */
- (void)showToolView:(BOOL)result caller:(UIButton *)button dismiss:(BOOL)flag
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
            if (flag){
            
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }];
        
    }
}
#pragma mark 点击事件

/**  取消工具箱 */
- (void)cancelTool
{
    [self showToolView:NO caller:nil dismiss:YES];
}

// toolbox上面的按钮的点击事件
- (void)toolButtonDidClick:(XMButton *)btn{
    // 标记当前被点击的按钮
    self.clickBtn = btn;
    // 该工具是否需要指纹验证
    if (btn.authentication){

        [self loadAuthentication];
        
    }else{
    
        if ([self.delegate respondsToSelector:@selector(toolboxButtonDidClick:)]){
            [self.delegate toolboxButtonDidClick:btn];
        }
        [self showToolView:NO caller:btn dismiss:YES];
    }

}


#pragma mark - 指纹验证

- (void)authenticationCallBack:(NSNotification *)noti{
    NSUInteger result = [noti.userInfo[@"result"] integerValue];
    NSString *msg = @"";
    BOOL touchIDKeyboardFlag = NO;
    //模拟器强制判断为成功验证
    if (TARGET_OS_SIMULATOR == 1 && TARGET_OS_IPHONE == 1) {
        result = AuthenResultTypeSuccess;
    }
    // 处理验证的结果
    switch (result) {
        case AuthenResultTypeSuccess:{ //验证成功
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self dismissViewControllerAnimated:YES completion:^{
                    
                    if([self.delegate respondsToSelector:@selector(toolboxButtonDidClick:)]){
                        [self.delegate toolboxButtonDidClick:self.clickBtn];
                    }
                }];
            });
            break;
        }
        case AuthenResultTypeFail:{ // 验证失败,3次错误,按下home键,点击"取消",点击'键盘输入'
            NSError *error = noti.userInfo[@"error"];
            NSLog(@"~~~fail---code:%zd  text:%@",error.code,error.localizedDescription);
            switch (error.code) {
                case LAErrorSystemCancel:{
                    NSLog(@"Authentication was cancelled by the system");
                    //切换到其他APP，系统取消验证Touch ID
                    break;
                }
                case LAErrorUserCancel:{
                    NSLog(@"Authentication was cancelled by the user");
                    //用户点击"取消"验证Touch ID
                    break;
                }
                case LAErrorUserFallback:{
                    // 点击"输入密码"
                    NSLog(@"User selected to enter custom password");
                    touchIDKeyboardFlag = YES;
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        //用户选择其他验证方式，切换主线程处理
                        XMTouchIDKeyboardViewController *keyVC = [[XMTouchIDKeyboardViewController alloc] init];
                        keyVC.delegate = self;
                        [self presentViewController:keyVC animated:YES completion:nil];

                    }];
                    break;
                }
                default:{
                    // 指纹不对,连续输错三次,应该转到
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        //其他情况，切换主线程处理
                    }];
                    
                    msg = @"错误次数已达3次,达到了5次将被系统锁定Touch ID,建议用键盘输入";
                    break;
                }
            }

            break;
        }
        case AuthenResultTypeUnsupport:{ // 不支持指纹验证或者未设置指纹或者5次错误touchID被锁
            NSError *error = noti.userInfo[@"error"];
            NSLog(@"~~~unsupp---code:%zd  text:%@",error.code,error.localizedDescription);
            // 是否应该显示指纹登录按钮
            BOOL showTouchIDBtn = NO;
            //不支持指纹识别，LOG出错误详情
            switch (error.code) {
                case LAErrorTouchIDNotEnrolled: {
                    // 没有指纹登录功能
                    NSLog(@"TouchID is not enrolled");
                    break;
                }
                case LAErrorPasscodeNotSet:{
                    // 有指纹登录,但是没有设置
                    NSLog(@"A passcode has not been set");
                    break;
                }
                default:{
                    // 达到5次将会被锁touch ID,需要锁屏输入开机密码才能解锁
                    NSLog(@"TouchID not available");
                    msg = @"达到了5次的错误限制,已经被系统锁定,请锁屏再输入密码激活Touch ID";
                    // 这种情况下应该显示指纹按钮
                    showTouchIDBtn = YES;
                    break;
                }
                    
            }
            // 打开键盘输入验证
            touchIDKeyboardFlag = YES;
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [MBProgressHUD showMessage:@"指纹验证不可用"];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    //用户选择其他验证方式，切换主线程处理
                    XMTouchIDKeyboardViewController *keyVC = [[XMTouchIDKeyboardViewController alloc] init];
                    keyVC.showTouchIdBtn = showTouchIDBtn;
                    keyVC.delegate = self;
                    [self presentViewController:keyVC animated:YES completion:nil];
                });
                
            }];
            
            
            break;
        }
        default:
            break;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![msg isEqualToString:@""]){
            UIAlertView *ale = [[UIAlertView alloc] initWithTitle:@"提醒" message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
            [ale show];
        }
        
        [self showToolView:NO caller:self.clickBtn dismiss:!touchIDKeyboardFlag];
    });

}


/**
 * 指纹登录验证
 */
- (void)loadAuthentication
{
    LAContext *context = [[LAContext alloc] init]; //这个属性是设置指纹输入失败之后的弹出框的选项
    context.localizedFallbackTitle = @"输入密码";
    NSError *error = nil;
    NSString* result = @"需要验证您的touch ID";
    //首先使用canEvaluatePolicy 判断设备支持状态

    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        
        //支持指纹验证
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:result reply:^(BOOL success, NSError *error) {
            
            if (success) {
                //验证成功，主线程处理UI
                NSLog(@"验证成功");
                [[NSNotificationCenter defaultCenter] postNotificationName:kAuthenCallBackNotificaiton object:self userInfo:@{@"result":[NSNumber numberWithInteger:AuthenResultTypeSuccess]}];
            }else{

                NSLog(@"%@",error.localizedDescription);
                [[NSNotificationCenter defaultCenter] postNotificationName:kAuthenCallBackNotificaiton object:self userInfo:@{@"result":[NSNumber numberWithInteger:AuthenResultTypeFail],@"error":error}];
                
            }
            
        }];
        
    }else{
        // 不支持指纹验证或者未设置指纹或者5次错误touchID被锁
        NSLog(@"post----failed---unsuport");
        [[NSNotificationCenter defaultCenter] postNotificationName:kAuthenCallBackNotificaiton object:self userInfo:@{@"result":[NSNumber numberWithInteger:AuthenResultTypeUnsupport],@"error":error                                                                                          }];
        
    }
    
}

#pragma mark - XMTouchIDKeyboardViewControllerDelegate
- (void)touchIDKeyboardViewControllerDidDismiss{

    [self dismissViewControllerAnimated:YES completion:nil];

}

// 验证成功
- (void)touchIDKeyboardViewAuthenSuccess{
    [[NSNotificationCenter defaultCenter] postNotificationName:kAuthenCallBackNotificaiton object:self userInfo:@{@"result":[NSNumber numberWithInteger:AuthenResultTypeSuccess]}];

}

// 密码验证切换回指纹验证
- (void)touchIDKeyboardViewControllerAskForTouchID{
    [self loadAuthentication];
}

@end
