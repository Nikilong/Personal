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
#import "XMFileDisplayWebViewViewController.h"
#import "XMWifiLeftTableViewController.h"
#import "XMWifiGroupTool.h"

#import "XMWebTableViewCell.h"
#import "MBProgressHUD+NK.h"

#import "SSZipArchive.h"
#import "XMPhotoCollectionViewController.h"
#import "HJVideoPlayerController.h"
#import "XMQRCodeViewController.h"
#import "ZLPhotoPickerViewController.h"
#import "XMImageUtil.h"
#import "XMNavigationController.h"

typedef enum : NSUInteger {
    XMFileSortTypeBigFirst,     //
    XMFileSortTypeSmallFirst,
    XMFileSortTypeNewFirst,
    XMFileSortTypeOldFirst,
    XMFileSortTypeFileType,
} XMFileSortType;


@interface XMWifiTransFileViewController ()
<XMWifiLeftTableViewControllerDelegate,
ZLPhotoPickerViewControllerDelegate,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate,
UITextFieldDelegate,
UIGestureRecognizerDelegate>


@property (nonatomic, strong) HTTPServer *httpServer;
@property (nonatomic, assign)  BOOL isScanConectQrcode;   // 是否正在扫码
@property (nonatomic, assign)  BOOL openHttpServerFlag;   // 是否开启本地http服务
@property (nonatomic, assign)  BOOL connectServerFlag;      // 是否与电脑端服务器连接
@property (nonatomic, copy)  NSString *serverURL;      // 电脑端服务器地址
@property (weak, nonatomic)  UIButton *navWifiBtn;     // 导航栏wifi按钮

@property (weak, nonatomic)  UIView *toolBar;                // 批量编辑下的工具条
@property (weak, nonatomic)  UIButton *toolBarDeleBtn;       // 工具条删除按钮
@property (weak, nonatomic)  UIButton *toolBarMoveBtn;       // 工具条移动按钮
@property (weak, nonatomic)  UIButton *toolBarUploadBtn;     // 工具条上传按钮
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

/// 搜索框
@property (weak, nonatomic)  UITextField *searchF;

/// 搜索结果数据源
@property (nonatomic, strong) NSMutableArray *searchArr;
/// 当前数据源
@property (nonatomic, strong) NSMutableArray *currentDataArr;
/// 文件夹遍历的数据源
@property (nonatomic, strong) NSMutableArray *realDataArr;


@end

@implementation XMWifiTransFileViewController

- (UIView *)toolBar{
    if (!_toolBar){
        
        CGFloat toolH = 44;
        CGFloat margin = 10;
        CGFloat btnWH = 30;
        CGFloat btnY = (toolH - btnWH) * 0.5;
        UIView *toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, XMScreenH - toolH + (isIphoneX ? -24 : 0), XMScreenW, toolH + (isIphoneX ? 24 : 0))];
        toolBar.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0f];
        _toolBar = toolBar;
        [self.view.superview addSubview:toolBar];
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
        
        // 上传按钮
        UIButton *uploadBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(moveBtn.frame) + 40, btnY, btnWH, btnWH)];
        self.toolBarUploadBtn = uploadBtn;
        [toolBar addSubview:uploadBtn];
        [uploadBtn addTarget:self action:@selector(uploadFiles:) forControlEvents:UIControlEventTouchUpInside];
        [uploadBtn setImage:[UIImage imageNamed:@"file_upload_disable"] forState:UIControlStateDisabled];
        [uploadBtn setImage:[UIImage imageNamed:@"file_upload_able"] forState:UIControlStateNormal];
        uploadBtn.enabled = NO;
    }
    return _toolBar;
}

- (NSMutableArray *)searchArr{
    if (!_searchArr){
        _searchArr = [NSMutableArray array];
    }
    return _searchArr;
}

- (NSMutableArray *)realDataArr{
    if (!_realDataArr){
        _realDataArr = [XMWifiGroupTool getCurrentGroupFiles];
    }
    return _realDataArr;
}

- (NSMutableArray *)currentDataArr{
    if (!_currentDataArr){
        _currentDataArr = [NSMutableArray arrayWithArray:self.realDataArr];
    }
    return _currentDataArr;
}

