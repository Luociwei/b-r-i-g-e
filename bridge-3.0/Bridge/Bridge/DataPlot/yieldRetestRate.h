//
//  yieldRetestRate.h
//  Bridge
//
//  Created by RyanGao on 2020/7/31.
//  Copyright © 2020 RyanGao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface yieldRetestRate : NSWindowController<NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate>
@property (strong) IBOutlet NSWindow *yieldWin;
- (IBAction)btOK:(id)sender;
@property (strong) IBOutlet NSView *imageShowView;


@property (strong) IBOutlet NSView *showImage1;
@property (strong) IBOutlet NSView *showImage2;
@property (strong) IBOutlet NSView *showImage3;
@property (strong) IBOutlet NSView *showImage4;
@property (strong) IBOutlet NSView *showImage5;
@property (strong) IBOutlet NSView *showImage6;
@property (strong) IBOutlet NSView *showImage7;

@property (strong) IBOutlet NSImageView *imagePng1;
@property (strong) IBOutlet NSImageView *imagePng2;
@property (strong) IBOutlet NSImageView *imagePng3;
@property (strong) IBOutlet NSImageView *imagePng4;
@property (strong) IBOutlet NSImageView *imagePng5;
@property (strong) IBOutlet NSImageView *imagePng6;
@property (strong) IBOutlet NSImageView *imagePng7;

@property (strong) IBOutlet NSButton *btnCopy1;
@property (strong) IBOutlet NSButton *btnCopy2;
@property (strong) IBOutlet NSButton *btnCopy3;
@property (strong) IBOutlet NSButton *btnCopy4;
@property (strong) IBOutlet NSButton *btnCopy5;
@property (strong) IBOutlet NSButton *btnCopy6;
@property (strong) IBOutlet NSButton *btnCopy7;

- (IBAction)clickActionCopy1:(id)sender;
- (IBAction)clickActionCopy2:(id)sender;
- (IBAction)clickActionCopy3:(id)sender;
- (IBAction)clickActionCopy4:(id)sender;
- (IBAction)clickActionCopy5:(id)sender;
- (IBAction)clickActionCopy6:(id)sender;
- (IBAction)clickActionCopy7:(id)sender;


@end

NS_ASSUME_NONNULL_END
