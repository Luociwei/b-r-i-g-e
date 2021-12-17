//
//  Feed.h
//  BDR_Tool
//
//  Created by RyanGao on 2020/7/6.
//  Copyright © 2020 RyanGao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeedItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface Feed : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableArray<FeedItem *> *children;

- (instancetype)initWithName:(NSString *)name;
+ (NSMutableArray<Feed *> *)pathList:(NSString *)fileName;

+ (int)readLocalDataFlag:(NSString *)fileName;
+ (void)writeLocalDataFlag:(NSString *)fileName withFlag:(int) flag;
+ (int)readInsightlDataFlag:(NSString *)fileName;

+ (void)addToPathWrite:(NSString *)fileName withAddPath:(NSString *)addPath with:(int)flag;
+ (void)addToItemClick:(NSString *)fileName withLine:(int)line ItemClick:(int)state with:(int)flag;
+ (void)addToClearItemClick:(NSString *)fileName;
+ (int)readInsightItemCheckBox:(NSString *)fileName;


+ (void)addLocalToPathWrite:(NSString *)fileName withAddPath:(NSString *)addPath with:(int)flag;
+ (void)addLocalToItemClick:(NSString *)fileName withLine:(int)line ItemClick:(int)state with:(int)flag;
+ (void)addLocalToClearItemClick:(NSString *)fileName;
+ (int)readLocalItemCheckBox:(NSString *)fileName;

@end

NS_ASSUME_NONNULL_END
