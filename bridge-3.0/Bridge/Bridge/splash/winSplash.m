//
//  winSplash.m
//  Bridge
//
//  Created by RyanGao on 2021/1/7.
//  Copyright © 2021 RyanGao. All rights reserved.
//


#import "winSplash.h"
//#import "defineHeader.h"
#import "../DataPlot/defineHeader.h"
#import "SCProgressView.h"

@interface winSplash ()
{
    NSMutableString *previousStr;
}
@property (nonatomic, strong) SCProgressView *progressView;
@end

@implementation winSplash

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

-(void)awakeFromNib
{
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnNotification:) name:kNotificationIndicatorMsg object:nil];
    
    [windowSplash setLevel:kCGFloatingWindowLevel];
    [windowSplash center];
    windowSplash.backgroundColor = [NSColor whiteColor];
    //[indicatorSplash startAnimation:nil];
    [m_scrollView setHasHorizontalScroller:YES];
    [m_scrollView setHasVerticalScroller:YES];
    [txtMsgInfo setEditable:NO];
    [windowSplash setAccessibilityFocused:YES];
    
    /*self.progressView = [[SCProgressView alloc] initWithFrame:[indicatorView bounds]];
    self.progressView.progressLineWidth = 15.0f;
    self.progressView.backgroundLineWidth = 15.0f;
    self.progressView.progressLineColor = [NSColor colorWithCalibratedRed:0.125f green:0.698f blue:0.667f alpha:1.00f];
    self.progressView.backgroundLineColor = [NSColor colorWithCalibratedRed:0.840f green:0.920f blue:1.0f alpha:0.90f];
    [self.progressView setProgress:0.0f animated:YES];
    [indicatorView addSubview:self.progressView];
    [indicatorLab setStringValue:@""];*/
    
    previousStr = [[NSMutableString alloc]init];
    
}

-(void)startTimer
{
    if( [timer isValid])
    {
        [timer invalidate];
        timer = nil;
    }
    n_dot = 0;
    if(timer == nil)
    {
        
        timer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(OnTimer:) userInfo:nil repeats:YES];
    }
}

-(void)stopTimer
{
    [timer invalidate];
    timer = nil;
}

-(void)OnTimer:(NSTimer *)timer
{
    
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationIndicatorMsg object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@".",kStartupMsg,[NSNumber numberWithInt:MSG_LEVEL_NORMAL],kStartupLevel,[NSNumber numberWithFloat:100.0+n_dot], kStartupPercentage, nil]];
    n_dot ++;
}

- (void)OnNotification:(NSNotification *)nf
{
    NSString * name = [nf name];
    if([name isEqualToString:kNotificationIndicatorMsg])
    {
        [self performSelectorOnMainThread:@selector(UpdateLog:) withObject:[nf userInfo] waitUntilDone:YES];
        [[NSRunLoop currentRunLoop]runMode:NSDefaultRunLoopMode beforeDate:[NSDate date]];
    }
}

- (void)UpdateLog:(id)sender
{
    
    NSString * str = [sender objectForKey:kStartupMsg];
    NSNumber * level = [sender objectForKey:kStartupLevel];
    float percentage = [[sender objectForKey:kStartupPercentage] floatValue];
    if(!str) return;
    NSColor * color;
    if(level)
    {
        switch ([level integerValue]) {
            case MSG_LEVEL_NORMAL:
                color = [NSColor systemBlueColor];
                break;
            case MSG_LEVEL_ERROR:
                color = [NSColor redColor];
                break;
            case MSG_LEVEL_WARNNING:
                color = [NSColor orangeColor];
                break;
            default:
                color = [NSColor blackColor];
                break;
        }
    }
    else
        color = [NSColor blackColor];
    
    /*NSDateFormatter * fmt = [[NSDateFormatter alloc]init];
    [fmt setDateFormat:@"yyyy/MM/dd HH:mm:ss.SSS : "];
    NSString * date = [NSString stringWithFormat:@"%@\t %@\r\n",[fmt stringFromDate:[NSDate date]],str];*/
    
    if (percentage>=100.0)
    {
        NSString *date;
        if(((int)percentage)%20 == 0)
        {
            date = [NSString stringWithFormat:@"%@\r\n  %@",previousStr,str];
            [txtMsgInfo setString:@""];
        }
        else
        {
            date = [NSString stringWithFormat:@" %@ ",str];
        }
        
        NSAttributedString *attStr = [[NSAttributedString alloc]initWithString:date attributes:[NSDictionary dictionaryWithObjectsAndKeys:color,NSForegroundColorAttributeName , nil]];
        [[txtMsgInfo textStorage] appendAttributedString:attStr];
        NSRange range = NSMakeRange([[txtMsgInfo textStorage] length],0);
        [txtMsgInfo scrollRangeToVisible:range];
    }
    else
    {
        NSString *date = [NSString stringWithFormat:@"\r\n  %@",str];
        [previousStr appendString:date];
        NSAttributedString *attStr = [[NSAttributedString alloc]initWithString:date attributes:[NSDictionary dictionaryWithObjectsAndKeys:color,NSForegroundColorAttributeName , nil]];
        [[txtMsgInfo textStorage] appendAttributedString:attStr];
        NSRange range = NSMakeRange([[txtMsgInfo textStorage] length],0);
        [txtMsgInfo scrollRangeToVisible:range];
        NSString *n_str = [attStr string];
        if ([n_str containsString:@"Wating Cpk & Bimodality metrics & Build Summary reports"])
        {
            [self startTimer];
        }
        if ([n_str containsString:@"Cpk & Bimodality metrics & Build Summary reports done"])
        {
            [self stopTimer];
        }
    }
     
    /*[indicatorLab setStringValue:[NSString stringWithFormat:@"%.f%@",percentage*100,@"%"]];
    [self.progressView setProgress:percentage animated:YES];*/

}
-(void)ClearLog
{
    [self.progressView setProgress:0.0f animated:NO];
    [txtMsgInfo setString:@""];
    [indicatorLab setStringValue:@""];
    [previousStr setString:@""];
    //[indicatorSplash stopAnimation:nil];
}

-(void)winClose
{
    [windowSplash close];
    NSLog(@">close splash!!!");
}

-(BOOL)shouldCloseDocument
{
    NSLog(@">shouldCloseDocument");
    return YES;
}
@end
