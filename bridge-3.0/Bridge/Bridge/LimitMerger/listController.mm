//
//  csvListController.m
//  BDR_Tool
//
//  Created by RyanGao on 2020/7/5.
//  Copyright © 2020 RyanGao. All rights reserved.
//

#import "listController.h"
//#import "defineHeader.h"
#import "../DataPlot/defineHeader.h"

# define insightMergePlist        @"limitMerge.plist"
#import "vtTable.h"

extern NSMutableDictionary *m_configDictionary;


@interface listController ()
{
    __weak IBOutlet vtTable *tableDrag;
    NSString *userPath;
    int local_checkBoxFlag;
    int insight_checkBoxFlag;
    
    bool isLimitChecked;
    
}



@end

@implementation listController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self fillTestData];
    
    
    [self.outlineView expandItem:nil expandChildren:YES];
    
    
    [_browes setEnabled:YES];
    [_browesButton setEnabled:YES];
    
    [_browes setFont:[NSFont boldSystemFontOfSize:30]];
    [_browesButton setFont:[NSFont boldSystemFontOfSize:30]];
    
    
    [_outlineView setFont:[NSFont boldSystemFontOfSize:30]];
    
    
    [tableDrag isProfile:true];
    [tableDrag registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnNotification:) name:@"addPath" object:nil];
    
    
}



- (void)OnNotification:(NSNotification *)nf
{
    NSString * name = [nf name];
    
    if([name isEqualToString:@"addPath"])
    {
        NSString *filePath = [NSString stringWithFormat:@"%@/%@",userPath,insightMergePlist];
        NSDictionary* info = [nf userInfo];
        NSString * type  = info[@"type"];
        NSString * filename = info[@"file"];
        
        if ([type isEqualToString:@"profile"]) {
            
            [self addToPathWrite:filePath withAddPath:filename with:0];
            self.feeds = [Feed pathList:filePath];
            [self.outlineView reloadData];
            [self.outlineView expandItem:nil expandChildren:YES];
        }else if ([type isEqualToString:@"limit"]){
            
            [self addToPathWrite:filePath withAddPath:filename with:2];
            self.feeds = [Feed pathList:filePath];
            [self.outlineView reloadData];
            [self.outlineView expandItem:nil expandChildren:YES];
            
        }
    }
}
- (IBAction)itemChecked:(id)sender
{
    
    NSButton *checkedCellButton = (NSButton*)sender;

    NSInteger checkedCellIndex = [_outlineView rowForView:sender];

    int state = (int)checkedCellButton.state;

    NSArray *arr1 = self.feeds[0].children;
    
    NSUInteger count = [arr1 count] ;
    
    NSArray *arr2 = self.feeds[1].children;
    
    NSUInteger count2 = [arr2 count] ;
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",userPath,insightMergePlist];
    
    if (checkedCellIndex<=count)
    {
        int line = (int)checkedCellIndex-1;
        [Feed addToItemClick:filePath withLine:line ItemClick:state with:0];
    }
    else if(checkedCellIndex<=count+count2+1)
    {
        int line = (int)(checkedCellIndex-count-2);
        [Feed addToItemClick:filePath withLine:line ItemClick:state with:1];
    }


    self.feeds = [Feed pathList:filePath];
    [self.outlineView reloadData];
    [self.outlineView expandItem:nil expandChildren:YES];
    
    insight_checkBoxFlag = [self readInsightItemCheckBox:filePath];
    [m_configDictionary setValue:[NSNumber numberWithInt:insight_checkBoxFlag] forKey:kSetInsightCsvMode];

}
- (void)addToPathWrite:(NSString *)fileName withAddPath:(NSString *)addPath with:(int)flag
{
    NSArray *pathList = [NSArray arrayWithContentsOfFile:fileName];
    if (flag==0)
    {
        NSDictionary * dic = pathList[0];
        NSArray *arr1 = [dic valueForKey:@"items"];
        
        NSDictionary *dicAdd =[NSDictionary dictionaryWithObjectsAndKeys:addPath,@"file_path",@1,@"check",nil];
        //NSArray *arr2 = [[NSArray alloc] initWithObjects:dicAdd,nil];
        if ([arr1 count]<1)
        {
            arr1 = [NSArray arrayWithObjects:dicAdd,nil];
        }
        else
        {
            NSMutableArray *arrM = [NSMutableArray array];
            
            for (int i=0; i<[arr1 count]; i++)  //所有的check 都不用选
            {
                NSString *faildata = [arr1[i] valueForKey:@"file_path"];
                NSDictionary *dicOrig =[NSDictionary dictionaryWithObjectsAndKeys:faildata,@"file_path",@0,@"check",nil];
                [arrM addObject:dicOrig];
            }
            
            [arrM addObject:dicAdd];
            arr1 = arrM;
        }
        
        NSDictionary *dict1 = [NSDictionary dictionaryWithObjectsAndKeys:@"Load Test Script",@"name",arr1,@"items", nil];
        NSDictionary * dic1 = pathList[1];
        NSArray *arr = [NSArray arrayWithObjects:dict1,dic1, nil];
        [arr writeToFile:fileName atomically:YES];
        
        
    }
    else if (flag==2)
    {
        NSDictionary * dic = pathList[1];
        NSArray *arr1 = [dic valueForKey:@"items"];
        NSDictionary *dicAdd =[NSDictionary dictionaryWithObjectsAndKeys:addPath,@"file_path",@1,@"check",nil];

        
        if ([arr1 count]<1)
        {
            arr1 = [NSArray arrayWithObjects:dicAdd,nil];
        }
        else
        {
            
            NSMutableArray *arrM = [NSMutableArray array];
             
             for (int i=0; i<[arr1 count]; i++)  //所有的check 都不用选
             {
                 NSString *faildata = [arr1[i] valueForKey:@"file_path"];
                 NSDictionary *dicOrig =[NSDictionary dictionaryWithObjectsAndKeys:faildata,@"file_path",@0,@"check",nil];
                 [arrM addObject:dicOrig];
             }
    
            [arrM addObject:dicAdd];
            arr1 = arrM;
        }
        
        NSDictionary *dict1 = [NSDictionary dictionaryWithObjectsAndKeys:@"Load Limit Excel",@"name",arr1,@"items", nil];
        
        NSDictionary * dic0 = pathList[0];
        NSArray *arr = [NSArray arrayWithObjects:dic0,dict1, nil];
        //NSLog(@"===write plist: %@",arr);
        [arr writeToFile:fileName atomically:YES];
    }
 
}

