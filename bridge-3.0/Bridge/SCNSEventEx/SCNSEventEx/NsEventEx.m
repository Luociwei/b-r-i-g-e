//
//  NsEvent.m
//  MainUI
//
//  Created by RyanGao on 2020/3/2.
//  Copyright © 2020  RyanGao. All rights reserved.
//

#import "NSEventEx.h"
@implementation NSEvent(Category)
- (BOOL)isCommandDown
{
    return (self.modifierFlags & NSEventModifierFlagCommand) != 0;
}

- (BOOL)isShiftDown
{
    return (self.modifierFlags & NSEventModifierFlagShift) != 0;
}

- (BOOL)isControlDown
{
    return (self.modifierFlags & NSEventModifierFlagControl) != 0;
}

- (BOOL)isOptionDown
{
    return (self.modifierFlags & NSEventModifierFlagOption) != 0;
}

@end
