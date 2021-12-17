//
//  winSplash.h
//  Bridge
//
//  Created by RyanGao on 2021/1/7.
//  Copyright © 2021 RyanGao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface winSplash : NSWindowController
{
    IBOutlet NSTextView *txtMsgInfo;
    IBOutlet NSWindow *windowSplash;
    IBOutlet NSProgressIndicator *indicatorSplash;
    IBOutlet NSScrollView *m_scrollView;
    
    IBOutlet NSView *indicatorView;
    IBOutlet NSTextField *indicatorLab;
    NSTimer * timer;
    int n_dot;
}

-(void)ClearLog;
-(void)winClose;

@end

NS_ASSUME_NONNULL_END
