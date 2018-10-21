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
#import "XMToolboxModel.h"

#import "XMTouchIDKeyboardViewController.h"
#import "MBProgressHUD+NK.h"
#import "XMDebugDefine.h"
#import "XMImageUtil.h"


#import "XMClipImageViewController.h"
#import "XMWifiTransFileViewController.h"

static NSString * const kAuthenCallBackNotificaiton = @"kAuthenCallBackNotificaiton";
double const XMToolBoxViewAnimationTime = 0.2;

typedef NS_ENUM(NSUInteger, AuthenResultType) {
    AuthenResultTypeSuccess,    //验证成功
    AuthenResultTypeFail,       //验证失败
    AuthenResultTypeUnsupport   //touchID不可用或者被锁或者未设置
};


@interface XMToolboxViewController ()<
XMTouchIDKeyboardViewControllerDelegate,
UIGestureRecognizerDelegate
>

// 记录当前点击的toolBox按钮
@property (assign, nonatomic)  NSInteger clickIndex;

@property (nonatomic, strong) NSArray *dataArr;

@end

@implementation XMToolboxViewController

- (NSArray *)dataArr{
    if (!_dataArr){
        _dataArr = [XMToolboxModel toolboxModels];
    }
    return _dataArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = 70;
    self.navigationItem.title = @"工具箱";
    
    // 观察指纹登录通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticationCallBack:) name:kAuthenCallBackNotificaiton object:self];
    
    // 3指上划快捷打开工具箱手势
    UISwipeGestureRecognizer *toolboxSwip = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(test)];
    toolboxSwip.numberOfTouchesRequired = 3;
    // 必须要实现一个代理方法支持多手势,这时候3指下滑同时也会触发单指滚动tableview
    toolboxSwip.delegate = self;
    toolboxSwip.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:toolboxSwip];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
    
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
}

- (void)test{
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"xmweb://"]]){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"xmweb://"]];
    }
}

- (void)dealloc{
    // 移除指纹登录通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAuthenCallBackNotificaiton object:self];
}

#pragma mark - 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"toolboxCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    XMToolboxModel *model = self.dataArr[indexPath.row];
    cell.textLabel.text = model.title;
    cell.imageView.image = [UIImage imageNamed:model.image];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    XMToolboxModel *model = self.dataArr[indexPath.row];
    self.clickIndex = indexPath.row;
    
    if (model.authenType == XMToolBoxAuthenTypeNeed){
        [self loadAuthentication];
    }else{
        [self cellDidClickWithIndex:model.tag];
    }
}

- (void)cellDidClickWithIndex:(NSInteger )index{
    XMToolboxModel *model = self.dataArr[index];
    switch (model.type) {
        case XMToolBoxTypeClipImg:{
            // 裁剪图片
            XMClipImageViewController *clipVC = [[XMClipImageViewController alloc] init];
            clipVC.view.backgroundColor = [UIColor whiteColor];
            [self.navigationController pushViewController:clipVC animated:YES];
            
            break;
        }
        case XMToolBoxTypeWifiTransFiles:{
            // wifi传输文件模块
            XMWifiTransFileViewController *wifiTransVC = [[XMWifiTransFileViewController alloc] init];
            [self.navigationController pushViewController:wifiTransVC animated:YES];
            
            break;
        }
        default:
            break;
    }
}

#pragma mark - 指纹验证

- (void)authenticationCallBack:(NSNotification *)noti{
    NSUInteger result = [noti.userInfo[@"result"] integerValue];
    NSString *msg = @"";
    BOOL touchIDKeyboardFlag = NO;
    //模拟器强制判断为成功验证
#ifdef XMToolboxWithoutAuthentication
    result = AuthenResultTypeSuccess;
#endif
    // 处理验证的结果
    switch (result) {
        case AuthenResultTypeSuccess:{ //验证成功
            dispatch_async(dispatch_get_main_queue(), ^{
                [self cellDidClickWithIndex:self.clickIndex];
            });
            break;
        }
        case AuthenResultTypeFail:{ // 验证失败,3次错误,按下home键,点击"取消",点击'键盘输入'
            NSError *error = noti.userInfo[@"error"];
            NSLog(@"~~~fail---code:%ld  text:%@",(long)error.code,error.localizedDescription);
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
            NSLog(@"~~~unsupp---code:%ld  text:%@",(long)error.code,error.localizedDescription);
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
    });

}


/// 指纹登录验证
- (void)loadAuthentication{
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

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
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