-(IBAction)btnChoose:(id)sender
{
    NSLog(@"=====button chose==");
    NSInteger checkedCellIndex = [_outlineView rowForView:sender];
    NSArray *arr1 = self.feeds[0].children;
    NSUInteger n_script =  checkedCellIndex- [arr1 count] ;
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",userPath,insightMergePlist];
    
    
    if (checkedCellIndex==0)
    {
         NSString *strpath = [self openCSVLoadPanel];
        if (filePath && strpath)
        {
            [self addToPathWrite:filePath withAddPath:strpath with:0];
            self.feeds = [Feed pathList:filePath];
            [self.outlineView reloadData];
            [self.outlineView expandItem:nil expandChildren:YES];

        }
        else
        {
            return;
        }
    }
    else if (n_script==1)
    {
        NSString *strpath = [self openXlsxLoadPanel];
       if (filePath && strpath)
       {
           [self addToPathWrite:filePath withAddPath:strpath with:2];
           self.feeds = [Feed pathList:filePath];
           [self.outlineView reloadData];
           [self.outlineView expandItem:nil expandChildren:YES];
       }
       else
       {
           return;
       }
    }

    insight_checkBoxFlag = [self readInsightItemCheckBox:filePath];
    [m_configDictionary setValue:[NSNumber numberWithInt:insight_checkBoxFlag] forKey:kSetInsightCsvMode];

}

- (IBAction)btLoadScript:(id)sender
{
    // insight 数据加载
    [self.outlineView reloadData];
    NSString *dataCsv = nil;
    NSArray *arr1 = self.feeds[0].children;
    for (int i=0; i<[arr1 count]; i++)
    {
        NSArray * arrsub = [[NSString stringWithFormat:@"%@",arr1[i]] componentsSeparatedByString:@","];
        int check = self.feeds[0].children[i].flag;
        if (check == 1)
        {
            dataCsv = arrsub[1];
            break;
        }
    }
    if (dataCsv == nil)
    {
        [self AlertBox:@"Warning." withInfo:@"Please choose load file path."];
        return;
    }
    else{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"LoadMsg" object:nil userInfo:@{@"type":@"profile",@"file":dataCsv}];
    }

    
    NSString *limitXlsx = @"";
    NSArray *arr3 = self.feeds[1].children;
    for (int i=0; i<[arr3 count]; i++)
    {
        NSArray * arrsub = [[NSString stringWithFormat:@"%@",arr3[i]] componentsSeparatedByString:@","];
        int check = self.feeds[1].children[i].flag;
        if (check == 1)
        {
            limitXlsx =arrsub[1];
            break;
        
        }
    }
    if (limitXlsx == nil) {
        [self AlertBox:@"Warning." withInfo:@"Please choose limit excel file path."];
        return;
    }else{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"LoadMsg" object:nil userInfo:@{@"type":@"limit",@"file":limitXlsx}];
        
    }
    



}

