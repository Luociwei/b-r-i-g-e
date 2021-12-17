//
//  csvListController.m
//  BDR_Tool
//
//  Created by RyanGao on 2020/7/5.
//  Copyright © 2020 RyanGao. All rights reserved.
//

#import "csvListController.h"
//#import "defineHeader.h"
#import "../DataPlot/defineHeader.h"


# define customDataPlist         @".customDataScript.plist"
# define insightDataPlist        @".loadDataScript.plist"


#import "defineHeader.h"
#import "SCRedis.framework/Headers/RedisInterface.hpp"
#import "SCZmq.framework/Headers/Client.h"


#import <Foundation/Foundation.h>
#import <stdio.h>
#import <stdlib.h>

#import "StartUp.framework/Headers/StartUp.h"

#import "CycleDelegate.h"

extern Client *reportAtlas2Client;
extern NSMutableDictionary *m_configDictionary;


@interface csvListController ()
{
    NSString *userPath;
    int local_checkBoxFlag;
    int insight_checkBoxFlag;
    
    bool isLimitChecked;
    
}



@end

@implementation csvListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    //[self getDataFlag];
    [self fillLocalTestData];
    [self fillTestData];
    
    [_cpk_lthl setStringValue:@"1.5"];
    [_cpk_hthl setStringValue:@"10.0"];
    
    [self.outlineView expandItem:nil expandChildren:YES];
    [self.outlineViewLocal expandItem:nil expandChildren:YES];
    
    
    [_browes setEnabled:YES];
    [_browesButton setEnabled:YES];
    
    [_browes setFont:[NSFont boldSystemFontOfSize:30]];
    [_browesButton setFont:[NSFont boldSystemFontOfSize:30]];
    
    
    [_outlineViewLocal setFont:[NSFont boldSystemFontOfSize:30]];
    [_outlineView setFont:[NSFont boldSystemFontOfSize:30]];
    
    NSDistributedNotificationCenter *center =
        [NSDistributedNotificationCenter defaultCenter];
        NSString *observedObject = @"com.vito.notification";
        [center addObserver: self
                   selector: @selector(callbackWithNotification:)
                       name: nil/*@"PiaoYun Notification"*/
                     object: observedObject];

    m_dic = [[NSMutableDictionary alloc] init];
    
    
    
}

//- (void)setDataSource
//{
//    [_outlineView setDataSource:(id)self];
//}
//
//- (void)setDelegate
//{
//    [_outlineView setDelegate:self];
//}

#pragma mark path load methods

