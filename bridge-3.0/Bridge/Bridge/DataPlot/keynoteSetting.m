//
//  keynoteSetting.m
//  Bridge
//
//  Created by RyanGao on 2020/7/20.
//  Copyright © 2020 RyanGao. All rights reserved.
//

#import "keynoteSetting.h"
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

@interface keynoteSetting ()
{
    NSMutableArray *selelct_1b_yes;
}

@end

@implementation keynoteSetting

- (void)windowDidLoad {
    [super windowDidLoad];
    selelct_1b_yes = [[NSMutableArray alloc] init];
    [_keynoteWin setLevel:kCGFloatingWindowLevel];
    [self initAllCtl];
    

}

-(void)initAllCtl
{
    [_txtCPKLow setStringValue:@"1.5"];
    [m_configDictionary setValue:@"1.5" forKey:kcpkKeynoteLowThd];
    
    self.buttonOk.enabled = NO;
    [self.prjName setStringValue:@""];
    
    [self.prjName becomeFirstResponder];
    
    [self.targetBuild setStringValue:@""];
    
    [_item_Advanced_Yes setState:0];
    [m_configDictionary setValue:[NSNumber numberWithInt:0] forKey:KitemAdvancedYes];
    
    [_item_Advanced_No setState:1];
    [m_configDictionary setValue:[NSNumber numberWithInt:1] forKey:KitemAdvancedNo];
    
    [_item_1a_Yes setState:1];
    [m_configDictionary setValue:[NSNumber numberWithInt:1] forKey:Kitem1aYes];
    
    [_item_1a_No setState:0];
    [_item_1a_No setEnabled:NO];
    [m_configDictionary setValue:[NSNumber numberWithInt:0] forKey:Kitem1aNo];
    
    [_item_1b_Yes setState:0];
    [_item_1b_Yes setEnabled:NO];
    [m_configDictionary setValue:[NSNumber numberWithInt:0] forKey:Kitem1bYes];
    
    [_item_1b_No setState:0];
    [_item_1b_No setEnabled:NO];
    [m_configDictionary setValue:[NSNumber numberWithInt:0] forKey:Kitem1bNo];
    
    [_m_combobox addItemWithObjectValue:(@1)];
    [_m_combobox addItemWithObjectValue:(@2)];
    [_m_combobox addItemWithObjectValue:(@4)];
    [_m_combobox addItemWithObjectValue:(@6)];
    [_m_combobox addItemWithObjectValue:(@8)];
    [_m_combobox selectItemAtIndex:0];
    
    [self.m_comReportType removeAllItems];
    [self.m_comReportType addItemWithObjectValue:(@"Python")];
    [self.m_comReportType addItemWithObjectValue:(@"Keynote")];
    [self.m_comReportType addItemWithObjectValue:(@"Numbers to Keynote ")];
    [self.m_comReportType selectItemAtIndex:0];
    
    [self.m_comboSikpSummary removeAllItems];
    [self.m_comboSikpSummary addItemWithObjectValue:(@"YES")];
    [self.m_comboSikpSummary addItemWithObjectValue:(@"NO")];
    [self.m_comboSikpSummary selectItemAtIndex:1];
    
}

- (IBAction)btActionDefault:(id)sender
{
    [self initAllCtl];
}
- (IBAction)plotTypeChange:(id)sender {
    
}

