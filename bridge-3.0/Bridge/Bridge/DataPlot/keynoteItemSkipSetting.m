//
//  keynoteItemSkipSetting.m
//  Bridge
//
//  Created by RyanGao on 2020/8/8.
//  Copyright © 2020 RyanGao. All rights reserved.
//

#import "keynoteItemSkipSetting.h"
#import "defineHeader.h"
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

extern NSMutableArray *_dataReverse;



#define MyTableCellViewDataType @"MyTableCellViewDataType"

//#define MyGroupName  @"Test_Group_Name"
//#define MyGroupFlag  @"Test_Group_Flag"
#define MyGroupName   @"Test_Group"
#define MyGroupName2  @"Test_Group_Test_Group"
#define MyGroupName3  @"Test_Group_Test_Group_Test_Group"
#define MySubName    @"Test_Sub_Name"
#define MyGroupFlag  @"Test_Group_Flag"

@interface keynoteItemSkipSetting ()


@end

@implementation keynoteItemSkipSetting
@synthesize label, table;



-(instancetype)init
{
    self = [super init];
    if (self)
    {
        dataArray = [[NSMutableArray alloc] init];
        expandTable = [[NSMutableArray alloc] init];
        expandedArray = [[NSMutableArray alloc] init];
        subNameArray = [[NSMutableArray alloc] init];
        

       // [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(CreateCSVDebugPanel:) name:kProfilePath object:nil];
    }
    return self;
}

-(void)iconCilcked:(id)sender {
    NSLog(@"icon clicked");
    [self tableToggleBlock:sender];
}

-(void)tableToggleBlock:(id)sender
{

    if ([table clickedColumn] == 0 || [table clickedColumn] == 1 )
    {
        // 如果是group 就折疊
        if ([[expandTable objectAtIndex:[table clickedRow]] isKindOfClass:[GroupEntry class]])
        {
            // 找到 group 物件
            GroupEntry *clickedGroup = (GroupEntry *)[expandTable objectAtIndex:[table clickedRow]];
            clickedGroup.isExpand = !clickedGroup.isExpand;
            
            [self refreshData];
            [table reloadData];
        }
        else if ([[expandTable objectAtIndex:[table clickedRow]] isKindOfClass:[SubNameEntry class]])
        {
            // 找到 subName 物件
            SubNameEntry *clickedSubName = (SubNameEntry *)[expandTable objectAtIndex:[table clickedRow]];
            clickedSubName.isExpand = !clickedSubName.isExpand;
            [self refreshData];
            [table reloadData];
        }
    }
    else
    {
    }

    NSLog(@"run toggle : %zd",[table clickedColumn]);
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
                [_item2Yes setState:check];
                [_item2No setState:!check];
                
            }
            else
            {
                [_item2Yes setState:!check];
                [_item2No setState:check];
            }
            
        }
            break;
        case 21:
        {
            if (check)
               {
                   [_item2Yes setState:!check];
                   [_item2No setState:check];
               }
            else
            {
                [_item2Yes setState:check];
                [_item2No setState:!check];
            }
            
        }
            break;
        default:
            break;
    }
    
    [m_configDictionary setValue:[NSNumber numberWithInteger:[_item2Yes state]] forKey:@"item10Yes"];
    [m_configDictionary setValue:[NSNumber numberWithInteger:[_item2No state]] forKey:@"item10No"];
    
    
}

#pragma mark - delegate
//-(BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
//    [self tableToggleBlock:nil];
//    if ([tableColumn.identifier isEqualToString:@"commandname"]) {
//        return YES;
//    }
//    return NO;
//}

-(BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    [self tableToggleBlock:@""];
    return YES;
}

