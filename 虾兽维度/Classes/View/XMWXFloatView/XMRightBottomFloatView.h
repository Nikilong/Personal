//
//  XMRightBottomFloatView.h
//  虾兽维度
//
//  Created by Niki on 2018/7/17.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^XMRightBottomStartBlock)(BOOL);
typedef void(^XMRightBottomEndBlock)();
typedef void(^XMRightBottomChangeBlock)(CGPoint);

@interface XMRightBottomFloatView : UIView

+ (XMRightBottomFloatView *)shareRightBottomFloatView;

// 触发模式,是增加还是取消
@property (nonatomic, assign)  BOOL addMode;

@property (nonatomic, copy)XMRightBottomStartBlock rightBottomStartBlock;
@property (nonatomic, copy)XMRightBottomChangeBlock rightBottomChangeBlock;
@property (nonatomic, copy)XMRightBottomEndBlock rightBottomEndBlock;

@end
