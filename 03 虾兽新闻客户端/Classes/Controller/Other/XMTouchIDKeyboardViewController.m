//
//  XMTouchIDKeyboardViewController.m
//  虾兽维度
//
//  Created by Niki on 18/3/11.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMTouchIDKeyboardViewController.h"
#import "CommonHeader.h"

@interface XMTouchIDKeyboardViewController ()

@property (weak, nonatomic)  UILabel *resultLab;

@end

@implementation XMTouchIDKeyboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self initToolView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

#pragma mark - 工具箱面板整体
#pragma mark 创建工具箱面板
/** 初始化工具箱面板 */
- (void)initToolView
{
    // 1.顶部提示和'取消按钮'
    UIView *topContentV = [[UIView alloc] initWithFrame:CGRectMake(0, 20, XMScreenW, 44)];
    [self.view addSubview:topContentV];
    topContentV.backgroundColor = [UIColor whiteColor];
    UIButton *cancelBtn = [[UIButton alloc] init];
    cancelBtn.frame = CGRectMake(XMScreenW - 100, 0, 100, 44);
    [topContentV addSubview:cancelBtn];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal
     ];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    
    // 2.输入框整体
    UIView *inputContentV = [[UIView alloc] init];
    [self.view addSubview:inputContentV];
    inputContentV.backgroundColor = [UIColor redColor];
    
    // 按钮下标签
    UILabel *labT = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, XMScreenW, 60)];
    labT.backgroundColor = [UIColor whiteColor];
    labT.numberOfLines = 0;
    labT.lineBreakMode = NSLineBreakByWordWrapping;
    labT.text = @"请输入密码";
    labT.tintColor = [UIColor blackColor];
    labT.textAlignment = NSTextAlignmentCenter;
    labT.font = [UIFont systemFontOfSize:17];
    [inputContentV addSubview:labT];
    self.resultLab = labT;
//    //结果显示按钮
//    UIButton *resultBtn = [[UIButton alloc] init];
//    resultBtn.frame = CGRectMake(0, CGRectGetMaxY(labT.frame), XMScreenW, 30);
//    [inputContentV addSubview:resultBtn];
////    resultBtn.hidden = YES;
//    resultBtn.backgroundColor = [UIColor orangeColor];
//    [resultBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal
//     ];
//    resultBtn.titleLabel.font = [UIFont systemFontOfSize:11];
//    [resultBtn setTitle:@"密码错误" forState:UIControlStateNormal];
//    [resultBtn setTitle:@"密码错误" forState:UIControlStateSelected];

    inputContentV.frame = CGRectMake(0, CGRectGetMaxY(topContentV.frame), XMScreenW, CGRectGetMaxY(labT.frame));
    
    // 3.键盘整体
    CGFloat btnWH = 70;         // 工具箱按钮宽高,根据bundle下toolBixIcons文件夹的图标确定
    CGFloat btnLabelH = 20;     // 工具箱按钮标签高度
    CGFloat padding = 10;       // 间隙
    NSUInteger colMaxNum = 3;      // 每行允许排列的图标个数
    // 工具箱菜单栏整体
    UIView *toolView = [[UIView alloc] init];
    [self.view addSubview:toolView];
    toolView.backgroundColor = [UIColor clearColor];
    
    // 工具箱按钮参数(根据需求只开放微信好友和朋友圈和facebook)
    NSArray *btnParams = @[@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1];
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
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(btnX, btnY, btnWH, btnWH)];
        [toolMenuV addSubview:btn];

        btn.tag = 1;
        if (i == 9){
            [btn setTitle:@"忘记密码" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }else if (i == 11){
            [btn setTitle:@"删除" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        }else{
        
            UIImage *iconImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"tool_icon_%zd.png",btn.tag] ofType:nil]];
            [btn setImage:iconImage forState:UIControlStateNormal];
        }
        [btn addTarget:self action:@selector(toolButtonDidClick:) forControlEvents:UIControlEventTouchDown];
        
    }
    
    CGFloat toolViewH = CGRectGetMaxY(toolMenuV.frame) - CGRectGetMinY(toolMenuV.frame);
    toolView.frame = CGRectMake(0, CGRectGetMaxY(inputContentV.frame), [UIScreen mainScreen].bounds.size.width, toolViewH);
}


#pragma mark - 按钮点击事件
- (void)toolButtonDidClick:(UIButton *)btn{
    [self setResultLabel:YES];
    NSLog(@"0000000");
}

- (void)cancel{
//    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"cancel");
}

- (void)setResultLabel:(BOOL)result{
    // 注意:标题决定了下面的两个range需要同步调整,这里说的标题统计指"请输入密码",共5个字,当有改动时需要同步调整titleCount
    int titleCount = 5;
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"请输入密码\n密码错误"];
    // 设置第一行样式
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[NSFontAttributeName] = [UIFont systemFontOfSize:17];
    [str setAttributes:dict range:NSMakeRange(0, titleCount)];
    
    // 设置频道的样式
    NSMutableDictionary *dictChannel = [NSMutableDictionary dictionary];
    dictChannel[NSFontAttributeName] = [UIFont systemFontOfSize:13];
    dictChannel[NSForegroundColorAttributeName] = [UIColor orangeColor];
    [str setAttributes:dictChannel range:NSMakeRange(titleCount + 1, 4)];
    self.resultLab.attributedText = str;
}

@end
