//
//  FeedItem.m
//  BDR_Tool
//
//  Created by RyanGao on 2020/7/6.
//  Copyright © 2020 RyanGao. All rights reserved.
//

#import "FeedItem.h"

@implementation FeedItem

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        _pathFile = dict[@"file_path"];
        _flag = [dict[@"check"] intValue];
    }
    return self;
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"%d,%@",self.flag,self.pathFile];
}

@end
