//
//  limitfileDelegate.m
//  Bridge
//
//  Created by vito xie on 2021/5/20.
//  Copyright © 2021 RyanGao. All rights reserved.
//

#import "limitfileDelegate.h"

@interface limitfileDelegate ()

@property NSMutableArray * RedIndex;
@property NSMutableArray * colorGreenIndex;
@property NSMutableArray * colorYellowIndex;

@property NSMutableArray * colorGrayIndex;

@property NSLock * lock;
@end

@implementation limitfileDelegate

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    data=[[NSMutableArray alloc]init];
    
    _colorGreenIndex =[[NSMutableArray alloc]init];
    
    
}

-(NSArray*)getData{
    
    return data;
}
-(bool)isDataLoaded{
    
    if ([data count]>0) {
        return true;
    }
    else{
        
        return false;
    }
}

- (void)OnTestPlanMsg:(NSNotification *)nf {
    if ([[nf name] isEqualToString:@"testplan-limit"]) {
        int Index =  [[nf userInfo][@"index"] intValue] ;
       
       
        [view1 selectRowIndexes:[NSIndexSet indexSetWithIndex:(Index-1)] byExtendingSelection:false];
        [view1 setAccessibilityFocused:YES];
        
        NSPoint poin;
        poin.x = 0;
        
        
        poin.y =(Index-1-5 <=0 ? Index-1 : Index-1-5 )*19 ;/// view.numberOfRows
        
        [view1 numberOfRows];
        [view1 scrollPoint:poin];
        
        //int viewIndex = Index-1 >41 ? (Index-1 + 10) : Index-1;
        //[view scrollRowToVisible:viewIndex];
        
        
    }
    else if ([[nf name] isEqualToString:@"colorchange"]) {
        int Index =  [[nf userInfo][@"index"] intValue];
        
        NSString* type =  [nf userInfo][@"type"];
        
        if ([type isEqualToString:@"do"]) {
            if(![_colorGreenIndex containsObject:@(Index)]){
                
                [_colorGreenIndex addObject:@(Index)];
            }
            
        }
        else if([type isEqualToString:@"undo"]){
            if([_colorGreenIndex containsObject:@(Index)]){
                [_colorGreenIndex removeObject:@(Index)];
            }
        }
        else if([type isEqualToString:@"clear"]){
            [_colorGreenIndex removeAllObjects];
        }
        else if([type isEqualToString:@"all"]){
            [_colorGreenIndex setArray:[nf userInfo][@"data"]];
        }
        
        [view1 reloadData];
        
        [view1 setAccessibilityFocused:YES];
        
    }
}