//- (NSIndexSet *)tableView:(NSTableView *)tableView selectionIndexesForProposedSelection:(NSIndexSet *)proposedSelectionIndexes {
//    if([proposedSelectionIndexes count] == 1) {
//        // 單選
//        NSLog(@"index %@", proposedSelectionIndexes);
//        return proposedSelectionIndexes;
//    }
//
//    // 多選情況
//    NSInteger selectedRow = table.selectedRow;
//    // 找出與 select row 相等的類別
//    id<EntryIndexProtocol> selectedEntry = [expandTable objectAtIndex:selectedRow];
//    NSArray *selectedEntryIndex = [selectedEntry getEntryIndex];
//
//    // 轉 indexset 成 array
//    NSMutableArray *selectedIndexArray=[NSMutableArray array];
//    [proposedSelectionIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
//        [selectedIndexArray addObject:[NSNumber numberWithInteger:idx]];
//    }];
//
//
//    NSMutableIndexSet *returnIndexSet = [NSMutableIndexSet indexSet];
//    // 只允許同一類型(class)、同一層級(entryIndex 只有最後不同)
//    for (NSInteger i= 0, ii= selectedIndexArray.count; i<ii; i++) {
//        // indexset 指向目標 是否同類別
//        if ([[expandTable objectAtIndex:[selectedIndexArray[i] integerValue]] isKindOfClass:[(id)selectedEntry class]]
//            && [[expandTable objectAtIndex:[selectedIndexArray[i] integerValue]] conformsToProtocol:@protocol(EntryIndexProtocol)]) {
//            // 待檢查物件
//            id <EntryIndexProtocol> checkingEntry = [expandTable objectAtIndex:[selectedIndexArray[i] integerValue]];
//
//            NSArray *checkingIndexEntry = [checkingEntry getEntryIndex];
//            if ([checkingIndexEntry count] == [selectedEntryIndex count]) {
//
//                BOOL underSamePath = YES;
//                NSInteger checkingIndex = 0;
//                if ([selectedEntryIndex count] == 1) {
//                    // 特殊情況，選擇了最上層物件, 不用比對
//                }
//                else {
//                    // 只比較最後一個元素之前的元素
//                    do {
//                        if ([checkingIndexEntry objectAtIndex:checkingIndex] != [selectedEntryIndex objectAtIndex:checkingIndex]) {
//                            underSamePath = NO;
//                        }
//                        checkingIndex++;
//                    } while (checkingIndex < ([checkingIndexEntry count] - 1));
//                }
//                if (underSamePath) {
//                    [returnIndexSet addIndex:[selectedIndexArray[i] integerValue]];
//                }
//            }
//        }
//    }
//    return returnIndexSet;
//}
-(void) setCheckItem:(id) data
{
  
    NSNumber *row = data;
    GroupEntry *group = [expandTable objectAtIndex:row.integerValue];
    [group setIsChecked:!group.isChecked];
    //NSLog(@"====>>> %@",group.iD);
    
    if ([group.iD containsString:MyGroupName3])
    {
        SubSubNameEntry *subsubname = (SubSubNameEntry *)group;
        [subsubname setIsChecked:group.isChecked];
        
    }
    else if ([group.iD containsString:MyGroupName2])
    {
        
        for (id tempsubsubname in group.strArray)
        {
            SubSubNameEntry *subsubname = (SubSubNameEntry *)tempsubsubname;
            [subsubname setIsChecked:group.isChecked];
        }
    }
    else if ([group.iD containsString:MyGroupName])
    {
        for (id tempsubname in group.strArray)
        {
            SubNameEntry *subname = (SubNameEntry *)tempsubname;
            [subname setIsChecked:group.isChecked];
            
            for (id tempsubsubname in subname.strArray)
            {
                SubSubNameEntry *subsubname = (SubSubNameEntry *)tempsubsubname;
                [subsubname setIsChecked:subname.isChecked];
            }
            
        }
    }

    [self refreshData];
    [table reloadData];
}

#pragma mark - datasource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    if (aTableView == table) {
        return [expandTable count];
    }
    return 0;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
//    id entry = [expandTable objectAtIndex:rowIndex];
//    if ([aTableColumn.identifier isEqualToString:@"blockimage"]) {
//        // image
//        if ([entry isKindOfClass:[GroupEntry class]]) {
//            GroupEntry *aa = (GroupEntry*)entry;
//            if (aa.isExpand) {
//                return [NSImage imageNamed:@"open"];
//            }
//            else {
//                return [NSImage imageNamed:@"close"];
//            }
//        }
//        else {
//            return nil;
//        }
//    }
//    return [entry description];
    
    return nil;
  
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
 {
    
     id entry = [expandTable objectAtIndex:rowIndex];
          if ([aTableColumn.identifier isEqualToString:@"blockimage"])
          {
              if ([entry isKindOfClass:[GroupEntry class]]) {
                  GroupEntry *aa = (GroupEntry*)entry;
                  if (aa.isExpand)
                  {
                      RyanCheckImageCell *checkCell = cell;
                      [checkCell setImage:[NSImage imageNamed:@"open"]];
                  }
                  else
                  {
                      RyanCheckImageCell *checkCell = cell;
                      [checkCell setImage:[NSImage imageNamed:@"close"]];
                  }
              }
              else
              {
                  
              }
          }
          else if ([aTableColumn.identifier isEqualToString:@"blockimagesub"])
          {
              if ([entry isKindOfClass:[SubNameEntry class]]) {
                  SubNameEntry *aa = (SubNameEntry*)entry;
                  if (aa.isExpand)
                  {
                      RyanCheckImageCell *checkCell = cell;
                      [checkCell setImage:[NSImage imageNamed:@"open"]];
                  }
                  else
                  {
                      RyanCheckImageCell *checkCell = cell;
                      [checkCell setImage:[NSImage imageNamed:@"close"]];
                  }
              }
              else
              {
                  
              }
          }
          
          else if ([aTableColumn.identifier isEqualToString:@"grouptestname"])  // no use
          {
              
     //         NSTextFieldCell *textCell = cell;
     //         [textCell setTitle:[entry iD]];
          }
          else if ([aTableColumn.identifier isEqualToString:@"subtestname"])
          {
              
             RyanCheckImageCell *checkCell = cell;
             if ([entry isKindOfClass:[GroupEntry class]])
             {
                 [checkCell setXpos:0];
             }
              else if ([entry isKindOfClass:[SubNameEntry class]])
              {
                 [checkCell setXpos:20];
              }
              else if ([entry isKindOfClass:[SubSubNameEntry class]])
              {
                 [checkCell setXpos:40];
              }
              else
              {
                 [checkCell setXpos:0];
              }
              
              
              [checkCell setTitle:[entry name]];
              [checkCell setBackgroundColor:[entry textColor]];
              [checkCell setIsChecked:[entry isChecked]];
              

          }
          else if ([aTableColumn.identifier isEqualToString:@"subsubtestname"]) //no use
          {
              
     //        RyanCheckImageCell *checkCell = cell;
     //        [checkCell setTitle:[entry name]];
     //        [checkCell setBackgroundColor:[entry textColor]];
     //        [checkCell setIsChecked:[entry isChecked]];
     //
     //         NSLog(@"===11===>>> %@ %@",[entry name],checkCell.identifier);

          }
          else
          {

          }
   
 }