- (UIView *)cover{
    if (!_cover){
        UIView *cover = [[UIView alloc] initWithFrame:CGRectMake(XMWifiLeftViewTotalW, 0, XMScreenW - XMWifiLeftViewTotalW, XMScreenH)];
        cover.backgroundColor = [UIColor clearColor];
        [self.view.superview insertSubview:cover belowSubview:self.tableView];
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
    self.openHttpServerFlag = NO;
    self.connectServerFlag = NO;
    self.isScanConectQrcode = NO;
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.isMoveFilesMode = NO;
    // 更新本地数据
//    [self refreshDate:nil];
    
    // 初始化导航栏
    [self createNav];
    
    // 添加系统原生下拉刷新
    [self creatRefreshKit];
    
    // 添加左侧栏轻扫手势
    [self addLeftViewGesture];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadFinish:) name:@"XMWifiTransfronFilesComplete" object:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self cancelSearch];
    [self.searchF removeFromSuperview];
    [self hideLeftView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"XMWifiTransfronFilesComplete" object:nil];
}

- (void)dealloc{
    self.httpServer = nil;
    NSLog(@"XMWifiTransFileViewController----%s",__func__);
}

- (void)refreshDate:(UIRefreshControl *)con{
    // 如果是由下拉刷新触发的刷新则需要结束刷新动画
    if (con){
        [con endRefreshing];
    }
    [self.realDataArr removeAllObjects];
    [self.currentDataArr removeAllObjects];
    self.realDataArr = [XMWifiGroupTool getCurrentGroupFiles];
    [self.currentDataArr addObjectsFromArray:self.realDataArr];
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
    // 搜索模式
    UIBarButtonItem *searchBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchFile)];
    self.navigationItem.leftBarButtonItems = @[backBtn,editBtn,searchBtn];
    
    // 右边为打开wifi的按钮 wifiopen
//    UIView *rightContentV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30 * 3, 30)];
    UIButton *wifiBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    self.navWifiBtn = wifiBtn;
    [wifiBtn setImage:[UIImage imageNamed:@"wifiopen"] forState:UIControlStateSelected];
    [wifiBtn setImage:[UIImage imageNamed:@"wificlose"] forState:UIControlStateNormal];
    [wifiBtn addTarget:self action:@selector(switchHttpServerConnect:) forControlEvents:UIControlEventTouchUpInside];
//    [rightContentV addSubview:wifiBtn];
//    // 从相册添加图片
//    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeSystem];
//    addBtn.frame =CGRectMake(30, 0, 30, 30);
//    [addBtn setTitle:@"+" forState:UIControlStateNormal];
//    [addBtn addTarget:self action:@selector(addImageFromAlbum) forControlEvents:UIControlEventTouchUpInside];
//    [rightContentV addSubview:addBtn];
//    // 排序
//    UIButton *sortBtn = [UIButton buttonWithType:UIButtonTypeSystem];
//    sortBtn.frame =CGRectMake(60, 0, 30, 30);
//    [sortBtn setTitle:@"+" forState:UIControlStateNormal];
//    [sortBtn addTarget:self action:@selector(sortFiles) forControlEvents:UIControlEventTouchUpInside];
//    [rightContentV addSubview:sortBtn];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightContentV];
    UIBarButtonItem *wifiBarBtn = [[UIBarButtonItem alloc] initWithCustomView:wifiBtn];
    // 从相册添加图片
    UIBarButtonItem *addBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addImageFromAlbum)];
    // 排序
    UIBarButtonItem *sortBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(sortFiles)];
    self.navigationItem.rightBarButtonItems = @[wifiBarBtn,addBtn,sortBtn];
    
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
    
#pragma mark 手机服务器和电脑服务器连接情况---end
/// 打开/关闭一个http服务
- (void)switchHttpServerConnect:(UIButton *)wifiBtn{
    if (self.openHttpServerFlag){
        UIAlertController *tips = [UIAlertController alertControllerWithTitle:@"下一步" message:nil preferredStyle:UIAlertControllerStyleAlert];
        __weak typeof(self) weakSelf = self;
        [tips addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [tips addAction:[UIAlertAction actionWithTitle:@"显示本机ip" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action){
            [weakSelf showIP];
        }]];
//        [tips addAction:[UIAlertAction actionWithTitle:@"接收文件" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action){
//            [weakSelf sendMessageToServer:weakSelf.serverURL];
//        }]];
        [tips addAction:[UIAlertAction actionWithTitle:@"重新配对" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action){
            weakSelf.connectServerFlag = NO;
            weakSelf.serverURL = nil;
            [weakSelf connnectToServer];
        }]];
        [tips addAction:[UIAlertAction actionWithTitle:@"关闭传输" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action){
            weakSelf.navWifiBtn.selected = NO;
            // 关闭http服务
            [weakSelf.httpServer stop];
            weakSelf.openHttpServerFlag = NO;
            weakSelf.serverURL = nil;
            [MBProgressHUD showMessage:@"Wifi传输已关闭" toView:nil];
        }]];
        
        [self presentViewController:tips animated:YES completion:nil];
        
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
//    [self.httpServer setPort:60285];
    
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
        self.openHttpServerFlag = YES;
        self.navWifiBtn.selected = YES;
        [self connnectToServer];
    }
    
    
}
    

