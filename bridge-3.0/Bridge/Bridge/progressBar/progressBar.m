//
//  progressBar.m
//  Bridge
//
//  Created by vito xie on 2021/4/29.
//  Copyright © 2021 RyanGao. All rights reserved.
//

#import "progressBar.h"

#import "../DataPlot/defineHeader.h"

@interface progressBar ()

@end

@implementation progressBar

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}
- (void)awakeFromNib{
    //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnNotification:) name:kNotificationProgressMsg object:nil];
    
    [_progressWindow setLevel:kCGFloatingWindowLevel];
    [_progressWindow center];
    [_progressWindow setAccessibilityFocused:YES];
    
}

-(void)resetState:(NSString*) info withProgress:(double) fprogress withTitle:( NSString *)title{
    
    _info.stringValue = info;
    _progress.doubleValue = fprogress;
    [_progressWindow setTitle:title];
}

//- (void)OnNotification:(NSNotification *)nf
//{
//    NSString * name = [nf name];
//    if([name isEqualToString:kNotificationProgressMsg])
//    {
//        NSDictionary* info = [nf userInfo];
//        _info.stringValue = [info[@"info"] stringValue];
//        _progress.doubleValue = [info[@"progress"] doubleValue];
//    }
//}
@end
