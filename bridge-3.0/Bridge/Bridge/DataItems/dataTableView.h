//
//  dataTableView.h
//  CPK_Test
//
//  Created by RyanGao on 2020/6/25.
//  Copyright © 2020 RyanGao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "csvListController.h"
#import "StartUp.framework/Headers/StartUp.h"

NS_ASSUME_NONNULL_BEGIN

@interface dataTableView : NSViewController<NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate,NSSplitViewDelegate>
{
    csvListController *csvView;
    IBOutlet NSView *csvViewMain;
    IBOutlet NSView *leftViewMain;
    StartUp * startPython;
}
@property (strong) IBOutlet NSView *viewWindow;
- (IBAction)btLoadCsvData:(id)sender;
- (IBAction)btnSearchCsv:(id)sender;


@property (weak) IBOutlet NSView *leftPane;
@property (weak) IBOutlet NSView *rightPanel;
@property (weak) IBOutlet NSSplitView *splitView;

@property (weak) IBOutlet NSTextField *txtTestCount;
@property (weak) IBOutlet NSTextField *txtPass;

@property (weak) IBOutlet NSTextField *txtFail;
@property (weak) IBOutlet NSTextField *txtYieldP;

@property (weak) IBOutlet NSTextField *txtRetestR;
@property (weak) IBOutlet NSTextField *txtRetestC;

@property (weak) IBOutlet NSTableCellView *itemCellView;
@property (weak) IBOutlet NSTextField *txtTotalC;

@property (strong) IBOutlet NSSearchField *txtSearch;
@property (strong) IBOutlet NSTableHeaderView *tbViewHeader;

@end

NS_ASSUME_NONNULL_END