#pragma mark - default

-(void)refreshData {
    // data source 更新時，需要重新設定一次 expandedArray, expandTable 並進入預設狀態: 全部展開
    
    // 將 data source 不分層級全部展開放到 exapand array 中
    NSMutableArray *tempExpandArray = nil;
    if (tempExpandArray) {
        [tempExpandArray removeAllObjects];
    }
    else
    {
        tempExpandArray =  [[NSMutableArray alloc] init];
    }
    NSMutableArray *tempExpandTable = nil;
    if (tempExpandTable) {
        [tempExpandTable removeAllObjects];
    }
    else
    {
        tempExpandTable = [[NSMutableArray alloc] init];
    }
    
    [array_CSV removeAllObjects];
    for (id tempGroup in dataArray)
    {
        if ([tempGroup isKindOfClass:[GroupEntry class]])
        {
            GroupEntry *group = (GroupEntry *)tempGroup;
            [tempExpandArray addObject:group];
            [tempExpandTable addObject:group];
            
            for (id tempsubname in group.strArray)
            {
                SubNameEntry *subname = (SubNameEntry *)tempsubname;
                [tempExpandArray addObject:subname];
                if (group.isExpand)
                {
                    [tempExpandTable addObject:subname];
                
                
                     for (id tempsubsubname in subname.strArray)
                     {
                         SubSubNameEntry *subsubname = (SubSubNameEntry *)tempsubsubname;
                         [tempExpandArray addObject:subsubname];
                         if (subname.isExpand)
                         {
                             [tempExpandTable addObject:subsubname];
                         }
                         
                         if ([subsubname isChecked])
                         {
                             NSString * str = subsubname.csvLine;
                             [array_CSV addObject:str];
                         }
                         
                     }
                }
                else
                {
                    for (id tempsubsubname in subname.strArray)
                    {
                         SubSubNameEntry *subsubname = (SubSubNameEntry *)tempsubsubname;
                         [tempExpandArray addObject:subsubname];
                        if ([subsubname isChecked])
                        {
                            NSString * str = subsubname.csvLine;
                            [array_CSV addObject:str];
                        }

                    }
                }
            
            }
        }
    }
    expandedArray = tempExpandArray;
    expandTable = tempExpandTable;
     //[self updateDataArray];
}


-(void)viewWillAppear {
    //[super viewWillAppear];
    [table setAllowsMultipleSelection: YES];
}


-(void)updateDataArray
{

    NSMutableArray *tempData = nil;
    if (tempData)
    {
        [tempData removeAllObjects];
    }
    else
    {
        tempData = [[NSMutableArray alloc] init];
    }
    
    int a=0;
    for (id tempGroup in expandTable)
    {
        if ([tempGroup isKindOfClass:[GroupEntry class]])
        {
            GroupEntry *group = (GroupEntry *)tempGroup;
            
            GroupEntry *groupTemp = [[GroupEntry alloc] init];
            
            groupTemp.name = group.name;
            groupTemp.entryIndex = group.getEntryIndex;
            groupTemp.isExpand = group.isExpand;
            groupTemp.iD = group.iD;
            groupTemp.name_flag = group.name_flag;
            groupTemp.isChecked = group.isChecked;
            
            int b=0;
            NSMutableArray *tempListSub = [[NSMutableArray alloc] init];
            for (id tempsubname in group.strArray)
            {
                SubNameEntry *subname = (SubNameEntry *)tempsubname;
                SubNameEntry *subnameTemp = [[SubNameEntry alloc] init];
                subnameTemp.entryIndex = subname.getEntryIndex;
                subnameTemp.iD = subname.iD;
                subnameTemp.name_flag = subname.name_flag;
                subnameTemp.isChecked = subname.isChecked;
                subnameTemp.name = subname.name;
                
                if (group.isExpand)
                {
                    if ([expandTable count]>a+b+1)
                    {
                        //subnameTemp.name = [NSString stringWithFormat:@"%@",expandTable[a+b+1]];
                    }
                    else
                    {
                        
                        [self AlertBox:@"Error" withInfo:@"You can't drag to different groups!!!!\r\n不能把item拖到其他Group里面,拖放出错!!!!"];
                        //subnameTemp.name = subname.name;
                    }
                    
                     NSMutableArray *tempListSubSub = [[NSMutableArray alloc] init];
                     for (id tempsubsubname in subname.strArray)
                     {
                         SubSubNameEntry *subsubname = (SubSubNameEntry *)tempsubsubname;
                         SubSubNameEntry *subsubnameTemp = [[SubSubNameEntry alloc] init];
                          subsubnameTemp.entryIndex = subsubname.getEntryIndex;
                          subsubnameTemp.iD = subsubname.iD;
                          subsubnameTemp.name_flag = subsubname.name_flag;
                          subsubnameTemp.name_flag2 = subsubname.name_flag2;
                          subsubnameTemp.isChecked = subsubname.isChecked;
                          subsubnameTemp.name = subsubname.name;
                         
                         [tempListSubSub addObject:subsubnameTemp];
                        
                         
                     }
                    
                    subnameTemp.strArray = tempListSubSub;
                    
                    
                }

                [tempListSub addObject:subnameTemp];
               
                b++;
            }
            
            group.strArray = tempListSub;
           
            [tempData addObject:group];
            
        }
        a++;
    }
    dataArray = tempData;
    
}

