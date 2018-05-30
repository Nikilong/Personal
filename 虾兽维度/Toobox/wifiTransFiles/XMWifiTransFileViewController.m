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
#import "XMWifiLeftTableViewController.h"
#import "XMWifiGroupTool.h"

#import "XMWebTableViewCell.h"
#import "MBProgressHUD+NK.h"

#import "SSZipArchive.h"
#import "XMPhotoCollectionViewController.h"


@interface XMWifiTransFileViewController ()
<XMWifiLeftTableViewControllerDelegate,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate>


@property (nonatomic, strong) HTTPServer *httpServer;
@property (nonatomic, assign)  BOOL connectFlag;

@property (nonatomic, strong) NSMutableArray *dataArr;

@property (weak, nonatomic)  UIView *toolBar;                // 批量编辑下的工具条
@property (weak, nonatomic)  UIButton *toolBarDeleBtn;       // 工具条删除按钮
@property (weak, nonatomic)  UIButton *toolBarMoveBtn;       // 工具条移动按钮
@property (weak, nonatomic)  UIButton *toolBarSeleAllBtn;    // 工具条全选按钮
@property (weak, nonatomic)  UILabel *navTitleLab;           // 自定义导航栏标题

/** 强引用左侧边栏窗口 */
@property (nonatomic, strong) XMWifiLeftTableViewController *leftVC;
@property (weak, nonatomic)  UIView *leftContentView;
@property (weak, nonatomic)  UIView *cover;

/// 添加的图片的展示框
@property (weak, nonatomic)  UIView *showSeleImageView;

/// 是否是移动文件模式,yes下点击cell不会展示文件夹内容
@property (nonatomic, assign)  BOOL isMoveFilesMode;


@end

@implementation XMWifiTransFileViewController

- (UIView *)toolBar
{
    if (!_toolBar)
    {
        CGFloat toolH = 44;
        CGFloat margin = 10;
        CGFloat btnWH = 30;
        CGFloat btnY = (toolH - btnWH) * 0.5;
        UIView *toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, XMScreenH - toolH, XMScreenW, toolH)];
        toolBar.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0f];
        _toolBar = toolBar;
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window addSubview:toolBar];
        // 全选/反选
        UIButton *allSelectBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        allSelectBtn.frame = CGRectMake(XMScreenW - toolH * 2 - margin, 0, toolH * 2, toolH);
        self.toolBarSeleAllBtn = allSelectBtn;
        [toolBar addSubview:allSelectBtn];
        [allSelectBtn addTarget:self action:@selector(selectAllCell:) forControlEvents:UIControlEventTouchUpInside];
        [allSelectBtn setTitle:@"全选所有" forState:UIControlStateNormal];
        [allSelectBtn setTitle:@"取消全选" forState:UIControlStateSelected];
        
        // 退出编辑
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        cancelBtn.frame = CGRectMake(CGRectGetMinX(allSelectBtn.frame) - margin - toolH, 0, toolH, toolH);
        [toolBar addSubview:cancelBtn];
        [cancelBtn addTarget:self action:@selector(cancelEdit:) forControlEvents:UIControlEventTouchUpInside];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        
        // 删除按钮
        UIButton *deleBtn = [[UIButton alloc] initWithFrame:CGRectMake(margin, btnY, btnWH, btnWH)];
        self.toolBarDeleBtn = deleBtn;
        [toolBar addSubview:deleBtn];
        [deleBtn addTarget:self action:@selector(deleteSelectCell:) forControlEvents:UIControlEventTouchUpInside];
        [deleBtn setImage:[UIImage imageNamed:@"file_delete_disable"] forState:UIControlStateDisabled];
        [deleBtn setImage:[UIImage imageNamed:@"file_delete_able"] forState:UIControlStateNormal];
        deleBtn.enabled = NO;
        
        // 移动按钮
        UIButton *moveBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(deleBtn.frame) + 40, btnY, btnWH, btnWH)];
        self.toolBarMoveBtn = moveBtn;
        [toolBar addSubview:moveBtn];
        [moveBtn addTarget:self action:@selector(moveSelectCell:) forControlEvents:UIControlEventTouchUpInside];
        [moveBtn setImage:[UIImage imageNamed:@"file_move_disable"] forState:UIControlStateDisabled];
        [moveBtn setImage:[UIImage imageNamed:@"file_move_able"] forState:UIControlStateNormal];
        moveBtn.enabled = NO;
    }
    return _toolBar;
}

