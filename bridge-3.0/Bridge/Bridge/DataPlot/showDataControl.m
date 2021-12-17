//
//  showDataControl.m
//  Bridge
//
//  Created by RyanGao on 2020/8/7.
//  Copyright © 2020 RyanGao. All rights reserved.
//

#import "showDataControl.h"
//#import "../SCparseCSV.framework/Headers/parseCSV.h"
#import "parseCSV.h"
#import "defineHeader.h"
#import "ShowData.h"

@interface showDataControl ()
{
    //Added By Vito 20210305
    NSMutableArray *sourceData;
    NSMutableArray*searchExceptIndex;
    //Add end
    
    NSMutableArray *showData;
    NSMutableArray *showDataBackup;
    int m_sortnum;
}
@property (weak) IBOutlet NSTableView *showDataView;


@end

@implementation showDataControl

-(instancetype)init
{
    self = [super init];
    if (self)
    {
       
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    showData = [[NSMutableArray alloc] init];
    showDataBackup = [[NSMutableArray alloc] init];
    
    //Added By Vito 20210305
    sourceData =[[NSMutableArray alloc] init];
    searchExceptIndex =[[NSMutableArray alloc] init];
    //Add end
    
     [_showDataWin setLevel:kCGFloatingWindowLevel];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(readCsvData:) name:kNotificationShowData object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnSearchFilter:) name:kNotificationShowDataFilterMsg object:nil];
    
    
    m_sortnum = 0;
    [self.showDataView setTarget:self];
    [self.showDataView setAction:@selector(ClickOnTableViewDouble:)];
    [self.showDataView setDoubleAction:@selector(ClickOnTableViewDouble:)];

}

