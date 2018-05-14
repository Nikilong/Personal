//
//  XMTouchIDKeyboardViewController.m
//  虾兽维度
//
//  Created by Niki on 18/3/11.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMTouchIDKeyboardViewController.h"

@interface XMTouchIDKeyboardViewController ()

// 显示密码错误或者提示输入的标题
@property (weak, nonatomic)  UILabel *resultLab;

// 4位密码的数组
@property (nonatomic, strong) NSMutableArray *inputBtnArr;

// 输入的实质数组
@property (nonatomic, strong) NSMutableArray *clickBtnArr;

// 记录输入了多少位数字
@property (nonatomic, assign)  NSUInteger inputIndex;

// 删除按钮
@property (weak, nonatomic)  UIButton *deleBtn;

@end

@implementation XMTouchIDKeyboardViewController

- (NSMutableArray *)inputBtnArr
{
    if (!_inputBtnArr)
    {
        _inputBtnArr = [[NSMutableArray alloc] init];
    }
    return _inputBtnArr;
}

- (NSMutableArray *)clickBtnArr
{
    if (!_clickBtnArr)
    {
        _clickBtnArr = [[NSMutableArray alloc] init];
    }
    return _clickBtnArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
    self.inputIndex = 0;
    [self initToolView];
    [self setResultLabel:NO];
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
    topContentV.backgroundColor = [UIColor clearColor];
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
    inputContentV.backgroundColor = [UIColor clearColor];
    
    // 按钮下标签
    UILabel *labT = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, XMScreenW, 60)];
    labT.backgroundColor = [UIColor clearColor];
    labT.numberOfLines = 0;
    labT.lineBreakMode = NSLineBreakByWordWrapping;
    labT.tintColor = [UIColor blackColor];
    labT.textAlignment = NSTextAlignmentCenter;
    labT.font = [UIFont systemFontOfSize:17];
    [inputContentV addSubview:labT];
    self.resultLab = labT;
    //结果显示按钮
    CGFloat inputBtnWH = 30;
    CGFloat inputBtnPadding = 5;
    CGFloat inputBtnMargin = (XMScreenW - 4 * inputBtnWH - 3 * inputBtnPadding) * 0.5;
    for (NSUInteger i = 0; i < 4; i++) {
        UIButton *resultBtn = [[UIButton alloc] init];
        [self.inputBtnArr addObject:resultBtn];
        resultBtn.frame = CGRectMake(inputBtnMargin + (inputBtnWH + inputBtnPadding) * i, CGRectGetMaxY(labT.frame), inputBtnWH, inputBtnWH);
        [inputContentV addSubview:resultBtn];
        resultBtn.backgroundColor = [UIColor clearColor];
    }

    inputContentV.frame = CGRectMake(0, CGRectGetMaxY(topContentV.frame), XMScreenW, CGRectGetMaxY(labT.frame) + inputBtnWH * 1.5);
    
    // 3.键盘整体
    CGFloat btnWH = 75;         // 工具箱按钮宽高,根据bundle下toolBixIcons文件夹的图标确定
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
    toolMenuV.backgroundColor = [UIColor clearColor];
    
    // 添加按钮
    CGFloat btnX;
    CGFloat btnY;
    for (int i = 0; i < btnNum; i++)
    {
        btnX = toolBtnMarginX + (btnWH + toolBtnMarginX) * (i % colMaxNum);
        btnY = toolBtnMarginY + (btnWH + btnLabelH + padding) * (i / colMaxNum);
        // 工具箱按钮
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(btnX, btnY, btnWH, btnWH)];
        [toolMenuV addSubview:btn];

        if (i == 9){  // 忘记密码按钮
            [btn setTitle:@"忘记密码" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }else if (i == 11){  // 删除/指纹按钮
            self.deleBtn = btn;
            [btn setImage:[UIImage imageNamed:@"Passcode_icon_delete"] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"Passcode_icon_TouchID"] forState:UIControlStateSelected];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(deleteInput:) forControlEvents:UIControlEventTouchDown];
            btn.selected = YES;
        
        }else{
            if (i != 10){
                btn.tag = i + 1;
                [btn setTitle:[NSString stringWithFormat:@"%zd",btn.tag] forState:UIControlStateNormal];
            }else{
                [btn setTitle:@"0" forState:UIControlStateNormal];
                btn.tag = 0;
            }
            btn.layer.cornerRadius = 0.5 * btnWH;
            btn.clipsToBounds = YES;
            btn.backgroundColor = [UIColor whiteColor];
            [btn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:40];
            [btn addTarget:self action:@selector(toolButtonDidClick:) forControlEvents:UIControlEventTouchDown];
        }
        
        
    }
    
    CGFloat toolViewH = CGRectGetMaxY(toolMenuV.frame) - CGRectGetMinY(toolMenuV.frame);
    toolView.frame = CGRectMake(0, CGRectGetMaxY(inputContentV.frame), [UIScreen mainScreen].bounds.size.width, toolViewH);
}