/// 与电脑端服务器连接
- (void)connnectToServer{
    // 判断目前与电脑连接是否良好
    if(!self.connectServerFlag && !self.isScanConectQrcode){
        // 标记正在扫码
        self.isScanConectQrcode = YES;
        XMQRCodeViewController *qrVC = [[XMQRCodeViewController alloc] init];
        __weak typeof(self) weakSelf = self;
        qrVC.scanCallBack = ^(NSString *scanResult){
            // 获得本机IP和端口号
            unsigned short port = [weakSelf.httpServer listeningPort];
            NSString *ip = [NSString stringWithFormat:@"http://%@:%hu",[ZBTool getIPAddress:YES],port];
            // 发送请求给服务器,要求链接
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/connect?url=%@",scanResult,ip]];
            NSURLSession *section = [NSURLSession sharedSession];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            NSURLSessionDataTask *task = [section dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                // 标记扫码结束
                weakSelf.isScanConectQrcode = NO;
                
                NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                /// connect success是与服务器约定的链接成功的标志
                if ([result containsString:@"connect success"]){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // 保存服务器地址
                        weakSelf.serverURL = scanResult;
                        weakSelf.connectServerFlag = YES;
                        [MBProgressHUD showMessage:@"连接成功"];
//                        dispatch_after(3.0f, dispatch_get_main_queue(), ^{
//                            [weakSelf sendMessageToServer:scanResult];
//                        });
                    });
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.connectServerFlag = NO;
                        [MBProgressHUD showMessage:@"无法连接到服务器"];
                    });
                }
            } ];
            
            [task resume];
        };
        [self.navigationController pushViewController:qrVC animated:YES];
    }
}
    
/// 发送消息给电脑端服务器,表示手机端准备接受文件
- (void)sendMessageToServer:(NSString *)serverURL{
    // 获得本机IP和端口号
    unsigned short port = [self.httpServer listeningPort];
    NSString *ip = [NSString stringWithFormat:@"http://%@:%hu",[ZBTool getIPAddress:YES],port];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/sendFiles?url=%@",serverURL,ip]];
    NSURLSession *section = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSURLSessionDataTask *task = [section dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    } ];
    
    [task resume];
}

/// 弹出ip信息
- (void)showIP{
    if(self.openHttpServerFlag){
        // 获得本机IP和端口号
        unsigned short port = [self.httpServer listeningPort];
        NSString *ip = [NSString stringWithFormat:@"http://%@:%hu",[ZBTool getIPAddress:YES],port];
        [self showAlertWithTitle:@"浏览器传输网址" message:ip];
        
    }else{
        [MBProgressHUD showMessage:@"Wifi传输未打开" toView:self.view];
    }
    
}
    
/// 上传动画开始
- (void)startUploadAnimate{
    [self.navWifiBtn setImage:[UIImage imageNamed:@"wifiopen_upload"] forState:UIControlStateSelected];
    CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0];
    rotationAnimation.duration = 2.0;;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount=MAXFLOAT;
    [self.navWifiBtn.imageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}
    
/// 停止上传动画
- (void)stopUploadAnimate{
    [self.navWifiBtn.imageView.layer removeAllAnimations];
    [self.navWifiBtn setImage:[UIImage imageNamed:@"wifiopen"] forState:UIControlStateSelected];
}
    
#pragma mark 手机服务器和电脑服务器连接情况---end
    
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

/// 搜索文件
- (void)searchFile{
    if (!self.searchF){
        UITextField *searchF = [[UITextField alloc] init];
        searchF.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 32);
        searchF.delegate = self;
        searchF.placeholder = @"请输入要搜索的条件";
        searchF.background = [UIImage imageNamed:@"searchbar_textfield_background"];
        // 添加右边全部清除按钮
        searchF.clearButtonMode = UITextFieldViewModeWhileEditing;
        // 添加左边搜索框图片
        UIImageView *leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchbar_textfield_search_icon"]];
        // 设置图片居中
        leftView.contentMode = UIViewContentModeCenter;
        leftView.frame = CGRectMake(0, 0, 30, 30);
        searchF.leftView = leftView;
        searchF.leftViewMode = UITextFieldViewModeAlways;
        self.searchF = searchF;
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window addSubview:searchF];
    }
    self.searchF.text = @"";
    self.searchF.hidden = NO;
    [self.searchF becomeFirstResponder];
}

