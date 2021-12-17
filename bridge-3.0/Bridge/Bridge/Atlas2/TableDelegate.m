//
//  testplanTableDelegate.m
//  Bridge
//
//  Created by vito xie on 2021/5/20.
//  Copyright © 2021 RyanGao. All rights reserved.
//

#import "TableDelegate.h"

@interface TableDelegate ()

@property NSMutableArray* arryBlueIndex ;
@property NSMutableArray* arryGrayIndex ;
@property NSMutableArray* arryRedIndex  ;
@property NSMutableArray* arryYellowIndex  ;

@property NSLock *lock;

@property NSMutableArray* SyncArray  ;
@property NSMutableDictionary* SyncDict  ;
@property NSMutableArray* limiData;

@property NSMutableArray* modifyIndex  ;
@property NSMutableDictionary* dictMappingIndex  ;
@property NSMutableDictionary* dictMappingIndexFlag  ;
@end

@implementation TableDelegate



- (instancetype)initWithView:(NSTableView*)Inview{
    view = Inview;
    if (data == nil) {
        data = [[NSMutableArray alloc] init];
        showdata =[[NSMutableArray alloc] init];
        _arryBlueIndex = [[NSMutableArray alloc]init];
        _arryGrayIndex = [[NSMutableArray alloc]init];
        _arryYellowIndex = [[NSMutableArray alloc]init];
        _arryRedIndex = [[NSMutableArray alloc]init];
        
        
        
        
        _limiData =[[NSMutableArray alloc]init];
        _modifyIndex=[[NSMutableArray alloc]init];
        _dictMappingIndex = [[NSMutableDictionary alloc] init];
        _dictMappingIndexFlag = [[NSMutableDictionary alloc] init];
        
        _SyncArray = [[NSMutableArray alloc] init];
        
        _lock = [[NSLock alloc] init];
        
    }
    return self;
}

-(NSString*) generateModifyInfo{
    NSString * modifyInfo = nil;
    for (int i=0; i< [_modifyIndex count]; i++) {
        if (i ==0){
            modifyInfo =[NSString stringWithFormat:@"%d|%@|%@",[_modifyIndex[i] intValue]-1,data[[_modifyIndex[i] intValue]-1][5],data[[_modifyIndex[i] intValue]-1][6]];
            
            
            
        }else{
            modifyInfo =[NSString stringWithFormat:@"%@;%d|%@|%@",modifyInfo,[_modifyIndex[i] intValue]-1,data[[_modifyIndex[i] intValue]-1][5],data[[_modifyIndex[i] intValue]-1][6]];
        }
    }
    return modifyInfo;
    
}

-(void)setDataSingle:(NSArray*)Indata{
    [_lock lock];
    [data removeAllObjects];
    [showdata removeAllObjects];
    
    [_arryBlueIndex removeAllObjects];
    [_arryGrayIndex removeAllObjects];
    [_arryYellowIndex removeAllObjects];
    [_arryRedIndex removeAllObjects];
    [_dictMappingIndex removeAllObjects];
    
    
    [_modifyIndex removeAllObjects];
    [_dictMappingIndexFlag removeAllObjects];
    [_limiData removeAllObjects];
    [data setArray:Indata];
    [showdata setArray:Indata];
    [_SyncArray removeAllObjects];
    [_lock unlock];
}
-(bool)isDataLoaded{
    
    if ([data count]>0) {
        return true;
    }
    else{
        
        return false;
    }
}
-(NSArray*)getData{
    
    return data;
}

