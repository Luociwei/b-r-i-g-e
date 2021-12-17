//
//  customWinController.m
//  tableViewDemo2
//
//  Created by RyanGao on 2020/12/27.
//

#import "customWinController.h"

//#import "defineHeader.h"
#import "../DataPlot/defineHeader.h"
extern NSMutableDictionary *m_configDictionary;

@interface customWinController ()
{
    NSCell *dataCell;
    NSArray *columnNames;
    BOOL ignoreColumnDidMoveNotifications;
    NSUInteger row_define;
}

@end

@implementation customWinController

-(instancetype)init
{
    self = [super init];
    if (self) {
        
        _maxColumnNumber = 1;
        _maxRowNumber = 0;
        _testItemnameRowNumber = 0;
        
        
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    _data = [[NSMutableArray alloc]init];
    dataCell = [self.tableView.tableColumns.firstObject dataCell];
    [self updateTableColumns];
    //[_data addObject:@[@"22",@"33",@"55",@"66",@"66",@"66",@"66",@"66",@"67"]];
    //[_data addObject:@[@"22",@"33",@"55",@"66",@"66",@"66",@"66",@"66",@"678"]];
    
    // row---
    [self.txtStartRow setStringValue:@"1"];
    [self.txtUpperRow setStringValue:@"NA"];
    [self.txtLowerRow setStringValue:@"NA"];
    [self.txtUnitRow setStringValue:@"NA"];
    [self.txtDataStartRow setStringValue:@"4"];
    
    // column
    [self.txtStartItemCol setStringValue:@"0"];
    [self.txtSerialNumberCol setStringValue:@"0"];
    [self.txtPassFailStatusCol setStringValue:@"0"];
    [self.txtProductCol setStringValue:@"NA"];  // can ignore
    [self.txtStartTimeCol setStringValue:@"NA"];  // can ignore
    [self.txtStationIDCol setStringValue:@"NA"];  // can ignore
    [self.txtVersionCol setStringValue:@"NA"];  // can ignore
    [self.txtListOfFailCol setStringValue:@"NA"];  // can ignore
    [self.txtSlotIdCol setStringValue:@"NA"];  // can ignore
    
    
    //label
    [self.labProductCol setStringValue:@""];
    [self.labStartItemCol setStringValue:@""];
    [self.labSerialNumberCol setStringValue:@""];
    [self.labStartTimeCol setStringValue:@""];
    [self.labPassFailStatusCol setStringValue:@""];
    [self.labStationIdCol setStringValue:@""];
    [self.labVersionCol setStringValue:@""];
    [self.labListOfFailCol setStringValue:@""];
    [self.labSlotIdCol setStringValue:@""];
    
    
    [_data removeAllObjects];
    NSArray *arr = [m_configDictionary valueForKey:KrawDataTmp];
    
    row_define = [arr count];
    _maxRowNumber = [arr count];
    [_data setArray:arr];
    if (row_define == 0)
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationCloseStartUp object:nil userInfo:nil];
        [self AlertBox:@"Error:016" withInfo:@"no data to load into customer setting panel!"];
        return;
    }
