//
//  limitMerger.m
//  Bridge
//
//  Created by vito xie on 2021/5/18.
//  Copyright © 2021 RyanGao. All rights reserved.
//

#import "limitMerger.hpp"
#import "../DataPlot/defineHeader.h"
#import "SCZmq.framework/Headers/Client.h"

#import "testplanTableDelegate.h"
#import "limitfileDelegate.h"
#import "testPlanSource.h"
#import "listController.h"

#import <Quartz/Quartz.h>
#import <QuartzCore/QuartzCore.h>

#import "vtTable.h"
@interface limitMerger (){
    
    CGFloat _lastLeftPaneWidth;
}
@property (weak) IBOutlet NSTableView *testplanTableview;
@property (weak) IBOutlet NSTableView *limitfileTableview;
@property testplanTableDelegate * delegateTestplan;
@property limitfileDelegate * delegateLimitFile;
@property (weak) IBOutlet testPlanSource *testplanSource;
@property (weak) IBOutlet testPlanSource *limitFileSource;
@property (weak) IBOutlet NSSplitView *splitView;
@property (weak) IBOutlet NSButtonCell *btnUndo;



@property (weak) IBOutlet NSView *broseView;

@property (weak) IBOutlet vtTable *testPlanDrag;
@property (weak) IBOutlet vtTable *limitDrag;

@property (weak) IBOutlet NSTextField *testPlanName;
@property (weak) IBOutlet NSTextField *limitName;
@end
Client *limitmergeClient;
@implementation limitMerger{
    
    listController *csvView;
}

- (void)windowDidLoad {
    [super windowDidLoad];
}

- (void)awakeFromNib{

    [self.window setLevel:kCGFloatingWindowLevel];
    [self.window center];
    [self.window setAccessibilityFocused:YES];
    
    NSDistributedNotificationCenter *center =
        [NSDistributedNotificationCenter defaultCenter];
        NSString *observedObject = @"com.vito.notification";
        [center addObserver: self
                   selector: @selector(callbackWithNotification:)
                       name: nil/*@"PiaoYun Notification"*/
                     object: observedObject];
    
    
    [self Lanuch_limit_merge];
    [self Init_limit_merge_python];
    
    
    
    
    _delegateTestplan = [[testplanTableDelegate alloc] initWithView:_testplanTableview];
    _delegateLimitFile = [[limitfileDelegate alloc] initWithView:_limitfileTableview];
    
    
    
    [_limitDrag isProfile:false];
    [_limitDrag registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
 
    [_testPlanDrag isProfile:true];
    [_testPlanDrag registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];

    
    [_limitFileSource isProfile:false];
    [_limitFileSource registerForDraggedTypes:[NSArray arrayWithObjects:
                                             NSFilenamesPboardType, nil]];
    

    
    
    [_testplanSource isProfile:true];
    [_testplanSource registerForDraggedTypes:[NSArray arrayWithObjects:
                                             NSFilenamesPboardType, nil]];
    
    
    
    [_testplanSource setWantsLayer:YES];
    CALayer *viewLayer = [CALayer layer];
     [_testplanSource setLayer:viewLayer];
    _testplanSource.layer.backgroundColor = [NSColor colorWithRed:0.14 green:0.62 blue:0.93 alpha:1.0].CGColor;
     [_testplanSource setNeedsDisplay:YES];
    
    
    [_limitFileSource setWantsLayer:YES];
    CALayer *viewLayer_ = [CALayer layer];
     [_limitFileSource setLayer:viewLayer_];
    _limitFileSource.layer.backgroundColor = [NSColor colorWithRed:0.14 green:0.62 blue:0.93 alpha:1.0].CGColor;
     [_limitFileSource setNeedsDisplay:YES];
    
    
    [_testPlanName setStringValue:@"testplan file"];
    [_limitName setStringValue:@"limit file"];
    
    
    
    
    
    
    
    [_testplanTableview setDelegate:_delegateTestplan];
    [_testplanTableview setDataSource:_delegateTestplan];
 
    
    [_limitfileTableview setDelegate:_delegateLimitFile];
    [_limitfileTableview setDataSource:_delegateLimitFile];
    
    
    //
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnNotification:) name:@"LoadMsg" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnNotification:) name:@"focus" object:nil];
    
    
    
    csvView = [[listController alloc]init];
    
    //[self LoadSubView:csvView.view];
    
    [[_broseView superview] replaceSubview:_broseView with:csvView.view];
    [csvView.view setFrame:[_broseView frame]];
    _broseView = csvView.view;
    //[self loadView];
    
    [self.splitView setPosition:0 ofDividerAtIndex:0];
    
    [_btnUndo setEnabled:false];
    
    
}
- (IBAction)onLoad:(id)sender {
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.allowsImplicitAnimation = YES;
        context.duration = 0.25; // seconds
        context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
         if (_lastLeftPaneWidth==0 )
         {
            
             [self.splitView setPosition:160 ofDividerAtIndex:0];
             _lastLeftPaneWidth = 1200;
             
         }
         else
         {
             [self.splitView setPosition:0 ofDividerAtIndex:0];
              _lastLeftPaneWidth = 0;
             
         }
         
        
        [self.splitView layoutSubtreeIfNeeded];
    }];
}


