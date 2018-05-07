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

@property (weak, nonatomic)  UIView *toolBar;           // 批量编辑下的工具条
@property (weak, nonatomic)  UILabel *navTitleLab;      // 自定义导航栏标题

@end

@implementation XMWifiTransFileViewController

- (UIView *)toolBar
{
    if (!_toolBar)
    {
        CGFloat toolH = 44;
        UIView *toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, XMScreenH - toolH, XMScreenW, toolH)];
        toolBar.backgroundColor = [UIColor grayColor];
        _toolBar = toolBar;
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window addSubview:toolBar];
        UIButton *allSelectBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, toolH, toolH)];
        [toolBar addSubview:allSelectBtn];
        [allSelectBtn addTarget:self action:@selector(selectAllCell) forControlEvents:UIControlEventTouchUpInside];
        [allSelectBtn setTitle:@"全选" forState:UIControlStateNormal];
        [allSelectBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        
        UIButton *deleBtn = [[UIButton alloc] initWithFrame:CGRectMake(XMScreenW - toolH, 0, toolH, toolH)];
        [toolBar addSubview:deleBtn];
        [deleBtn addTarget:self action:@selector(deleteSelectCell) forControlEvents:UIControlEventTouchUpInside];
        [deleBtn setTitle:@"删除" forState:UIControlStateNormal];
        [deleBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    }
    return _toolBar;
}

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
    UIBarButtonItem *wifiBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(switchHttpServerConnect)];
    UIBarButtonItem *ipBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(showIP)];
    self.navigationItem.rightBarButtonItems = @[wifiBtn,ipBtn];
    
    // 设置标题
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    self.navTitleLab = titleLab;
    titleLab.font = [UIFont systemFontOfSize:17];
    titleLab.textColor = [UIColor blackColor];
    titleLab.text = @"Wifi传输未打开";
    // 添加刷新手势
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navTitleViewDidDoubleTap)];
    doubleTap.numberOfTapsRequired = 2;
    [titleLab addGestureRecognizer:doubleTap];
    self.navigationItem.titleView = titleLab;
    self.navigationItem.titleView.userInteractionEnabled = YES;
    
}
#pragma mark - 导航栏/toolbar及点击事件
/// 打开/关闭一个http服务
- (void)switchHttpServerConnect{
    if (self.connectFlag){
        // 关闭http服务
        [self.httpServer stop];
        self.navTitleLab.text = @"Wifi传输未打开";
        self.connectFlag = NO;
        [MBProgressHUD showMessage:@"Wifi传输已关闭" toView:self.view];
        return;
    }
    // Configure our logging framework.
    // To keep things simple and fast, we're just going to log to the Xcode console.
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    self.httpServer = [[HTTPServer alloc] init];
    
    // Tell the server to broadcast its presence via Bonjour.
    // This allows browsers such as Safari to automatically discover our service.
    [self.httpServer setType:@"_http._tcp."];
    
    // 指定端口号(用于测试),实际由系统随机分配即可
    [self.httpServer setPort:50914];
    
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
        self.navTitleLab.text = @"Wifi传输已打开";
        self.connectFlag = YES;
        // 获得本机IP和端口号
        [self showIP];
    }


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

/// 导航栏双击刷新
- (void)navTitleViewDidDoubleTap{
    [self refreshDate];
    [self.tableView reloadData];
}

/// 创建分组文件夹
- (void)creatGroupDir{
#warning undo
    
}

/// 批量编辑模式
- (void)setEditMode{
    if (![self.tableView isEditing]){
        self.toolBar.hidden = NO;
        
    }else{
        self.toolBar.hidden = YES;
        
    }
    [self.tableView setEditing:![self.tableView isEditing] animated:YES];
}

#pragma mark toolbart
/// 全选所有cell
- (void)selectAllCell{
    if (self.dataArr.count == 0) return;
    for (NSInteger i = 0; i < self.dataArr.count; i++) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
   
    
}

/// 数组降序,即arr[0]的数值最大
- (NSArray *)sortArray:(NSArray *)arr{
    NSComparator comp = ^(NSIndexPath *obj1,NSIndexPath *obj2){
        if (obj1.row > obj2.row){
            return (NSComparisonResult)NSOrderedAscending;
        }
        if (obj1.row < obj2.row){
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
    };
    return [arr sortedArrayUsingComparator:comp];
}

/// 删除所选的cell
- (void)deleteSelectCell{
    self.toolBar.userInteractionEnabled = NO;
    NSArray *seleArr = [self.tableView indexPathsForSelectedRows];
    // 先对数组进行降序处理,将indexPath.row最大(即最底下的数据先删除),防止序号紊乱
    NSArray *sortArr = [self sortArray:seleArr];
    if (seleArr.count > 0){
        for (NSIndexPath *indexPath in sortArr){
            [self deleteOneCellAtIndexPath:indexPath];
        }
    }
    [self.tableView setEditing:NO animated:YES];
    self.toolBar.userInteractionEnabled = YES;
    self.toolBar.hidden = YES;
}

/// 根据indexPath删除单个cell
- (void)deleteOneCellAtIndexPath:(NSIndexPath *)indexPath{
    if (self.dataArr.count - 1 < indexPath.row){
        return;
    }
    XMWifiTransModel *model = self.dataArr[indexPath.row];
    NSError *error;
    BOOL succesFlag = [[NSFileManager defaultManager] removeItemAtPath:model.fullPath error:&error];
    if(succesFlag){
        [self.dataArr removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }else{
        
        [MBProgressHUD showMessage:[NSString stringWithFormat:@"删除失败__>%@",error] toView:self.view];
        
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

- (void)longPressToEditCell:(UILongPressGestureRecognizer *)gest{
    if (gest.state == UIGestureRecognizerStateBegan){
        NSLog(@"%s",__func__);
        
        UIAlertController *tips = [UIAlertController alertControllerWithTitle:@"警告" message:@"确定要注销？？" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        __weak typeof(self) weakSelf = self;
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action){
            
            // 获得输入内容
            UITextField *textF = tips.textFields[0];
            
            // 根据触摸点推送indexPath
            CGPoint point = [gest locationInView:weakSelf.tableView];
            NSIndexPath *indexPath = [weakSelf.tableView indexPathForRowAtPoint:point];
            XMWifiTransModel *model = weakSelf.dataArr[indexPath.row];
            NSString *extesionStr = [[model.fileName lowercaseString] pathExtension];
            NSString *newName = [NSString stringWithFormat:@"%@.%@",textF.text,extesionStr];
            NSString *newFullPath = [XMWifiUploadDirPath stringByAppendingPathComponent:newName];
#warning todo 有缓存,效果不好
            // 重命名
            NSError *error;
            if ([[NSFileManager defaultManager] moveItemAtPath:model.fullPath toPath:newFullPath error:&error]){
                model.fileName = newName;
                model.fullPath = newFullPath;
//                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                [weakSelf.tableView reloadData];
//                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }else{
                [MBProgressHUD showMessage:@"名称已存在" toView:weakSelf.view];
            }

        }];
        
        [tips addAction:cancelAction];
        [tips addAction:okAction];
        [tips addTextFieldWithConfigurationHandler:nil];
        [self presentViewController:tips animated:YES completion:nil];
        
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    
    // 添加长按重命名收税
    UILongPressGestureRecognizer *longGest = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToEditCell:)];
    [cell.contentView addGestureRecognizer:longGest];
    
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
        [self deleteOneCellAtIndexPath:indexPath];
    }
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return UITableViewCellEditingStyleDelete;
}

@end
