//
//  AppDelegate.m
//  CPK_Test
//
//  Created by RyanGao on 2020/6/23.
//  Copyright © 2020 RyanGao. All rights reserved.
//

#import "AppDelegate.h"
//#import "defineHeader.h"
#import "DataPlot/defineHeader.h"
//#import "winSplash.h"
#import "splash/winSplash.h"
#import "ExcelFilter/ExcelWindow.h"
#import "progressBar/progressBar.h"
Client *boxClient;
Client *cpkClient;
Client *correlationClient;
Client *reportHashClient;          //excel
Client *copyImageClient;   //
Client *scatterClient;   //
//Client *retestPlotClient;
//Client *calculateClient;   save memory
//Client *reportKeynoteClient;  //keynote
//Client *retestRateClient;  //

RedisInterface *myRedis;

#import "LimitMerger/limitMerger.hpp"

#import "Login.h"
#import "cAtlas2Funcs.h"
#import "cAtlas2Timer.h"
#import "cAtlas2DiagsParse.h"
@interface AppDelegate ()
{
    winSplash *splash;
    ExcelWindow * excelFilter;
    progressBar * proBar;
    limitMerger * limitM;
    Login* login;
}
@property (weak) IBOutlet NSWindow *window;

@property(strong) cAtlas2Funcs  * atlas2;
@property(strong) cAtlas2Timer  * atlas2Timer;
@property(strong) cAtlas2DiagsParse  * atlas2Diags;
@end

@implementation AppDelegate

- (IBAction)showLimitMerge:(id)sender {
    bool isLogin = [login isLogin];
    
    if(isLogin){
        [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationLimitMergerShowUp object:nil userInfo:nil];
    }
    else{
        

        [login setNextShowMessage:kNotificationLimitMergerShowUp];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationLoginShowUp object:nil userInfo:nil];
    }
    
}

- (IBAction)showTimer:(id)sender {
    [_atlas2Timer reset];
    NSModalResponse result = [NSApp runModalForWindow:_atlas2Timer.window];
}

- (IBAction)showAtlas2Legacy:(id)sender {
    [_atlas2 reset];
    NSModalResponse result = [NSApp runModalForWindow:_atlas2.window];
}
- (IBAction)showDiagsExtrator:(id)sender {
    
    [_atlas2Diags reset];
    NSModalResponse result = [NSApp runModalForWindow:_atlas2Diags.window];
}


-(instancetype)init
{
    self = [super init];
    if (self)
    {
        
        
        NSString *userDocuments = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
      
        NSString *modulePath = [NSString stringWithFormat:@"%@/.errormodule.txt",userDocuments];
        NSFileManager *fileManager = [NSFileManager defaultManager];

        if ([fileManager removeItemAtPath:modulePath error:NULL])
        {
            NSLog(@"Removed errormodule.txt successfully");
        }
        startPython = [[StartUp alloc] init];
        [startPython OpenRedisServer];  // redis server launch
        
        [startPython Lanuch_cpk];   // python cpk
        [startPython Lanuch_correlation];  // python
        [startPython Lanuch_hash_report];   // hash report
        
        [startPython Lanuch_extra_func];
        [startPython Lanuch_scatter];
        
        
        [startPython Lanuch_box];   // python cpk
        
        
        boxClient = [[Client alloc] init];   // connect CPK zmq for cpk_test.py
        [boxClient CreateRPC:box_zmq_addr withSubscriber:nil];
        [boxClient setTimeout:20*1000];
        
        cpkClient = [[Client alloc] init];   // connect CPK zmq for cpk_test.py
        [cpkClient CreateRPC:cpk_zmq_addr withSubscriber:nil];
        [cpkClient setTimeout:20*1000];
        
        correlationClient = [[Client alloc] init];   // connect Correlation zmq for correlation_test.py
        [correlationClient CreateRPC:correlation_zmq_addr withSubscriber:nil];
        [correlationClient setTimeout:20*1000];
        
        reportHashClient = [[Client alloc] init];   // connect excel
        [reportHashClient CreateRPC:hash_zmq_addr withSubscriber:nil];
        [reportHashClient setTimeout:20*1000];
        
        copyImageClient = [[Client alloc] init];   //
        [copyImageClient CreateRPC:copy_image_zmq_addr withSubscriber:nil];
        [copyImageClient setTimeout:20*1000];
        
        scatterClient = [[Client alloc] init];   //
        [scatterClient CreateRPC:scatter_zmq_addr withSubscriber:nil];
        [scatterClient setTimeout:20*1000];
        
        
        myRedis = new RedisInterface();  // redis client connect
        myRedis->Connect();
        myRedis->SetString("dummy", "just for test");
        
    }
    return self;
}

