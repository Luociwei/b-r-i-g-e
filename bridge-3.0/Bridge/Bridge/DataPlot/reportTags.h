//
//  reportTags.h
//  Bridge
//
//  Created by RyanGao on 2020/11/5.
//  Copyright © 2020 RyanGao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface reportTags : NSWindowController<NSTableViewDataSource, NSTableViewDelegate>
@property (strong) IBOutlet NSWindow *reportTagsWindow;
- (IBAction)btExportExcel:(id)sender;
- (IBAction)btCancel:(id)sender;
@property (weak) IBOutlet NSTableView *groupTable;
@property (weak) IBOutlet NSTextField *labelDataSource;
@property (weak) IBOutlet NSTextField *labelTestPlanFile;

@end

NS_ASSUME_NONNULL_END