/// 取消搜索
- (void)cancelSearch{
    if (self.searchF.hidden == NO){
        [self.searchF resignFirstResponder];
        self.searchF.hidden = YES;
    }
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
    ZLPhotoPickerViewController *photoVC = [[ZLPhotoPickerViewController alloc] init];
    photoVC.delegate = self;
    photoVC.minCount = 9;  // 最多选择9张
    photoVC.status = PickerViewShowStatusCameraRoll;
    [photoVC show];
    
}
    
#pragma mark - ZLPhotoPickerViewControllerDelegate
- (void) pickerViewControllerDoneAsstes : (NSArray *) assets{
    for (NSUInteger i = 0; i < assets.count; i++) {
        ZLPhotoAssets *asset = assets[i];
        UIImage *seleImg = [asset originImage];
        // 拼接文件全路径,文件名是日期(排除空格和后面的时区)
//        NSString *fileName = [XMWifiGroupTool dateChangeToString:[NSDate date]];
        //        NSString *savePath = [NSString stringWithFormat:@"%@/%@_%lu.jpg",[XMWifiGroupTool getCurrentGroupPath],fileName,i+1];
        // 采用相册文件本身的源名字作为文件名
        NSString *originName = [asset imageName];
        NSString *savePath = [NSString stringWithFormat:@"%@/%@",[XMWifiGroupTool getCurrentGroupPath],originName];
        
        // 区别gif和图片
        if(asset.isGif){
            NSData *gifData = [XMImageUtil changeGifToDataWithAsset:asset.asset];
            [gifData writeToFile:savePath atomically:YES];
        }else{
            [UIImageJPEGRepresentation(seleImg,0.9) writeToFile:savePath atomically:YES];
        }

    }
    [self refreshDate:nil];
}

#pragma mark toolbar
/// 全选/取消全选所有cell
- (void)selectAllCell:(UIButton *)btn{
    btn.selected = !btn.selected;
    if (btn.selected){
        // 全选状态
        if (self.currentDataArr.count == 0) return;
        for (NSInteger i = 0; i < self.currentDataArr.count; i++) {
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
        }
        self.toolBarUploadBtn.enabled = (self.serverURL) ? YES : NO;
        self.toolBarDeleBtn.enabled = YES;
        self.toolBarMoveBtn.enabled = YES;
    }else{
        // 取消全选状态
        NSArray *seleArr = [self.tableView indexPathsForSelectedRows];
        for (NSIndexPath *indexPath in seleArr){
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        self.toolBarUploadBtn.enabled = NO;
        self.toolBarDeleBtn.enabled = NO;
        self.toolBarMoveBtn.enabled = NO;
    }
}

/// 移动所选的cell
- (void)moveSelectCell:(UIButton *)btn{
//    btn.enabled = NO;
    self.toolBar.userInteractionEnabled = NO;
    self.isMoveFilesMode = YES;
    [self showLeftView];
}

/// 上传所选的文件
- (void)uploadFiles:(UIButton *)btn{
    btn.enabled = NO;
    self.toolBar.userInteractionEnabled = NO;
    NSArray *seleArr = [self.tableView indexPathsForSelectedRows];
    // 先对数组进行降序处理,将indexPath.row最大(即最底下的数据先删除),防止序号紊乱
    NSArray *sortArr = [self sortArray:seleArr];
    if (seleArr.count > 0){
        for (NSIndexPath *indexPath in sortArr){
            [self sendFileToServer:indexPath];
            sleep(2);
        }
    }
    [self cancelEdit:nil];
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
    if (self.currentDataArr.count - 1 < indexPath.row){
        return;
    }
    XMWifiTransModel *model = self.currentDataArr[indexPath.row];
    // 先判断文件能够进行操作
    if (![XMWifiGroupTool canDeleteFileAtPath:model.fullPath]){
        [MBProgressHUD showMessage:@"系统文件,不可操作!" toView:self.view];
        return;
    }
    NSError *error;
    BOOL succesFlag = [[NSFileManager defaultManager] removeItemAtPath:model.fullPath error:&error];
    if(succesFlag){
        [self.currentDataArr removeObjectAtIndex:indexPath.row];
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
    self.toolBarSeleAllBtn.selected = NO;
    self.toolBarDeleBtn.enabled = NO;
    self.toolBarMoveBtn.enabled = NO;
    [self.tableView setEditing:NO animated:YES];
    self.toolBar.hidden = YES;
}


#pragma mark 左侧栏
/// 左侧栏手势设置
- (void)addLeftViewGesture{
    // 左侧抽屉手势,限定触发区域在屏幕1/4到最右边
    UISwipeGestureRecognizer *swip = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showLeftView)];
    swip.delegate = self;
    swip.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swip];
    
    // 防止手势冲突
    XMNavigationController *nav = (XMNavigationController *)self.navigationController;
    [nav.customerPopGestureRecognizer requireGestureRecognizerToFail:swip];
}