-(void)awakeFromNib
{
    [self.window center];
    tablePanel = [[dataTableView alloc]init];
    [self setTableDetailView:tablePanel.view];
    
    plotPanel = [[dataPlotView alloc]init];
    [self setPlotDetailView:plotPanel.view];
    
    
    [self setWindow:self.window];
    
    self.window.delegate = self;
   // [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(wsNotificationHook:) name:NSWorkspaceDidActivateApplicationNotification object:nil];
}




-(void)setTableDetailView:(NSView *)view
{
    [self replaceView:tableViewDetail with:view];
    tableViewDetail =view;
}

-(void)setPlotDetailView:(NSView *)view
{
    [self replaceView:plotViewDetail with:view];
    plotViewDetail = view;
}

-(void)replaceView:(NSView *)oldView with:(NSView *)newView
{
    [newView setFrame:[oldView frame]];
    [[oldView superview] addSubview:newView];
    [[oldView superview] replaceSubview:oldView with:newView];
    [oldView setHidden:YES];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
//    self.csvController = [[loadCsvControl alloc] initWithWindowNibName:@"loadCsvControl"];
//    [self.csvController showWindow:self];
    NSDictionary *systemVersionDictionary =
        [NSDictionary dictionaryWithContentsOfFile:
            @"/System/Library/CoreServices/SystemVersion.plist"];
    NSString *systemVersion =
        [systemVersionDictionary objectForKey:@"ProductVersion"];
    NSLog(@"systemVersion: %@",systemVersion);
    if ([systemVersion floatValue]<10.14)
    {
        [self AlertBox:@"Warning!" withInfo:@"Bridge.app is only tested on MacOS 10.14.x and Later.\nIt may not work properly on other versions"];
    }
    
    _atlas2 = [[cAtlas2Funcs alloc] initWithWindowNibName:@"cAtlas2Funcs"];

    [_atlas2 initZmqConnect];
    
    _atlas2Timer = [[cAtlas2Timer alloc] initWithWindowNibName:@"cAtlas2Timer"];
    
    _atlas2Diags = [[cAtlas2DiagsParse alloc] initWithWindowNibName:@"cAtlas2DiagsParse"];

    
    
    
    login = [[Login alloc] initWithWindowNibName:@"Login"];
    [login.window center];
    [login.window orderOut:nil];
   
    splash = [[winSplash alloc] initWithWindowNibName:@"winSplash"];
    [splash ClearLog];
    [splash.window center];
    [splash.window orderOut:nil];
    
    excelFilter = [[ExcelWindow alloc] initWithWindowNibName:@"ExcelWindow"];
    [excelFilter.window center];
    [excelFilter.window orderOut:nil];
    
    proBar = [[progressBar alloc] initWithWindowNibName:@"progressBar"];
    [proBar.window center];
    [proBar.window orderOut:nil];
    
    
    limitM = [[limitMerger alloc] initWithWindowNibName:@"limitMerger"];
    [limitM.window center];
    [limitM.window orderOut:nil];
    
    
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnNotification:) name:kNotificationLoginShowUp object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnNotification:) name:kNotificationLoginShowClose object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnNotification:) name:kNotificationInHidenFilter object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnNotification:) name:kNotificationInShowFilter object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnNotification:) name:kNotificationShowStartUp object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnNotification:) name:kNotificationCloseStartUp object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnNotification:) name:kNotificationShowProgressUp object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnNotification:) name:kNotificationCloseProgressUp object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnNotification:) name:kNotificationLimitMergerShowUp object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnNotification:) name:kNotificationLimitMergerShowClose object:nil];
    
    //
    NSDistributedNotificationCenter *center =
        [NSDistributedNotificationCenter defaultCenter];
        NSString *observedObject = @"com.vito.notification";
        [center addObserver: self
                   selector: @selector(callbackWithNotification:)
                       name: nil/*@"PiaoYun Notification"*/
                     object: observedObject];
        NSLog(@"notification send");
        //[center postNotificationName: @"progress"
         //                     object: observedObject
         //                   userInfo: @{@"info":@"start keynot report ???",@"progress":@(100),@"title":@"this is a Test !" } /* no dictionary */
        //          deliverImmediately: NO];
    
}