#pragma mark - 按钮点击事件
// 点击了键盘数字按钮
- (void)toolButtonDidClick:(UIButton *)btn{
    self.deleBtn.selected = NO;
    if (self.inputIndex < 4){
        // 记录当前点击的按钮
        [self.clickBtnArr addObject:btn];
        // 显示一个按钮
        UIButton *btn = self.inputBtnArr[self.inputIndex];
        self.inputIndex += 1;
        btn.backgroundColor = [UIColor orangeColor];
        if (self.inputIndex == 4){
            NSString *password = @"";
            for (UIButton *clickBtn in self.clickBtnArr) {
                password = [password stringByAppendingString:[NSString stringWithFormat:@"%zd",clickBtn.tag]];
            }
            NSLog(@"-----%@",password);
            //此时需要验证密码,延迟执行
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if ([password isEqualToString:@"2236"]){
                    if ([self.delegate respondsToSelector:@selector(touchIDKeyboardViewAuthenSuccess)]){
                        
                        [self.delegate touchIDKeyboardViewAuthenSuccess];
                    }
                }else{
                    // 密码错误时清空选择数组,显示错误
                    [self setResultLabel:YES];
                    [self.clickBtnArr removeAllObjects];
                    self.inputIndex = 0;
                    for (UIButton *inputBtn in self.inputBtnArr) {
                        inputBtn.backgroundColor = [UIColor clearColor];
                    }
                }
            });
        }
    }
}

// '删除'按钮点击操作
- (void)deleteInput:(UIButton *)deleBtn{
    if (deleBtn.selected){
        // 当是选择状态下,跳转到指纹认证
        if ([self.delegate respondsToSelector:@selector(touchIDKeyboardViewControllerAskForTouchID)]){
            [self dismissViewControllerAnimated:YES completion:^{
                
                [self.delegate touchIDKeyboardViewControllerAskForTouchID];
            }];
        }
        
    }else{
    
        if (self.inputIndex > 0){
            // 移除最后一个点击的按钮
            [self.clickBtnArr removeLastObject];
            
            // 隐藏一个显示按钮
            //        self.resultLab.text = @"请输入密码";
            [self setResultLabel:NO];
            self.inputIndex -= 1;
            UIButton *btn = self.inputBtnArr[self.inputIndex];
            btn.backgroundColor = [UIColor clearColor];
            
            // 当全部输入清除时,显示删除按钮为指纹登录团
            if (self.inputIndex == 0) self.deleBtn.selected = YES;
        }
    
    }
}

// 右上角"取消按钮"
- (void)cancel{
    [self dismissViewControllerAnimated:YES completion:^{
        if([self.delegate respondsToSelector:@selector(touchIDKeyboardViewControllerDidDismiss)]){
            [self.delegate touchIDKeyboardViewControllerDidDismiss];
        }
    }];
}


// 根据密码结果设定标题
- (void)setResultLabel:(BOOL)result{
    // 注意:标题决定了下面的两个range需要同步调整,这里说的标题统计指"请输入密码",共5个字,当有改动时需要同步调整titleCount
    int titleCount = 5;
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"请输入密码\n密码错误"];
    // 设置第一行样式
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[NSFontAttributeName] = [UIFont systemFontOfSize:22];
    [str setAttributes:dict range:NSMakeRange(0, titleCount)];
    
    // 设置频道的样式
    NSMutableDictionary *dictChannel = [NSMutableDictionary dictionary];
    dictChannel[NSFontAttributeName] = [UIFont systemFontOfSize:15];
    if (result){
        dictChannel[NSForegroundColorAttributeName] = [UIColor orangeColor];
    }else{
        dictChannel[NSForegroundColorAttributeName] = [UIColor clearColor];
    }
    [str setAttributes:dictChannel range:NSMakeRange(titleCount + 1, 4)];
    self.resultLab.attributedText = str;
}

@end