-(void)setDataSingleInfo:(NSArray*)Greendata withYellow:(NSArray*)Yellowdata withGray:(NSArray*)Graydata withLimitData:(NSArray*)Limitdata  withRed:(NSArray*)Reddata{
    
    [_lock lock];
    
    [_arryBlueIndex removeAllObjects];
    [_arryGrayIndex removeAllObjects];
    [_arryYellowIndex removeAllObjects];
    [_arryRedIndex removeAllObjects];
    
    [_dictMappingIndex removeAllObjects];
    [_dictMappingIndexFlag removeAllObjects];
    
    [_limiData removeAllObjects];
    
    [_arryBlueIndex setArray:Greendata];
    [_arryGrayIndex setArray:Graydata];
    [_arryYellowIndex setArray:Yellowdata];
    [_arryRedIndex setArray:Reddata];
    
    
    
    [_limiData setArray:Limitdata];
    
    [_SyncArray removeAllObjects];
    
    [_lock unlock];
}
-(void)reset{
    
    [_lock lock];
    
    [_arryBlueIndex removeAllObjects];
    [_arryGrayIndex removeAllObjects];
    [_arryYellowIndex removeAllObjects];
    [_arryRedIndex removeAllObjects];
    
    [_dictMappingIndex removeAllObjects];
    [_dictMappingIndexFlag removeAllObjects];
    
    [_limiData removeAllObjects];
    
    
    [data removeAllObjects];
    [showdata removeAllObjects];
    
    [_modifyIndex removeAllObjects];
    [_limiData removeAllObjects];
    [_SyncArray removeAllObjects];
    
    
    [_lock unlock];
}