- (IBAction)btOk:(id)sender
{
    NSString *low = [self.txtCPKLow stringValue];
    if ([self isPureInt:low] || [self isPureFloat:low])
    {
        [m_configDictionary setValue:low forKey:kcpkKeynoteLowThd];
        
        [m_configDictionary setValue:self.prjName.stringValue forKey:kkeynotePrjName];
        [m_configDictionary setValue:self.targetBuild.stringValue forKey:kkeynoteBuild];
        [m_configDictionary setValue:self.m_combobox.stringValue forKey:kkeynotePlotCount];
        
        [m_configDictionary setValue:[self.m_comReportType.stringValue lowercaseString] forKey:kkeynotePlotType];
        
        
        
        [m_configDictionary setValue:[self.m_comboSikpSummary.stringValue lowercaseString] forKey:kkeynoteSkipSummarySlid];
        
        
        
        [m_configDictionary setValue:[NSNumber numberWithInt:0] forKey:khasBiggerThanLowThd];
        
        if ([_item_1a_No state]==0)
        {
            [self uiSelectItemData2CSV];
    
         }
        else if([_item_1b_Yes state]==1)
        {
            [self uiDispaly2CSV];
            [self uiSelectItemName2Csv];
            [self cpk_lowerThan_lsl_item];
            if ([[m_configDictionary valueForKey:khasBiggerThanLowThd] intValue] == 0)
            {
                [self baseOnSelectgenerateDara2CSV];
            }
            
        }
        else if ([_item_1b_No state]==1)
        {
            [self uiDispaly2CSV];
            [self uiSelectItemName2Csv];
            
        }
        if ([[self.m_comReportType.stringValue lowercaseString] containsString:@"keynote"]) {
                    [self AlertBox:@"Warning" withInfo:@"—Keynote Graphs and Charts are plotted at a preliminary level now and user has to manually edit settings to modify them as per needs. You may also lose fractional precision on the data due to rounding issues. Keynote graphs will keep improving in next versions depending on AppleScript support\n\n—Please dont use Keyboard or Trackpad, when Keynote Charts are being created and fine tuned by Automation Script in order to avoid a crash "];
                }
        [NSApp stopModalWithCode:NSModalResponseOK];
        [[sender window] orderOut:self];
    }
    else
    {
        [self AlertBox:@"Error:016" withInfo:@"Please input a number"];
    }
    
    //NSString *high = [self.txtCPKHigh stringValue];
    /*if (([self isPureInt:low] || [self isPureFloat:low]) && ([self isPureInt:high] || [self isPureFloat:high]))
    {
        float lowV = [low floatValue];
        float highV = [high floatValue];
        if (lowV>highV)
        {
            [self AlertBox:@"Error!!!" withInfo:@"CPK high threshold should be bigger than CPK low threshold!"];
            return;
        }
        
        [m_configDictionary setValue:low forKey:kcpkKeynoteLowThd];
        [m_configDictionary setValue:high forKey:kcpkKeynoteHighThd];
        
        [NSApp stopModalWithCode:NSModalResponseOK];
        [[sender window] orderOut:self];
    }
    else
    {
        [self AlertBox:@"Error!!!" withInfo:@"Input CPK threshold should be a number!"];
    }
    */
    
    
}

