//
//  selectGroupViewControl.h
//  NSTableViewRyan
//
//  Created by RyanGao on 2019/6/5.
//  Copyright © 2019 RyanGao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <RyanCheckImageCell/RyanCheckImageCell.h>

NS_ASSUME_NONNULL_BEGIN

@interface selectGroupViewControl : NSViewController<NSTableViewDataSource, NSTableViewDelegate, IconClickProtocol>
{
    
    
    IBOutlet NSWindow *csvDebugWin;
    IBOutlet NSWindow *winMain;
    IBOutlet NSTextField *m_profilePath;
    
    //NSMutableArray *array;
    NSMutableArray *dataArray;
    NSMutableArray *expandedArray;
    NSMutableArray *expandTable;
    NSMutableArray *subNameArray;
    //NSIndexSet *tableSelection;
    bool isBlock;
    
    //for CSV
    NSMutableDictionary *dic_CSVHeader;
    NSMutableString *array_CSV;
}
@property (copy) IBOutlet NSTextField *label;
@property (strong) IBOutlet NSTableView *table;


-(IBAction)tableToggleBlock:(id)sender;
-(void) setCheckItem:(id) data;

@end


NS_ASSUME_NONNULL_END
