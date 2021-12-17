//
//  keynoteItemSkipSetting.h
//  Bridge
//
//  Created by RyanGao on 2020/8/8.
//  Copyright © 2020 RyanGao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "selectGroup/RyanCheckImageCell.framework/Headers/RyanCheckImageCell.h"
NS_ASSUME_NONNULL_BEGIN

@interface keynoteItemSkipSetting : NSWindowController <NSTableViewDataSource, NSTableViewDelegate, IconClickProtocol>
{
//       IBOutlet NSWindow *csvDebugWin;
//       IBOutlet NSWindow *winMain;
//       IBOutlet NSTextField *m_profilePath;
       
       //NSMutableArray *array;
       NSMutableArray *dataArray;
       NSMutableArray *expandedArray;
       NSMutableArray *expandTable;
       NSMutableArray *subNameArray;
       //NSIndexSet *tableSelection;
       bool isBlock;
       
       //for CSV
       NSMutableDictionary *dic_CSVHeader;
       NSMutableArray *array_CSV;
}
@property (strong) IBOutlet NSWindow *keynoteItemSkipWin;

@property (copy) IBOutlet NSTextField *label;
@property (strong) IBOutlet NSTableView *table;
@property (strong) IBOutlet NSButton *item2Yes;
@property (strong) IBOutlet NSButton *item2No;
- (IBAction)checkBox:(id)sender;
@property (strong) IBOutlet NSTextField *txtCPKHigh;


-(IBAction)tableToggleBlock:(id)sender;
-(void) setCheckItem:(id) data;

@end

NS_ASSUME_NONNULL_END