//    for (NSUInteger i = 0; i<row_define; i++)
//    {
//
//        [_data addObject:arr[i]];
//    }
    
    for (int i=0; i<row_define; i++)
    {
        NSInteger n_count = [arr[i] count];
        if (_maxColumnNumber<n_count)
        {
            _maxColumnNumber = n_count;
        }
    }
    
    for (int i=0; i<row_define; i++)
    {
        NSInteger n_number = 0;
        for (int j=0; j<[arr[i] count]; j++)
        {
            NSString *value = arr[i][j];
            if ([value length]>0)
            {
                n_number++;
            }
        }
        if (_maxColumnNumber == n_number)
        {
            BOOL flag1 = YES;
            BOOL flag2 = YES;
            BOOL flag3 = YES;
            BOOL flag4 = YES;
            BOOL flag5 = YES;
            BOOL flag6 = YES;  
            BOOL flag7 = YES;
            BOOL flag8 = YES;
            [self.txtStartRow setStringValue:[NSString stringWithFormat:@"%d",i]];
            _testItemnameRowNumber = i;
            for (NSInteger m=0;m < n_number; m++)
            {
                NSString *itemname = arr[i][m];
                if (([itemname containsString:@"PASS/FAIL"] || [itemname containsString:@"Pass/Fail"])&& flag1)
                {
                    [self.txtPassFailStatusCol setStringValue:[NSString stringWithFormat:@"%zd",m]];
                    [self.labPassFailStatusCol setStringValue:itemname];
                    flag1 = NO;
                }
                if (([itemname containsString:@"SerialNumber"])&& flag2)
                {
                    [self.txtSerialNumberCol setStringValue:[NSString stringWithFormat:@"%zd",m]];
                    [self.labSerialNumberCol setStringValue:itemname];
                    flag2 = NO;
                }
                if (([itemname containsString:@"Start Time"] ||[itemname containsString:@"StartTime"] || [itemname containsString:@"startTime"])&&flag3)
                {
                    [self.txtStartTimeCol setStringValue:[NSString stringWithFormat:@"%zd",m]];  //time
                    [self.labStartTimeCol setStringValue:itemname];
                    
                    if ([arr[i] count]>m+3)
                    {
                        [self.txtStartItemCol setStringValue:[NSString stringWithFormat:@"%zd",m+3]];  // item
                        [self.labStartItemCol setStringValue:arr[i][m+3]];
                    }
                    
                    flag3 = NO;
                }
                if (([itemname containsString:@"Product"])&&flag4)
                {
                    [self.txtProductCol setStringValue:[NSString stringWithFormat:@"%zd",m]];
                    [self.labProductCol setStringValue:itemname];
                    
                    if ([arr[i] count]>m+1)
                    {
                        [self.txtStartItemCol setStringValue:[NSString stringWithFormat:@"%zd",m+1]];
                        [self.labStartItemCol setStringValue:arr[i][m+1]];
                    }
                    flag4 = NO;
                }
                if (([itemname containsString:@"Station_ID"] || [itemname containsString:@"Station ID"]) && flag5)
                {
                    [self.txtStationIDCol setStringValue:[NSString stringWithFormat:@"%zd",m]];
                    [self.labStationIdCol setStringValue:itemname];
                    if ([arr[i] count]>m+1)
                    {
                        [self.txtStartItemCol setStringValue:[NSString stringWithFormat:@"%zd",m+1]];
                        [self.labStartItemCol setStringValue:arr[i][m+1]];
                    }
                    
                    flag5 = NO;
                }
                
                if (([itemname containsString:@"Version"]) && flag6)
                {
                    [self.txtVersionCol setStringValue:[NSString stringWithFormat:@"%zd",m]];
                    [self.labVersionCol setStringValue:itemname];
                    if ([arr[i] count]>m+1)
                    {
                        [self.txtStartItemCol setStringValue:[NSString stringWithFormat:@"%zd",m+1]];
                        [self.labStartItemCol setStringValue:arr[i][m+1]];
                    }
                    
                    flag6 = NO;
                }
                
                if (([itemname containsString:@"List of Failing Tests"] || [itemname containsString:@"Failed_List"]) && flag7)
                {
                    [self.txtListOfFailCol setStringValue:[NSString stringWithFormat:@"%zd",m]];
                    [self.labListOfFailCol setStringValue:itemname];
                    if ([arr[i] count]>m+1)
                    {
                        [self.txtStartItemCol setStringValue:[NSString stringWithFormat:@"%zd",m+1]];
                        [self.labStartItemCol setStringValue:arr[i][m+1]];
                    }
                    
                    flag7 = NO;
                }
                
                NSString *keyWord1 = @"Fixture Channel ID";
                NSString *keyWord2 = @"Fixture Initialization SLOT_ID"; //INITIALIZATION
                NSString *keyWord3 = @"Fixture Reset CALC fixture_channel";
                NSString *keyWord4 = @"Head Id";
                NSString *keyWord5 = @"Fixture_Channel Channel Channel_ID";
                NSString *keyWord6 = @"Fixture Channel Channel_ID";
                NSString *keyWord7 = @"Channel ID";
                NSString *keyWord8 = @"Channel_ID";
                NSString *keyWord9 = @"Slot ID";
                NSString *keyWord10 = @"Slot_ID";
                NSString *keyWord11 = @"Fixture_Setup Channel Channel_ID";
                NSString *keyWord12 = @"Fixture Get Slot_ID";
                NSString *keyWord13 = @"SLOT-ID";
                
                if (([itemname containsString:keyWord1] || [itemname containsString:keyWord2]|| [itemname containsString:keyWord3] || [itemname containsString:keyWord4] || [itemname containsString:keyWord5] || [itemname containsString:keyWord6] || [itemname containsString:keyWord7] || [itemname containsString:keyWord8] || [itemname containsString:keyWord9] || [itemname containsString:keyWord10] || [itemname containsString:keyWord11] || [itemname containsString:keyWord12] || [itemname containsString:keyWord13] ) && flag8)
                {
                    [self.txtSlotIdCol setStringValue:[NSString stringWithFormat:@"%zd",m]];
                    [self.labSlotIdCol setStringValue:itemname];
                    flag8 = NO;
                }
                
                if (!flag1&&!flag2&&!flag3&&!flag4&&!flag5 && !flag6 && !flag7 && !flag8)
                {
                    break;
                }
            }
            
            break;
        }
    }
    
    for (int i=0; i<row_define; i++)  //[arr count]
    {
        
        NSString *value = arr[i][0];
        if ([value containsString:@"Upper Limit"])
        {
            [self.txtUpperRow setStringValue:[NSString stringWithFormat:@"%d",i]];
            [self.txtDataStartRow setStringValue:[NSString stringWithFormat:@"%d",i+1]];
            break;
        }
    }
    for (int i=0; i<row_define; i++) //[arr count]
    {
        
        NSString *value = arr[i][0];
        if ([value containsString:@"Lower Limit"])
        {
            [self.txtLowerRow setStringValue:[NSString stringWithFormat:@"%d",i]];
            [self.txtDataStartRow setStringValue:[NSString stringWithFormat:@"%d",i+1]];
            break;
        }
    }
    
    for (int i=0; i<row_define; i++)  //[arr count]
    {
        
        NSString *value = arr[i][0];
        if ([value containsString:@"Measurement unit"] || [value containsString:@"Measurement Unit"])
        {
            [self.txtUnitRow setStringValue:[NSString stringWithFormat:@"%d",i]];
            [self.txtDataStartRow setStringValue:[NSString stringWithFormat:@"%d",i+1]];
            break;
        }
    }
    
    
    [self updateTableColumns];
    [self updateTableColumnsNames];
    int j=0;
    for (NSTableColumn * col in [self.tableView tableColumns])
    {
        if (j==0)
        {
            [col setWidth:240];
        }
        else
        {
            [col setWidth:140];
        }
        
        j++;
    }
    [self.tableView reloadData];
    
    [self.btnOK setEnabled:YES];
    [self.txtStartRow setAccessibilityFocused:YES];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationCloseStartUp object:nil userInfo:nil];
    
}


-(BOOL)isPureInt:(NSString *)string
{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}


