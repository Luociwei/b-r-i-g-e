//
//  SCProgressView.m
//  Bridge
//
//  Created by RyanGao on 2021/1/9.
//  Copyright © 2021 RyanGao. All rights reserved.
//

#import "SCProgressView.h"
#import <QuartzCore/QuartzCore.h>

@implementation SCProgressView
{
    CGFloat _currentProgress;
    CAShapeLayer *_backgroundLineLayer;
    CAShapeLayer *_progressLineLayer;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]){
        [self setUp];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]){
        [self setUp];
    }
    return self;
}

- (void)setUp
{
    self.wantsLayer = YES;
    _currentProgress = 0.0;
    _duration = 0.4f;
    _progressLineWidth = 3.0f;
    _progressLineColor = [NSColor lightGrayColor];
    _backgroundLineWidth = 6.0f;
    _backgroundLineColor = [NSColor darkGrayColor];

    _backgroundLineLayer = [CAShapeLayer layer];
    [self.layer addSublayer:_backgroundLineLayer];
    _progressLineLayer = [CAShapeLayer layer];
    [self.layer addSublayer:_progressLineLayer];
}
#pragma mark - Exposed Methods

- (void)setProgress:(CGFloat)progress
{
    [self setProgress:progress animated:NO];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
    // Boundry correctness
    progress = MIN(progress, 1.0);
    progress = MAX(progress, 0.0);
    
    _progress = progress;
    
    CGFloat borderWidth = MAX(_progressLineWidth, _backgroundLineWidth);
    CGFloat radius = (MIN(self.bounds.size.width, self.bounds.size.height) / 2.0) - borderWidth;
    CGFloat diameter = (radius * 2.0);
    CGRect cirlceRect = CGRectMake(NSMidX(self.bounds) - radius, NSMidY(self.bounds) - radius, diameter, diameter);
    CGPathRef path = [self _createCirclePathRefForRect:cirlceRect];
    
    _backgroundLineLayer.path = path;
    _backgroundLineLayer.fillColor = [NSColor clearColor].CGColor;
    _backgroundLineLayer.strokeColor = _backgroundLineColor.CGColor;
    _backgroundLineLayer.lineWidth = _backgroundLineWidth;
    
    _progressLineLayer.path = _backgroundLineLayer.path;
    _progressLineLayer.fillColor = [NSColor clearColor].CGColor;
    _progressLineLayer.strokeColor = _progressLineColor.CGColor;
    _progressLineLayer.lineWidth = _progressLineWidth;
    
    CFTimeInterval animationDuration = (animated ? _duration : 0.0);
    [_progressLineLayer addAnimation:[self _fillAnimationWithDuration:animationDuration] forKey:@"strokeEnd"];
    _currentProgress = _progress;

    CGPathRelease(path);
}

#pragma mark - Private Methods

- (CABasicAnimation *)_fillAnimationWithDuration:(CFTimeInterval)duration
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration = duration;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeBoth;
    animation.fromValue = @(_currentProgress);
    animation.toValue = @(_progress);
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return animation;
}

- (CGPathRef)_createCirclePathRefForRect:(CGRect)rect
{
    /**
     CGPathAddEllipseInRect creates the path in an anticlockwise direction and
     the "strokeEnd" values/animation is reverted. By creating the path ourselfs we ensure
     that the direction is clockwise and the animation direction is correct.
    */
    CGFloat radius = (rect.size.width / 2);
    CGFloat minx = CGRectGetMinX(rect), midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect);
    CGFloat miny = CGRectGetMinY(rect), midy = CGRectGetMidY(rect), maxy = CGRectGetMaxY(rect);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, midx + 0.5, maxy + 0.5);
    CGPathAddArcToPoint(path, NULL, maxx + 0.5, maxy + 0.5, maxx + 0.5, midy + 0.5, radius);
    CGPathAddArcToPoint(path, NULL, maxx + 0.5, miny + 0.5, midx + 0.5, miny + 0.5, radius);
    CGPathAddArcToPoint(path, NULL, minx + 0.5, miny + 0.5, minx + 0.5, midy + 0.5, radius);
    CGPathAddArcToPoint(path, NULL, minx + 0.5, maxy + 0.5, midx + 0.5, maxy + 0.5, radius);
    CGPathCloseSubpath(path);
    return path;
}

@end
