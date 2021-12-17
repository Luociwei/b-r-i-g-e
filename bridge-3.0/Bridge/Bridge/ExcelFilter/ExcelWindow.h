//
//  ExcelWindow.h
//  Bridge
//
//  Created by macbook on 2021/3/1.
//  Copyright © 2021 RyanGao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface ExcelWindow : NSWindowController{
    
    IBOutlet NSWindow *filterWindo;
    
    __weak IBOutlet NSClipView *cipView;
    __weak IBOutlet NSScroller *vScroler;
    __weak IBOutlet NSStackView *listView;
    
}

@property NSMutableDictionary* keys;
@property NSString* identify;
-(void)reloadKeys:(NSArray*) keys withIdentify:(NSString*) identify;
@end

NS_ASSUME_NONNULL_END