- (IBAction)brCancel:(id)sender
{
    [NSApp stopModalWithCode:NSModalResponseCancel];
    [[sender window] orderOut:self];
    [_mainWin close];
}
- (IBAction)btOk:(id)sender
{
    NSString *startRowVal = [self.txtStartRow stringValue];
    NSString *upperRowVal = [self.txtUpperRow stringValue];  // can NA
    NSString *lowerRowVal = [self.txtLowerRow stringValue];   // can NA
    NSString *unitRowVal = [self.txtUnitRow stringValue];    //can NA
    NSString *dataStartRowVal = [self.txtDataStartRow stringValue];
    
    
    NSString *passFailVal = [self.txtPassFailStatusCol stringValue];
    NSString *serialNumberVal = [self.txtSerialNumberCol stringValue];
    NSString *startTimeVal = [self.txtStartTimeCol stringValue];  //can NA
    NSString *productVal = [self.txtProductCol stringValue];  // can NA
    NSString *stationidVal = [self.txtStationIDCol stringValue];  //Can NA
    NSString *startItemVal = [self.txtStartItemCol stringValue];
    NSString *versionVal = [self.txtVersionCol stringValue];  //can NA
    NSString *listOfFailVal = [self.txtListOfFailCol stringValue];  // can NA
    NSString *slotIdVal = [self.txtSlotIdCol stringValue];  //Can NA
    
    if ([startRowVal isEqual:@""] ||[passFailVal isEqual:@""] ||[serialNumberVal isEqual:@""] || [startTimeVal isEqual:@""] ||[productVal isEqual:@""] ||[stationidVal isEqual:@""]||[startItemVal isEqual:@""] ||![self isPureInt:passFailVal]||![self isPureInt:serialNumberVal]||![self isPureInt:startItemVal] || [upperRowVal isEqual:@""]|| [lowerRowVal isEqual:@""]||[unitRowVal isEqual:@""] || [dataStartRowVal isEqual:@""] ||![self isPureInt:dataStartRowVal] || [versionVal isEqual:@""] || [listOfFailVal isEqual:@""] || [slotIdVal isEqual:@""])
    {
        [self AlertBox:@"Error:017" withInfo:@"Please input a number or NA"];
        return ;
    }
    else
    {
        int startRow_int = [startRowVal intValue];
        int dataStartRow_int = [dataStartRowVal intValue];
        
        int passFail_int = [passFailVal intValue];
        int serialNumber_int = [serialNumberVal intValue];
        int startItem_int = [startItemVal intValue];
        
        int startTime_int =900000;
        if ([startTimeVal isNotEqualTo:@"NA"])
        {
            startTime_int = [startTimeVal intValue];  // can NA
        }
        
        int product_int =900001;
        if ([productVal isNotEqualTo:@"NA"])
        {
            product_int = [productVal intValue];   //can NA
        }
        
        int stationid_int =900002;
        if ([stationidVal isNotEqualTo:@"NA"])
        {
            stationid_int = [stationidVal intValue];  // can NA
        }
        
        int version_int =900003;
        if ([versionVal isNotEqualTo:@"NA"])
        {
            version_int = [versionVal intValue];  // can NA
        }
        
        int listOfFail_int =900004;
        if ([listOfFailVal isNotEqualTo:@"NA"])
        {
            listOfFail_int = [listOfFailVal intValue];  // can NA
        }
        
        int slotId_int =900005;
        if ([slotIdVal isNotEqualTo:@"NA"])
        {
            slotId_int = [slotIdVal intValue];  // can NA
        }
        
        
        
        NSMutableArray *arr = [NSMutableArray array];
        [arr addObject:[NSNumber numberWithInt:startRow_int]];
        [arr addObject:[NSNumber numberWithInt:dataStartRow_int]];
        [arr addObject:[NSNumber numberWithInt:passFail_int]];
        [arr addObject:[NSNumber numberWithInt:serialNumber_int]];
        [arr addObject:[NSNumber numberWithInt:startTime_int]];
        [arr addObject:[NSNumber numberWithInt:product_int]];
        [arr addObject:[NSNumber numberWithInt:stationid_int]];
        [arr addObject:[NSNumber numberWithInt:startItem_int]];
        [arr addObject:[NSNumber numberWithInt:version_int]];
        [arr addObject:[NSNumber numberWithInt:listOfFail_int]];
        [arr addObject:[NSNumber numberWithInt:slotId_int]];
        for (int i=0; i<[arr count]; i++)
        {
            if (arr[i]<0)
            {
                [self AlertBox:@"Error:017" withInfo:@"Please input number must greater than or equal to 0."];
                return ;
                
            }
            
        }
        
        int upper_int = 1000;
        if ([upperRowVal isNotEqualTo:@"NA"])
        {
            upper_int = [upperRowVal intValue];
        }
        int lower_int = 1001;
        if ([lowerRowVal isNotEqualTo:@"NA"])
        {
            lower_int = [lowerRowVal intValue];
        }
        int unit_int = 1002;
        if ([unitRowVal isNotEqualTo:@"NA"])
        {
            unit_int = [unitRowVal intValue];
        }
       
        NSMutableArray *arrRow = [NSMutableArray array];
        [arrRow addObject:[NSNumber numberWithInt:startRow_int]];
        [arrRow addObject:[NSNumber numberWithInt:upper_int]];
        [arrRow addObject:[NSNumber numberWithInt:lower_int]];
        [arrRow addObject:[NSNumber numberWithInt:unit_int]];
        [arrRow addObject:[NSNumber numberWithInt:dataStartRow_int]];
            
        [arr removeObjectAtIndex:0];   //remove item
        [arr removeObjectAtIndex:0];   // remove data start
        NSArray *arr2 = [NSArray arrayWithArray:arr];
        
        NSMutableArray *ary = [NSMutableArray array];
        NSString *sameStr = @"";
        for (NSString *str in arr2)
        {
            if (![ary containsObject:str])
            {
                [ary addObject:str];
            }
            else
            {
                if ([sameStr length]>0)
                {
                    sameStr = [NSString stringWithFormat:@"%@,%@",sameStr,str];
                }
                else
                {
                    sameStr = [NSString stringWithFormat:@"%@",str];
                }
                
            }
        }
        
        if ([sameStr length]>0)
        {
            [self AlertBox:@"Error:017" withInfo:[NSString stringWithFormat:@"Input duplication number for column: %@",sameStr]];
            return ;
        }
        
        NSMutableArray *aryRow = [NSMutableArray array];
        NSString *sameStrRow = @"";
        for (NSString *str in arrRow)
        {
            if (![aryRow containsObject:str])
            {
                [aryRow addObject:str];
            }
            else
            {
                if ([sameStrRow length]>0)
                {
                    sameStrRow = [NSString stringWithFormat:@"%@,%@",sameStrRow,str];
                }
                else
                {
                    sameStrRow = [NSString stringWithFormat:@"%@",str];
                }
                
            }
        }
        
        if ([sameStrRow length]>0)
        {
            [self AlertBox:@"Error:017" withInfo:[NSString stringWithFormat:@"Input duplication number for row : %@",sameStrRow]];
            return ;
        }
        
        // row
        [m_configDictionary setValue:[NSNumber numberWithInt:startRow_int] forKey:KcustomCsvStartRow];
        [m_configDictionary setValue:[NSNumber numberWithInt:dataStartRow_int] forKey:KcustomCsvDataStartRow];
        [m_configDictionary setValue:upperRowVal forKey:KcustomCsvUpperLimitRow];
        [m_configDictionary setValue:lowerRowVal forKey:KcustomCsvLowerLimitRow];
        [m_configDictionary setValue:unitRowVal forKey:KcustomCsvUnitRow];
        
        
        //column
        [m_configDictionary setValue:[NSNumber numberWithInt:startItem_int] forKey:KcustomCsvStartItemCol];
        [m_configDictionary setValue:[NSNumber numberWithInt:passFail_int] forKey:KcustomCsvPassFailCol];
        [m_configDictionary setValue:[NSNumber numberWithInt:serialNumber_int] forKey:KcustomCsvSerialNumberCol];
        [m_configDictionary setValue:[NSNumber numberWithInt:startTime_int] forKey:KcustomCsvStartTimeCol];
        [m_configDictionary setValue:[NSNumber numberWithInt:product_int] forKey:KcustomCsvProductCol];
        [m_configDictionary setValue:[NSNumber numberWithInt:stationid_int] forKey:KcustomCsvStationIdCol];
        [m_configDictionary setValue:[NSNumber numberWithInt:version_int] forKey:KcustomCsvVersionCol];
        [m_configDictionary setValue:[NSNumber numberWithInt:listOfFail_int] forKey:KcustomCsvListOfFailCol];
        [m_configDictionary setValue:[NSNumber numberWithInt:slotId_int] forKey:KcustomCsvSlotIdCol];
        
        
        
        int row = startRow_int;  // item name in row
        
        int col = startItem_int;
        [m_configDictionary setValue:_data[row][col] forKey:KcustomCsvStartItemWord]; // first test item
        col = passFail_int;
        [m_configDictionary setValue:_data[row][col] forKey:KcustomCsvPassFailWord];
        col = serialNumber_int;
        [m_configDictionary setValue:_data[row][col] forKey:KcustomCsvSerialNumberWord];
        
        
        col = startTime_int;
        if (startTime_int == 900000)
        {
            [m_configDictionary setValue:@"NA" forKey:KcustomCsvStartTimeWord];
        }
        else
        {
            [m_configDictionary setValue:_data[row][col] forKey:KcustomCsvStartTimeWord];
        }
        
        col = product_int;
        if (product_int == 900001)
        {
            [m_configDictionary setValue:@"NA" forKey:KcustomCsvProductWord];
        }
        else
        {
            [m_configDictionary setValue:_data[row][col] forKey:KcustomCsvProductWord];
        }
        
        col = stationid_int;
        if (stationid_int == 900002)
        {
            [m_configDictionary setValue:@"NA" forKey:KcustomCsvStationIdWord];
        }
        else
        {
            [m_configDictionary setValue:_data[row][col] forKey:KcustomCsvStationIdWord];
        }
        
        col = version_int;
        if (version_int == 900003)
        {
            [m_configDictionary setValue:@"NA" forKey:KcustomCsvVersionWord];
        }
        else
        {
            [m_configDictionary setValue:_data[row][col] forKey:KcustomCsvVersionWord];
        }
        
        col = listOfFail_int;
        if (listOfFail_int == 900004)
        {
            [m_configDictionary setValue:@"NA" forKey:KcustomCsvListOfFailWord];
        }
        else
        {
            [m_configDictionary setValue:_data[row][col] forKey:KcustomCsvListOfFailWord];
        }
        
        col = slotId_int;
        if (slotId_int == 900005)
        {
            [m_configDictionary setValue:@"NA" forKey:KcustomCsvSlotIdWord];
        }
        else
        {
            [m_configDictionary setValue:_data[row][col] forKey:KcustomCsvSlotIdWord];
        }

    }
   
    [NSApp stopModalWithCode:NSModalResponseOK];
    [[sender window] orderOut:self];
    [_mainWin close];
}


