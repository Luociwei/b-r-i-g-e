//
//  keynote_skip_setting.h
//  Bridge
//
//  Created by RyanGao on 2020/8/11.
//  Copyright © 2020 RyanGao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface keynote_skip_setting : NSWindowController<NSTableViewDataSource, NSTableViewDelegate>

@property (strong) IBOutlet NSWindow *skipSettingsWin;
@property (strong) IBOutlet NSTextField *txtCpkH;
@property (strong) IBOutlet NSTableView *groupTable;



@property (strong) IBOutlet NSButton *skipOneLimitYes;
@property (strong) IBOutlet NSButton *skipOneLimitNo;
@property (strong) IBOutlet NSButton *skipHTHLDYes;
@property (strong) IBOutlet NSButton *skipHTHLDNo;

- (IBAction)btActionDefault:(id)sender;

-(void)initAllCtl;

@end

NS_ASSUME_NONNULL_END