- (void)OnNotification:(NSNotification *)nf
{
    NSString * name = [nf name];
    if([name isEqualToString:@"LoadMsg"])
    {
        NSDictionary* info = [nf userInfo];
        NSString * type  = info[@"type"];
        NSString * filename = info[@"file"];
        
        if ([type isEqualToString:@"profile"]) {
            
            [_testPlanName setStringValue:filename];
            
            [self sendTestPlanParse:filename];
            
        }else if ([type isEqualToString:@"limit"]){
            
            [_limitName setStringValue:filename];
            [self sendLimitFileParse:filename];
        }
        else if ([type isEqualToString:@"both"]){
            if([_delegateTestplan isDataLoaded] && [_delegateLimitFile isDataLoaded]){
                
                
                [self sendBothParse];
                
            }
        }
    }
    else if([name isEqualToString:@"focus"]){
        
        //[self.window makeKeyWindow];
        
        //[[NSApp mainWindow] makeKeyWindow];
        //[[NSApp mainWindow] makeKeyAndOrderFront:self];
        
        NSApplication *thisApp = [NSApplication sharedApplication];
        [thisApp activateIgnoringOtherApps:YES];
        
        [self.window makeKeyAndOrderFront:self];
    }
}
- (IBAction)UndoSync:(id)sender {
    
    if([_delegateTestplan UnSyncLastStep]){
        [_btnUndo setEnabled:true];
    }
    else{
        [_btnUndo setEnabled:false];
    }
}

- (IBAction)ExportProfile:(id)sender {
    NSString * info= [_delegateTestplan generateModifyInfo];
    int ret = [limitmergeClient SendCmd: [NSString  stringWithFormat:@"save$$%@",info]];
    if (ret > 0)
    {
        NSString * response = [limitmergeClient RecvRquest:1024];
        if (!response)
        {
            NSLog(@"zmq for python retest plot  error");
        }
        NSLog(@"app->get response from python retest plot: %@",response);
    }
    
}


