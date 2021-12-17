//
//  vtTable.h
//  Bridge
//
//  Created by vito xie on 2021/6/4.
//  Copyright © 2021 RyanGao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface vtTable : NSScrollView<NSDraggingDestination>
-(void)isProfile:(bool)flag;
@end

NS_ASSUME_NONNULL_END
