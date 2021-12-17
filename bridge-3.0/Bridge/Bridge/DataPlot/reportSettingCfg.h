//
//  reportSettingCfg.h
//  BDR_Tool
//
//  Created by RyanGao on 2020/7/5.
//  Copyright © 2020 RyanGao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface reportSettingCfg : NSWindowController

@property (strong) IBOutlet NSWindow *settingCfgWin;
@property (weak) IBOutlet NSButton *buttonOK;
@property (weak) IBOutlet NSButton *populate;
@property (weak) IBOutlet NSButton *p_val_Check;

@property (weak) IBOutlet NSButton *exportAllItems;
@property (weak) IBOutlet NSButton *exportAllItemsOutOf;
@property (weak) IBOutlet NSTextField *lowTH;
@property (weak) IBOutlet NSTextField *highTH;
@property (weak) IBOutlet NSTextField *userName;
@property (weak) IBOutlet NSTextField *projectName;
@property (weak) IBOutlet NSTextField *TargetBuild;
- (IBAction)clickAllItems:(id)sender;
- (IBAction)clickAllItemsOutOf:(id)sender;
- (IBAction)clickPopulate:(id)sender;
- (IBAction)click_p_val:(id)sender;
@property (weak) IBOutlet NSButton *onlyLimitUpdated;
- (IBAction)ClickOnlyLimitUpdate:(id)sender;



@property (strong) IBOutlet NSButton *push2Git;
@property (strong) IBOutlet NSTextField *gitAddress;
@property (strong) IBOutlet NSTextField *gitComment;
- (IBAction)clickPush2Git:(id)sender;
@property (strong) IBOutlet NSButton *btDefault;

- (IBAction)btActionDefault:(id)sender;


@end

NS_ASSUME_NONNULL_END