- (void)callbackWithNotification:(NSNotification *)nf;
{
    if([nf.name isEqualToString:@"progress"]){
        if([[nf userInfo][@"progress"] intValue] > 100){
            [proBar.window orderOut:nil];
            [proBar resetState:@""  withProgress:0 withTitle:@""];
            
        }
        else{
            
            [proBar.window orderFront:nil];
            [proBar resetState:[nf userInfo][@"info"]  withProgress:[[nf userInfo][@"progress"] doubleValue] withTitle:[nf userInfo][@"title"]];
        }
        
    }
    NSLog(@"Notification Received1");
}
- (void)OnNotification:(NSNotification *)nf
{
    NSString * name = [nf name];
    if([name isEqualToString:kNotificationShowStartUp])
    {
        [splash ClearLog];
        [splash.window orderFront:nil];
    }
    else if([name isEqualToString:kNotificationCloseStartUp])
    {
        [splash.window orderOut:nil];
    }
    else if([name isEqualToString:kNotificationInShowFilter])
    {
        [excelFilter.window orderFront:nil];
        if([[[nf userInfo] allKeys] containsObject:@"keys"] and [[[nf userInfo] allKeys] containsObject:@"identifier"]){
            
            [excelFilter reloadKeys:[nf userInfo][@"keys"] withIdentify:[nf userInfo][@"identifier"]];
            
        }
    }
    else if([name isEqualToString:kNotificationInHidenFilter])
    {
        [excelFilter.window orderOut:nil];
    }
    else if([name isEqualToString:kNotificationShowProgressUp])
    {
        [proBar.window orderFront:nil];
        [proBar resetState:[nf userInfo][@"info"]  withProgress:[[nf userInfo][@"progress"] doubleValue] withTitle:[nf userInfo][@"title"]];
    }
    else if([name isEqualToString:kNotificationCloseProgressUp])
    {
//        [proBar.window orderOut:nil];
//        [proBar resetState:@""  withProgress:0 withTitle:@""];
    }
    
    else if([name isEqualToString:kNotificationLimitMergerShowUp])//kNotificationLimitMergerShowUp kNotificationLimitMergerShowClose
    {
        [limitM reset];
        [limitM.window orderFront:nil];
        
        [limitM.window makeKeyWindow];
        [limitM.window makeMainWindow];
        
        
        
        
        //[limitM loadInfo:[nf userInfo][@"testplans"][0] withLimits:[nf userInfo][@"limitfiles"] ];
        
    }
    else if([name isEqualToString:kNotificationLimitMergerShowClose])
    {
        [limitM.window orderOut:nil];
    }
    
    else if([name isEqualToString:kNotificationLoginShowUp])
    {
        [login.window orderFront:nil];
        [login.window makeMainWindow];
        
       
    }
    else if([name isEqualToString:kNotificationLoginShowClose])
    {
        [login.window orderOut:nil];
    }
    
    
    
    
}

-(void)AlertBox:(NSString *)msgTxt withInfo:(NSString *)strmsg
{
    NSAlert * alert = [[NSAlert alloc] init];
    alert.messageText = msgTxt;
    alert.informativeText = strmsg;
    [alert runModal];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    NSLog(@">applicationWillTerminate");
    
}
- (BOOL)windowShouldClose:(id)sender{
    //[NSApp terminate:self];
    //
    [splash winClose];
    [splash.window orderOut:nil];
    NSLog(@">applicationShouldTerminateAfterLastWindowClosed");
    [startPython ShutDown];
    NSString *fail_plot_path = @"/tmp/CPK_Log/fail_plot/";
    NSString *plot_path = @"/tmp/CPK_Log/plot/";
    NSString *temp_path = @"/tmp/CPK_Log/temp/";
    NSString *retest_path = @"/tmp/CPK_Log/retest/";
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if ([fileManager removeItemAtPath:fail_plot_path error:NULL])
    {
        NSLog(@"Removed fail_plot folder successfully");
    }
    if ([fileManager removeItemAtPath:plot_path error:NULL])
     {
         NSLog(@"Removed plot folder successfully");
     }
    if ([fileManager removeItemAtPath:temp_path error:NULL])
     {
         NSLog(@"Removed temp folder successfully");
     }
    if ([fileManager removeItemAtPath:retest_path error:NULL])
     {
         NSLog(@"Removed retest folder successfully");
     }


    
    [NSApp terminate:self];
    return YES;
}
- (void)applicationWillHide:(NSNotification *)notification{
    
    NSLog(@">applicationWillHide");
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    [splash winClose];
    [splash.window orderOut:nil];
    NSLog(@">applicationShouldTerminateAfterLastWindowClosed");
    [startPython ShutDown];
    NSString *fail_plot_path = @"/tmp/CPK_Log/fail_plot/";
    NSString *plot_path = @"/tmp/CPK_Log/plot/";
    NSString *temp_path = @"/tmp/CPK_Log/temp/";
    NSString *retest_path = @"/tmp/CPK_Log/retest/";
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if ([fileManager removeItemAtPath:fail_plot_path error:NULL])
    {
        NSLog(@"Removed fail_plot folder successfully");
    }
    if ([fileManager removeItemAtPath:plot_path error:NULL])
     {
         NSLog(@"Removed plot folder successfully");
     }
    if ([fileManager removeItemAtPath:temp_path error:NULL])
     {
         NSLog(@"Removed temp folder successfully");
     }
    if ([fileManager removeItemAtPath:retest_path error:NULL])
     {
         NSLog(@"Removed retest folder successfully");
     }


    return YES;
}