- (void)callbackWithNotification:(NSNotification *)nf;
{
    if([nf.name isEqualToString:@"post-json"]){
    
        NSLog(@"Notification Received1 %@",[nf userInfo][@"info"]);
        
        
        NSString * limitfile =[NSString stringWithFormat:@"%@",[nf userInfo][@"info"]];
        
        NSArray* datas =  [limitfile componentsSeparatedByString:NSLocalizedString(@"^&^", nil)];
        
        if([datas count] >=2){
            
            if ([datas[0] isEqualToString:@"profile"]) {
                NSData *jsonData = [datas[1] dataUsingEncoding:NSUTF8StringEncoding];
                //NSLog(@"jsonData: %@", jsonData);
                
                NSError *err;
                
                NSArray *jsonDict_testPlan = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                    options:NSJSONReadingMutableContainers
                                                                      error:&err];
                
                if(err) {
                    NSLog(@"TestPlan Parse Fail：%@",err);
                    
                }
                
                [_delegateTestplan setDataSingle:jsonDict_testPlan] ;
                [self.testplanTableview reloadData];
                
                [self.testplanTableview setAccessibilityFocused:YES];
                
                [[NSNotificationCenter defaultCenter]postNotificationName:@"LoadMsg" object:nil userInfo:@{@"type":@"both"}];
                
            }
            else if([datas[0] isEqualToString:@"limit"]){
                NSError *err_limit;
                NSArray *jsonDict_Limit = [NSJSONSerialization JSONObjectWithData:[datas[1] dataUsingEncoding:NSUTF8StringEncoding]
                                                                    options:NSJSONReadingMutableContainers
                                                                      error:&err_limit];
                
                if(err_limit) {
                    NSLog(@"Limit Parse Fail：%@",err_limit);
                }
                [_delegateLimitFile setData:jsonDict_Limit];
                [self.limitfileTableview reloadData];
                [self.limitfileTableview setAccessibilityFocused:YES];
                
                [[NSNotificationCenter defaultCenter]postNotificationName:@"LoadMsg" object:nil userInfo:@{@"type":@"both"}];
                
            }
            else if([datas[0] isEqualToString:@"both"]){
                NSError *err_both;
                NSDictionary *jsonDict_both = [NSJSONSerialization JSONObjectWithData:[datas[1] dataUsingEncoding:NSUTF8StringEncoding]
                                                                    options:NSJSONReadingMutableContainers
                                                                      error:&err_both];
                
                if(err_both) {
                    NSLog(@"both Parse Fail：%@",err_both);
                }
                else{
                    
                    [_delegateTestplan setDataSingle:jsonDict_both[@"new_data"]] ;
                    [_delegateTestplan setDataSingleInfo:jsonDict_both[@"green"] withYellow:jsonDict_both[@"yellow"] withGray:jsonDict_both[@"gray"] withLimitData:[self.delegateLimitFile getData] withRed:jsonDict_both[@"red"]];
                    
                    [self.testplanTableview reloadData];
                    [self.testplanTableview setAccessibilityFocused:YES];
                    
                    [self.splitView setPosition:0 ofDividerAtIndex:0];
                    
                    
                }
                
                
                 
            }
            else if([datas[0] isEqualToString:@"finish"]){
                
                [self AlertBox:@"Export Success !" withInfo: [NSString stringWithFormat:@"%@",datas[1] ]];
                
            }
            else if([datas[0] isEqualToString:@"exception"]){
                
                [self AlertBox:@"exception error !" withInfo: [NSString stringWithFormat:@"%@",datas[1] ]];
                
            }
        }
    }
    
}

-(void)AlertBox:(NSString *)msgTxt withInfo:(NSString *)strmsg
{
    NSAlert * alert = [[NSAlert alloc] init];
    alert.messageText = msgTxt;
    alert.informativeText = strmsg;
    [alert runModal];
}
- (IBAction)clickTestPlan:(id)sender {
    [_delegateTestplan clickedRow];
}


- (IBAction)clickLimit:(id)sender {
}


-(void)reset{
    [_delegateTestplan reset];
    //[_testplanTableview reloadData];
    [self.testplanTableview reloadData];
    
    
}

-(void)loadInfo:(NSString *)csvfile withLimits:(NSArray*)limitFiles{
    
    

}

-(int)execute_withTask:(NSString*) szcmd withPython:(NSString *)arg
{
    if (!szcmd) return -1;
    NSTask * task = [[NSTask alloc] init];
    [task setLaunchPath:szcmd];
    [task setArguments:[NSArray arrayWithObjects:arg, nil]];
    [task launch];
    return 0;
}
-(void)Lanuch_limit_merge
{
    NSString * cmd = @"/Library/Frameworks/Python.framework/Versions/3.9/bin/python3.9";
    NSString * arg = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"limit_merge_test.py"];
    NSString *logCmd = @"ps -ef |grep -i python |grep -i limit_merge_test.py |grep -v grep|awk '{print $2}' | xargs kill -9";
    system([logCmd UTF8String]); //
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:arg])
    {
        arg = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"limit_merge_test.pyc"];
        logCmd = @"ps -ef |grep -i python |grep -i limit_merge_test |grep -v grep|awk '{print $2}' | xargs kill -9";
        system([logCmd UTF8String]);
    }
         
    [self execute_withTask:cmd withPython:arg];
    
}



