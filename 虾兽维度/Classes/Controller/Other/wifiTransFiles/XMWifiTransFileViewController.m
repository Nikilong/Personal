//
//  XMWifiTransFileViewController.m
//  虾兽维度
//
//  Created by Niki on 18/5/6.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMWifiTransFileViewController.h"
#import "HTTPServer.h"
#import "DDLog.h"
#import "DDTTYLogger.h"


#import "MyHTTPConnection.h"
#import "ZBTool.h"


#import "XMWifiTransModel.h"
//#import <AVFoundation/AVFoundation.h>
#import "XMFileDisplayWebViewViewController.h"
#import "MBProgressHUD+NK.h"
#import "CommonHeader.h"

//typedef enum : NSUInteger {
//    XMAlertTypeMessage,
//    XMAlertTypeOpen,
//    XMAlertTypeClose,
//} XMAlertType;

@interface XMWifiTransFileViewController ()

@property (nonatomic, strong) HTTPServer *httpServer;
@property (nonatomic, assign)  BOOL connectFlag;

@property (nonatomic, strong) NSMutableArray *dataArr;

@end

@implementation XMWifiTransFileViewController

- (NSMutableArray *)dataArr
{
    if (!_dataArr)
    {
        _dataArr = [NSMutableArray array];
        NSArray *array = [[NSFileManager defaultManager] subpathsAtPath:XMWifiUploadDirPath];
        NSDictionary *dict = @{};
        for (NSString *ele in array){
            XMWifiTransModel *model = [[XMWifiTransModel alloc] init];
            dict = [[NSFileManager defaultManager] attributesOfItemAtPath:[XMWifiUploadDirPath stringByAppendingPathComponent:ele] error:nil];
            model.fileName = ele;
            model.fullPath = [XMWifiUploadDirPath stringByAppendingPathComponent:ele];
            model.size = dict.fileSize/1024.0/1024.0;
//            NSLog(@"%@---size:%.3fM",ele,dict.fileSize/1024.0/1024.0);
            [_dataArr addObject:model];
        }
    }
    return _dataArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.connectFlag = NO;
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    // 更新本地数据
    [self refreshDate];

    // 初始化导航栏
    [self createNav];
}



- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadFinish:) name:@"XMWifiTransfronFilesComplete" object:nil];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"XMWifiTransfronFilesComplete" object:nil];
}

 - (void)refreshDate{
     [_dataArr removeAllObjects];
     NSArray *array = [[NSFileManager defaultManager] subpathsAtPath:XMWifiUploadDirPath];
     NSDictionary *dict = @{};
     for (NSString *ele in array){
         XMWifiTransModel *model = [[XMWifiTransModel alloc] init];
         dict = [[NSFileManager defaultManager] attributesOfItemAtPath:[XMWifiUploadDirPath stringByAppendingPathComponent:ele] error:nil];
         model.fileName = ele;
         model.fullPath = [XMWifiUploadDirPath stringByAppendingPathComponent:ele];
         model.size = dict.fileSize/1024.0/1024.0;
    
         [_dataArr addObject:model];
     }
     
     
 }


/// 初始化导航栏
- (void)createNav{
    self.navigationItem.backBarButtonItem.title = @"返回";
    // 增加文件夹按钮
    UIBarButtonItem *createdBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(creatGroupDir)];
    // 编辑模式
    UIBarButtonItem *editBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(setEditMode)];
    self.navigationItem.leftBarButtonItems = @[createdBtn,editBtn];
    // 右边为打开wifi的按钮
    UIBarButtonItem *wifiBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(startHttpServer)];
    UIBarButtonItem *wifiCloseBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopHttpServer)];
    UIBarButtonItem *ipBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(showIP)];
    self.navigationItem.rightBarButtonItems = @[wifiCloseBtn,wifiBtn,ipBtn];
    
    // 设置标题
    self.navigationItem.title = @"Wifi传输未打开";
    
}
#pragma mark - 导航栏及点击事件
/// 打开一个http服务
- (void)startHttpServer{
    if (self.connectFlag){
        [MBProgressHUD showMessage:@"已经打开Wifi传输" toView:self.view];
        return;
    }
    // Configure our logging framework.
    // To keep things simple and fast, we're just going to log to the Xcode console.
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    // Initalize our http server
    self.httpServer = [[HTTPServer alloc] init];
    
    // Tell the server to broadcast its presence via Bonjour.
    // This allows browsers such as Safari to automatically discover our service.
    [self.httpServer setType:@"_http._tcp."];
    
    // 指定端口号(用于测试),实际由系统随机分配即可
//        [self.httpServer setPort:60431];
    
    // 设置index.html的路径
    NSString *webPath = [[NSBundle mainBundle] resourcePath];
    NSLog(@"设置根目录: %@", webPath);
    [self.httpServer setDocumentRoot:webPath];
    [self.httpServer setConnectionClass:[MyHTTPConnection class]];
    
    NSError *error = nil;
    if(![self.httpServer start:&error])
    {
        //        DDLogError(@"Error starting HTTP Server: %@", error);
        NSLog(@"打开HTTP服务失败: %@", error);
        [MBProgressHUD showMessage:@"打开HTTP服务失败" toView:self.view];
    }else{
        NSLog(@"打开HTTP服务成功");
        self.navigationItem.title = @"Wifi传输已打开";
        self.connectFlag = YES;
        // 获得本机IP和端口号
        [self showIP];
    }


}
/// 关闭wifi传输
- (void)stopHttpServer{
    if (self.connectFlag){
        [self.httpServer stop];
        self.navigationItem.title = @"Wifi传输未打开";
        self.connectFlag = NO;
    }
    [MBProgressHUD showMessage:@"Wifi传输已关闭" toView:self.view];
}

