//
//  ViewController.h
//  hiWeb
//
//  Created by Niki on 17/9/16.
//  Copyright © 2017年 excellence.com.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XMHiwebViewController : UIViewController

@property (nonatomic, assign)  NSUInteger index;
@property (nonatomic, copy) NSString *url;

@property (weak, nonatomic)  UITextField *searchV;

- (void)starRequest;

@end