#pragma mark TableView Datasource & delegate

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    //NSLog(@"->>>> %zd",[_data count]);
    return [_data count];
}
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
   
    if(_data.count >= row+1) {
        NSArray *rowArray = _data[row];
        if(rowArray.count >= tableColumn.identifier.integerValue+1)
        {
            if([rowArray[tableColumn.identifier.integerValue] isKindOfClass:[NSDecimalNumber class]])
            {
                return [(NSDecimalNumber *)rowArray[tableColumn.identifier.integerValue] descriptionWithLocale:@{NSLocaleDecimalSeparator:@"."}];
            }
            return rowArray[tableColumn.identifier.integerValue];
        }
    }
    return nil;
    
}

-(void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)rowIndex {
    
    if(_data.count <= rowIndex) return;
    NSTextFieldCell *textCell = cell;
    NSArray *rowArray = [_data objectAtIndex:rowIndex];
    if(rowArray.count > tableColumn.identifier.integerValue){
        if([rowArray[tableColumn.identifier.integerValue] isKindOfClass:[NSDecimalNumber class]]){
            textCell.alignment = NSTextAlignmentRight;
        }else{
            textCell.alignment = NSTextAlignmentLeft;
        }
    }
}

/*-(NSArray *)getColumnsOrder{
    NSMutableArray *columnsOrder = [[NSMutableArray alloc] init];
    for(NSTableColumn *col in self.tableView.tableColumns) {
        [columnsOrder addObject:col.identifier];
    }
    return columnsOrder.copy;
}
*/


#pragma mark - updateTableView

-(void)updateTableColumns
{
    if (!self.tableView) return;
    
    for(NSTableColumn *col in self.tableView.tableColumns.mutableCopy) {
        [self.tableView removeTableColumn:col];
    }
    for(int i = 0; i < _maxColumnNumber; ++i)
    {
        NSTableColumn *tableColumn = [[NSTableColumn alloc] initWithIdentifier:[NSString stringWithFormat:@"%d",i]];
        tableColumn.dataCell = dataCell;
        tableColumn.headerCell.stringValue = i < columnNames.count ? columnNames[i] : [self generateColumnName:i];
        //((NSCell *)tableColumn.headerCell).alignment = NSTextAlignmentCenter;
        [self.tableView addTableColumn: tableColumn];
    }
}

-(void)updateTableColumnsNames {
    
    for(int i = 0; i < [self.tableView.tableColumns count]; i++) {
        NSTableColumn *tableColumn = self.tableView.tableColumns[i];
        tableColumn.headerCell.stringValue = [self generateColumnName:i];
        //((NSCell *)tableColumn.headerCell).alignment = NSTextAlignmentCenter;
    }
}