/// 弹出ip信息
- (void)showIP{
    if(self.connectFlag){
        // 获得本机IP和端口号
        unsigned short port = [self.httpServer listeningPort];
        NSString *ip = [NSString stringWithFormat:@"http://%@:%hu",[ZBTool getIPAddress:YES],port];
        [self showAlertWithTitle:@"浏览器传输网址" message:ip];
        
    }else{
        [MBProgressHUD showMessage:@"Wifi传输未打开" toView:self.view];
    }
    
}
/// 弹框
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *aleView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
        [aleView show];
    });
    
}

/// 创建分组文件夹
- (void)creatGroupDir{
#warning undo
    
}

/// 批量编辑模式
- (void)setEditMode{
    if ([self.tableView isEditing]){
        
        [self.tableView setEditing:YES animated:YES];
    }else{
        NSArray *arr = [self.tableView indexPathsForSelectedRows];
//        for
        #warning todo
        [self.tableView setEditing:NO animated:YES];
        
    }
}

#pragma mark - 监听上传的结果
- (void)uploadFinish:(NSNotification *)noti{
    NSLog(@"%@",noti.userInfo);
    [self refreshDate];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    XMWifiTransModel *model = self.dataArr[indexPath.row];
    cell.textLabel.text = model.fileName;
    if(model.size < 0.001){
        cell.detailTextLabel.text = [NSString stringWithFormat:@"文件大小:%.2f Byte",model.size * 1024.0 * 1024.0];
    }else if (model.size < 1){
        cell.detailTextLabel.text = [NSString stringWithFormat:@"文件大小:%.2fK",model.size  * 1024.0];
    }else{
        cell.detailTextLabel.text = [NSString stringWithFormat:@"文件大小:%.2fM",model.size];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.tableView.isEditing){
        return;
    }
    
    
    XMWifiTransModel *model = self.dataArr[indexPath.row];
    
    NSString *extesionStr = [[model.fileName lowercaseString] pathExtension];
    // 不支持的格式
    if ([@"zip|rar" containsString:extesionStr]){
        [MBProgressHUD showMessage:@"尚未支持该格式" toView:self.view];
        return;
    }
    
    // 用webview去预览
    XMFileDisplayWebViewViewController *displayVC = [[XMFileDisplayWebViewViewController alloc] init];
    displayVC.view.frame = self.view.bounds;
    [displayVC loadLocalFileWithPath:model.fullPath];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:displayVC animated:YES];
    });
    
    
//    NSString *extesionStr = [[model.fileName lowercaseString] pathExtension];
//    if ([@"jpg|png" containsString:extesionStr]){
//    
//    }else if ([@"mp4|avi" containsString:extesionStr]){
//        NSURL *sourceMovieURL = [NSURL fileURLWithPath:model.fullPath];
//        
//        AVAsset *movieAsset = [AVURLAsset URLAssetWithURL:sourceMovieURL options:nil];
//        
//        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
//        
//        AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
//        
//        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
//        
//        playerLayer.frame = self.view.layer.bounds;
//        
//        playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
//        
//        [self.view.layer addSublayer:playerLayer];
//        
//        [player play];
//    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete){
        XMWifiTransModel *model = self.dataArr[indexPath.row];
        
        if([[NSFileManager defaultManager] removeItemAtPath:model.fullPath error:nil]){
            [self.dataArr removeObjectAtIndex:indexPath.row];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }else{
            [MBProgressHUD showMessage:@"删除失败" toView:self.view];
        }
    }
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return UITableViewCellEditingStyleDelete;
}

@end