/**  添加左侧边栏*/
-(void)addLeftVC{
    
    // 创建左侧边栏容器
    UIView *leftContentView = [[UIView alloc] initWithFrame:CGRectMake(-XMWifiLeftViewTotalW, 44 + XMStatusBarHeight, XMWifiLeftViewTotalW, XMScreenH - 44 - XMStatusBarHeight)];
    leftContentView.backgroundColor = [UIColor grayColor];
    self.leftContentView = leftContentView;
    self.leftContentView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    // 创建左侧边栏
    self.leftVC = [[XMWifiLeftTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    self.leftVC.delegate = self;
    self.leftVC.view.frame = CGRectMake(XMLeftViewPadding, XMLeftViewPadding, XMWifiLeftViewTotalW - 2 *XMLeftViewPadding, self.leftContentView.frame.size.height - 2 * XMLeftViewPadding);
    [self.leftContentView addSubview:self.leftVC.view];
    [self.view.superview insertSubview:self.leftContentView aboveSubview:self.tableView];
    
    // 左侧边栏添加左划取消手势
    UISwipeGestureRecognizer *swip = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideLeftView)];
    swip.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.leftVC.tableView addGestureRecognizer:swip];
}

/** 显示左侧边栏 */
- (void)showLeftView{
    if (!self.leftContentView){
        [self addLeftVC];
    }
    // 显示蒙板
    self.cover.hidden = NO;
    
    // 添加到蒙板和侧边栏到最顶部
    [self.view.superview bringSubviewToFront:self.leftContentView];
    [self.view.superview bringSubviewToFront:self.cover];
    
    // 设置动画弹出左侧边栏
    [UIView animateWithDuration:0.5 animations:^{
        self.leftContentView.transform = CGAffineTransformMakeTranslation(XMWifiLeftViewTotalW, 0);
    }];
    
}

/** 隐藏左侧边栏 */
- (void)hideLeftView{
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

#pragma mark UITextfieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self cancelSearch];
    [self.searchArr removeAllObjects];
    // 此处应该从最原始的数据去搜索
    for (XMWifiTransModel *model in self.realDataArr){
        if([model.fileName.lowercaseString containsString:textField.text.lowercaseString]){
            [self.searchArr addObject:model];
        }
    }
    if(self.searchArr.count > 0){
        [self.currentDataArr removeAllObjects];
        [self.currentDataArr addObjectsFromArray:self.searchArr];
        [self.tableView reloadData];
    }else{
        [MBProgressHUD showMessage:@"没有找到相关的结果"];
    }
    
    return YES;
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
            XMWifiTransModel *model = self.currentDataArr[indexPath.row];
            NSString *newFullPath = [NSString stringWithFormat:@"%@/%@/%@",[XMSavePathUnit getWifiUploadDirPath],groupName,model.pureFileName];
//            NSLog(@"%@",newFullPath);
            // 重命名,自己覆盖自己
            NSError *error= nil;
            if (![[NSFileManager defaultManager] moveItemAtPath:model.fullPath toPath:newFullPath error:&error]){
                [MBProgressHUD showMessage:@"名称已存在" toView:self.view];
            }
        }
        [self refreshDate:nil];
        
    }else{
        // 一系列设置标题
        self.navTitleLab.text = groupName;
        [XMWifiGroupTool upgradeCurrentGroupName:groupName];
        [self refreshDate:nil];
        
    }
    
    [self hideLeftView];
    // 不论何种模式,点击了选择组别,取消全选状态和设置删除和移动按钮不可用
//    self.toolBarSeleAllBtn.selected = NO;
//    self.toolBarDeleBtn.enabled = NO;
//    self.toolBarMoveBtn.enabled = NO;
    [self cancelEdit:nil];
}

- (void)leftWifiTableViewControllerDidDeleteGroupName:(NSString *)groupName{
    // 如果删除的文件夹刚好是当前展示的数组,那么需要切换到"默认"的文件夹
    if ([groupName isEqualToString:self.navTitleLab.text]){
        self.navTitleLab.text = defaultGroupName;
        [self refreshDate:nil];
    }
}

