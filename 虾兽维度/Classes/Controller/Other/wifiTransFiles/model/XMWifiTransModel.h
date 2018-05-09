//
//  XMWifiTransModel.h
//  虾兽维度
//
//  Created by Niki on 18/5/6.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMWifiTransModel : NSObject

@property (nonatomic, copy) NSString *fileName;     // 文件名称,带格式后缀,如111.png
@property (nonatomic, assign) double size;          // 文件大小,单位M
@property (nonatomic, copy) NSString *fullPath;     // 全路径(root + '/' + fileName)
@property (nonatomic, copy) NSString *rootPath;     // 根路径

@end
