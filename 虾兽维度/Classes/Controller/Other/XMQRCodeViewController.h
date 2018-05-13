//
//  XMQRCodeViewController.h
//  虾兽维度
//
//  Created by Niki on 17/6/25.
//  Copyright © 2017年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMOpenWebmoduleProtocol.h"

@interface XMQRCodeViewController : UIViewController

@property (weak, nonatomic)  id<XMOpenWebmoduleProtocol> delegate;

@end