- (void)fillTestData  //insight data
{
    //NSString *filePath = [[NSBundle mainBundle] pathForResource:@"csvListFile" ofType:@"plist"];
    //NSString *filePath = @"/Users/RyanGao/Desktop/CPK_Log/temp/22222.plist";
    
    //userPath = [NSSearchPathForDirectoriesInDomains(NSUserDirectory, NSUserDomainMask, YES)objectAtIndex:0];
      userPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",userPath,insightDataPlist];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:filePath])
    {
        NSDictionary *dic0 =nil;
        NSArray *array = [[NSArray alloc] initWithObjects:dic0,nil];
        NSDictionary *dict1 = [NSDictionary dictionaryWithObjectsAndKeys:@"Test Data",@"name",array,@"items", nil];
        NSDictionary *dict2 = [NSDictionary dictionaryWithObjectsAndKeys:@"Test Script",@"name",array,@"items", nil];
        NSDictionary *dict3 = [NSDictionary dictionaryWithObjectsAndKeys:@"Load Previous Limit Review Excel",@"name",array,@"items", nil];
 
        NSArray *arr = [[NSArray alloc] initWithObjects:dict1,dict2,dict3,nil];
        BOOL flag1 = [arr writeToFile:filePath atomically:YES];
              if (flag1) {
                  NSLog(@"plist文件写入成功");
              }else{
                  NSLog(@"plist 文件写入失败");
              }
    }
    if (filePath)
    {
        self.feeds = [Feed pathList:filePath];
        //NSLog(@"path: %@", self.feeds);
        
        insight_checkBoxFlag = [Feed readInsightItemCheckBox:filePath];
        [m_configDictionary setValue:[NSNumber numberWithInt:insight_checkBoxFlag] forKey:kSetInsightCsvMode];
        
        NSString *filePathlocal = [NSString stringWithFormat:@"%@/%@",userPath,customDataPlist];
        local_checkBoxFlag = [Feed readLocalItemCheckBox:filePathlocal];
        [m_configDictionary setValue:[NSNumber numberWithInt:local_checkBoxFlag] forKey:kSetLocalCsvMode];
        
        [self.outlineView reloadData];
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


- (IBAction)onLimitMerger:(id)sender {
    
    NSMutableDictionary * info =[self isTestPlanAndLimitFile];
    
    if(info[@"result"] == @(YES)){
        [info removeObjectForKey:@"result"];
        [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationLimitMergerShowUp object:nil userInfo:info];
    }
    else{
        
        [self AlertBox:@"Limit Merger Error" withInfo:@"Please Check a TestScript & a Limit File !!!"];
    }
    
}


- (void)getDataFlag
{
    userPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/.dataFlag.plist",userPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:filePath])
    {
       // NSDictionary *dic0 =nil;
        //NSArray *array = [[NSArray alloc] initWithObjects:dic0,nil];
        NSMutableDictionary *dic0 = [NSMutableDictionary dictionary];
        [dic0 setValue:[NSNumber numberWithInt:0] forKey:@"Local Data Flag"];
        [dic0 setValue:[NSNumber numberWithInt:0] forKey:@"Insight Data Flag"];
        BOOL flag1 = [dic0 writeToFile:filePath atomically:YES];
        if (flag1)
        {
            NSLog(@"loadDataFlag文件写入成功");
        }else
        {
            NSLog(@"loadDataFlag 文件写入失败");
        }
    }
    if (filePath)
    {
        local_checkBoxFlag = [Feed readLocalDataFlag:filePath];
        insight_checkBoxFlag = [Feed readInsightlDataFlag:filePath];
        [m_configDictionary setValue:[NSNumber numberWithInt:local_checkBoxFlag] forKey:kSetLocalCsvMode];
        [m_configDictionary setValue:[NSNumber numberWithInt:insight_checkBoxFlag] forKey:kSetInsightCsvMode];
        NSLog(@"====>local check box data flag : %d",local_checkBoxFlag);
        
    }
}

- (void)fillLocalTestData
{
    //NSString *filePath = [[NSBundle mainBundle] pathForResource:@"csvListFile" ofType:@"plist"];
    //NSString *filePath = @"/Users/RyanGao/Desktop/CPK_Log/temp/22222.plist";
    
    //userPath = [NSSearchPathForDirectoriesInDomains(NSUserDirectory, NSUserDomainMask, YES)objectAtIndex:0];
      userPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",userPath,customDataPlist];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:filePath])
    {
        NSDictionary *dic0 =nil;
        NSArray *array = [[NSArray alloc] initWithObjects:dic0,nil];
        NSDictionary *dict1 = [NSDictionary dictionaryWithObjectsAndKeys:@"Custom CSV File",@"name",array,@"items", nil];
        NSArray *arr = [[NSArray alloc] initWithObjects:dict1,nil];
        BOOL flag1 = [arr writeToFile:filePath atomically:YES];
              if (flag1) {
                  NSLog(@"plist文件写入成功");
              }else{
                  NSLog(@"plist 文件写入失败");
              }
    }
    if (filePath)
    {
        self.feedsLocal = [Feed pathList:filePath];
        //NSLog(@"path: %@", self.feedsLocal);
        [self.outlineViewLocal reloadData];
    }
    
     local_checkBoxFlag = [Feed readLocalItemCheckBox:filePath];
    [m_configDictionary setValue:[NSNumber numberWithInt:local_checkBoxFlag] forKey:kSetLocalCsvMode];
    
    NSString *fileInsightPath = [NSString stringWithFormat:@"%@/%@",userPath,insightDataPlist];
    insight_checkBoxFlag = [Feed readInsightItemCheckBox:fileInsightPath];
    [m_configDictionary setValue:[NSNumber numberWithInt:insight_checkBoxFlag] forKey:kSetInsightCsvMode];
    
    
    
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
    if ([sender.identifier isEqualToString:@"localdata"])
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
    
    if ([outlineView.identifier isEqualToString:@"localdata"])
    {
        if ([item isKindOfClass:[Feed class]]) {
                 //NSLog(@"feed.children.count....");
                 Feed *feed = (Feed *)item;
                 return feed.children.count;
             } else {
                 //NSLog(@"self.feeds.count..");
                 return self.feedsLocal.count;
             }
        
    }
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
    if ([outlineView.identifier isEqualToString:@"localdata"])
    {
        Feed *feed = (Feed *)item;
             if (feed) {
                 return feed.children[index];
             } else {
                 return self.feedsLocal[index];
             }
        
    }
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
    if ([outlineView.identifier isEqualToString:@"localdata"])
       {
           
           if ([item isKindOfClass:[Feed class]]) {
               Feed *feed = (Feed *)item;
               return feed.children.count > 0;
           } else {
               return NO;
           }
       }
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
    if ([outlineView.identifier isEqualToString:@"localdata"])
    {
        if ([item isKindOfClass:[Feed class]])
            {
                Feed *feed = (Feed *)item;
                if ([tableColumn.identifier isEqualToString:@"filepath"])
                {
                    view = (NSTableCellView *)[outlineView makeViewWithIdentifier:@"FilePathCell" owner:self];
                    
                    NSArray *subviews = [view subviews];
                    
                    NSTextField *textField = subviews[0];
                    if (textField)
                    {
                        textField.stringValue = feed.name;
                        [textField sizeToFit];
                    }
                    
                    NSButton *cellButton = subviews[1];
                    
                    if (local_checkBoxFlag ==0)
                    {
                        [cellButton setEnabled:NO];
                        [cellButton setEnabled:YES];
                    }
                    else
                    {
                        [cellButton setEnabled:YES];
                    }
                    if (insight_checkBoxFlag ==0 && local_checkBoxFlag == 0)
                    {
                       [cellButton setEnabled:YES];
                    }
                    [cellButton setFrame:NSMakeRect(200, -7, 80, 32)];
                    [cellButton setAction:@selector(btnChooseLocal:)];
                    
                }
                else if ([tableColumn.identifier isEqualToString:@"choosepath"])
                        {
                            view = [outlineView makeViewWithIdentifier:@"choosepath" owner:self];
                            NSButton *cellButton = (NSButton*)view;
                            
                            if (local_checkBoxFlag ==0)
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
                            [cellButton setAction:@selector(btnChooseLocal:)];
                                 
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
                    if (local_checkBoxFlag ==0)
                    {
                        //[cellButton setEnabled:NO];
                       
                        [cellButton setEnabled:YES];
                    }
                    else
                    {
                        [cellButton setEnabled:YES];
                    }
                    if (insight_checkBoxFlag ==0 && local_checkBoxFlag == 0)
                    {
                        [cellButton setEnabled:YES];
                    }
                    
                    [cellButton setAction:@selector(itemCheckedLocal:)];
                         
                }

            }
        
        return view;
    }
    
    
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
            //                 NSString *itemName = [self getItemName:item];
            //                 [cellButton setTitle:itemName];
    //                    cellButton.tag = row;
    //                    cellButton.target = self;
                        
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
    //        if ([tableColumn.identifier isEqualToString:@"index"]) {
    //            view = (NSTableCellView *)[outlineView makeViewWithIdentifier:@"IndexCell" owner:self];
    //            NSTextField *textField = view.textField;
    //            if (textField) {
    //                textField.stringValue = feedItem.indexPath;
    //                [textField sizeToFit];
    //            }
    //        }
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
    //                 NSString *itemName = [self getItemName:item];
    //                 [cellButton setTitle:itemName];
                
                
                if (insight_checkBoxFlag ==0)
                {
                    [cellButton setEnabled:YES];
                    [_browes setEnabled:YES];
                    [_browesButton setEnabled:YES];
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
                
                [cellButton setAction:@selector(itemChecked:)];
                     
            }

        }
    return view;
    }
    return nil;
}


- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
//    if (![notification.object isKindOfClass:[NSOutlineView class]]) {
//        return;
//    }
//    NSOutlineView *outlineView = (NSOutlineView *)notification.object;
//    NSInteger selectedIndex = outlineView.selectedRow;
//    FeedItem *feedItem = [outlineView itemAtRow:selectedIndex];
//    if (![feedItem isKindOfClass:[FeedItem class]]) {
//        return;
//    }
//    if (feedItem)
//    {
//        NSURL *url = [NSURL URLWithString:feedItem.url];
//        if (url) {
//            [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
//        }
//    }
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
    NSUInteger selectedRowLocal = self.outlineViewLocal.selectedRow;
    if (selectedRow == -1 && selectedRowLocal == -1)
    {
        return;
    }
    
    if (selectedRowLocal >0)
    {
        [self.outlineViewLocal beginUpdates];
        id item = [self.outlineViewLocal itemAtRow:selectedRowLocal];
        if ([item isKindOfClass:[Feed class]])
        {
    
        }
        else if ([item isKindOfClass:[FeedItem class]])
        {
                FeedItem *feedItem = (FeedItem *)item;
                for (Feed *feed in self.feedsLocal)
                {
                    NSUInteger index = [feed.children indexOfObjectPassingTest:^BOOL(FeedItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
                    {
                        return [feedItem.pathFile isEqualToString:obj.pathFile];
                        
                    }];
                    if (index != NSNotFound)
                    {
                        [feed.children removeObjectAtIndex:index];
                        NSLog(@"=======remove: %zd,  %@  ,  %@",index,feed.name,feed.children);
                        [self.outlineViewLocal removeItemsAtIndexes:[NSIndexSet indexSetWithIndex:index] inParent:feed withAnimation:NSTableViewAnimationSlideLeft];
                    }
                }
                
                NSString *name1 = self.feedsLocal[0].name;
                NSArray *arr1 = self.feedsLocal[0].children;
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
                
                NSArray *arr = [NSArray arrayWithObjects:dict1, nil];
                NSString *filePath = [NSString stringWithFormat:@"%@/%@",userPath,customDataPlist];
                BOOL flag1 = [arr writeToFile:filePath atomically:YES];
                if (flag1)
                {
                   NSLog(@"plist文件写入成功");
                }else
                {
                   NSLog(@"plist 文件写入失败");
                }
            }
            
            [self.outlineViewLocal endUpdates];
        
    }
    
    if (selectedRow >0)
    {
        [self.outlineView beginUpdates];
        
        id item = [self.outlineView itemAtRow:selectedRow];
        if ([item isKindOfClass:[Feed class]]) {
    //        Feed *feed = (Feed *)item;
    //        NSUInteger index = [self.feeds indexOfObjectPassingTest:^BOOL(Feed * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    //            return [feed.name isEqualToString:obj.name];
    //        }];
    //        if (index != NSNotFound) {
    //            [self.feeds removeObjectAtIndex:index];
    //            [self.outlineView removeItemsAtIndexes:[NSIndexSet indexSetWithIndex:selectedRow] inParent:nil withAnimation:NSTableViewAnimationSlideLeft];
    //        }
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
            
            
            NSString *name3 = self.feeds[2].name;
            NSArray *arr3 = self.feeds[2].children;
            NSMutableArray *arrM3 = [NSMutableArray array];
            for (int i=0; i<[arr3 count]; i++)
            {
                NSArray * arrsub = [[NSString stringWithFormat:@"%@",arr3[i]] componentsSeparatedByString:@","];
                int check = [arrsub[0] intValue];
                NSString *filePath = arrsub[1];
                NSDictionary *dicitem =[NSDictionary dictionaryWithObjectsAndKeys:filePath,@"file_path",[NSNumber numberWithInt:check],@"check",nil];
                [arrM3 addObject:dicitem];
            }
            NSDictionary *dict3 = [NSDictionary dictionaryWithObjectsAndKeys:name3,@"name",arrM3,@"items", nil];
            
            
            NSArray *arr = [NSArray arrayWithObjects:dict1,dict2,dict3, nil];
            NSString *filePath = [NSString stringWithFormat:@"%@/%@",userPath,insightDataPlist];
            BOOL flag1 = [arr writeToFile:filePath atomically:YES];
                       if (flag1) {
                           NSLog(@"plist文件写入成功");
                       }else{
                           NSLog(@"plist 文件写入失败");
                       }
            
            
            
           
            
    //        NSArray *arr = [NSArray arrayWithObjects:dic1,dic2, nil];
            
            
        }
        
        [self.outlineView endUpdates];
    }
}


- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item{
    [outlineView setFont:[NSFont boldSystemFontOfSize:30]];
    return 20;

}
-(NSString *)openAtlasLoadPanel
{
    NSString *csvpath =nil;
    NSOpenPanel * panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO]; //设置多选模式
    [panel setCanChooseFiles:NO];
    [panel setCanCreateDirectories:YES];
    [panel setCanChooseDirectories:YES];

    [panel runModal];
    if ([[panel URLs] count]>0)
    {
        csvpath = [[[panel URLs] objectAtIndex:0] path];
        return csvpath;
    }
    return csvpath;
}



-(NSString *)openCSVLoadPanel
{
    NSString *csvpath =nil;
    NSOpenPanel * panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO]; //设置多选模式
    [panel setCanChooseFiles:YES];
    [panel setCanCreateDirectories:YES];
    [panel setCanChooseDirectories:YES];
    [panel setAllowedFileTypes:[NSArray arrayWithObjects:@"CSV", @"csv", @"Csv",nil]];
    //[panel setDirectoryURL:[NSURL URLWithString:desktopPath]];
    [panel runModal];
    if ([[panel URLs] count]>0)
    {
        csvpath = [[[panel URLs] objectAtIndex:0] path];
        if ([[csvpath pathExtension] isEqualToString:@"CSV"]||[[csvpath pathExtension] isEqualToString:@"csv"]||[[csvpath pathExtension] isEqualToString:@"Csv"])
        {
            return csvpath;
        }
        else
        {
            [self AlertBox:@"Error:011" withInfo:@"You choose wrong csv file path!"];
            return nil;
        }
        //[self.txtScriptPath setStringValue:csvpath];
    }
//    else
//    {
//        //[self.txtScriptPath setStringValue:@"--"];
//    }
    //if (csvpath==nil || [csvpath isEqualToString:desktopPath])
//    if (csvpath==nil)
//    {
//        return nil;
//    }
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

#pragma mark Action methods



-(IBAction)btnChoose:(id)sender
{
    NSLog(@"=====button chose==");
    NSInteger checkedCellIndex = [_outlineView rowForView:sender];
    NSArray *arr1 = self.feeds[0].children;
    NSArray *arr2 = self.feeds[1].children;
    NSArray *arr3 = self.feeds[2].children;
    //NSArray *arr4 = self.feeds[3].children;
    NSUInteger n_script =  checkedCellIndex- [arr1 count] ;
    NSUInteger n_update_limit =  checkedCellIndex- [arr1 count] - [arr2 count];
    NSUInteger n_atlas2_folder =checkedCellIndex-   [arr3 count] - [arr1 count] - [arr2 count];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",userPath,insightDataPlist];
    

    if (checkedCellIndex==0)
    {
         NSString *strpath = [self openCSVLoadPanel];
        if (filePath && strpath)
        {
            [Feed addToPathWrite:filePath withAddPath:strpath with:0];
            self.feeds = [Feed pathList:filePath];
            [self.outlineView reloadData];
            [self.outlineView expandItem:nil expandChildren:YES];
            
            [self itemLocalUncheckAll];
        }
        else
        {
            return;
        }
    }
    else if (n_script==1)
    //else if(checkedCellIndex==1)
    {
        
        NSTextView *accessory = [[NSTextView alloc] initWithFrame:NSMakeRect(0,0,200,15)];

        [accessory setEditable:NO];

        [accessory setDrawsBackground:NO];
        
        NSAlert *alert = [[NSAlert alloc] init];

        [alert setMessageText:@"Please select a button"];

        [alert addButtonWithTitle:@"Atlas2 Script"];

        [alert addButtonWithTitle:@"Legacy Script" ];

        [alert setAccessoryView:accessory];

        NSUInteger result = [alert runModal];
        
        NSMutableString* strpath = [[NSMutableString alloc] init];

        if (result == NSAlertFirstButtonReturn)
        {

            [strpath setString:[self openAtlasLoadPanel]];

        }
        else{
            [strpath setString:[self openCSVLoadPanel]];
        }
        
        
        if (filePath && strpath)
        {
            [Feed addToPathWrite:filePath withAddPath:strpath with:1];
            
            for (int i=0; i<[arr2 count]; i++) {

                int line = (int)(i+[arr1 count]+2);
                [Feed addToItemClick:filePath withLine:line ItemClick:NO with:1];
            }
            
            self.feeds = [Feed pathList:filePath];
            [self.outlineView reloadData];
            [self.outlineView expandItem:nil expandChildren:YES];
            
            [self itemLocalUncheckAll];
        }
        else
        {
            return;
        }

          
        
        
    }
    //else if(checkedCellIndex==2)
    else if (n_update_limit==2)
    {
         NSString *strpath = [self openXlsxLoadPanel];
        if (filePath && strpath)
        {
            [Feed addToPathWrite:filePath withAddPath:strpath with:2];
            self.feeds = [Feed pathList:filePath];
            [self.outlineView reloadData];
            [self.outlineView expandItem:nil expandChildren:YES];
            
            [self itemLocalUncheckAll];
        }
        else
        {
            return;
        }
    }
//    else if (n_atlas2_folder==3)
//    {
//        NSString *strpath = [self openAtlasLoadPanel];
//        if (filePath && strpath)
//        {
//            [Feed addToPathWrite:filePath withAddPath:strpath with:3];
//
//            for (int i=0; i<[arr2 count]; i++) {
//
//                int line = (int)(i+[arr1 count]+2);
//                [Feed addToItemClick:filePath withLine:line ItemClick:NO with:1];
//            }
//
//            self.feeds = [Feed pathList:filePath];
//            [self.outlineView reloadData];
//            [self.outlineView expandItem:nil expandChildren:YES];
//
//            [self itemLocalUncheckAll];
//        }
//        else
//        {
//            return;
//        }
//    }
    
    
    insight_checkBoxFlag = [Feed readInsightItemCheckBox:filePath];
    [m_configDictionary setValue:[NSNumber numberWithInt:insight_checkBoxFlag] forKey:kSetInsightCsvMode];
    
    
    NSString *filePath_local = [NSString stringWithFormat:@"%@/%@",userPath,customDataPlist];
    //[Feed addLocalToClearItemClick:filePath_local];
    local_checkBoxFlag  = [Feed readLocalItemCheckBox:filePath_local];
    [m_configDictionary setValue:[NSNumber numberWithInt:local_checkBoxFlag] forKey:kSetLocalCsvMode];
    self.feedsLocal = [Feed pathList:filePath_local];
    [self.outlineViewLocal reloadData];
    [self.outlineViewLocal expandItem:nil expandChildren:YES];
    
}




