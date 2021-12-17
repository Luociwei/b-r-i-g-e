//
//  SCMouseFunction.h
//  Bridge
//
//  Created by RyanGao on 2020/12/16.
//  Copyright © 2020 RyanGao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface SCMouseFunction : NSView
{
    NSTrackingArea * trackingArea;
    NSString *mouse_id;
    BOOL b_status_enter;
    BOOL b_status_exit;
    double start_time;
}
-(instancetype)initWithID:(NSString *)myId;

@end

NS_ASSUME_NONNULL_END
