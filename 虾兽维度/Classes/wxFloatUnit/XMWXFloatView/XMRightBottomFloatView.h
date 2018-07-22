//
//  XMRightBottomFloatView.h
//  虾兽维度
//
//  Created by Niki on 2018/7/17.
//  Copyright © 2018年 admin. All rights reserved.
//

/**
    该文件是在右下角创建一个扇形区域,来提供添加/删除悬浮窗口
 */

#import <UIKit/UIKit.h>

typedef void(^XMRightBottomStartBlock)(BOOL);
typedef void(^XMRightBottomEndBlock)();
typedef void(^XMRightBottomCancelOrFailBlock)();
typedef void(^XMRightBottomChangeBlock)(CGPoint);

@interface XMRightBottomFloatView : UIView

+ (XMRightBottomFloatView *)shareRightBottomFloatView;

// 触发模式,是增加还是取消
@property (nonatomic, assign)  BOOL addMode;
// 是否进入扇形区域
@property (nonatomic, assign)  BOOL isInArea;


@property (nonatomic, copy)XMRightBottomStartBlock rightBottomStartBlock;
@property (nonatomic, copy)XMRightBottomChangeBlock rightBottomChangeBlock;
@property (nonatomic, copy)XMRightBottomEndBlock rightBottomEndBlock;
@property (nonatomic, copy)XMRightBottomCancelOrFailBlock rightBottomCancelOrFailBlock;

@end
