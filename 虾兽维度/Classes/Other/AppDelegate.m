//
//  AppDelegate.m
//  虾兽维度
//
//  Created by admin on 17/2/27.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "AppDelegate.h"
#import "XMMainViewController.h"
#import "XMNavigationController.h"

#import "XMWXFloatWindowIconConfig.h"
#import "XMSavePathUnit.h"
#import "XMWXVCFloatWindow.h"
//#import "XMWebViewController.h"
#import "XMWKWebViewController.h"
#import "XMWebURLProtocol.h"

/// 试验区头文件,可随时删除
#import "XMTouchIDKeyboardViewController.h"
#import "XMHiwebViewController.h"
#import "XMClipImageViewController.h"
#import "XMWifiTransFileViewController.h"

@interface AppDelegate ()<UITraitEnvironment>

@property (nonatomic, strong) XMMainViewController *mainVC;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 监听所有网络请求
//    [NSURLProtocol registerClass:[XMWebURLProtocol class]];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    if (TARGET_OS_SIMULATOR == 1 && TARGET_OS_IPHONE == 1) {
        //模拟器
        self.mainVC = [[XMMainViewController alloc] init];
    }else{
        //真机
        self.mainVC = [[XMMainViewController alloc] init];
    }

    
    XMNavigationController *nav = [[XMNavigationController alloc] initWithRootViewController:_mainVC];
    
    self.window.rootViewController = nav;
    
    [self.window makeKeyAndVisible];
    
    //创建应用图标上的3D touch快捷选项,需要遵守UITraitEnvironment协议,才能判断方法
    if([self respondsToSelector:@selector(traitCollection)]){
        if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)]){
            if(self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable){
                [self creatShortcutItem];
            }
        }
    }
    
    // 创建悬浮窗口
    [self recoverFloatVC];
    
    //注册本地通知
//    [self registerLocalNotification];
    
    return YES;
}

- (void)registerLocalNotification{
    /**
     *iOS 8之后需要向系统注册通知，让用户开放权限
     */
    if ([UIDevice currentDevice].systemVersion.integerValue > 8) {
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
            
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert categories:nil];
            
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        }
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    
    NSLog(@"localNotification---%s",__func__);
    UIApplicationState state = application.applicationState;
    if (state == UIApplicationStateActive) {
        if ([UIDevice currentDevice].systemVersion.integerValue > 9) {
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"警告" message:notification.alertBody preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:okAction];
            [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
            
        }else{
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"警告" message:notification.alertBody delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            
        }
        
        //        //清除已经推送的消息
        //        [LocalNotificationManager  compareFiretime:notification needRemove:^(UILocalNotification *item) {
        //            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        //        }];
    }
    
}



/// 根据缓存来恢复之前保存的浮窗
- (void)recoverFloatVC{
    NSString *saveVCName = [[NSUserDefaults standardUserDefaults] valueForKey:wxfloatVCKey];
    if (saveVCName.length == 0) return;
    
    // 根据类名创建控制器vc
    Class saveVCClass = NSClassFromString(saveVCName);
    UIViewController *saveVC = [[[saveVCClass class] alloc] init];
    self.floadVC = saveVC;
    
    // 如果是webview,需要特殊处理
    if([saveVC isKindOfClass:[XMWKWebViewController class]]){
        XMWebModel *model = nil;
        if ([[NSFileManager defaultManager] fileExistsAtPath:[XMSavePathUnit getFloatWindowWebmodelArchivePath]]) {
            model = [NSKeyedUnarchiver unarchiveObjectWithFile:[XMSavePathUnit getFloatWindowWebmodelArchivePath]];
        }
        // 标记为第一个webmodule,以便pan手势设置statusbar的颜色
        model.firstRequest = YES;
        XMWKWebViewController *webVC = (XMWKWebViewController *)saveVC;
        webVC.model = model;
    }
    
    // 显示浮窗
    [XMWXVCFloatWindow shareXMWXVCFloatWindow].hidden = NO;
}

/** 用代码创建应用图标上的3D touch快捷选项  */
- (void)creatShortcutItem {
    //创建系统风格的icon
//    UIApplicationShortcutIcon *iconShare = [UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeShare];
    UIApplicationShortcutIcon *iconSearch = [UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeSearch];
    UIApplicationShortcutIcon *iconSave = [UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeLove];
    UIApplicationShortcutIcon *iconScan = [UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeCapturePhoto];
    
    //    //创建自定义图标的icon
    //    UIApplicationShortcutIcon *icon2 = [UIApplicationShortcutIcon iconWithTemplateImageName:@"分享.png"];
    //创建快捷选项
    UIApplicationShortcutItem * itemSave = [[UIApplicationShortcutItem alloc]initWithType:@"save" localizedTitle:@"珍藏" localizedSubtitle:nil icon:iconSave userInfo:nil];
    UIApplicationShortcutItem * itemToolbox = [[UIApplicationShortcutItem alloc]initWithType:@"toolbox" localizedTitle:@"工具箱" localizedSubtitle:nil icon:iconSave userInfo:nil];
    UIApplicationShortcutItem * itemSearch = [[UIApplicationShortcutItem alloc]initWithType:@"search" localizedTitle:@"搜索" localizedSubtitle:nil icon:iconSearch userInfo:nil];
    UIApplicationShortcutItem * itemScan = [[UIApplicationShortcutItem alloc]initWithType:@"scan" localizedTitle:@"扫描二维码" localizedSubtitle:nil icon:iconScan userInfo:nil];
    
    //添加到快捷选项数组
    [UIApplication sharedApplication].shortcutItems = @[itemToolbox,itemSearch,itemSave,itemScan];
}

/** 3D touch快捷选项触发事件 */
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler{
    if([shortcutItem.type isEqualToString:@"one"]){
        // 这个分享的3D touch快捷选项是从plist里面创建的
        NSArray *arr = @[@"hello 3D Touch--分享"];
        UIActivityViewController *vc = [[UIActivityViewController alloc]initWithActivityItems:arr applicationActivities:nil];
        [self.window.rootViewController presentViewController:vc animated:YES completion:^{
        }];
    } else if ([shortcutItem.type isEqualToString:@"save"]) {//进入珍藏界面
        
        [_mainVC callSaveViewController];
    }else if ([shortcutItem.type isEqualToString:@"search"]) {//进入搜索界面
        
        [_mainVC search:nil];
    }
    else if ([shortcutItem.type isEqualToString:@"scan"]) {//进入扫描二维码界面
        
        [_mainVC scanQRCode];
    }
    else if ([shortcutItem.type isEqualToString:@"toolbox"]) {//进入工具箱
        
        [_mainVC callToolBox];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