- (IBAction)btClear:(id)sender
{
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",userPath,insightMergePlist];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager removeItemAtPath:filePath error:NULL])
      {
          NSLog(@"Removed loadScript.plist successfully");
      }
    
    [self fillTestData];
    insight_checkBoxFlag = 0;
    

}



-(void)itemUncheckAll{
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",userPath,insightMergePlist];
    
    int groupCount = [[Feed pathList:filePath] count];
    
    for (int i=0; i < groupCount; i++) {
        NSUInteger count = [[Feed pathList:filePath][i].children count];
    
        for (int j=0; j < count; j++) {
            [Feed addToItemClick:filePath withLine:j ItemClick:0 with:i];
        }
        
    }
 

    [self.outlineView reloadData];
    [self.outlineView expandItem:nil expandChildren:YES];
    
    insight_checkBoxFlag = 0;
    
}



#pragma mark path load methods

- (int)readInsightItemCheckBox:(NSString *)fileName
{
      int n_ckeckBox = 0;
      NSArray *pathList = [NSArray arrayWithContentsOfFile:fileName];
      NSDictionary * dic = pathList[0];
      NSArray *arr1 = [dic valueForKey:@"items"];
    
      for (int i=0; i<[arr1 count]; i++)  //所有的check 都不用选
      {
          int flag = [[arr1[i] valueForKey:@"check"] intValue];
          n_ckeckBox += flag;
      }

      NSDictionary * dic_2 = pathList[1];
      NSArray *arr1_2 = [dic_2 valueForKey:@"items"];
      for (int i=0; i<[arr1_2 count]; i++)  //所有的check 都不用选
      {
           int flag = [[arr1_2[i] valueForKey:@"check"] intValue];
           n_ckeckBox += flag;
      }
    
      return n_ckeckBox;
}

- (void)fillTestData  //insight data
{

    userPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]; // @"/usr/local/lib";//
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",userPath,insightMergePlist];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:filePath])
    {
        NSDictionary *dic0 =nil;
        NSArray *array = [[NSArray alloc] initWithObjects:dic0,nil];
        NSDictionary *dict1 = [NSDictionary dictionaryWithObjectsAndKeys:@"Load Test Script",@"name",array,@"items", nil];
        NSDictionary *dict3 = [NSDictionary dictionaryWithObjectsAndKeys:@"Load Limit Excel",@"name",array,@"items", nil];
        NSArray *arr = [[NSArray alloc] initWithObjects:dict1,dict3,nil];
        BOOL flag1 = [arr writeToFile:filePath atomically:YES];
              if (flag1) {
                  NSLog(@"plist文件写入成功");
              }else{
                  NSLog(@"plist 文件写入失败");
                  [self AlertBox:@"plist file error" withInfo: [NSString stringWithFormat:@"generate plist file fail ! \n<<%@>>",filePath]];
              }
    }
    if (filePath)
    {
        self.feeds = [Feed pathList:filePath];
 
        insight_checkBoxFlag = [self readInsightItemCheckBox:filePath];
        [m_configDictionary setValue:[NSNumber numberWithInt:insight_checkBoxFlag] forKey:kSetInsightCsvMode];

        [self.outlineView reloadData];
    }else{
        [self AlertBox:@"plist file error" withInfo: [NSString stringWithFormat:@"plist file not exist ! \n<<%@>>",filePath]];
    }
    
}