- (NSMutableArray *)dataArr
{
    if (!_dataArr)
    {
        _dataArr = [XMWifiGroupTool getCurrentGroupFiles];
    }
    return _dataArr;
}

- (UIView *)cover
{
    if (!_cover)
    {
        UIView *cover = [[UIView alloc] initWithFrame:CGRectMake(XMWifiLeftViewTotalW, 0, XMScreenW - XMWifiLeftViewTotalW, XMScreenH)];
        cover.backgroundColor = [UIColor clearColor];
        [self.view addSubview:cover];
        _cover = cover;
        
        // 添加手势点击和拖，触发蒙板隐藏左侧边栏
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideLeftView)];
        [cover addGestureRecognizer:tap];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self  action:@selector(hideLeftView)];
        [cover addGestureRecognizer:pan];
        
    }
    return _cover;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化参数
    self.view.backgroundColor = [UIColor whiteColor];
    self.connectFlag = NO;
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.isMoveFilesMode = NO;
    // 更新本地数据
//    [self refreshDate:nil];

    // 初始化导航栏
    [self createNav];
    
    // 添加系统原生下拉刷新
    [self creatRefreshKit];
    
    // 添加左侧边栏
    [self addLeftVC];
    // 左侧抽屉手势
    UISwipeGestureRecognizer *swip = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showLeftView)];
    [self.view addGestureRecognizer:swip];
}



- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadFinish:) name:@"XMWifiTransfronFilesComplete" object:nil];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"XMWifiTransfronFilesComplete" object:nil];
}

- (void)refreshDate:(UIRefreshControl *)con{
    // 如果是由下拉刷新触发的刷新则需要结束刷新动画
    if (con){
        [con endRefreshing];
    }
     [self.dataArr removeAllObjects];
     self.dataArr = [XMWifiGroupTool getCurrentGroupFiles];
     dispatch_async(dispatch_get_main_queue(), ^{
         [self.tableView reloadData];
     });
}

/// 添加系统原生下拉刷新
- (void)creatRefreshKit{
    UIRefreshControl *con = [[UIRefreshControl alloc] init];
    [self.tableView addSubview:con];
    [con addTarget:self action:@selector(refreshDate:) forControlEvents:UIControlEventValueChanged];
    [con beginRefreshing];
    [self refreshDate:con];
}