- (void)setRepresentedObject:(id)representedObject {
   // [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}


- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard
{
    // Copy the row numbers to the pasteboard.
    NSData *zNSIndexSetData = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
    [pboard declareTypes:[NSArray arrayWithObject:MyTableCellViewDataType] owner:self];
    [pboard setData:zNSIndexSetData forType:MyTableCellViewDataType];
    return YES;
}

- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)op
{
    // Add code here to validate the drop
    //NSLog(@"validate Drop");
    return NSDragOperationEvery;
}
-(void)AlertBox:(NSString *)msgTxt withInfo:(NSString *)strmsg
{
    NSAlert * alert = [[NSAlert alloc] init];
    alert.messageText = msgTxt;
    alert.informativeText = strmsg;
    [alert runModal];
}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id <NSDraggingInfo>)info
              row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation
{
    return NO;
    /*
    NSPasteboard* pboard = [info draggingPasteboard];
    NSData* rowData = [pboard dataForType:MyTableCellViewDataType];
    NSIndexSet* rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
    NSInteger dragRow = [rowIndexes firstIndex];
    
    // Move the specified row to its new location...
    // if we remove a row then everything moves down by one
    // so do an insert prior to the delete
    // --- depends which way we're moving the data!!!
    
    GroupEntry *groupDrag = [expandTable objectAtIndex:dragRow];
    if ([expandTable count]<=row)
    {
        return NO;
    }
    GroupEntry *groupRow = [expandTable objectAtIndex:row];
    
    NSLog(@"groupDrag.name_flag: %@  groupRow.name_flag:%@\r\ngroupDrag.name_flag2:%@         groupRow.name_flag2:%@",groupDrag.name_flag,groupRow.name_flag,groupDrag.name_flag2,groupRow.name_flag2);
    
    if ([groupDrag.iD containsString:MyGroupName3])
    {
        
    }
    else if ([groupDrag.iD containsString:MyGroupName2] )
    {
        [self ExpandAndShrinkSubName:YES withSubSubName:NO];
        
        if ([expandTable count]<dragRow || [expandTable count]<row)
        {
            [self AlertBox:@"Tip" withInfo:@"Please .reselect and drag the SubName\r\n请 重新单击拖动，当SubName收缩起来时，才能拖动!!!"];
            [table reloadData];
            return NO;
        }
        
    }
    else if ([groupDrag.iD containsString:MyGroupName])
    {
        [self ExpandAndShrinkSubName:NO withSubSubName:NO];
        
        if ([expandTable count]<dragRow || [expandTable count]<row)
        {
            [self AlertBox:@"Tip!" withInfo:@"Please reselect and drag the Group\r\n请 重新单击拖动，当Group收缩起来时，才能拖动!!!"];
            [table reloadData];
            return NO;
        }
        
    }


    if (![groupDrag.name_flag isEqualToString:groupRow.name_flag])
    {
        [self AlertBox:@"Error!!" withInfo:@"You can't drag to different SubName!!\r\n不能把item拖到其他SubName里面，只能在同一个SubName里面拖动!!"];
        NSLog(@"----error--@_@@");

        [table reloadData];
        return NO;
    }
    if (![groupDrag.name_flag2 isEqualToString:groupRow.name_flag2])
    {
        [self AlertBox:@"Error!" withInfo:@"You can't drag to different SubName!!\r\n不能把item拖到其他SubName里面，只能在同一个SubName里面拖动!!"];
        NSLog(@"----error--@");
        [table reloadData];
        return NO;
    }
    
    if (dragRow < row)
    {

        [expandTable insertObject:groupDrag atIndex:row];
        [expandTable removeObjectAtIndex:dragRow];
        [self updateDataArray];
        [table noteNumberOfRowsChanged];
        [table reloadData];
        return YES;
    }
    
    NSString * zData = [expandTable objectAtIndex:dragRow];
    [expandTable removeObjectAtIndex:dragRow];
    [expandTable insertObject:zData atIndex:row];
    [self updateDataArray];
    [table noteNumberOfRowsChanged];
    [table reloadData];
    
    return YES;
    */
    
}

-(void)ExpandAndShrinkSubName:(bool)status withSubSubName:(bool) status2
{
   
    NSMutableArray *tempExpandArray = nil;
    if (tempExpandArray) {
        [tempExpandArray removeAllObjects];
    }
    else
    {
        tempExpandArray =  [[NSMutableArray alloc] init];
    }
    NSMutableArray *tempExpandTable = nil;
    if (tempExpandTable) {
        [tempExpandTable removeAllObjects];
    }
    else
    {
        tempExpandTable = [[NSMutableArray alloc] init];
    }
    [array_CSV removeAllObjects];
    for (id tempGroup in dataArray) {
        if ([tempGroup isKindOfClass:[GroupEntry class]]) {
            GroupEntry *group = (GroupEntry *)tempGroup;
            group.isExpand = status;
            [tempExpandArray addObject:group];
            [tempExpandTable addObject:group];
            
            for (id tempsubname in group.strArray)
            {
                SubNameEntry *subname = (SubNameEntry *)tempsubname;
                subname.isExpand = status2;
                [tempExpandArray addObject:subname];
                if (group.isExpand)
                {
                    [tempExpandTable addObject:subname];
                    for (id tempsubsubname in subname.strArray)
                    {
                         SubSubNameEntry *subsubname = (SubSubNameEntry *)tempsubsubname;
                         [tempExpandArray addObject:subsubname];
                         if (subname.isExpand)
                         {
                            [tempExpandTable addObject:subsubname];
                         }
                        if ([subsubname isChecked])
                        {
                                  NSString * str = subsubname.csvLine;
                                  [array_CSV addObject:str];
                        }
                        
                    }
                }
                else
                {
                    for (id tempsubsubname in subname.strArray)
                    {
                         SubSubNameEntry *subsubname = (SubSubNameEntry *)tempsubsubname;
                         [tempExpandArray addObject:subsubname];
                        if ([subsubname isChecked])
                        {
                            NSString * str = subsubname.csvLine;
                            [array_CSV addObject:str];
                        }
                        
                    }
                }
                

            }
        }
    }
    expandedArray = tempExpandArray;
    expandTable = tempExpandTable;
    dataArray = tempExpandArray;
    [table reloadData];
}