#pragma mark - UIScrollerViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self cancelSearch];
    [self hideLeftView];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if ([gestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]){
        [self hideLeftView];
    }
    /// 左侧栏的轻扫手势作用区域要在1/4到最右边
    if ([gestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]]){
        if ([gestureRecognizer locationInView:self.tableView].x < 0.25 * XMScreenW){
            return NO;
        }
    }
    return YES;
}
    
#pragma mark - 排序方法
/// 排序按钮点击事件
- (void)sortFiles{
    UIAlertController *tips = [UIAlertController alertControllerWithTitle:@"排序方式" message:@"选择排序方式" preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    [tips addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [tips addAction:[UIAlertAction actionWithTitle:@"时间(降序)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        [weakSelf sortFilesByType:XMFileSortTypeNewFirst];
    }]];
    [tips addAction:[UIAlertAction actionWithTitle:@"时间(升序)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        [weakSelf sortFilesByType:XMFileSortTypeOldFirst];
    }]];
    [tips addAction:[UIAlertAction actionWithTitle:@"大小(降序)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        [weakSelf sortFilesByType:XMFileSortTypeBigFirst];
    }]];
    [tips addAction:[UIAlertAction actionWithTitle:@"大小(升序)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        [weakSelf sortFilesByType:XMFileSortTypeSmallFirst];
    }]];
    [tips addAction:[UIAlertAction actionWithTitle:@"类型" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        [weakSelf sortFilesByType:XMFileSortTypeFileType];
    }]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:tips animated:YES completion:nil];
    });


}