/// 初始化导航栏
- (void)createNav{
    CGFloat btnWH = 44;
    // 返回按钮
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(dismissCurrentViewController)];
    // 编辑模式
    UIBarButtonItem *editBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(setEditMode)];
    self.navigationItem.leftBarButtonItems = @[backBtn,editBtn];
    
    // 右边为打开wifi的按钮 wifiopen
    UIButton *wifiBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnWH, btnWH)];
    [wifiBtn setImage:[UIImage imageNamed:@"wifiopen"] forState:UIControlStateSelected];
    [wifiBtn setImage:[UIImage imageNamed:@"wificlose"] forState:UIControlStateNormal];
    [wifiBtn addTarget:self action:@selector(switchHttpServerConnect:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *wifiBarBtn = [[UIBarButtonItem alloc] initWithCustomView:wifiBtn];
    // 从相册添加图片
    UIBarButtonItem *addBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addImageFromAlbum)];
    self.navigationItem.rightBarButtonItems = @[wifiBarBtn,addBtn];
    
    // 设置标题
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    self.navTitleLab = titleLab;
    titleLab.font = [UIFont systemFontOfSize:17];
    titleLab.textColor = [UIColor blackColor];
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.text = defaultGroupName;
    // 添加双击刷新手势
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navTitleViewDidDoubleTap)];
    doubleTap.numberOfTapsRequired = 2;
    [titleLab addGestureRecognizer:doubleTap];
    
    // 添加单击显示IP信息
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showIP)];
    [titleLab addGestureRecognizer:singleTap];
    
    // 解决单击和双击同时触发问题,只有双击失败时才允许单击
    [singleTap requireGestureRecognizerToFail:doubleTap];
    self.navigationItem.titleView = titleLab;
    self.navigationItem.titleView.userInteractionEnabled = YES;
    
}
#pragma mark - 导航栏/toolbar及点击事件
#pragma mark 导航栏
/// 打开/关闭一个http服务
- (void)switchHttpServerConnect:(UIButton *)wifiBtn{
    wifiBtn.selected = !wifiBtn.selected;
    if (self.connectFlag){
        // 关闭http服务
        [self.httpServer stop];
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
//    [self.httpServer setPort:50914];
    
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
    [self refreshDate:nil];
}


/// 批量编辑模式
- (void)setEditMode{
    if (![self.tableView isEditing]){
        self.toolBar.hidden = NO;
        self.toolBarSeleAllBtn.selected = NO;
        self.toolBarDeleBtn.enabled = NO;
        self.toolBarMoveBtn.enabled = NO;
        self.toolBar.userInteractionEnabled = YES;
    }else{
        self.toolBar.hidden = YES;
    }
    [self.tableView setEditing:![self.tableView isEditing] animated:YES];
}

/// 退出模块
- (void)dismissCurrentViewController{
    dispatch_async(dispatch_get_main_queue(),^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

/// 从相册添加照片
- (void)addImageFromAlbum{
    UIImagePickerController *pickVC  = [[UIImagePickerController alloc] init];
    pickVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickVC.delegate = self;
    [self presentViewController:pickVC animated:YES completion:nil];
    
}

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    // 获得原始的照片,转为NSData格式保存为jpg格式,如果是PNG格式尺寸太大
    UIImage *seleImg =info[UIImagePickerControllerOriginalImage];
    // 拼接文件全路径,文件名是日期(排除空格和后面的时区)
    NSString *fileName = [NSDate date].description;
    fileName = [[fileName substringToIndex:(fileName.length - 5)] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *savePath = [NSString stringWithFormat:@"%@/%@.jpg",[XMWifiGroupTool getCurrentGroupPath],fileName];

    BOOL isSave = [UIImageJPEGRepresentation(seleImg,0.5) writeToFile:savePath atomically:YES];
    if (isSave){
        [MBProgressHUD show:[NSString stringWithFormat:@"成功添加:/n%@.jpg",fileName] image:seleImg view:picker.view];
        [self refreshDate:nil];
    }
}

#pragma mark toolbar
/// 全选/取消全选所有cell
- (void)selectAllCell:(UIButton *)btn{
    btn.selected = !btn.selected;
    if (btn.selected){
        // 全选状态
        if (self.dataArr.count == 0) return;
        for (NSInteger i = 0; i < self.dataArr.count; i++) {
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
        }
        self.toolBarDeleBtn.enabled = YES;
        self.toolBarMoveBtn.enabled = YES;
    }else{
        // 取消全选状态
        NSArray *seleArr = [self.tableView indexPathsForSelectedRows];
        for (NSIndexPath *indexPath in seleArr){
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        self.toolBarDeleBtn.enabled = NO;
        self.toolBarMoveBtn.enabled = NO;
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

/// 移动所选的cell
- (void)moveSelectCell:(UIButton *)btn{
//    btn.enabled = NO;
    self.toolBar.userInteractionEnabled = NO;
    self.isMoveFilesMode = YES;
    [self showLeftView];
}

/// 删除所选的cell
- (void)deleteSelectCell:(UIButton *)btn{
    btn.enabled = NO;
    self.toolBar.userInteractionEnabled = NO;
    NSArray *seleArr = [self.tableView indexPathsForSelectedRows];
    // 先对数组进行降序处理,将indexPath.row最大(即最底下的数据先删除),防止序号紊乱
    NSArray *sortArr = [self sortArray:seleArr];
    if (seleArr.count > 0){
        for (NSIndexPath *indexPath in sortArr){
            [self deleteOneCellAtIndexPath:indexPath];
        }
    }
    [self cancelEdit:nil];
}

/// 根据indexPath删除单个cell
- (void)deleteOneCellAtIndexPath:(NSIndexPath *)indexPath{
    if (self.dataArr.count - 1 < indexPath.row){
        return;
    }
    XMWifiTransModel *model = self.dataArr[indexPath.row];
    // 先判断文件能够进行操作
    if (![XMWifiGroupTool canDeleteFileAtPath:model.fullPath]){
        [MBProgressHUD showMessage:@"系统文件,不可操作!" toView:self.view];
        return;
    }
    NSError *error;
    BOOL succesFlag = [[NSFileManager defaultManager] removeItemAtPath:model.fullPath error:&error];
    if(succesFlag){
        [self.dataArr removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        // 当删除了一个文件夹,还会把里面的文件也删除,需要刷新数据
        if (model.isDir){
            [self refreshDate:nil];
        }
        
    }else{
        [MBProgressHUD showMessage:[NSString stringWithFormat:@"删除失败>%@",error] toView:self.view];
    }
}

/// 退出编辑模式
- (void)cancelEdit:(UIButton *)btn{
    [self.tableView setEditing:NO animated:YES];
    self.toolBar.hidden = YES;
}

#pragma mark 左侧栏
/**  添加左侧边栏*/
-(void)addLeftVC
{
    // 创建左侧边栏容器
    UIView *leftContentView = [[UIView alloc] initWithFrame:CGRectMake(-XMWifiLeftViewTotalW, 0, XMWifiLeftViewTotalW, XMScreenH)];
    leftContentView.backgroundColor = [UIColor grayColor];
    self.leftContentView = leftContentView;
    self.leftContentView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    // 创建左侧边栏
    self.leftVC = [[XMWifiLeftTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    self.leftVC.delegate = self;
    self.leftVC.view.frame = CGRectMake(XMLeftViewPadding, 40, XMWifiLeftViewTotalW - 2 *XMLeftViewPadding, XMScreenH - XMLeftViewPadding - 20);
    [self.leftContentView addSubview:self.leftVC.view];
    
    // 添加到导航条之上
    [self.navigationController.view insertSubview:self.leftContentView aboveSubview:self.navigationController.navigationBar];
    
    // 左侧边栏添加左划取消手势
    UISwipeGestureRecognizer *swip = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideLeftView)];
    swip.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.leftVC.tableView addGestureRecognizer:swip];
}

/** 显示左侧边栏 */
- (void)showLeftView
{
    // 显示蒙板
    self.cover.hidden = NO;
    
    // 添加到导航栏的上面
    [self.navigationController.view insertSubview:self.cover aboveSubview:self.navigationController.navigationBar];
    // 添加到导航条之上
    [self.navigationController.view insertSubview:self.leftContentView aboveSubview:self.navigationController.navigationBar];
    
    // 设置动画弹出左侧边栏
    [UIView animateWithDuration:0.5 animations:^{
        self.leftContentView.transform = CGAffineTransformMakeTranslation(XMWifiLeftViewTotalW, 0);
    }];
    
}

/** 隐藏左侧边栏 */
- (void)hideLeftView
{
    // 隐藏蒙板
    self.cover.hidden = YES;
    [UIView animateWithDuration:0.5 animations:^{
        // 恢复到最左边的位置
        self.leftContentView.transform = CGAffineTransformIdentity;
        // 当isMoveFilesMode隐藏左边栏,需要回复toolbar的可用
        if(self.isMoveFilesMode){
            self.toolBar.userInteractionEnabled = YES;
        }
        self.isMoveFilesMode = NO;
    }];
}

#pragma mark XMWifiLeftTableViewControllerDelegate
- (void)leftWifiTableViewControllerDidSelectGroupName:(NSString *)groupName{
    if (self.isMoveFilesMode){
        if([groupName isEqualToString:allFilesGroupName]){
            [MBProgressHUD showMessage:@"不可移动到该文件夹" toView:self.view];
            return;
        }
        NSArray *seleArr = [self.tableView indexPathsForSelectedRows];
        // 先对数组进行降序处理,将indexPath.row最大(即最底下的数据先删除),防止序号紊乱
        NSArray *sortArr = [self sortArray:seleArr];
        for (NSIndexPath *indexPath in sortArr){
            XMWifiTransModel *model = self.dataArr[indexPath.row];
            NSString *newFullPath = [NSString stringWithFormat:@"%@/%@/%@",[XMSavePathUnit getWifiUploadDirPath],groupName,model.pureFileName];
            NSLog(@"%@",newFullPath);
            // 重命名,自己覆盖自己
            NSError *error;
            if ([[NSFileManager defaultManager] moveItemAtPath:model.fullPath toPath:newFullPath error:&error]){
                [self refreshDate:nil];
            }else{
                [MBProgressHUD showMessage:@"名称已存在" toView:self.view];
            }
        }
    }else{
        // 一系列设置标题
        self.navTitleLab.text = groupName;
        [XMWifiGroupTool upgradeCurrentGroupName:groupName];
        [self refreshDate:nil];
        
    }
    
    [self hideLeftView];
    // 不论何种模式,点击了选择组别,取消全选状态和设置删除和移动按钮不可用
    self.toolBarSeleAllBtn.selected = NO;
    self.toolBarDeleBtn.enabled = NO;
    self.toolBarMoveBtn.enabled = NO;
}

- (void)leftWifiTableViewControllerDidDeleteGroupName:(NSString *)groupName{
    // 如果删除的文件夹刚好是当前展示的数组,那么需要切换到"默认"的文件夹
    if ([groupName isEqualToString:self.navTitleLab.text]){
        self.navTitleLab.text = defaultGroupName;
        [self refreshDate:nil];
    }
}

#pragma mark - 监听上传的结果
- (void)uploadFinish:(NSNotification *)noti{
    NSLog(@"%@",noti.userInfo);
    [self refreshDate:nil];
}

#pragma mark - UITableViewDataSource
#pragma mark cell的初始化方法
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    XMWebTableViewCell *cell = [XMWebTableViewCell cellWithTableView:tableView];
    
    // 添加重命名手势
    UILongPressGestureRecognizer *longGest = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToEditCell:)];
    [cell.contentView addGestureRecognizer:longGest];
    
    XMWifiTransModel *model = self.dataArr[indexPath.row];
    cell.wifiModel = model;
    return cell;
}

#pragma mark 选中与反选
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.isEditing){
        // 编辑模式下如果没有选中按钮则删除和移动按钮不可用
        if([tableView indexPathsForSelectedRows].count ==  0){
            self.toolBarDeleBtn.enabled = NO;
            self.toolBarMoveBtn.enabled = NO;
            self.toolBarSeleAllBtn.selected = NO;
        }
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView.isEditing){
        // 编辑模式下,启用删除,移动按钮
        self.toolBarDeleBtn.enabled = YES;
        self.toolBarMoveBtn.enabled = YES;
        if ([tableView indexPathsForSelectedRows].count == self.dataArr.count){
            self.toolBarSeleAllBtn.selected = YES;
        }
        return;
    }
    
    XMWifiTransModel *model = self.dataArr[indexPath.row];
    NSString *extesionStr = [[model.fileName lowercaseString] pathExtension];
    // 不支持的格式
    if ([@"zip|rar" containsString:extesionStr]){
        [MBProgressHUD showMessage:@"尚未支持该格式" toView:self.view];
        return;
    }
    
    if(model.fileType == fileTypeImageName){
        NSMutableArray *imgArr = [NSMutableArray array];
        NSInteger currentImgIndex = 0;   // 记录当前的选择图片
        for (XMWifiTransModel *ele in self.dataArr) {
            if (ele.fileType == fileTypeImageName){
                [imgArr addObject:ele];
            }
            if([ele.fullPath isEqualToString:model.fullPath]){
                currentImgIndex = imgArr.count - 1;
            }
        }
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        XMPhotoCollectionViewController *photoVC = [[XMPhotoCollectionViewController alloc] initWithCollectionViewLayout:layout];
        photoVC.selectImgIndex = currentImgIndex;
        photoVC.photoModelArr = imgArr;
        photoVC.cellSize = CGSizeMake(XMScreenW, XMScreenH);
        photoVC.cellInset = UIEdgeInsetsMake(0, 0, 0, 0);
        photoVC.collectionView.contentSize = CGSizeMake(XMScreenW * imgArr.count, XMScreenH);
        [self.navigationController pushViewController:photoVC animated:YES];
        
    }else{
        // 用webview去预览
        XMFileDisplayWebViewViewController *displayVC = [[XMFileDisplayWebViewViewController alloc] init];
        displayVC.wifiModel = model;
        displayVC.view.frame = self.view.bounds;
        [displayVC loadLocalFileWithPath:model.fullPath];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController pushViewController:displayVC animated:YES];
        });
        
    }
}

