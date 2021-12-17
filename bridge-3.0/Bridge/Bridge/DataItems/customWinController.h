//
//  customWinController.h
//  tableViewDemo2
//
//  Created by RyanGao on 2020/12/27.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface customWinController : NSWindowController<NSTableViewDataSource, NSTableViewDelegate>

@property NSMutableArray *data;
@property long maxColumnNumber;
@property long maxRowNumber;
@property long testItemnameRowNumber;
@property (strong) IBOutlet NSTableView *tableView;
@property (strong) IBOutlet NSWindow *mainWin;


@property (strong) IBOutlet NSTextField *txtStartRow;

@property (strong) IBOutlet NSTextField *txtPassFailStatusCol;
@property (strong) IBOutlet NSTextField *labPassFailStatusCol;

@property (strong) IBOutlet NSTextField *txtSerialNumberCol;
@property (strong) IBOutlet NSTextField *labSerialNumberCol;

@property (strong) IBOutlet NSTextField *txtStartTimeCol;
@property (strong) IBOutlet NSTextField *labStartTimeCol;

@property (strong) IBOutlet NSTextField *txtProductCol;
@property (strong) IBOutlet NSTextField *labProductCol;

@property (strong) IBOutlet NSTextField *txtStationIDCol;
@property (strong) IBOutlet NSTextField *labStationIdCol;

@property (strong) IBOutlet NSTextField *txtStartItemCol;
@property (strong) IBOutlet NSTextField *labStartItemCol;

@property (strong) IBOutlet NSTextField *txtUpperRow;
@property (strong) IBOutlet NSTextField *txtLowerRow;
@property (strong) IBOutlet NSTextField *txtUnitRow;
@property (strong) IBOutlet NSTextField *txtDataStartRow;

@property (strong) IBOutlet NSTextField *txtVersionCol;
@property (strong) IBOutlet NSTextField *labVersionCol;

@property (strong) IBOutlet NSTextField *txtListOfFailCol;
@property (strong) IBOutlet NSTextField *labListOfFailCol;

@property (strong) IBOutlet NSTextField *txtSlotIdCol;
@property (strong) IBOutlet NSTextField *labSlotIdCol;



- (IBAction)txtActionCheck:(id)sender;

@property (strong) IBOutlet NSButton *btnOK;

@end

NS_ASSUME_NONNULL_END
