//
//  ZRRImageClipView.m
//  Bridge
//
//  Created by RyanGao on 2020/10/1.
//  Copyright © 2020 RyanGao. All rights reserved.
//

#import "ZRRImageClipView.h"


@implementation ZRRImageClipView

//- (void)drawRect:(NSRect)dirtyRect
//{
//    [super drawRect:dirtyRect];
//
//    // Drawing code here.
//}

-(void)centerDocument {
    NSRect docRect = [[self documentView] frame];
    NSRect clipRect = [self bounds];

    if( docRect.size.width < clipRect.size.width )
        clipRect.origin.x = roundf( ( docRect.size.width - clipRect.size.width ) / 2.0 );

    if( docRect.size.height < clipRect.size.height )
        clipRect.origin.y = roundf( ( docRect.size.height - clipRect.size.height ) / 2.0 );
    [self scrollToPoint:clipRect.origin];
}

- (NSPoint)constrainScrollPoint:(NSPoint)proposedNewOrigin
{
    NSRect docRect = [[self documentView] frame];
    NSRect clipRect = [self bounds];
    NSPoint newScrollPoint = proposedNewOrigin;
    float maxX = docRect.size.width - clipRect.size.width;
    float maxY = docRect.size.height - clipRect.size.height;
    if( docRect.size.width < clipRect.size.width )
        newScrollPoint.x = roundf( maxX / 2.0 );
    else
        newScrollPoint.x = roundf( MAX(0,MIN(newScrollPoint.x,maxX)) );
    if( docRect.size.height < clipRect.size.height )
        newScrollPoint.y = roundf( maxY / 2.0 );
    else
        newScrollPoint.y = roundf( MAX(0,MIN(newScrollPoint.y,maxY)) );

    return newScrollPoint;
}

-(void)viewBoundsChanged:(NSNotification *)notification {
    [super viewBoundsChanged:notification];
    [self centerDocument];
}

-(void)viewFrameChanged:(NSNotification *)notification {
    [super viewFrameChanged:notification];
    [self centerDocument];
}

- (void)setFrame:(NSRect)frameRect {
    [super setFrame:frameRect];
    [self centerDocument];
}

- (void)setFrameOrigin:(NSPoint)newOrigin {
    [super setFrameOrigin:newOrigin];
    [self centerDocument];
}

- (void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    [self centerDocument];
}

- (void)setFrameRotation:(CGFloat)angle {
    [super setFrameRotation:angle];
    [self centerDocument];
}

@end