- (IBAction)itemChecked:(id)sender
{
    [self itemLocalUncheckAll];
    
    
    NSButton *checkedCellButton = (NSButton*)sender;
    
   // NSString *checkedCellName = [checkedCellButton title];
    NSInteger checkedCellIndex = [_outlineView rowForView:sender];
    //id itemAtRow = [_outlineView itemAtRow:checkedCellIndex];
    //NSLog(@"====itemChecked>>>%@, %@",checkedCellName,itemAtRow);
   
    int state = (int)checkedCellButton.state;
    //NSLog(@"====<<>>>>%ld: %@   %zd", checkedCellIndex, checkedCellName,state);
    
    
//    self.feed
    NSArray *arr1 = self.feeds[0].children;
    NSUInteger count = [arr1 count] ;
    
    NSArray *arr2 = self.feeds[1].children;
    NSUInteger count2 = [arr2 count] ;
    
    NSArray *arr3 = self.feeds[2].children;
    NSUInteger count3 = [arr3 count] ;
    
    //NSArray *arr4 = self.feeds[3].children;
    //NSUInteger count4 = [arr4 count] ;
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",userPath,insightDataPlist];
    
    if (checkedCellIndex<=count)
    {
        
        
        int line = (int)checkedCellIndex-1;
        //self.feeds[0].children[line].flag = state;
        [Feed addToItemClick:filePath withLine:line ItemClick:state with:0];
    }
    else if(checkedCellIndex<=count+count2+1)
    {

        int line = (int)(checkedCellIndex-count-2);
        [Feed addToItemClick:filePath withLine:line ItemClick:state with:1];
        
//        if (state == YES) {
//            for (int i=0; i<count4; i++) {
//
//                int line = (int)(i+count+count2+count3+4);
//                [Feed addToItemClick:filePath withLine:line ItemClick:NO with:3];
//            }
//        }
        //self.feeds[1].children[checkedCellIndex-count -2].flag = state;
    }
    else if(checkedCellIndex<=count+count2+count3+2)
    {
        //？？？？
        int line = (int)(checkedCellIndex-count-count2-3);
        [Feed addToItemClick:filePath withLine:line ItemClick:state with:2];
    }
    else
    {
        //？？？？
//        int line = (int)(checkedCellIndex-count-count2-count3-4);
//        [Feed addToItemClick:filePath withLine:line ItemClick:state with:3];
//
//        if (state == YES) {
//            for (int i=0; i<count2; i++) {
//
//                int line = (int)(i+count+2);
//                [Feed addToItemClick:filePath withLine:line ItemClick:NO with:1];
//            }
//        }
    }

//    [self.outlineView reloadData];
    
    self.feeds = [Feed pathList:filePath];
    [self.outlineView reloadData];
    [self.outlineView expandItem:nil expandChildren:YES];
    
    insight_checkBoxFlag = [Feed readInsightItemCheckBox:filePath];
    [m_configDictionary setValue:[NSNumber numberWithInt:insight_checkBoxFlag] forKey:kSetInsightCsvMode];
    
    NSString *filePath_local = [NSString stringWithFormat:@"%@/%@",userPath,customDataPlist];
    local_checkBoxFlag = [Feed readLocalItemCheckBox:filePath_local];
    [m_configDictionary setValue:[NSNumber numberWithInt:local_checkBoxFlag] forKey:kSetLocalCsvMode];
    //[Feed addLocalToClearItemClick:filePath_local];
    self.feedsLocal = [Feed pathList:filePath_local];
    [self.outlineViewLocal reloadData];
    [self.outlineViewLocal expandItem:nil expandChildren:YES];

  
}

