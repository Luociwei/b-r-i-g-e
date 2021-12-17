//
//  keynoteSetting.h
//  Bridge
//
//  Created by RyanGao on 2020/7/20.
//  Copyright © 2020 RyanGao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface keynoteSetting : NSWindowController
@property (strong) IBOutlet NSWindow *keynoteWin;
@property (weak) IBOutlet NSTextField *txtCPKLow;


@property (strong) IBOutlet NSButton *item_Advanced_Yes;
@property (strong) IBOutlet NSButton *item_Advanced_No;
@property (strong) IBOutlet NSButton *item_1a_Yes;
@property (strong) IBOutlet NSButton *item_1a_No;
@property (strong) IBOutlet NSButton *item_1b_Yes;
@property (strong) IBOutlet NSButton *item_1b_No;
- (IBAction)checkBox:(id)sender;

@property (strong) IBOutlet NSButton *buttonOk;

@property (weak) IBOutlet NSComboBox *m_comboSikpSummary;

@property (weak) IBOutlet NSComboBox *m_combobox;
@property (strong) IBOutlet NSComboBox *m_comReportType;


@property (strong) IBOutlet NSTextField *prjName;
@property (strong) IBOutlet NSTextField *targetBuild;


-(void)initAllCtl;


- (IBAction)btCancel:(id)sender;
- (IBAction)btOk:(id)sender;
- (IBAction)btActionDefault:(id)sender;


@end

NS_ASSUME_NONNULL_END
