//
//  testPlanSource.h
//  Bridge
//
//  Created by vito xie on 2021/5/22.
//  Copyright © 2021 RyanGao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface testPlanSource : NSView<NSDraggingDestination>
-(void)isProfile:(bool)flag;

@end

NS_ASSUME_NONNULL_END