-(NSString *)generateColumnName:(int)index {
    return [NSString stringWithFormat:@"column: %d",index];
    /*int columnBase = 26;
    int digitMax = 7; // ceil(log26(Int32.Max))
    //NSString *digits = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    if (index < columnBase) {
        return [digits substringWithRange:NSMakeRange(index, 1)];
    }
    
    NSMutableArray *columnName = [[NSMutableArray alloc]initWithCapacity:digitMax];
    for(int i = 0; i < digitMax; i++) {
        columnName[i] = @"";
    }
    
    index++;
    int offset = digitMax;
    while (index > 0) {
        [columnName replaceObjectAtIndex:--offset withObject:[digits substringWithRange:NSMakeRange(--index % columnBase, 1)]];
        index /= columnBase;
    }
    
    return [columnName componentsJoinedByString:@""];
     */
}


-(void)addColumnAtIndex:(long) columnIndex {
    
    ignoreColumnDidMoveNotifications = YES;
    long columnIdentifier = _maxColumnNumber;
    NSTableColumn *col = [[NSTableColumn alloc] initWithIdentifier:[NSString stringWithFormat:@"%ld",columnIdentifier]];
    col.dataCell = dataCell;
    [self.tableView addTableColumn:col];
    col.headerCell.stringValue = @"";
    [self.tableView moveColumn:[self.tableView numberOfColumns]-1 toColumn:columnIndex];
    
    for(NSMutableArray *rowArray in _data) {
        [rowArray addObject:@""];
    }
    
    _maxColumnNumber++;
    
    [self.tableView selectColumnIndexes:[NSIndexSet indexSetWithIndex:columnIndex] byExtendingSelection:NO];
    [self updateTableColumnsNames];
    [self.tableView scrollColumnToVisible:columnIndex];
    ignoreColumnDidMoveNotifications = NO;
    
   // [self dataGotEdited];
    //[[self.undoManager prepareWithInvocationTarget:self] deleteColumnsAtIndexes:[NSIndexSet indexSetWithIndex:columnIndex]];
}

-(void)AlertBox:(NSString *)msgTxt withInfo:(NSString *)strmsg
{
    NSAlert * alert = [[NSAlert alloc] init];
    alert.messageText = msgTxt;
    alert.informativeText = strmsg;
    [alert runModal];
}
-(int)AlertBoxWith2Button:(NSString *)msgTxt withInfo:(NSString *)strmsg
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:msgTxt];
    [alert setInformativeText:strmsg];
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Cancel"];
   // [alert addButtonWithTitle:@"abort"];
    [alert setAlertStyle:NSAlertStyleWarning];
    NSUInteger action = [alert runModal];
    if(action == NSAlertFirstButtonReturn) //1000
    {
        return 1000;
    }
    else if(action == NSAlertSecondButtonReturn )//1001
    {
        return 1001;
    }
//    else if(action == NSAlertThirdButtonReturn)//1002
//    {
//        NSLog(@"Abort");
//    }
    else
    {
        return -1;
    }

}

-(BOOL)popMsgWin:(NSString *)ret
{
    if ([ret isEqual:@""] || ![self isPureInt:ret])
    {
        [self AlertBox:@"Error:016" withInfo:@"Please input a number."];
        return YES;
        
    }
    else
    {
        int val = [ret intValue];
        if(val <0)
        {
            [self AlertBox:@"Error:017" withInfo:@"Please input number must greater than or equal to 0."];
            return YES;
        }
    }
    return NO;
}

-(BOOL)popMsgWin_2:(NSString *)ret
{
    if ([ret isEqualToString:@"NA"])
    {
        return NO;
    }
    
    if ([ret isEqual:@""] || ![self isPureInt:ret])
    {
        [self AlertBox:@"Error:016" withInfo:@"Please input a number."];
        return YES;
        
    }
    else
    {
        int val = [ret intValue];
        if(val <0)
        {
            [self AlertBox:@"Error:017" withInfo:@"Please input number must greater than or equal to 0."];
            return YES;
        }
    }
    return NO;
}

-(BOOL)popMsgWin_3:(NSString *)ret with:(BOOL)flag  // can use NA
{
    if (flag)
    {
        if ([ret isEqualToString:@"N"] || [ret isEqualToString:@"NA"])
        {
            return NO;
        }
    }
    if ([ret isEqualToString:@""])
    {
        return NO;
    }
    
    if (![self isPureInt:ret])
    {
        [self AlertBox:@"Error:016" withInfo:@"Please input a number."];
        return YES;
        
    }
    else
    {
        int val = [ret intValue];
        if(val <0)
        {
            [self AlertBox:@"Error:017" withInfo:@"Input number must greater than or equal to 0."];
            return YES;
        }
    }
    return NO;
}

-(BOOL)checkRow
{
    NSString *ret = [self.txtStartRow stringValue];
    if ([ret isNotEqualTo:@""])
    {
        if ([self isPureInt:ret])
        {
            if([ret intValue]>=0)
            {
                return YES;
            }
        }
    }
    return NO;
}