-(IBAction)btnChooseLocal:(id)sender
{
       NSLog(@"******local choose******");
       NSInteger checkedCellIndex = [_outlineViewLocal rowForView:sender];
       NSString *filePath = [NSString stringWithFormat:@"%@/%@",userPath,customDataPlist];
       
       if (checkedCellIndex==0)
       {
            NSString *strpath = [self openCSVLoadPanel];
           if (filePath && strpath)
           {
               [Feed addLocalToPathWrite:filePath withAddPath:strpath with:0];
               self.feedsLocal = [Feed pathList:filePath];
               [self.outlineViewLocal reloadData];
               [self.outlineViewLocal expandItem:nil expandChildren:YES];
               
               [self itemUncheckAll];
           }
           else
           {
               return;
           }
       }
    
    
     local_checkBoxFlag = [Feed readLocalItemCheckBox:filePath];
    [m_configDictionary setValue:[NSNumber numberWithInt:local_checkBoxFlag] forKey:kSetLocalCsvMode];
    
    NSString *filePath_insight = [NSString stringWithFormat:@"%@/%@",userPath,insightDataPlist];
    insight_checkBoxFlag = [Feed readInsightItemCheckBox:filePath_insight];
    [m_configDictionary setValue:[NSNumber numberWithInt:insight_checkBoxFlag] forKey:kSetInsightCsvMode];
    
    self.feeds = [Feed pathList:filePath_insight];
    [self.outlineView reloadData];
    [self.outlineView expandItem:nil expandChildren:YES];
       
    
}

