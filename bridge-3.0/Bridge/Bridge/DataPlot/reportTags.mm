//
//  reportTags.m
//  Bridge
//
//  Created by RyanGao on 2020/11/5.
//  Copyright © 2020 RyanGao. All rights reserved.
//

#import "reportTags.h"
#import "defineHeader.h"
//#import "../SCparseCSV.framework/Headers/parseCSV.h"
#import "parseCSV.h"
#import "SCRedis.framework/Headers/RedisInterface.hpp"
#import "SCZmq.framework/Headers/Client.h"

extern NSMutableDictionary *m_configDictionary;
extern Client *reportTagsClient;
extern RedisInterface *myRedis;

@interface reportTags ()
@property (nonatomic,strong)NSMutableArray *dataGroup;

@property (nonatomic,strong)NSMutableArray *colorRedIndex;  //不相同的item，后面追加的数据，显示红色
@property (nonatomic,strong)NSMutableArray *colorGreenIndex; //相同的item，显示绿色

@end

@implementation reportTags

- (void)windowDidLoad
{
    [super windowDidLoad];
    _colorRedIndex = [[NSMutableArray alloc] init];
    _colorGreenIndex = [[NSMutableArray alloc] init];
    [_labelDataSource setStringValue:@"--"];
    [_labelTestPlanFile setStringValue:@"--"];
    [_reportTagsWindow setLevel:kCGFloatingWindowLevel];
    _dataGroup = [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadGroupData:) name:kNotificationReloadReportTags object:nil];
    [self reloadGroupData:nil];
}

-(void)setlabelName
{
    [_labelDataSource setStringValue:[[m_configDictionary valueForKey:Load_Csv_Path] lastPathComponent]];
    if ([[m_configDictionary valueForKey:Load_Csv_Path] isEqual:@""])
    {
        [_labelDataSource setStringValue:[[m_configDictionary valueForKey:Load_Local_Csv_Path] lastPathComponent]];
    }
    
    [_labelTestPlanFile setStringValue:[[m_configDictionary valueForKey:Load_Script_Path] lastPathComponent]];
    
    //[_dataGroup addObjectsFromArray:@[@[@1,@12,@0],@[@2,@22666,@0],@[@3,@22444,@0]]];
}

