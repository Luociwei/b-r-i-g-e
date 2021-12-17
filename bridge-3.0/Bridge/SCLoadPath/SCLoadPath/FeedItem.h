//
//  FeedItem.h
//  BDR_Tool
//
//  Created by RyanGao on 2020/7/6.
//  Copyright © 2020 RyanGao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FeedItem : NSObject
{
    
}

@property (nonatomic) int flag;
@property (nonatomic, strong) NSString *pathFile;
-(instancetype)initWithDictionary:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