-(void)itemUncheckAll{
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",userPath,insightDataPlist];
    
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
-(void)itemLocalUncheckAll{
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",userPath,customDataPlist];
    
    
    NSArray *arr1 = self.feedsLocal[0].children;
    NSUInteger count = [arr1 count] ;

    for (int i=0; i < count; i++) {
        [Feed addLocalToItemClick:filePath withLine:i ItemClick:0 with:0];
        
        
        
    
    }
    
    local_checkBoxFlag = 0;
    
    [self.outlineViewLocal reloadData];
    [self.outlineViewLocal expandItem:nil expandChildren:YES];
    
    
    
}

- (IBAction)itemCheckedLocal:(id)sender
{
    
    [self itemUncheckAll];
        
        NSButton *checkedCellButton = (NSButton*)sender;
    
        NSInteger checkedCellIndex = [_outlineViewLocal rowForView:sender];
        int state = (int)checkedCellButton.state;
        NSArray *arr1 = self.feedsLocal[0].children;
        NSUInteger count = [arr1 count] ;

        NSString *filePath = [NSString stringWithFormat:@"%@/%@",userPath,customDataPlist];
        
        if (checkedCellIndex<=count)
        {
            int line = (int)checkedCellIndex-1;
            [Feed addLocalToItemClick:filePath withLine:line ItemClick:state with:0];
        }

        local_checkBoxFlag = [Feed readLocalItemCheckBox:filePath];
        [m_configDictionary setValue:[NSNumber numberWithInt:local_checkBoxFlag] forKey:kSetLocalCsvMode];
    
        self.feedsLocal = [Feed pathList:filePath];
        [self.outlineViewLocal reloadData];
        [self.outlineViewLocal expandItem:nil expandChildren:YES];
    
        NSString *filePath_insight = [NSString stringWithFormat:@"%@/%@",userPath,insightDataPlist];
       
        insight_checkBoxFlag = [Feed readInsightItemCheckBox:filePath_insight];
       [m_configDictionary setValue:[NSNumber numberWithInt:insight_checkBoxFlag] forKey:kSetInsightCsvMode];
    
        //[Feed addToClearItemClick:filePath_insight];
        self.feeds = [Feed pathList:filePath_insight];
        [self.outlineView reloadData];
        [self.outlineView expandItem:nil expandChildren:YES];
    
}

- (IBAction)btClearLocal:(id)sender
{
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",userPath,customDataPlist];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager removeItemAtPath:filePath error:NULL])
      {
          NSLog(@"Removed loadScript.plist successfully");
      }
    
    [self fillLocalTestData];
    local_checkBoxFlag = 0;
    
    NSString *filePath_insight = [NSString stringWithFormat:@"%@/%@",userPath,insightDataPlist];
    [Feed addToClearItemClick:filePath_insight];
    insight_checkBoxFlag = [Feed readInsightItemCheckBox:filePath_insight];
    [m_configDictionary setValue:[NSNumber numberWithInt:insight_checkBoxFlag] forKey:kSetInsightCsvMode];

    self.feeds = [Feed pathList:filePath_insight];
    [self.outlineView reloadData];
    [self.outlineView expandItem:nil expandChildren:YES];
    
}



- (IBAction)btClear:(id)sender
{
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",userPath,insightDataPlist];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager removeItemAtPath:filePath error:NULL])
      {
          NSLog(@"Removed loadScript.plist successfully");
      }
    
    [self fillTestData];
    insight_checkBoxFlag = 0;
    
    NSString *filePath_local = [NSString stringWithFormat:@"%@/%@",userPath,customDataPlist];
    [Feed addLocalToClearItemClick:filePath_local];
    local_checkBoxFlag = [Feed readLocalItemCheckBox:filePath_local];
    [m_configDictionary setValue:[NSNumber numberWithInt:local_checkBoxFlag] forKey:kSetLocalCsvMode];
    self.feedsLocal = [Feed pathList:filePath_local];
    [self.outlineViewLocal reloadData];
    [self.outlineViewLocal expandItem:nil expandChildren:YES];
    
}


- (IBAction)btLoadLocalData:(id)sender   // no use
{
        NSString *cpkL=[_cpk_lthl stringValue];
        NSString *cpkH=[_cpk_hthl stringValue];
        if ([self isOnlyhasNumberAndpointWithString:cpkL] && [self isOnlyhasNumberAndpointWithString:cpkH])
        {
            float cpk_L = [cpkL floatValue];
            float cpk_H = [cpkH floatValue];
            if (cpk_L>cpk_H)
            {
                [self AlertBox:@"Error:015" withInfo:@"Input cpk HTHL must bigger than LTHL!"];
                return;
            }
            else
            {
                // continue
            }
            
        }
        else
        {
            [self AlertBox:@"Error:016" withInfo:@"Please input a number!"];
            return;
        }

        
        [self.outlineViewLocal reloadData];
        NSString *dataCsv = nil;
        NSArray *arr1 = self.feedsLocal[0].children;
        for (int i=0; i<[arr1 count]; i++)
        {
            NSArray * arrsub = [[NSString stringWithFormat:@"%@",arr1[i]] componentsSeparatedByString:@","];
            int check = self.feedsLocal[0].children[i].flag;
            if (check == 1)
            {
                dataCsv = arrsub[1];
                break;
            }
        }
}

-(bool)isAtlas2{
    return false;
//    NSArray *arr1 = self.feeds[0].children;
//    NSUInteger count = [arr1 count] ;
//
//    NSArray *arr2 = self.feeds[1].children;
//    NSUInteger count2 = [arr2 count] ;
//
//    NSArray *arr3 = self.feeds[2].children;
//    NSUInteger count3 = [arr3 count] ;
//
//    NSArray *arr4 = self.feeds[3].children;
//    NSUInteger count4 = [arr4 count] ;
//
//    NSString *filePath = [NSString stringWithFormat:@"%@/%@",userPath,insightDataPlist];
//
//
//
//    bool isAtlas2 = false;
//    for (int i=0; i<count4; i++) {
//        if (self.feeds[3].children[i].flag == YES) {
//            isAtlas2 = true;
//            break;
//        }
//    }
//    return isAtlas2;
}
- (IBAction)btLoadScript:(id)sender
{
    
    
    
    
    //Added By Vito
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCloseStartUp object:nil userInfo:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationInHidenFilter object:nil userInfo:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationHidenAllWindows object:nil userInfo:nil];

    NSString *cpkL=[_cpk_lthl stringValue];
    NSString *cpkH=[_cpk_hthl stringValue];
    if ([self isOnlyhasNumberAndpointWithString:cpkL] && [self isOnlyhasNumberAndpointWithString:cpkH])
    {
        float cpk_L = [cpkL floatValue];
        float cpk_H = [cpkH floatValue];
        if (cpk_L>cpk_H)
        {
            [self AlertBox:@"Error:015" withInfo:@"Input cpk HTHL must bigger than LTHL!"];
            return;
        }
        else
        {
            // continue
        }
        
    }
    else
    {
        [self AlertBox:@"Error:016" withInfo:@"Please input a number!"];
        return;
    }

    
    //----local 数据加载
    [self.outlineViewLocal reloadData];
    NSString *dataCsvLocal = nil;
    NSArray *arr1_local = self.feedsLocal[0].children;
    for (int i=0; i<[arr1_local count]; i++)
    {
       NSArray * arrsub = [[NSString stringWithFormat:@"%@",arr1_local[i]] componentsSeparatedByString:@","];
       int check = self.feedsLocal[0].children[i].flag;
       if (check == 1)
       {
           dataCsvLocal = arrsub[1];
           break;
       }
    }
    if (local_checkBoxFlag>0)  //local_checkBoxFlag
    {
        
        NSLog(@"=*>local dataCsv: %@, ",dataCsvLocal);
        [m_configDictionary setValue:dataCsvLocal forKey:Load_Local_Csv_Path];
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:cpkL,cpk_Lowthl,cpkH,cpk_Highthl,dataCsvLocal,@"data_csv", nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationToLocalLoadCsv object:nil userInfo:dic];
        [NSThread sleepForTimeInterval:0.5];
        return;
    }
    
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
    
    
    
    NSString *scriptCsv = @"";
    NSArray *arr2 = self.feeds[1].children;
    
    for (int i=0; i<[arr2 count]; i++)
    {
        NSArray * arrsub = [[NSString stringWithFormat:@"%@",arr2[i]] componentsSeparatedByString:@","];
        int check = self.feeds[1].children[i].flag;
        if (check == 1)
        {
            scriptCsv =arrsub[1];
            break;
        }
    }
    
    
    NSString *limitXlsx = @"";
    NSArray *arr3 = self.feeds[2].children;
    for (int i=0; i<[arr3 count]; i++)
    {
        NSArray * arrsub = [[NSString stringWithFormat:@"%@",arr3[i]] componentsSeparatedByString:@","];
//        int check = [arrsub[0] intValue];
        int check = self.feeds[2].children[i].flag;
        if (check == 1)
        {
            limitXlsx =arrsub[1];
            break;
        }
    }
    
    
    // need do 2
    //scriptCsv
    //scriptCsv check end with "/Assets" then isAtlas2Flag = true
    // else isAtlas2Flag = false
    NSString *strCompare= @"/Assets";
    
    bool isAtlas2Flag= [scriptCsv hasSuffix:strCompare];
    
    if(isAtlas2Flag==1){
//        NSArray *arr4 = self.feeds[3].children;
//        for (int i=0; i<[arr4 count]; i++)
//        {
//            NSArray * arrsub = [[NSString stringWithFormat:@"%@",arr4[i]] componentsSeparatedByString:@","];
//            int check = self.feeds[3].children[i].flag;
//            if (check == 1)
//            {
//                scriptCsv =arrsub[1];
//                break;
//            }
//        }
        //
        [m_dic setDictionary:[NSDictionary dictionaryWithObjectsAndKeys:cpkL,cpk_Lowthl,cpkH,cpk_Highthl,dataCsv,@"data_csv",scriptCsv,@"script_csv",limitXlsx,@"limit_xlsx", nil]];
        [self sendAtlas2ZmqMsg:[NSString stringWithFormat:@"atlas2_profile_load@%@",scriptCsv ]];
    }
    else{
        NSLog(@"dataCsv: %@,  scriptCsv:%@, limitXlsx: %@",dataCsv,scriptCsv,limitXlsx);
        [m_configDictionary setValue:dataCsv forKey:Load_Csv_Path];
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:cpkL,cpk_Lowthl,cpkH,cpk_Highthl,dataCsv,@"data_csv",scriptCsv,@"script_csv",limitXlsx,@"limit_xlsx", nil];
        
        
        //NSDictionary *dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:xy] forKey:selectXY];
        [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationToLoadCsv object:nil userInfo:dic];
        
    }
    

}
- (void)callbackWithNotification:(NSNotification *)nf;
{
    if([nf.name isEqualToString:@"post-json"]){
    
//NSLog(@"Notification Received1 %@",[nf userInfo][@"info"]);
        
        
        NSString * limitfile =[NSString stringWithFormat:@"%@",[nf userInfo][@"info"]];
        
        NSArray* datas =  [limitfile componentsSeparatedByString:NSLocalizedString(@"^&^", nil)];
        
        if([datas count] >=2){
            
            if ([datas[0] isEqualToString:@"atlas2_profile_load"]) {
                NSData *jsonData = [datas[1] dataUsingEncoding:NSUTF8StringEncoding];

                NSError *err;

                NSDictionary *jsonDict_testPlan = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                    options:NSJSONReadingMutableContainers
                                                                      error:&err];


                if(err) {
                    NSLog(@"TestPlan Convert Fail：%@",err);

                }
                
               
                m_dic[@"script_csv"] =jsonDict_testPlan[@"path"];
                
                [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationToLoadCsv object:nil userInfo:m_dic];

            }
        }
    }
}