-(NSMutableDictionary*) isTestPlanAndLimitFile{
    
    NSMutableDictionary * ret =[[NSMutableDictionary alloc] init];
    NSString *filePath = [NSString stringWithFormat:@"%@/.loadDataScript.plist",userPath];
    
    NSArray *rootDict = [NSArray arrayWithContentsOfFile:filePath];
    
    if ([rootDict count] >=3) {
        NSArray* testplanItems =  rootDict[1][@"items"];
        
        bool istestplanchecked = false;
        NSMutableArray* testplans = [[NSMutableArray alloc] init];
        for (int i=0; i<[testplanItems count]; i++) {
            if ([testplanItems[i][@"check"] intValue] == 1) {
                [testplans addObject:testplanItems[i][@"file_path"] ];
                istestplanchecked = true;
                break;
            }
        }
        NSArray* LimitsItems =  rootDict[2][@"items"];
        bool islimitchecked = false;
        NSMutableArray* limitfiles = [[NSMutableArray alloc] init];
        for (int i=0; i<[LimitsItems count]; i++) {
            if ([LimitsItems[i][@"check"] intValue] == 1) {
                [limitfiles addObject:LimitsItems[i][@"file_path"] ];
                islimitchecked = true;
                break;
            }
        }
        [ret setValue:testplans forKey:@"testplans"];
        [ret setValue:limitfiles forKey:@"limitfiles"];
        
        [ret setValue:(islimitchecked&istestplanchecked) ? @(YES):@(NO) forKey:@"result"];
        return ret;
        
    }else{
        [ret setValue:@(NO) forKey:@"result"];
        return ret;
    }
    
    //NSDictionary *rootDict = [NSDictionary dictionaryWithContentsOfFile:filePath];
    //NSMutableDictionary* dict =  [ [ NSMutableDictionary alloc ] initWithContentsOfFile:filePath  ];
    
}






-(BOOL)isOnlyhasNumberAndpointWithString:(NSString *)string
{
    NSCharacterSet *cs=[[NSCharacterSet characterSetWithCharactersInString:NUMBERS] invertedSet];
    NSString *filter=[[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    return [string isEqualToString:filter];

}

#pragma mark - Actions

- (IBAction)doubleClickedItem:(NSOutlineView *)sender
{
   
    if ([sender.identifier isEqualToString:@"insightdata"])
    {
        Feed *item = [sender itemAtRow:[sender clickedRow]];
        if ([item isKindOfClass:[Feed class]]) {
            if ([sender isItemExpanded:item]) {
                [sender collapseItem:item];
            } else {
                [sender expandItem:item];
            }
        }
    }
}

#pragma mark - NSOutlineViewDataSource

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    [outlineView setFont:[NSFont boldSystemFontOfSize:30]];
    
    
    if ([outlineView.identifier isEqualToString:@"insightdata"])
    {
        if ([item isKindOfClass:[Feed class]]) {
            //NSLog(@"feed.children.count");
            Feed *feed = (Feed *)item;
            return feed.children.count;
        } else {
            //NSLog(@"self.feeds.count");
            return self.feeds.count;
        }
    }
    return 0;

}


- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    [outlineView setFont:[NSFont boldSystemFontOfSize:30]];
    
    if ([outlineView.identifier isEqualToString:@"insightdata"])
    {
        Feed *feed = (Feed *)item;
        if (feed) {
            return feed.children[index];
        } else {
            return self.feeds[index];
        }
    }
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    [outlineView setFont:[NSFont boldSystemFontOfSize:30]];
   
    if ([outlineView.identifier isEqualToString:@"insightdata"])
    {
         if ([item isKindOfClass:[Feed class]]) {
             Feed *feed = (Feed *)item;
             return feed.children.count > 0;
         } else {
             return NO;
         }
    }
    return NO;
}


#pragma mark - NSOutlineViewDelegate


- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    NSTableCellView *view;
    
    [outlineView setFont:[NSFont boldSystemFontOfSize:30]];
    
    
    if ([outlineView.identifier isEqualToString:@"insightdata"])
    {
   
    
        if ([item isKindOfClass:[Feed class]])
        {
            Feed *feed = (Feed *)item;

             if ([tableColumn.identifier isEqualToString:@"filepath"])
            {
                view = (NSTableCellView *)[outlineView makeViewWithIdentifier:@"FilePathCell" owner:self];
                NSArray *subviews = [view subviews];
                NSTextField *textField = subviews[0];
                if (textField) {
                    textField.stringValue = feed.name;
                    [textField sizeToFit];
                }
                NSButton *cellButton = subviews[1];
                if (insight_checkBoxFlag ==0)
                {
                    [cellButton setEnabled:YES];
                    //[cellButton setEnabled:YES];
                }
                else
                {
                    [cellButton setEnabled:YES];
                }
                
                if (insight_checkBoxFlag ==0 && local_checkBoxFlag == 0)
                {
                   [cellButton setEnabled:YES];
                }
                [cellButton setFrame:NSMakeRect(100, -7, 80, 32)];
                if ([feed.name isEqualToString:@"Load Previous Limit Review Excel"])
                {
                    [cellButton setFrame:NSMakeRect(250, -7, 80, 32)];
                }

                [cellButton setAction:@selector(btnChoose:)];
                
                
            }
            else if ([tableColumn.identifier isEqualToString:@"choosepath"])
                    {
                        view = [outlineView makeViewWithIdentifier:@"choosepath" owner:self];
                        NSButton *cellButton = (NSButton*)view;
                        if (insight_checkBoxFlag ==0)
                        {
                            [cellButton setEnabled:NO];
                        }
                        else
                        {
                            [cellButton setEnabled:YES];
                        }
                        
                        if (insight_checkBoxFlag ==0 && local_checkBoxFlag == 0)
                        {
                           [cellButton setEnabled:YES];
                        }
                        [cellButton setAction:@selector(btnChoose:)];
                             
                    }
           
        }
        else if ([item isKindOfClass:[FeedItem class]])
        {
            FeedItem *feedItem = (FeedItem *)item;
         if ([tableColumn.identifier isEqualToString:@"filepath"])
            {
                view = (NSTableCellView *)[outlineView makeViewWithIdentifier:@"FilePathItemCell" owner:self];
                NSTextField *textField = view.textField;
                if (textField) {
                    textField.stringValue = feedItem.pathFile;
                    [textField sizeToFit];
                }
            }
             else if ([tableColumn.identifier isEqualToString:@"checkbox"])
            {
                view = [outlineView makeViewWithIdentifier:@"checkbox" owner:self];
                NSButton *cellButton = (NSButton*)view;
                [cellButton setIntValue:feedItem.flag];
                
                
                if (insight_checkBoxFlag ==0)
                {
                    [cellButton setEnabled:YES];
                    [_browes setEnabled:YES];
                    [_browesButton setEnabled:YES];
                }
                else
                {
                    [cellButton setEnabled:YES];
                }
                if (insight_checkBoxFlag ==0 && local_checkBoxFlag == 0)
                {
                   [cellButton setEnabled:YES];
                }
                
                [cellButton setAction:@selector(itemChecked:)];
                     
            }

        }
    return view;
    }
    return nil;
}


- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
}

#pragma mark - Keyboard Handling

- (void)keyDown:(NSEvent *)event
{
    [self interpretKeyEvents:[NSArray arrayWithObject:event]];
}

