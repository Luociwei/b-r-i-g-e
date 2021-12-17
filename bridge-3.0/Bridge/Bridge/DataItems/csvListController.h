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


@interface csvListController : NSViewController<NSApplicationDelegate,NSOutlineViewDelegate,NSOutlineViewDataSource>
{
    NSMutableDictionary * m_dic;
}
@property (strong) IBOutlet NSOutlineView *outlineView;
@property (nonatomic, strong) NSMutableArray<Feed *> *feeds;
@property (nonatomic, strong) NSMutableArray<Feed *> *feedsLocal;


@property (strong) IBOutlet NSOutlineView *outlineViewLocal;
@property (weak) IBOutlet NSButton *browesButton;


@property (weak) IBOutlet NSButtonCell *browes;

@property (weak) IBOutlet NSTextField *cpk_lthl;
@property (weak) IBOutlet NSTextField *cpk_hthl;
- (IBAction)txtCpkLthl:(id)sender;
- (IBAction)txtCpkHthl:(id)sender;

- (IBAction)btLoadScript:(id)sender;
- (IBAction)btClear:(id)sender;


@end

NS_ASSUME_NONNULL_END
