//
//  NsEvent.h
//  MainUI
//
//  Created by RyanGao on 2020/3/2.
//  Copyright © 2020 ___ RyanGao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
NS_ASSUME_NONNULL_BEGIN
@interface NSEvent (Category)

- (BOOL)isCommandDown;
- (BOOL)isShiftDown;
- (BOOL)isControlDown;
- (BOOL)isOptionDown;

@end

NS_ASSUME_NONNULL_END
