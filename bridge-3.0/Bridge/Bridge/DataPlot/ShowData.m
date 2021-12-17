//
//  ShowData.m
//  Bridge
//
//  Created by RyanGao on 2020/8/7.
//  Copyright © 2020 RyanGao. All rights reserved.
//

#import "ShowData.h"

@implementation ShowData

+(NSMutableArray *)getShowDataList
{
    NSMutableArray *dataArray = [[NSMutableArray alloc] initWithCapacity: 100];
    showDataValue *val1 = [[showDataValue alloc] init];
    val1.sn = @"11111";
    val1.vale = @"eeeee";
    showDataValue *val2 = [[showDataValue alloc] init];
    val2.sn = @"2222";
    val2.vale = @"bbbbb";
    [dataArray addObject:val1];
    [dataArray addObject:val2];
    return dataArray;
}

@end