- (instancetype)initWithView:(NSTableView*)Inview{
    //[super init];
    view1 = Inview;
    
    data=[[NSMutableArray alloc]init];
    
    _colorGreenIndex =[[NSMutableArray alloc]init];
    _colorYellowIndex =[[NSMutableArray alloc]init];
    _colorGrayIndex=[[NSMutableArray alloc]init];
    
    _RedIndex =[[NSMutableArray alloc]init];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnTestPlanMsg:) name:@"testplan-limit" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnTestPlanMsg:) name:@"colorchange" object:nil];
    return self;
}
-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    [_lock lock];
    NSString *columnIdentifier = [tableColumn identifier];
    NSTableCellView *cellview = [view1 makeViewWithIdentifier:columnIdentifier owner:self];
    NSUInteger index = -1;
    if ([columnIdentifier isEqualToString:@"ItemName"])
    {
        index = 1;
        
        NSArray *subviews = [cellview subviews];
        NSTextField *txtField = subviews[0];
        txtField.drawsBackground = NO;
        txtField.textColor= NSColor.labelColor;
        [txtField setStringValue:[data objectAtIndex:row][index]];
    }
    else if ([columnIdentifier isEqualToString:@"Lsl"])
    {
     
        index = 2;
        NSArray *subviews = [cellview subviews];
        NSTextField *txtField = subviews[0];
        txtField.drawsBackground = NO;
        txtField.textColor= NSColor.labelColor;
        if ([data objectAtIndex:row][index] == nil) {
            [txtField setStringValue:@""];
        }
        else{
            [txtField setStringValue:[data objectAtIndex:row][index]];
        }
        
    }
    else if ([columnIdentifier isEqualToString:@"Usl"])
    {
     
        index = 3;
        NSArray *subviews = [cellview subviews];
        NSTextField *txtField = subviews[0];
        txtField.drawsBackground = NO;
        txtField.textColor= NSColor.labelColor;
        if ([data objectAtIndex:row][index] == nil) {
            [txtField setStringValue:@""];
        }
        else{
            [txtField setStringValue:[data objectAtIndex:row][index]];
        }
    }
    else if ([columnIdentifier isEqualToString:@"Index"])
    {
        index = 0;
        
        NSArray *subviews = [cellview subviews];
        NSTextField *txtField = subviews[0];
        txtField.drawsBackground = NO;
        txtField.textColor= NSColor.labelColor;
        
        [txtField setStringValue:[data objectAtIndex:row][index]];
        
    }
    NSNumber* Index= @([[data objectAtIndex:row][0] intValue]);
    
    
    if ([_colorYellowIndex containsObject:@([[data objectAtIndex:row][0] intValue])]) {
        NSArray *subviews = [cellview subviews];
        NSTextField *txtField = subviews[0];
        txtField.drawsBackground = YES;
        txtField.backgroundColor = [NSColor systemYellowColor];
        txtField.textColor = [NSColor colorWithSRGBRed:0 green:0 blue:0 alpha:100];
    }
    
    if ([_colorGreenIndex containsObject:@([[data objectAtIndex:row][0] intValue])]) {
        NSArray *subviews = [cellview subviews];
        NSTextField *txtField = subviews[0];
        txtField.drawsBackground = YES;
        txtField.backgroundColor = [NSColor systemGreenColor];
        txtField.textColor = [NSColor colorWithSRGBRed:0 green:0 blue:0 alpha:100];
    }
    else if([_RedIndex containsObject:Index]) {
        NSArray *subviews = [cellview subviews];
        NSTextField *txtField = subviews[0];
        txtField.drawsBackground = YES;
        txtField.backgroundColor = [NSColor systemRedColor];
        txtField.textColor = [NSColor colorWithSRGBRed:0 green:0 blue:0 alpha:100];
    }
    else if([_colorGrayIndex containsObject:Index]) {
        NSArray *subviews = [cellview subviews];
        NSTextField *txtField = subviews[0];
        txtField.drawsBackground = YES;
        txtField.backgroundColor = [NSColor systemGrayColor];
        txtField.textColor = [NSColor colorWithSRGBRed:0 green:0 blue:0 alpha:100];
    }
    [_lock unlock];
    
    
  

    
    
    return cellview;
}
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    //return [_data count];
    return [data count];
}

-(void)setRedData:(NSArray*)Indata withYellowData:(NSArray*) yellowData withGreenData:(NSArray*) GreenData withGrayData:(NSArray*) GrayData{
    
    [_lock lock];
   
    [_RedIndex removeAllObjects];
    
    [_RedIndex setArray:Indata];
    
    [_colorYellowIndex removeAllObjects];
    
    [_colorYellowIndex setArray:yellowData];
    
    [_colorGreenIndex removeAllObjects];
    
    [_colorGreenIndex setArray:GreenData];
    
    [_colorGrayIndex removeAllObjects];
    
    [_colorGrayIndex setArray:GrayData];
    
    [_lock unlock];
}
-(void)setData:(NSArray*)Indata{
    
    [_lock lock];
    if (data == nil) {
        data = [[NSMutableArray alloc] init];
    }
    [data removeAllObjects];
    [data setArray:Indata];
    
    
    [_colorGreenIndex removeAllObjects];
    [_lock unlock];
}
@end
