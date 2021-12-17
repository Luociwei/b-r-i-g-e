//
//  cAtlas2DiagsParse.m
//  Bridge
//
//  Created by vito xie on 2021/9/14.
//  Copyright © 2021 RyanGao. All rights reserved.
//

#import "cAtlas2DiagsParse.h"


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
@interface cAtlas2DiagsParse (){
    
    NSMutableArray* selectfiles;
    
}
@property (weak) IBOutlet NSComboBox *selectedFile;
@property (weak) IBOutlet NSButton *btnLoad;
@property (weak) IBOutlet NSButton *isSmokeyElement;
@property (weak) IBOutlet NSComboBox *fileoption;
@property (weak) IBOutlet NSComboBox *parseOption;
@property (weak) IBOutlet NSButton *doGenerate;

@end

@implementation cAtlas2DiagsParse

- (IBAction)btndoLoad:(id)sender {
    NSArray * atlasfiles = [self openAtlasLoadPanel];
    
    if (atlasfiles != nil){
       
        [_selectedFile removeAllItems];
        
        [selectfiles removeAllObjects];
        
        for (int i = 0 ; i <[atlasfiles count] ; i++) {
            
            [selectfiles addObject:atlasfiles[i]];
            [_selectedFile addItemWithObjectValue:atlasfiles[i]];
            
            NSArray* infos = [atlasfiles[i] componentsSeparatedByString:@"/"];
            
            [_fileoption addItemWithObjectValue:[infos lastObject]];
        }
        [_selectedFile selectItemAtIndex:0];
        
        
    }
    else{
        
        [self AlertBox:@"Error" withInfo:@"Please located flow.log"];
    }
}
-(void)AlertBox:(NSString *)msgTxt withInfo:(NSString *)strmsg
{
    NSAlert * alert = [[NSAlert alloc] init];
    alert.messageText = msgTxt;
    alert.informativeText = strmsg;
    [alert runModal];
}
- (IBAction)btnIsSmokey:(id)sender {
}
- (IBAction)fileList:(id)sender {
}

- (IBAction)parseByOption:(id)sender {
}
- (IBAction)doClose:(id)sender {
    [NSApp stopModalWithCode:NSModalResponseCancel];
    [[sender window] orderOut:self];
}
- (IBAction)doGenerate:(id)sender {
    
    NSString * fileopetion = [_fileoption itemObjectValueAtIndex:[_fileoption indexOfSelectedItem]];
    
    int isSmokey= [_isSmokeyElement state] == YES ? 1:0;
    
    NSArray* files = selectfiles;
    
    NSMutableString* ret = [[NSMutableString alloc] init];
    for (int i=0; i<[selectfiles count]; i++) {
        if (i==0) {
            [ret setString: [NSString stringWithFormat:@"%@",selectfiles[i] ]];
        }
        
        [ret setString:[NSString stringWithFormat:@"%@;%@",ret,selectfiles[i] ]];
    }
    
    int parseOption = [_parseOption indexOfSelectedItem];
    
    [self sendAtlas2ZmqMsg:[NSString stringWithFormat:@"atlas2_diags_extrator@%d@%d@%@@%@",isSmokey,parseOption,fileopetion,ret]];
    
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
- (void)windowDidLoad {
    [super windowDidLoad];
    
    [_selectedFile removeAllItems];
    
    [_isSmokeyElement setState:NO];
    
    [_fileoption selectItemAtIndex:0];
    
    [_parseOption selectItemAtIndex:0];
    
    selectfiles  = [[NSMutableArray alloc] init];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

-(NSArray *)openAtlasLoadPanel
{
    NSString *csvpath =nil;
    NSOpenPanel * panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:YES]; //设置多选模式
    [panel setCanChooseFiles:YES];
    [panel setCanCreateDirectories:NO];
    [panel setCanChooseDirectories:NO];

    [panel setAllowedFileTypes:[NSArray arrayWithObjects:@"log", @"txt",nil]];
    
    [panel setDirectoryURL:[NSURL URLWithString:@"~/Desktop"]];
    [panel runModal];
    if ([[panel URLs] count]>0)
    {
        csvpath = [[[panel URLs] objectAtIndex:0] path];
        
        NSMutableArray* ret = [[NSMutableArray alloc] init];
        
        for (int i=0; i<[[panel URLs] count]; i++) {
            [ret addObject:[[panel URLs][i] path]];
        }
        return ret;
    }
    return nil;
}
-(void)reset{

    [_selectedFile setStringValue:@""];
    [_selectedFile removeAllItems];
    [_fileoption removeAllItems];
    [_fileoption addItemWithObjectValue:@"ALL"];

    
    [_isSmokeyElement setState:NO];
    
    [_fileoption selectItemAtIndex:0];
    
    [_parseOption selectItemAtIndex:0];
}
@end