/// 个性化排序
- (void)sortFilesByType:(XMFileSortType)type{

//    NSArray *sortArr = [NSArray array];
    switch (type) {
        case XMFileSortTypeBigFirst:{   // 文件大小降序
            [self.currentDataArr sortUsingComparator:^(XMWifiTransModel * obj1, XMWifiTransModel * obj2){
                if (obj1.size > obj2.size) {
                    return (NSComparisonResult)NSOrderedAscending;
                }
                if (obj1.size < obj2.size) {
                    return (NSComparisonResult)NSOrderedDescending;
                }
                return (NSComparisonResult)NSOrderedSame;
            }];
            break;
        }
        case XMFileSortTypeSmallFirst:{ // 文件大小升序
            [self.currentDataArr sortUsingComparator:^(XMWifiTransModel * obj1, XMWifiTransModel * obj2){
                if (obj1.size < obj2.size) {
                    return (NSComparisonResult)NSOrderedAscending;
                }
                if (obj1.size > obj2.size) {
                    return (NSComparisonResult)NSOrderedDescending;
                }
                return (NSComparisonResult)NSOrderedSame;
            }];
            break;
        }
        case XMFileSortTypeNewFirst:{   // 文件时间降序
            [self.currentDataArr sortUsingComparator:^(XMWifiTransModel * obj1, XMWifiTransModel * obj2){
                if (obj1.createDateCount > obj2.createDateCount) {
                    return (NSComparisonResult)NSOrderedAscending;
                }
                if (obj1.createDateCount < obj2.createDateCount) {
                    return (NSComparisonResult)NSOrderedDescending;
                }
                return (NSComparisonResult)NSOrderedSame;
            }];

            break;
        }
        case XMFileSortTypeOldFirst:{   // 文件时间升序
            [self.currentDataArr sortUsingComparator:^(XMWifiTransModel * obj1, XMWifiTransModel * obj2){
                if (obj1.createDateCount < obj2.createDateCount) {
                    return (NSComparisonResult)NSOrderedAscending;
                }
                if (obj1.createDateCount > obj2.createDateCount) {
                    return (NSComparisonResult)NSOrderedDescending;
                }
                return (NSComparisonResult)NSOrderedSame;
            }];
            break;
        }
        case XMFileSortTypeFileType:{   // 文件类型
            [self.currentDataArr sortUsingComparator:^(XMWifiTransModel * obj1, XMWifiTransModel * obj2){
                if (obj1.fileType > obj2.fileType) {
                    return (NSComparisonResult)NSOrderedAscending;
                }
                if (obj1.fileType < obj2.fileType) {
                    return (NSComparisonResult)NSOrderedDescending;
                }
                return (NSComparisonResult)NSOrderedSame;
            }];
            break;
        }
        default:{
            break;
        }
    }
//    [self.currentDataArr removeAllObjects];
//    [self.currentDataArr addObjectsFromArray:sortArr];
    [self.tableView reloadData];
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
    return self.currentDataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    XMWebTableViewCell *cell = [XMWebTableViewCell cellWithTableView:tableView];
    
    // 添加重命名手势
    UILongPressGestureRecognizer *longGest = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToEditCell:)];
    [cell.contentView addGestureRecognizer:longGest];

    XMWifiTransModel *model = self.currentDataArr[indexPath.row];
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
            self.toolBarUploadBtn.enabled = NO;
            self.toolBarSeleAllBtn.selected = NO;
        }
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 隐藏搜索
    [self cancelSearch];
    if(tableView.isEditing){
        // 编辑模式下,启用删除,移动按钮
        self.toolBarDeleBtn.enabled = YES;
        self.toolBarMoveBtn.enabled = YES;
        self.toolBarUploadBtn.enabled = (self.serverURL) ? YES : NO;
        if ([tableView indexPathsForSelectedRows].count == self.currentDataArr.count){
            self.toolBarSeleAllBtn.selected = YES;
        }
        return;
    }else{
        // 取消选中状态
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    XMWifiTransModel *model = self.currentDataArr[indexPath.row];
    NSString *extesionStr = [[model.fileName lowercaseString] pathExtension];
    // 不支持的格式
    if ([@"zip|rar" containsString:extesionStr]){
        [MBProgressHUD showMessage:@"尚未支持该格式" toView:self.view];
        return;
    }
    if (model.isDir){
        [MBProgressHUD showMessage:@"不支持文件夹" toView:nil];
        return;
    }
    if(model.fileType == fileTypeImageName){
        // 图片浏览器
        NSMutableArray *imgArr = [NSMutableArray array];
        NSInteger currentImgIndex = 0;   // 记录当前的选择图片
        for (XMWifiTransModel *ele in self.currentDataArr) {
            if (ele.fileType == fileTypeImageName){
                [imgArr addObject:ele];
            }
            if([ele.fullPath isEqualToString:model.fullPath]){
                currentImgIndex = imgArr.count - 1;
            }
        }
        
        // 获得点击的cell的相框的frame
        XMWebTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIImageView *imgV;
        for(UIView *subV in cell.contentView.subviews){
            if ([subV isKindOfClass:[UIImageView class]]){
                imgV = (UIImageView *)subV;
            }
        }
        // 转为绝对坐标
        CGRect imgF = [cell convertRect:imgV.frame toView:[UIApplication sharedApplication].keyWindow];
        
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        XMPhotoCollectionViewController *photoVC = [[XMPhotoCollectionViewController alloc] initWithCollectionViewLayout:layout];
        photoVC.clickImageF = imgF;
        photoVC.clickCellH = cell.frame.size.height;
        photoVC.selectImgIndex = currentImgIndex;
        photoVC.photoModelArr = imgArr;
        photoVC.cellSize = CGSizeMake(XMScreenW, XMScreenH);
        photoVC.cellInset = UIEdgeInsetsMake(- (44 + XMStatusBarHeight), 0, 0, 0);
        photoVC.collectionView.contentSize = CGSizeMake(XMScreenW * imgArr.count, XMScreenH);
        [self.navigationController pushViewController:photoVC animated:YES];
    
    }else if (model.fileType == fileTypeVideoName){
        // 视频播放
        // 筛选视频列表
        NSMutableArray *videoArr = [NSMutableArray array];
        NSInteger currentVideoIndex = 0;   // 记录当前的视频索引
        for (XMWifiTransModel *ele in self.currentDataArr) {
            if (ele.fileType == fileTypeVideoName){
                [videoArr addObject:ele];
            }
            if([ele.fullPath isEqualToString:model.fullPath]){
                currentVideoIndex = videoArr.count - 1;
            }
        }
        HJVideoPlayerController *videoVC = [[HJVideoPlayerController alloc] init];
        videoVC.videoIndex = currentVideoIndex;
        videoVC.videoList = videoArr;
        [videoVC setUrl:model.fullPath];
        [videoVC.configModel setOnlyFullScreen:YES];
//        [videoVC.configModel setAutoPlay:YES];  // 默认自动播放
        [self.navigationController pushViewController:videoVC animated:YES];
        
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

/// 修改左划文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete){
        XMWifiTransModel *model = self.currentDataArr[indexPath.row];
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

        [tips addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [tips addAction:[UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action){
            [weakSelf deleteOneCellAtIndexPath:indexPath];
        }]];
        [tips addAction:[UIAlertAction actionWithTitle:@"重命名" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
            [weakSelf renameFileAtIndexPath:indexPath];
        }]];
        [tips addAction:[UIAlertAction actionWithTitle:@"分享" style: UIAlertActionStyleDefault  handler:^(UIAlertAction * _Nonnull action){
            [weakSelf shareFileAtIndexPath:indexPath];
        }]];
        [tips addAction:[UIAlertAction actionWithTitle:@"上传" style: UIAlertActionStyleDefault  handler:^(UIAlertAction * _Nonnull action){
            [weakSelf sendFileToServer:indexPath];
        }]];
        
        // 根据文件类型是否增加"解压"按钮
        XMWifiTransModel *model = self.currentDataArr[indexPath.row];
        if ([model.fileType isEqualToString:fileTypeZipName]){
            [tips addAction:[UIAlertAction actionWithTitle:@"解压" style: UIAlertActionStyleDefault  handler:^(UIAlertAction * _Nonnull action){
                BOOL success = [XMWifiGroupTool unzipFileAtPath:model.fullPath];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD showResult:success message:nil];
                    if (success){
                        [weakSelf refreshDate:nil];
                    }
                });
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
    XMWifiTransModel *model = self.currentDataArr[indexPath.row];
    NSString *extesionStr = [[model.fileName lowercaseString] pathExtension];
    NSString *fileName = [[model.fileName lastPathComponent] stringByDeletingPathExtension];;
    //弹出
    UIAlertController *tips = [UIAlertController alertControllerWithTitle:@"重命名" message:@"输入新的名称(不带后缀)" preferredStyle:UIAlertControllerStyleAlert];
    
    __weak typeof(self) weakSelf = self;
    [tips addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [tips addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action){
        
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
        
    }]];
    [tips addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.clearButtonMode = UITextFieldViewModeAlways;
        textField.text = fileName;
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:tips animated:YES completion:nil];
    });
    
}