-(void)setData:(NSArray*)Indata withGreen:(NSArray*)Greendata withRed:(NSArray*)Reddata withGray:(NSArray*)Graydata withYellow:(NSArray*)Yellowdata withLimitData:(NSArray*)Limitdata{
    
    [data removeAllObjects];
    
    [_arryBlueIndex removeAllObjects];
    [_arryGrayIndex removeAllObjects];
    [_arryYellowIndex removeAllObjects];
    
    [_modifyIndex removeAllObjects];
    [_dictMappingIndex removeAllObjects];
    [_dictMappingIndexFlag removeAllObjects];
    
    [_limiData removeAllObjects];
    
    [data setArray:Indata];
    [_arryBlueIndex setArray:Greendata];
    [_arryGrayIndex setArray:Graydata];
    [_arryRedIndex setArray:Reddata];
    [_arryYellowIndex setArray:Reddata];
    
    [_SyncArray removeAllObjects];
    
    
    [_limiData setArray:Limitdata];
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    
    
    [_lock lock];
    NSString *columnIdentifier = [tableColumn identifier];
    NSTableCellView *cellview = [view makeViewWithIdentifier:columnIdentifier owner:self];
    NSUInteger index = -1;
    NSArray *subviews = [cellview subviews];
    NSTextField *txtField = subviews[0];
    bool isModify = false;
    int currentRowIndex = [[showdata objectAtIndex:row][0] intValue] ;
    
    if ([_modifyIndex containsObject:[showdata objectAtIndex:row][0]]){
        isModify = true;
    }
    

    else if ([columnIdentifier isEqualToString:@"TESTNAME"])
    {
        index = 0;

        txtField.drawsBackground = NO;
        txtField.textColor= NSColor.labelColor;
        [txtField setStringValue:[showdata objectAtIndex:row][index]];
    }
    else if ([columnIdentifier isEqualToString:@"SUBTESTNAME"])
    {
        index = 1;

        txtField.drawsBackground = NO;
        txtField.textColor= NSColor.labelColor;
        [txtField setStringValue:[showdata objectAtIndex:row][index]];
    }
    else if ([columnIdentifier isEqualToString:@"SUBSUBTESTNAME"])
    {
        index = 2;

        txtField.drawsBackground = NO;
        txtField.textColor= NSColor.labelColor;
        [txtField setStringValue:[showdata objectAtIndex:row][index]];
    }
    else if ([columnIdentifier isEqualToString:@"DESCRIPTION"])
    {
        index = 3;

        txtField.drawsBackground = NO;
        txtField.textColor= NSColor.labelColor;
        [txtField setStringValue:[showdata objectAtIndex:row][index]];
    }
    else if ([columnIdentifier isEqualToString:@"FUNCTION"])
    {
        index = 4;

        txtField.drawsBackground = NO;
        txtField.textColor= NSColor.labelColor;
        [txtField setStringValue:[showdata objectAtIndex:row][index]];
    }
    else if ([columnIdentifier isEqualToString:@"TIMEOUT"])
    {
        index = 5;

        txtField.drawsBackground = NO;
        txtField.textColor= NSColor.labelColor;
        [txtField setStringValue:[showdata objectAtIndex:row][index]];
    }
    else if ([columnIdentifier isEqualToString:@"PARAM1"])
    {
        index = 6;

        txtField.drawsBackground = NO;
        txtField.textColor= NSColor.labelColor;
        [txtField setStringValue:[showdata objectAtIndex:row][index]];
    }
    else if ([columnIdentifier isEqualToString:@"PARAM2"])
    {
        index = 7;

        txtField.drawsBackground = NO;
        txtField.textColor= NSColor.labelColor;
        [txtField setStringValue:[showdata objectAtIndex:row][index]];
    }
    else if ([columnIdentifier isEqualToString:@"UNIT"])
    {
        index = 8;

        txtField.drawsBackground = NO;
        txtField.textColor= NSColor.labelColor;
        [txtField setStringValue:[showdata objectAtIndex:row][index]];
    }
    else if ([columnIdentifier isEqualToString:@"LOW"])
    {
        index = 9;

        txtField.drawsBackground = NO;
        txtField.textColor= NSColor.labelColor;
        [txtField setStringValue:[showdata objectAtIndex:row][index]];
    }
    else if ([columnIdentifier isEqualToString:@"HIGH"])
    {
        index = 10;

        txtField.drawsBackground = NO;
        txtField.textColor= NSColor.labelColor;
        [txtField setStringValue:[showdata objectAtIndex:row][index]];
    }
    else if ([columnIdentifier isEqualToString:@"KEY"])
    {
        index = 11;

        txtField.drawsBackground = NO;
        txtField.textColor= NSColor.labelColor;
        [txtField setStringValue:[showdata objectAtIndex:row][index]];
    }
    else if ([columnIdentifier isEqualToString:@"VAL"])
    {
        index = 12;

        txtField.drawsBackground = NO;
        txtField.textColor= NSColor.labelColor;
        [txtField setStringValue:[showdata objectAtIndex:row][index]];
    }
    else if ([columnIdentifier isEqualToString:@"FAIL_COUNT"])
    {
        index = 13;

        txtField.drawsBackground = NO;
        txtField.textColor= NSColor.labelColor;
        [txtField setStringValue:[showdata objectAtIndex:row][index]];
    }
    else if ([columnIdentifier isEqualToString:@"NYQUIST_GROUP"])
    {
        index = 14;

        txtField.drawsBackground = NO;
        txtField.textColor= NSColor.labelColor;
        [txtField setStringValue:[showdata objectAtIndex:row][index]];
    }
    else if ([columnIdentifier isEqualToString:@"NYQUIST_PROPOSED_RATE"])
    {
        index = 15;

        txtField.drawsBackground = NO;
        txtField.textColor= NSColor.labelColor;
        [txtField setStringValue:[showdata objectAtIndex:row][index]];
    }
    
    

    if ([_arryBlueIndex containsObject:[showdata objectAtIndex:row][0] ]) {
        txtField.drawsBackground = YES;
        txtField.backgroundColor = [NSColor systemGreenColor];
         txtField.textColor = [NSColor colorWithSRGBRed:0 green:0 blue:0 alpha:100];
    }
    if ([_arryYellowIndex containsObject:[showdata objectAtIndex:row][0]])
    {
        if ([_modifyIndex containsObject:[showdata objectAtIndex:row][0]]) {
            txtField.drawsBackground = YES;
            txtField.backgroundColor = [NSColor systemGreenColor];
            txtField.textColor = [NSColor colorWithSRGBRed:0 green:0 blue:0 alpha:100];
        }
        else{
            txtField.drawsBackground = YES;
            txtField.backgroundColor = [NSColor systemYellowColor];
            txtField.textColor = [NSColor colorWithSRGBRed:0 green:0 blue:0 alpha:100];
        }
        

       
    }
    if([_arryRedIndex containsObject:[showdata objectAtIndex:row][0]])
    {
        txtField.drawsBackground = YES;
        txtField.backgroundColor = [NSColor systemRedColor];
        txtField.textColor = [NSColor whiteColor];
    }
    
    if([_arryGrayIndex containsObject:[showdata objectAtIndex:row][0]]){
        txtField.drawsBackground = YES;
        txtField.backgroundColor = [NSColor grayColor];
        txtField.textColor = [NSColor whiteColor];
        
    }
    
    [_lock unlock];
    
  

    
    
    return cellview;
}