- (IBAction)txtActionCheck:(id)sender
{
    NSString *ret = @"";
    
    int check = (int)[sender tag];
    switch (check)
    {
        //-------------row------------------
        case 0:
            ret = [self.txtStartRow stringValue];
            if ([self popMsgWin:ret])
            {
                [self.txtStartRow setStringValue:@"1"];
            }
            else
            {
                
            }
            break;
        case 10:
            ret = [self.txtUpperRow stringValue];  // can NA
            if ([self popMsgWin_2:ret])
            {
                [self.txtUpperRow setStringValue:@"NA"];
            }
            else
            {
                
            }
            break;
        case 11:
            ret = [self.txtLowerRow stringValue];  // can NA
            if ([self popMsgWin_2:ret])
            {
                [self.txtLowerRow setStringValue:@"NA"];
            }
            else
            {
                
            }
            break;
        case 12:
            ret = [self.txtUnitRow stringValue];  //can NA
            if ([self popMsgWin_2:ret])
            {
                [self.txtUnitRow setStringValue:@"NA"];
            }
            else
            {
                
            }
            break;
        case 13:
            ret = [self.txtDataStartRow stringValue];
            if ([self popMsgWin:ret])
            {
                [self.txtDataStartRow setStringValue:@"4"];
            }
            else
            {
                
            }
            break;
        //-----------------column------------
        case 1:
            ret = [self.txtPassFailStatusCol stringValue];   //pass fail status col---
            if ([self popMsgWin:ret])
            {
                [self.txtPassFailStatusCol setStringValue:@"0"];
            }
            else
            {
                if ([self checkRow])
                {
                    int row = [self.txtStartRow intValue];
                    int col = [ret intValue];
                    NSString *key = _data[row][col];
                    if ([key isEqualToString:@""])
                    {
                        //[self AlertBox:@"Error:51" withInfo:@"Input wrong row number for keyword."];
                    }
                    else
                    {
                        [self.labPassFailStatusCol setStringValue:key];
                    }
                    
                }
            }
            break;
        case 2:
            ret = [self.txtSerialNumberCol stringValue];  // serial number
            if ([self popMsgWin:ret])
            {
                [self.txtSerialNumberCol setStringValue:@"0"];
            }
            else
            {
                if ([self checkRow])
                {
                    int row = [self.txtStartRow intValue];
                    int col = [ret intValue];
                    NSString *key = _data[row][col];
                    if ([key isEqualToString:@""])
                    {
                        //[self AlertBox:@"Error:51" withInfo:@"Input wrong row number for keyword."];
                    }
                    else
                    {
                        [self.labSerialNumberCol setStringValue:key];
                    }
                    
                }
            }
            break;
        case 3:
            ret = [self.txtStartTimeCol stringValue];  // can NA --  start test time col
            if([self popMsgWin_2:ret])
            {
                [self.txtStartTimeCol setStringValue:@"0"];
            }
            else
            {
                if ([self checkRow])
                {
                    if ([ret isEqualToString:@"NA"])
                    {
                        [self.labStartTimeCol setStringValue:@""];
                    }
                    else
                    {
                        int row = [self.txtStartRow intValue];
                        int col = [ret intValue];
                        NSString *key = _data[row][col];
                        if ([key isEqualToString:@""])
                        {
                            //[self AlertBox:@"Error:51" withInfo:@"Input wrong row number for keyword."];
                        }
                        else
                        {
                            [self.labStartTimeCol setStringValue:key];
                        }
                    }
                    
                    
                }
            }
            break;
        case 4:
            ret = [self.txtProductCol stringValue];  // can NA   --- product col
            if([self popMsgWin_2:ret])
            {
                [self.txtProductCol setStringValue:@"0"];
            }
            else
            {
                if ([self checkRow])
                {
                    if ([ret isEqualToString:@"NA"])
                    {
                        [self.labProductCol setStringValue:@""];
                    }
                    else
                    {
                        int row = [self.txtStartRow intValue];
                        int col = [ret intValue];
                        NSString *key = _data[row][col];
                        if ([key isEqualToString:@""])
                        {
                            //[self AlertBox:@"Error:51" withInfo:@"Input wrong row number for keyword."];
                        }
                        else
                        {
                            [self.labProductCol setStringValue:key];
                        }
                    }
                    
                    
                }
            }
            
            break;
        case 5:
            ret = [self.txtStationIDCol stringValue];  // can NA  --- station id col
            if([self popMsgWin_2:ret])
            {
                [self.txtStationIDCol setStringValue:@"NA"];
            }
            else
            {
                if ([self checkRow])
                {
                    if ([ret isEqualToString:@"NA"])
                    {
                        [self.labStationIdCol setStringValue:@""];
                    }
                    else
                    {
                        int row = [self.txtStartRow intValue];
                        int col = [ret intValue];
                        NSString *key = _data[row][col];
                        if ([key isEqualToString:@""])
                        {
                            //[self AlertBox:@"Error:51" withInfo:@"Input wrong row number for keyword."];
                        }
                        else
                        {
                            [self.labStationIdCol setStringValue:key];
                        }
                    }
                    
                    
                }
            }
            break;
        case 6:
            ret = [self.txtStartItemCol stringValue];   //first test item col
            if([self popMsgWin:ret])
            {
                [self.txtStartItemCol setStringValue:@"0"];
            }
            else
            {
                if ([self checkRow])
                {
                    int row = [self.txtStartRow intValue];
                    int col = [ret intValue];
                    NSString *key = _data[row][col];
                    if ([key isEqualToString:@""])
                    {
                       // [self AlertBox:@"Error:51" withInfo:@"Input wrong row number for keyword."];
                    }
                    else
                    {
                        [self.labStartItemCol setStringValue:key];
                    }
                    
                }
            }
            break;
        
        case 21:
            ret = [self.txtVersionCol stringValue];  // can NA  --- version col
            if([self popMsgWin_2:ret])
            {
                [self.txtVersionCol setStringValue:@"NA"];
            }
            else
            {
                if ([self checkRow])
                {
                    if ([ret isEqualToString:@"NA"])
                    {
                        [self.labVersionCol setStringValue:@""];
                    }
                    else
                    {
                        int row = [self.txtStartRow intValue];
                        int col = [ret intValue];
                        NSString *key = _data[row][col];
                        if ([key isEqualToString:@""])
                        {
                            //[self AlertBox:@"Error:51" withInfo:@"Input wrong row number for keyword."];
                        }
                        else
                        {
                            [self.labVersionCol setStringValue:key];
                        }
                    }
                    
                    
                }
            }
            break;
            
        case 22:
            ret = [self.txtListOfFailCol stringValue];  // can NA  --- list of fail
            if([self popMsgWin_2:ret])
            {
                [self.txtListOfFailCol setStringValue:@"NA"];
            }
            else
            {
                if ([self checkRow])
                {
                    if ([ret isEqualToString:@"NA"])
                    {
                        [self.labListOfFailCol setStringValue:@""];
                    }
                    else
                    {
                        int row = [self.txtStartRow intValue];
                        int col = [ret intValue];
                        NSString *key = _data[row][col];
                        if ([key isEqualToString:@""])
                        {
                            //[self AlertBox:@"Error:51" withInfo:@"Input wrong row number for keyword."];
                        }
                        else
                        {
                            [self.labListOfFailCol setStringValue:key];
                        }
                    }
                    
                    
                }
            }
            break;
        case 23:
            ret = [self.txtSlotIdCol stringValue];  // can NA  --- channel id col
            if([self popMsgWin_2:ret])
            {
                [self.txtSlotIdCol setStringValue:@"NA"];
            }
            else
            {
                if ([self checkRow])
                {
                    if ([ret isEqualToString:@"NA"])
                    {
                        [self.labSlotIdCol setStringValue:@""];
                    }
                    else
                    {
                        int row = [self.txtStartRow intValue];
                        int col = [ret intValue];
                        NSString *key = _data[row][col];
                        if ([key isEqualToString:@""])
                        {
                            //[self AlertBox:@"Error:51" withInfo:@"Input wrong row number for keyword."];
                        }
                        else
                        {
                            [self.labSlotIdCol setStringValue:key];
                        }
                    }
                    
                }
            }
            break;
        default:
            break;
    }
    
}

