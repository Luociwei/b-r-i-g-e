//
//  SCMouseFunction.m
//  Bridge
//
//  Created by RyanGao on 2020/12/16.
//  Copyright © 2020 RyanGao. All rights reserved.
//

#import "SCMouseFunction.h"
//#import "defineHeader.h"
#import "../DataPlot/defineHeader.h"

@implementation SCMouseFunction

-(instancetype)initWithID:(NSString *)myId
{
    self = [super init];
    if(self)
    {
        mouse_id = [[NSString alloc] initWithString:myId];
        b_status_enter = NO;
        b_status_exit = NO;
        [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(OnTimer:) userInfo:nil repeats:YES];

    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    //[super drawRect:dirtyRect];
    
    //[[NSColor greenColor] set];
    //NSRectFill([self bounds]);
    // Drawing code here.
}

-(void)updateTrackingAreas
{
    if(trackingArea != nil)
    {
        [self removeTrackingArea:trackingArea];
        
    }
    
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways );//| NSTrackingMouseMoved
    trackingArea = [ [NSTrackingArea alloc] initWithRect:[self bounds]
                                            options:opts
                                            owner:self
                                            userInfo:nil];
    [self addTrackingArea:trackingArea];
}

-(void)OnTimer:(NSTimer *)timer
{
    double now = [[NSDate date]timeIntervalSince1970];
    if (b_status_enter)
    {
        if ((now-start_time)>=0.98)
        {
            b_status_enter = NO;
            b_status_exit = NO;
            float x = 0;
            float y = 0;
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:x],ktbHeaderX,[NSNumber numberWithFloat:y],ktbHeaderY, mouse_id,ktbHeaderID,nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationMouseEnter object:nil userInfo:dic];
        }
    }
    if (b_status_exit)
    {
        if ((now-start_time)>=0.3)
        {
            start_time = [[NSDate date]timeIntervalSince1970];
            
            b_status_enter = NO;
            b_status_exit = NO;
            float x = 0;
            float y = 0;
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:x],ktbHeaderX,[NSNumber numberWithFloat:y],ktbHeaderY, mouse_id,ktbHeaderID,nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationMouseExit object:nil userInfo:dic];
            
        }
    }
    
    
}
-(void)mouseEntered:(NSEvent *)theEvent
{

    b_status_enter = YES;
    b_status_exit = NO;
    start_time = [[NSDate date]timeIntervalSince1970];
    
}

-(void)mouseExited:(NSEvent *)theEvent
{
    
    b_status_enter = NO;
    b_status_exit = YES;
    
}



@end