/// 分享文件
- (void)shareFileAtIndexPath:(NSIndexPath *)indexPath{
    XMWifiTransModel *model = self.currentDataArr[indexPath.row];
    NSString *title = model.pureFileName;
    NSURL *url = [NSURL fileURLWithPath:model.fullPath];
    NSArray *params = @[title, url];
    UIActivityViewController *actVC = [[UIActivityViewController alloc] initWithActivityItems:params applicationActivities:nil];
    [self presentViewController:actVC animated:YES completion:nil];
    
}
    
- (void)sendFileToServer:(NSIndexPath *)indexPath{
    // 保持移动端和电脑端两边同时打开服务器才能传输文件
    if (!self.openHttpServerFlag){
        [self switchHttpServerConnect:nil];
    }
    if(self.connectServerFlag){
        // 取出模型
        XMWifiTransModel *model = self.currentDataArr[indexPath.row];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        
        // 指定上传服务器的地址
        NSURL *url;
        if (TARGET_OS_SIMULATOR == 1 && TARGET_OS_IPHONE == 1) {
            // 模拟器
            url = [NSURL URLWithString:[@"http://192.168.1.100:8000" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }else{
            url = [NSURL URLWithString:[self.serverURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
        NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:url];
        mutableRequest.HTTPMethod = @"POST";
        
        NSString * kHttpRequestHeadBoundaryValue =@"forjoritest";
        NSString * kHttpRequestContentDisposition =@"Content-Disposition: form-data";
        [mutableRequest addValue:@"multipart/form-data; boundary=forjoritest" forHTTPHeaderField:@"Content-Type"];
        
        // 边界头尾,用于隔开文件
        NSString *body = [NSString stringWithFormat:@"\r\n--%@\r\n%@; filename=\"%@\" \r\n\r\n", kHttpRequestHeadBoundaryValue, kHttpRequestContentDisposition,model.pureFileName];
        
        // 拼接要上传的文件,转为data
        NSMutableData *data = [NSMutableData data];
        [data appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:[NSData dataWithContentsOfURL:[NSURL fileURLWithPath:model.fullPath]]];
        // 添加结束标志
        [data appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", kHttpRequestHeadBoundaryValue] dataUsingEncoding:NSUTF8StringEncoding]];
        mutableRequest.HTTPBody = data;
        
        // 添加文件长度
        [mutableRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)data.length] forHTTPHeaderField:@"Content-Length"];
        
        // 开始任务
        __weak typeof(self) weakSelf = self;
        NSURLSessionUploadTask *task = [session uploadTaskWithRequest:mutableRequest fromData:nil completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf stopUploadAnimate];
                if(error){
                    [MBProgressHUD showFailed:nil];
                }else{
                    [MBProgressHUD showSuccess:nil];
                }
            });
        }];
        [task resume];
        // 开始上传动画
        [self startUploadAnimate];
    }else{
        [self connnectToServer];
    }
    
}
    


@end