- (void)deleteBackward:(id)sender
{
    NSLog(@"delete key detected");
    
    NSUInteger selectedRow = self.outlineView.selectedRow;
    if (selectedRow == -1 )
    {
        return;
    }
    
    
    if (selectedRow >0)
    {
        [self.outlineView beginUpdates];
        
        id item = [self.outlineView itemAtRow:selectedRow];
        if ([item isKindOfClass:[Feed class]]) {
        } else if ([item isKindOfClass:[FeedItem class]])
        {
            FeedItem *feedItem = (FeedItem *)item;
            for (Feed *feed in self.feeds) {
                NSUInteger index = [feed.children indexOfObjectPassingTest:^BOOL(FeedItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
                {
                    return [feedItem.pathFile isEqualToString:obj.pathFile];
                    
                }];
                if (index != NSNotFound)
                {
                    [feed.children removeObjectAtIndex:index];
                    NSLog(@"=======remove: %zd,  %@  ,  %@",index,feed.name,feed.children);
                    [self.outlineView removeItemsAtIndexes:[NSIndexSet indexSetWithIndex:index] inParent:feed withAnimation:NSTableViewAnimationSlideLeft];
                }
            }
            
            NSString *name1 = self.feeds[0].name;
            NSArray *arr1 = self.feeds[0].children;
            NSMutableArray *arrM1 = [NSMutableArray array];
            for (int i=0; i<[arr1 count]; i++)
            {
                NSArray * arrsub = [[NSString stringWithFormat:@"%@",arr1[i]] componentsSeparatedByString:@","];
                int check = [arrsub[0] intValue];
                NSString *filePath = arrsub[1];
                NSDictionary *dicitem =[NSDictionary dictionaryWithObjectsAndKeys:filePath,@"file_path",[NSNumber numberWithInt:check],@"check",nil];
                [arrM1 addObject:dicitem];
            }
            NSDictionary *dict1 = [NSDictionary dictionaryWithObjectsAndKeys:name1,@"name",arrM1,@"items", nil];
            
            
            NSString *name2 = self.feeds[1].name;
            NSArray *arr2 = self.feeds[1].children;
            NSMutableArray *arrM2 = [NSMutableArray array];
            for (int i=0; i<[arr2 count]; i++)
            {
                NSArray * arrsub = [[NSString stringWithFormat:@"%@",arr2[i]] componentsSeparatedByString:@","];
                int check = [arrsub[0] intValue];
                NSString *filePath = arrsub[1];
                NSDictionary *dicitem =[NSDictionary dictionaryWithObjectsAndKeys:filePath,@"file_path",[NSNumber numberWithInt:check],@"check",nil];
                [arrM2 addObject:dicitem];
            }
            NSDictionary *dict2 = [NSDictionary dictionaryWithObjectsAndKeys:name2,@"name",arrM2,@"items", nil];
            
            
          
            
            NSArray *arr = [NSArray arrayWithObjects:dict1,dict2, nil];
            NSString *filePath = [NSString stringWithFormat:@"%@/%@",userPath,insightMergePlist];
            BOOL flag1 = [arr writeToFile:filePath atomically:YES];
                       if (flag1) {
                           NSLog(@"plist文件写入成功");
                       }else{
                           NSLog(@"plist 文件写入失败");
                           [self AlertBox:@"plist file error" withInfo: [NSString stringWithFormat:@"delete plist line fail ! \n<<%@>>",filePath]];
                       }
            
            
        }
        
        [self.outlineView endUpdates];
    }
}


- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item{
    [outlineView setFont:[NSFont boldSystemFontOfSize:30]];
    return 20;

}


-(NSString *)openCSVLoadPanel
{
    NSString *csvpath =nil;
    NSOpenPanel * panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO]; //设置多选模式
    [panel setCanChooseFiles:YES];
    [panel setCanCreateDirectories:YES];
    [panel setCanChooseDirectories:YES];
    //[panel setAllowedFileTypes:[NSArray arrayWithObjects:@"CSV", @"csv", @"Csv",nil]];
    //[panel setDirectoryURL:[NSURL URLWithString:desktopPath]];
    [panel runModal];
    if ([[panel URLs] count]>0)
    {
        csvpath = [[[panel URLs] objectAtIndex:0] path];
//        if ([[csvpath pathExtension] isEqualToString:@"CSV"]||[[csvpath pathExtension] isEqualToString:@"csv"]||[[csvpath pathExtension] isEqualToString:@"Csv"])
//        {
//            return csvpath;
//        }
//        else
//        {
//            [self AlertBox:@"Error:011" withInfo:@"You choose wrong csv file path!"];
//            return nil;
//        }
    }
    return csvpath;
}

-(NSString *)openXlsxLoadPanel
{
    NSString *csvpath =nil;
    NSOpenPanel * panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO]; //设置多选模式
    [panel setCanChooseFiles:YES];
    [panel setCanCreateDirectories:YES];
    [panel setCanChooseDirectories:YES];
    [panel setAllowedFileTypes:[NSArray arrayWithObjects:@"xlsx",nil]];
    //[panel setDirectoryURL:[NSURL URLWithString:desktopPath]];
    [panel runModal];
    if ([[panel URLs] count]>0)
    {
        csvpath = [[[panel URLs] objectAtIndex:0] path];
        if ([[csvpath pathExtension] isEqualToString:@"xlsx"])
        {
            return csvpath;
        }
        else
        {
            [self AlertBox:@"Error:012" withInfo:@"You choose wrong xlsx file path!"];
            return nil;
        }
    }
    return csvpath;
}

-(void)AlertBox:(NSString *)msgTxt withInfo:(NSString *)strmsg
{
    NSAlert * alert = [[NSAlert alloc] init];
    alert.messageText = msgTxt;
    alert.informativeText = strmsg;
    [alert runModal];
}
@end




