-(NSString *)sendAtlas2ZmqMsg:(NSString *)name  //keynote zmq
{
    int ret = [reportAtlas2Client SendCmd:name];
    if (ret > 0)
    {
        NSString * response = [reportAtlas2Client RecvRquest:1024];
        if (!response)
        {
            NSLog(@"zmq atlas for python error");
        }
        NSLog(@"app->get response from keynote python: %@",response);
        return response;
    }
    return nil;
}

- (IBAction)txtCpkHthl:(id)sender
{
    NSString *str = [_cpk_hthl stringValue];
    if ([self isOnlyhasNumberAndpointWithString:str])
    {
        
        return;
    }
    else
    {
        [self AlertBox:@"Error:016" withInfo:@"Please input a number."];
        [_cpk_hthl setStringValue:@"10.0"];
    }
    
}

- (IBAction)txtCpkLthl:(id)sender
{
    
     NSString *str = [_cpk_lthl stringValue];
     if ([self isOnlyhasNumberAndpointWithString:str])
     {
         return;
     }
     else
     {
         [self AlertBox:@"Error:016" withInfo:@"Please input a number."];
         [_cpk_lthl setStringValue:@"1.5"];
     }
}


//-(void)controlTextDidEndEditing:(NSNotification *)obj
//{
//    NSTextField *textF =obj.object;
//    if ([textF.identifier isEqualToString:@"cpk_lthl"])
//    {
//        NSLog(@"------txt2221");
//    }
//    else if ([textF.identifier isEqualToString:@"cpk_hthl"])
//    {
//        NSLog(@"------txt1111");
//    }
//
//}
-(void)AlertBox:(NSString *)msgTxt withInfo:(NSString *)strmsg
{
    NSAlert * alert = [[NSAlert alloc] init];
    alert.messageText = msgTxt;
    alert.informativeText = strmsg;
    [alert runModal];
}
@end
