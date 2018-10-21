//
//  XMToolboxModel.h
//  虾兽维度
//
//  Created by Niki on 2018/10/19.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, XMToolBoxType){
    XMToolBoxTypeClipImg,           // 裁剪图片
    XMToolBoxTypeWifiTransFiles,    // wifi传输文件
    XMToolBoxTypeTaiji,             // 易数
    XMToolBoxTypeDDD,
    XMToolBoxTypeEEE,
};

typedef NS_ENUM(NSUInteger, XMToolBoxAuthenType) {
    XMToolBoxAuthenTypeNeed,        // 需要指纹验证
    XMToolBoxAuthenTypeNone         // 不需要指纹验证
    
};

extern NSString *const touchIDKeyboardAuthenPassward;

@interface XMToolboxModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *image;
@property (nonatomic, assign) NSInteger tag;                     // 序号
@property (nonatomic, assign)  XMToolBoxType type;               // 类型
@property (nonatomic, assign)  XMToolBoxAuthenType authenType;   // 是否需要验证


+ (NSArray<XMToolboxModel *> *)toolboxModels;



@end
