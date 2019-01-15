//
//  XMHealthTool.m
//  虾兽维度
//
//  Created by Niki on 2019/1/15.
//  Copyright © 2019年 admin. All rights reserved.
//

#import "XMHealthTool.h"
#import <HealthKit/HealthKit.h>
#import "MBProgressHUD+NK.h"

@interface XMHealthTool()

@property (nonatomic, strong) HKHealthStore *healthStore;

@end


@implementation XMHealthTool

+ (instancetype)shareHealthTool{
    static XMHealthTool *healthTool = nil;
    static dispatch_once_t xmHealthToolToken;
    dispatch_once(&xmHealthToolToken, ^{
        healthTool = [[XMHealthTool alloc] init];
        //创建healthStore实例对象
        healthTool.healthStore = [[HKHealthStore alloc] init];
    });
    return healthTool;
}

- (void)getStepCountWithCompleteBlock:(void (^)(NSString *))block{
    //获取权限
    HKObjectType *setpCount = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    NSSet *healthSet = [NSSet setWithObjects:setpCount, nil];
    
    //健康中获取权限
    [self.healthStore requestAuthorizationToShareTypes:nil readTypes:healthSet completion:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            //权限获取成功 调用获取步数的方法
            [self queryStepCountWithBlock:block];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"获取步数权限失败");
                [MBProgressHUD showFailed:@"获取步数权限失败"];
            });
        }
    }];
    
}

- (void)queryStepCountWithBlock:(void (^)(NSString *))block{
//    //查询采样信息
//    HKSampleType *sampleType = [HKQuantityType         quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
//    //NSSortDescriptors用来告诉healthStore怎么样将结果排序。
//    NSSortDescriptor *start = [NSSortDescriptor   sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:NO];
//    NSSortDescriptor *end = [NSSortDescriptor   sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];
//    HKSampleQuery *collectionQuery = [[HKSampleQuery alloc]initWithSampleType:sampleType predicate:nil limit:1 sortDescriptors:@[start,end] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
//        NSLog(@"resultCount = %ld result = %@",results.count,results);
//        if(results.count > 0){
//            //把结果转换成字符串类型
//            HKQuantitySample *result = results[0];
//            HKQuantity *quantity = result.quantity;
//            NSString *stepStr = [[NSString stringWithFormat:@"👣%@",quantity] stringByReplacingOccurrencesOfString:@" count" withString:@""];
//            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                NSLog(@"获取今天到现在为止的步数 %@",stepStr);
//                block(stepStr);
//            }];
//         }
//    }];
    
    
    HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.day = 1;
    HKStatisticsCollectionQuery *collectionQuery = [[HKStatisticsCollectionQuery alloc] initWithQuantityType:quantityType quantitySamplePredicate:nil options: HKStatisticsOptionCumulativeSum | HKStatisticsOptionSeparateBySource anchorDate:[NSDate dateWithTimeIntervalSince1970:0] intervalComponents:dateComponents];
    collectionQuery.initialResultsHandler = ^(HKStatisticsCollectionQuery *query, HKStatisticsCollection * __nullable result, NSError * __nullable error) {
        // result.statistics 是所有天数的数据
        if(result.statistics.count > 0){
            HKStatistics *statistic  = result.statistics.lastObject;
            for (HKSource *source in statistic.sources) {
                if ([source.name isEqualToString:[UIDevice currentDevice].name]) {
                    float stepDou = [[statistic sumQuantityForSource:source] doubleValueForUnit:[HKUnit countUnit]];
                    NSString *stepStr = [NSString stringWithFormat:@"👣 %.0f",stepDou];
                    block(stepStr);
                }
            }
        }
    };
    //执行查询
    [self.healthStore executeQuery:collectionQuery];
}

@end
