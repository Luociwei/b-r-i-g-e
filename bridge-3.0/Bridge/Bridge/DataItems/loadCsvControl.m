//
//  loadCsvControl.m
//  BDR_Tool
//
//  Created by RyanGao on 2020/7/4.
//  Copyright © 2020 RyanGao. All rights reserved.
//

#import "loadCsvControl.h"

@interface loadCsvControl ()

@end

@implementation loadCsvControl

- (id)init
{
    if (self = [super initWithWindowNibName:[self className] owner:self]) {
        
    }
    return self;
}
- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)btnCancel:(id)sender
{
     [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseCancel];
    //[NSApp stopModalWithCode:NSModalResponseCancel];
    //[[sender window] orderOut:self];
    NSLog(@"> cancel");
}

- (IBAction)btnOK:(id)sender
{
     [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseOK];
    //[NSApp stopModalWithCode:NSModalResponseOK];
     //[[sender window] orderOut:self];
    NSLog(@"> OK");
}
@end