-(void)controlTextDidChange:(NSNotification *)obj
{
    // row--
    NSTextField *textF =obj.object;
    if ([textF isEqual:self.txtStartRow])  //item name row
    {
        NSString *ret = [self.txtStartRow stringValue];
        if ([self popMsgWin_3:ret with:NO])
        {
            [self.txtStartRow setStringValue:@"1"];
        }
        else
        {
            int ret_int = [ret intValue];
            if (ret_int >_maxRowNumber)
            {
                [self AlertBox:@"Error:53" withInfo:@"Input row number greater than max row."];
                [self.txtStartRow setStringValue:@"1"];
            }
            else
            {
                NSInteger n_number = 0;
                for (int j=0; j<[_data[ret_int] count]; j++)
                {
                    NSString *value = _data[ret_int][j];
                    if ([value length]>0)
                    {
                        n_number++;
                    }
                }
                if (n_number == _maxColumnNumber)
                {
                    NSLog(@"-> check OK");
                }
                else
                {
                    int r = [self AlertBoxWith2Button:@"Warning." withInfo:@"You set row number has empty test item name. If you Click 'OK' to force modify, maybe case error for column setting. If you did not want to modify, please click 'Cancel'."];
                    if (r==1000)
                    {
                        NSLog(@">OK..");
                    }
                    else
                    {
                        [self.txtStartRow setStringValue:[NSString stringWithFormat:@"%zd",_testItemnameRowNumber]];
                        NSLog(@">ignore");
                    }
                }
                
                
            }
        }
    }
    else if ([textF isEqual:self.txtUpperRow])
    {
        NSString *ret = [self.txtUpperRow stringValue];  // can NA
        if ([self popMsgWin_3:ret with:YES])
        {
            [self.txtUpperRow setStringValue:@"NA"];
        }
        else
        {
            int ret_int = [ret intValue];
            if (ret_int >_maxRowNumber)
            {
                [self AlertBox:@"Error:53" withInfo:@"Input row number greater than max row."];
                [self.txtUpperRow setStringValue:@"NA"];
            }
            
        }
        
    }
    else if ([textF isEqual:self.txtLowerRow])
    {
        NSString *ret = [self.txtLowerRow stringValue];  // can NA
        if ([self popMsgWin_3:ret with:YES])
        {
            [self.txtLowerRow setStringValue:@"NA"];
        }
        else
        {
            int ret_int = [ret intValue];
            if (ret_int >_maxRowNumber)
            {
                [self AlertBox:@"Error:53" withInfo:@"Input row number greater than max row."];
                [self.txtLowerRow setStringValue:@"NA"];
            }
            
        }
        
    }
    else if ([textF isEqual:self.txtUnitRow])
    {
        NSString *ret = [self.txtUnitRow stringValue];  //can NA
        if ([self popMsgWin_3:ret with:YES])
        {
            [self.txtUnitRow setStringValue:@"NA"];
        }
        else
        {
            int ret_int = [ret intValue];
            if (ret_int >_maxRowNumber)
            {
                [self AlertBox:@"Error:53" withInfo:@"Input row number greater than max row."];
                [self.txtUnitRow setStringValue:@"NA"];
            }
            
        }
        
    }
    else if ([textF isEqual:self.txtDataStartRow])
    {
        NSString *ret = [self.txtDataStartRow stringValue];
        if ([self popMsgWin_3:ret with:NO])
        {
            [self.txtDataStartRow setStringValue:@"4"];
        }
        else
        {
            int ret_int = [ret intValue];
            if (ret_int >_maxRowNumber)
            {
                [self AlertBox:@"Error:53" withInfo:@"Input row number greater than max row."];
                [self.txtDataStartRow setStringValue:@"4"];
            }
        }
        
    }
    
    
    //-----column
    else if ([textF isEqual:self.txtPassFailStatusCol])
    {
        NSString *ret = [self.txtPassFailStatusCol stringValue];
        if ([self popMsgWin_3:ret with:NO])
        {
            [self.txtPassFailStatusCol setStringValue:@"0"];
            [self.labPassFailStatusCol setStringValue:@""];
        }
        else
        {
            if ([self checkRow])
            {
                int row = [self.txtStartRow intValue];
                int col = [ret intValue];
                if (col>_maxColumnNumber)
                {
                    [self AlertBox:@"Error:54" withInfo:@"Input column number greater than max column."];
                    [self.txtPassFailStatusCol setStringValue:@"0"];
                    [self.labPassFailStatusCol setStringValue:@""];
                }
                else
                {
                    NSString *key = _data[row][col];
                    if ([key isEqualToString:@""])
                    {
                        [self AlertBox:@"Error:52" withInfo:@"Keyword is empty, can not find 'PASS/FAIL' keyword.\nPlease check your input 'Item name in row', and 'Keyword PASS/FAIL in column' "];
                        [self.txtPassFailStatusCol setStringValue:@""];
                        [self.labPassFailStatusCol setStringValue:@""];
                    }
                    else
                    {
                        [self.labPassFailStatusCol setStringValue:key];
                        BOOL flagStatus = NO;
                        for (int i=0; i<_maxRowNumber; i++)
                        {
                            NSString * val = _data[i][col];
                            if ([val isEqualToString:@"PASS"] || [val isEqualToString:@"FAIL"])
                            {
                                flagStatus = YES;
                            }
                        }
                        if (!flagStatus)
                        {
                            [self AlertBox:@"Error:54" withInfo:@"Input column number does not contain the 'PASS' or 'Fail' status."];
                        }
                        
                    }
                }
                
                
            }
        }
    }
    else if ([textF isEqual:self.txtSerialNumberCol])
    {
        NSString *ret = [self.txtSerialNumberCol stringValue];
        if ([self popMsgWin_3:ret with:NO])
        {
            [self.txtSerialNumberCol setStringValue:@"0"];
            [self.labSerialNumberCol setStringValue:@""];
        }
        else
        {
            if ([self checkRow])
            {
                int row = [self.txtStartRow intValue];
                int col = [ret intValue];
                if (col>_maxColumnNumber)
                {
                    [self AlertBox:@"Error:54" withInfo:@"Input column number greater than max column."];
                    [self.txtSerialNumberCol setStringValue:@"0"];
                    [self.labSerialNumberCol setStringValue:@""];
                }
                else
                {
                    NSString *key = _data[row][col];
                    if ([key isEqualToString:@""])
                    {
                        [self AlertBox:@"Error:52" withInfo:@"Keyword is empty, can not find 'SerialNumber' keyword.\nPlease check your input 'Item name in row', and 'Keyword SerialNumber in column' "];
                        [self.txtSerialNumberCol setStringValue:@""];
                        [self.labSerialNumberCol setStringValue:@""];
                    }
                    else
                    {
                        [self.labSerialNumberCol setStringValue:key];
                    }
                }
                
                
            }
        }
        
    }
    else if ([textF isEqual:self.txtStartTimeCol])
    {
        NSString *ret = [self.txtStartTimeCol stringValue];  // can NA
        if([self popMsgWin_3:ret with:YES])
        {
            [self.txtStartTimeCol setStringValue:@"NA"];
            [self.labStartTimeCol setStringValue:@""];
        }
        else
        {
            if ([self checkRow])
            {
                if ([ret isEqualToString:@"N"]||[ret isEqualToString:@"NA"])
                {
                    [self.labStartTimeCol setStringValue:@""];
                }
                else
                {
                    int row = [self.txtStartRow intValue];
                    int col = [ret intValue];
                    if (col>_maxColumnNumber)
                    {
                        [self AlertBox:@"Error:54" withInfo:@"Input column number greater than max column."];
                        [self.txtStartTimeCol setStringValue:@"NA"];
                        [self.labStartTimeCol setStringValue:@""];
                    }
                    else
                    {
                        NSString *key = _data[row][col];
                        if ([key isEqualToString:@""])
                        {
                            [self AlertBox:@"Error:52" withInfo:@"Keyword is empty, can not find 'Test Start Time' keyword.\nPlease check your input 'Item name in row', and 'Keyword Test Start Time in column' "];
                            [self.txtStartTimeCol setStringValue:@"NA"];
                            [self.labStartTimeCol setStringValue:@""];
                        }
                        else
                        {
                            [self.labStartTimeCol setStringValue:key];
                        }
                        
                    }
                    
                }
                
                
            }
        }
        
    }
    else if ([textF isEqual:self.txtProductCol])
    {
        NSString *ret = [self.txtProductCol stringValue];  // can NA
        if([self popMsgWin_3:ret with:YES])
        {
            [self.txtProductCol setStringValue:@"NA"];
            [self.labProductCol setStringValue:@""];
        }
        else
        {
            if ([self checkRow])
            {
                if ([ret isEqualToString:@"N"]||[ret isEqualToString:@"NA"])
                {
                    [self.labProductCol setStringValue:@""];
                }
                else
                {
                    int row = [self.txtStartRow intValue];
                    int col = [ret intValue];
                    if (col>_maxColumnNumber)
                    {
                        [self AlertBox:@"Error:54" withInfo:@"Input column number greater than max column."];
                        [self.txtProductCol setStringValue:@"NA"];
                        [self.labProductCol setStringValue:@""];
                        
                    }
                    else
                    {
                        NSString *key = _data[row][col];
                        if ([key isEqualToString:@""])
                        {
                            [self AlertBox:@"Error:52" withInfo:@"Keyword is empty, can not find 'Product' keyword.\nPlease check your input 'Item name in row', and 'Keyword Product in column' "];
                            [self.txtProductCol setStringValue:@"NA"];
                            [self.labProductCol setStringValue:@""];
                        }
                        else
                        {
                            [self.labProductCol setStringValue:key];
                        }
                    }
                    
                }
                
            }
        }
        
    }
    else if ([textF isEqual:self.txtStationIDCol])
    {
        NSString *ret = [self.txtStationIDCol stringValue];  // can NA
        if([self popMsgWin_3:ret with:YES])
        {
            [self.txtStationIDCol setStringValue:@"NA"];
            [self.labStationIdCol setStringValue:@""];
        }
        else
        {
            if ([self checkRow])
            {
                if ([ret isEqualToString:@"N"]||[ret isEqualToString:@"NA"])
                {
                    [self.labStationIdCol setStringValue:@""];
                }
                else
                {
                    int row = [self.txtStartRow intValue];
                    int col = [ret intValue];
                    if (col>_maxColumnNumber)
                    {
                        [self AlertBox:@"Error:54" withInfo:@"Input column number greater than max column."];
                        [self.txtStationIDCol setStringValue:@"NA"];
                        [self.labStationIdCol setStringValue:@""];
                    }
                    else
                    {
                        NSString *key = _data[row][col];
                        if ([key isEqualToString:@""])
                        {
                            [self AlertBox:@"Error:52" withInfo:@"Keyword is empty, can not find 'Station ID' keyword.\nPlease check your input 'Item name in row', and 'Keyword Station ID in column' "];
                            [self.txtStartTimeCol setStringValue:@"NA"];
                            [self.labStationIdCol setStringValue:@""];
                        }
                        else
                        {
                            [self.labStationIdCol setStringValue:key];
                        }
                    }
                    
                    
                }
                
                
            }
        }
        
    }
    else if ([textF isEqual:self.txtStartItemCol])
    {
        NSString *ret = [self.txtStartItemCol stringValue];
        if([self popMsgWin_3:ret with:NO])
        {
            [self.txtStartItemCol setStringValue:@"0"];
            [self.labStartItemCol setStringValue:@""];
        }
        else
        {
            if ([self checkRow])
            {
                int row = [self.txtStartRow intValue];
                int col = [ret intValue];
                if (col>_maxColumnNumber)
                {
                    [self AlertBox:@"Error:54" withInfo:@"Input column number greater than max column."];
                    [self.txtStartItemCol setStringValue:@"0"];
                    [self.labStartItemCol setStringValue:@""];
                }
                else
                {
                    NSString *key = _data[row][col];
                    if ([key isEqualToString:@""])
                    {
                        //[self AlertBox:@"Error:52" withInfo:@"Input item name row is wrong, "];
                    }
                    else
                    {
                        [self.labStartItemCol setStringValue:key];
                    }
                }
                
                
            }
        }
        
    }
    
    
    
}
@end
