//
//  ZLPhotoPickerGroupViewController.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-11.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#define CELL_ROW 4
#define CELL_MARGIN 5
#define CELL_LINE_MARGIN 5


#import "ZLPhotoPickerGroupViewController.h"
#import "ZLPhotoPickerCollectionView.h"
#import "ZLPhotoPickerDatas.h"
#import "ZLPhotoPickerGroupViewController.h"
#import "ZLPhotoPickerGroup.h"
#import "ZLPhotoPickerGroupTableViewCell.h"
#import "ZLPhotoPickerAssetsViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface ZLPhotoPickerGroupViewController () <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic , weak) ZLPhotoPickerAssetsViewController *collectionVc;

@property (nonatomic , weak) UITableView *tableView;
@property (nonatomic , strong) NSArray *groups;

@end

@implementation ZLPhotoPickerGroupViewController

- (UITableView *)tableView{
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        tableView.translatesAutoresizingMaskIntoConstraints = NO;
        tableView.delegate = self;
        [self.view addSubview:tableView];
        self.tableView = tableView;
        
        // 无数据的时候取消cell之间的分割线
        self.tableView.tableFooterView = [[UIView alloc] init];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(tableView);
        
        NSString *heightVfl = @"V:|-0-[tableView]-0-|";
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:heightVfl options:0 metrics:nil views:views]];
        NSString *widthVfl = @"H:|-0-[tableView]-0-|";
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:widthVfl options:0 metrics:nil views:views]];
        
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self tableView];
    
    // 设置按钮
    [self setupButtons];
    
    // 获取图片
    [self getImgs];
}

- (void) setupButtons{
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    
    self.navigationItem.rightBarButtonItem = barItem;
    
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
    titleLab.textColor = [UIColor whiteColor];
    titleLab.font = [UIFont boldSystemFontOfSize:19];
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.text = @"选择相册";
    self.navigationItem.titleView = titleLab;
}

#pragma mark - <UITableViewDataSource>
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.groups.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ZLPhotoPickerGroupTableViewCell *cell = [ZLPhotoPickerGroupTableViewCell instanceCell];
    
    cell.group = self.groups[indexPath.row];
    
    return cell;
    
}

#pragma mark 跳转到控制器里面的内容
- (void) jump2StatusVc{
    // 如果是相册
    ZLPhotoPickerGroup *gp = nil;
    for (ZLPhotoPickerGroup *group in self.groups) {
        if (self.status == PickerViewShowStatusCameraRoll && ([group.groupName isEqualToString:@"Camera Roll"] || [group.groupName isEqualToString:@"相机胶卷"])) {
            gp = group;
            break;
        }else if (self.status == PickerViewShowStatusSavePhotos && ([group.groupName isEqualToString:@"Saved Photos"] || [group.groupName isEqualToString:@"保存相册"])){
            gp = group;
            break;
        }else if (self.status == PickerViewShowStatusPhotoStream &&  ([group.groupName isEqualToString:@"Stream"] || [group.groupName isEqualToString:@"我的照片流"])){
            gp = group;
            break;
        }
    }
    
    if (!gp) return ;
    
    ZLPhotoPickerAssetsViewController *assetsVc = [[ZLPhotoPickerAssetsViewController alloc] init];
    assetsVc.selectPickerAssets = self.selectAsstes;
    assetsVc.assetsGroup = gp;
    assetsVc.groupVc = self;
    assetsVc.minCount = self.minCount;
    [self.navigationController pushViewController:assetsVc animated:NO];
}

#pragma mark -<UITableViewDelegate>
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ZLPhotoPickerGroup *group = self.groups[indexPath.row];
    ZLPhotoPickerAssetsViewController *assetsVc = [[ZLPhotoPickerAssetsViewController alloc] init];
    assetsVc.selectPickerAssets = self.selectAsstes;
    assetsVc.groupVc = self;
    assetsVc.assetsGroup = group;
    assetsVc.minCount = self.minCount;
    [self.navigationController pushViewController:assetsVc animated:YES];
}

#pragma mark -<Images Datas>

-(void)getImgs{
    ZLPhotoPickerDatas *datas = [ZLPhotoPickerDatas defaultPicker];
    
    __weak typeof(self) weakSelf = self;
    // 获取所有的图片URLs
    [datas getAllGroupWithPhotos:^(NSArray *groups) {
        self.groups = groups;
        if (self.status) {
            [self jump2StatusVc];
        }
        
        weakSelf.tableView.dataSource = self;
        [weakSelf.tableView reloadData];
        
    }];
}


#pragma mark -<Navigation Actions>
- (void) back{
    [self dismissViewControllerAnimated:YES completion:nil];
}




@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com
