//
//  CommonHeader.h
//  虾兽维度
//
//  Created by Niki on 18/3/5.
//  Copyright © 2018年 admin. All rights reserved.
//

#ifndef CommonHeader_h
#define CommonHeader_h

// 左侧边栏
#define XMLeftViewTotalW 200
#define XMLeftViewPadding 10

// 屏幕尺寸
#define XMScreenW [UIScreen mainScreen].bounds.size.width
#define XMScreenH [UIScreen mainScreen].bounds.size.height

// app的documents路径
#define XMHomeDirectory NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0]

// hiweb主页路径
#define XMHiwebHomeUrlPath [XMHomeDirectory stringByAppendingPathComponent:@"hiweb.homeurl"]

// wifi传输的保存沙盒路径
#define XMWifiUploadDirPath  [NSString stringWithFormat:@"%@/WifiTransPort",XMHomeDirectory]


#endif /* CommonHeader_h */