-(void)AlertBox:(NSString *)msgTxt withInfo:(NSString *)strmsg
{
    NSAlert * alert = [[NSAlert alloc] init];
    alert.messageText = msgTxt;
    alert.informativeText = strmsg;
    [alert runModal];
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

-(void)reloadGroupData:(NSNotification *)nf
{
    [self setlabelName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExist = [fileManager fileExistsAtPath:KdataItemNamePath];
    if (!isExist)
    {
        [self AlertBox:@"Error:029" withInfo:[NSString stringWithFormat:@"File not Exist at path:%@",KdataItemNamePath]];
        return;
    }
    NSMutableArray *arrTmp = [NSMutableArray array];
     CSVParser *csvItem = [[CSVParser alloc]init];
     if ([csvItem openFile:KdataItemNamePath])
    {
        arrTmp = [csvItem parseFile];
    }
    [_dataGroup removeAllObjects];
   
    NSMutableArray *lastGroupName = [NSMutableArray array];
    int n_index=0;
    for (int i=0; i<[arrTmp count]; i++)
    {
        NSArray *itemName = [arrTmp[i][1] componentsSeparatedByString:@" "];
       
        NSString *currentTestName = itemName[0];
        NSString *currentSubTestName = @"";
        if ([itemName count]>1)
        {
            currentSubTestName = itemName[1];
        }
        else
        {
            currentSubTestName = itemName[0];
        }
        
        if ([currentSubTestName containsString:@"@"])
        {
            currentSubTestName = [currentSubTestName componentsSeparatedByString:@"@"][0];
        }
        else if ([currentSubTestName containsString:@"-"])
        {
            currentSubTestName = [currentSubTestName componentsSeparatedByString:@"-"][0];
        }
        NSString *currentGroup = [NSString stringWithFormat:@"%@ %@",currentTestName,currentSubTestName];
        if (![lastGroupName containsObject:currentGroup])
        {
            [_dataGroup addObject:arrTmp[i]];
            _dataGroup[n_index][0] = [NSNumber numberWithInt:n_index+1];
            _dataGroup[n_index][1] = currentTestName;
            _dataGroup[n_index][2] = currentSubTestName;
            n_index ++;
        }
        [lastGroupName addObject:currentGroup];
    }
    
    [_colorRedIndex removeAllObjects];
    [_colorGreenIndex removeAllObjects];
    BOOL m_loadScript = [[m_configDictionary valueForKey:Load_Script_Path] length]>0?TRUE:FALSE;
    if (m_loadScript)
    {
        NSArray *insightItemName = [m_configDictionary valueForKey:KItemNameInsight];
        NSString *insightItemNameStr = [insightItemName componentsJoinedByString:@";"];
        NSArray *scriptItemName = [m_configDictionary valueForKey:KItemNameScript];
        NSString *scriptItemNameStr = [scriptItemName componentsJoinedByString:@";"];
        for (int i=0; i<[_dataGroup count]; i++)
        {
            NSString * name = @"";
            if ([_dataGroup[i][2] isEqualTo:@""])
            {
                name = _dataGroup[i][1];
            }
            else
            {
                name = [NSString stringWithFormat:@"%@ %@",_dataGroup[i][1],_dataGroup[i][2]];
            }
            if ([insightItemNameStr containsString:name] && [scriptItemNameStr containsString:name])
            {
                [_colorGreenIndex addObject:[NSNumber numberWithInt:i]];
            }
            else if (![scriptItemNameStr containsString:name])
            {
                [_colorRedIndex addObject:[NSNumber numberWithInt:i]];
            }
            
        }
       
    }
   
    [self.groupTable reloadData];
}

- (IBAction)btCancel:(id)sender
{
   // [NSApp stopModalWithCode:NSModalResponseCancel];
   // [[sender window] orderOut:self];
    
    NSString *cmdKillPythonLaunch = @"ps -ef |grep -i python |grep -i report_targs_test |grep -v grep|awk '{print $2}' |xargs kill -9";
    system([cmdKillPythonLaunch UTF8String]);
    
    [_reportTagsWindow close];
    
}

- (IBAction)btExportExcel:(id)sender
{
   // [NSApp stopModalWithCode:NSModalResponseOK];
   // [[sender window] orderOut:self];
    NSMutableString *csvStr = [NSMutableString string];
    [csvStr appendString:[NSString stringWithFormat:@"Source,%@, \n",_labelDataSource.stringValue]];
    [csvStr appendString:[NSString stringWithFormat:@"Test Plan File,%@, \n",_labelTestPlanFile.stringValue]];
    [csvStr appendString:@"Index,Technology Tag,Coverage Tag\n"];
    for (int i=0; i<[_dataGroup count]; i++)
    {
        [csvStr appendString:[NSString stringWithFormat:@"%@,%@,%@\n",_dataGroup[i][0],_dataGroup[i][1],_dataGroup[i][2]]];
        
    }
    NSString *csvpath = @"/tmp/CPK_Log/temp/reporttags.csv";
    [csvStr writeToFile:csvpath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    
    NSDateFormatter* DateFomatter = [[NSDateFormatter alloc] init];
    [DateFomatter setDateFormat:@"yyyy_MM_dd-HH_mm_ss"];
    NSTimeZone *timezone = [[NSTimeZone alloc] initWithName:@"PST"];
    [DateFomatter setTimeZone:timezone];
    NSString* systemTime = [DateFomatter stringFromDate:[NSDate date]];
    
    NSString *outputExcelName = [NSString stringWithFormat:@"Tags_Report_%@.xlsx",systemTime];
    NSString *outputExcelPath = [NSString stringWithFormat:@"%@/CPK_Log/%@",[NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES)objectAtIndex:0],outputExcelName];
    [m_configDictionary setValue:outputExcelPath forKey:KreportTagsExcelPath];
    NSMutableArray *msgArrayR = [NSMutableArray arrayWithObjects:csvpath,outputExcelPath,outputExcelName,nil];
    NSString *itemNameR = @"generate_report_tags";
    [self sendDataToRedis:itemNameR withData:msgArrayR];
    [self sendReportTagsZmqMsg:itemNameR];
    [_reportTagsWindow close];
    
}
-(NSString *)sendReportTagsZmqMsg:(NSString *)name  //
{
    int ret = [reportTagsClient SendCmd:name];
    if (ret > 0)
    {
        NSString * response = [reportTagsClient RecvRquest:1024];
        if (!response)
        {
            NSLog(@"zmq report tags for python error");
        }
        NSLog(@"app->get response from report tags python: %@",response);
        return response;
    }
    return nil;
}

-(void)sendDataToRedis:(NSString *)name withData:(NSMutableArray *)arrData
{
    if (myRedis)
    {
         myRedis->SetString([name UTF8String],[[NSString stringWithFormat:@"%@",arrData] UTF8String]);
    }
    else
    {
        [self AlertBox:@"Error:027" withInfo:@"Redis server is shut down.!!!"];
    }
    NSLog(@">>set name to redis:%@  %zd",name,[arrData count]);
}

#pragma mark TableView Datasource & delegate

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [_dataGroup count];
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString *columnIdentifier = [tableColumn identifier];
    NSTableCellView *view = [_groupTable makeViewWithIdentifier:columnIdentifier owner:self];
    NSUInteger index = -1;
    
    if ([columnIdentifier isEqualToString:@"index"])
        {
            index = 0;
            NSArray *subviews = [view subviews];
            NSTextField *txtField = subviews[0];
            if ([_colorRedIndex count]>0 || [_colorGreenIndex count]>0)
            {
                if ([_colorGreenIndex containsObject:[NSNumber numberWithInteger:row]])
                  {
                     txtField.drawsBackground = YES;
                     txtField.backgroundColor = [NSColor greenColor];
                  }

                if ([_colorRedIndex containsObject:[NSNumber numberWithInteger:row]])
                   {
                      txtField.drawsBackground = YES;
                      txtField.backgroundColor = [NSColor systemRedColor];
                   }
                 if (![_colorGreenIndex containsObject:[NSNumber numberWithInteger:row]] && ![_colorRedIndex containsObject:[NSNumber numberWithInteger:row]])
                      {
                          txtField.drawsBackground = YES;
                          txtField.backgroundColor = [NSColor grayColor];
                      }
                
            }
            else
            {
                txtField.drawsBackground = YES;
                txtField.backgroundColor = [NSColor whiteColor];
            }
        }
    
    if ([columnIdentifier isEqualToString:@"technology"])
       {
            index = 1;
       }
    if ([columnIdentifier isEqualToString:@"coverage"])
       {
            index = 2;
       }
    
    /*if ([columnIdentifier isEqualToString:@"checked"]) {
        NSArray *subviews = [view subviews];
        NSButton *checkBoxField = subviews[0];
        checkBoxField.tag = row;
        checkBoxField.target = self;
        [checkBoxField setAction:@selector(btnClickCheck:)];
        index = 2;
        if ([[_dataGroup objectAtIndex:row] count]>=index)
        {
            [checkBoxField setState:[[_dataGroup objectAtIndex:row][index] intValue]];
        }
        
        if ([arr_disableCheckBox containsObject:[NSNumber numberWithInteger:row]])
        {
            [checkBoxField setEnabled:NO];
        }
        else
        {
            [checkBoxField setEnabled:YES];
        }
        
        
        return view;
        
    }*/
    if ([[_dataGroup objectAtIndex:row] count]>index)
    {
        [[view textField] setStringValue:[_dataGroup objectAtIndex:row][index]];
    }
    else
    {
         [[view textField] setStringValue:@""];
    }
    return view;
}
@end
