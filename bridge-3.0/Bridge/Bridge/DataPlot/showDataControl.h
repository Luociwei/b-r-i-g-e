//
//  showDataControl.h
//  Bridge
//
//  Created by RyanGao on 2020/8/7.
//  Copyright © 2020 RyanGao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface showDataControl : NSWindowController<NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate>
@property (weak) IBOutlet NSSearchFieldCell *searchField;
@property (strong) IBOutlet NSWindow *showDataWin;
- (IBAction)btOk:(id)sender;

@end

NS_ASSUME_NONNULL_END