-(void)uiDispaly2CSV
{
    int i=0;
    NSMutableString *strCsv = [NSMutableString string];
    for(NSMutableArray *lineArray in _dataReverse)
    {
        if (i>=n_Start_Data_Col)
        {
            NSString *arrString = [NSString stringWithFormat:@"%@,%@,%@\n",lineArray[tb_index],lineArray[tb_item],lineArray[tb_keynote]];
            [strCsv appendString:arrString];
        }
        i++;
    }
    //NSString *desktopPath = [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSString *csv_Path = @"/tmp/CPK_Log/temp/items_for_skip_setting.csv";//[NSString stringWithFormat:@"%@/CPK_Log/temp/items_for_skip_setting.csv",desktopPath];
    [strCsv writeToFile:csv_Path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
}

-(void)cpk_lowerThan_lsl_item  //把
{
    NSString *low = [self.txtCPKLow stringValue];
    
    if ([self isPureInt:low] || [self isPureFloat:low])
    {
        //NSString *desktopPath = [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES)objectAtIndex:0];
        NSString *param_path = @"/tmp/CPK_Log/temp/calculate_param.csv";//[NSString stringWithFormat:@"%@/CPK_Log/temp/calculate_param.csv",desktopPath];
        
        CSVParser *csvParamItem = [[CSVParser alloc]init];
        NSMutableArray *dataParam = [NSMutableArray array];
        if ([csvParamItem openFile:param_path])
        {
            dataParam = [csvParamItem parseFile];
        }
        if (dataParam.count<1)
        {
            NSLog(@"-no dataParam --");
            return;
        }
        float cpk_lthl = [low floatValue];
        NSMutableString *csvStr = [NSMutableString string];
        int is_bigger_cpk_lthl = 0;
        
        [selelct_1b_yes removeAllObjects];
        for (int i=0; i<dataParam.count; i++)
        {
            if ([dataParam[i] count]>5)
            {
                if ([self isPureInt:dataParam[i][6]] || [self isPureFloat:dataParam[i][6]])
                {
                    float orig_cpk = [dataParam[i][6] floatValue];
                    if (orig_cpk < cpk_lthl)
                    {
                       // NSLog(@"---orig_cpk: %@   cpk_lthl: %@",dataParam[i][6],low);
                        [csvStr appendString:[NSString stringWithFormat:@"%@\n",dataParam[i][0]]];
                        [selelct_1b_yes addObject:dataParam[i][0]];
                    }
                    else
                    {
                        is_bigger_cpk_lthl ++;
                    }
                    
                }
            }
            
        }
        
        [m_configDictionary setValue:[NSNumber numberWithInt:is_bigger_cpk_lthl] forKey:khasBiggerThanLowThd];
        
        if (is_bigger_cpk_lthl == 0)
        {
             [_buttonOk setTitle:@"OK"];
        }
        
        NSString *csv_temp_Item_Path = @"/tmp/CPK_Log/Temp/keynote_data_temp_select_k.csv";//[NSString stringWithFormat:@"%@/CPK_Log/Temp/keynote_data_temp_select_k.csv",desktopPath];
        NSString *str =  [NSString stringWithContentsOfFile:csv_temp_Item_Path encoding:NSUTF8StringEncoding error:nil];
        NSString *allStr = [NSString stringWithFormat:@"%@%@",str,csvStr];
        NSError *error = nil;
        [allStr writeToFile:csv_temp_Item_Path atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (error)
           {
               NSLog(@"write csv all cpk<cpk_lthl item  and select K item fail: %@",csv_temp_Item_Path);
           }
           else
           {
               NSLog(@"write csv all cpk<cpk_lthl item  and select K item successful: %@",csv_temp_Item_Path);
           }
        
     }
}



-(void)uiSelectItemName2Csv
{
        //NSString *desktopPath = [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES)objectAtIndex:0];
        //--按照k 勾选，生成新的csv
    NSString *csv_temp_Item_Path = @"/tmp/CPK_Log/Temp/keynote_data_temp_select_k.csv";//[NSString stringWithFormat:@"%@/CPK_Log/Temp/keynote_data_temp_select_k.csv",desktopPath];
    //            NSFileManager *manager = [NSFileManager defaultManager];
    //            [manager removeItemAtPath:csv_temp_Item_Path error:nil];
                
        NSMutableArray *csvTmpItem = [NSMutableArray array];
        int i_col=0;
        for(NSMutableArray *lineArray in _dataReverse)
        {
            if (i_col >= n_Start_Data_Col)
            {
                if ([lineArray[tb_keynote] intValue]==1)
                {
                    [csvTmpItem addObject:_dataReverse[i_col][1]];  // item name for K choose
                }
            }
            i_col++;
        }
                
        NSMutableString *csvStr = [NSMutableString string];
        for(NSString *lineArray in csvTmpItem)
        {
            [csvStr appendFormat:@"%@\n",lineArray];
        }
                
        NSError *error = nil;
        [csvStr writeToFile:csv_temp_Item_Path atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (error)
        {
            NSLog(@"write csv item for keynote failed: %@",csv_temp_Item_Path);
        }
        else
        {
            NSLog(@"write csv for keynote successful: %@",csv_temp_Item_Path);
        }
}


-(void)baseOnSelectgenerateDara2CSV
{
        //NSString *desktopPath = [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSString *csv_temp_Path = @"/tmp/CPK_Log/Temp/keynote_data_temp.csv";//[NSString stringWithFormat:@"%@/CPK_Log/Temp/keynote_data_temp.csv",desktopPath];

        NSMutableArray *csvTmpData = [NSMutableArray array];
        int i_col=0;
        for(NSMutableArray *lineArray in _dataReverse)
        {
            if (i_col <n_Start_Data_Col)
            {
                [csvTmpData addObject:_dataReverse[i_col]];
            }
            else
            {
                if ([selelct_1b_yes containsObject:lineArray[tb_item]])
                {
                    ////
                    if (([lineArray[tb_keynote] intValue]==1) && ([lineArray[tb_apply] intValue]==1))
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
       [csvStr writeToFile:csv_temp_Path atomically:YES encoding:NSUTF8StringEncoding error:&error];
       if (error)
       {
           NSLog(@"write csv 1b yes directly for keynote failed: %@",csv_temp_Path);
       }
       else
       {
           NSLog(@"write csv 1b yes directly for keynote successful: %@",csv_temp_Path);
       }
           
}

-(void)uiSelectItemData2CSV
{
    //NSString *desktopPath = [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSString *csv_temp_Path = @"/tmp/CPK_Log/temp/keynote_data_temp.csv";//[NSString stringWithFormat:@"%@/CPK_Log/Temp/keynote_data_temp.csv",desktopPath];
    NSLog(@"---temp keynote: %@",csv_temp_Path);
    
    //--按照k 勾选，生成新的csv
    
    NSMutableArray *csvTmpData = [NSMutableArray array];
    int i_col=0;
    int falgK = 0;
    for(NSMutableArray *lineArray in _dataReverse)
    {
        if (i_col <n_Start_Data_Col)
        {
            [csvTmpData addObject:_dataReverse[i_col]];
        }
        else
        {
            if ([lineArray[tb_keynote] intValue]==1)
            {
                falgK = 1;
                if ([lineArray[tb_apply] intValue]==1)  //当k列与apply 都选中，用新limit
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
        }
        i_col++;
    }
    
    [m_configDictionary setValue:[NSNumber numberWithInt:falgK] forKey:kchooseUIK];
    if (falgK == 1)
    {
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
            [csvStr writeToFile:csv_temp_Path atomically:YES encoding:NSUTF8StringEncoding error:&error];
            if (error)
            {
                NSLog(@"write csv for keynote failed: %@",csv_temp_Path);
            }
            else
            {
                NSLog(@"write csv for keynote successful: %@",csv_temp_Path);
            }
            
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
    [NSApp stopModalWithCode:NSModalResponseCancel];
    [[sender window] orderOut:self];
}

- (IBAction)checkBox:(id)sender
{

    int check = (int)[sender state];
    switch ([sender tag])
    {
        case 10:
        {
            if (check)
            {
                [self AlertBox:@"note" withInfo:@"This Advanced Bimodality Breakdown Analysis is under development!!!"];
                [_item_Advanced_No setState:1];
                [_item_Advanced_Yes setState:0];
                return;
            }
            else
            {
                [_item_Advanced_No setState:check];
                [_item_Advanced_Yes setState:!check];
                
            }
            
        }
            break;
        case 11:
        {
            if (check)
               {
                   [_item_Advanced_Yes setState:!check];
                   [_item_Advanced_No setState:check];
               }
            else
            {
                [_item_Advanced_Yes setState:check];
                [_item_Advanced_No setState:!check];
            }
            
        }
            break;
        case 12:
        {
            if (check)
            {
                [_item_1a_Yes setState:check];
                //[_item_1a_No setState:!check];
                
                [_item_1a_No setState:0];
                [_item_1a_No setEnabled:NO];
                
                [_item_1b_Yes setState:0];
                [_item_1b_No setState:0];
                [_item_1b_Yes setEnabled:NO];
                [_item_1b_No setEnabled:NO];
                
                
            }
            else
            {
                [_item_1a_Yes setState:0];
                [_item_1a_No setState:1];
                [_item_1a_No setEnabled:YES];
                
                [_item_1b_Yes setEnabled:YES];
                [_item_1b_No setEnabled:YES];
                
                [_item_1b_Yes setState:1];
                [_item_1b_No setState:0];
               
                
            }
            
        }
            break;
        case 13:
        {
            if (check)
            {
                [_item_1a_No setState:check];
                [_item_1a_Yes setState:!check];
                
                [_item_1b_Yes setState:1];
                [_item_1b_No setState:0];
                
            }
            else
            {
                [_item_1a_No setState:!check];
                [_item_1a_Yes setState:check];
                
            }
            
        }
            break;
        case 14:
        {
            if (check)
            {
                [_item_1b_Yes setState:check];
                [_item_1b_No setState:!check];
                [_item_1a_No setState:1];
                [_item_1a_Yes setState:0];
                
            }
            else
            {
                [_item_1b_Yes setState:!check];
                [_item_1b_No setState:check];
            }
            
        }
            break;
        case 15:
        {
            if (check)
            {
                [_item_1b_No setState:check];
                [_item_1b_Yes setState:!check];
                
                [_item_1a_No setState:1];
                [_item_1a_Yes setState:0];
                
            }
            else
            {
                [_item_1b_No setState:!check];
                [_item_1b_Yes setState:check];
            }
            
        }
            break;


        default:
            break;
    }
    
    if (_item_1b_No.state == 1|| _item_1b_Yes.state == 1)
    {
        [_buttonOk setTitle:@"NEXT"];
    }
    else
    {
         [_buttonOk setTitle:@"OK"];
    }
    
    [m_configDictionary setValue:[NSNumber numberWithInteger:[_item_Advanced_Yes state]] forKey:KitemAdvancedYes];
    [m_configDictionary setValue:[NSNumber numberWithInteger:[_item_Advanced_No state]] forKey:KitemAdvancedNo];
    [m_configDictionary setValue:[NSNumber numberWithInteger:[_item_1a_Yes state]] forKey:Kitem1aYes];
    [m_configDictionary setValue:[NSNumber numberWithInteger:[_item_1a_No state]] forKey:Kitem1aNo];
    [m_configDictionary setValue:[NSNumber numberWithInteger:[_item_1b_Yes state]] forKey:Kitem1bYes];
    [m_configDictionary setValue:[NSNumber numberWithInteger:[_item_1b_No state]] forKey:Kitem1bNo];
     
    
}


-(void)controlTextDidChange:(NSNotification *)obj
{
   
    if (self.prjName.stringValue.length &&self.targetBuild.stringValue.length)
        {
            self.buttonOk.enabled = YES;
        }
        else
        {
            self.buttonOk.enabled = NO;
        }
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

@end
