//
//  keynote_skip_setting.m
//  Bridge
//
//  Created by RyanGao on 2020/8/11.
//  Copyright © 2020 RyanGao. All rights reserved.
//

#import "keynote_skip_setting.h"
#import "defineHeader.h"
//#import "../SCparseCSV.framework/Headers/parseCSV.h"
#import "parseCSV.h"
extern NSMutableDictionary *m_configDictionary;
extern int n_Start_Data_Col;
extern int n_Pass_Fail_Status;
extern int n_Product_Col;
extern int n_SerialNumber;
extern int n_SpecialBuildName_Col;
extern int n_Special_Build_Descrip_Col;
extern int n_StationID_Col;
extern int n_StartTime;
extern int n_Version_Col;
extern int n_Diags_Version_Col;
extern int n_OS_VERSION_Col;

extern NSMutableArray *_dataReverse;

@interface keynote_skip_setting ()
{
    NSMutableArray *arr_disableCheckBox;
}

@property (nonatomic,strong)NSMutableArray *dataGroup;
@property (nonatomic,strong)NSMutableArray *selectKItem;

@end

@implementation keynote_skip_setting


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
    _dataGroup = [[NSMutableArray alloc] init];
    _selectKItem = [[NSMutableArray alloc] init];
    
    arr_disableCheckBox = [[NSMutableArray alloc] init];
    
     [_skipSettingsWin setLevel:kCGFloatingWindowLevel];
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadGroupData:) name:kNotificationReloadSkipSettingData object:nil];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    
    
    
    [self initAllCtl];
    
       //[_dataGroup addObjectsFromArray:@[@[@1,@12,@0],@[@2,@22666,@0],@[@3,@22444,@0]]];
       [self reloadGroupData:nil];
    
}

-(void)initAllCtl
{
    [self.txtCpkH setStringValue:@"10"];
    [_skipOneLimitYes setState:1];
    [m_configDictionary setValue:[NSNumber numberWithInt:1] forKey:KskipOneLimitYes];
 
    [_skipOneLimitNo setState:0];
    [m_configDictionary setValue:[NSNumber numberWithInt:0] forKey:KskipOneLimitNo];
    
    [_skipHTHLDYes setState:1];
    [m_configDictionary setValue:[NSNumber numberWithInt:1] forKey:KskipHTHLDYes];
    
    [_skipHTHLDNo setState:0];
    [m_configDictionary setValue:[NSNumber numberWithInt:0] forKey:KskipHTHLDNo];
}