-(BOOL)isPureInt:(NSString *)string
{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

-(BOOL)isPureFloat:(NSString *)string
{
    NSScanner* scan = [NSScanner scannerWithString:string];
    float val;
    return [scan scanFloat:&val] && [scan isAtEnd];
}




-(void)sortingData:(int)flag
{
    
    if (flag>0)  //max to min
    {
        
        NSMutableArray * resultArr = [NSMutableArray array];
        //[resultArr setArray:showDataBackup];
        [resultArr setArray:sourceData];
       
        
       // NSArray *sortedArray = [resultArr sortedArrayUsingSelector:@selector(compareSort:)];
        NSArray *sortedArray = [resultArr sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
        {
            NSString *left = obj1[2];
            NSString *right = obj2[2];
            if (([self isPureInt:left] || [self isPureFloat:left]) && ([self isPureInt:right] || [self isPureFloat:right]))
            {
                float leftNum = [left floatValue];
                float rightNum = [right floatValue];
                if (leftNum <rightNum)
                {
                    return NSOrderedDescending;
                }
                else if(leftNum > rightNum)
                {
                    return NSOrderedAscending;
                }
                else
                {
                    return NSOrderedSame;
                }
                
            }
            else
            {
                NSComparisonResult result = [left compare:right];
                return result;
            }
            
           }];
        
        
        NSMutableArray * showDataSort = [[NSMutableArray alloc] init];
        for (NSMutableArray* line in sortedArray) {
            if(![searchExceptIndex containsObject: line[0] ]){
                [showDataSort addObject:line];
            }
        }
        [showData removeAllObjects];
        [showData setArray:showDataSort];
        
    }
    else if (flag<0) // min to max
    {
       NSMutableArray * resultArr = [NSMutableArray array];
       [resultArr setArray:showData];
       
       NSArray *sortedArray = [resultArr sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
       {
           NSString *left = obj1[2];
           NSString *right = obj2[2];
           
           if (([self isPureInt:left] || [self isPureFloat:left]) && ([self isPureInt:right] || [self isPureFloat:right]))
           {
               float leftNum = [left floatValue];
               float rightNum = [right floatValue];
               if (leftNum <rightNum)
               {
                   return NSOrderedAscending;
               }
               else if(leftNum > rightNum)
               {
                   return NSOrderedDescending;
               }
               else
               {
                   return NSOrderedSame;
               }
           }
           else
           {
               NSComparisonResult result = [right compare:left];
               return result;
            }
          }];
        NSMutableArray * showDataSort = [[NSMutableArray alloc] init];
        for (NSMutableArray* line in sortedArray) {
            if(![searchExceptIndex containsObject: line[0] ]){
                [showDataSort addObject:line];
            }
        }
        [showData removeAllObjects];
        [showData setArray:showDataSort];
               
        
        
    }
    else  // go back
    {

        NSMutableArray * showDataSort = [[NSMutableArray alloc] init];
        for (NSMutableArray* line in sourceData) {
            if(![searchExceptIndex containsObject: line[0] ]){
                [showDataSort addObject:line];
            }
        }
        [showData removeAllObjects];
        [showData setArray:showDataSort];
        
        
    }
}
- (void)OnSearchFilter:(NSNotification *)nf {
    
    //Add search Function Call Same Flash Function

    NSMutableArray* arryShow = [[NSMutableArray alloc] init];

    for (int i=0; i<[sourceData count]; i++) {
        bool isNeed = true;
        NSNumber* checkIndex = sourceData[i][0];
        
        
        if (isNeed && [searchExceptIndex count] >0 ) {
            isNeed = ![searchExceptIndex containsObject:checkIndex];
        }
        
        
        
        if(isNeed){
            
            [arryShow addObject:sourceData[i]];
        }
    }
    
    [showData setArray:arryShow];
    
    [self.showDataView reloadData];
    
    
    
    
    
}
- (IBAction)OnClearSearchSn:(id)sender {
    [self.searchField setStringValue:@""];
    [self.searchField resetSearchButtonCell];

    [searchExceptIndex removeAllObjects];

    [self OnSearchFilter:nil];
}
- (IBAction)OnSearchSn:(id)sender {
    NSString *content = @"";
    if(sender){
        content = [sender stringValue];
        
    }
    if ([content isNotEqualTo:@""])
    {
        
        
        [searchExceptIndex removeAllObjects];
        
        
        
        
        for (int i =0; i<[sourceData count]; i++) {
            
            NSString * itemName = sourceData[i][1];
            
            if(![itemName.lowercaseString containsString:content.lowercaseString]){
              
                [searchExceptIndex addObject:sourceData[i][0]];
            }
        }
        
        [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationShowDataFilterMsg object:nil userInfo:nil];
    }
    else{
        if ([searchExceptIndex count]>0) {
            [searchExceptIndex removeAllObjects];
            [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationShowDataFilterMsg object:nil userInfo:nil];
        }
    }
    
}

-(void)ClickOnTableViewDouble:(id)sender
{
   NSInteger row = [self.showDataView selectedRow];
   if (row == -1)
   {
       NSInteger col = [self.showDataView selectedColumn];
       if (col ==2)
       {
           if (showData.count>0)
           {
               m_sortnum ++;
               NSLog(@"--click time: %d  %zd",m_sortnum,showData.count);
               if (m_sortnum %3 ==1)
               {
                   [self sortingData:1];
                   
               }
               else if (m_sortnum %3 == 2)
               {
                   [self sortingData:-1];
               }
               else if (m_sortnum %3 == 0)
               {
                   [self sortingData:0];
                   m_sortnum = 0;
               }
               [self.showDataView reloadData];
              
           }
           
       }
       
   }
       
}

-(void)readCsvData:(NSNotification *)nf
{
    NSString * name = [nf name];
    if ([ name isEqualToString:kNotificationShowData])
    {
       
        NSDictionary * dic = [nf userInfo];
        NSArray * snArray = [dic valueForKey:kSerial_number];
        NSArray * dataArray = [dic valueForKey:kData_Value];
        
        NSMutableArray *tmpSN =[NSMutableArray array];
        NSMutableArray *tmpdata =[NSMutableArray array];
        NSMutableArray *indexData =[NSMutableArray array];
        
        int j = 0;
        for (int i=tb_data_start; i<snArray.count; i++)
        {
            if ([snArray[i] isNotEqualTo:@"Start_Data"] && [snArray[i] isNotEqualTo:@"End_Data"] && [snArray[i] isNotEqualTo:@""] && [snArray[i] isNotEqualTo:@"SerialNumber"] && [dataArray[i] isNotEqualTo:@""])
            {
                [tmpSN addObject:snArray[i]];
                [tmpdata addObject:dataArray[i]];
                
                [indexData addObject:@(j)];
                j++;
            }
        }
        
        m_sortnum = 0;
        NSMutableArray *arrTmp = [NSMutableArray array];
        
        [arrTmp addObject:indexData];
        [arrTmp addObject:tmpSN];
        [arrTmp addObject:tmpdata];
        [showData removeAllObjects];
        [showDataBackup removeAllObjects];
        [showData setArray:[self reverseArray:arrTmp]];
        [showDataBackup setArray:[self reverseArray:arrTmp]];
        
        [sourceData setArray:[self reverseArray:arrTmp]];

        
        [self OnClearSearchSn:nil];
        
        
        
        
        [self.showDataView reloadData];
        
    }
}


-(NSArray *)reverseArray:(NSArray *)array
{
    NSArray *tmpArray = array[1];
    NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:tmpArray.count];
    for (NSInteger i=0; i<tmpArray.count; i++) {
        NSMutableArray *lineArray = [NSMutableArray arrayWithCapacity:array.count];
        for (NSInteger j=0; j<array.count; j++) {
            [lineArray addObject:@""];
        }
        [newArray addObject:lineArray];
    }
    
    for (NSInteger i=0; i<array.count; i++) {
        for (NSInteger j=0; j<tmpArray.count; j++) {
            if ([array[i] count]<=j)
            {
                newArray[j][i] = @"";
            }
            else
            {
                newArray[j][i] = array[i][j];
            }
        }
    }
    return newArray;
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return showData.count;
}

/*
-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
     NSString *columnIdentifier = [tableColumn identifier];
     NSTableCellView *view = [_showDataView makeViewWithIdentifier:columnIdentifier owner:self];
    NSUInteger index = -1;
    
    if ([columnIdentifier isEqualToString:@"sn"])
    {
        index = 0;
    }
     if ([columnIdentifier isEqualToString:@"value"])
     {
         index = 1;
     }
    
    
    if ([[showData objectAtIndex:row] count]>index)
    {
        [[view textField] setStringValue:[showData objectAtIndex:row][index]];
    }
    else
    {
         [[view textField] setStringValue:@""];
    }
    return view;
}
 */

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    
    NSString *columnIdentifier = [tableColumn identifier];
    if ([columnIdentifier isEqualToString:@"sn"])
    {
        return [showData objectAtIndex:row][1];
    }
    else if ([columnIdentifier isEqualToString:@"value"])
    {
        return [showData objectAtIndex:row][2];
    }
    else if ([columnIdentifier isEqualToString:@"no"])
    {
        return [showData objectAtIndex:row][0];
    }
    return @"";
}
 

- (IBAction)btOk:(id)sender
{
    [self.showDataWin close];
}
@end
