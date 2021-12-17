//
//  cAtlas2Timer.m
//  Bridge
//
//  Created by vito xie on 2021/9/3.
//  Copyright © 2021 RyanGao. All rights reserved.
//

#import "cAtlas2Timer.h"


#import "defineHeader.h"
#import "SCRedis.framework/Headers/RedisInterface.hpp"
#import "SCZmq.framework/Headers/Client.h"


#import <Foundation/Foundation.h>
#import <stdio.h>
#import <stdlib.h>

#import "StartUp.framework/Headers/StartUp.h"

#import "CycleDelegate.h"


extern Client *reportAtlas2Client;
extern StartUp * startPython;

#define  atlas2_report_zmq_addr     @"tcp://127.0.0.1:3310"
@interface cAtlas2Timer ()
@property (weak) IBOutlet NSTableView *timerTable;
@property CycleDelegate * atlasdelegateCycle;
@end

@implementation cAtlas2Timer

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
    

    _atlasdelegateCycle = [[CycleDelegate alloc] initWithView:_timerTable];
    
    [_timerTable setDelegate:_atlasdelegateCycle];
    [_timerTable setDataSource:_atlasdelegateCycle];

}

- (IBAction)doParseCycleTime:(id)sender {

    
    
}
- (IBAction)doLoad:(id)sender {
    NSString * atlasFolder = [self openAtlasLoadPanel];
    
    if (atlasFolder != nil){
        folder =atlasFolder;
        [self.window setTitle:folder];
        if( folder == nil){
            
            [self AlertBox:@"Error" withInfo:@"Please Load Log System folder/ flow.log root folder first !!!"];
        }
        else{
            
            [self sendAtlas2ZmqMsg:[NSString stringWithFormat:@"atlas2_timer@%@",folder ]];
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
-(NSString *)openAtlasLoadPanel
{
    NSString *csvpath =nil;
    NSOpenPanel * panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO]; //设置多选模式
    [panel setCanChooseFiles:YES];
    [panel setCanCreateDirectories:NO];
    [panel setCanChooseDirectories:NO];

    [panel setAllowedFileTypes:[NSArray arrayWithObjects:@"log", @"txt",nil]];
    
    [panel setDirectoryURL:[NSURL URLWithString:@"~/Desktop"]];
    [panel runModal];
    if ([[panel URLs] count]>0)
    {
        csvpath = [[[panel URLs] objectAtIndex:0] path];
        return csvpath;
    }
    return csvpath;
}
-(void)reset{
    [_atlasdelegateCycle reset];
    [_timerTable reloadData];
    [self.window setTitle:@"Timer"];
}
- (IBAction)exportCsv:(id)sender {
    
    [self sendAtlas2ZmqMsg:@"atlas2_timer_export@"];
    
}

- (void)callbackWithNotification:(NSNotification *)nf;
{
    if([nf.name isEqualToString:@"post-json"]){
        NSLog(@"Notification Received1 %@",[nf userInfo][@"info"]);
        NSString * limitfile =[NSString stringWithFormat:@"%@",[nf userInfo][@"info"]];
        NSArray* datas =  [limitfile componentsSeparatedByString:NSLocalizedString(@"^&^", nil)];
        if([datas count] >=2){
            if ([datas[0] isEqualToString:@"atlas2_timer"]) {
                NSData *jsonData = [datas[1] dataUsingEncoding:NSUTF8StringEncoding];
                NSError *err;
                NSArray *jsonDict_testPlan = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                    options:NSJSONReadingMutableContainers
                                                                      error:&err];
                if(err) {
                    NSLog(@"TestPlan Parse Fail：%@",err);
                }
                [self.atlasdelegateCycle setDataSingle:jsonDict_testPlan] ;
                [self.timerTable reloadData];
            
            }
        }
    }
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
            NSLog(@"zmq atlas timer for python error");
        }
        NSLog(@"app->get response from atlas timer python: %@",response);
        return response;
    }
    return nil;
}
@end