-(void)reloadGroupData:(NSNotification *)nf
{
    /*int check_1bYes = [[m_configDictionary valueForKey:Kitem1bYes] intValue];
    //int check_1bNo = [[m_configDictionary valueForKey:Kitem1bNo] intValue];
    if (check_1bYes ==1)
    {
        [_skipHTHLDYes setEnabled:NO];
        [_skipHTHLDNo setEnabled:NO];
        [_skipHTHLDNo setState:0];
        [_skipHTHLDYes setState:0];
        [m_configDictionary setValue:[NSNumber numberWithInt:0] forKey:KskipHTHLDYes];
        [m_configDictionary setValue:[NSNumber numberWithInt:0] forKey:KskipHTHLDNo];
    }
    else
    {
        [_skipHTHLDYes setEnabled:YES];
        [_skipHTHLDNo setEnabled:YES];
        
        [_skipHTHLDYes setState:1];
        [m_configDictionary setValue:[NSNumber numberWithInt:1] forKey:KskipHTHLDYes];
              
        [_skipHTHLDNo setState:0];
        [m_configDictionary setValue:[NSNumber numberWithInt:0] forKey:KskipHTHLDNo];
        
    }
    */
    
    NSLog(@"---reloadGroupData--");
    //NSString *desktopPath = [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSString *csv_temp_Item_Path = @"/tmp/CPK_Log/Temp/keynote_data_temp_select_k.csv";//[NSString stringWithFormat:@"%@/CPK_Log/Temp/keynote_data_temp_select_k.csv",desktopPath];  //k 勾选的item，需要强制生成keynote
     CSVParser *csvItem = [[CSVParser alloc]init];
     [_selectKItem removeAllObjects];
    [arr_disableCheckBox removeAllObjects];
    
     if ([csvItem openFile:csv_temp_Item_Path])
       {
           _selectKItem = [csvItem parseFile];
       }
       if (_selectKItem.count<1)
       {
           NSLog(@"-no select k  name");
       }
    
    NSString *item_group_Path = @"/tmp/CPK_Log/temp/items_for_skip_setting.csv";//[NSString stringWithFormat:@"%@/CPK_Log/temp/items_for_skip_setting.csv",desktopPath];
    [_dataGroup removeAllObjects];
    NSMutableArray *tmpArr = [NSMutableArray array];
    CSVParser *csvItemGroup = [[CSVParser alloc]init];
    if ([csvItemGroup openFile:item_group_Path])
    {
        tmpArr = [csvItemGroup parseFile];
    }
    if (tmpArr.count<1)
    {
        NSLog(@"-no data group");
        return;
    }
    
    
    int n_index=0;
    NSMutableArray *lastGroup = [NSMutableArray array];
#if 1
    for (int i=0; i<[tmpArr count]; i++)
    {
        NSArray *itemName = [tmpArr[i][1] componentsSeparatedByString:@" "];
        NSString *currentGroup = itemName[0];
        if (![lastGroup containsObject:currentGroup])
        {
            [_dataGroup addObject:tmpArr[i]];
            _dataGroup[n_index][0] = [NSNumber numberWithInt:n_index+1];
            _dataGroup[n_index][1] = currentGroup;  //group
            _dataGroup[n_index][2] = [NSNumber numberWithInt:0];
            
            if ([currentGroup isEqualToString:@"FATAL"] || [currentGroup isEqualToString:@"Process"])
            {
                [arr_disableCheckBox addObject:[NSNumber numberWithInt:n_index]];
                _dataGroup[n_index][2] = [NSNumber numberWithInt:1];
            }
            n_index ++;
            
        }
        [lastGroup addObject:currentGroup];
    }
    
#else
    if ([_selectKItem count]>0)
    {
        NSMutableArray *selectArrK = [NSMutableArray array];
        for (int j = 0; j<[_selectKItem count]; j++)
        {
            NSArray *itemKSelect = [_selectKItem[j][0] componentsSeparatedByString:@" "];
            [selectArrK addObject:itemKSelect[0]];
        }
               
        for (int i=0; i<[tmpArr count]; i++)
        {
            NSArray *itemName = [tmpArr[i][1] componentsSeparatedByString:@" "];
            NSString *currentGroup = itemName[0];
            if ([currentGroup isNotEqualTo:lastGroup] && ![selectArrK containsObject:currentGroup])
            {
               [_dataGroup addObject:tmpArr[i]];
               _dataGroup[n_index][0] = [NSNumber numberWithInt:n_index+1];
               _dataGroup[n_index][1] = currentGroup;  //group
               _dataGroup[n_index][2] = [NSNumber numberWithInt:0];
               n_index ++;
            }
            lastGroup = currentGroup;
        }
    
    }
    else
    {
        for (int i=0; i<[tmpArr count]; i++)
        {
            NSArray *itemName = [tmpArr[i][1] componentsSeparatedByString:@" "];
            NSString *currentGroup = itemName[0];
            if ([currentGroup isNotEqualTo:lastGroup])
            {
                [_dataGroup addObject:tmpArr[i]];
                _dataGroup[n_index][0] = [NSNumber numberWithInt:n_index+1];
                _dataGroup[n_index][1] = currentGroup;  //group
                _dataGroup[n_index][2] = [NSNumber numberWithInt:0];
                n_index ++;
            }
            lastGroup = currentGroup;
           
        }
        
    }
#endif
   
    [self.groupTable reloadData];
}