#pragma mark 编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete){
        XMWifiTransModel *model = self.dataArr[indexPath.row];
        // 如果是文件夹着弹出警告
        if (model.isDir){
            UIAlertController *tips = [UIAlertController alertControllerWithTitle:@"警告" message:@"你即将删除一个文件夹及里面的所有文件" preferredStyle:UIAlertControllerStyleActionSheet];
            __weak typeof(self) weakSelf = self;
            [tips addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
            [tips addAction:[UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action){
                [weakSelf deleteOneCellAtIndexPath:indexPath];
            }]];
            
            [self presentViewController:tips animated:YES completion:nil];
        }else{
            [self deleteOneCellAtIndexPath:indexPath];
        }
    }
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return UITableViewCellEditingStyleDelete;
}

#pragma mark - cell长按编辑手势
- (void)longPressToEditCell:(UILongPressGestureRecognizer *)gest{
    if (gest.state == UIGestureRecognizerStateBegan){
        // 退出编辑模式
        [self cancelEdit:nil];
        // 根据触摸点推算indexPath
        CGPoint point = [gest locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
        __weak typeof(self) weakSelf = self;
        UIAlertController *tips = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *deleAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action){
            [weakSelf deleteOneCellAtIndexPath:indexPath];
        }];
        UIAlertAction *renameAction = [UIAlertAction actionWithTitle:@"重命名" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
            [weakSelf renameFileAtIndexPath:indexPath];
        }];
        UIAlertAction *shareAction = [UIAlertAction actionWithTitle:@"分享" style: UIAlertActionStyleDefault  handler:^(UIAlertAction * _Nonnull action){
            [weakSelf shareFileAtIndexPath:indexPath];
        }];
        
        [tips addAction:cancelAction];
        [tips addAction:deleAction];
        [tips addAction:renameAction];
        [tips addAction:shareAction];
        
        // 根据文件类型是否增加"解压"按钮
        XMWifiTransModel *model = self.dataArr[indexPath.row];
        if ([model.fileType isEqualToString:fileTypeZipName]){
            [tips addAction:[UIAlertAction actionWithTitle:@"解压" style: UIAlertActionStyleDefault  handler:^(UIAlertAction * _Nonnull action){
                BOOL success = [XMWifiGroupTool unzipFileAtPath:model.fullPath];
                [MBProgressHUD showResult:success message:nil];
                if (success){
                    [weakSelf refreshDate:nil];
                   
                }
            }]];
            // 如果是配置文件的zip文件,还多一个同步到本地的选项
            if ([model.fullPath containsString:[NSString stringWithFormat:@"%@/%@",backupGroupName,settingZipFilePre]]){
                [tips addAction:[UIAlertAction actionWithTitle:@"更新本地配置文件" style: UIAlertActionStyleDefault  handler:^(UIAlertAction * _Nonnull action){
                    BOOL success = [XMWifiGroupTool unzipSettingFilesAtPath:model.fullPath];
                    [MBProgressHUD showResult:success message:((success)? @"更新本地配置文件成功":@"更新本地配置文件失败")];
            
                    [weakSelf refreshDate:nil];
                }]];
            }
        }
        
        [self presentViewController:tips animated:YES completion:nil];
    
    }
    
}