-(void)awakeFromNib{
    //[super viewDidLoad];
    NSLog(@"--viewDidLoad--");
    [table registerForDraggedTypes:[NSArray arrayWithObject:MyTableCellViewDataType] ];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showGroupPanel:) name:kLoadGroupPanel object:nil];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [_keynoteItemSkipWin setLevel:kCGFloatingWindowLevel];
   // [table setAllowsMultipleSelection: YES];
    NSLog(@"--viewDidLoad--");
    array_CSV =  [[NSMutableArray alloc] init];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    NSString *csv_path = [m_configDictionary valueForKey:Load_Csv_Path];
    NSString *csv_path_local = [m_configDictionary valueForKey:Load_Local_Csv_Path];
    NSLog(@"====>csv_path: %@   csv_path_local: %@",csv_path,csv_path_local);
    [self showGroupPanel:nil];
    [self refreshData];
    [table reloadData];
    
    [_txtCPKHigh setStringValue:@"10.0"];
    [m_configDictionary setValue:@"10.0" forKey:kcpkKeynoteHighThd];
    
    [m_configDictionary setValue:[NSNumber numberWithInt:1] forKey:@"item10Yes"];
    [m_configDictionary setValue:[NSNumber numberWithInt:0] forKey:@"item10No"];
    
}