- (IBAction)btOk:(id)sender
{
    NSString *high = [self.txtCpkH stringValue];
    if ([self isPureInt:high] || [self isPureFloat:high])
    {
        [m_configDictionary setValue:high forKey:kcpkKeynoteHighThd];
        
        //========生成新的数据
        NSMutableArray *skipItem = [NSMutableArray array];  // need skip group
        for (int i=0; i<[_dataGroup count]; i++)
        {
            if ([_dataGroup[i][2] intValue] == 1)
            {
                [skipItem addObject:_dataGroup[i][1]];
            }
            
        }
        
        NSMutableArray *selectItemK = [NSMutableArray array];  //UI select K 强制生成keynote
        if ([_selectKItem count]>0)
        {
            for (int j = 0; j<[_selectKItem count]; j++)
            {
                [selectItemK addObject:_selectKItem[j][0]];
            }
        }
        
        int i_col = 0;
        NSMutableArray *csvTmpData = [NSMutableArray array];
        for(NSMutableArray *lineArray in _dataReverse)
           {
               if (i_col <n_Start_Data_Col)
               {
                   [csvTmpData addObject:_dataReverse[i_col]];
               }
               else
               {
                   if ([selectItemK containsObject:lineArray[tb_item]])  // K select 强制加进去
                   {
                       ////
                       if (([lineArray[tb_apply] intValue]==1)&&([lineArray[tb_keynote] intValue]==1))  //当k列与apply 都选中，用新limit
                       {
                           NSMutableArray *tmp_arr =[NSMutableArray array];
                           for (int m = 0; m<[_dataReverse[i_col] count]; m++)
                           {
                               if (m==tb_lower)
                               {
                                   NSString *new_lsl = _dataReverse[i_col][tb_lsl];
                                   [tmp_arr addObject:new_lsl];
                               }
                               else if (m==tb_upper)
                               {
                                   NSString *new_usl = _dataReverse[i_col][tb_usl];
                                   [tmp_arr addObject:new_usl];
                               }
                               else
                               {
                                   [tmp_arr addObject:_dataReverse[i_col][m]];
                               }
                           }
                           [csvTmpData addObject:tmp_arr];
                       }
                       else
                       {
                           [csvTmpData addObject:_dataReverse[i_col]];
                       }
                       
                   }
                   else
                   {
                       NSArray *item = [lineArray[tb_item] componentsSeparatedByString:@" "];
                       NSString *groupN = item[0];
                       
                       if (![skipItem containsObject:groupN])  //skip setting group 去掉
                       {
                           [csvTmpData addObject:_dataReverse[i_col]];
                       }
                   }
               }
               i_col++;
           }
        
        NSMutableArray *csvInsight = [NSMutableArray arrayWithArray:[self reverseArray:csvTmpData]];
        [csvInsight removeObjectsInRange:NSMakeRange(7,30)];

        NSMutableString *csvStr = [NSMutableString string];
        int i=0;
        for(NSMutableArray *lineArray in csvInsight)
        {
            NSString *arrayString;
            if (i==0)
            {
                int len = (int)[lineArray count] -n_Start_Data_Col;
                [lineArray removeObjectsInRange:NSMakeRange(n_Start_Data_Col, len)];
                arrayString = [NSString stringWithFormat:@"%@,Parametric",[lineArray componentsJoinedByString:@","]];
            }
            else
            {
                arrayString = [lineArray componentsJoinedByString:@","];
            }
            [csvStr appendFormat:@"%@\n",arrayString];
            i++;
        }
        NSError *error = nil;
        //NSString *desktopPath = [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES)objectAtIndex:0];
        NSString *csv_temp_Path = @"/tmp/CPK_Log/Temp/keynote_data_temp.csv";//[NSString stringWithFormat:@"%@/CPK_Log/Temp/keynote_data_temp.csv",desktopPath];
        [csvStr writeToFile:csv_temp_Path atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (error)
        {
            NSLog(@"write csv for keynote failed: %@",csv_temp_Path);
        }
        else
        {
            NSLog(@"write csv for keynote successful: %@",csv_temp_Path);
        }
        
        [m_configDictionary setValue:@"OK" forKey:Kkeynote_skip_setting_Cancel];
        [NSApp stopModalWithCode:NSModalResponseOK];
        [[sender window] orderOut:self];
        
    }
    else
    {
        [self AlertBox:@"Error:016" withInfo:@"Please input a number."];
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


- (IBAction)btCancel:(id)sender
{
    [self initAllCtl];
    [m_configDictionary setValue:@"Cancel" forKey:Kkeynote_skip_setting_Cancel];
    [NSApp stopModalWithCode:NSModalResponseCancel];
    [[sender window] orderOut:self];
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


-(void)AlertBox:(NSString *)msgTxt withInfo:(NSString *)strmsg
{
    NSAlert * alert = [[NSAlert alloc] init];
    alert.messageText = msgTxt;
    alert.informativeText = strmsg;
    [alert runModal];
}


- (IBAction)checkBox:(id)sender
{
    int check = (int)[sender state];
    switch ([sender tag])
    {
        case 20:
        {
            if (check)
            {
                [_skipOneLimitYes setState:check];
                [_skipOneLimitNo setState:!check];
            }
            else
            {
                [_skipOneLimitNo setState:check];
                [_skipOneLimitYes setState:!check];
                
            }
            
        }
            break;
        case 21:
        {
            if (check)
            {
                [_skipOneLimitNo setState:check];
                [_skipOneLimitYes setState:!check];

            }
            else
            {
                [_skipOneLimitNo setState:!check];
                [_skipOneLimitYes setState:check];
                
            }
            
        }
            break;
            
        case 22:
        {
            if (check)
            {
                [_skipHTHLDYes setState:check];
                [_skipHTHLDNo setState:!check];

            }
            else
            {
                [_skipHTHLDYes setState:!check];
                [_skipHTHLDNo setState:check];
                
            }
            
        }
            break;
         case 23:
            {
                if (check)
                {
                    [_skipHTHLDYes setState:!check];
                    [_skipHTHLDNo setState:check];

                }
                else
                {
                    [_skipHTHLDYes setState:check];
                    [_skipHTHLDNo setState:!check];
                    
                }
                
            }
                break;
          default:
                break;
            
    }
    
    [m_configDictionary setValue:[NSNumber numberWithInteger:[_skipOneLimitYes state]] forKey:KskipOneLimitYes];
    [m_configDictionary setValue:[NSNumber numberWithInteger:[_skipOneLimitNo state]] forKey:KskipOneLimitNo];
    [m_configDictionary setValue:[NSNumber numberWithInteger:[_skipHTHLDYes state]] forKey:KskipHTHLDYes];
    [m_configDictionary setValue:[NSNumber numberWithInteger:[_skipHTHLDNo state]] forKey:KskipHTHLDNo];
    
}


-(IBAction)btnClickCheck:(NSButton*)sender
{
    NSInteger btnTag = sender.tag;  // select row
    NSInteger state = sender.state;
    NSLog(@"===select group: %zd,%zd",btnTag,state);
    _dataGroup[btnTag][2] = [NSNumber numberWithInteger:state];
    [self.groupTable reloadData];

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
        }
    
    if ([columnIdentifier isEqualToString:@"group"])
       {
            index = 1;
       }
    
    if ([columnIdentifier isEqualToString:@"checked"]) {
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
        
    }
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

- (IBAction)btActionDefault:(id)sender
{
    [self initAllCtl];
    [self reloadGroupData:nil];
}
@end
