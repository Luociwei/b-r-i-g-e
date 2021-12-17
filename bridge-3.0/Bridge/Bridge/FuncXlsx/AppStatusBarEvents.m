//
//  AppStatusBarEvents.m
//
//  Created by RyanGao on 2020/6/25.
//  Copyright © 2020 RyanGao. All rights reserved.

#import "AppStatusBarEvents.h"
#import "AppUtils.h"

@implementation AppStatusBarEvents

+ (void)help {
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    
    NSString *title = [NSString stringWithFormat:@"Technical Support"];
    NSString *message = [NSString stringWithFormat:@"@Author: %@", infoDict[@"Author"]];
    message = [message stringByAppendingString:@"\n"];
    message = [message stringByAppendingFormat:@"@Email: %@", infoDict[@"Email"]];
    
    [AppUtils showAlert:nil style:NSWarningAlertStyle title:title message:message buttonTitles:@[@"OK"] completionHandler:nil];
}

@end