-(void)showGroupPanel:(NSNotification *)nf
{
    NSArray *itemArr = [m_configDictionary valueForKey:k_All_Item_Name];
    NSString *lastTestName = @"";
    NSString *lastSubTestName = @"";
    NSMutableString *mutableStr = nil;
    if (mutableStr)
    {
        [mutableStr setString:@""];
    }
    else
    {
        mutableStr = [[NSMutableString alloc] init];
    }
    for (int i = 0; i< [itemArr count]; i++)
    {
        NSArray *groupname = [itemArr[i] componentsSeparatedByString:@" "];
        NSString *testName = @"";
        NSString *subName = @"";
        NSString *subsubName = @"";
        if ([groupname count]>2)
        {
            testName = groupname[0];
            subName = groupname[1];
            subsubName = groupname[2];
        }
        else
        {
            testName = groupname[0];
            subName = @"";
            subsubName = @"";
        }
          NSString * currentTestName = [NSString stringWithFormat:@"%@",testName];
           NSString * currentSubTestName = [NSString stringWithFormat:@"%@,%@",testName,subName];
           if ([currentTestName isNotEqualTo:lastTestName])
           {
               [mutableStr appendString:@"#$#$#$#$#"];
               [mutableStr appendString:[NSString stringWithFormat:@"%@#&#&#", testName]];
           }
           if([currentSubTestName isNotEqualTo:lastSubTestName])
           {
               [mutableStr appendString:@"#!#!#!#!#"];
               [mutableStr appendString:[NSString stringWithFormat:@"%@#&#&#", subName]];
           }
          
           [mutableStr appendString:@"#$!#$!#$!#$!#"];
           [mutableStr appendString:[NSString stringWithFormat:@"%@&!&!&!%@#&#&#",subsubName,itemArr[i]]];
           
           lastTestName = currentTestName;
           lastSubTestName = currentSubTestName;
    }
    
    NSMutableArray *tempData = nil;
        if (tempData) {
            [tempData removeAllObjects];
        }
        else
        {
            tempData = [[NSMutableArray alloc] init];
        }
    
        NSArray *strArrayName = [mutableStr componentsSeparatedByString:@"#$#$#$#$#"];
    
        int index_subitem = 1;
        int index_subsubitem = 1;
        for (int i=0; i<[strArrayName count]; i++)
        {
            NSArray * strArrayNameTemp = [strArrayName[i] componentsSeparatedByString:@"#&#&#"];
            if ([strArrayNameTemp count]<1)
            {
                return;
            }
            
            if ([[strArrayNameTemp[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualTo:@""])
            {
                continue;
            }
            
            //NSLog(@"==test Name==%@",strArrayNameTemp[0]);
            GroupEntry *group = [[GroupEntry alloc] init];
            group.nameGroup = strArrayNameTemp[0];
            //group.name = strArrayNameTemp[0];
            group.name = [NSString stringWithFormat:@"%d : %@",i,strArrayNameTemp[0]];
            group.csvLine = @"";
            group.entryIndex = @[@(i)];
            group.isExpand = NO;
            group.iD = [NSString stringWithFormat:@"%@:%d",MyGroupName,i];
            group.name_flag = [NSString stringWithFormat:@"group:%@: 8001",MyGroupFlag];
            group.name_flag2 = [NSString stringWithFormat:@"sub:%@: %i",MySubName,i];
            group.isChecked = YES;
            //group.textColor = [NSColor lightGrayColor];
            
            NSMutableArray *tempList = [[NSMutableArray alloc] init];
            NSArray *strArraySubName = [strArrayName[i] componentsSeparatedByString:@"#!#!#!#!#"];
            for (int j=1; j< [strArraySubName count]; j++)
            {
                NSArray * strArraySubNameTemp = [strArraySubName[j] componentsSeparatedByString:@"#&#&#"];
                if ([strArraySubNameTemp count]< 1)
                {
                    return;
                }
                if ([[strArraySubNameTemp[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualTo:@""])
                {
                    continue;
                }
                
                //NSLog(@"==sub Name==%@",strArraySubNameTemp[0]);
                SubNameEntry *subname = [[SubNameEntry alloc] init];
                subname.nameGroup = strArraySubNameTemp[0];
                subname.name =  [NSString stringWithFormat:@"%@      ", strArraySubNameTemp[0]];
                //subname.name = [NSString stringWithFormat:@"%d~%d : %@",i,index_subitem,strArraySubNameTemp[0]];
                index_subitem++;
                subname.entryIndex = @[@(i), @(j)];
                subname.iD = [NSString stringWithFormat:@"%@:%d",MyGroupName2,i];
                subname.csvLine = @"";
                subname.name_flag = [NSString stringWithFormat:@"group:%@: 8001",MyGroupFlag];
                subname.name_flag2 = [NSString stringWithFormat:@"sub:%@: %i",MySubName,i];
                subname.isChecked = YES;
                
                NSMutableArray *tempListSub = [[NSMutableArray alloc] init];
                NSArray *strArraySubSubName = [strArraySubName[j] componentsSeparatedByString:@"#$!#$!#$!#$!#"];
                for (int x = 1; x< [strArraySubSubName count]; x++)
                {

                    NSArray * strArraySubSubNameTemp = [strArraySubSubName[x] componentsSeparatedByString:@"#&#&#"];
                    if ([strArraySubSubNameTemp count]< 1)
                    {
                        return;
                    }
                    if ([[strArraySubSubNameTemp[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualTo:@""])
                    {
                        continue;
                    }
                    
                    //NSLog(@"==sub sub Name==%@",strArraySubSubNameTemp[0]);
                    NSArray *subSubNameArray = [strArraySubSubNameTemp[0] componentsSeparatedByString:@"&!&!&!"];
                    SubSubNameEntry *subsubname = [[SubSubNameEntry alloc] init];
                    subsubname.nameGroup = strArraySubNameTemp[0];
                    if ([subSubNameArray[0] length]<20)
                    {
                        subsubname.name = [NSString stringWithFormat:@"%d : %@                    ",index_subsubitem,subSubNameArray[0]];
                    }
                    else
                    {
                        subsubname.name = [NSString stringWithFormat:@"%d : %@",index_subsubitem,subSubNameArray[0]];
                    }
                    index_subsubitem++;
                    subsubname.entryIndex = @[@(i), @(x)];
                    subsubname.iD = [NSString stringWithFormat:@"%@:%d",MyGroupName3,i];
                    subsubname.csvLine = subSubNameArray[1];
                    subsubname.name_flag = [NSString stringWithFormat:@"group:%@: 8001",MyGroupFlag];
                    subsubname.name_flag2 = [NSString stringWithFormat:@"sub:%@: %i",MySubName,i];
                    subsubname.isChecked = YES;
                    [tempListSub addObject:subsubname];
                    
                    
                }
                
                subname.strArray = tempListSub;
                [tempList addObject:subname];
                
            }
            group.strArray = tempList;
            [tempData addObject:group];
            
        }
        dataArray = tempData;
        [self refreshData];
        [table reloadData];
    
       [self ExpandAndShrinkSubName:NO withSubSubName:NO];
    
}

-(void)CreateCSVDebugPanel:(id)sender
{
    NSString *path = @"/Users/RyanGao/Desktop/loadFile/script/watch/APsequ_2.14.7_TTunity_v14__DVT_0619_1400_MAIN.csv";
       
       NSFileManager *fh_csv = [NSFileManager defaultManager];
       NSData *data = [fh_csv contentsAtPath:path];
       NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
       NSArray *line = [str componentsSeparatedByString:@"\n"];
       
       if (dic_CSVHeader)
       {
           [dic_CSVHeader removeAllObjects];
       }
       else
       {
           dic_CSVHeader = [[NSMutableDictionary alloc] init];
       }
       

        int i_csvHearder = 0;
        NSString *lastTestName = @"";
        NSString *lastSubTestName = @"";

        NSMutableString *mutableStr = nil;
        if (mutableStr)
        {
            [mutableStr setString:@""];
        }
        else
        {
            mutableStr = [[NSMutableString alloc] init];
        }
    
       for (int i = 0; i< [line count]; i++)
       {
           NSArray *groupname = [line[i] componentsSeparatedByString:@","];
           NSString * finnalStr=[line[i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
           if ([groupname count] <8 || [finnalStr hasPrefix:@"//"])
           {
               i_csvHearder++;
               continue;
           }
           
           if ([line[i] length] > 15 )
           {
               if (i == i_csvHearder)
               {
                   [dic_CSVHeader setValue:line[0] forKey:@"kCSVheader"];
               }
               else
               {
                   NSString * currentTestName = [NSString stringWithFormat:@"%@",groupname[0]];
                   NSString * currentSubTestName = [NSString stringWithFormat:@"%@,%@",groupname[0],groupname[1]];
                   if ([currentTestName isNotEqualTo:lastTestName])
                   {
                       [mutableStr appendString:@"#$#$#$#$#"];
                       [mutableStr appendString:[NSString stringWithFormat:@"%@#&#&#", groupname[0]]];
                   }
                   if([currentSubTestName isNotEqualTo:lastSubTestName])
                   {
                       [mutableStr appendString:@"#!#!#!#!#"];
                       [mutableStr appendString:[NSString stringWithFormat:@"%@#&#&#", groupname[1]]];
                   }
                  
                   [mutableStr appendString:@"#$!#$!#$!#$!#"];
                   [mutableStr appendString:[NSString stringWithFormat:@"%@&!&!&!%@#&#&#",groupname[2],line[i]]];
                   
                   lastTestName = currentTestName;
                   lastSubTestName = currentSubTestName;
                
               }
           }
       }
       
    
    
        NSMutableArray *tempData = nil;
        if (tempData) {
            [tempData removeAllObjects];
        }
        else
        {
            tempData = [[NSMutableArray alloc] init];
        }
    
        NSArray *strArrayName = [mutableStr componentsSeparatedByString:@"#$#$#$#$#"];
    
        int index_subitem = 1;
        int index_subsubitem = 1;
        for (int i=0; i<[strArrayName count]; i++)
        {
            NSArray * strArrayNameTemp = [strArrayName[i] componentsSeparatedByString:@"#&#&#"];
            if ([strArrayNameTemp count]<1)
            {
                return;
            }
            
            if ([[strArrayNameTemp[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualTo:@""])
            {
                continue;
            }
            
            //NSLog(@"==test Name==%@",strArrayNameTemp[0]);
            GroupEntry *group = [[GroupEntry alloc] init];
            group.nameGroup = strArrayNameTemp[0];
            //group.name = strArrayNameTemp[0];
            group.name = [NSString stringWithFormat:@"%d : %@",i,strArrayNameTemp[0]];
            group.csvLine = @"";
            group.entryIndex = @[@(i)];
            group.isExpand = NO;
            group.iD = [NSString stringWithFormat:@"%@:%d",MyGroupName,i];
            group.name_flag = [NSString stringWithFormat:@"group:%@: 8001",MyGroupFlag];
            group.name_flag2 = [NSString stringWithFormat:@"sub:%@: %i",MySubName,i];
            group.isChecked = YES;
            //group.textColor = [NSColor lightGrayColor];
            
            NSMutableArray *tempList = [[NSMutableArray alloc] init];
            NSArray *strArraySubName = [strArrayName[i] componentsSeparatedByString:@"#!#!#!#!#"];
            for (int j=1; j< [strArraySubName count]; j++)
            {
                NSArray * strArraySubNameTemp = [strArraySubName[j] componentsSeparatedByString:@"#&#&#"];
                if ([strArraySubNameTemp count]< 1)
                {
                    return;
                }
                if ([[strArraySubNameTemp[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualTo:@""])
                {
                    continue;
                }
                
                //NSLog(@"==sub Name==%@",strArraySubNameTemp[0]);
                SubNameEntry *subname = [[SubNameEntry alloc] init];
                subname.nameGroup = strArraySubNameTemp[0];
                subname.name = strArraySubNameTemp[0];
                //subname.name = [NSString stringWithFormat:@"%d~%d : %@",i,index_subitem,strArraySubNameTemp[0]];
                index_subitem++;
                subname.entryIndex = @[@(i), @(j)];
                subname.iD = [NSString stringWithFormat:@"%@:%d",MyGroupName2,i];
                subname.csvLine = @"";
                subname.name_flag = [NSString stringWithFormat:@"group:%@: 8001",MyGroupFlag];
                subname.name_flag2 = [NSString stringWithFormat:@"sub:%@: %i",MySubName,i];
                subname.isChecked = YES;
                
                NSMutableArray *tempListSub = [[NSMutableArray alloc] init];
                NSArray *strArraySubSubName = [strArraySubName[j] componentsSeparatedByString:@"#$!#$!#$!#$!#"];
                for (int x = 1; x< [strArraySubSubName count]; x++)
                {

                    NSArray * strArraySubSubNameTemp = [strArraySubSubName[x] componentsSeparatedByString:@"#&#&#"];
                    if ([strArraySubSubNameTemp count]< 1)
                    {
                        return;
                    }
                    if ([[strArraySubSubNameTemp[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualTo:@""])
                    {
                        continue;
                    }
                    
                    //NSLog(@"==sub sub Name==%@",strArraySubSubNameTemp[0]);
                    NSArray *subSubNameArray = [strArraySubSubNameTemp[0] componentsSeparatedByString:@"&!&!&!"];
                    SubSubNameEntry *subsubname = [[SubSubNameEntry alloc] init];
                    subsubname.nameGroup = strArraySubNameTemp[0];
                    if ([subSubNameArray[0] length]<20)
                    {
                        subsubname.name = [NSString stringWithFormat:@"%d : %@                    ",index_subsubitem,subSubNameArray[0]];
                    }
                    else
                    {
                        subsubname.name = [NSString stringWithFormat:@"%d : %@",index_subsubitem,subSubNameArray[0]];
                    }
                    index_subsubitem++;
                    subsubname.entryIndex = @[@(i), @(x)];
                    subsubname.iD = [NSString stringWithFormat:@"%@:%d",MyGroupName3,i];
                    subsubname.csvLine = subSubNameArray[1];
                    subsubname.name_flag = [NSString stringWithFormat:@"group:%@: 8001",MyGroupFlag];
                    subsubname.name_flag2 = [NSString stringWithFormat:@"sub:%@: %i",MySubName,i];
                    subsubname.isChecked = YES;
                    [tempListSub addObject:subsubname];
                    
                    
                }
                
                subname.strArray = tempListSub;
                [tempList addObject:subname];
                
            }
            group.strArray = tempList;
            [tempData addObject:group];
            
        }
        dataArray = tempData;
        [self refreshData];
        [table reloadData];
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


- (IBAction)btOK:(id)sender
{
      [self refreshData];
      [table reloadData];
       NSString *high = [self.txtCPKHigh stringValue];
       if ([self isPureInt:high] || [self isPureFloat:high])
       {
           //NSLog(@"===>>>data: %@",array_CSV);
           //=====********************** 根据所选择的item，生成新的数据
           NSMutableArray *csvTit = [NSMutableArray array];
           for (int i = 0; i<n_Start_Data_Col; i++)
           {
               [csvTit addObject:_dataReverse[i]];
           }
           
           NSMutableArray * csvData = [NSMutableArray array];  //按照脚本规则写csv 数据
           for (int i=0; i<[array_CSV count]; i++)
           {
               for (int j=0; j<[_dataReverse count]; j++)
               {
                   if ([array_CSV[i] isEqualTo:_dataReverse[j][1]])
                   {
                       [csvData addObject:_dataReverse[j]];
                       break;
                   }
               }
               
           }
           
           for (int i=0; i<[csvData count]; i++)
           {
               [csvTit addObject:csvData[i]];
           }
           
           NSMutableArray *csvInsight = [NSMutableArray arrayWithArray:[self reverseArray:csvTit]];
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
           
           NSString *desktopPath = [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES)objectAtIndex:0];
           NSError *error = nil;
           //NSString *dataFileName=@"";//[[dataPath lastPathComponent] stringByDeletingPathExtension];
           NSString *csv_Path = [NSString stringWithFormat:@"%@/CPK_Log/Temp/keynote_data_temp.csv",desktopPath];
           [csvStr writeToFile:csv_Path atomically:YES encoding:NSUTF8StringEncoding error:&error];
           if (error)
           {
              // [self AlertBox:@"Failed" withInfo:[NSString stringWithFormat:@"Write file to path failed!!!\r\n%@",csv_Path]];
           }
           else
           {
              // [self AlertBox:@"Success" withInfo:[NSString stringWithFormat:@"Write file to path Successful!!!\r\n%@",csv_Path]];
           }
            
            //==========*******************************
           
           
           [m_configDictionary setValue:high forKey:kcpkKeynoteHighThd];
           [NSApp stopModalWithCode:NSModalResponseOK];
           [[sender window] orderOut:self];
       }
       else
       {
           [self AlertBox:@"Error!!!" withInfo:@"Input CPK threshold should be a number!"];
       }
    
}
- (IBAction)btCancel:(id)sender
{
    [NSApp stopModalWithCode:NSModalResponseCancel];
    [[sender window] orderOut:self];
    
}

- (IBAction)btClearAll:(id)sender
{
    [self clearAndSelect:NO];
}
- (IBAction)btSelectAll:(id)sender
{
    [self clearAndSelect:YES];
}

-(void)clearAndSelect:(bool)checked
{
    NSMutableArray *tempExpandArray = nil;
    if (tempExpandArray) {
        [tempExpandArray removeAllObjects];
    }
    else
    {
        tempExpandArray =  [[NSMutableArray alloc] init];
    }
    NSMutableArray *tempExpandTable = nil;
    if (tempExpandTable) {
        [tempExpandTable removeAllObjects];
    }
    else
    {
        tempExpandTable = [[NSMutableArray alloc] init];
    }
    [array_CSV removeAllObjects];
    for (id tempGroup in dataArray) {
        if ([tempGroup isKindOfClass:[GroupEntry class]]) {
            GroupEntry *group = (GroupEntry *)tempGroup;
            group.isChecked = checked;
            [tempExpandArray addObject:group];
            [tempExpandTable addObject:group];
            
            for (id tempsubname in group.strArray) {
                SubNameEntry *subname = (SubNameEntry *)tempsubname;
                subname.isChecked = checked;
                [tempExpandArray addObject:subname];
                if (group.isExpand)
                {
                    [tempExpandTable addObject:subname];
                    for (id tempsubsubname in subname.strArray)
                    {
                        SubSubNameEntry *subsubname = (SubSubNameEntry *)tempsubsubname;
                        subsubname.isChecked = checked;
                        [tempExpandArray addObject:subsubname];
                        if (subname.isExpand)
                        {
                            [tempExpandTable addObject:subsubname];
                        }
                        
                        if ([subsubname isChecked])
                        {
                            NSString * str = subsubname.csvLine;
                            [array_CSV addObject:str];
                        }
                        
                    }
                }
                else
                {
                    for (id tempsubsubname in subname.strArray)
                    {
                         SubSubNameEntry *subsubname = (SubSubNameEntry *)tempsubsubname;
                         subsubname.isChecked = checked;
                         [tempExpandArray addObject:subsubname];
                        if ([subsubname isChecked])
                        {
                            NSString * str = subsubname.csvLine;
                            [array_CSV addObject:str];
                        }

                    }
                }
            }
        }
    }
    expandedArray = tempExpandArray;
    expandTable = tempExpandTable;
    dataArray = tempExpandArray;
    [table reloadData];
}




@end

@implementation BlockImageIcon
@synthesize delegate;

-(BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)flag {
    [delegate iconCilcked:nil];
    return NO;
}
@end
