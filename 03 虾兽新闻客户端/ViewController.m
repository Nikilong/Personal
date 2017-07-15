//
//  ViewController.m
//  03 虾兽新闻客户端
//
//  Created by admin on 17/2/27.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "ViewController.h"
#import "XMWebViewController.h"


@interface ViewController () <UITableViewDataSource,UITableViewDelegate,NSURLSessionDelegate>

@property (nonatomic, strong) NSMutableArray *urls;

@end

@implementation ViewController

-(NSMutableArray *)urls
{
    if (_urls == nil)
    {
        _urls = [NSMutableArray array];
    }
    return _urls;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self refresh];
    
}

#pragma mark - uitableview 的基本实现
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.urls.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil)
    {
        // 此处从没有被执行
        NSLog(@"build----------------newcell");
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
    }
    
    
    cell.textLabel.text = [NSString stringWithFormat:@"第%ld条新闻",indexPath.row + 1];
    cell.imageView.image = [UIImage imageNamed:@"placehoder"];
    
    return cell;
    
}

// 根据选中哪一行播放相关的新闻
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMWebViewController *webVC = [[XMWebViewController alloc] init];
    webVC.view.frame = self.view.frame;
    webVC.view.backgroundColor = [UIColor blueColor];
    webVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:webVC animated:YES completion:nil];
    
    webVC.request = [NSURLRequest requestWithURL:self.urls[indexPath.row]];
    [webVC.view addSubview:webVC.web];
    [webVC.web loadRequest:webVC.request];
}

#pragma mark - 刷新表格数据
- (IBAction)refresh
{
    // 1,创建session
    NSURLSessionConfiguration *cfg = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:cfg];
    
    // 2,创建url
    NSURL *idUrl = [NSURL URLWithString:@"http://iflow.uczzd.cn/iflow/api/v1/channel/100?app=uc-iflow&sp_gz=1&recoid=4780413596505591035&ftime=1488170672207&method=new&count=20&no_op=0&auto=0&content_ratio=0&_tm=1488170686131&sign=bTkwBf9iQB%2F%2B%2F%2BHW3ogpeRxXTASXxQkcussc021pvCbY8PhRcDeSzLbM&sc=&uc_param_str=dnnivebichfrmintcpgieiwidsudsvli&dn=20151536891-fdd83270&ni=bTkwBTRiltTM%2FB%2BoM9%2BSzKFTH%2Fw9my2pBssWYs9s4gujq%2F0%3D&ve=10.9.6.755&bi=997&fr=iphone&mi=iPhone8%2C1&nt=2&cp=isp%3A%E7%94%B5%E4%BF%A1%3Bprov%3A%E5%B9%BF%E4%B8%9C%3Bcity%3A%3Bna%3A%E4%B8%AD%E5%9B%BD%3Bcc%3ACN%3Bac%3A&ei=bTkwBcdiqTSojXfM8KyHGJdaY7Z1jg5t1b9yZ4hg%2B347oiyKCUxxdgEfSBZKXw%3D%3D&ds=bTkwBepirf3loQ6QrJ76djgUEWU26yiBFIsxt2oP%2FNcXoQ%3D%3D&ud=bTkwBQ1isdG7gH35p53uwnMKCofF7Sj45ZQil%2B8I6hf4tQ%3D%3D&sv=app&li=g9qKibW4p5yD14qJsbysy4%2Fa04ji5%2FOd7ui%2F"];
    
    // 3,创建一个下载任务，类型为NSURLSessionDataTask
    // 此处用到block，涉及到self里面用弱引用
    __weak typeof(self) vc =self;
    NSURLSessionDataTask *task = [session dataTaskWithURL:idUrl  completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
      {
          // 5,创建session网络请求结束后
          // 解析json数据
          NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
          NSArray *arr = dict[@"data"][@"items"];
          
          NSMutableArray *arrM = [NSMutableArray array];
          for (int i = 0; i < arr.count; i++)
          {
              NSString *web = [NSString stringWithFormat:@"http://m.uczzd.cn/webview/news?app=uc-iflow&aid=%@&cid=100&zzd_from=uc-iflow&uc_param_str=dndsfrvesvntnwpfgicp&recoid=3902548323263252739&rd_type=reco&sp_gz=1",dict[@"data"][@"items"][i][@"id"]];
              
              NSURL *url = [NSURL URLWithString:web];
              [arrM addObject:url];
          }
          if (vc.urls.count)
          {
              [arrM addObjectsFromArray:vc.urls];
          }
          vc.urls = arrM;
         
          
          
#warning 必须回到主线程设置参数
          // 6，回到主线程设置cell的信息
          [[NSOperationQueue mainQueue] addOperationWithBlock:^{
              [vc.tableView reloadData];
          }];
          
      }  ];
    
    // 4,开始任务（异步）
    [task resume];
}


@end

