//
//  AppDelegate.h
//  CPK_Test
//
//  Created by RyanGao on 2020/6/23.
//  Copyright © 2020 RyanGao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "StartUp.framework/Headers/StartUp.h"
#import "SCRedis.framework/Headers/RedisInterface.hpp"
#import "SCZmq.framework/Headers/Client.h"
//#import "dataTableView.h"
#import "DataItems/dataTableView.h"
//#import "dataPlotView.h"
#import "DataPlot/dataPlotView.h"
//#import "loadCsvControl.h"


@interface AppDelegate : NSObject <NSApplicationDelegate,NSWindowDelegate>
{
    
    IBOutlet NSView *tableViewDetail;
    IBOutlet NSView *plotViewDetail;
    NSViewController * tablePanel;
    NSViewController * plotPanel;
    StartUp * startPython;

}



@end

