//
//  progressBar.h
//  Bridge
//
//  Created by vito xie on 2021/4/29.
//  Copyright © 2021 RyanGao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface progressBar : NSWindowController
@property (strong) IBOutlet NSWindow *progressWindow;
@property (weak) IBOutlet NSProgressIndicator *progress;
@property (weak) IBOutlet NSTextField *info;
-(void)resetState:(NSString*) info withProgress:(double) fprogress withTitle:(NSString*) title;
@end

NS_ASSUME_NONNULL_END
