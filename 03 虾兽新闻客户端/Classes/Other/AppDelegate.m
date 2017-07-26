//
//  AppDelegate.m
//  03 虾兽新闻客户端
//
//  Created by admin on 17/2/27.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "AppDelegate.h"
#import "XMMainViewController.h"
#import "XMNavWebViewController.h"

@interface AppDelegate ()

@property (nonatomic, strong) XMMainViewController *mainVC;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    self.mainVC = [[XMMainViewController alloc] init];
    
//    XMNavWebViewController *nav = [[XMNavWebViewController alloc] initWithRootViewController:_mainVC];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:_mainVC];
    
    self.window.rootViewController = nav;
    
    [self.window makeKeyAndVisible];
    
    //创建应用图标上的3D touch快捷选项
    [self creatShortcutItem];
    
    return YES;
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
    UIApplicationShortcutItem * itemSearch = [[UIApplicationShortcutItem alloc]initWithType:@"search" localizedTitle:@"搜索" localizedSubtitle:nil icon:iconSearch userInfo:nil];
    UIApplicationShortcutItem * itemScan = [[UIApplicationShortcutItem alloc]initWithType:@"scan" localizedTitle:@"扫描二维码" localizedSubtitle:nil icon:iconScan userInfo:nil];
    
    //添加到快捷选项数组
    [UIApplication sharedApplication].shortcutItems = @[itemSave,itemSearch,itemScan];
}

/** 3D touch快捷选项触发事件 */
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler
{
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