-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{

    return [showdata count];
}

-(bool)ModifyAll{
    
    for (int i=0; i<[_arryYellowIndex count]; i++) {
        int rowIndex =[_arryYellowIndex[i] intValue];
        if ( ![_modifyIndex containsObject:@(rowIndex)] ) {
            [_modifyIndex addObject:@(rowIndex)];
        }
    }
    
    //[_SyncDict setValue:@(-1) forKey:@"sync"];
    [_SyncArray addObject:@{@"sync":@(-1)}];
    

    [view reloadData];
    
    return [_SyncArray count] >0 ? true : false;

}
- (bool)UnSyncLastStep {
    if ([_SyncArray count] >0) {
        
        NSDictionary* cur = [_SyncArray lastObject];
        if([cur[@"sync"]  isEqual:@(-1)]){
            
            // ALL
            [_modifyIndex removeAllObjects];
            
            
        }
        else{
            if( [_modifyIndex containsObject:cur[@"sync"]]){
                [_modifyIndex removeObject:cur[@"sync"]];
            }
            
        }
        [_SyncArray removeLastObject];
       
    }
    [view reloadData];
    return [_SyncArray count] >0 ? true : false;
}
-(bool)Modify{
    NSInteger row= [view selectedRow];
    
    if (row >=0) {
        int rowIndex= [showdata[row][0] intValue];
        
        if ( ![_modifyIndex containsObject:@(rowIndex)] ) {
            [_modifyIndex addObject:@(rowIndex)];
            [view reloadData];
        }
        
        [_SyncArray addObject:@{@"sync":@(rowIndex)}];
        
    }
    return [_SyncArray count] >0 ? true : false;
    
    
}

- (void)showGreen {
    [self changeShowData:_arryBlueIndex ];
    [view reloadData];
}
- (void)showYellow {
    
    [self changeShowData:_arryYellowIndex ];
    [view reloadData];
}
- (void)showRedAndGray {
    NSMutableArray * newShow = [[NSMutableArray alloc] init];
    [newShow addObjectsFromArray:_arryRedIndex];
    [newShow addObjectsFromArray:_arryGrayIndex];
    [self changeShowData:newShow ];
    [view reloadData];
}
- (void)showGray {
    [self changeShowData:_arryGrayIndex ];
    [view reloadData];
}
- (void)showAll {
    [_lock lock];
    [showdata removeAllObjects];
    [showdata setArray:data];
    [_lock unlock];
    [view reloadData];
    
}
-(void) changeShowData:(NSArray*)lines{
    [_lock lock];
    [showdata removeAllObjects];
    for (int i=0; i< [lines count]; i++) {
        int row = [lines[i] intValue]-1;
        [showdata addObject:data[row]];
    }
    [_lock unlock];
    
}


-(void)clickedRow{
    
    NSInteger row= [view selectedRow];
    
    int rowIndex= [data[row][0] intValue];
    
    if ([_dictMappingIndex count] >0 && [[_dictMappingIndex allKeys] containsObject:[NSString stringWithFormat:@"%@",@(rowIndex)] ]) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"testplan-limit" object:nil userInfo:@{@"index":_dictMappingIndex[[NSString stringWithFormat:@"%@",@(rowIndex)]]}];
    }

}
///for drag


@end