-(void)parse_json_string:(NSString*) info{
    
//    NSString *pauseAdJson = [[NSString alloc] initWithUTF8String:info];
//
//    NSData *jsonData = [pauseAdJson dataUsingEncoding:NSUTF8StringEncoding];
//    //NSLog(@"jsonData: %@", jsonData);
//
//    NSError *err;
//
//    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
//                                                        options:NSJSONReadingMutableContainers
//                                                          error:&err];
//
//    if(err) {
//        NSLog(@"json解析失败：%@",err);
//    }
}
-(void)Init_limit_merge_python
{
    
    
    limitmergeClient = [[Client alloc] init];   // connect calculate zmq for calculate.py
    [limitmergeClient CreateRPC:limit_merge_zmq_addr withSubscriber:nil];
    [limitmergeClient setTimeout:20*1000];
    
    
}
- (IBAction)ModifyAll:(id)sender {
    if([_delegateTestplan ModifyAll]){
        [_btnUndo setEnabled:true];
    }
    else{
        [_btnUndo setEnabled:false];
    }
}


- (IBAction)Modify:(id)sender {
    
    if([_delegateTestplan Modify]){
        [_btnUndo setEnabled:true];
    }
    else{
        [_btnUndo setEnabled:false];
    }
    
}

- (IBAction)showGreen:(id)sender {
    [_delegateTestplan showGreen];
}
- (IBAction)showYellow:(id)sender {
    [_delegateTestplan showYellow];
}
- (IBAction)showRed:(id)sender {
    [_delegateTestplan showRedAndGray];
}

- (IBAction)showAll:(id)sender {
    [_delegateTestplan showAll];
}


-(NSString *)sendBothParse
{

    NSString *msg = @"limitmerge$$both$$anthing";

    int ret = [limitmergeClient SendCmd:msg];
    if (ret > 0)
    {
        NSString * response = [limitmergeClient RecvRquest:1024];
        if (!response)
        {
            NSLog(@"zmq for python retest plot  error");
        }
        NSLog(@"app->get response from python retest plot: %@",response);
        return response;
    }
    return nil;
}
-(NSString *)sendLimitFileParse:(NSString *)testplan
{

    NSString *msg = [NSString stringWithFormat:@"limitmerge$$limit$$%@",testplan];

    int ret = [limitmergeClient SendCmd:msg];
    if (ret > 0)
    {
        NSString * response = [limitmergeClient RecvRquest:1024];
        if (!response)
        {
            NSLog(@"zmq for python retest plot  error");
        }
        NSLog(@"app->get response from python retest plot: %@",response);
        return response;
    }
    return nil;
}
-(NSString *)sendTestPlanParse:(NSString *)testplan
{

    NSString *msg = [NSString stringWithFormat:@"limitmerge$$profile$$%@",testplan];

    int ret = [limitmergeClient SendCmd:msg];
    if (ret > 0)
    {
        NSString * response = [limitmergeClient RecvRquest:1024];
        if (!response)
        {
            NSLog(@"zmq for python retest plot  error");
        }
        NSLog(@"app->get response from python retest plot: %@",response);
        return response;
    }
    return nil;
}

-(NSString *)sendLimitMergeStartParse:(NSString *)testplan withLimitfiles:(NSArray*) limitfiles
{
    NSString * limitfile = nil;
    for (int i=0; i < [limitfiles count];i++) {
       
        if (i ==0){
            limitfile =[NSString stringWithFormat:@"%@",limitfiles[i]];
            
        }else{
            limitfile =[NSString stringWithFormat:@"%@;%@",limitfile,limitfiles[i]];
        }
    }

    NSString *msg = [NSString stringWithFormat:@"limitmerge$$%@$$%@",testplan,limitfile];

    int ret = [limitmergeClient SendCmd:msg];
    if (ret > 0)
    {
        NSString * response = [limitmergeClient RecvRquest:1024];
        if (!response)
        {
            NSLog(@"zmq for python retest plot  error");
        }
        NSLog(@"app->get response from python retest plot: %@",response);
        return response;
    }
    return nil;
}
@end
