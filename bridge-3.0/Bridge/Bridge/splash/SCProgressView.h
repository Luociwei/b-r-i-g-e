//
//  SCProgressView.h
//  Bridge
//
//  Created by RyanGao on 2021/1/9.
//  Copyright © 2021 RyanGao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface SCProgressView : NSView

@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) CGFloat progressLineWidth;
@property (nonatomic, strong) NSColor *progressLineColor;
@property (nonatomic, assign) CGFloat backgroundLineWidth;
@property (nonatomic, strong) NSColor *backgroundLineColor;
@property (nonatomic, assign) CFTimeInterval duration;
- (void)setProgress:(CGFloat)progress;
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;
@end

NS_ASSUME_NONNULL_END