/// 重命名文件
- (void)renameFileAtIndexPath:(NSIndexPath *)indexPath{
    // 提取模型,获得文件名称,后缀,然后把不带后缀的名称提取出来当做输入框的文字以便修改
    XMWifiTransModel *model = self.dataArr[indexPath.row];
    NSString *extesionStr = [[model.fileName lowercaseString] pathExtension];
    NSString *fileName = [[model.fileName lastPathComponent] stringByDeletingPathExtension];;
    //弹出
    UIAlertController *tips = [UIAlertController alertControllerWithTitle:@"重命名" message:@"输入新的名称(不带后缀)" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    __weak typeof(self) weakSelf = self;
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action){
        
        // 获得输入内容
        UITextField *textF = tips.textFields[0];
        
        NSString *newName = [NSString stringWithFormat:@"%@.%@",textF.text,extesionStr];
        NSString *newFullPath = [model.rootPath stringByAppendingPathComponent:newName];
        // 重命名,自己覆盖自己
        NSError *error;
        if ([[NSFileManager defaultManager] moveItemAtPath:model.fullPath toPath:newFullPath error:&error]){
            [weakSelf refreshDate:nil];
        }else{
            [MBProgressHUD showMessage:@"名称已存在" toView:weakSelf.view];
        }
        
    }];
    
    [tips addAction:cancelAction];
    [tips addAction:okAction];
    [tips addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = fileName;
    }];
    [self presentViewController:tips animated:YES completion:nil];
    
}

/// 分享文件
- (void)shareFileAtIndexPath:(NSIndexPath *)indexPath{
    XMWifiTransModel *model = self.dataArr[indexPath.row];
    NSString *title = model.pureFileName;
    NSURL *url = [NSURL fileURLWithPath:model.fullPath];
    NSArray *params = @[title, url];
    UIActivityViewController *actVC = [[UIActivityViewController alloc] initWithActivityItems:params applicationActivities:nil];
    [self presentViewController:actVC animated:YES completion:nil];
    
}

@end