- (IBAction)btReadCsv:(id)sender
{
    myRedis->SetString("csv_all", "0.01,0.03\n0.02,0.05,0.8\n");
    myRedis->SetString("Audio HP_MIC_China_Mode_Loopback China_Mode_HP_Left_Loopback_@-5dB_Frequency", "0.01,0.03");
    myRedis->SetString("row1", "0.01,0.03,0.02");
    myRedis->SetString("row2", "0.01,0.03,0.02");
    myRedis->SetString("one_item", "0.01,0.03,0.02");
    myRedis->SetString("Audio HP_MIC_China_Mode_Loopback China_Mode_HP_Left_Loopback_@-5dB_Peak_Power", "0.05,0.04,0.06");
    myRedis->SetString("test_item_3", "350");
    myRedis->SetString("test_item_1", "0.01,0.03,0.02");
    myRedis->SetString("test_item_2", "1.01,1.03,0.02");
    myRedis->SetString("test_item_3", "2.01,3.03,0.02");
}
- (IBAction)btCpk:(id)sender
{
   //NSLog(@"==>%s",myRedis->GetString("test_item_1"));
   //NSLog(@"==>%s",myRedis->GetString("test_item_2"));
    
    NSTimeInterval starttime = [[NSDate date]timeIntervalSince1970];
    int ret = [cpkClient SendCmd:@"Audio HP_MIC_China_Mode_Loopback China_Mode_HP_Left_Loopback_@-5dB_Frequency"];
    if (ret > 0)
    {
        NSString * response = [cpkClient RecvRquest:1024];
        
        if (!response)
        {    //Not response
            //@throw [NSException exceptionWithName:@"automation Error" reason:@"pleaase check fixture." userInfo:nil];
            NSLog(@"zmq for python error");
        }
        NSLog(@"app->get response from python: %@",response);
    }
    NSTimeInterval now = [[NSDate date]timeIntervalSince1970];
    NSLog(@"====python 执行时间: %f",now-starttime);
    
}
- (IBAction)btCorrelation:(id)sender
{
    NSTimeInterval starttime = [[NSDate date]timeIntervalSince1970];
    int ret = [correlationClient SendCmd:@"test_item_2"];
    if (ret > 0)
    {
        NSString * response = [correlationClient RecvRquest:1024];
        if (!response)
        {
            NSLog(@"zmq for python error");
        }
        NSLog(@"app->get response from python: %@",response);
    }
    
    NSTimeInterval now = [[NSDate date]timeIntervalSince1970];
    NSLog(@"====python 执行时间: %f",now-starttime);
}

- (IBAction)btCalculate:(id)sender
{
    /*(NSTimeInterval starttime = [[NSDate date]timeIntervalSince1970];
    
    int ret = [calculateClient SendCmd:@"test_item_3"];
    if (ret > 0)
    {
        NSString * response = [calculateClient RecvRquest:1024];
        if (!response)
        {
            NSLog(@"zmq for python error");
        }
        NSLog(@"app->get response from python: %@",response);
    }
    
    NSTimeInterval now = [[NSDate date]timeIntervalSince1970];
    NSLog(@"====python 执行时间: %f",now-starttime);
    */
}

- (IBAction)btCpkCorrTogether:(id)sender
{
    NSTimeInterval starttime = [[NSDate date]timeIntervalSince1970];
    
    int ret1 = [cpkClient SendCmd:@"test_item_1"];
    int ret2 = [correlationClient SendCmd:@"test_item_2"];
    
    if (ret1 > 0)
    {
        NSString * response = [cpkClient RecvRquest:1024];
        
        if (!response)
        {
            NSLog(@"zmq cpk for python error");
        }
        NSLog(@"app->get response from cpk python: %@",response);
    }
    
    if (ret2 > 0)
    {
        NSString * response = [correlationClient RecvRquest:1024];
        if (!response)
        {
            NSLog(@"zmq correlation for python error");
        }
        NSLog(@"app->get response from correlation python: %@",response);
    }
    
    NSTimeInterval now = [[NSDate date]timeIntervalSince1970];
    NSLog(@"====python 执行时间: %f",now-starttime);
    
}

@end
