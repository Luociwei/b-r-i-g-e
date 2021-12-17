//
//  csvListController.h
//  BDR_Tool
//
//  Created by RyanGao on 2020/7/5.
//  Copyright © 2020 RyanGao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SCLoadPath.framework/Headers/Feed.h"

NS_ASSUME_NONNULL_BEGIN


@interface listController : NSViewController<NSApplicationDelegate,NSOutlineViewDelegate,NSOutlineViewDataSource>
{
 
}
@property (strong) IBOutlet NSOutlineView *outlineView;
@property (nonatomic, strong) NSMutableArray<Feed *> *feeds;


@property (weak) IBOutlet NSButton *browesButton;
@property (weak) IBOutlet NSButtonCell *browes;


- (IBAction)btLoadScript:(id)sender;
- (IBAction)btClear:(id)sender;


@end

NS_ASSUME_NONNULL_END
