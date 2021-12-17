//
//  cAtlas2Funcs.m
//  Bridge
//
//  Created by vito xie on 2021/9/2.
//  Copyright © 2021 RyanGao. All rights reserved.
//


#import "cAtlas2Funcs.h"

#import "defineHeader.h"
#import "SCRedis.framework/Headers/RedisInterface.hpp"
#import "SCZmq.framework/Headers/Client.h"


#import <Foundation/Foundation.h>
#import <stdio.h>
#import <stdlib.h>

#import "StartUp.framework/Headers/StartUp.h"

#import "TableDelegate.h"

#define  atlas2_report_zmq_addr     @"tcp://127.0.0.1:3310"
Client *reportAtlas2Client;
StartUp * startPython;
@interface cAtlas2Funcs (){
    StartUp * startPython;
    
}
@property (weak) IBOutlet NSTableView *atlastableView;
@property TableDelegate * atlasdelegateView;

@end

@implementation cAtlas2Funcs

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    NSDistributedNotificationCenter *center =
        [NSDistributedNotificationCenter defaultCenter];
        NSString *observedObject = @"com.vito.notification";
        [center addObserver: self
                   selector: @selector(callbackWithNotification:)
                       name: nil/*@"PiaoYun Notification"*/
                     object: observedObject];
        NSLog(@"notification send");
    
    _atlasdelegateView = [[TableDelegate alloc] initWithView:_atlastableView];
    
    [_atlastableView setDelegate:_atlasdelegateView];
    [_atlastableView setDataSource:_atlasdelegateView];


}
-(void)reset{
    [_atlasdelegateView reset];
    [_atlastableView reloadData];
    [self.window setTitle:@"Matchbox to Legacy"];
}
- (IBAction)exportCsv:(id)sender {
    [self sendAtlas2ZmqMsg:@"atlas2_profile_export@"];
}


-(void)initZmqConnect{
    NSString *cmdKillPythonLaunch = @"ps -ef |grep -i python |grep -i atlas2_test |grep -v grep|awk '{print $2}' |xargs kill -9";

    system([cmdKillPythonLaunch UTF8String]);
    
    startPython = [[StartUp alloc] init];
    
    [startPython Lanuch_atlas_report];
    
    reportAtlas2Client = [[Client alloc] init];   // connect keynote
    
    [reportAtlas2Client CreateRPC:atlas2_report_zmq_addr withSubscriber:nil];
    
    [reportAtlas2Client setTimeout:20*1000];
    
}

- (void)callbackWithNotification:(NSNotification *)nf;
{
    if([nf.name isEqualToString:@"post-json"]){
    
        NSLog(@"Notification Received1 %@",[nf userInfo][@"info"]);
        
        
        NSString * limitfile =[NSString stringWithFormat:@"%@",[nf userInfo][@"info"]];
        
        NSArray* datas =  [limitfile componentsSeparatedByString:NSLocalizedString(@"^&^", nil)];
        
        if([datas count] >=2){
            
            if ([datas[0] isEqualToString:@"atlas2_profile"]) {
                NSData *jsonData = [datas[1] dataUsingEncoding:NSUTF8StringEncoding];

                NSError *err;

                NSArray *jsonDict_testPlan = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                    options:NSJSONReadingMutableContainers
                                                                      error:&err];


                if(err) {
                    NSLog(@"TestPlan Parse Fail：%@",err);

                }

                [self.atlasdelegateView setDataSingle:jsonDict_testPlan] ;
                [self.atlastableView reloadData];
            
            }
        }
    }
}


- (IBAction)doLoad:(id)sender {
    NSString * atlasFolder = [self openAtlasLoadPanel];
    if (atlasFolder != nil){
        folder =atlasFolder;
        [self.window setTitle:folder];
        
        if( folder == nil){
            
            [self AlertBox:@"Error" withInfo:@"Please Load Atlas2 Assets folder first !!!"];
        }
        else{
            
            [self sendAtlas2ZmqMsg:[NSString stringWithFormat:@"atlas2_profile@%@",folder ]];
        }
    }
    
}
-(NSString *)openAtlasLoadPanel
{
    NSString *csvpath =nil;
    NSOpenPanel * panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO]; //设置多选模式
    [panel setCanChooseFiles:NO];
    [panel setCanCreateDirectories:YES];
    [panel setCanChooseDirectories:YES];

    [panel setDirectoryURL:[NSURL URLWithString:@"~/Desktop"]];
    [panel runModal];
    if ([[panel URLs] count]>0)
    {
        csvpath = [[[panel URLs] objectAtIndex:0] path];
        return csvpath;
    }
    return csvpath;
}

-(void)AlertBox:(NSString *)msgTxt withInfo:(NSString *)strmsg
{
    NSAlert * alert = [[NSAlert alloc] init];
    alert.messageText = msgTxt;
    alert.informativeText = strmsg;
    [alert runModal];
}
- (IBAction)doClose:(id)sender {
    [NSApp stopModalWithCode:NSModalResponseCancel];
    [[sender window] orderOut:self];
}

-(NSString *)sendAtlas2ZmqMsg:(NSString *)name  //keynote zmq
{
    int ret = [reportAtlas2Client SendCmd:name];
    if (ret > 0)
    {
        NSString * response = [reportAtlas2Client RecvRquest:1024];
        if (!response)
        {
            NSLog(@"zmq atlas for python error");
        }
        NSLog(@"app->get response from keynote python: %@",response);
        return response;
    }
    return nil;
}


@end
