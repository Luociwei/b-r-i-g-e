//
//  dataTableView.m
//  CPK_Test
//
//  Created by RyanGao on 2020/6/25.
//  Copyright © 2020 RyanGao. All rights reserved.
//

#import "dataTableView.h"
#import "parseCSV.h"
#import "SCNSEventEx.framework/Headers/NSEventEx.h"
#import "SCRedis.framework/Headers/RedisInterface.hpp"
#import "../DataPlot/dataPlotView.h"
#import "../DataPlot/defineHeader.h"
//#import "dataPlotView.h"
//#import "defineHeader.h"
#import "SCZmq.framework/Headers/Client.h"
//#import "../XlsxReaderWriter.framework/Headers/BRAOfficeDocumentPackage.h"
#import "SCopensslSha1.framework/Headers/sha.h"
#import "loadCsvControl.h"
#import <Quartz/Quartz.h>
#import <QuartzCore/QuartzCore.h>
#import "SCMouseFunction.h"
#import "NSPopover+Message.h"
#import "customWinController.h"
#import "CSVParser2.h"
#import "CSVReader.h"
#import "CSVConfiguration.h"
#import "csv.h"

//#import "AppConstants.h"
//#import "AppUtils.h"
//#import "../SCparseCSV.framework/Headers/parseCSV.h"



extern NSMutableDictionary *m_configDictionary;
extern NSInteger tbDataTableSelectItemRow;

extern NSMutableArray *_dataReverse;
extern NSMutableArray *_rawData;
extern int selectColorBoxIndex; //left color by
extern int selectColorBoxIndex2;//right color by

extern RedisInterface *myRedis;
extern Client *cpkClient;
extern Client *boxClient;
extern Client *correlationClient;

extern Client *reportHashClient;//hash

extern Client *scatterClient;

Client *retestPlotClient;
Client *calculateClient;
Client *retestRateClient;

int n_Start_Data_Col;
int n_Pass_Fail_Status;
int n_Product_Col;
int n_SerialNumber;
int n_SpecialBuildName_Col;
int n_Special_Build_Descrip_Col;
int n_StationID_Col;
int n_SlotId_Col;
int n_StartTime;
int n_Version_Col;
int n_Diags_Version_Col;
int n_OS_VERSION_Col;
int n_passdata;

/*
 
 
 #define Start_Data_Row                 7
 #define Start_Data_Col                 11
 #define Pass_Fail_Status               7
 #define Product_Col                    1
 #define SerialNumber                   2
 #define SpecialBuildName_Col           3
 #define Special_Build_Descrip_Col      4
 #define StationID_Col                  6
 #define StartTime                      8
 #define Version_Col                    10
 */


@interface dataTableView ()
{
    BOOL enableEditing;
    NSUInteger clickItemIndex;
    NSUInteger editLimitRow;
    NSString *retestValue;  //记录上次结果
    NSString *removeValue;  //记录上次结果
    NSString *desktopPath;
    int select_btn_x;
    int select_btn_y;
    int click_item_flag;
    NSMutableArray *arrSearch;
    NSMutableArray *arrSearchRed;
    NSMutableArray *arrSearchGreen;
    
    NSMutableArray *arrSearchRedCPK;
    NSMutableArray *arrSearchGreenCPK;
    NSMutableArray *arrSearchYellowCPK;
    
    int n_search;
    CGFloat _lastLeftPaneWidth;
    int n_loadCsvBtn;
    int n_sort_col1;
    int n_sort_col5;
    int n_sort_col9;  //reviwer
    int n_sort_col12;  //bmc
    
    NSMutableArray * tmpColorArr;
    NSInteger click_tb_row;
    
    NSInteger n_reviewer_col;
    NSInteger n_double_click;
    NSMutableArray *hash_value;
    BOOL b_ClearComment;
    NSMutableString *inputCharacter;
    
    int n_firstItemClick;
    NSInteger n_clickApplyRow;
    
    NSMutableDictionary *dicMouseFunc;
    NSMutableDictionary *dicHeaderName;
    NSMutableDictionary *dicHelpInfo;
    NSArray *helpInfo_name;
    BOOL b_isCustomCSV;
    
    NSMutableArray *rawArrarTmp1;
    float n_loadStepCount;
    
    
    //Added by Vito
    
    NSMutableArray * searchExceptIndex;
    
    NSMutableArray * filterStack;
    NSMutableArray * filterStackData;
    
    NSMutableArray* cpkOrigRedColorIndex;
    NSMutableArray* cpkOrigGreenColorIndex;
    NSMutableArray* cpkOrigYellowColorIndex;
    NSMutableArray* cpkOrigOtherColorIndex;
    
    NSMutableDictionary * indexfilterFlag;
    NSMutableArray * indexfilterRowIndex;
    
    NSMutableDictionary * unitfilterFlag;
    NSMutableArray * unitfilterRowIndex;
    
    NSMutableDictionary * uslfilterFlag;
    NSMutableArray * uslRowIndex;
    NSMutableDictionary * lslfilterFlag;
    NSMutableArray * lslRowIndex;
    
    NSMutableDictionary * cpk_origfilterFlag;
    NSMutableArray * cpk_origfilterRowIndex;
    
    NSMutableDictionary * reviewerfilterFlag;
    NSMutableArray * reviewerfilterRowIndex;
    
    NSMutableDictionary * reviewerKFlag;
    NSMutableArray * reviewerKIndex;
    
    NSMutableDictionary * bmfilterFlag;
    NSMutableArray * bmfilterRowIndex;
    
    NSMutableArray* allRowIndex;
    
    NSMutableArray * filterSourceData;
    
    NSArray *filterItemNames;
    
   
    
    //add end
    
}
@property (weak) IBOutlet NSSearchFieldCell *searchField;

@property (weak) IBOutlet NSTableView *dataTableView;
@property (nonatomic,strong)NSMutableArray *data;
@property (nonatomic,strong) NSMutableArray *dataBackup;
@property (nonatomic,strong)NSMutableArray *scriptData;
@property (nonatomic,strong)NSMutableArray *limitUpdateData;

@property (nonatomic,strong)NSMutableArray *sortDataBackup;
//@property (nonatomic,strong)NSMutableArray *rawData;
@property (nonatomic,strong)NSMutableDictionary *indexItemNameDic;
@property (nonatomic,strong)NSMutableArray *ListAllItemNameArr;
@property (nonatomic,strong)NSMutableDictionary *textEditLimitDic;

@property (nonatomic,strong)NSMutableArray *colorRedIndex;  //不相同的item，后面追加的数据，显示红色
@property (nonatomic,strong)NSMutableArray *colorGreenIndex; //相同的item，显示绿色
@property (nonatomic,strong)NSMutableArray *colorOtherIndex; //相同的item，显示绿色
@property (nonatomic,strong)NSMutableArray *colorGrayIndex; //相同的item，显示绿色


@property (nonatomic,strong)NSMutableArray *colorRedIndexBackup;  //不相同的item，后面追加的数据，显示红色
@property (nonatomic,strong)NSMutableArray *colorGreenIndexBackup; //相同的item，显示绿色

@property (nonatomic,strong)NSMutableArray *colorRedIndexSearchBackup;  //搜索的时候，颜色备份
@property (nonatomic,strong)NSMutableArray *colorGreenIndexSearchBackup; //搜素的时候，颜色备份

@property (nonatomic,strong)NSMutableArray *colorRedIndexCpk;  //cpk颜色
@property (nonatomic,strong)NSMutableArray *colorGreenIndexCpk; //cpk颜色
@property (nonatomic,strong)NSMutableArray *colorYellowIndexCpk; //cpk颜色

@property (nonatomic,strong)NSMutableArray *colorRedIndexSearchCpk;  //cpk颜色
@property (nonatomic,strong)NSMutableArray *colorGreenIndexSearchCpk; //cpk颜色
@property (nonatomic,strong)NSMutableArray *colorYellowIndexSearchCpk; //cpk颜色

@property (nonatomic,strong)NSMutableArray *colorRedIndexCpkBackup;  //cpk red颜色备份
@property (nonatomic,strong)NSMutableArray *colorGreenIndexCpkBackup; //cpk green颜色备份
@property (nonatomic,strong)NSMutableArray *colorYellowIndexCpkBackup; //cpk yellow颜色备份

@property (nonatomic,strong)NSMutableArray *reviewerNameIndex;  //reviewer name
@property (nonatomic,strong)NSMutableArray *reviewerNameIndexBackup;  //reviewer name 备份

@property (nonatomic,strong)NSMutableArray *bmcYesIndex;  //bmc YES
@property (nonatomic,strong)NSMutableArray *bmcNoIndex;  //bmc YES
@property (nonatomic,strong)NSMutableArray *bmcOtherIndex;  //bmc YES

@property (nonatomic,strong)NSMutableArray *KYesIndexItemNames;  //bmc YES
@property (nonatomic,strong)NSMutableArray *KYesIndex;  //bmc YES
@property (nonatomic,strong)NSMutableArray *KNoIndex;  //bmc YES

@property (weak) IBOutlet NSTextField *txtcsvDataName;
@property (weak) IBOutlet NSTextField *txtScriptName;
@property (weak) IBOutlet NSTextField *txtLimitUpdate;

@property loadCsvControl *modalCsvController;
@end

@implementation dataTableView


-(void) initFilterBuf{
    
    searchExceptIndex =[[NSMutableArray alloc]init];
    
    filterStack=[[NSMutableArray alloc]init];
    filterStackData=[[NSMutableArray alloc]init];
    
    indexfilterFlag=[[NSMutableDictionary alloc]init];
    indexfilterRowIndex=[[NSMutableArray alloc]init];
    
    
    
    unitfilterFlag=[[NSMutableDictionary alloc]init];
    unitfilterRowIndex=[[NSMutableArray alloc]init];
    
    uslfilterFlag =[[NSMutableDictionary alloc]init];
    uslRowIndex=[[NSMutableArray alloc]init];
    lslfilterFlag =[[NSMutableDictionary alloc]init];
    lslRowIndex=[[NSMutableArray alloc]init];
    
    cpk_origfilterFlag=[[NSMutableDictionary alloc]init];
    cpk_origfilterRowIndex=[[NSMutableArray alloc]init];
    
    cpkOrigRedColorIndex=[[NSMutableArray alloc]init];
    cpkOrigGreenColorIndex=[[NSMutableArray alloc]init];
    cpkOrigYellowColorIndex=[[NSMutableArray alloc]init];
    cpkOrigOtherColorIndex =[[NSMutableArray alloc]init];
    
    reviewerfilterFlag=[[NSMutableDictionary alloc]init];
    reviewerfilterRowIndex=[[NSMutableArray alloc]init];
    
    reviewerKFlag=[[NSMutableDictionary alloc]init];
    reviewerKIndex=[[NSMutableArray alloc]init];
    
    bmfilterFlag=[[NSMutableDictionary alloc]init];
    bmfilterRowIndex=[[NSMutableArray alloc]init];
    
    allRowIndex = [[NSMutableArray alloc] init];
    [allRowIndex addObject:indexfilterRowIndex];
    [allRowIndex addObject:cpk_origfilterRowIndex];
    [allRowIndex addObject:bmfilterRowIndex];
    [allRowIndex addObject:reviewerKIndex];
    
    
    
    
    //[allRowIndex addObject:unitfilterRowIndex];
    //[allRowIndex addObject:reviewerfilterRowIndex];
    
    //NSDictionary* dic = @{@"green":@(YES),@"yellow":@(YES),@"red":@(YES),@"other":@(YES)};
    
    [indexfilterFlag setDictionary:@{@"green":@(YES),@"red":@(YES),@"other":@(YES)}];
    [cpk_origfilterFlag setDictionary:@{@"green":@(YES),@"yellow":@(YES),@"red":@(YES),@"other":@(YES)}];
    [reviewerfilterFlag setDictionary:@{@"green":@(YES),@"yellow":@(YES),@"red":@(YES),@"other":@(YES)}];
    [reviewerKFlag setDictionary:@{@"YES":@(YES),@"NO":@(YES)}];
    [bmfilterFlag setDictionary:@{@"YES":@(YES),@"NO":@(YES),@"other":@(YES)}];
    [unitfilterFlag setDictionary:@{@"green":@(YES),@"yellow":@(YES),@"red":@(YES),@"other":@(YES)}];
    
    
    
    
    filterSourceData=[[NSMutableArray alloc]init];
}
-(void) initFilterBind{
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnExcelFilter:) name:kNotificationFilterMsg object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnClearExcelFilter:) name:kNotificationFilterClearMsg object:nil];
    //
}
- (IBAction)OnClearKSections:(id)sender {
    
    for (int i=0; i < [_KYesIndex count]; i++) {
        if (![_KNoIndex containsObject:_KYesIndex[i]]){
            
            [_KNoIndex addObject:_KYesIndex[i]];
        }
    }
    [_KYesIndex removeAllObjects];
    
    [_KYesIndexItemNames removeAllObjects];
    for (int i=0; i < [_data count]; i++) {
        _data[i][tb_keynote] = @(0);
    }
    
    [self.dataTableView reloadData];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationInHidenFilter object:nil userInfo:nil];
    

    [m_configDictionary setValue:_KYesIndexItemNames forKey:@"KCheckedItemNames"];
    [m_configDictionary setValue:_KYesIndex forKey:@"KCheckedItems"];
    
    [m_configDictionary setValue:_bmcYesIndex forKey:@"KCheckedBMStates"];
    
}
- (IBAction)OnClickClearAllFilter:(id)sender {

    [self OnClearExcelFilter:nil];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationInHidenFilter object:nil userInfo:nil];
    
    
}
- (void)OnClearExcelFilter:(NSNotification *)nf {
    
    [filterStack removeAllObjects];
    [self.searchField setStringValue:@""];
    [self.searchField resetSearchButtonCell];
    
    [searchExceptIndex removeAllObjects];
    [indexfilterRowIndex removeAllObjects];
    [cpk_origfilterRowIndex removeAllObjects];
    [bmfilterRowIndex removeAllObjects];
    [reviewerKIndex removeAllObjects];
    [unitfilterRowIndex removeAllObjects];
    [uslRowIndex removeAllObjects];
    [lslRowIndex removeAllObjects];
    
    [reviewerfilterRowIndex removeAllObjects];

    [self.data setArray:filterSourceData];

    
    [self.dataTableView reloadData];
}
-(void) AddToListWithoutSameItem:(NSMutableArray*)input addList:(NSArray*)add{

    if ([input count] ==0) {
        [input addObjectsFromArray:add];
    }
    else if ([input count] >0 && [add count]>0){
        
        if(![input containsObject:add[0]]){
            
            [input addObjectsFromArray:add];
            
        }
    }
}
-(void) RemoveToListWithoutSameItem:(NSMutableArray*)input rmList:(NSArray*)rm{
//    for (int i=0;i< [rm count]; i++) {
//        if ([input containsObject:rm[i]]) {
//            [input removeObject:rm[i]];
//        }
//    }
    if ([input count] >0 && [rm count]>0){
        
        if([input containsObject:rm[0]]){
            
            [input removeObjectsInArray:rm];
            
        }
    }
}

- (void)OnExcelFilter:(NSNotification *)nf {
    
    //Add search Function Call Same Flash Function
    
    if ([nf userInfo]) {
        //Add
        NSMutableDictionary* infos =   [nf userInfo][@"keys"];
        NSString* identifier =  [nf userInfo][@"identifier"];
        

        
        
        //Add Keys State Back Up
        if ([[filterStack lastObject][@"identifier"] isEqualToString:identifier]) {

            [filterStack removeLastObject];
            
            [filterStack addObject:@{@"identifier":identifier,@"keys":[infos copy]}];
            
            if ([infos allKeysForObject:@(YES)] && [[infos allKeysForObject:@(YES)]  count] == [infos count]) {
                [filterStack removeLastObject];
            }
            
        }else{
           
            [filterStack addObject:@{@"identifier":identifier,@"keys":[infos copy]}];
            
        }
        
        
        //Get data
        NSInteger colindex =[self mappingColumname:identifier];
        
        NSMutableArray* arryData = [[NSMutableArray alloc] init];
        
        if([identifier isEqualTo:identifier_cpk_orig]){
            //[cpk_origfilterRowIndex removeAllObjects];
            
            if ([[infos allKeys] containsObject:@"Red - Cpk < Cpk-LTHL"]) {
                if (infos[@"Red - Cpk < Cpk-LTHL"] == @(NO)) {
                    //[cpk_origfilterRowIndex addObjectsFromArray:cpkOrigRedColorIndex];
                    
                    [self AddToListWithoutSameItem:cpk_origfilterRowIndex addList:cpkOrigRedColorIndex];
                }
                else{
                    
                    //[cpk_origfilterRowIndex removeObjectsInArray:cpkOrigRedColorIndex];
                    [self RemoveToListWithoutSameItem:cpk_origfilterRowIndex rmList:cpkOrigRedColorIndex];
                    
                }
            }else{
                //[cpk_origfilterRowIndex addObjectsFromArray:cpkOrigRedColorIndex];
            }
            
            if ([[infos allKeys] containsObject:@"Yellow - Cpk > Cpk-HTHL"]) {
                if (infos[@"Yellow - Cpk > Cpk-HTHL"] == @(NO)) {
                    //[cpk_origfilterRowIndex addObjectsFromArray:cpkOrigYellowColorIndex];
                    
                    [self AddToListWithoutSameItem:cpk_origfilterRowIndex addList:cpkOrigYellowColorIndex];
                }
                else{
                    //[cpk_origfilterRowIndex removeObjectsInArray:cpkOrigYellowColorIndex];
                    
                    [self RemoveToListWithoutSameItem:cpk_origfilterRowIndex rmList:cpkOrigYellowColorIndex];
                }
            }else{
                //[cpk_origfilterRowIndex addObjectsFromArray:cpkOrigYellowColorIndex];
            }
            
            if ([[infos allKeys] containsObject:@"Green - Cpk-LTHL < CPk < Cpk_HTHL"]) {
                if (infos[@"Green - Cpk-LTHL < CPk < Cpk_HTHL"] == @(NO)) {
                   // [cpk_origfilterRowIndex addObjectsFromArray:cpkOrigGreenColorIndex];
                    
                    [self AddToListWithoutSameItem:cpk_origfilterRowIndex addList:cpkOrigGreenColorIndex];
                }
                else{
                    //[cpk_origfilterRowIndex removeObjectsInArray:cpkOrigGreenColorIndex];
                    
                    [self RemoveToListWithoutSameItem:cpk_origfilterRowIndex rmList:cpkOrigGreenColorIndex];
                }
                
            }else{
                //[cpk_origfilterRowIndex addObjectsFromArray:cpkOrigGreenColorIndex];
            }
            
            if([[infos allKeys] containsObject:@"other"]){
                if (infos[@"other"] == @(NO)) {
                    //[cpk_origfilterRowIndex addObjectsFromArray:cpkOrigOtherColorIndex];
                    
                    [self AddToListWithoutSameItem:cpk_origfilterRowIndex addList:cpkOrigOtherColorIndex];
                }else{
                    //[cpk_origfilterRowIndex removeObjectsInArray:cpkOrigOtherColorIndex];
                    
                    [self RemoveToListWithoutSameItem:cpk_origfilterRowIndex rmList:cpkOrigOtherColorIndex];
                }
            }else{
                //[cpk_origfilterRowIndex addObjectsFromArray:cpkOrigOtherColorIndex];
            }
            
        }
        else if([identifier isEqualTo:identifier_bmc]){
            
            //[bmfilterRowIndex removeAllObjects];
            
            if([[infos allKeys] containsObject:@"YES - Bimodal"]){
                if (infos[@"YES - Bimodal"] == @(NO)) {
                    //[bmfilterRowIndex addObjectsFromArray:_bmcYesIndex];
                    
                    [self AddToListWithoutSameItem:bmfilterRowIndex addList:_bmcYesIndex];
                }
                else{
                    //[bmfilterRowIndex removeObjectsInArray:_bmcYesIndex];
                    
                    
                    [self RemoveToListWithoutSameItem:bmfilterRowIndex rmList:_bmcYesIndex];
                }
            }else{
                //[bmfilterRowIndex addObjectsFromArray:_bmcYesIndex];
            }
            
            if([[infos allKeys] containsObject:@"NO - Not Bimodal"]){
                if (infos[@"NO - Not Bimodal"] ==@(NO)) {
                    //[bmfilterRowIndex addObjectsFromArray:_bmcNoIndex];
                    
                    [self AddToListWithoutSameItem:bmfilterRowIndex addList:_bmcNoIndex];
                    
                }else{
                    //[bmfilterRowIndex removeObjectsInArray:_bmcNoIndex];
                    [self RemoveToListWithoutSameItem:bmfilterRowIndex rmList:_bmcNoIndex];
                }
            }
            else{
                //[bmfilterRowIndex addObjectsFromArray:_bmcNoIndex];
            }
            
            if([[infos allKeys] containsObject:@"other"]){
                if (infos[@"other"] ==@(NO)) {
                    //[bmfilterRowIndex addObjectsFromArray:_bmcOtherIndex];
                    
                    [self AddToListWithoutSameItem:bmfilterRowIndex addList:_bmcOtherIndex];
                    
                }else{
                    //[bmfilterRowIndex removeObjectsInArray:_bmcOtherIndex];
                    
                    [self RemoveToListWithoutSameItem:bmfilterRowIndex rmList:_bmcOtherIndex];
                }
            }else{
                //[bmfilterRowIndex addObjectsFromArray:_bmcOtherIndex];
            }
            
        }
        else if([identifier isEqualTo:identifier_keynote]){
            
            //[bmfilterRowIndex removeAllObjects];
            
            if([[infos allKeys] containsObject:@"Ticked"]){
                if (infos[@"Ticked"] == @(NO)) {
                    [self AddToListWithoutSameItem:reviewerKIndex addList:_KYesIndex];
                }
                else{
                    [self RemoveToListWithoutSameItem:reviewerKIndex rmList:_KYesIndex];
                }
            }else{
            }
            
            if([[infos allKeys] containsObject:@"UnTicked"]){
                if (infos[@"UnTicked"] ==@(NO)) {
                    [self AddToListWithoutSameItem:reviewerKIndex addList:_KNoIndex];
                    
                }else{
                    [self RemoveToListWithoutSameItem:reviewerKIndex rmList:_KNoIndex];
                }
            }
            else{
            }
        }
        else if([identifier isEqualTo:identifier_index]){
            //[indexfilterRowIndex removeAllObjects];
            
            if([[infos allKeys] containsObject:@"Red - Exists in data,but not in script"]){
                if (infos[@"Red - Exists in data,but not in script"] == @(NO)) {
                    //[indexfilterRowIndex addObjectsFromArray:_colorRedIndex];
                    
                    [self AddToListWithoutSameItem:indexfilterRowIndex addList:_colorRedIndex];
                }
                else{
                    //[indexfilterRowIndex removeObjectsInArray:_colorRedIndex];
                    
                    
                    [self RemoveToListWithoutSameItem:indexfilterRowIndex rmList:_colorRedIndex];
                }
            }else{
                //[indexfilterRowIndex addObjectsFromArray:_colorRedIndex];
            }
            if([[infos allKeys] containsObject:@"Green - Match between data and script"]){
                if (infos[@"Green - Match between data and script"] ==@(NO)) {
                    //[indexfilterRowIndex addObjectsFromArray:_colorGreenIndex];
                    
                    [self AddToListWithoutSameItem:indexfilterRowIndex addList:_colorGreenIndex];
                }else{
                    //[indexfilterRowIndex removeObjectsInArray:_colorGreenIndex];
                    
                    [self RemoveToListWithoutSameItem:indexfilterRowIndex rmList:_colorGreenIndex];
                }
            }else{
                //[indexfilterRowIndex addObjectsFromArray:_colorGreenIndex];
            }
            
            
            
            if([[infos allKeys] containsObject:@"Gray - Exists in script,but not in data"]){
                if (infos[@"Gray - Exists in script,but not in data"]==@(NO)) {
                    [self AddToListWithoutSameItem:indexfilterRowIndex addList:_colorGrayIndex];
                    
                }else{
                    
                    [self RemoveToListWithoutSameItem:indexfilterRowIndex rmList:_colorGrayIndex];
                }
            }else{
                //[indexfilterRowIndex addObjectsFromArray:_colorGrayIndex];
            }
            if([[infos allKeys] containsObject:@"other"]){
                if (infos[@"other"]==@(NO)) {
                    
                    //[indexfilterRowIndex addObjectsFromArray:_colorOtherIndex];
                    
                    [self AddToListWithoutSameItem:indexfilterRowIndex addList:_colorOtherIndex];
                }else{
                   // [indexfilterRowIndex removeObjectsInArray:_colorOtherIndex];
                    
                    
                    [self RemoveToListWithoutSameItem:indexfilterRowIndex rmList:_colorOtherIndex];
                }
            }else{
                //[indexfilterRowIndex addObjectsFromArray:_colorOtherIndex];
            }
            
            
        }
        else if([identifier isEqualTo:identifier_unit]){
            
            [unitfilterRowIndex removeAllObjects];
            [unitfilterRowIndex addObjectsFromArray:[infos allKeysForObject:@(NO)] ];
        }
        else if([identifier isEqualTo:identifier_reviewer]){
            
            [reviewerfilterRowIndex removeAllObjects];
            [reviewerfilterRowIndex addObjectsFromArray:[infos allKeysForObject:@(NO)]];
        }
        
        else if([identifier isEqualTo:identifier_lsl]){
            
            [lslRowIndex removeAllObjects];
            [lslRowIndex addObjectsFromArray:[infos allKeysForObject:@(NO)]];
        }
        else if([identifier isEqualTo:identifier_usl]){
            
            [uslRowIndex removeAllObjects];
            [uslRowIndex addObjectsFromArray:[infos allKeysForObject:@(NO)]];
        }
    }
    else{
        // Search in this Way , but do nothing ?
        NSLog(@"nonono");
    }
    
    
    
    NSMutableArray* arryShow = [[NSMutableArray alloc] init];

    for (int i=0; i<[filterSourceData count]; i++) {
        bool isNeed = true;
        int checkIndex = [filterSourceData[i][tb_index] intValue] -1;//show from 1~n , but cal from 0;
        
        for (NSArray* RowArray in allRowIndex) {
            if([RowArray containsObject:@(checkIndex)]){
                isNeed = false;
                break;
            }
        }
        if (isNeed && [unitfilterRowIndex count] >0 ) {
            isNeed = ![unitfilterRowIndex containsObject:filterSourceData[i][tb_measurement_unit]];
        }
        
        if (isNeed && [uslRowIndex count] >0 ) {
            isNeed = ![uslRowIndex containsObject:filterSourceData[i][tb_usl]];
        }
        if (isNeed && [lslRowIndex count] >0 ) {
            isNeed = ![lslRowIndex containsObject:filterSourceData[i][tb_lsl]];
        }
        
        if (isNeed && [reviewerfilterRowIndex count] >0 ) {
            isNeed = ![reviewerfilterRowIndex containsObject:filterSourceData[i][tb_reviewer]];
        }
        
        if (isNeed && [searchExceptIndex count] >0 ) {
            isNeed = ![searchExceptIndex containsObject:@([filterSourceData[i][tb_index] intValue] -1)];
        }
        
        
        
        if(isNeed){
            
            [arryShow addObject:filterSourceData[i]];
        }
    }
    [self.data setArray:arryShow];
    
    [self.dataTableView reloadData];
    //[[self dataTableView] reloadData];
    
    
    
    
    
    
    
    
}


-(instancetype)init
{
    self = [super init];
    if (self)
    {
        //Vito Added filter Function
        [self initFilterBuf];
        
        
        _data = [[NSMutableArray alloc]init];
        _scriptData = [[NSMutableArray alloc]init];
        _limitUpdateData = [[NSMutableArray alloc]init];
        //_dataReverse = [[NSMutableArray alloc]init];
        //_rawData = [[NSMutableArray alloc]init];
        _indexItemNameDic = [[NSMutableDictionary alloc] init];
        _textEditLimitDic = [[NSMutableDictionary alloc] init];
        _ListAllItemNameArr  = [[NSMutableArray alloc]init];
        hash_value = [[NSMutableArray alloc]init];
        enableEditing = YES;
        clickItemIndex = -1;
        editLimitRow = -1;
        retestValue=@"";
        removeValue = @"";
        
        select_btn_x = 0;
        select_btn_y = 0;
        click_item_flag = 0;
        arrSearch = [[NSMutableArray alloc]init];
        arrSearchRed = [[NSMutableArray alloc]init];
        arrSearchGreen = [[NSMutableArray alloc]init];
        
        arrSearchRedCPK = [[NSMutableArray alloc]init];
        arrSearchGreenCPK = [[NSMutableArray alloc]init];
        arrSearchYellowCPK = [[NSMutableArray alloc]init];
        
        _dataBackup = [[NSMutableArray alloc]init];
        n_search = 0;
        n_loadCsvBtn = 0;
        n_sort_col1 = 0;
        n_sort_col5 = 0;
        n_sort_col9 = 0;
        n_sort_col12 = 0;
        _sortDataBackup = [[NSMutableArray alloc]init];
        
        n_Start_Data_Col = -1;
        n_Pass_Fail_Status = -1;
        n_Product_Col =-1;
        n_SerialNumber = -1;
        n_SpecialBuildName_Col = -1;
        n_Special_Build_Descrip_Col =-1;
        n_StationID_Col =-1;
        n_SlotId_Col = -1;
        n_StartTime = -1;
        n_Version_Col =-1;
        n_Diags_Version_Col = -1;
        n_OS_VERSION_Col = -1;
        
        click_tb_row = 0;
        n_reviewer_col = 0;
        n_double_click = 0;
        
        n_firstItemClick = 0;
        n_passdata = 0;
        
        _colorRedIndex = [[NSMutableArray alloc]init];
        _colorGreenIndex = [[NSMutableArray alloc]init];
        _colorGrayIndex =[[NSMutableArray alloc]init];
        _colorOtherIndex =[[NSMutableArray alloc]init];
        
        _colorRedIndexBackup = [[NSMutableArray alloc]init];
        _colorGreenIndexBackup = [[NSMutableArray alloc]init];
        
        _colorRedIndexSearchBackup =[[NSMutableArray alloc]init];
        _colorGreenIndexSearchBackup = [[NSMutableArray alloc]init];
        
        _colorRedIndexCpk = [[NSMutableArray alloc]init];
        _colorGreenIndexCpk = [[NSMutableArray alloc]init];
        _colorYellowIndexCpk = [[NSMutableArray alloc]init];
        
        _colorRedIndexSearchCpk = [[NSMutableArray alloc]init];
        _colorGreenIndexSearchCpk = [[NSMutableArray alloc]init];
        _colorYellowIndexSearchCpk = [[NSMutableArray alloc]init];
        
        _colorRedIndexCpkBackup = [[NSMutableArray alloc]init];
        _colorGreenIndexCpkBackup = [[NSMutableArray alloc]init];
        _colorYellowIndexCpkBackup = [[NSMutableArray alloc]init];
        
        _reviewerNameIndex = [[NSMutableArray alloc]init];
        _bmcYesIndex = [[NSMutableArray alloc]init];
        _bmcNoIndex = [[NSMutableArray alloc]init];
        _bmcOtherIndex = [[NSMutableArray alloc]init];
        
        
        _KYesIndexItemNames =[[NSMutableArray alloc]init];
        _KYesIndex= [[NSMutableArray alloc]init];
        _KNoIndex= [[NSMutableArray alloc]init];
        
        tmpColorArr = [[NSMutableArray alloc]init];
        b_ClearComment = YES;
        b_isCustomCSV = NO;
        
        inputCharacter = [[NSMutableString alloc] init];
        n_clickApplyRow = -1;
        
        dicMouseFunc = [[NSMutableDictionary alloc] init];
        dicHeaderName = [[NSMutableDictionary alloc] init];
        dicHelpInfo = [[NSMutableDictionary alloc] init];
        helpInfo_name = @[@"helpInfo_index",@"",@"helpInfo_low",@"helpInfo_upper",@"",@"helpInfo_cpk_orig",@"helpInfo_lsl",@"helpInfo_usl",
                              @"helpInfo_apply",@"helpInfo_cpk_new",@"helpInfo_comment",@"helpInfo_reviewer",@"helpInfo_date",@"helpInfo_bmc",
                              @"helpInfo_keynote",@"helpInfo_command",@"helpInfo_description"];
        
        n_loadStepCount = 0.0;
    }
    return self;
}

- (void)viewDidLoad
{
    //Added By Vito 20210308
    for (int i=0; i< [[_dataTableView tableColumns] count]; i++) {
        if([[[_dataTableView tableColumns][i] identifier] isEqualToString:identifier_bmc] ||
           [[[_dataTableView tableColumns][i] identifier] isEqualToString:identifier_index] ||
           [[[_dataTableView tableColumns][i] identifier] isEqualToString:identifier_reviewer] ||
           [[[_dataTableView tableColumns][i] identifier] isEqualToString:identifier_unit] ||
           [[[_dataTableView tableColumns][i] identifier] isEqualToString:identifier_cpk_orig]||
           [[[_dataTableView tableColumns][i] identifier] isEqualToString:identifier_lsl] ||
           [[[_dataTableView tableColumns][i] identifier] isEqualToString:identifier_usl] ||
           [[[_dataTableView tableColumns][i] identifier] isEqualToString:identifier_keynote]
           )
        [self.dataTableView setIndicatorImage:[NSImage imageNamed : @ "sort.png" ] inTableColumn:[_dataTableView tableColumns][i]];
//        NSTableHeaderCell * item =colHeaders[i];
//        [item setImage:[NSImage imageNamed : @ "sort.png" ]] ;
    }
    
    //
    
    [_dataTableView setDelegate:self];
    [_dataTableView setDataSource:self];
    
    [self.dataTableView reloadData];
    
    [self.dataTableView setTarget:self];
    [self.dataTableView setDoubleAction:@selector(DblClickOnTableViewDouble:)];
    [self.dataTableView setAction:@selector(DblClickOnTableView:)];
    
    [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskKeyDown handler:^NSEvent * _Nullable(NSEvent * _Nonnull aEvent) {
    [self keyDown:aEvent];
    return aEvent;
    }];
    
    desktopPath = [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSString *logPath = [NSString stringWithFormat:@"%@/CPK_Log",desktopPath];
    [self createFileDirectories:logPath];
    
    NSString *logPath2 = @"/tmp/CPK_Log";
    [self createFileDirectories:logPath2];
    NSString *failPlot = [NSString stringWithFormat:@"%@/fail_plot",logPath2];
    [self createFileDirectories:failPlot];
    NSString *retestPlot = [NSString stringWithFormat:@"%@/retest",logPath2];
    [self createFileDirectories:retestPlot];
    NSString *plot = [NSString stringWithFormat:@"%@/plot",logPath2];
    [self createFileDirectories:plot];
    NSString *temp = [NSString stringWithFormat:@"%@/temp",logPath2];
    [self createFileDirectories:temp];
    
    [@"none" writeToFile:[NSString stringWithFormat:@"%@/temp/.logcpk.txt",logPath2] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [@"none" writeToFile:[NSString stringWithFormat:@"%@/temp/.logcor.txt",logPath2] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [@"none" writeToFile:[NSString stringWithFormat:@"%@/temp/.logscatter.txt",logPath2] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [@"none" writeToFile:[NSString stringWithFormat:@"%@/temp/.logcalc.txt",logPath2] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [@"none" writeToFile:[NSString stringWithFormat:@"%@/temp/.logretest.txt",logPath2] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [@"none" writeToFile:[NSString stringWithFormat:@"%@/temp/.excel.txt",logPath2] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [@"none" writeToFile:[NSString stringWithFormat:@"%@/temp/.excel_hash.txt",logPath2] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [@"none" writeToFile:[NSString stringWithFormat:@"%@/temp/.keynote.txt",logPath2] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [@"none" writeToFile:[NSString stringWithFormat:@"%@/temp/.reporttags.txt",logPath2] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [@"" writeToFile:[NSString stringWithFormat:@"%@/temp/.recordSelctItem.csv",logPath2] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [@"" writeToFile:[NSString stringWithFormat:@"%@/temp/.cpknew.txt",logPath2] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    [@"" writeToFile:[NSString stringWithFormat:@"%@/retest/.retest_plot.txt",logPath2] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *nonpicPath =[[NSBundle mainBundle]pathForResource:@"none_pic.png" ofType:nil];
    [manager copyItemAtPath:nonpicPath toPath:@"/tmp/CPK_Log/retest/.none_pic.png" error:nil];
    NSString *appl_picPath =[[NSBundle mainBundle]pathForResource:@"apple_log_black.png" ofType:nil];
    [manager copyItemAtPath:appl_picPath toPath:@"/tmp/CPK_Log/retest/.apple_log_black.png" error:nil];
    
   // [@"none" writeToFile:[NSString stringWithFormat:@"%@/CPK_Log/temp/.logparam.txt",desktopPath] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    [self.txtcsvDataName setStringValue:@""];
    [self.txtScriptName setStringValue:@""];
    [self.txtLimitUpdate setStringValue:@""];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(settingTableViewData:) name:kNotificationSetColorByLeft object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(settingTableViewData:) name:kNotificationSetColorByRight object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(settingTableViewData:) name:kNotificationSelectX object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(settingTableViewData:) name:kNotificationSelectY object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(settingTableViewData:) name:kNotificationSetParameters object:nil];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(settingTableViewData:) name:kNotificationSaveUIdata object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(settingTableViewData:) name:kNotificationSetCpkNew object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(toLoadCsv:) name:kNotificationToLoadCsv object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(toLoadLocalCsv:) name:kNotificationToLocalLoadCsv object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(clickOneItem:) name:kNotificationClickOneItem object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(forMouseEnter:) name:kNotificationMouseEnter object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(forMouseEnter:) name:kNotificationMouseExit object:nil];
    
    //Added By Vito 20210302
    [self initFilterBind];
    //Add end
    
    

    _lastLeftPaneWidth = self.leftPane.frame.size.width;
    csvView = [[csvListController alloc]init];
    [self LoadSubView:csvView.view];
    [self.splitView setPosition:0 ofDividerAtIndex:0];
    
    startPython = [[StartUp alloc] init];
    
    [self addMouseFuc];
    
    [m_configDictionary setValue:@[@[]] forKey:KrawDataTmp];
    
}

-(void)addMouseFuc
{
    NSArray *helpInfo = @[helpInfo_index,@"",helpInfo_low,helpInfo_upper,@"",helpInfo_cpk_orig,helpInfo_lsl,helpInfo_usl,
                          helpInfo_apply,helpInfo_cpk_new,helpInfo_comment,helpInfo_reviewer,helpInfo_date,helpInfo_bmc,
                          helpInfo_keynote,helpInfo_command,helpInfo_description,helpInfo_Report_tags];
    
    for (int col = 0; col<[helpInfo_name count]; col ++)
    {
        if ([helpInfo_name[col] isNotEqualTo:@""])
        {
            NSString *col_identifier = [[[self.dataTableView tableColumns] objectAtIndex:col] identifier];
            SCMouseFunction *viewHeader = [[SCMouseFunction alloc] initWithID:col_identifier];
            [dicMouseFunc setObject:viewHeader forKey:col_identifier];
            NSRect rect = [self.tbViewHeader headerRectOfColumn:col];
            [dicHeaderName setObject:[NSValue valueWithRect:rect] forKey:col_identifier];
            [viewHeader setFrame:rect];
            [self.tbViewHeader addSubview:viewHeader];
            [dicHelpInfo setValue:helpInfo[col] forKey:col_identifier];
        }
    }
}

-(void)awakeFromNib
{
    [self.splitView setPosition:0 ofDividerAtIndex:0];
}
-(void)settingTableViewData:(NSNotification *)nf
{
    NSString * name = [nf name];   // set color by choose
    if ([ name isEqualToString:kNotificationSetColorByLeft])
    {
        NSDictionary* info = [nf userInfo];
        int colorIndex = [[info valueForKey:select_Color_Box_left] intValue];
        NSInteger row = [self.dataTableView selectedRow];
        if (row>=0)
        {
            _data[row][tb_color_by_left]=[NSNumber numberWithInt:colorIndex];
        }
    }
    else if ([ name isEqualToString:kNotificationSetColorByRight])
    {
        NSDictionary* info = [nf userInfo];
        int colorIndex = [[info valueForKey:select_Color_Box_Right] intValue];
        NSInteger row = [self.dataTableView selectedRow];
        if (row>=0)
        {
            _data[row][tb_color_by_right]=[NSNumber numberWithInt:colorIndex];
        }
        
    }
    else if ([ name isEqualToString:kNotificationSelectX])
    {
        NSDictionary* info = [nf userInfo];
        int x = [[info valueForKey:btn_select_x] intValue];
        NSInteger row = [self.dataTableView selectedRow];
        if (row>=0)
        {
            _data[row][button_select_x]=[NSNumber numberWithInt:x];
            n_firstItemClick = 1;
            [self triggerGeneratePlot:row withApplyBox:YES withSelectXY:1];
            
        }
        
        //add recore select item for correlation
        
        
    }
    else if ([ name isEqualToString:kNotificationSetCpkNew])
    {
        NSDictionary* info = [nf userInfo];
        NSString * ret = [info valueForKey:cpkNewNumber];
        if (n_clickApplyRow>=0)
        {
            _data[n_clickApplyRow][tb_cpk_new] =ret;
            
            int n_i = 0;
            for (n_i=0; n_i<[[self.dataTableView tableColumns] count]; n_i++)
            {
                if ([[[[self.dataTableView tableColumns] objectAtIndex:n_i] identifier] isEqualTo:identifier_cpknew]) {
                    break;
                }
            }
            [self.dataTableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:n_clickApplyRow] columnIndexes:[NSIndexSet indexSetWithIndex:n_i]];
            n_clickApplyRow = -1;
        }
        
        
    }
    else if ([ name isEqualToString:kNotificationSelectY])
    {
        NSDictionary* info = [nf userInfo];
        int y = [[info valueForKey:btn_select_y] intValue];
        NSInteger row = [self.dataTableView selectedRow];
        if (row>=0)
        {
            _data[row][button_select_y]=[NSNumber numberWithInt:y];
             n_firstItemClick = 1;
             [self triggerGeneratePlot:row withApplyBox:YES withSelectXY:10];
        }
        //add recore select item for correlation
        
    }
    else if ([ name isEqualToString:kNotificationSaveUIdata])
    {
        
        //NSMutableArray *csvData = [NSMutableArray arrayWithArray:[self reverseArray:_data]];
        NSMutableString *strCsv = [NSMutableString string];
        [strCsv appendString:@"index,item,low,upper,new_lsl,new_usl,apply\n"];

        for(NSMutableArray *lineArray in _data)
        {
            NSString *arrString = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@\n",lineArray[0],lineArray[1],lineArray[5],lineArray[4],lineArray[7],lineArray[8],lineArray[9]];
            
            [strCsv appendString:arrString];
        }
       
        NSString *csv_Path = @"/tmp/CPK_Log/temp/item_limit.csv";//[NSString stringWithFormat:@"%@/CPK_Log/temp/item_limit.csv",desktopPath];
        [strCsv writeToFile:csv_Path atomically:YES encoding:NSUTF8StringEncoding error:nil];
       
        
    }
    else if ([ name isEqualToString:kNotificationRetestRate])
    {
       /* @try
        {
            NSFileManager *fh_csv = [NSFileManager defaultManager];
            NSString *pathRate = [NSString stringWithFormat:@"%@/CPK_Log/temp/yield_rate_param.csv",desktopPath];
            NSData *data = [fh_csv contentsAtPath:pathRate];
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSArray *line = [str componentsSeparatedByString:@"\n"];
            NSLog(@"--->yield_rate_param %@",line[1]);
            
            if ([line count]>1)
            {
                NSArray *lineArr = [line[1] componentsSeparatedByString:@","];
                //test_count,fail_count,pass_count,retest_count,retest_rate,yield_percentage
                [self.txtTestCount setStringValue:lineArr[0]];
                [self.txtPass setStringValue:lineArr[2]];
                [self.txtFail setStringValue:lineArr[1]];
                [self.txtYieldP setStringValue:lineArr[5]];
                [self.txtRetestR setStringValue:lineArr[4]];
                [self.txtRetestC setStringValue:lineArr[3]];
                [self.txtTotalC setStringValue:lineArr[6]];

            }
            
            
        }
        @catch (NSException *exception)
        {
            NSLog(@"-----update yiled retest faile");
        }
        */
        
    }
     else if ([ name isEqualToString:kNotificationSetParameters])
     {
          @try {
              [_KYesIndexItemNames removeAllObjects];
              [_KYesIndex removeAllObjects];
              [_KNoIndex removeAllObjects];
              
              [_bmcYesIndex removeAllObjects];
              [_bmcNoIndex removeAllObjects];
              [_bmcOtherIndex removeAllObjects];
              
              [cpkOrigRedColorIndex removeAllObjects];
              [cpkOrigYellowColorIndex removeAllObjects];
              [cpkOrigGreenColorIndex removeAllObjects];
              [cpkOrigOtherColorIndex removeAllObjects];
              //
//              for (int j = 0; j< [_data count]; j++)
//              {
//
//                  if ([_data[j][tb_bmc] containsString:@"YES"])
//                  {
//                      [_bmcYesIndex addObject:[NSNumber numberWithInt:j]];
//                  }else if ([_data[j][tb_bmc] containsString:@"NO"])
//                  {
//                      [_bmcNoIndex addObject:[NSNumber numberWithInt:j]];
//                  }
//                  else{
//
//                      [_bmcOtherIndex addObject:[NSNumber numberWithInt:j]];
//                  }
//                  [self setCpkOrigColor:_data[j][tb_cpk_orig] withRow:j];
//
//              }
//              [self.dataTableView reloadData];
              //
              

             NSDictionary* info = [nf userInfo];
             NSString *path = [info valueForKey:paramPath];
             //NSLog(@"======>>>>>>:%@",path);
             NSFileManager *fh_csv = [NSFileManager defaultManager];
             NSData *data = [fh_csv contentsAtPath:path];
             NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             NSArray *line = [str componentsSeparatedByString:@"\n"];
             for (int i = 1; i< [line count]; i++)
            {
                NSArray *lineArr = [line[i] componentsSeparatedByString:@","];
                //NSLog(@"=====> count: %zd",[lineArr count]);
                if ([lineArr count]>7)
                {
                    for (int j = 0; j< [_ListAllItemNameArr count]; j++)
                    {
                        if ([_ListAllItemNameArr[j] isEqualToString:lineArr[0]])
                        {
                            
                            _data[j][tb_cpk_orig] =lineArr[6] ;
                            _data[j][tb_bmc] =lineArr[7] ;
                            if ([lineArr[7] containsString:@"YES"])
                            {
                                [_bmcYesIndex addObject:[NSNumber numberWithInt:j]];
                            }else if ([lineArr[7] containsString:@"NO"])
                            {
                                [_bmcNoIndex addObject:[NSNumber numberWithInt:j]];
                            }
                            else{

                                [_bmcOtherIndex addObject:[NSNumber numberWithInt:j]];
                            }
                            [self setCpkOrigColor:lineArr[6] withRow:j];
                            break;
                        }
                    }
                }
            }
            [m_configDictionary setValue:_bmcYesIndex forKey:@"KCheckedBMStates"];
            for (int i=0; i< [_data count]; i++) {
                if (!([_bmcOtherIndex containsObject:@(i) ] || [_bmcYesIndex containsObject:@(i) ] || [_bmcNoIndex containsObject:@(i) ])) {
                    //
                    [_bmcOtherIndex addObject:@(i)];
                }
                if (!([cpkOrigRedColorIndex containsObject:@(i) ] || [cpkOrigYellowColorIndex containsObject:@(i) ] || [cpkOrigGreenColorIndex containsObject:@(i) ] || [cpkOrigOtherColorIndex containsObject:@(i) ])) {
                    //
                    [cpkOrigOtherColorIndex addObject:@(i)];
                }
                [_KNoIndex addObject:@(i)];
            }
             
            //NSLog(@"--_colorRedIndexCpk:%@, _colorGreenIndexCpk:%@",_colorRedIndexCpk,_colorGreenIndexCpk);
            [self.dataTableView reloadData];
              
        }
         @catch (NSException *exception)
         {
             NSLog(@"-----update 3CV,a_q,a_irr error");
         }
          
         
     }
    
    
}

//-(void)readParameterCsv:(NSString *)path
//{
//       NSFileManager *fh_csv = [NSFileManager defaultManager];
//       NSData *data = [fh_csv contentsAtPath:path];
//       NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//       NSArray *line = [str componentsSeparatedByString:@"\n"];
//
//
//       for (int i = 0; i< [line count]; i++)
//       {
//           NSArray *lineArr = [line[i] componentsSeparatedByString:@","];
//           NSString * finnalStr=[line[i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//
//       }
//}


-(void)setCpkOrigColor:(NSString *)value withRow:(int)row
{
    float cpkL = [[m_configDictionary valueForKey:cpk_Lowthl] floatValue];
    float cpkH = [[m_configDictionary valueForKey:cpk_Highthl] floatValue];
    if ([self isPureFloat:value]|| [self isPureInt:value])
    {
        if ([value floatValue]<cpkL)
        {
            [cpkOrigRedColorIndex addObject:[NSNumber numberWithInt:row]];
            [_colorRedIndexCpk addObject:[NSNumber numberWithInt:row]];
            [_colorRedIndexCpkBackup addObject:[NSNumber numberWithInt:row]];
        }
        else if([value floatValue] >cpkH)
        {
             [cpkOrigYellowColorIndex addObject:[NSNumber numberWithInt:row]];
             [_colorYellowIndexCpk addObject:[NSNumber numberWithInt:row]];
             [_colorYellowIndexCpkBackup addObject:[NSNumber numberWithInt:row]];
        }
        else
        {
            [cpkOrigGreenColorIndex addObject:[NSNumber numberWithInt:row]];
            [_colorGreenIndexCpk addObject:[NSNumber numberWithInt:row]];
            [_colorGreenIndexCpkBackup addObject:[NSNumber numberWithInt:row]];
        }
        
    }
    else
    {
        [cpkOrigOtherColorIndex addObject:[NSNumber numberWithInt:row]];
    }
}

- (void)createFileDirectories:(NSString *)folderPath
{
    // 判断文件夹是否存在，不存在则创建对应文件夹
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExist = [fileManager fileExistsAtPath:folderPath];
    if (isExist)
    {
        //NSLog(@"目录已经存在");
    }
    else
    {
        BOOL ret = [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
        if (ret)
        {
           // NSLog(@"目录创建成功");
            
        }
        else
        {
            NSLog(@"目录创建失败");
            return;
        }
    }
}


-(IBAction)DblClickOnTableViewDouble:(id)sender
{
    if ([_dataReverse count]<1)
    {
        return;
    }
    
    NSInteger row = [self.dataTableView selectedRow];
    if (row == -1)
    {
        return;
    }

    n_double_click = row;
    [self.dataTableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:row] columnIndexes:[NSIndexSet indexSetWithIndex:1]];

    

}


-(IBAction)DblClickOnTableView:(id)sender
{
    if ([_dataReverse count]<1)
    {
        [self closePopoverMsg];
        return;
    }
    
    [m_configDictionary setValue:[NSNumber numberWithBool:NO] forKey:kInputRangeFlag];
    NSInteger row = [self.dataTableView selectedRow];
    
    if (row == -1)
    {
        //added by Vito 20210302
        //do filter function
        
        [self closePopoverMsg];
        NSInteger col = [self.dataTableView selectedColumn];

        if (col==-1)
        {
            return;
        }
        
        NSString *col_identifier = [[[self.dataTableView tableColumns] objectAtIndex:col] identifier];
        NSLog(@">>click select row: %zd ,double_click %zd , col_identifier: %@",row,col,col_identifier);
        
        //Check Use Stack Data Or Use _data
        if ([[filterStack lastObject][@"identifier"] isEqualToString:col_identifier]) {
            //do nothing
            [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationInShowFilter object:nil userInfo:@{@"identifier":col_identifier,@"keys":[filterStack lastObject][@"keys"] }];
        }
        else if([filterStack count] ==0) {
            
            
            NSMutableDictionary* dataKeys = [self mappingFilterArray:col_identifier];
            
            if ([col_identifier isEqualToString:identifier_unit]) {
                [dataKeys removeAllObjects];
                for (int i =0; i<[filterSourceData count]; i++) {
                    [dataKeys setValue:@(YES) forKey:filterSourceData[i][tb_measurement_unit]];
                }
                
            }
            else if([col_identifier isEqualToString:identifier_usl]){
                [dataKeys removeAllObjects];
                for (int i =0; i<[filterSourceData count]; i++) {
                    [dataKeys setValue:@(YES) forKey:filterSourceData[i][tb_usl]];
                }
            }
            else if([col_identifier isEqualToString:identifier_lsl]){
                [dataKeys removeAllObjects];
                for (int i =0; i<[filterSourceData count]; i++) {
                    [dataKeys setValue:@(YES) forKey:filterSourceData[i][tb_lsl]];
                }
            }
            else if([col_identifier isEqualToString:identifier_reviewer]){
                [dataKeys removeAllObjects];
                for (int i =0; i<[filterSourceData count]; i++) {
                    [dataKeys setValue:@(YES) forKey:filterSourceData[i][tb_reviewer]];
                }
            }
            else if([col_identifier isEqualToString:identifier_cpk_orig]){
                [dataKeys removeAllObjects];
                if([cpkOrigRedColorIndex count] > 0){
                    [dataKeys setValue:@(YES) forKey:@"Red - Cpk < Cpk-LTHL"];
                }
                if([cpkOrigGreenColorIndex count] > 0) {
                    [dataKeys setValue:@(YES) forKey:@"Green - Cpk-LTHL < CPk < Cpk_HTHL"];
                }
                if([cpkOrigYellowColorIndex count] > 0){
                    [dataKeys setValue:@(YES) forKey:@"Yellow - Cpk > Cpk-HTHL"];
                }
                if([cpkOrigOtherColorIndex count] > 0){
                    [dataKeys setValue:@(YES) forKey:@"other"];
                }
            }
            else if([col_identifier isEqualToString:identifier_index]){
                [dataKeys removeAllObjects];
                
                if ([_colorOtherIndex count] != [filterSourceData count] - [_colorRedIndex count] - [_colorGreenIndex count] - [_colorGrayIndex count]) {
                    _colorOtherIndex = [NSMutableArray arrayWithCapacity:[filterSourceData count]];
                    for (int j=0; j<[filterSourceData count]; j++) {
                        if (!([_colorGrayIndex containsObject:@(j)] ||[_colorRedIndex containsObject:@(j)] || [_colorGreenIndex containsObject:@(j)])) {
                            [_colorOtherIndex addObject:@(j)];
                        }

                    }
                }
                if([_colorRedIndex count] > 0){
                    [dataKeys setValue:@(YES) forKey:@"Red - Exists in data,but not in script"];
                }
                if([_colorGreenIndex count] > 0) {
                    [dataKeys setValue:@(YES) forKey:@"Green - Match between data and script"];
                }
               
                if([_colorGrayIndex count] > 0){
                    [dataKeys setValue:@(YES) forKey:@"Gray - Exists in script,but not in data"];
                }
                if([_colorOtherIndex count] > 0){
                    [dataKeys setValue:@(YES) forKey:@"other"];
                }
            }
            else if([col_identifier isEqualToString:identifier_bmc]){
                [dataKeys removeAllObjects];
                if([_bmcYesIndex count] > 0){
                    [dataKeys setValue:@(YES) forKey:@"YES - Bimodal"];
                }
                if([_bmcNoIndex count] > 0) {
                    [dataKeys setValue:@(YES) forKey:@"NO - Not Bimodal"];
                }
                if([_bmcOtherIndex count] > 0){
                    [dataKeys setValue:@(YES) forKey:@"other"];
                }
            }
            else if([col_identifier isEqualToString:identifier_keynote]){
                [dataKeys removeAllObjects];
                if([_KYesIndex count] > 0){
                    [dataKeys setValue:@(YES) forKey:@"Ticked"];
                }
                if([_KNoIndex count] > 0) {
                    [dataKeys setValue:@(YES) forKey:@"UnTicked"];
                }
            }
            
            
            //[filterStack addObject:@{@"identifier":col_identifier,@"lastKeyList":[dataKeys copy]}];
            
 
            [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationInShowFilter object:nil userInfo:@{@"identifier":col_identifier,@"keys":dataKeys }];
        
            
        }
        else if([filterStack count] > 0){
            
            NSMutableDictionary* dataKeys = [self mappingFilterArray:col_identifier];
            
            if ([col_identifier isEqualToString:identifier_unit]) {
                [dataKeys removeAllObjects];
                for (int i =0; i<[_data count]; i++) {
                    [dataKeys setValue:@(YES) forKey:_data[i][tb_measurement_unit]];
                }
            }
            else if([col_identifier isEqualToString:identifier_usl]){
                [dataKeys removeAllObjects];
                for (int i =0; i<[_data count]; i++) {
                    [dataKeys setValue:@(YES) forKey:_data[i][tb_usl]];
                }
            }
            else if([col_identifier isEqualToString:identifier_lsl]){
                [dataKeys removeAllObjects];
                for (int i =0; i<[_data count]; i++) {
                    [dataKeys setValue:@(YES) forKey:_data[i][tb_lsl]];
                }
            }
            else if([col_identifier isEqualToString:identifier_reviewer]){
                [dataKeys removeAllObjects];
                for (int i =0; i<[_data count]; i++) {
                    [dataKeys setValue:@(YES) forKey:_data[i][tb_reviewer]];
                }
            }
            else if([col_identifier isEqualToString:identifier_cpk_orig]){
                [dataKeys removeAllObjects];
                
                BOOL isRed = NO;
                BOOL isGreen = NO;
                BOOL isYellow = NO;
                BOOL isOther = NO;
                
                
                
                for (int i =0; i<[_data count]; i++) {
                    NSInteger index = [_data[i][tb_index] intValue] -1;
                    if(isRed == NO and [cpkOrigRedColorIndex containsObject:@(index) ]){
                        isRed = YES;
                        [dataKeys setValue: @(YES) forKey:@"Red - Cpk < Cpk-LTHL"];
                    }
                    if(isGreen == NO and [cpkOrigGreenColorIndex containsObject:@(index)]){
                        isGreen = YES;
                        [dataKeys setValue: @(YES)  forKey:@"Green - Cpk-LTHL < CPk < Cpk_HTHL"];
                    }
                    if(isYellow == NO and [cpkOrigYellowColorIndex containsObject:@(index)]){
                        isYellow = YES;
                        [dataKeys setValue: @(YES)  forKey:@"Yellow - Cpk > Cpk-HTHL"];
                    }
                    if(isOther == NO and [cpkOrigOtherColorIndex containsObject:@(index)]){
                        isOther = YES;
                        [dataKeys setValue: @(YES)  forKey:@"other"];
                    }
                    if (isRed==YES && isGreen==YES && isYellow==YES && isOther==YES ) {
                        break;
                    }
                }
                
            }
            else if([col_identifier isEqualToString:identifier_index]){
                [dataKeys removeAllObjects];
                
                BOOL isRed = NO;
                BOOL isGreen = NO;
                BOOL isGray = NO;
                BOOL isOther = NO;
                
                for (int i =0; i<[_data count]; i++) {
                    NSInteger index = [_data[i][tb_index] intValue] -1;
                    if(isRed == NO and [_colorRedIndex containsObject:@(index)]){
                        isRed = YES;
                        [dataKeys setValue: @(YES) forKey:@"Red - Exists in data,but not in script"];
                    }
                    if(isGreen == NO and [_colorGreenIndex containsObject:@(index)]){
                        isGreen = YES;
                        [dataKeys setValue: @(YES)  forKey:@"Green - Match between data and script"];
                    }
                    if(isGray == NO and [_colorGrayIndex containsObject:@(index)]){
                        isGray = YES;
                        [dataKeys setValue: @(YES)  forKey:@"Gray - Exists in script,but not in data"];
                    }
                    if(isOther == NO and [_colorOtherIndex containsObject:@(index)]){
                        isOther = YES;
                        [dataKeys setValue: @(YES)  forKey:@"other"];
                    }
                    if (isRed==YES && isGreen==YES  && isGray==YES && isOther==YES ) {
                        break;
                    }
                }
            }
            else if([col_identifier isEqualToString:identifier_keynote]){
                
                [dataKeys removeAllObjects];
                
                BOOL isYes = NO;
                BOOL isNo = NO;
                
                for (int i =0; i<[_data count]; i++) {
                    NSInteger index = [_data[i][tb_index] intValue] -1;
                    if(isYes == NO and [_KYesIndex containsObject:@(index)]){
                        isYes = YES;
                        [dataKeys setValue: @(YES) forKey:@"Ticked"];
                    }
                    if(isNo == NO and [_KNoIndex containsObject:@(index)]){
                        isNo = YES;
                        [dataKeys setValue: @(YES)  forKey:@"Unticked"];
                    }
                    if (isYes==YES && isNo==YES   ) {
                        break;
                    }
                }
                
            }
            else if([col_identifier isEqualToString:identifier_bmc]){
                
                [dataKeys removeAllObjects];
                
                BOOL isYes = NO;
                BOOL isNo = NO;
                BOOL isOther = NO;
                
                for (int i =0; i<[_data count]; i++) {
                    NSInteger index = [_data[i][tb_index] intValue] -1;
                    if(isYes == NO and [_bmcYesIndex containsObject:@(index)]){
                        isYes = YES;
                        [dataKeys setValue: @(YES) forKey:@"YES - Bimodal"];
                    }
                    if(isNo == NO and [_bmcNoIndex containsObject:@(index)]){
                        isNo = YES;
                        [dataKeys setValue: @(YES)  forKey:@"NO - Not Bimodal"];
                    }
                    if(isOther == NO and [_bmcOtherIndex containsObject:@(index)]){
                        isOther = YES;
                        [dataKeys setValue: @(YES)  forKey:@"other"];
                    }
                    if (isYes==YES && isNo==YES  && isOther==YES ) {
                        break;
                    }
                }
                
            }
            [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationInShowFilter object:nil userInfo:@{@"identifier":col_identifier,@"keys":dataKeys }];
            
            
        }
        
    }
    else{
        // do generate plot cmd
        click_tb_row = row;
        [self triggerGeneratePlot:row withApplyBox:NO withSelectXY:-1];
        return;
    }
    


}


-(NSString *)opensslSha1:(NSString *)inputStr
{
    unsigned char digest[SHA_DIGEST_LENGTH];
    const char* string = [inputStr UTF8String];
    SHA_CTX ctx;
    SHA1_Init(&ctx);
    SHA1_Update(&ctx, string, strlen(string));
    SHA1_Final(digest, &ctx);
    char mdString[SHA_DIGEST_LENGTH*2+1];
    for (int i = 0; i < SHA_DIGEST_LENGTH; i++)
    sprintf(&mdString[i*2], "%02x", (unsigned int)digest[i]);
    NSString * hashCode = [NSString stringWithFormat:@"%s",mdString];
    return hashCode;
}

-(NSString *)opensslSha1FilePath:(NSString *)path
{
    if (path)
    {
        FILE* file = fopen([path UTF8String], "rb");
        SHA_CTX c;
        unsigned char md[SHA_DIGEST_LENGTH];
        int fd;
        ssize_t i;
        unsigned char buf[BUFSIZE];
        fd=fileno(file);
        SHA1_Init(&c);
        for (;;)
        {
            i=read(fd,buf,BUFSIZE);
            if (i <= 0) break;
            SHA1_Update(&c,buf,(unsigned long)i);
        }
        SHA1_Final(&(md[0]),&c);
        char mdString[SHA_DIGEST_LENGTH*2+1];
        for (i=0; i<SHA_DIGEST_LENGTH; i++)
            sprintf(&mdString[i*2], "%02x", (unsigned int)md[i]);
        NSString * hashCode = [NSString stringWithFormat:@"%s",mdString];
           return hashCode;
    }
    else
    {
        return @"123456789ABCDEFGH";
    }
}
-(void)clickOneItem:(NSNotification *)nf
{
    [self triggerGeneratePlot:click_tb_row withApplyBox:YES withSelectXY:-1];
}

-(void)forMouseEnter:(NSNotification *)nf
{
    NSString * name = [nf name];
    if ([ name isEqualToString:kNotificationMouseEnter])
    {
        NSDictionary* info = [nf userInfo];
        //float x = [[info valueForKey:ktbHeaderX] floatValue];
        //float y = [[info valueForKey:ktbHeaderY] floatValue];
        NSString * myId = [info valueForKey:ktbHeaderID];
        if ([myId isEqualToString: kReport_tags])
        {
            return;
        }
        
        [NSPopover showRelativeToRect:[[dicHeaderName valueForKey:myId] rectValue]
                               ofView:[self.tbViewHeader superview]
                        preferredEdge:NSMaxYEdge
                               string:[dicHelpInfo valueForKey:myId]
                             maxWidth:200.0];
        
    }
    if ([ name isEqualToString:kNotificationMouseExit])
    {
        NSDictionary* info = [nf userInfo];
        NSString * myId = [info valueForKey:ktbHeaderID];
        if ([myId isEqualToString: kReport_tags])
        {
            return;
        }
        
        [self closePopoverMsg];
    }
}

- (void)closePopoverMsg
{
    [NSPopover closeRelativeToRect:[self.tbViewHeader headerRectOfColumn:0]
                           ofView:[self.tbViewHeader superview]
                    preferredEdge:NSMaxYEdge
                           string:@""
                         maxWidth:0.0];
    
    //[self.tbViewHeader subviews];
    
    
}

-(BOOL)triggerGeneratePlot:(NSInteger)rowtb withApplyBox:(BOOL)ApplyBoxflag withSelectXY:(int)xy
{
    NSInteger row = 0;
    for (NSInteger i= 0; i<[_ListAllItemNameArr count]; i++)  //当UI 选择search 的时候，数据变了，row 也变了，要找到对应值
    {
        if ([_ListAllItemNameArr[i] isEqualToString:_data[rowtb][1]])
        {
            row = i;
            break;
        }
    }
    
    tbDataTableSelectItemRow = row;
    NSString *retest = [m_configDictionary valueForKey:kRetestSeg];
    NSString *removeFail = [m_configDictionary valueForKey:kRemoveFailSeg];
    NSString *bins = [m_configDictionary valueForKey:kBins];
    NSString *typeZoom = [m_configDictionary valueForKey:kzoom_type];
    
    //NSLog(@"==>row:%zd   %@  %@  bin:%@ zoom type: %@ ",row,retest,removeFail,bins,typeZoom);
    _data[rowtb][tb_color_by_left]= [NSNumber numberWithInteger:selectColorBoxIndex];  //设置color By左边那个,给python生成图表用
    _data[rowtb][tb_color_by_right]= [NSNumber numberWithInteger:selectColorBoxIndex2];  //设置color By左边那个,给python生成图表用
    //NSLog(@"---->select color by1: %d  by2: %d",selectColorBoxIndex,selectColorBoxIndex2);
    _data[rowtb][tb_bins] = bins;
    _data[rowtb][tb_zoom_type] = typeZoom;

    if (clickItemIndex!=row|| [retestValue isNotEqualTo:retest] || [removeValue isNotEqualTo:removeFail]||ApplyBoxflag)
    {
        clickItemIndex = row;
        retestValue = retest;
        removeValue = removeFail;
        if (selectColorBoxIndex == 0 && selectColorBoxIndex2 == 0)  //color by box 关闭
        {
            NSString *choose_item_name = [_indexItemNameDic valueForKey:[NSString stringWithFormat:@"%zd",row]];
            NSString * itemName = [self combineItemName:choose_item_name];
            //NSLog(@"--ClickOnTableView--:%zd  selectColorBoxIndex:%d, selectColorBoxIndex2:%d,item name : %@",row,selectColorBoxIndex,selectColorBoxIndex2,itemName);
            
            NSInteger row_0 =  [[m_configDictionary valueForKey:kChooseItemIndex] integerValue];
            NSMutableArray * itemData_0 = [self calculateData:row_0];
            NSMutableArray * itemData = [self calculateData:row];  // must after itemData_0, because of show data

            if ([[m_configDictionary valueForKey:kInputRangeFlag] boolValue])
            {
                NSString *rangelsl = [m_configDictionary valueForKey:krangelsl];
                NSString *rangeusl = [m_configDictionary valueForKey:krangeusl];
                itemData_0[tb_range_lsl] = rangelsl;
                itemData_0[tb_range_usl] = rangeusl;
                itemData[tb_range_lsl] = rangelsl;
                itemData[tb_range_usl] = rangeusl;
                NSLog(@">>range: %@,%@",rangelsl,rangeusl);
            }
            else
            {
                NSString *rangelsl = itemData[tb_lower];
                NSString *rangeusl = itemData[tb_upper];
                itemData_0[tb_range_lsl] = rangelsl;
                itemData_0[tb_range_usl] = rangeusl;
                itemData[tb_range_lsl] = rangelsl;
                itemData[tb_range_usl] = rangeusl;
                NSLog(@".>>range: %@,%@",rangelsl,rangeusl);

            }
           
            if (((n_firstItemClick ==0) && ([itemData count]>38 ))|| (n_firstItemClick ==1))  // n_firstItemClick 为1 就是点击了select x  或者 select y
            {
                [m_configDictionary setValue:[NSNumber numberWithInteger:row] forKey:kChooseItemIndex];
                [m_configDictionary setValue:choose_item_name forKey:kChooseItemName];
                n_firstItemClick =10;
                
            }
            if (n_firstItemClick == 10)
            {
                NSString *itemName_0 = [NSString stringWithFormat:@"%@_XY",[m_configDictionary valueForKey:kChooseItemName]];
                itemData[tb_correlation_xy] = itemName_0;
                itemData_0[tb_correlation_xy] = itemName_0;
                [self sendDataToRedis:itemName_0 withData:itemData_0];
            }
            
            if (xy==-1)
            {
                // do nothing
            }
            else
            {
                itemName = [NSString stringWithFormat:@"%@$$%d",itemName,xy];
            }
            
            [self sendDataToRedis:itemName withData:itemData];
            [self sendCpkZmqMsg:itemName];
            [self sendBoxZmqMsg:itemName];
            [self sendCorrelationZmqMsg:itemName];
            [self sendScatterZmqMsg:itemName];
        }
        else
        {
            if (n_firstItemClick ==0|| n_firstItemClick ==1)
            {
                NSString *choose_item_name = [_indexItemNameDic valueForKey:[NSString stringWithFormat:@"%zd",row]];
                [m_configDictionary setValue:[NSNumber numberWithInteger:row] forKey:kChooseItemIndex];
                [m_configDictionary setValue:choose_item_name forKey:kChooseItemName];
                n_firstItemClick =10;
                
            }
            
            if (xy==-1)
            {
                // NSDictionary *dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:ApplyBoxflag] forKey:applyBoxCheck];
                if (selectColorBoxIndex > 0)
                {
                   [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationClickPlotTable object:nil userInfo:nil];
                }
                else if (selectColorBoxIndex2 > 0)
                {
                    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationClickPlotTable2 object:nil userInfo:nil];
                }
                 
            }
            else
            {
                NSDictionary *dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:xy] forKey:selectXY];
                [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationClickPlotTable_selectXY object:nil userInfo:dic];

            }
        }

    }
    else
    {
        if (selectColorBoxIndex > 0 )
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationClickPlotTable object:nil userInfo:nil];
        }
        else if(selectColorBoxIndex2 > 0)
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationClickPlotTable2 object:nil userInfo:nil];
        }
        else
        {
            NSLog(@"--click the same item, do nothing");
        }
    }

    return ApplyBoxflag;
}

-(void)newCpkDataToRedis:(NSInteger)rowtb
{
    NSInteger row = 0;
    for (NSInteger i= 0; i<[_ListAllItemNameArr count]; i++)  //当UI 选择search 的时候，数据变了，row 也变了，要找到对应值
    {
        if ([_ListAllItemNameArr[i] isEqualToString:_data[rowtb][1]])
        {
            row = i;
            break;
        }
    }
    
    NSString *retest = vRetestAll;
    NSString *removeFail = vRemoveFailYes;
    NSString *choose_item_name = [_indexItemNameDic valueForKey:[NSString stringWithFormat:@"%zd",row]];
    NSString * itemName = [NSString stringWithFormat:@"%@##%@&%@",choose_item_name,retest,removeFail];
    NSString *dic_key = [NSString stringWithFormat:@"%@&%@",retest,removeFail];
    NSMutableArray *indexArr = [m_configDictionary valueForKey:dic_key];
    NSMutableArray * itemData = [self getItemDataWithRetestIndex:indexArr bySelectRow:row];
    NSString *itemName2 = [NSString stringWithFormat:@"%@_new_cpk",itemName];
    NSLog(@">->new cpk name: %@ , %zd",itemName2,[itemData count]);
    [self sendDataToRedis:itemName2 withData:itemData];
           
}

- (IBAction)btnClickItem:(NSTextField *)sender
{
    NSLog(@"*****>>item click");
    [sender setEditable:YES];
    [sender setBordered:NO];
}

//-(BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
//{
//    return YES;
//}

-(IBAction)btnClickKeynoteApply:(NSButton*)sender
{
    NSInteger btnTag = sender.tag;  // select row
    NSInteger state = sender.state;
    NSLog(@"btnClickKeynoteApply: %zd,%zd",btnTag,state);
    _data[btnTag][tb_keynote] = [NSNumber numberWithInteger:state];
    
    
    NSString * itemName =  _data[btnTag][tb_item];
    
    NSInteger value= [_data[btnTag][tb_index] intValue] -1;
    
    if (state) {
        if(![_KYesIndex containsObject:@(value) ]){
            [_KYesIndex addObject:@(value) ];
            
            
        }
        if(![_KYesIndexItemNames containsObject:itemName ]){
            [_KYesIndexItemNames addObject:itemName ];
            
            
        }
        
        [_KNoIndex removeObject:@(value)];
    }
    else{
        if(![_KNoIndex containsObject:@(value)]){
            [_KNoIndex addObject:@(value) ];
            
        }
        [_KYesIndex removeObject:_data[btnTag][tb_index] ];
        [_KYesIndexItemNames removeObject:itemName ];
    }
    [self.dataTableView reloadData];
    [m_configDictionary setValue:[NSNumber numberWithBool:btnTag] forKey:K_dic_keynoteBoxCheck];
    
    [m_configDictionary setValue:_KYesIndexItemNames forKey:@"KCheckedItemNames"];
    [m_configDictionary setValue:_KYesIndex forKey:@"KCheckedItems"];
    [m_configDictionary setValue:_bmcYesIndex forKey:@"KCheckedBMStates"];
}

-(void)reloadReviewerDate:(NSInteger)row
{
  
    NSString *lsl = [_data[row][tb_lsl] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *usl = [_data[row][tb_usl] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([lsl length]<1 && [usl length]<1)
    {
        return;
    }
    float lowPrevious = -9999;
    float highPrevious = -9999;
    NSString *reviewer_name = @"";
    NSString *reviewer_date = @"";
    NSString *user_comment = @"";
    
    if (_limitUpdateData.count >0)
    {
        for (int i=0; i<[_limitUpdateData count]; i++) // find load excel之前的设置
        {
            if ([_limitUpdateData[i] count]==27)
            {
                if ([_limitUpdateData[i][1] isEqualToString:_data[row][tb_item]] )
                {
                     if ([_limitUpdateData[i][updatelimit_newLower-1] isNotEqualTo:@""] &&[_limitUpdateData[i][updatelimit_newUpper-1] isNotEqualTo:@""]) //load excel之前的设置
                     {
                         lowPrevious =  [[_limitUpdateData[i][updatelimit_newLower-1]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
                         highPrevious =  [[_limitUpdateData[i][updatelimit_newUpper-1]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
                         reviewer_name = [_limitUpdateData[i][updatelimit_reviewer_name-1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                         reviewer_date = [_limitUpdateData[i][updatelimit_reviewer_date-1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                         user_comment = [_limitUpdateData[i][updatelimit_user_comment-1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                         break;
                     }
                }
                
            }
            else if ([_limitUpdateData[i] count]==28)
            {
                if ([_limitUpdateData[i][1] isEqualToString:_data[row][tb_item]] )
                {
                     if ([_limitUpdateData[i][updatelimit_newLower] isNotEqualTo:@""] &&[_limitUpdateData[i][updatelimit_newUpper] isNotEqualTo:@""]) //load excel之前的设置
                     {
                         lowPrevious =  [[_limitUpdateData[i][updatelimit_newLower]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
                         highPrevious =  [[_limitUpdateData[i][updatelimit_newUpper]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
                         reviewer_name = [_limitUpdateData[i][updatelimit_reviewer_name] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                         reviewer_date = [_limitUpdateData[i][updatelimit_reviewer_date] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                         user_comment = [_limitUpdateData[i][updatelimit_user_comment] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                         break;
                     }
                }
            }
            else if ([_limitUpdateData[i] count]==29)
            {
                if ([_limitUpdateData[i][1] isEqualToString:_data[row][tb_item]] )
                {
                     if ([_limitUpdateData[i][updatelimit_newLower+1] isNotEqualTo:@""] &&[_limitUpdateData[i][updatelimit_newUpper+1] isNotEqualTo:@""]) //load excel之前的设置
                     {
                         lowPrevious =  [[_limitUpdateData[i][updatelimit_newLower+1]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
                         highPrevious =  [[_limitUpdateData[i][updatelimit_newUpper+1]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
                         reviewer_name = [_limitUpdateData[i][updatelimit_reviewer_name+1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                         reviewer_date = [_limitUpdateData[i][updatelimit_reviewer_date+1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                         user_comment = [_limitUpdateData[i][updatelimit_user_comment+1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                         break;
                     }
                }
            }
            
        }
    }
    
    if (lowPrevious != highPrevious && lowPrevious != -9999)
    {
        float low =  [lsl floatValue];
        float high =  [usl floatValue];
        //NSString *comment = [_data[row][tb_comment] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (low == lowPrevious && high == highPrevious)
        {
            _data[row][tb_comment] = user_comment;
            _data[row][tb_reviewer] = reviewer_name;
            _data[row][tb_date] = reviewer_date;
            b_ClearComment = YES;
            
            
        }
        else
        {
            if (b_ClearComment)
            {
                _data[row][tb_comment] = @"";
            }
            _data[row][tb_reviewer] = @"";
            _data[row][tb_date] = @"";
        }
        [self.dataTableView reloadData];
    }
    
}

-(IBAction)btnClickApply:(NSButton*)sender
{
    n_clickApplyRow = -1;
    NSLog(@">==>%@  %@",[m_configDictionary valueForKey:kRetestSeg],[m_configDictionary valueForKey:kRemoveFailSeg]);
    NSInteger btnTag = sender.tag;  // select row
    
    NSInteger state = sender.state;
    
    float lowPrevious = 0;
    float highPrevious = 0;
    
    NSString *reviewer_name = @"";
    NSString *reviewer_date = @"";
    NSString *user_comment = @"";
    
    if (_limitUpdateData.count >0)
    {
        for (int i=0; i<[_limitUpdateData count]; i++) // find load excel之前的设置
        {
            if ([_limitUpdateData[i] count]==27)
            {
                if ([_limitUpdateData[i][1] isEqualToString:_data[btnTag][tb_item]] )
                {
                     if ([_limitUpdateData[i][updatelimit_newLower-1] isNotEqualTo:@""] &&[_limitUpdateData[i][updatelimit_newUpper-1] isNotEqualTo:@""]) //load excel之前的设置
                     {
                         lowPrevious =  [[_limitUpdateData[i][updatelimit_newLower-1]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
                         highPrevious =  [[_limitUpdateData[i][updatelimit_newUpper-1]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
                         reviewer_name = [_limitUpdateData[i][updatelimit_reviewer_name-1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                         reviewer_date = [_limitUpdateData[i][updatelimit_reviewer_date-1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                         user_comment = [_limitUpdateData[i][updatelimit_user_comment-1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                         break;
                     }
                }
                
            }
            else if ([_limitUpdateData[i] count]==28)
            {
                if ([_limitUpdateData[i][1] isEqualToString:_data[btnTag][tb_item]] )
                {
                     if ([_limitUpdateData[i][updatelimit_newLower] isNotEqualTo:@""] &&[_limitUpdateData[i][updatelimit_newUpper] isNotEqualTo:@""]) //load excel之前的设置
                     {
                         lowPrevious =  [[_limitUpdateData[i][updatelimit_newLower]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
                         highPrevious =  [[_limitUpdateData[i][updatelimit_newUpper]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
                         reviewer_name = [_limitUpdateData[i][updatelimit_reviewer_name] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                         reviewer_date = [_limitUpdateData[i][updatelimit_reviewer_date] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                         user_comment = [_limitUpdateData[i][updatelimit_user_comment] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                         break;
                     }
                }
            }
            else if ([_limitUpdateData[i] count]==29)
            {
                if ([_limitUpdateData[i][1] isEqualToString:_data[btnTag][tb_item]] )
                {
                     if ([_limitUpdateData[i][updatelimit_newLower+1] isNotEqualTo:@""] &&[_limitUpdateData[i][updatelimit_newUpper+1] isNotEqualTo:@""]) //load excel之前的设置
                     {
                         lowPrevious =  [[_limitUpdateData[i][updatelimit_newLower+1]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
                         highPrevious =  [[_limitUpdateData[i][updatelimit_newUpper+1]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue];
                         reviewer_name = [_limitUpdateData[i][updatelimit_reviewer_name+1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                         reviewer_date = [_limitUpdateData[i][updatelimit_reviewer_date+1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                         user_comment = [_limitUpdateData[i][updatelimit_user_comment+1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                         break;
                     }
                }
            }
                
            
        }
    }
    
//     if ([_data[btnTag][tb_lsl] isNotEqualTo:@""] &&[_data[btnTag][tb_usl] isNotEqualTo:@""]) //load excel之前的设置
//     {
//         lowPrevious =  [_data[btnTag][tb_lsl] floatValue];
//         highPrevious =  [_data[btnTag][tb_usl] floatValue];
//     }
    
    _data[btnTag][tb_apply] = [NSNumber numberWithInteger:state];
    _data[btnTag][tb_color_by_left]= [NSNumber numberWithInteger:selectColorBoxIndex];  //设置color By左边那个,给python生成图表用
    _data[btnTag][tb_color_by_right]= [NSNumber numberWithInteger:selectColorBoxIndex2];  //设置color By right那个,给python生成图表用
    
    
    [self.dataTableView reloadData];
    
    if ([_data[btnTag][tb_lsl] isEqualTo:@""] && [_data[btnTag][tb_usl] isEqualTo:@""])
    {
        [self AlertBox:@"Warning!!!" withInfo:@"Please input LSL or USL firstly!!!"];
        _data[btnTag][tb_apply] = [NSNumber numberWithInt:0];
        [self.dataTableView reloadData];
        return;
    }
    
    if ([_data[btnTag][tb_lsl] isEqualTo:@""])
    {
        [self AlertBox:@"Warning!!!" withInfo:@"Please input LSL firstly!!!"];
        _data[btnTag][tb_apply] = [NSNumber numberWithInt:0];
        [self.dataTableView reloadData];
        return;
    }
    
    if ([_data[btnTag][tb_usl] isEqualTo:@""])
       {
           [self AlertBox:@"Warning!!!" withInfo:@"Please input USL firstly!!!"];
           _data[btnTag][tb_apply] = [NSNumber numberWithInt:0];
           [self.dataTableView reloadData];
           return;
       }
    
    if ([_data[btnTag][tb_lsl] isNotEqualTo:@""] &&[_data[btnTag][tb_usl] isNotEqualTo:@""] && ([_data[btnTag][tb_lsl] isNotEqualTo:@"NA"] && [_data[btnTag][tb_usl] isNotEqualTo:@"NA"]))
    {
        float low =  [_data[btnTag][tb_lsl] floatValue];
        float high =  [_data[btnTag][tb_usl] floatValue];
        if (low>high)
        {
            [self AlertBox:@"Error:023" withInfo:@"Input LSL is bigger than USL!!!"];
            _data[btnTag][tb_apply] = [NSNumber numberWithInt:0];
            _data[btnTag][tb_lsl] = @"";
            _data[btnTag][tb_usl] = @"";
            [self.dataTableView reloadData];
            return;
        }
        if (lowPrevious != highPrevious)
        {
            if (low != lowPrevious || high != highPrevious)
            {
                if (b_ClearComment)
                {
                    _data[btnTag][tb_comment] = @"";
                }
                
                _data[btnTag][tb_reviewer] = @"";
                _data[btnTag][tb_date] = @"";
            }
            else
            {
                _data[btnTag][tb_comment] = user_comment;
                _data[btnTag][tb_reviewer] = reviewer_name;
                _data[btnTag][tb_date] = reviewer_date;
                b_ClearComment = YES;
                
            }
        }
        
    }
    
    /*if (state == 1)
    {
        NSDateFormatter* DateFomatter = [[NSDateFormatter alloc] init];
        [DateFomatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString* systemTime = [DateFomatter stringFromDate:[NSDate date]];
        _data[btnTag][13] = systemTime;
    }
    else
    {
        _data[btnTag][13] = @"";
    }
     */
    if( [sender state] ){
        
        n_clickApplyRow = btnTag;
    }
    
    if (state == 1)
    {
        
    }
    else
    {
        _data[btnTag][tb_cpk_new] =@"";
    }

    [m_configDictionary setValue:[NSNumber numberWithBool:btnTag] forKey:K_dic_ApplyBoxCheck];
    NSString * itemName =[self combineItemName: [_indexItemNameDic valueForKey:[NSString stringWithFormat:@"%zd",btnTag]]];
    NSLog(@">tag:%zd  state:%zd, item name: %@",btnTag,state,itemName);
    [self newCpkDataToRedis:btnTag];
    [self triggerGeneratePlot:btnTag withApplyBox:YES withSelectXY:-1];
    
}

-(NSString *)openCSVLoadPanel
{
    //[[NSWorkspace sharedWorkspace] openFile:@"~/desktop"];
    //[[NSWorkspace sharedWorkspace] openFile:desktopPath];
    //    [panel setDirectoryURL:[NSURL URLWithString:desktopPath]];
        //[panel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result)  //[NSApp mainWindow]
    //    {
    //        if (result == NSModalResponseOK) {
    //             @try {
    //                 csvpath = [[[panel URLs] objectAtIndex:0] path];
    //                 [self.txtScriptPath setStringValue:csvpath];
    //             }
    //             @catch (NSException *exception) {
    //                 NSLog(@"Load file failed,please check the data");
    //             }
    //             @finally {
    //             }
    //         }
    //     }];
        
    NSString *csvpath =nil;
    NSOpenPanel * panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO]; //设置多选模式
    [panel setCanChooseFiles:YES];
    [panel setCanCreateDirectories:YES];
    [panel setCanChooseDirectories:YES];
    [panel setAllowedFileTypes:[NSArray arrayWithObjects:@"CSV", @"csv", @"Csv",nil]];
    [panel setDirectoryURL:[NSURL URLWithString:desktopPath]];
    [panel runModal];
    if ([[panel URLs] count]>0)
    {
        csvpath = [[[panel URLs] objectAtIndex:0] path];
        [self.txtcsvDataName setStringValue:csvpath];
    }
    else
    {
        [self.txtcsvDataName setStringValue:@"--"];
    }
    if (csvpath==nil || [csvpath isEqualToString:desktopPath])
    {
        return nil;
    }
    return csvpath;
}

- (IBAction)btnSearchCsv:(id)sender
{

    
    NSString *content = @"";
    if( [sender isKindOfClass:[NSString class]]){
        content = sender;
    }
    else{
        content = [sender stringValue];
    }
    //NSString *content = [sender stringValue];
    if ([content isNotEqualTo:@""])
    {
        //content = [sender stringValue];
        
        [searchExceptIndex removeAllObjects];
        

        for (int i =0; i<[filterSourceData count]; i++) {
            
            NSString * itemName = filterSourceData[i][tb_item];
            
            if(![itemName.lowercaseString  containsString:content.lowercaseString]){
                NSInteger index = [filterSourceData[i][tb_index] intValue] -1;
                
                [searchExceptIndex addObject:@(index)];
            }
        }
        
        [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationFilterMsg object:nil userInfo:nil];
    }
    else{
        if ([searchExceptIndex count]>0) {
            [searchExceptIndex removeAllObjects];
            [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationFilterMsg object:nil userInfo:nil];
        }
        
        //do nothing !
    }
    

}

-(void)searchFind:(NSString *)content
{
    
    NSUInteger m_length1 = [_sortDataBackup count];
    NSUInteger m_length2 = [_dataBackup count];
    
    if(m_length1 == m_length2)
    {
        
        [arrSearchRedCPK removeAllObjects];
        [arrSearchGreenCPK removeAllObjects];
        [arrSearchYellowCPK removeAllObjects];
        
        int n_num = 0;
        for (NSArray *lineData in _dataBackup)
        {
            NSString *lineStr = lineData[1];
            
            if ([lineStr.uppercaseString containsString:content.uppercaseString])
            {
                [arrSearch addObject:lineData];
                int x_row = [lineData[0] intValue]-1;

                if ([_colorRedIndexSearchBackup containsObject:[NSNumber numberWithInt:x_row]])
                {
                  
                    [arrSearchRed addObject:[NSNumber numberWithInt:n_num]];
                }
                else if ([_colorGreenIndexSearchBackup containsObject:[NSNumber numberWithInt:x_row]])
                {
                    [arrSearchGreen addObject:[NSNumber numberWithInt:n_num]];
                }
                
                if ([_colorRedIndexSearchCpk containsObject:[NSNumber numberWithInt:x_row]])
                {
                    [arrSearchRedCPK addObject:[NSNumber numberWithInt:n_num]];
                }
                else if ([_colorGreenIndexSearchCpk containsObject:[NSNumber numberWithInt:x_row]])
                {
                    [arrSearchGreenCPK addObject:[NSNumber numberWithInt:n_num]];
                }
                else if ([_colorYellowIndexSearchCpk containsObject:[NSNumber numberWithInt:x_row]])
                {
                    [arrSearchYellowCPK addObject:[NSNumber numberWithInt:n_num]];
                }
                 
                
                n_num++;
            }
        }
        [_data setArray:arrSearch];
    }
    else
    {
        [arrSearchRedCPK removeAllObjects];
        [arrSearchGreenCPK removeAllObjects];
        [arrSearchYellowCPK removeAllObjects];
        
        int n_num = 0;
        for (NSArray *lineData in _dataBackup)
        {
            NSString *lineStr = lineData[1];
            
            if ([lineStr.uppercaseString containsString:content.uppercaseString])
            {
                [arrSearch addObject:lineData];

                if ([_colorRedIndexSearchBackup containsObject:[NSNumber numberWithInt:n_num]])
                {
                    [arrSearchRed addObject:[NSNumber numberWithInt:n_num]];
                }
                else if ([_colorGreenIndexSearchBackup containsObject:[NSNumber numberWithInt:n_num]])
                {
                    [arrSearchGreen addObject:[NSNumber numberWithInt:n_num]];
                }
                
                
                n_num++;
            }
        }
        
        [_data setArray:arrSearch];
        int n_num2 = 0;
        float cpkL = [[m_configDictionary valueForKey:cpk_Lowthl] floatValue];
        float cpkH = [[m_configDictionary valueForKey:cpk_Highthl] floatValue];
        for (NSArray *lineData in arrSearch)
        {
            NSString *value = lineData[tb_cpk_orig];
            if ([self isPureFloat:value]|| [self isPureInt:value])
            {
                if ([value floatValue]<cpkL)
                {
                    [arrSearchRedCPK addObject:[NSNumber numberWithInt:n_num2]];
                }
                else if([value floatValue] >cpkH)
                {
                    [arrSearchYellowCPK addObject:[NSNumber numberWithInt:n_num2]];
                }
                else
                {
                    [arrSearchGreenCPK addObject:[NSNumber numberWithInt:n_num2]];
                }
                
            }
            n_num2++;
            
        }
    }
    
    [_colorRedIndex setArray:arrSearchRed];
    [_colorGreenIndex setArray:arrSearchGreen];
    
    [_colorRedIndexCpk setArray: arrSearchRedCPK];
    [_colorGreenIndexCpk setArray:arrSearchGreenCPK];
    [_colorYellowIndexCpk setArray:arrSearchYellowCPK];
    [self.dataTableView reloadData];
}

-(BOOL)isContinuous:(NSArray *)array
{
    if([array count]<1)
        return true;
    
    int min = [array[0] intValue];
    int max = [array[0] intValue];
    for (int i = 1; i < [array count]; i++)
    {
        if (array[i] != 0)
        {
            if (min>[array[i] intValue])
            {
                min = [array[i] intValue];
            }
            if (max < [array[i] intValue])
            {
                max = [array[i] intValue];
            }
        }
    }
    if ((max - min)>([array count] - 1))
        return false;
    else
        return true;
}

- (IBAction)btLoadCsvData:(id)sender  // for button use
{
   
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.allowsImplicitAnimation = YES;
        context.duration = 0.25; // seconds
        context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        //if ([self.splitView isSubviewCollapsed:self.rightPanel])
//         if(n_loadCsvBtn %2==1)
//        {
//            // -> expand
//            [self.splitView setPosition:_lastLeftPaneWidth ofDividerAtIndex:0];
//        }
//        else {
//            // <- collapse
//            _lastLeftPaneWidth = self.leftPane.frame.size.width; //  remember current width to restore
//            [self.splitView setPosition:0 ofDividerAtIndex:0];
//        }
         if (_lastLeftPaneWidth==0 )
         {
            
             [self.splitView setPosition:1200 ofDividerAtIndex:0];
             _lastLeftPaneWidth = 1200;
             
         }
         else
         {
             [self.splitView setPosition:0 ofDividerAtIndex:0];
              _lastLeftPaneWidth = 0;
             
         }
         
        
        [self.splitView layoutSubtreeIfNeeded];
    }];
    
    //return;
   // [self openSheet:sender];
   /* NSString *csvPath = [self openCSVLoadPanel];

    if (!csvPath) {
        NSLog(@"--no csv select");
        return;
    }
    [m_configDictionary setValue:[NSNumber numberWithBool:NO] forKey:K_dic_Load_Csv_Finished];
    [m_configDictionary setValue:csvPath forKey:Load_Csv_Path];
    [self sendCalculateZmqMsg:@"calculate-param"];
    NSTimeInterval starttime = [[NSDate date]timeIntervalSince1970];
    //NSString *csvPath = @"/Users/RyanGao/Desktop/cpk/cpk_data_0611/J5xx-FCT.csv"; //J5xx-FCT   test
    [self reloadDataWithPath:csvPath];
    
    NSTimeInterval now = [[NSDate date]timeIntervalSince1970];
    [self initRetestAndRemoveFailSeg];
    [self initColorByTableView];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationInitColorTable object:nil userInfo:nil];
    
    //再次加载，需要init
    enableEditing = YES;
    clickItemIndex = -1;
    editLimitRow = -1;
    retestValue=@"";
    removeValue = @"";
    NSLog(@"====load csv执行时间: %f",now-starttime);
    
    NSString *file1 = [NSString stringWithFormat:@"%@/CPK_Log/temp/cpk.png",desktopPath];
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager removeItemAtPath:file1 error:nil];
    NSString *picPath =[[NSBundle mainBundle]pathForResource:@"cpk.png" ofType:nil];
    [manager copyItemAtPath:picPath toPath:file1 error:nil];
    
    NSString *file2 = [NSString stringWithFormat:@"%@/CPK_Log/temp/correlation.png",desktopPath];
    [manager removeItemAtPath:file2 error:nil];
    NSString *picPath2 =[[NSBundle mainBundle]pathForResource:@"correlation.png" ofType:nil];
    [manager copyItemAtPath:picPath2 toPath:file2 error:nil];
    */
}

-(void)toLoadLocalCsv:(NSNotification *)nf
{
    
    //Added By Vito 20210304
    //Clear Filter
    [self OnClearExcelFilter:nil];
    [_colorRedIndex removeAllObjects];
    [_colorGreenIndex removeAllObjects];
    [_colorGrayIndex removeAllObjects];
    [_colorOtherIndex removeAllObjects];
    //Add end
    
    
    b_isCustomCSV = NO;
    [self.txtSearch setStringValue:@""];
    [self btnSearchCsv:@""];
    
    [self launch_yield_rate];
    [self launch_calculate_test];
    [self launch_retest_plot];
    
    [m_configDictionary setValue:[NSNumber numberWithBool:NO] forKey:K_dic_Load_Csv_Finished];
    NSDictionary* info = [nf userInfo];
    NSString *csvPath = [info valueForKey:@"data_csv"];
    [m_configDictionary setValue:[info valueForKey:cpk_Lowthl] forKey:cpk_Lowthl];
    [m_configDictionary setValue:[info valueForKey:cpk_Highthl] forKey:cpk_Highthl];
    NSLog(@">>>local csvpath: %@   ",csvPath);
    [m_configDictionary setValue:csvPath forKey:Load_Local_Csv_Path];
    [m_configDictionary setValue:@"" forKey:Load_Csv_Path];   //清掉
    [m_configDictionary setValue:@"" forKey:Load_Script_Path];
    // NSString *csvPath = [m_configDictionary valueForKey:Load_Csv_Path];
    
    //for debug
    //[self AlertBox:@"!!!" withInfo:[NSString stringWithFormat:@"Under development:\r\n%@",csvPath]];
    //return;
    
    if (!csvPath)
    {
        NSLog(@"--no csv select");
        return;
    }
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:csvPath])
    {
        [self AlertBox:@"Error:001" withInfo:[NSString stringWithFormat:@"Local data file did not exist at Path:\r\n%@",csvPath]];
        return;
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationShowStartUp object:nil userInfo:nil];
    [[NSRunLoop currentRunLoop]runMode:NSDefaultRunLoopMode beforeDate:[NSDate date]];
    n_loadStepCount = 11.0;
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationIndicatorMsg object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Initialization ...",kStartupMsg,[NSNumber numberWithInt:MSG_LEVEL_NORMAL],kStartupLevel,[NSNumber numberWithFloat:1/n_loadStepCount],kStartupPercentage, nil]];
    
    if(![self reloadLocalDataWithPath:csvPath])
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationCloseStartUp object:nil userInfo:nil];
        return;
    }
    
    //[self.txtcsvDataName setStringValue:[csvPath lastPathComponent]];
    //[self.txtScriptName setStringValue:@""];
    //[self.txtLimitUpdate setStringValue:@""];
    [self initRetestPlotAndCsv];
    //[self sendCalculateZmqMsgLocal:@"calculate-param"]; //calculate-param-local
    //[self sendYieldRateZmqMsgLocal:@"yield_rate-param"]; //yield_rate-param-local
    [self sendCalculateZmqMsg:@"calculate-param"];
    [self sendYieldRateZmqMsg:@"yield_rate-param"];
    [self sendRetestPlotZmqMsg:@"retest_plot"];
    
    //NSTimeInterval starttime = [[NSDate date]timeIntervalSince1970];
    //NSString *csvPath = @"/Users/RyanGao/Desktop/cpk/cpk_data_0611/J5xx-FCT.csv"; //J5xx-FCT   test
    
    
    //解析脚本csv
    
    //解析XLSX
   
    
    //NSTimeInterval now = [[NSDate date]timeIntervalSince1970];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationInitColorTable object:nil userInfo:nil];
    [self initRetestAndRemoveFailSeg];
    [self initColorByTableView];
    [m_configDictionary setValue:_ListAllItemNameArr forKey:k_All_Item_Name];
    
    
    //再次加载，需要init
    enableEditing = YES;
    clickItemIndex = -1;
    editLimitRow = -1;
    retestValue=@"";
    removeValue = @"";
    //NSLog(@"====load csv执行时间: %f",now-starttime);
    
    NSString *file1 = @"/tmp/CPK_Log/temp/cpk.png";//[NSString stringWithFormat:@"%@/CPK_Log/temp/cpk.png",desktopPath];
    [manager removeItemAtPath:file1 error:nil];
    NSString *picPath =[[NSBundle mainBundle]pathForResource:@"cpk.png" ofType:nil];
    [manager copyItemAtPath:picPath toPath:file1 error:nil];
    
    NSString *file2 = @"/tmp/CPK_Log/temp/correlation.png";//[NSString stringWithFormat:@"%@/CPK_Log/temp/correlation.png",desktopPath];
    [manager removeItemAtPath:file2 error:nil];
    NSString *picPath2 =[[NSBundle mainBundle]pathForResource:@"correlation.png" ofType:nil];
    [manager copyItemAtPath:picPath2 toPath:file2 error:nil];
    
    NSString *file3 = @"/tmp/CPK_Log/temp/scatter.png";//[NSString stringWithFormat:@"%@/CPK_Log/temp/scatter.png",desktopPath];
    [manager removeItemAtPath:file3 error:nil];
    NSString *picPath3 =[[NSBundle mainBundle]pathForResource:@"scatter.png" ofType:nil];
    [manager copyItemAtPath:picPath3 toPath:file3 error:nil];
    
    
    _lastLeftPaneWidth = self.leftPane.frame.size.width; //  remember current width to restore
    [self.splitView setPosition:0 ofDividerAtIndex:0];
     _lastLeftPaneWidth = 0;
    [self.splitView layoutSubtreeIfNeeded];
    [self.dataTableView setFocusRingType:NSFocusRingTypeNone];
    [self.dataTableView setAccessibilityFocused:YES];//isAccessibilityFocused
    //[[NSNotificationCenter defaultCenter]postNotificationName:kLoadGroupPanel object:nil userInfo:nil];
    
    [self setHiddenCol:NO];
    b_ClearComment = YES;
    
    //Added By Vito 20210306
    //
    [filterSourceData removeAllObjects];
    [filterSourceData setArray:_data];
    [m_configDictionary setValue:[NSNumber numberWithBool:YES] forKey:K_dic_Load_Csv_Finished];
    //Add end
    
}


-(int)deleteFiles:(NSString *)path
{
    NSFileManager * fileManger = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isExist = [fileManger fileExistsAtPath:path isDirectory:&isDir];
    if (isExist)
    {
        if (isDir)
        {
            NSArray * dirArray = [fileManger contentsOfDirectoryAtPath:path error:nil];
            NSString * subPath = nil;
            for (NSString * str in dirArray)
            {
                subPath  = [path stringByAppendingPathComponent:str];
                BOOL issubDir = NO;
                [fileManger fileExistsAtPath:subPath isDirectory:&issubDir];
                if (!issubDir)
                {
                    [self deleteFiles:subPath];
                }
                else
                {
                    NSString *fileName = [subPath lastPathComponent];
                    if ([fileName isNotEqualTo:@".apple_log_black.png"] &&[fileName isNotEqualTo:@".retest_plot.txt"] && [fileName isNotEqualTo:@".none_pic.png"])
                    {
                        NSError *error = nil;
                        [fileManger removeItemAtPath:subPath error:&error];
                        NSLog(@">delete folder: %@ ,error: %@",subPath,error);
                    }
                    
                }
            }
        }
        else
        {
            NSString *fileName = [path lastPathComponent];
            if ([fileName isNotEqualTo:@".apple_log_black.png"] &&[fileName isNotEqualTo:@".retest_plot.txt"] && [fileName isNotEqualTo:@".none_pic.png"])
            {
                NSError *error = nil;
                [fileManger removeItemAtPath:path error:&error];
                NSLog(@">delete file: %@error: %@",path,error);
            }
            
        }
    }
    else
    {
        return -1;
    }
    return 0;
}

-(void)toLoadCsv:(NSNotification *)nf
{
   
    b_isCustomCSV = NO;
    [self.txtSearch setStringValue:@""];
    [self btnSearchCsv:@""];
    
    //Added By Vito 20210304
    //Clear Filter
    [self OnClearExcelFilter:nil];
    //Add end
    
    //NSString *csvPath = [self openCSVLoadPanel];
    [self launch_yield_rate];
    [self launch_calculate_test];
    [self launch_retest_plot];
    
    [m_configDictionary setValue:[NSNumber numberWithBool:NO] forKey:K_dic_Load_Csv_Finished];
    NSDictionary* info = [nf userInfo];
    NSString *csvPath = [info valueForKey:@"data_csv"];
    NSString *scriptPath = [info valueForKey:@"script_csv"];
    NSString *limitPath = [info valueForKey:@"limit_xlsx"];
    
    [m_configDictionary setValue:[info valueForKey:cpk_Lowthl] forKey:cpk_Lowthl];
    [m_configDictionary setValue:[info valueForKey:cpk_Highthl] forKey:cpk_Highthl];
    NSLog(@">>>csvpath: %@   scriptpath: %@ limitPath: %@",csvPath,scriptPath,limitPath);
    [m_configDictionary setValue:csvPath forKey:Load_Csv_Path];
    [m_configDictionary setValue:@"" forKey:Load_Local_Csv_Path];  //清除掉
    [m_configDictionary setValue:@"" forKey:Load_Script_Path];
    // NSString *csvPath = [m_configDictionary valueForKey:Load_Csv_Path];
    if (!csvPath) {
        NSLog(@"--no csv select");
        return;
    }
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:csvPath])
    {
        [self AlertBox:@"Error:002" withInfo:[NSString stringWithFormat:@"Data file did not exist at Path:\r\n%@",csvPath]];
        return;
    }
    [self.txtcsvDataName setStringValue:[csvPath lastPathComponent]];
    [self.txtScriptName setStringValue:@""];
    [self.txtLimitUpdate setStringValue:@""];
    
    [self initRetestPlotAndCsv];
    [self sendCalculateZmqMsg:@"calculate-param"];
    [self sendYieldRateZmqMsg:@"yield_rate-param"];
    [self sendRetestPlotZmqMsg:@"retest_plot"];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationShowStartUp object:nil userInfo:nil];
    [[NSRunLoop currentRunLoop]runMode:NSDefaultRunLoopMode beforeDate:[NSDate date]];
    
    n_loadStepCount = 15.0;
    
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationIndicatorMsg object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Initialization ...",kStartupMsg,[NSNumber numberWithInt:MSG_LEVEL_NORMAL],kStartupLevel,[NSNumber numberWithFloat:1/n_loadStepCount], kStartupPercentage, nil]];
    
    //Added By Vito 20210306
    //
    [_colorRedIndex removeAllObjects];
    [_colorGreenIndex removeAllObjects];
    [_colorOtherIndex removeAllObjects];
    [_colorGrayIndex removeAllObjects];
    //Add end
    
    if (![self reloadDataWithPath:csvPath])
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationCloseStartUp object:nil userInfo:nil];
        return;
    }
    
    //解析脚本csv
    if ([scriptPath isNotEqualTo:@""])
    {
        if ([manager fileExistsAtPath:scriptPath])
        {
            [m_configDictionary setValue:scriptPath forKey:Load_Script_Path];
            [self reloadScriptDataWithPath:scriptPath dataPath:csvPath];
        }
        else
        {
            [self AlertBox:@"Error:003" withInfo:[NSString stringWithFormat:@"Script file did not exist at Path:\r\n%@",scriptPath]];
        }
       
    }
    
    //解析XLSX
    if ([limitPath isNotEqualTo:@""])
    {
        if ([manager fileExistsAtPath:limitPath])
        {
            [self reloadUpdateLimit:limitPath dataPath:csvPath];
        }
        else
        {
            [self AlertBox:@"Error:004" withInfo:[NSString stringWithFormat:@"limit update file did not exist at Path:\r\n%@",limitPath]];
        }
        
    }
    
    
    //NSTimeInterval now = [[NSDate date]timeIntervalSince1970];
    
    //Added By Vito 20210306
    //
    [_KNoIndex removeAllObjects];
    for (int i=0; i < [_data count]; i++) {
        [_KNoIndex addObject:@(i)];
    }
    [filterSourceData removeAllObjects];
    [filterSourceData setArray:_data];
    [m_configDictionary setValue:[NSNumber numberWithBool:YES] forKey:K_dic_Load_Csv_Finished];
    //Add end
    
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationInitColorTable object:nil userInfo:nil];
    [self initRetestAndRemoveFailSeg];
    [self initColorByTableView];
    [m_configDictionary setValue:_ListAllItemNameArr forKey:k_All_Item_Name];
    
    
    //再次加载，需要init
    enableEditing = YES;
    clickItemIndex = -1;
    editLimitRow = -1;
    retestValue=@"";
    removeValue = @"";
    //NSLog(@"====load csv执行时间: %f",now-starttime);
    
    NSString *file1 = @"/tmp/CPK_Log/temp/cpk.png";//[NSString stringWithFormat:@"%@/CPK_Log/temp/cpk.png",desktopPath];
    [manager removeItemAtPath:file1 error:nil];
    NSString *picPath =[[NSBundle mainBundle]pathForResource:@"cpk.png" ofType:nil];
    [manager copyItemAtPath:picPath toPath:file1 error:nil];
    
    NSString *file2 = @"/tmp/CPK_Log/temp/correlation.png";//[NSString stringWithFormat:@"%@/CPK_Log/temp/correlation.png",desktopPath];
    [manager removeItemAtPath:file2 error:nil];
    NSString *picPath2 =[[NSBundle mainBundle]pathForResource:@"correlation.png" ofType:nil];
    [manager copyItemAtPath:picPath2 toPath:file2 error:nil];
    
    NSString *file3 = @"/tmp/CPK_Log/temp/scatter.png";//[NSString stringWithFormat:@"%@/CPK_Log/temp/scatter.png",desktopPath];
    [manager removeItemAtPath:file3 error:nil];
    NSString *picPath3 =[[NSBundle mainBundle]pathForResource:@"scatter.png" ofType:nil];
    [manager copyItemAtPath:picPath3 toPath:file3 error:nil];
    
    
    _lastLeftPaneWidth = self.leftPane.frame.size.width; //  remember current width to restore
    [self.splitView setPosition:0 ofDividerAtIndex:0];
     _lastLeftPaneWidth = 0;
    [self.splitView layoutSubtreeIfNeeded];
    [self.dataTableView setFocusRingType:NSFocusRingTypeNone];
    [self.dataTableView setAccessibilityFocused:YES];//isAccessibilityFocused
    //[[NSNotificationCenter defaultCenter]postNotificationName:kLoadGroupPanel object:nil userInfo:nil];
    
    [self setHiddenCol:NO];
  
    b_ClearComment = YES;
    
    
    //[[NSNotificationCenter defaultCenter]postNotificationName:kNotificationCloseStartUp object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationIndicatorMsg object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Wating Cpk & Bimodality metrics & Build Summary reports.",kStartupMsg,[NSNumber numberWithInt:MSG_LEVEL_NORMAL],kStartupLevel, [NSNumber numberWithFloat:8/n_loadStepCount], kStartupPercentage,nil]];
    
}

-(void)initRedisAndData
{
    NSString *file_cli = [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"redis-cli"] stringByReplacingOccurrencesOfString:@" " withString:@"\\ "];
    file_cli = [file_cli stringByReplacingOccurrencesOfString:@"(" withString:@"\\("];
    file_cli = [file_cli stringByReplacingOccurrencesOfString:@")" withString:@"\\)"];
    NSString *cli_Path = [NSString stringWithFormat:@"%@ flushall",file_cli];
    system([cli_Path UTF8String]);
    NSLog(@"-->redis flushall");
    //[@"" writeToFile:[NSString stringWithFormat:@"%@/CPK_Log/temp/.recordSelctItem.csv",desktopPath] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [@"" writeToFile:@"/tmp/CPK_Log/temp/.recordSelctItem.csv" atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    [m_configDictionary setValue:[NSNumber numberWithInteger:0] forKey:kChooseItemIndex];
    [m_configDictionary setValue:@"" forKey:kChooseItemName];
    
    [self sendStringToRedis:KSetPDF withData:@"0"];
    [self sendStringToRedis:KSetCDF withData:@"0"];
}

-(void)setHiddenCol:(BOOL)status
{
    NSTableColumn * colApply = [self.dataTableView tableColumnWithIdentifier:identifier_apply];
      [colApply setHidden:status];
      NSTableColumn *colLSL  = [self.dataTableView tableColumnWithIdentifier:identifier_lsl];
      [colLSL setHidden:status];
      NSTableColumn *colUSL  = [self.dataTableView tableColumnWithIdentifier:identifier_usl];
      [colUSL setHidden:status];
      NSTableColumn *colComment  = [self.dataTableView tableColumnWithIdentifier:identifier_comment];
      [colComment setHidden:status];
      NSTableColumn *colKeynote  = [self.dataTableView tableColumnWithIdentifier:identifier_keynote];
      [colKeynote setHidden:status];
      NSTableColumn *colDate  = [self.dataTableView tableColumnWithIdentifier:identifier_date];
      [colDate setHidden:status];
      NSTableColumn *colReviewer  = [self.dataTableView tableColumnWithIdentifier:identifier_reviewer];
      [colReviewer setHidden:status];
      NSTableColumn *colCpkNew  = [self.dataTableView tableColumnWithIdentifier:identifier_cpknew];
      [colCpkNew setHidden:status];
}


/*
-(void)changeXlsxTocsv:(NSString *)excelpath toTxt:(NSString *)txtpath
{
    NSString *launchPath = [self taskLaunchPath];//stringByReplacingOccurrencesOfString:@" " withString:@"\\ "];
//    NSString *launchPath = @"/Users/RyanGao/Desktop/cpk/BDA_package/BDR_ Tool/Bridge/FuncXlsx/Vector/usr/bin/FileConversion";
    NSMutableArray *args = [NSMutableArray arrayWithCapacity:0];
    [args addObject:@"txt"];
    [args addObject:excelpath];
    [args addObject:txtpath];
    [self launch:launchPath arguments:args index:0];
}

- (void)launch:(NSString *)launchPath arguments:(NSArray *)args index:(NSInteger)index {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:launchPath];
    [task setArguments:args];
    
    [self updateEnvironmentForTask:task];
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    [task setStandardError:pipe];

    [task launch];
}

- (void)updateEnvironmentForTask:(NSTask *)task {
    NSMutableDictionary *env = [NSMutableDictionary dictionaryWithDictionary:task.environment];
    [env removeObjectForKey:kMallocNanoZone];
    [task setEnvironment:env];
}

- (NSString *)taskLaunchPath {
    return [[self binDirectoryPath] stringByAppendingPathComponent:APCmdName];
}

- (void)fileHandleReadObserver:(NSPipe *)pipe {
    NSFileHandle *fileHandle = [pipe fileHandleForReading];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileHandleReadCompleted:) name:NSFileHandleReadToEndOfFileCompletionNotification object:fileHandle];
    [fileHandle readToEndOfFileInBackgroundAndNotify];
}

- (NSString *)binDirectoryPath {
    return [[self vectorDirectoryPath] stringByAppendingPathComponent:APCmdLocDirpath];
}
- (NSString *)vectorDirectoryPath {
    return [[NSBundle mainBundle] pathForResource:APVectorDirname ofType:nil];
}
 */

-(void)openSheet:(id)sender {
    if(!_modalCsvController)
    {
        _modalCsvController = [[loadCsvControl alloc] init];
    }
//    loadCsvControl *modalCsvController = [[loadCsvControl alloc] init];
//    _modalCsvController = modalCsvController;
//    NSLog(@"===<<>> begine");
    [self.viewWindow.window beginSheet:self.modalCsvController.window completionHandler:^(NSModalResponse returnCode)
    {
        switch (returnCode) {
            case NSModalResponseOK:
                NSLog(@"===***** OK");
                break;
            case NSModalResponseCancel:
                NSLog(@"===***** Cancel");
                break;
            default:
                break;
        }
    }];
     
}


-(NSString *)sendHashZmqMsg:(NSString *)name  //excel zmq
{
    int ret = [reportHashClient SendCmd:name];
    if (ret > 0)
    {
        NSString * response = [reportHashClient RecvRquest:1024];
        if (!response)
        {
            NSLog(@"zmq excel for python error");
        }
        NSLog(@"app->get response from excel python: %@",response);
        return response;
    }
    return nil;
}

-(BOOL)reloadUpdateLimit:(NSString *)limitPath dataPath:(NSString *)dataPath
{
//    BRAOfficeDocumentPackage *spreadsheet = [BRAOfficeDocumentPackage open:limitPath];
//    BRAWorksheet *worksheet =  [spreadsheet.workbook worksheetNamed:@"ssh"];
//    NSString *read_excel_hash = [[worksheet cellForCellReference:@"C7"] stringValue];
//    NSString *cellStr = [[worksheet cellForCellReference:@"C3"] stringValue];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationIndicatorMsg object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Start load and parse Excel file: %@.",[limitPath lastPathComponent]],kStartupMsg,[NSNumber numberWithInt:MSG_LEVEL_NORMAL],kStartupLevel,[NSNumber numberWithFloat:9/n_loadStepCount], kStartupPercentage, nil]];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *path_csv_hash = [NSString stringWithFormat:@"/tmp/CPK_Log/temp/%@_hash.csv",[[limitPath lastPathComponent] stringByDeletingPathExtension]];
    [manager removeItemAtPath:path_csv_hash error:nil];
    NSString *itemNameZmg = @"excel_hash_to_csv";
    
    NSMutableArray *msgArray = [NSMutableArray arrayWithObjects:limitPath,path_csv_hash,nil];
    NSLog(@"====excel==name:%@  data:%@",itemNameZmg,msgArray);
    [self sendDataToRedis:itemNameZmg withData:msgArray];
    [self sendHashZmqMsg:itemNameZmg];
    for (int i=0; i<20; i++)
    {
        [NSThread sleepForTimeInterval:1.0];
        if ([manager fileExistsAtPath:path_csv_hash])
        {
            break;
        }
        if (i==19)
        {
            [self AlertBox:@"Error:005" withInfo:@"Get Limit Update Excel sheet2 hash code error!!!"];
            return NO;
        }
    }
    CSVParser *csv_hash_data = [[CSVParser alloc]init];
    [hash_value removeAllObjects];
    if ([csv_hash_data openFile:path_csv_hash])
       {
           hash_value = [csv_hash_data parseFile];
       }
       if (!hash_value.count)
       {
           return NO;
       }
    NSLog(@"=>>>hash:::: %@",hash_value);
    if ([hash_value count]<8)
    {
        [self AlertBox:@"Error:006" withInfo:@"Hash code value miss!!!"];
        return NO;
    }
  
    NSString *limit_excel_table1_hash = hash_value[7][2];
    NSString *data_csv_hash = hash_value[2][2];
    
    NSString *limitCsv = @"/tmp/CPK_Log/temp/limit_update.csv";//[NSString stringWithFormat:@"%@/CPK_Log/temp/limit_update.csv",desktopPath];
    
    [manager removeItemAtPath:limitCsv error:nil];
    
    /*[self changeXlsxTocsv:limitPath toTxt:limitCsv];
    [NSThread sleepForTimeInterval:1.5];
    if (![manager fileExistsAtPath:limitCsv])
    {
        for (int i=0; i<5; i++)
        {
            [self changeXlsxTocsv:limitPath toTxt:limitCsv];
            [NSThread sleepForTimeInterval:3*i];
            if ([manager fileExistsAtPath:limitCsv])
            {
                break;
            }
        }
    }
    */
    
    NSMutableArray *msgArraycsv = [NSMutableArray arrayWithObjects:limitPath,limitCsv,nil];
    NSString *itemNameCsv = @"excel_limit_update_to_csv";
    [self sendDataToRedis:itemNameCsv withData:msgArraycsv];
    [self sendHashZmqMsg:itemNameCsv];
    
    for (int i=0; i<20; i++)
    {
        [NSThread sleepForTimeInterval:1.0];
        if ([manager fileExistsAtPath:limitCsv])
        {
            break;
        }
        if (i==19)
        {
            [self AlertBox:@"Error:007" withInfo:@"Calculate Limit Update Excel sheet1 for hash code error!!!"];
            return NO;
        }
    }
    
    
    NSString *excel_table1 = [self opensslSha1FilePath:limitCsv];
    
    if (![limit_excel_table1_hash isEqualToString:excel_table1])
    {
        [self AlertBox:@"Error:008" withInfo:@"Limit Update Excel has been modified, it will be not load!!!"];
        return NO;
    }
    
    
    NSString *hash_code_raw_Data = [self opensslSha1FilePath:dataPath];
    NSLog(@"data file %@: %@",dataPath,hash_code_raw_Data);
    if (![data_csv_hash isEqualToString:hash_code_raw_Data])
    {
        [self AlertBox:@"Error:009" withInfo:@"Limit Update Excel is not match raw CSV data, it will be not load!"];
        return NO;
    }
    
    
    
    CSVParser *csv = [[CSVParser alloc]init];
    if ([csv openFile:limitCsv])
    {
        _limitUpdateData = [csv parseFile];
    }
    if (!_limitUpdateData.count)
    {
        return NO;
    }

    NSString *limitExcelName=[[limitPath lastPathComponent] stringByDeletingPathExtension];
    NSArray *arrN = [limitExcelName componentsSeparatedByString:@"_"];
    NSString *reviewer = @"";
    NSString *update_date = @"";
    if ([arrN count]>6)
    {
        reviewer = arrN[2];
        update_date = arrN[6];
    }
    for (int j = 0; j<[_limitUpdateData count]; j++)
    {
        //NSLog(@"====>>>_limitUpdateData : %zd",[_limitUpdateData[j] count]);
        if (!([_limitUpdateData[j] count]==27 || [_limitUpdateData[j] count]==28 || [_limitUpdateData[j] count]==29))  //因为删除了p_val,所以由之前的28 改为27
        {
            [self AlertBox:@"Error:010" withInfo:[NSString stringWithFormat:@"Limit update file :%@ format error!!!",limitPath]];
            return NO;
        }
        /*NSString *newLowerLimit = [_limitUpdateData[j][18] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *newUpperLimit = [_limitUpdateData[j][20] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        NSString *reviewer_name = [_limitUpdateData[j][25] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *reviewer_date = [_limitUpdateData[j][26] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *user_comment = [_limitUpdateData[j][27] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
         */
        //因为删除了p_val,所以由之前的28 改为27,add BM colomn, then is 29
        
        NSString *newLowerLimit = @"";
        NSString *newUpperLimit = @"";
        NSString *reviewer_name = @"";
        NSString *reviewer_date = @"";
        NSString *user_comment = @"";
        
        if ([_limitUpdateData[j] count]==27)
        {
            newLowerLimit = [_limitUpdateData[j][updatelimit_newLower-1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            newUpperLimit = [_limitUpdateData[j][updatelimit_newUpper-1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            reviewer_name = [_limitUpdateData[j][updatelimit_reviewer_name-1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            reviewer_date = [_limitUpdateData[j][updatelimit_reviewer_date-1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            user_comment = [_limitUpdateData[j][updatelimit_user_comment-1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        }
        else if ([_limitUpdateData[j] count]==28)
        {
            newLowerLimit = [_limitUpdateData[j][updatelimit_newLower] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            newUpperLimit = [_limitUpdateData[j][updatelimit_newUpper] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            reviewer_name = [_limitUpdateData[j][updatelimit_reviewer_name] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            reviewer_date = [_limitUpdateData[j][updatelimit_reviewer_date] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            user_comment = [_limitUpdateData[j][updatelimit_user_comment] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
        }
        else if ([_limitUpdateData[j] count]==29)
        {
            newLowerLimit = [_limitUpdateData[j][updatelimit_newLower+1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            newUpperLimit = [_limitUpdateData[j][updatelimit_newUpper+1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            reviewer_name = [_limitUpdateData[j][updatelimit_reviewer_name+1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            reviewer_date = [_limitUpdateData[j][updatelimit_reviewer_date+1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            user_comment = [_limitUpdateData[j][updatelimit_user_comment+1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
        }
        
        if ([newLowerLimit isNotEqualTo:@""] || [newUpperLimit isNotEqualTo:@""]||[reviewer_name isNotEqualTo:@""] ||[reviewer_date isNotEqualTo:@""] || [user_comment isNotEqualTo:@""])
        {
            for (int k=0; k<[_data count]; k++)
            {
                if ([_limitUpdateData[j][1] isEqualTo:_data[k][tb_item]])
                {
   

                    if ([newLowerLimit isNotEqualTo:@""] && [newUpperLimit isNotEqualTo:@""])
                    {
                        
                        _data[k][tb_lsl] = newLowerLimit;   //new lsl
                        _data[k][tb_usl] = newUpperLimit;   //new lsl
                        //_data[k][tb_apply] = [NSNumber numberWithInt:1];  //apply
                        _data[k][tb_apply] = [NSNumber numberWithInt:0];
                    }
                    else if([newLowerLimit isNotEqualTo:@""] && [newUpperLimit isEqualToString:@""])
                    {
                        _data[k][tb_lsl] = newLowerLimit;   //new lsl
                        _data[k][tb_usl] = @"NA";   //new lsl
                        //_data[k][tb_apply] = [NSNumber numberWithInt:1];  //apply
                        _data[k][tb_apply] = [NSNumber numberWithInt:0];
                        
                    }
                    else if([newLowerLimit isEqualToString:@""] && [newUpperLimit isNotEqualTo:@""])
                    {
                        _data[k][tb_lsl] = @"NA";   //new lsl
                        _data[k][tb_usl] = newUpperLimit;   //new lsl
                        //_data[k][tb_apply] = [NSNumber numberWithInt:1];  //apply
                        _data[k][tb_apply] = [NSNumber numberWithInt:0];
                        
                    }
                    else
                    {
                         _data[k][tb_apply] = [NSNumber numberWithInt:0];  //apply
                    }
                   
                    if([reviewer_name isNotEqualTo:@""])
                    {
                        _data[k][tb_reviewer] = reviewer_name;
                        
                        if ([newLowerLimit isEqualToString:@""] && [newUpperLimit isEqualToString:@""])
                        {
                            _data[k][tb_lsl] = @"NA";   //new lsl
                            _data[k][tb_usl] = @"NA";   //new lsl
                        }
                        
                    }
                    else
                    {
                        _data[k][tb_reviewer] = reviewer;
                    }
                        
                    
                    //if([_limitUpdateData[j][26] isNotEqualTo:@""])
                    if([reviewer_date isNotEqualTo:@""])
                    {
                        _data[k][tb_date] = reviewer_date;
                    }
                    else
                    {
                        _data[k][tb_date] = update_date;
                    }
                    
                    if ([user_comment isNotEqualTo:@""])
                    {
                        _data[k][tb_comment] = user_comment;
                    }
                    
                    [_reviewerNameIndex addObject:[NSNumber numberWithInt:k]];
                   
                    break;
                }
            }
        }
        
    }
    
    [self.dataTableView reloadData];
    [self.txtLimitUpdate setStringValue:[limitPath lastPathComponent]];
    
    
    
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationIndicatorMsg object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Load and parse Excel file done.",kStartupMsg,[NSNumber numberWithInt:MSG_LEVEL_NORMAL],kStartupLevel,[NSNumber numberWithFloat:10/n_loadStepCount], kStartupPercentage, nil]];
    
    return YES;
}
-(BOOL)reloadScriptDataWithPath:(NSString *)path dataPath:(NSString *)dataPath
{
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationIndicatorMsg object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Start load and parse script file: %@.",[path lastPathComponent]],kStartupMsg,[NSNumber numberWithInt:MSG_LEVEL_NORMAL],kStartupLevel,[NSNumber numberWithFloat:7/n_loadStepCount], kStartupPercentage, nil]];
    
    NSString *scriptFileName=[[path lastPathComponent] stringByDeletingPathExtension];
    NSArray *vers = _dataReverse[n_Version_Col];

    if (![vers containsObject:scriptFileName])
    {
        NSArray *scriptName = [scriptFileName componentsSeparatedByString:@"__"];
        if ([scriptName count]>1)
        {
            NSString *scriptName1 = [NSString stringWithFormat:@"%@__%@",scriptName[0],scriptName[1]];// 根据 两个下划线拆分
            NSString *scriptName2 = [NSString stringWithFormat:@"%@__%@",scriptName[1],scriptName[0]];// 根据 两个下划线拆分
            if (![vers containsObject:scriptName1] ||![vers containsObject:scriptName2])
            {
                //[self AlertBox:@"error!" withInfo:@"Load test script version can not match test data, it will be not loading!!!"];
                /*int ret = [self AlertBoxWith2Button:@"error" withInfo:@"Load test script version can not match test data. \r\nClick OK it will be loading,click Cancel it will be not loading!!!!"];
                if (ret == 1001)  //cancel not load
                {
                    return NO;
                }
                 */
            }
            
        }
        else
        {
             if (![vers containsObject:scriptName[0]])
             {
//                 [self AlertBox:@"error!" withInfo:@"Load test script version can not match test data, it will be not loading!!!"];
                 
                /* int ret = [self AlertBoxWith2Button:@"error" withInfo:@"Load test script version can not match test data.\r\nClick OK it will be loading,click Cancel it will be not loading!!!"];
                 if (ret == 1001)  //cancel not load
                 {
                     return NO;
                 }
                 */
             }
             
        }
   
        
    }

    
    [_scriptData removeAllObjects];
    CSVParser *csv = [[CSVParser alloc]init];
    if ([csv openFile:path])
    {
        _scriptData = [csv parseFile];
    }
    if (!_scriptData.count)
    {
        return NO;
    }
    
    NSMutableArray *dataBackupTmp = [NSMutableArray array];
    [dataBackupTmp setArray:_data];
    
    int n_testname = -1;
    int n_subtestname = -1;
    int n_subsubtestname = -1;
    int n_discribe = -1;
    int n_lowlimit = -1;
    int n_highlimit = -1;
    
    int n_param1 = -1;
    int n_unit = -1;
    
    //NSMutableArray *mutArrayReverse = [NSMutableArray arrayWithArray:[self reverseArray:_scriptData]];
    ///NSMutableArray *mutArrayReverse = nil;//[NSMutableArray arrayWithArray:[self ]];
    
    for (int i=0; i<[_scriptData[0] count]; i++)
    {
         if ([_scriptData[0][i] isEqualToString:@"TESTNAME"] )
         {
              n_testname = i;
         }
        else if([_scriptData[0][i] isEqualToString:@"SUBTESTNAME"] )
        {
            n_subtestname = i;
        }
        else if([_scriptData[0][i] isEqualToString:@"SUBSUBTESTNAME"] )
        {
             n_subsubtestname = i;
        }
        else if([_scriptData[0][i] isEqualToString:@"DESCRIPTION"] )
        {
            n_discribe = i;
        }
        else if([_scriptData[0][i] isEqualToString:@"LOW"] )
        {
            n_lowlimit = i;
        }
        else if([_scriptData[0][i] isEqualToString:@"HIGH"] )
        {
            n_highlimit = i;
        }
        else if([_scriptData[0][i] isEqualToString:@"PARAM1"] )
        {
            n_param1 = i;
        }
        else if([_scriptData[0][i] isEqualToString:@"UNIT"] )
        {
            n_unit = i;
        }
        
    }

    if (n_testname>=0 && n_subtestname>=0&&n_subsubtestname>=0&&n_discribe>=0 && n_lowlimit>=0 && n_highlimit>=0 && n_param1 >0 && n_unit>0)
    {
     
    }
    else
    {
        [self AlertBox:@"Error:011" withInfo:@"Script format error!!!"];
        return NO;
    }
    
    

    [_textEditLimitDic removeAllObjects];
    
    NSMutableArray *ItemNameArrBackup = [NSMutableArray array];
    [ItemNameArrBackup setArray:_ListAllItemNameArr];
    
    NSMutableArray *categoryArr = [NSMutableArray array];  //找到 ItemNameArrBackup 不相同的item
    NSMutableArray *sameItemArr = [NSMutableArray array];  //找到 ItemNameArrBackup 有相同的item
    for (int i=0; i<[ItemNameArrBackup count]; i++)
    {
         if ([categoryArr containsObject:[ItemNameArrBackup objectAtIndex:i]]==NO)
               {
                   [categoryArr addObject:[ItemNameArrBackup objectAtIndex:i]];
               }
               else
               {
                   
                  [sameItemArr addObject:[ItemNameArrBackup objectAtIndex:i]];
               }
    }
    
    
    
    NSMutableArray * newArr = [NSMutableArray array]; //保存脚本与insight 匹配数据
    NSMutableArray * arrSameItemIndex = [NSMutableArray array];  //找到相同item 的index
    NSMutableArray * scriptTestName = [NSMutableArray array];
    int n_scriptDat = 0;  //确保不在空元素上索引
    
    NSMutableArray *indexBig =[[NSMutableArray alloc] init];
    [indexBig addObject:@(n_testname)];
    [indexBig addObject:@(n_subtestname)];
    [indexBig addObject:@(n_subsubtestname)];
    [indexBig addObject:@(n_discribe)];
    [indexBig addObject:@(n_lowlimit)];
    [indexBig addObject:@(n_highlimit)];
    [indexBig addObject:@(n_param1)];
    [indexBig addObject:@(n_unit)];
    
    CGFloat max =[[indexBig valueForKeyPath:@"@max.intValue"] intValue];
    
    
    try {
        
        
        for (int n_index=0; n_index<[_scriptData count]; n_index++)  //i=0 is the test name
        {
            
            
        
            if ([_scriptData[n_index] count]>=max+1)  //至少12列,去除脚本空行
            {
                NSString *testName = [NSString stringWithFormat:@"%@ %@ %@",[_scriptData[n_index][n_testname]   stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]],[_scriptData[n_index][n_subtestname]   stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]],[_scriptData[n_index][n_subsubtestname]    stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
                [scriptTestName addObject:testName];
                NSString *describe = _scriptData[n_index][n_discribe];
                
                NSString *lowLimit = _scriptData[n_index][n_lowlimit];
                NSString *highLimit = _scriptData[n_index][n_highlimit];
                NSString *command = _scriptData[n_index][n_param1];
                NSString *scropt_unit = _scriptData[n_index][n_unit];
                //NSLog(@"===command: %@",command);
        
                int m = -1;
                for (int j=0; j<[ItemNameArrBackup count]; j++)
                {
                     if ([ItemNameArrBackup[j] isEqualToString:testName])  //找到脚本与insight 数据相同的item，把数据插入与脚本相同的item     里面加进去，第一列index 显示绿色。 注意：是插入对应item 里面的数据
                     {
                         [newArr addObject:dataBackupTmp[j]];
                         newArr[n_scriptDat][tb_index]= [NSNumber numberWithInt:n_scriptDat];  //UI index
                         newArr[n_scriptDat][tb_description]= describe;  // UI description
                         newArr[n_scriptDat][tb_command]= command;  //
                         newArr[n_scriptDat][tb_reviewer]= @"";  //
                         newArr[n_scriptDat][tb_date]= @"";  //
        
                         [arrSameItemIndex addObject:[NSNumber numberWithInt:j]];
                         [_colorGreenIndex addObject:[NSNumber numberWithInt:n_scriptDat-1]];  //因为第一行要删除，第一行是Test  Name，所以不可能能匹配到，索引变成0 开始
                         m=j;
                         //NSLog(@"====>>>>>> same item: %@    %d",testName,n_scriptData);
                         break;
                     }
        
        
                }
        
                if (m<0)  //没有找到脚本与insight 相同的item，显示脚本顺序，不插入insight 数据
                {
                            [newArr addObject:_scriptData[n_index]];
                            newArr[n_scriptDat][tb_index]= [NSNumber numberWithInteger:n_scriptDat];  //UI index
                            newArr[n_scriptDat][tb_item]= testName;   //UI item;
                            newArr[n_scriptDat][tb_lower]= lowLimit;   //UI lower;
                            newArr[n_scriptDat][tb_upper]= highLimit;   //UI upper;
                            newArr[n_scriptDat][tb_display_name]= @"";
                            newArr[n_scriptDat][tb_PDCA_priority]= @"";
                            newArr[n_scriptDat][tb_measurement_unit]= scropt_unit;
        
                                                                          // number 6 is unit
                            newArr[n_scriptDat][tb_lsl]= @"";  // UI new LSL
                            newArr[n_scriptDat][tb_usl]= @"";  // UI new USL
                            newArr[n_scriptDat][tb_apply]= [NSNumber numberWithInteger:0];  // UI apply button
                            newArr[n_scriptDat][tb_description]= describe;  // UI description
        
                            newArr[n_scriptDat][tb_command]= command;  //
                            newArr[n_scriptDat][tb_reviewer]= @"";  //
                            newArr[n_scriptDat][tb_date]= @"";  //
        
                            newArr[n_scriptDat][tb_comment]= @"";  // UI i_irr
                            newArr[n_scriptDat][tb_3cv]= @"";  // UI 3CV
        
                            newArr[n_scriptDat][tb_cpk_orig]=@"";
                            newArr[n_scriptDat][tb_bmc]=@"";
                            newArr[n_scriptDat][tb_zoom_type]=@"";
        
                            newArr[n_scriptDat][tb_bins]= [NSNumber numberWithInteger:250];  // UI界面设置的bin值
                            newArr[n_scriptDat][20]= @"";  //zmq 传过给python的item 名字
                            newArr[n_scriptDat][21]= @"2020/0/0 00:00:00";                               //设置cpk start 开始时间
                            newArr[n_scriptDat][22]= @"2020/0/0 10:00:00";                               //设置cpk start结束 时间
                            newArr[n_scriptDat][tb_keynote]=@"";
                            newArr[n_scriptDat][24]=@"";//设置生成报告的 a_L
                            newArr[n_scriptDat][25]=@"";//设置生成报告的 a_M
                            newArr[n_scriptDat][tb_correlation_xy]=@"";
                            newArr[n_scriptDat][27]=@"";//设置生成报告的 a_U
                            newArr[n_scriptDat][28]=@"";//设置生成报告的 a_Q
                            newArr[n_scriptDat][29]=@"";//设置生成报告的 a_irr
                            newArr[n_scriptDat][30]=[NSString stringWithFormat:@"%@/CPK_Log",desktopPath];//设置log文件路径 /桌面/CPK_Log
                            newArr[n_scriptDat][tb_color_by_left]= [NSNumber numberWithInteger:0];  //设置color By左边那个
                            newArr[n_scriptDat][tb_color_by_right]= [NSNumber numberWithInteger:0];  //设置color By右边那个
                            newArr[n_scriptDat][button_select_x]= [NSNumber numberWithInteger:0];
                            newArr[n_scriptDat][button_select_y]= [NSNumber numberWithInteger:0];
                            newArr[n_scriptDat][tb_script_flag]= [NSNumber numberWithInteger:1];
                            newArr[n_scriptDat][tb_data]= Start_Data;  //all the test data below
        
        
    
        
                }
                n_scriptDat++;
        
            }
            else{
                if([_scriptData[n_index] count] ==1 ){
                    
                
                    
                }
                else{
                    NSString * info= [NSString stringWithFormat:@"Test script Parse Line Error \n line with cloum count: %d \n line:%@",[_scriptData[n_index] count] ,_scriptData[n_index]];
                    [self AlertBox:@"Warning\nLoad Script Failed" withInfo:info];
                }
                
                
            }
        }
    } catch (exception e) {
        NSString * info= [NSString stringWithFormat:@"Test script Parse Line Error \n %s",e.what() ];
        [self AlertBox:@"Error:Load Scripte" withInfo:info];
        return NO;
    }

    [m_configDictionary setValue:scriptTestName forKey:KItemNameScript];
    //NSLog(@"====>相同项目 index: %@    newArr count: %zd ",arrSameItemIndex,[newArr count]);
    if ([arrSameItemIndex count] >0)  //不匹配的数据追加在后面
    {
        int n_num = (int)[newArr count];  //前面显示的脚本的总数量，后面在脚本的总数量上，追加不匹配的数据
        int n_row=n_num;   //后面追加数据，开始的行号
        for (int i=0; i<[dataBackupTmp count]; i++)
        {
            //后面显示红色，由于data 数据有重复的item，导致脚本显示了，后面还有重复的，其实是匹配的，是由于其他数据有重复item
                if (![sameItemArr containsObject:dataBackupTmp[i][tb_item]])
                {
                    if (![arrSameItemIndex containsObject:[NSNumber numberWithInt:i]])//去除相同的item 以后，把剩下insight data 追加显示在后面，第显示 红色
                    {
                        [newArr addObject:dataBackupTmp[i]];
                        newArr[n_row][tb_index]= [NSNumber numberWithInt:n_row];  //UI index
                        [_colorRedIndex addObject:[NSNumber numberWithInt:n_row-1]];
                        n_row++;
                        
                    }
                }
             
        }
    }
    else
    {
        [self AlertBox:@"Error:025" withInfo:@"Test data and test script total mismatch."];
        return NO;
        
    }
    //
    if ([_colorGrayIndex count] != [_data count] - [_colorRedIndex count] - [_colorGreenIndex count]) {
        _colorGrayIndex = [NSMutableArray arrayWithCapacity:[_data count]];
        for (int j=0; j<[_data count]; j++) {
            if (!([_colorRedIndex containsObject:@(j)] || [_colorGreenIndex containsObject:@(j)])) {
                [_colorGrayIndex addObject:@(j)];
            }

        }
    }
    
    if ([_colorRedIndex count]>0)
    {
        if ([_colorRedIndex count]>20)
        {
            NSInteger red_numbers = [_colorRedIndex count];
            [_colorRedIndex removeAllObjects];
            [_colorGreenIndex removeAllObjects];
            [_colorGrayIndex removeAllObjects];
            [m_configDictionary setValue:@"" forKey:Load_Script_Path];
            for (int m=0; m<[_data count]; m++)
            {
                _data[m][tb_index]= [NSNumber numberWithInteger:m+1];
            }
            //[self AlertBox:@"Error:026" withInfo:[NSString stringWithFormat:@"Test data and test script have %zd items mismatch, more than 20 items.\nOnly load insight data.",red_numbers]];
            
            [self AlertBox:@"Error:026" withInfo:[NSString stringWithFormat:@"Insight test data has %zd of test items that don’t exist in the chosen test script. Ignore loading the test script. Only loading Insight test data",red_numbers]];
            
            
            
            
            return NO;
            
            //NSString * mismatch = [NSString stringWithFormat:@"Test data and test script have %zd items mismatch, more than 20 items.\r\n\r\nIf you click OK, it will force load test data and script,mismatch items are list at the end(red color).\r\n\r\nIf you click Cancel button, it will only load test data.",[_colorRedIndex count]];
            //int ret = [self AlertBoxWith2Button:@"Warning!!!" withInfo:mismatch];
            
            /*if (ret == 1001)  //cancel not load
            {
                [_colorRedIndex removeAllObjects];
                [_colorGreenIndex removeAllObjects];
                [_colorGreenIndexBackup removeAllObjects];
                [_colorRedIndexBackup removeAllObjects];
                [_data removeAllObjects];
                
                for (int i=0; i<[dataBackupTmp count]; i++)
                {
                    [_data addObject:dataBackupTmp[i]];
                    _data[i][tb_index]= [NSNumber numberWithInteger:i+1];   //UI index
                }
                
                [self.dataTableView reloadData];
                return NO;
            }
            */
        }
        else
        {
            //NSString * mismatch = [NSString stringWithFormat:@"Test insight data and test script have %zd items mismatch,they can all load in.\nMismatch items are list at the end(red color).",[_colorRedIndex count]];
            
            NSString * mismatch = [NSString stringWithFormat:@"Insight test data has %zd of test items that don’t exist in the chosen test script. These are shown at the end in RED color. Continue to load Insight test data and chosen test script",[_colorRedIndex count]];
            
            
            [self AlertBox:@"Warning!!!" withInfo:mismatch];
        }
    }
    
    

    [newArr removeObjectAtIndex:0];  //删除脚本数据TestName subTestName第一条名称删除
   
    NSMutableArray *dataReversBackupTmp = [NSMutableArray array];
    for (int i=0; i<[_dataReverse count]; i++)
    {
        if (i<n_Start_Data_Col)
        {
            [dataReversBackupTmp addObject:_dataReverse[i]];
        }
    }
    
    [_ListAllItemNameArr removeAllObjects];
    [_indexItemNameDic removeAllObjects];
    

     for (int i=0; i<[newArr count]; i++)
     {
         [dataReversBackupTmp addObject:newArr[i]];
         
         NSString * testName = newArr[i][tb_item];
         [_indexItemNameDic setValue:testName forKey:[NSString stringWithFormat:@"%d",i]];  //设置load script脚本以后，数据显示字典。 注意之前load insight 数据设置一次，如果load脚本，再设置一次。
         
         int nValue =  [newArr[i][tb_index] intValue] - 1;
         

         
         [_ListAllItemNameArr addObject:testName];     //设置load script脚本以后，数据显示数据item 名字，后面根据item 名字，找到对应数组索引
    
     }
     
    _dataReverse = dataReversBackupTmp;
    [_data setArray:newArr];
    [self.dataTableView reloadData];
    [_sortDataBackup removeAllObjects];
    [_sortDataBackup setArray:_data];
    [_colorGreenIndexBackup setArray:_colorGreenIndex];
    [_colorRedIndexBackup setArray:_colorRedIndex];
    
    
    //Added By Vito
    if ([_colorGrayIndex count] != [_data count] - [_colorRedIndex count] - [_colorGreenIndex count]) {
        _colorGrayIndex = [NSMutableArray arrayWithCapacity:[_data count]];
        for (int j=0; j<[_data count]; j++) {
            if (!([_colorRedIndex containsObject:@(j)] || [_colorGreenIndex containsObject:@(j)])) {
                [_colorGrayIndex addObject:@(j)];
            }

        }
    }
    //Add End
    
    [tmpColorArr removeAllObjects];
    [tmpColorArr setArray:_data];
    
    NSMutableString *itemStr = [NSMutableString string];
    for (int i=0; i<[_ListAllItemNameArr count]; i++)
    {
        [itemStr appendString:[NSString stringWithFormat:@"%d,%@\n",i+1,_ListAllItemNameArr[i]]];
    }
    [itemStr writeToFile:KdataItemNamePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationReloadReportTags object:nil userInfo:nil];
    [m_configDictionary setObject:_colorGreenIndex forKey:KGreenColorIndex];
    [m_configDictionary setObject:_colorRedIndex forKey:KRedColorIndex];
    
    NSMutableArray *csvTit = [NSMutableArray array];
    for (int i = 0; i<n_Start_Data_Col; i++)
    {
        [csvTit addObject:_dataReverse[i]];
    }
    
    NSMutableArray * csvData = [NSMutableArray array];  //按照脚本规则写csv 数据
    for (int i=0; i<[newArr count]; i++)
    {
        [csvData addObject:newArr[i]];
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
    
    //NSString *dataFileName=[[dataPath lastPathComponent] stringByDeletingPathExtension];
    //NSString *csv_Path = [NSString stringWithFormat:@"%@/CPK_Log/%@&%@.csv",desktopPath,dataFileName,scriptFileName];
    //NSLog(@"->csv_path: %@",csv_Path);
    
    // write csv file
    /*
     NSError *error = nil;
    [csvStr writeToFile:csv_Path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error)
    {
        [self AlertBox:@"Failed" withInfo:[NSString stringWithFormat:@"Write file to path failed!!!\r\n%@",csv_Path]];
    }
    else
    {
        [self AlertBox:@"Success" withInfo:[NSString stringWithFormat:@"Write file to path Successful!!!\r\n%@",csv_Path]];
    }
     */
    [self.txtScriptName setStringValue:[path lastPathComponent]];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationIndicatorMsg object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Load and parse script file done.",kStartupMsg,[NSNumber numberWithInt:MSG_LEVEL_NORMAL],kStartupLevel, [NSNumber numberWithFloat:8/n_loadStepCount], kStartupPercentage,nil]];
    
    return YES;
    
}


-(BOOL)reloadLocalDataWithPath:(NSString *)path  // local data
{
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationIndicatorMsg object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Start load file: %@.",[path lastPathComponent]],kStartupMsg,[NSNumber numberWithInt:MSG_LEVEL_NORMAL],kStartupLevel,[NSNumber numberWithFloat:2/n_loadStepCount], kStartupPercentage,nil]];
    
    b_isCustomCSV = NO;
    NSTimeInterval starttime = [[NSDate date]timeIntervalSince1970];
    CsvHandle handle = CsvOpen([path UTF8String]);
    if (!handle)
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationIndicatorMsg object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Load file error.",kStartupMsg,[NSNumber numberWithInt:MSG_LEVEL_ERROR],kStartupLevel, [NSNumber numberWithFloat:3/n_loadStepCount], kStartupPercentage,nil]];
        return NO;
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationIndicatorMsg object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Load file %@ done.",[path lastPathComponent]],kStartupMsg,[NSNumber numberWithInt:MSG_LEVEL_NORMAL],kStartupLevel,[NSNumber numberWithFloat:3/n_loadStepCount], kStartupPercentage,nil]];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationIndicatorMsg object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Parse file to array. Please be patient. It may take a while, depending on file size.",kStartupMsg,[NSNumber numberWithInt:MSG_LEVEL_NORMAL],kStartupLevel,[NSNumber numberWithFloat:4/n_loadStepCount], kStartupPercentage,nil]];
    char* row = NULL;
    unsigned rowcount = 0;
    unsigned colcount = 0;
    NSMutableArray *rawDataTmp = [NSMutableArray array];
    while ((row = CsvReadNextRow(handle)))
    {
        const char* col = NULL;
        rowcount++;
        NSMutableArray *rawDataTmp_row = [NSMutableArray array];
        while ((col = CsvReadNextCol(row, handle)))
        {
            [rawDataTmp_row addObject:[NSString stringWithFormat:@"%s",col]];
            colcount++;
        }
        if ([rawDataTmp_row count]>0)
        {
            [rawDataTmp addObject:rawDataTmp_row];
            if ((rowcount-1) %100 ==0) {//????
                [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationIndicatorMsg object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@".",kStartupMsg,[NSNumber numberWithInt:MSG_LEVEL_NORMAL],kStartupLevel,[NSNumber numberWithFloat:100.0+(rowcount-1)/100], kStartupPercentage, nil]];
            }
            
        }
        
    }
    CsvClose(handle);
    

    
    if (!rawDataTmp.count)
    {
        [self AlertBox:@"Error:20" withInfo:@"Load date is empty."];
        return NO;
    }
    [m_configDictionary setValue:rawDataTmp forKey:KrawDataTmp];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationIndicatorMsg object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Start load file to custom setting panel, please wait...",kStartupMsg,[NSNumber numberWithInt:MSG_LEVEL_NORMAL],kStartupLevel,[NSNumber numberWithFloat:9/n_loadStepCount], kStartupPercentage,nil]];
    
    // row
    int n_itemnameRow = -1;
    NSString *upperRow = @"";
    NSString *lowerRow = @"";
    NSString *unitRow = @"";
    int n_dataStartRow = -1;
  
    // column
    int n_Start_Data_Col_tmp = -1;  //test item start
    int n_Pass_Fail_Status_tmp = -1;
    int n_SerialNumber_tmp = -1;
    int n_StartTime_tmp = -1;
    int n_Product_Col_tmp =-1;
    int n_StationID_Col_tmp =-1;
    int n_Version_Col_tmp =-1;
    int n_ListOfFail_Col_tmp =-1;
    int n_SlotId_Col_tmp =-1;

    int n_SpecialBuildName_Col_tmp = -1;
    int n_Special_Build_Descrip_Col_tmp =-1;
    int n_Diags_Version_Col_tmp = -1;
    int n_OS_VERSION_Col_tmp = -1;
    
    customWinController *customWin = [[customWinController alloc] initWithWindowNibName:@"customWinController"];
    [customWin.window center];
    NSModalResponse result = [NSApp runModalForWindow:customWin.window];
    if (result == NSModalResponseOK)
    {
        b_isCustomCSV = YES;
        //row
        n_itemnameRow =  [[m_configDictionary valueForKey:KcustomCsvStartRow] intValue];
        upperRow = [m_configDictionary valueForKey:KcustomCsvUpperLimitRow];
        lowerRow = [m_configDictionary valueForKey:KcustomCsvLowerLimitRow];
        unitRow = [m_configDictionary valueForKey:KcustomCsvUnitRow];
        n_dataStartRow = [[m_configDictionary valueForKey:KcustomCsvDataStartRow] intValue];
        
        //column
        n_Start_Data_Col_tmp = [[m_configDictionary valueForKey:KcustomCsvStartItemCol] intValue];
        n_Pass_Fail_Status_tmp = [[m_configDictionary valueForKey:KcustomCsvPassFailCol] intValue];
        n_SerialNumber_tmp = [[m_configDictionary valueForKey:KcustomCsvSerialNumberCol] intValue];
        n_StartTime_tmp = [[m_configDictionary valueForKey:KcustomCsvStartTimeCol] intValue];  // if NA, it is 900000
        n_Product_Col_tmp = [[m_configDictionary valueForKey:KcustomCsvProductCol] intValue];  // if NA, it is 900001
        n_StationID_Col_tmp = [[m_configDictionary valueForKey:KcustomCsvStationIdCol] intValue]; //if NA, it is 900002
        n_Version_Col_tmp = [[m_configDictionary valueForKey:KcustomCsvVersionCol] intValue]; //if NA, it is 900003
        n_ListOfFail_Col_tmp = [[m_configDictionary valueForKey:KcustomCsvListOfFailCol] intValue]; //if NA, it is 900004
        n_SlotId_Col_tmp = [[m_configDictionary valueForKey:KcustomCsvSlotIdCol] intValue]; //if NA, it is 900005
        //NSLog(@">>csv setting win ok : %d %d %d %d %d %d %d",n_itemnameRow,n_Pass_Fail_Status_tmp,n_SerialNumber_tmp,n_StartTime_tmp,n_Product_Col_tmp,n_StationID_Col_tmp,n_StationID_Col_tmp);
        
    }
    else if (result == NSModalResponseCancel)
    {
        NSLog(@">>csv setting win cancel");
        return NO;
    }
    
    
            
    [_data removeAllObjects];
    [_dataReverse removeAllObjects];
    [_rawData removeAllObjects];
    
    NSMutableArray *arrReverse1_tmp = [NSMutableArray arrayWithArray:[self reverseArray:rawDataTmp]]; // 构建第一列
    [arrReverse1_tmp insertObject:@[@""] atIndex:0];  //??
    _rawData = [NSMutableArray arrayWithArray:[self reverseArray:arrReverse1_tmp]];
    
    [_indexItemNameDic removeAllObjects];
    [_textEditLimitDic removeAllObjects];
    [_ListAllItemNameArr removeAllObjects];
    
    [_colorRedIndex removeAllObjects];
    [_colorGreenIndex removeAllObjects];
    [_colorGrayIndex removeAllObjects];
    [_colorRedIndexBackup removeAllObjects];
    [_colorGreenIndexBackup removeAllObjects];
    
    [_colorRedIndexCpk removeAllObjects];
    [_colorGreenIndexCpk removeAllObjects];
    [_colorYellowIndexCpk removeAllObjects];
    [_colorRedIndexCpkBackup removeAllObjects];
    [_colorGreenIndexCpkBackup removeAllObjects];
    [_colorYellowIndexCpkBackup removeAllObjects];
    
    [_reviewerNameIndex removeAllObjects];
    //[_bmcNoIndex removeAllObjects];  not put here, put in set parameters
    //[_bmcYesIndex removeAllObjects];

    [_limitUpdateData removeAllObjects];
    
    [tmpColorArr removeAllObjects];
    [_sortDataBackup removeAllObjects];
    [_dataBackup removeAllObjects];
    
    
    
    
    n_Start_Data_Col = n_Start_Data_Col_tmp+1;  // 构建第一列，所有都后移1位
    n_Pass_Fail_Status = n_Pass_Fail_Status_tmp+1;
    n_SerialNumber = n_SerialNumber_tmp +1;
    
    if (n_StartTime_tmp == 900000)
    {
        n_StartTime = n_StartTime_tmp;
    }
    else
    {
        n_StartTime = n_StartTime_tmp +1;  // 构建了第一列
    }
    if (n_Product_Col_tmp == 900001)
    {
        n_Product_Col =n_Product_Col_tmp;
    }
    else
    {
        n_Product_Col =n_Product_Col_tmp + 1;
    }
    if (n_StationID_Col_tmp == 900002)
    {
        n_StationID_Col = n_StationID_Col_tmp;
    }
    else
    {
        n_StationID_Col = n_StationID_Col_tmp+1;
    }
    if (n_Version_Col_tmp == 900003)
    {
        n_Version_Col = n_Version_Col_tmp;
    }
    else
    {
        n_Version_Col = n_Version_Col_tmp +1;
    }
    
    int n_ListOfFail_Col = -1;
    if (n_ListOfFail_Col_tmp == 900004)
    {
        n_ListOfFail_Col = n_ListOfFail_Col_tmp;
    }
    else
    {
        n_ListOfFail_Col = n_ListOfFail_Col_tmp +1;
    }
    
    if (n_SlotId_Col_tmp == 900005)
    {
        n_SlotId_Col = n_SlotId_Col_tmp;
    }
    else
    {
        n_SlotId_Col = n_SlotId_Col_tmp + 1;
    }
    
    
    n_SpecialBuildName_Col = n_SpecialBuildName_Col_tmp;
    n_Special_Build_Descrip_Col = n_Special_Build_Descrip_Col_tmp;
    n_Diags_Version_Col = n_Diags_Version_Col_tmp;
    n_OS_VERSION_Col = n_OS_VERSION_Col_tmp;
    
    
    
    
    NSTimeInterval now = [[NSDate date]timeIntervalSince1970];
    NSLog(@">read csv waste time: %f",now-starttime);
    [self initRedisAndData];
    

    

    NSMutableArray *arrDataTmp = [NSMutableArray array];
    
    NSMutableArray *tmpData0 = [NSMutableArray array];
    NSMutableArray *tmpData2 = [NSMutableArray array];
    NSMutableArray *tmpData3 = [NSMutableArray array];
    for (int y=0; y<[_rawData[n_itemnameRow] count]; y++)
    {
        if (y==0)
        {
            [tmpData0 addObject:@"FCT"];
            [tmpData2 addObject:@"Display Name ----->"];
            [tmpData3 addObject:@"PDCA Priority ----->"];
        }
        else if (y==n_Start_Data_Col)
        {
            [tmpData0 addObject:@"Parametric"];
            [tmpData2 addObject:@""];
            [tmpData3 addObject:@""];
        }
        else
        {
            [tmpData0 addObject:@""];
            [tmpData2 addObject:@""];
            [tmpData3 addObject:@""];
        }
        
    }
    [arrDataTmp addObject:tmpData0];
    [arrDataTmp addObject:_rawData[n_itemnameRow]];  //item name
    arrDataTmp[1][0] = @"Site";
    arrDataTmp[1][n_Pass_Fail_Status] = @"Test Pass/Fail Status";
    arrDataTmp[1][n_SerialNumber] = @"SerialNumber";
        
    //arrDataTmp[0][n_Pass_Fail_Status_tmp] = @"Test Stop Time";
    [arrDataTmp addObject:tmpData2];
    [arrDataTmp addObject:tmpData3];
    
    if ([upperRow isNotEqualTo:@"NA"])
    {
        [arrDataTmp addObject:_rawData[[upperRow intValue]]];
        arrDataTmp[4][0] = @"Upper Limited----------->";
        arrDataTmp[4][1] = @"";
    }
    else
    {
        tmpData2[0] = @"Upper Limited----------->";
        [arrDataTmp addObject:tmpData2];
    }
    if ([lowerRow isNotEqualTo:@"NA"])
    {
        [arrDataTmp addObject:_rawData[[lowerRow intValue]]];
        arrDataTmp[5][0] = @"Lower Limited----------->";
        arrDataTmp[5][1] = @"";
    }
    else
    {
        tmpData2[0] = @"Lower Limited----------->";
        [arrDataTmp addObject:tmpData2];
    }
    if ([unitRow isNotEqualTo:@"NA"])
    {
        [arrDataTmp addObject:_rawData[[unitRow intValue]]];
        arrDataTmp[6][0] = @"Measurement unit------>";
        arrDataTmp[6][1] = @"";
    }
    else
    {
        tmpData2[0] = @"Measurement unit------>";
        [arrDataTmp addObject:tmpData2];
    }
    for (int i=n_dataStartRow; i<[_rawData count]; i++)
    {
        _rawData[i][0] = @"FXLH";
        [arrDataTmp addObject:_rawData[i]];
        
    }
    
    if (n_StartTime_tmp == 900000)
    {
        NSMutableArray *arrReverse1 = [NSMutableArray arrayWithArray:[self reverseArray:arrDataTmp]];
        [arrReverse1 insertObject:@[@"",@"",@"",@"",@"",@""] atIndex:n_Start_Data_Col];
        arrDataTmp = [NSMutableArray arrayWithArray:[self reverseArray:arrReverse1]];
        arrDataTmp[1][n_Start_Data_Col] = @"StartTime";
        arrDataTmp[2][n_Start_Data_Col] = @"";  //display
        arrDataTmp[3][n_Start_Data_Col] = @"";  // pdca
        arrDataTmp[4][n_Start_Data_Col] = @"";  //upper limit
        arrDataTmp[5][n_Start_Data_Col] = @"";  // lower limit
        arrDataTmp[6][n_Start_Data_Col] = @"";  // unit
    }
    else
    {
        arrDataTmp[1][n_StartTime] = @"StartTime";
        arrDataTmp[2][n_StartTime] = @"";
        arrDataTmp[3][n_StartTime] = @"";
        arrDataTmp[4][n_StartTime] = @"";  //upper limit
        arrDataTmp[5][n_StartTime] = @"";  // lower limit
        arrDataTmp[6][n_StartTime] = @"";
    }
    if (n_Product_Col_tmp == 900001)
    {
        NSMutableArray *arrReverse1 = [NSMutableArray arrayWithArray:[self reverseArray:arrDataTmp]];
        [arrReverse1 insertObject:@[@"",@""] atIndex:n_Start_Data_Col];
        arrDataTmp = [NSMutableArray arrayWithArray:[self reverseArray:arrReverse1]];
        arrDataTmp[1][n_Start_Data_Col] = @"Product";
        arrDataTmp[2][n_Start_Data_Col] = @"";
        arrDataTmp[3][n_Start_Data_Col] = @"";
        arrDataTmp[4][n_Start_Data_Col] = @"";
        arrDataTmp[5][n_Start_Data_Col] = @"";
        arrDataTmp[6][n_Start_Data_Col] = @"";
    }
    else
    {
        arrDataTmp[1][n_Product_Col] = @"Product";
        arrDataTmp[2][n_Product_Col] = @"";
        arrDataTmp[3][n_Product_Col] = @"";
        arrDataTmp[4][n_Product_Col] = @"";
        arrDataTmp[5][n_Product_Col] = @"";
        arrDataTmp[6][n_Product_Col] = @"";
    }
    if (n_StationID_Col_tmp == 900002)
    {
        NSMutableArray *arrReverse1 = [NSMutableArray arrayWithArray:[self reverseArray:arrDataTmp]];
        [arrReverse1 insertObject:@[@"",@""] atIndex:n_Start_Data_Col];
        arrDataTmp = [NSMutableArray arrayWithArray:[self reverseArray:arrReverse1]];
        arrDataTmp[1][n_Start_Data_Col] = @"Station ID";
        arrDataTmp[2][n_Start_Data_Col] = @"";
        arrDataTmp[3][n_Start_Data_Col] = @"";
        arrDataTmp[4][n_Start_Data_Col] = @"";
        arrDataTmp[5][n_Start_Data_Col] = @"";
        arrDataTmp[6][n_Start_Data_Col] = @"";
    }
    else
    {
        arrDataTmp[1][n_StationID_Col] = @"Station ID";
        arrDataTmp[2][n_StationID_Col] = @"";
        arrDataTmp[3][n_StationID_Col] = @"";
        arrDataTmp[4][n_StationID_Col] = @"";
        arrDataTmp[5][n_StationID_Col] = @"";
        arrDataTmp[6][n_StationID_Col] = @"";
    }
    if (n_Version_Col_tmp == 900003)
    {
        NSMutableArray *arrReverse1 = [NSMutableArray arrayWithArray:[self reverseArray:arrDataTmp]];
        [arrReverse1 insertObject:@[@"",@""] atIndex:n_Start_Data_Col];
        arrDataTmp = [NSMutableArray arrayWithArray:[self reverseArray:arrReverse1]];
        arrDataTmp[1][n_Start_Data_Col] = @"Version";
        arrDataTmp[2][n_Start_Data_Col] = @"";
        arrDataTmp[3][n_Start_Data_Col] = @"";
        arrDataTmp[4][n_Start_Data_Col] = @"";
        arrDataTmp[5][n_Start_Data_Col] = @"";
        arrDataTmp[6][n_Start_Data_Col] = @"";
    }
    else
    {
        arrDataTmp[1][n_Version_Col] = @"Version";
        arrDataTmp[2][n_Version_Col] = @"";
        arrDataTmp[3][n_Version_Col] = @"";
        arrDataTmp[4][n_Version_Col] = @"";
        arrDataTmp[5][n_Version_Col] = @"";
        arrDataTmp[6][n_Version_Col] = @"";
    }
    if (n_ListOfFail_Col_tmp == 900004)
    {
        NSMutableArray *arrReverse1 = [NSMutableArray arrayWithArray:[self reverseArray:arrDataTmp]];
        [arrReverse1 insertObject:@[@"",@""] atIndex:n_Start_Data_Col];
        arrDataTmp = [NSMutableArray arrayWithArray:[self reverseArray:arrReverse1]];
        arrDataTmp[1][n_Start_Data_Col] = @"List of Failing Tests";
        arrDataTmp[2][n_Start_Data_Col] = @"";
        arrDataTmp[3][n_Start_Data_Col] = @"";
        arrDataTmp[4][n_Start_Data_Col] = @"";
        arrDataTmp[5][n_Start_Data_Col] = @"";
        arrDataTmp[6][n_Start_Data_Col] = @"";
    }
    else
    {
        arrDataTmp[1][n_ListOfFail_Col] = @"List of Failing Tests";
        arrDataTmp[2][n_ListOfFail_Col] = @"";
        arrDataTmp[3][n_ListOfFail_Col] = @"";
        arrDataTmp[4][n_ListOfFail_Col] = @"";
        arrDataTmp[5][n_ListOfFail_Col] = @"";
        arrDataTmp[6][n_ListOfFail_Col] = @"";
    }
    if (n_SlotId_Col_tmp == 900005)
    {
        NSMutableArray *arrReverse1 = [NSMutableArray arrayWithArray:[self reverseArray:arrDataTmp]];
        [arrReverse1 insertObject:@[@"",@""] atIndex:n_Start_Data_Col];
        arrDataTmp = [NSMutableArray arrayWithArray:[self reverseArray:arrReverse1]];
        arrDataTmp[1][n_Start_Data_Col] = @"Fixture Channel ID";
    }
    else
    {
        arrDataTmp[1][n_SlotId_Col] = @"Fixture Channel ID";
    }
    
    [_rawData removeAllObjects];
    [_rawData setArray:arrDataTmp];
    
    NSMutableString *csvStr = [NSMutableString string];
    for(NSMutableArray *lineArray in _rawData)
    {
        if ([lineArray count] == 1)
        {
            for (int i = 0; i<[_rawData[0] count]-1; i++)
            {
                [csvStr appendString:@","];
            }
            [csvStr appendString:@"\n"];
        }
        else
        {
            NSString *arrayString = [lineArray componentsJoinedByString:@","];
            [csvStr appendFormat:@"%@\n",arrayString];
        }
        

    }
    NSError *error = nil;
    [csvStr writeToFile:kcustomToInsightCsv atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error)
    {
        NSLog(@">write csv error");
    }
    else
    {
        NSLog(@">write csv ok");
    }
               
    
    for (int i=0; i<create_empty_line; i++)  //参看  数据说明.xlsx，前面从0 到36行，留给ui界面 和UI界面的一些设置，从37行开始，是储存的数据
    {
        /*
         因为前面几7行，insight 有数据是如下，所以从第7行开始，创建新的，防止把insight data 数据污染
         FCT,20200310_v1__oscar_
         Site,Product,SerialNumb
         Display Name ----->,,,,
         PDCA Priority ----->,,,
         Upper Limit ----->,,,,,
         Lower Limit ----->,,,,,
         Measurement Unit ----->
         */
   
          [_rawData insertObject:@[@""] atIndex:7];
        
        
    }
    
    if (b_isCustomCSV)
    {
        if (n_StartTime_tmp == 900000)
        {
            n_Start_Data_Col = n_Start_Data_Col +1;
        }
        if (n_Product_Col_tmp == 900001)
        {
            n_Start_Data_Col = n_Start_Data_Col +1;
        }
        if (n_StationID_Col_tmp == 900002)
        {
            n_Start_Data_Col = n_Start_Data_Col +1;
        }
        if (n_Version_Col_tmp == 900003)
        {
            n_Start_Data_Col = n_Start_Data_Col +1;
        }
        if (n_ListOfFail_Col_tmp == 900004)
        {
            n_Start_Data_Col = n_Start_Data_Col +1;
        }
        if (n_SlotId_Col_tmp == 900005)
        {
            n_Start_Data_Col = n_Start_Data_Col +1;
        }
    }
    
 
    NSString *cpkL= [m_configDictionary valueForKey:cpk_Lowthl];
    NSString *cpkH = [m_configDictionary valueForKey:cpk_Highthl];
    
    NSMutableArray *mutArrayReverse = [NSMutableArray arrayWithArray:[self reverseArray:_rawData]];
    //_dataReverse = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:mutArrayReverse]];
    n_passdata = 0;
    for (int i=tb_data_start; i<[mutArrayReverse[n_Pass_Fail_Status] count]; i++)
    {
        if ([mutArrayReverse[n_Pass_Fail_Status][i] isEqualToString:@"PASS"])
        {
            n_passdata ++;
        }
        if (n_passdata>4)
        {
            break;
        }
    }
    

    
    _dataReverse = mutArrayReverse;
    NSUInteger indexItem=0;
    
 
    for (int i=0; i<[mutArrayReverse count]; i++)
    {
 
        if ([mutArrayReverse[i] isKindOfClass:[NSArray class]] && [mutArrayReverse[i] count] > 1)
        {
            if (i>=n_Start_Data_Col)  //
            {
                [_data addObject:mutArrayReverse[i]];

                
                _data[indexItem][tb_index]= [NSNumber numberWithInteger:indexItem+1];  //UI index
                _data[indexItem][tb_item]= mutArrayReverse[i][1];   //UI item;
                _data[indexItem][tb_lower]= mutArrayReverse[i][5];   //UI lower;
                _data[indexItem][tb_upper]= mutArrayReverse[i][4];   //UI upper;
                _data[indexItem][tb_measurement_unit]= mutArrayReverse[i][6];// number 6 is unit
                _data[indexItem][tb_lsl]= @"";  // UI new LSL
                _data[indexItem][tb_usl]= @"";  // UI new USL
                _data[indexItem][tb_apply]= [NSNumber numberWithInteger:0];  // UI apply button
                _data[indexItem][tb_description]= @"";  // UI description
                _data[indexItem][tb_command]= @"";  //
                _data[indexItem][tb_reviewer]= @"";  //
                _data[indexItem][tb_date]= @"";  //
                _data[indexItem][tb_comment]= @"";  // UI comment
                _data[indexItem][tb_3cv]= @"";  // UI 3CV
                
                
                
                _data[indexItem][tb_zoom_type]= @"limit";  //显示有没有limit zoom in
                _data[indexItem][19]= [NSNumber numberWithInteger:250];  // UI界面设置的bin值
                _data[indexItem][20]= @"";  //zmq 传过给python的item 名字
                _data[indexItem][21]= @"";                               //
                _data[indexItem][22]= @"";                               //
                _data[indexItem][23]=@""; //设置生成报告的 BC
                
                _data[indexItem][24]=cpkL;//
                _data[indexItem][25]=cpkH;//
                _data[indexItem][tb_correlation_xy] = @"";
                _data[indexItem][tb_range_lsl] = mutArrayReverse[i][5];
                _data[indexItem][tb_range_usl] = mutArrayReverse[i][4];
                _data[indexItem][tb_cpk_new]=@""; //
                _data[indexItem][tb_cpk_log_path]=[NSString stringWithFormat:@"%@/CPK_Log",desktopPath];//设置log文件路径 /桌面/CPK_Log
                _data[indexItem][tb_color_by_left]= [NSNumber numberWithInteger:0];  //设置color By左边那个
                _data[indexItem][tb_color_by_right]= [NSNumber numberWithInteger:0];  //设置color By右边那个
                _data[indexItem][button_select_x]= [NSNumber numberWithInteger:0];
                _data[indexItem][button_select_y]= [NSNumber numberWithInteger:0];
                _data[indexItem][tb_script_flag]= [NSNumber numberWithInteger:0]; //设置是否是script数据，insight 数据标志0
                
                _data[indexItem][tb_data]= Start_Data;  //all the test data below
                NSString *itemName = [NSString stringWithFormat:@"%@",mutArrayReverse[i][1]];
                [_indexItemNameDic setValue:itemName forKey:[NSString stringWithFormat:@"%zd",indexItem]];
                // myRedis->SetString([combineItem UTF8String],[[NSString stringWithFormat:@"%@",mutArrayReverse[i]] UTF8String]);
                [_ListAllItemNameArr addObject:itemName];
                indexItem ++;
            }
        }
    }
    
    [_sortDataBackup removeAllObjects];
    [_sortDataBackup setArray:_data];
    
    [tmpColorArr removeAllObjects];
    [tmpColorArr setArray:_data];
    
    [self.dataTableView reloadData];
    //Modifyed By Vito
    //[m_configDictionary setValue:[NSNumber numberWithBool:YES] forKey:K_dic_Load_Csv_Finished];
    //Modify End
    
    NSMutableString *itemStr = [NSMutableString string];
    for (int i=0; i<[_ListAllItemNameArr count]; i++)
    {
        [itemStr appendString:[NSString stringWithFormat:@"%d,%@\n",i+1,_ListAllItemNameArr[i]]];
    }
    [itemStr writeToFile:KdataItemNamePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    //[itemStr writeToFile:KItemNamePathDataTmp atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationReloadReportTags object:nil userInfo:nil];
    
    if (n_passdata<4) 
    {
        [self AlertBox:@"Warning." withInfo:@"PASS data less than 3, it can not calculate cpk value. \r\nPlease check CPK distribution by click “NO” in “Remove Fail”"];
    }
    return YES;
}

-(void)backCsvParse:(CSVParser*)csv
{
    rawArrarTmp1 = [NSMutableArray array];
    rawArrarTmp1 = [csv parseFile];
    NSLog(@">rawArrarTmp1: %zd",[rawArrarTmp1 count]);
}

-(BOOL)reloadDataWithPath:(NSString *)path
{
    NSTimeInterval starttime = [[NSDate date]timeIntervalSince1970];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationIndicatorMsg object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Start load file: %@.",[path lastPathComponent]],kStartupMsg,[NSNumber numberWithInt:MSG_LEVEL_NORMAL],kStartupLevel,[NSNumber numberWithFloat:2/n_loadStepCount], kStartupPercentage, nil]];
    
    CsvHandle handle = CsvOpen([path UTF8String]);
    if (!handle)
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationIndicatorMsg object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Load file error.",kStartupMsg,[NSNumber numberWithInt:MSG_LEVEL_ERROR],kStartupLevel, [NSNumber numberWithFloat:3/n_loadStepCount], kStartupPercentage,nil]];
        return NO;
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationIndicatorMsg object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Load file done.",kStartupMsg,[NSNumber numberWithInt:MSG_LEVEL_NORMAL],kStartupLevel, [NSNumber numberWithFloat:3/n_loadStepCount], kStartupPercentage,nil]];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationIndicatorMsg object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Parse file to array.\r\n  Separating PASS/FAIL/RETEST.\r\n  Separating Filter 1 & Filter 2.\r\n  Calculating Cpk in background.\r\n  Calculating Bimodality metrics in background.\r\n  Generating Build Summary reports in background.\r\n  Please be patient, it may take a while, depending on file size.",kStartupMsg,[NSNumber numberWithInt:MSG_LEVEL_NORMAL],kStartupLevel, [NSNumber numberWithFloat:4/n_loadStepCount], kStartupPercentage,nil]];
    
    char* row = NULL;
    unsigned rowcount = 0;
    unsigned colcount = 0;
    NSMutableArray *rawDataTmp = [NSMutableArray array];
    while ((row = CsvReadNextRow(handle)))
    {
        const char* col = NULL;
        rowcount++;
        NSMutableArray *rawDataTmp_row = [NSMutableArray array];
        
        bool is_BlankLine = true;
        while ((col = CsvReadNextCol(row, handle)))
        {
            [rawDataTmp_row addObject:[NSString stringWithFormat:@"%s",col]];
            colcount++;
            if (![[NSString stringWithFormat:@"%s",col] isEqualToString:@""]) {
                is_BlankLine = false;
            }
        }
        if ([rawDataTmp_row count]>0 & !is_BlankLine)
        {
           
            [rawDataTmp addObject:rawDataTmp_row];
            if ((rowcount-1) %100 ==0) {
                [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationIndicatorMsg object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@".",kStartupMsg,[NSNumber numberWithInt:MSG_LEVEL_NORMAL],kStartupLevel,[NSNumber numberWithFloat:100.0+(rowcount-1)/100], kStartupPercentage, nil]];
            }
            
        }
        
        
    }
    CsvClose(handle);
    /*
     [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationIndicatorMsg object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Start load file: %@.",[path lastPathComponent]],kStartupMsg,[NSNumber numberWithInt:MSG_LEVEL_NORMAL],kStartupLevel,[NSNumber numberWithFloat:2/n_loadStepCount], kStartupPercentage, nil]];
     
     
     CSVParser *csv = [[CSVParser alloc]init];
    NSMutableArray *rawDataTmp = [NSMutableArray array];
    if ([csv openFile:path])
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationIndicatorMsg object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Load file done.",kStartupMsg,[NSNumber numberWithInt:MSG_LEVEL_NORMAL],kStartupLevel, [NSNumber numberWithFloat:3/n_loadStepCount], kStartupPercentage,nil]];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationIndicatorMsg object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Parse file to array.\r\n  Separating PASS/FAIL/RETEST.\r\n  Separating Filter 1 & Filter 2.\r\n  Calculating Cpk.\r\n  Calculating Bimodality metrics.\r\n  Generating Build Summary reports.\r\n  Please be patient, it may take a while, depending on file size.",kStartupMsg,[NSNumber numberWithInt:MSG_LEVEL_NORMAL],kStartupLevel, [NSNumber numberWithFloat:4/n_loadStepCount], kStartupPercentage,nil]];
        rawDataTmp = [csv parseFile];
        
    }
    */
    if (!rawDataTmp.count)
    {
        [self AlertBox:@"Error:20" withInfo:@"Load date is empty."];
        return NO;
    }
    [[NSRunLoop currentRunLoop]runMode:NSDefaultRunLoopMode beforeDate:[NSDate date]];
    
    int n_index = (int)[rawDataTmp[0] count];
      //}
    
    
      int n_Start_Data_Col_tmp = -1;
      int n_Pass_Fail_Status_tmp = -1;
      int n_Product_Col_tmp =-1;
      int n_SerialNumber_tmp = -1;
      int n_SpecialBuildName_Col_tmp = -1;
      int n_Special_Build_Descrip_Col_tmp =-1;
      int n_StationID_Col_tmp =-1;
      int n_StartTime_tmp = -1;
      int n_Version_Col_tmp =-1;
      int n_Diags_Version_Col_tmp = -1;
      int n_OS_VERSION_Col_tmp = -1;

       for (int i=0; i<n_index; i++)
       {
           if ([rawDataTmp[0] count]>i)
           {
               if ([rawDataTmp[0][i] isEqualToString:@"Parametric"])
               {
                   n_Start_Data_Col_tmp = i;   //是12   第一个测试item 开始列
                   
               }
           }
           if ([rawDataTmp[1] count]>i)
           {
               if ([rawDataTmp[1][i] isEqualToString:@"Test Pass/Fail Status"])
               {
                    n_Pass_Fail_Status_tmp = i;
               }
               if ([rawDataTmp[1][i] isEqualToString:@"Product"])
               {
                   n_Product_Col_tmp = i;
               }
               if ([rawDataTmp[1][i] isEqualToString:@"SerialNumber"])
               {
                   n_SerialNumber_tmp = i;
               }
               if ([rawDataTmp[1][i] isEqualToString:@"Special Build Name"])
               {
                   n_SpecialBuildName_Col_tmp = i;
               }
               if ([rawDataTmp[1][i] isEqualToString:@"Special Build Description"])
               {
                   n_Special_Build_Descrip_Col_tmp = i;
               }
               if ([rawDataTmp[1][i] isEqualToString:@"Station ID"])
               {
                   n_StationID_Col_tmp = i;
               }
               if ([rawDataTmp[1][i] isEqualToString:@"StartTime"])
               {
                   n_StartTime_tmp = i;
               }
               if ([rawDataTmp[1][i] isEqualToString:@"Version"])
               {
                   n_Version_Col_tmp = i;
               }
               if ([rawDataTmp[1][i] isEqualToString:@"Diags_Version"])
               {
                   n_Diags_Version_Col_tmp = i;
               }
               if ([rawDataTmp[1][i] isEqualToString:@"OS_VERSION"])
               {
                   n_OS_VERSION_Col_tmp = i;
               }
           }
       }
      
      if (n_Start_Data_Col_tmp<0 ||n_Pass_Fail_Status_tmp<0||n_Product_Col_tmp<0||n_SerialNumber_tmp<0||n_SpecialBuildName_Col_tmp<0||n_Special_Build_Descrip_Col_tmp<0||n_StationID_Col_tmp<0||n_StartTime_tmp<0||n_Version_Col_tmp<0)
      {
          NSString *errorInfo = @"";
          if (n_Start_Data_Col_tmp <0)
          {
              errorInfo = @"Expected keyword •”Parametric” not found in row 1, as expected in standard Insight data file.";
              //errorInfo = @"Expected keyword •”Parametric” not found in row 1,";
          }
          if (n_Pass_Fail_Status_tmp<0)
          {
              if ([errorInfo length]>1)
              {
                  errorInfo = [NSString stringWithFormat:@"%@\nExpected keyword •”Test Pass/Fail Status” not found in row 2, as expected in standard Insight data file.",errorInfo];
              }
              else
              {
                  errorInfo = @"Expected keyword •”Test Pass/Fail Status” not found in row 2, as expected in standard Insight data file.";
              }
          }
          
          if (n_Product_Col_tmp<0)
          {
              if ([errorInfo length]>1)
              {
                  errorInfo = [NSString stringWithFormat:@"%@\nExpected keyword •”Product” not found in row 2, as expected in standard Insight data file.",errorInfo];
              }
              else
              {
                  errorInfo = @"Expected keyword •”Product” not found in row 2, as expected in standard Insight data file.";
              }
          }
          
          if (n_SerialNumber_tmp<0)
          {
              if ([errorInfo length]>1)
              {
                  errorInfo = [NSString stringWithFormat:@"%@\nExpected keyword •”SerialNumber” not found in row 2, as expected in standard Insight data file.",errorInfo];
              }
              else
              {
                  errorInfo = @"Expected keyword •”SerialNumber” not found in row 2, as expected in standard Insight data file.";
              }
          }
          
          if (n_SpecialBuildName_Col_tmp<0)
          {
              if ([errorInfo length]>1)
              {
                  errorInfo = [NSString stringWithFormat:@"%@\nExpected keyword •”Special Build Name” not found in row 2, as expected in standard Insight data file.",errorInfo];
              }
              else
              {
                  errorInfo = @"Expected keyword •”Special Build Name” not found in row 2, as expected in standard Insight data file.";
              }
          }
          
          if (n_Special_Build_Descrip_Col_tmp<0)
          {
              if ([errorInfo length]>1)
              {
                  errorInfo = [NSString stringWithFormat:@"%@\nExpected keyword •”Special Build Description” not found in row 2, as expected in standard Insight data file.",errorInfo];
              }
              else
              {
                  errorInfo = @"Expected keyword •”Special Build Description” not found in row 2, as expected in standard Insight data file.";
              }
          }
          
          if (n_StationID_Col_tmp<0)
          {
              if ([errorInfo length]>1)
              {
                  errorInfo = [NSString stringWithFormat:@"%@\nExpected keyword •”Station ID” not found in row 2, as expected in standard Insight data file.",errorInfo];
              }
              else
              {
                  errorInfo = @"Expected keyword •”Station ID” not found in row 2, as expected in standard Insight data file.";
              }
          }
          
          if (n_StartTime_tmp<0)
          {
              if ([errorInfo length]>1)
              {
                  errorInfo = [NSString stringWithFormat:@"%@\nExpected keyword •”StartTime” not found in row 2, as expected in standard Insight data file.",errorInfo];
              }
              else
              {
                  errorInfo = @"Expected keyword •”StartTime” not found in row 2, as expected in standard Insight data file.";
              }
          }
          
          if (n_Version_Col_tmp<0)
          {
              if ([errorInfo length]>1)
              {
                  errorInfo = [NSString stringWithFormat:@"%@\nExpected keyword •”Version” not found in row 2, as expected in standard Insight data file.",errorInfo];
              }
              else
              {
                  errorInfo = @"Expected keyword •”Version” not found in row 2, as expected in standard Insight data file.";
              }
          }
          
          
          [self AlertBox:@"Data Format Error:013\nPlease use custom csv to load." withInfo:errorInfo];
          return NO;
      }
    
      
    
    
    
    [_data removeAllObjects];
    [_dataReverse removeAllObjects];
    [_rawData removeAllObjects];
    _rawData  = rawDataTmp;
    [_indexItemNameDic removeAllObjects];
    [_textEditLimitDic removeAllObjects];
    [_ListAllItemNameArr removeAllObjects];
    
    [_colorRedIndex removeAllObjects];
    [_colorGreenIndex removeAllObjects];
    [_colorRedIndexBackup removeAllObjects];
    [_colorGreenIndexBackup removeAllObjects];
    
    [_colorRedIndexCpk removeAllObjects];
    [_colorGreenIndexCpk removeAllObjects];
    [_colorYellowIndexCpk removeAllObjects];
    [_colorRedIndexCpkBackup removeAllObjects];
    [_colorGreenIndexCpkBackup removeAllObjects];
    [_colorYellowIndexCpkBackup removeAllObjects];
    
    [_reviewerNameIndex removeAllObjects];
    //[_bmcNoIndex removeAllObjects];  not put here, put in set parameters
    //[_bmcYesIndex removeAllObjects];

    [_limitUpdateData removeAllObjects];
    
    [tmpColorArr removeAllObjects];
    [_sortDataBackup removeAllObjects];
    [_dataBackup removeAllObjects];
    
    n_Start_Data_Col = n_Start_Data_Col_tmp;
    n_Pass_Fail_Status = n_Pass_Fail_Status_tmp;
    n_Product_Col = n_Product_Col_tmp;
    n_SerialNumber = n_SerialNumber_tmp;
    n_SpecialBuildName_Col = n_SpecialBuildName_Col_tmp;
    n_Special_Build_Descrip_Col = n_Special_Build_Descrip_Col_tmp;
    n_StationID_Col =n_StationID_Col_tmp;
    n_StartTime = n_StartTime_tmp;
    n_Version_Col =n_Version_Col_tmp;
    n_Diags_Version_Col = n_Diags_Version_Col_tmp;
    n_OS_VERSION_Col = n_OS_VERSION_Col_tmp;

    NSTimeInterval now = [[NSDate date]timeIntervalSince1970];
    NSLog(@">read csv waste time: %f",now-starttime);
    // ====store data fct
    //myRedis->SetString(FCT_RAW_DATA,[[NSString stringWithFormat:@"%@",_rawData] UTF8String]);
    [self initRedisAndData];
    
    /*if (myRedis)
    {
        myRedis->SetString(FCT_SCRIPT_VERSION,[[NSString stringWithFormat:@"%@",_rawData[0]] UTF8String]);
        myRedis->SetString(FCT_ITEMS_NAME,[[NSString stringWithFormat:@"%@",_rawData[1]] UTF8String]);
    }
    else
    {
        NSLog(@"---->> redis error");
    }*/
    /*
     Site,Product,SerialNumber,Special Build Name,Special Build Description,Unit Number,Station ID,Test Pass/Fail Status,StartTime,EndTime,Version,List of Failing Tests,Head Id,Fixture Id
     
     #define Start_Data_Row                 7
     #define Start_Data_Col                 11
     #define Pass_Fail_Status               7
     #define Product_Col                    1
     #define SerialNumber                   2
     #define SpecialBuildName_Col           3
     #define Special_Build_Descrip_Col      4
     #define StationID_Col                  6
     #define Start_Calc_Data_Col            12
     #define StartTime                      8
     #define Version_Col                    10
     
     */
     //for (int i=0; i<[_rawData[0] count]; i++)  //计算开始
   // int n_index = 30; //匹配前30个数据，节约时间
    //if ([_rawData[0] count] >30)
   // {
     
    
    
    for (int i=0; i<create_empty_line; i++)  //参看  数据说明.xlsx，前面从0 到36行，留给ui界面 和UI界面的一些设置，从37行开始，是储存的数据
    {
        /*
         因为前面几7行，insight 有数据是如下，所以从第7行开始，创建新的，防止把insight data 数据污染
         FCT,20200310_v1__oscar_
         Site,Product,SerialNumb
         Display Name ----->,,,,
         PDCA Priority ----->,,,
         Upper Limit ----->,,,,,
         Lower Limit ----->,,,,,
         Measurement Unit ----->
         */
        [_rawData insertObject:@[@""] atIndex:7];  //占位，给UI显示 从第七开始，
        
    }
    
 
        
    
    NSMutableArray *mutArrayReverse = [NSMutableArray arrayWithArray:[self reverseArray:_rawData]];
    //_dataReverse = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:mutArrayReverse]];
    n_passdata = 0;
    for (int i=tb_data_start; i<[mutArrayReverse[n_Pass_Fail_Status] count]; i++)
    {
        if ([mutArrayReverse[n_Pass_Fail_Status][i] isEqualToString:@"PASS"])
        {
            n_passdata ++;
        }
        if (n_passdata>4)
        {
            break;
        }
    }
    
    /*if (n_passdata<4)
    {
        [self AlertBox:@"Warning." withInfo:@"PASS data less than 3, it can not calculate cpk value. \r\nPlease check CPK distribution by click “NO” in “Remove Fail”"];
    }*/
    
    _dataReverse = mutArrayReverse;
    NSUInteger indexItem=0;
    NSString *cpkL= [m_configDictionary valueForKey:cpk_Lowthl];
    NSString *cpkH = [m_configDictionary valueForKey:cpk_Highthl];
    
    NSMutableArray *insightTestName = [NSMutableArray array];
    for (int i=0; i<[mutArrayReverse count]; i++)
    {
 
        if ([mutArrayReverse[i] isKindOfClass:[NSArray class]] && [mutArrayReverse[i] count] > 1)
        {
            if (i>=n_Start_Data_Col)  //
            {
                [_data addObject:mutArrayReverse[i]];
                _data[indexItem][tb_index]= [NSNumber numberWithInteger:indexItem+1];  //UI index
                _data[indexItem][tb_item]= mutArrayReverse[i][1];   //UI item;
                [insightTestName addObject:mutArrayReverse[i][1]];
                _data[indexItem][tb_lower]= mutArrayReverse[i][5];   //UI lower;
                _data[indexItem][tb_upper]= mutArrayReverse[i][4];   //UI upper;
                _data[indexItem][tb_measurement_unit]= mutArrayReverse[i][6];    // number 6 is unit
                _data[indexItem][tb_lsl]= @"";  // UI new LSL
                _data[indexItem][tb_usl]= @"";  // UI new USL
                _data[indexItem][tb_apply]= [NSNumber numberWithInteger:0];  // UI apply button
                _data[indexItem][tb_description]= @"";  // UI description
                _data[indexItem][tb_command]= @"";  //
                _data[indexItem][tb_reviewer]= @"";  //
                _data[indexItem][tb_date]= @"";  //
                _data[indexItem][tb_comment]= @"";  // UI comment
                _data[indexItem][tb_3cv]= @"";  // UI 3CV
                
                _data[indexItem][tb_zoom_type]= @"limit";  //显示有没有limit zoom in
                _data[indexItem][19]= [NSNumber numberWithInteger:250];  // UI界面设置的bin值
                _data[indexItem][20]= @"";  //zmq 传过给python的item 名字
                _data[indexItem][21]= @"";
                _data[indexItem][22]=@"";
                _data[indexItem][tb_keynote]=[NSNumber numberWithInteger:0]; //设置keynote 勾选按钮
                _data[indexItem][24]=cpkL;                               //设置low ThLD  -->1.5
                _data[indexItem][25]=cpkH;                               //设置High THLD  -->10.0
                _data[indexItem][tb_correlation_xy]=@"";
                _data[indexItem][tb_range_lsl] = mutArrayReverse[i][5];
                _data[indexItem][tb_range_usl] = mutArrayReverse[i][4];
                _data[indexItem][tb_cpk_new]=@"";//
                _data[indexItem][tb_cpk_log_path]=[NSString stringWithFormat:@"%@/CPK_Log",desktopPath];//设置log文件路径 /桌面/CPK_Log
                _data[indexItem][tb_color_by_left]= [NSNumber numberWithInteger:0];  //设置color By左边那个
                _data[indexItem][tb_color_by_right]= [NSNumber numberWithInteger:0];  //设置color By右边那个
                _data[indexItem][button_select_x]= [NSNumber numberWithInteger:0];
                _data[indexItem][button_select_y]= [NSNumber numberWithInteger:0];
                _data[indexItem][tb_script_flag]= [NSNumber numberWithInteger:0]; //设置是否是script数据，insight 数据标志0
                
                _data[indexItem][tb_data]= Start_Data;  //all the test data below
                NSString *itemName = [NSString stringWithFormat:@"%@",mutArrayReverse[i][1]];
                [_indexItemNameDic setValue:itemName forKey:[NSString stringWithFormat:@"%zd",indexItem]];
                // myRedis->SetString([combineItem UTF8String],[[NSString stringWithFormat:@"%@",mutArrayReverse[i]] UTF8String]);
                [_ListAllItemNameArr addObject:itemName];
                indexItem ++;
            }
        }
    }
    [m_configDictionary setValue:insightTestName forKey:KItemNameInsight];
    [_sortDataBackup removeAllObjects];
    [_sortDataBackup setArray:_data];
    
    [tmpColorArr removeAllObjects];
    [tmpColorArr setArray:_data];
    
    [self.dataTableView reloadData];
    
    //Modifyed By Vito 20210306
    //[m_configDictionary setValue:[NSNumber numberWithBool:YES] forKey:K_dic_Load_Csv_Finished];
    
    //Modify end
    
    NSMutableString *itemStr = [NSMutableString string];
    for (int i=0; i<[_ListAllItemNameArr count]; i++)
    {
        [itemStr appendString:[NSString stringWithFormat:@"%d,%@\n",i+1,_ListAllItemNameArr[i]]];
    }
    [itemStr writeToFile:KdataItemNamePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    //[itemStr writeToFile:KItemNamePathDataTmp atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationReloadSkipSettingData object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationReloadReportTags object:nil userInfo:nil];
    
    if (n_passdata<4)
    {
        [self AlertBox:@"Warning." withInfo:@"PASS data less than 3, it can not calculate cpk value. \r\nPlease check CPK distribution by click “NO” in “Remove Fail”"];
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationIndicatorMsg object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"UI Parse file done.",kStartupMsg,[NSNumber numberWithInt:MSG_LEVEL_NORMAL],kStartupLevel,[NSNumber numberWithFloat:6/n_loadStepCount], kStartupPercentage, nil]];
    return YES;
}

-(NSString *)combineItemName:(NSString *)name
{
    NSString *str_name = @"";
    str_name = [NSString stringWithFormat:@"%@##%@&%@",name,[m_configDictionary valueForKey:kRetestSeg],[m_configDictionary valueForKey:kRemoveFailSeg]];
    return str_name;
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

-(NSArray *)reverseArray_ext:(NSArray *)array
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
                if (i==0 && j==0)
                {
                    newArray[j][i] = @"Parametric";
                }
                else
                {
                newArray[j][i] = @"";
                }
            }
            else
            {
                if (i==0 && j==0)
                {
                    newArray[j][i] = @"Parametric";
                }
                else
                {
                    newArray[j][i] = array[i][j];
                }
            }
        }
    }
    return newArray;
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
   
    NSLog(@"--->>set name to redis:%@  %zd",name,[arrData count]);
//    NSArray *nameArr = [name componentsSeparatedByString:@"###"];
//    if ([nameArr count]>1)
//    {
//        NSArray *nameArrOp = [nameArr[1] componentsSeparatedByString:@"&"];
//        if ([nameArrOp count]>1)
//        {
//            NSLog(@"==retest: %@  remove: %@",nameArrOp[0],nameArrOp[1]);
//        }
//    }
}

-(void)sendStringToRedis:(NSString *)name withData:(NSString *)strData
{
    if (myRedis)
    {
         myRedis->SetString([name UTF8String],[strData UTF8String]);
    }
    else
    {
        [self AlertBox:@"Error:027" withInfo:@"Redis server is shut down!"];
    }
}


//-(void)setCpkImage:(NSString *)path
//{
//     NSImage *imageCPK = [[NSImage alloc]initWithContentsOfFile:path];
//     dispatch_async(dispatch_get_main_queue(), ^{
//        [self.cpkImageMap setImage:imageCPK];
//    });
//}
//-(void)setCorrelationImage:(NSString *)path
//{
//     NSImage *imageCorrelation = [[NSImage alloc]initWithContentsOfFile:path];
//     dispatch_async(dispatch_get_main_queue(), ^{
//         [self.correlationImageMap setImage:imageCorrelation];
//    });
//}

-(NSString *)sendBoxZmqMsg:(NSString *)name
{
//    NSString *file1 = @"/tmp/CPK_Log/temp/box.png";
//    NSFileManager *manager = [NSFileManager defaultManager];
//    [manager removeItemAtPath:file1 error:nil];
//    NSString *picPath =[[NSBundle mainBundle]pathForResource:@"box.png" ofType:nil];
//    [manager copyItemAtPath:picPath toPath:file1 error:nil];
    
    int ret = [boxClient SendCmd:name];
    if (ret > 0)
    {
        NSString * response = [boxClient RecvRquest:1024];
        if (!response)
        {
            NSLog(@"zmq for Box python error");
        }
        NSLog(@"app->get response from python: %@",response);
        return response;
    }
    return nil;
}

-(NSString *)sendCpkZmqMsg:(NSString *)name
{
    NSString *file1 = @"/tmp/CPK_Log/temp/cpk.png";//[NSString stringWithFormat:@"%@/CPK_Log/temp/cpk.png",desktopPath];
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager removeItemAtPath:file1 error:nil];
    NSString *picPath =[[NSBundle mainBundle]pathForResource:@"cpk.png" ofType:nil];
    [manager copyItemAtPath:picPath toPath:file1 error:nil];
    
    int ret = [cpkClient SendCmd:name];
    if (ret > 0)
    {
        NSString * response = [cpkClient RecvRquest:1024];
        if (!response)
        {
            NSLog(@"zmq for Cpk python error");
        }
        NSLog(@"app->get response from python: %@",response);
        return response;
    }
    return nil;
}

-(NSString *)sendCalculateZmqMsg:(NSString *)name
{
    NSString *path1 = [m_configDictionary valueForKey:Load_Csv_Path];
    if (b_isCustomCSV)
    {
        path1 = kcustomToInsightCsv;
    }
    NSString *path2 = @"/tmp/CPK_Log/temp/calculate_param.csv";//[NSString stringWithFormat:@"%@/CPK_Log/temp/calculate_param.csv",desktopPath];
    NSString *path3 = @"/tmp/CPK_Log/temp/.logcalc.txt";//[NSString stringWithFormat:@"%@/CPK_Log/temp/.logcalc.txt",desktopPath];
    
    NSString *cpkL= [m_configDictionary valueForKey:cpk_Lowthl];
    NSString *cpkH = [m_configDictionary valueForKey:cpk_Highthl];
    NSString *msg = [NSString stringWithFormat:@"%@$$%@$$%@$$%@$$%@$$%@",name,path1,path2,path3,cpkL,cpkH];  //calculate-param

    int ret = [calculateClient SendCmd:msg];
    if (ret > 0)
    {
        NSString * response = [calculateClient RecvRquest:1024];
        if (!response)
        {
            NSLog(@"zmq for python calculate error");
        }
        NSLog(@"app->get response from python calculate: %@",response);
        return response;
    }
    return nil;
}

-(NSString *)sendCalculateZmqMsgLocal:(NSString *)name
{
    NSString *path1 = [m_configDictionary valueForKey:Load_Local_Csv_Path];
    if (b_isCustomCSV)
    {
        path1 = kcustomToInsightCsv;
    }
    NSString *path2 = @"/tmp/CPK_Log/temp/calculate_param.csv";//[NSString stringWithFormat:@"%@/CPK_Log/temp/calculate_param.csv",desktopPath];
    NSString *path3 = @"/tmp/CPK_Log/temp/.logcalc.txt";//[NSString stringWithFormat:@"%@/CPK_Log/temp/.logcalc.txt",desktopPath];
    
    NSString *cpkL= [m_configDictionary valueForKey:cpk_Lowthl];
    NSString *cpkH = [m_configDictionary valueForKey:cpk_Highthl];
    NSString *msg = [NSString stringWithFormat:@"%@$$%@$$%@$$%@$$%@$$%@",name,path1,path2,path3,cpkL,cpkH];  //calculate-param_local
    NSLog(@"--calculte local name: %@",msg);
    int ret = [calculateClient SendCmd:msg];
    if (ret > 0)
    {
        NSString * response = [calculateClient RecvRquest:1024];
        if (!response)
        {
            NSLog(@"zmq for python calculate local error");
        }
        NSLog(@"app->get response from python calculate local: %@",response);
        return response;
    }
    return nil;
}

-(NSString *)sendYieldRateZmqMsg:(NSString *)name
{
    NSString *path1 = @"/tmp/CPK_Log/temp/yield_rate_param.csv";//[NSString stringWithFormat:@"%@/CPK_Log/temp/yield_rate_param.csv",desktopPath];
    NSString *path2 = @"/tmp/CPK_Log/temp/.logretest.txt";//[NSString stringWithFormat:@"%@/CPK_Log/temp/.logretest.txt",desktopPath];
    NSString *csv_Data = [m_configDictionary valueForKey:Load_Csv_Path];
    if (b_isCustomCSV)
    {
        csv_Data = kcustomToInsightCsv;
    }
    NSString *msg = [NSString stringWithFormat:@"%@$$%@$$%@$$%@",name,csv_Data,path1,path2];  //retest rate-param

    int ret = [retestRateClient SendCmd:msg];
    if (ret > 0)
    {
        NSString * response = [retestRateClient RecvRquest:1024];
        if (!response)
        {
            NSLog(@"zmq for python retest rate  error");
        }
        NSLog(@"app->get response from python retest rate: %@",response);
        return response;
    }
    return nil;
}


-(void)initRetestPlotAndCsv
{
    NSArray *remove_path = @[pie_retest_csv,retest_csv_csv,retest_vs_station_id_csv,retest_vs_version_csv,summary_retest_csv,cpk_min_max_csv,daily_retest_summary_png,fail_item_overall_csv,fail_pareto_png,retest_breakdown_fixture_csv,retest_item_overall_csv,retest_pareto_png,retest_pie_png,retest_vs_station_id_png,retest_vs_version_png,header_info_csv_csv,fail_csv_csv,total_count_by_version_csv,total_count_by_station_slot_id_csv,total_count_by_date_product_csv,yield_rate_param_tmp_csv,cpk_range_csv,daily_all_retest_summary_png,KYieldRatePath,KbuildSummary];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (NSString *path_object in remove_path)
    {
        [fileManager removeItemAtPath:path_object error:NULL];
    }
    
    for (int i=0; i<100; i++)
    {
        NSString *filePath1 = [NSString stringWithFormat:@"%@%d.png",daily_retest_summary_x,i+1];
        BOOL isExist1 = [fileManager fileExistsAtPath:filePath1];
        if (isExist1)
        {
            [fileManager removeItemAtPath:filePath1 error:NULL];
        }
        NSString *filePath2 = [NSString stringWithFormat:@"%@%d.png",retest_vs_station_id_x,i+1];
        BOOL isExist2 = [fileManager fileExistsAtPath:filePath2];
        if (isExist2)
        {
            [fileManager removeItemAtPath:filePath2 error:NULL];
        }
        NSString *filePath3 = [NSString stringWithFormat:@"%@%d.png",retest_vs_version_x,i+1];
        BOOL isExist3 = [fileManager fileExistsAtPath:filePath3];
        if (isExist3)
        {
            [fileManager removeItemAtPath:filePath3 error:NULL];
        }
        
        NSString *filePath4 = [NSString stringWithFormat:@"%@%d.png",daily_all_retest_summary_x,i+1];
        BOOL isExist4 = [fileManager fileExistsAtPath:filePath4];
        if (isExist4)
        {
            [fileManager removeItemAtPath:filePath4 error:NULL];
        }
        
        if (!isExist1 && !isExist2 && !isExist3 && !isExist4)
        {
            break;
        }
      
    }
 
    
    NSString *pathretest =@"/tmp/CPK_Log/retest/.retest_plot.txt";
    [@"Finished,init retest folder empty!" writeToFile:pathretest atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

-(NSString *)sendRetestPlotZmqMsg:(NSString *)name
{
    NSString *path1 = @"/tmp/CPK_Log/retest/.retest_csv.csv";
    NSString *path2 = @"/tmp/CPK_Log/retest/.pie_retest.csv";
    NSString *csv_Data = [m_configDictionary valueForKey:Load_Csv_Path];
    if (b_isCustomCSV)
    {
        csv_Data = kcustomToInsightCsv;
    }
    NSString *msg = [NSString stringWithFormat:@"%@$$%@$$%@$$%@",name,csv_Data,path1,path2];  //retest rate-param

    int ret = [retestPlotClient SendCmd:msg];
    if (ret > 0)
    {
        NSString * response = [retestPlotClient RecvRquest:1024];
        if (!response)
        {
            NSLog(@"zmq for python retest plot  error");
        }
        NSLog(@"app->get response from python retest plot: %@",response);
        return response;
    }
    return nil;
}

-(NSString *)sendYieldRateZmqMsgLocal:(NSString *)name
{
    NSString *path1 = @"/tmp/CPK_Log/temp/yield_rate_param.csv";//[NSString stringWithFormat:@"%@/CPK_Log/temp/yield_rate_param.csv",desktopPath];
    NSString *path2 = @"/tmp/CPK_Log/temp/.logretest.txt";//[NSString stringWithFormat:@"%@/CPK_Log/temp/.logretest.txt",desktopPath];
    NSString *csv_Data = [m_configDictionary valueForKey:Load_Local_Csv_Path];
    if (b_isCustomCSV)
    {
        csv_Data = kcustomToInsightCsv;
    }
    NSString *msg = [NSString stringWithFormat:@"%@$$%@$$%@$$%@",name,csv_Data,path1,path2];  //retest rate-param

    int ret = [retestRateClient SendCmd:msg];
    if (ret > 0)
    {
        NSString * response = [retestRateClient RecvRquest:1024];
        if (!response)
        {
            NSLog(@"zmq for python retest rate  error");
        }
        NSLog(@"app->get response from python retest rate: %@",response);
        return response;
    }
    return nil;
}

-(NSString *)sendCorrelationZmqMsg:(NSString *)name
{
    NSString *file1 = @"/tmp/CPK_Log/temp/correlation.png";//[NSString stringWithFormat:@"%@/CPK_Log/temp/correlation.png",desktopPath];
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager removeItemAtPath:file1 error:nil];
    NSString *picPath =[[NSBundle mainBundle]pathForResource:@"correlation.png" ofType:nil];
    [manager copyItemAtPath:picPath toPath:file1 error:nil];
    NSLog(@"---set sendCorrelationZmqMsg:%@",name);
    int ret = [correlationClient SendCmd:name];
    if (ret > 0)
    {
        NSString * response = [correlationClient RecvRquest:1024];
        if (!response)
        {
            NSLog(@"zmq for python Correlation error");
        }
        NSLog(@"app->correlation get response from python: %@",response);
        return response;
    }
    return nil;
}

-(NSString *)sendScatterZmqMsg:(NSString *)name
{
    NSString *file1 = @"/tmp/CPK_Log/temp/scatter.png";//[NSString stringWithFormat:@"%@/CPK_Log/temp/scatter.png",desktopPath];
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager removeItemAtPath:file1 error:nil];
    NSString *picPath =[[NSBundle mainBundle]pathForResource:@"scatter.png" ofType:nil];
    [manager copyItemAtPath:picPath toPath:file1 error:nil];
    NSLog(@">>set send Scatter Zmq Msg:%@",name);
    int ret = [scatterClient SendCmd:name];
    if (ret > 0)
    {
        NSString * response = [scatterClient RecvRquest:1024];
        if (!response)
        {
            NSLog(@"zmq for Scatter python error");
        }
        NSLog(@"app->scatter get response from python: %@",response);
        return response;
    }
    return nil;
}


-(NSMutableArray *)removeFailData:(NSInteger)seletRow
{
    NSMutableArray *tempArray = [NSMutableArray array];
    NSMutableArray *itemArray = _dataReverse[seletRow+n_Start_Data_Col];
    NSArray *arrayCol = _dataReverse[n_Pass_Fail_Status];
    for (NSInteger i=0; i<[arrayCol count]; i++)
    {
        if (![arrayCol[i] isEqualToString:@"FAIL"]) {
            [tempArray addObject:itemArray[i]];
        }
    }
    return tempArray;
}

-(NSMutableArray *)removeFailDataIndex:(int)removeF
{
    NSMutableArray *tempArray = [NSMutableArray array];
    if (removeF==0)    // remove fail = yes
    {
        NSArray *arrayCol = _dataReverse[n_Pass_Fail_Status];
        for (int i=0; i<[arrayCol count]; i++)
        {
            if ([arrayCol[i] isEqualToString:@"FAIL"])
            {
                [tempArray addObject:[NSNumber numberWithInt:i]];
            }
        }
    }
    else if (removeF==1) //remove fail = no
    {
       // nothing need to do
    }
    return tempArray;
}

-(NSMutableArray *)addPassDataIndex
{
    NSMutableArray *tempArrayIndex = [NSMutableArray array];
    NSArray *arrayCol = _dataReverse[n_Pass_Fail_Status];
    for (NSInteger i=0; i<[arrayCol count]; i++)
    {
        if (![arrayCol[i] isEqualToString:@"FAIL"]) {
            [tempArrayIndex addObject:[NSNumber numberWithInteger:i]];
        }
    }
    return tempArrayIndex;
}

-(int)compareTime:(NSString*)date01 withDate:(NSString*)date02
{
    int ci;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *dt1 = [[NSDate alloc] init];
    NSDate *dt2 = [[NSDate alloc] init];
    dt1 = [df dateFromString:date01];
    dt2 = [df dateFromString:date02];
    NSComparisonResult result = [dt1 compare:dt2];
    switch (result)
    {
        case NSOrderedAscending: ci=1; break;  //date02比date01大
        case NSOrderedDescending: ci=-1; break; //date02比date01小
        case NSOrderedSame: ci=0; break; //date02=date01
        default: NSLog(@"erorr dates %@, %@", dt2, dt1); break;
    }
    return ci;
}

-(int)compareStartTime:(NSString*)date01 withDate:(NSString*)date02
{
    if ([date01 isEqualToString:@""])
    {
        return 1;
    }
    long time01 = [self getTimeNumberWithString:date01];
    long time02 = [self getTimeNumberWithString:date02];
    if (time01>time02)
    {
        return -1;
    }
    else if (time01<time02)
    {
        return 1;
    }
    else
    {
        return 0;
    }
}

-(int)compareStartTime2:(NSString*)date01 withDate:(NSString*)date02
{
    if ([date01 isEqualToString:@""])
    {
        return -1;
    }
    long time01 = [self getTimeNumberWithString:date01];
    long time02 = [self getTimeNumberWithString:date02];
    if (time01>time02)
    {
        return -1;
    }
    else if (time01<time02)
    {
        return 1;
    }
    else
    {
        return 0;
    }
}


//字符串转时间戳 如：2017-4-10 17:15:10
- (NSString*)getTimeStrWithString:(NSString *)str
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];// 创建一个时间格式化对象
    if ([str length]>17)
    {
        [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; //设定时间的格式
    }
    else
    {
        [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; //设定时间的格式
    }
    NSDate *tempDate = [dateFormatter dateFromString:str];//将字符串转换为时间对象
    NSString *timeStr = [NSString stringWithFormat:@"%ld", (long)[tempDate timeIntervalSince1970]];//字符串转成时间戳,精确到毫秒*1000
    return timeStr;
}

- (long)getTimeNumberWithString:(NSString *)str{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];// 创建一个时间格式化对象
    if ([str length]>17)
    {
        [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; //设定时间的格式
    }
    else
    {
        [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"]; //设定时间的格式
    }
    NSDate *tempDate = [dateFormatter dateFromString:str];//将字符串转换为时间对象
    return (long)[tempDate timeIntervalSince1970];
}

-(NSMutableArray *)failPassItemDataIndex:(NSInteger)seletRow withRemoveOption:(int)removeF
{
    NSMutableArray *dataTemp = nil;
    if (removeF==0)    // remove fail = yes
    {
        dataTemp = [self removeFailData:seletRow];
    }
    else if (removeF==1) //remove fail = no
    {
        dataTemp = _dataReverse[seletRow+n_Start_Data_Col];
    }
    return dataTemp;
}


-(NSArray *)getItemDataIndexWithRetestOption:(int)retestSeg withRemoveOption:(int)removeFSeg
{
    if (retestSeg == 1)   // retest = all
    {
        return nil;
    }
    
    NSMutableArray *snArray = _dataReverse[n_SerialNumber];
    NSMutableArray *startTimeArray;
    if (n_StartTime ==900000)
    {
        startTimeArray = [NSMutableArray arrayWithArray:@[@""]];
    }
    else
    {
        startTimeArray = _dataReverse[n_StartTime];
    }
    
    NSArray *arrayFailPass = _dataReverse[n_Pass_Fail_Status];
    
    NSMutableArray *arrayUnique = [NSMutableArray array];
    NSMutableArray *arraySame = [NSMutableArray array];
    for (unsigned i = 0; i<[snArray count]; i++)
    {
        if ([arrayUnique containsObject:[snArray objectAtIndex:i]] == NO)
        {
            [arrayUnique addObject:[snArray objectAtIndex:i]];
        }
        else
        {
            [arraySame addObject:[snArray objectAtIndex:i]];
            
        }
    }
    NSSet *setX = [NSSet setWithArray:arraySame];
    NSArray * arrayD = [setX allObjects];
    
    NSMutableArray *timeArrIndex = [NSMutableArray array];   //retest 选项所有相同的元素 索引
    NSMutableArray *timeArrMaxIndex = [NSMutableArray array];   //retest last 即时间最大元素
    if ([arrayD count] >0)
    {
        for (NSString *snDuplicate in arrayD)
        {
            if (snDuplicate && [snDuplicate isNotEqualTo:@""])
            {
                NSString * maxStartTime=@"";
                int maxTimeIndex = 0;
                int ii=0;
                for (NSString *object in snArray)
                {
                    if ([snDuplicate isEqualToString:object])
                    {
                        [timeArrIndex addObject:[NSNumber numberWithInt:ii]];
                        if (retestSeg == 2)  // retest last
                        {
                            int result;
                            if (n_StartTime ==900000)
                            {
                                result = 1;
                            }
                            else
                            {
                                result = [self compareStartTime:maxStartTime withDate:startTimeArray[ii]];
                            }
                            
                            //NSLog(@"====retult: %d",result);
                            if(result==1)
                            {
                                if (removeFSeg == 0)
                                {
                                    if (![arrayFailPass[ii] isEqualToString:@"FAIL"])
                                    {
                                        if (n_StartTime ==900000)
                                        {
                                            maxTimeIndex = ii;
                                        }
                                        else
                                        {
                                            maxStartTime = startTimeArray[ii];
                                            maxTimeIndex = ii;
                                        }
                                        
                                    }
                                }
                                else
                                {
                                    if (n_StartTime ==900000)
                                    {
                                        maxTimeIndex = ii;
                                    }
                                    else
                                    {
                                        maxStartTime = startTimeArray[ii];
                                        maxTimeIndex = ii;
                                    }
                                    
                                }
                            }
                        }
                        else if (retestSeg == 0)  //   retest first
                        {
                            int result;
                            
                            if (n_StartTime ==900000)
                            {
                                result = -1;
                            }
                            else
                            {
                                result = [self compareStartTime2:maxStartTime withDate:startTimeArray[ii]];
                            }
                            
                            //NSLog(@"====1 retult: %d",result);
                            if(result==-1)
                            {
                                if (removeFSeg == 0)  // remove fail=yes
                                {
                                    if (![arrayFailPass[ii] isEqualToString:@"FAIL"])
                                    {
                                        if (n_StartTime ==900000)
                                        {
                                            maxTimeIndex = ii;
                                        }
                                        else
                                        {
                                            maxStartTime = startTimeArray[ii];
                                            maxTimeIndex = ii;
                                        }
                                        
                                    }
                                }
                                else  // remove fail=no
                                {
                                    if (n_StartTime ==900000)
                                    {
                                        maxTimeIndex = ii;
                                    }
                                    else
                                    {
                                        maxStartTime = startTimeArray[ii];
                                        maxTimeIndex = ii;
                                    }
                                    
                                }
                            }
                        }

                    }
                    ii++;
                }
                [timeArrMaxIndex addObject:[NSNumber numberWithInt:maxTimeIndex]];
                //NSLog(@"**************");
            }

        }
    }
    
    NSPredicate * filterPredicate = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",timeArrMaxIndex];
    NSArray * filterLast = [timeArrIndex filteredArrayUsingPredicate:filterPredicate];  //==剔除Last 之前数据
    //NSLog(@"===剔除Last 之前数据 : %@  %@   %@",timeArrIndex,timeArrMaxIndex,filterLast);
    return filterLast;
}

-(NSMutableArray *)getItemDataWithRetestIndex:(NSArray *)filterData withRemoveFailIndex:(NSArray *)filterData2 bySelectRow:(NSInteger )seletRow  //根据index 删除数据
{
    NSMutableArray *itemArray = _dataReverse[seletRow+n_Start_Data_Col];
    NSMutableArray *tempArray = [NSMutableArray array];
    for (int i=0; i<[itemArray count]; i++)
    {
        if (![filterData containsObject:[NSNumber numberWithInt:i]] && ![filterData2 containsObject:[NSNumber numberWithInt:i]])
        {
           [tempArray addObject:itemArray[i]];
        }
    }
    //NSLog(@"====tempArray==>> %zd  %@",[tempArray count],tempArray);
    NSLog(@"====tempArray==>> %zd",[tempArray count]);
    return tempArray;
}

-(NSMutableArray *)getItemDataWithRetestIndex:(NSArray *)filterData bySelectRow:(NSInteger )seletRow  //根据index 删除数据
{
    NSMutableArray *itemArray = _dataReverse[seletRow+n_Start_Data_Col];
    NSMutableArray *snArray = _dataReverse[n_SerialNumber];
    NSMutableArray *tempArray = [NSMutableArray array];
    NSMutableArray *snTmpArray = [NSMutableArray array];
    
    bool isData = false;
    for (int i=0; i<[itemArray count]; i++)
    {
        if (![filterData containsObject:[NSNumber numberWithInt:i]])
        {
            //Added By Vito
            // Check if data is ""/"SKIP"/"none"/"nan"
           
            
            NSString * curInfo =[NSString stringWithFormat:@"%@",itemArray[i]];
            if ([[curInfo lowercaseString] isEqualToString:@"start_data"]) {
                isData = true;
            }
            if (isData  and ![[curInfo lowercaseString] isEqualToString:@"start_data"] ) {
                
                
                //& ([[curInfo lowercaseString] isEqualToString:@"nan"] ||
//                              [[curInfo lowercaseString] isEqualToString:@"none"] ||
//                              [[curInfo lowercaseString] isEqualToString:@""] ||
//                              [[curInfo lowercaseString] isEqualToString:@"skip"])
//
            
                NSString *pattern = @"-?\\d+\\.\\d+";

                NSRegularExpression *regular = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];

                NSArray *results = [regular matchesInString:curInfo options:0 range:NSMakeRange(0, curInfo.length)];
                
                NSString *pattern1 = @"\\d+";

                NSRegularExpression *regular1 = [[NSRegularExpression alloc] initWithPattern:pattern1 options:NSRegularExpressionCaseInsensitive error:nil];

                NSArray *results1 = [regular1 matchesInString:curInfo options:0 range:NSMakeRange(0, curInfo.length)];
                
                if ([results count] >0 | [results1 count] > 0) {
                    
                }
                else{
                    NSLog(@"data:%@",curInfo);
                    continue;;
                }
            
                
                
            
            }
           [tempArray addObject:itemArray[i]];
           [snTmpArray addObject:snArray[i]];

         
        }
    }

    [tempArray addObject:End_Data];
    [snTmpArray addObject:End_Data];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:snTmpArray,kSerial_number,tempArray,kData_Value, nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationShowData object:nil userInfo:dic];
    if (![[m_configDictionary valueForKey:kInputRangeFlag] boolValue])
    {
        NSDictionary *dic2 = [NSDictionary dictionaryWithObjectsAndKeys:tempArray[tb_lower],krangelsl,tempArray[tb_upper],krangeusl, nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationSetRangeLslUsl object:nil userInfo:dic2];
    }
    
    return tempArray;
}

-(NSMutableArray *)calculateData:(NSInteger )seletRow withRetest:(NSString *)opt1 withRemove:(NSString *)opt2
{
   // retest: first=0 all=1,last=2
    //remove fail: yes=0, no=1
    int retest = 0;
    int removeF = 0;
    if ([opt1 isEqualToString:vRetestAll] && [opt2 isEqualToString:vRemoveFailYes])
    {
        retest = 1;
        removeF = 0;
    }
    else if ([opt1 isEqualToString:vRetestAll] && [opt2 isEqualToString:vRemoveFailNo])
    {
        // for save time no need do anything
        retest = 1;
        removeF = 1;
        return _dataReverse[seletRow+n_Start_Data_Col];
    }
    else if ([opt1 isEqualToString:vRetestFirst] && [opt2 isEqualToString:vRemoveFailYes])
    {
        retest = 0;
        removeF = 0;
    }
    else if ([opt1 isEqualToString:vRetestFirst] && [opt2 isEqualToString:vRemoveFailNo])
    {
        retest = 0;
        removeF = 1;
    }
    else if ([opt1 isEqualToString:vRetestLast] && [opt2 isEqualToString:vRemoveFailYes])
    {
        retest = 2;
        removeF = 0;
    }
    else if ([opt1 isEqualToString:vRetestLast] && [opt2 isEqualToString:vRemoveFailNo])
    {
        retest = 2;
        removeF = 1;
    }
    else{
        return [NSMutableArray arrayWithObject:@[@"0"]];
    }
    
    NSMutableArray * removeArrIndex = [self removeFailDataIndex:removeF];
    NSArray *arrIndex = [self getItemDataIndexWithRetestOption:retest withRemoveOption:removeF];
    return [self getItemDataWithRetestIndex:removeArrIndex withRemoveFailIndex:arrIndex bySelectRow:seletRow];
    
}

-(NSMutableArray *)calculateData:(NSInteger )seletRow
{

    NSString *opt1 = [m_configDictionary valueForKey:kRetestSeg];
    NSString *opt2 = [m_configDictionary valueForKey:kRemoveFailSeg];
    NSString *dic_key = [NSString stringWithFormat:@"%@&%@",opt1,opt2];
    NSMutableArray *indexArr = [m_configDictionary valueForKey:dic_key];
    return [self getItemDataWithRetestIndex:indexArr bySelectRow:seletRow];
}



-(void)initRetestAndRemoveFailSeg
{

    int removeF = 0;  //RemoveFail=Yes
    int retest = 1;  //Retest=All
    NSMutableArray * removeArrIndex0 = [self removeFailDataIndex:removeF];
    NSArray *retestArrIndex0 = [self getItemDataIndexWithRetestOption:retest withRemoveOption:removeF];
    for (int i=0; i<[retestArrIndex0 count]; i++)
    {
        [removeArrIndex0 addObject:retestArrIndex0[i]];
    }
    [m_configDictionary setObject:removeArrIndex0 forKey:k_dic_RetestAll_RemoveFailYes];
    
    
    removeF = 1; // RemoveFail=No
    retest = 1; //Retest=All
    NSMutableArray * removeArrIndex1 = [self removeFailDataIndex:removeF];
    NSArray *retestArrIndex1 = [self getItemDataIndexWithRetestOption:retest withRemoveOption:removeF];
    for (int i=0; i<[retestArrIndex1 count]; i++)
    {
        [removeArrIndex1 addObject:retestArrIndex1[i]];
    }
    [m_configDictionary setObject:removeArrIndex1 forKey:k_dic_RetestAll_RemoveFailNo];
    
    removeF = 0; // RemoveFail=Yes
    retest = 0; //Retest=First
    NSMutableArray * removeArrIndex2 = [self removeFailDataIndex:removeF];
    NSArray *retestArrIndex2 = [self getItemDataIndexWithRetestOption:retest withRemoveOption:removeF];
    for (int i=0; i<[retestArrIndex2 count]; i++)
    {
        [removeArrIndex2 addObject:retestArrIndex2[i]];
    }
    [m_configDictionary setObject:removeArrIndex2 forKey:k_dic_RetestFirst_RemoveFailYes];
    
    removeF = 1; // RemoveFail=No
    retest = 0; //Retest=First
    NSMutableArray * removeArrIndex3 = [self removeFailDataIndex:removeF];
    NSArray *retestArrIndex3 = [self getItemDataIndexWithRetestOption:retest withRemoveOption:removeF];
    for (int i=0; i<[retestArrIndex3 count]; i++)
    {
        [removeArrIndex3 addObject:retestArrIndex3[i]];
    }
    [m_configDictionary setObject:removeArrIndex3 forKey:k_dic_RetestFirst_RemoveFailNo];
    
    retest = 2; //Retest=Last
    removeF = 0; //RemoveFail=Yes
    NSMutableArray * removeArrIndex4 = [self removeFailDataIndex:removeF];
    NSArray *retestArrIndex4 = [self getItemDataIndexWithRetestOption:retest withRemoveOption:removeF];
    for (int i=0; i<[retestArrIndex4 count]; i++)
    {
        [removeArrIndex4 addObject:retestArrIndex4[i]];
    }
    [m_configDictionary setObject:removeArrIndex4 forKey:k_dic_RetestLast_RemoveFailYes];

    retest = 2; //Retest=Last
    removeF = 1; //vRemoveFail=No
    NSMutableArray * removeArrIndex5 = [self removeFailDataIndex:removeF];
    NSArray *retestArrIndex5 = [self getItemDataIndexWithRetestOption:retest withRemoveOption:removeF];
     for (int i=0; i<[retestArrIndex5 count]; i++)
     {
         [removeArrIndex5 addObject:retestArrIndex5[i]];
     }
     [m_configDictionary setObject:removeArrIndex5 forKey:k_dic_RetestLast_RemoveFailNo];
    
}

-(void)initColorByTableView
{
    filterItemNames =@[Version,Station_ID,Special_Build_Name,Special_Build_Descrip,Product,Channel_ID,Diags_Version,OS_VERSION];
    
    //version
    if (n_Version_Col== 900003)
    {
        [m_configDictionary setObject:@"" forKey:k_dic_Version];
    }
    else if (n_Version_Col>=0)
    {
        NSArray *arrayVer = _dataReverse[n_Version_Col];
        NSMutableArray *arrM_tmp = [NSMutableArray array];
        for (int i=tb_data_start; i<[arrayVer count]; i++)
        {
            [arrM_tmp addObject:arrayVer[i]];
        }
        NSSet *set = [NSSet setWithArray:arrM_tmp];
        NSArray *tempVer = [set allObjects];
        NSMutableArray *vers = [NSMutableArray array];
        for (int i=0; i<[tempVer count]; i++)
        {
            NSString *tmpVer = @"";
            @try {
                tmpVer = [tempVer[i] uppercaseString];
            }
            @catch (NSException *exception)
            {
                tmpVer = tempVer[i];
            }
            
            
            if ([tempVer[i] isEqualTo:@""])
            {
                if (![vers containsObject:@"BLANK"])
                {
                    [vers addObject:@"BLANK"];
                }
                
            }
            else
            {
                [vers addObject:tempVer[i]];
            }
            
        }
        [m_configDictionary setObject:vers forKey:k_dic_Version];
    }
    else
    {
        [m_configDictionary setObject:@"" forKey:k_dic_Version];
    }
    
 
    // station id
    if (n_StationID_Col == 900002)
    {
        [m_configDictionary setObject:@"" forKey:k_dic_Station_ID];
    }
    else if (n_StationID_Col>=0)
    {
        NSArray *arrayStations = _dataReverse[n_StationID_Col];
        NSMutableArray *arrM_tmp = [NSMutableArray array];
        for (int i=tb_data_start; i<[arrayStations count]; i++)
        {
            [arrM_tmp addObject:arrayStations[i]];
        }
        
        NSSet *setStation = [NSSet setWithArray:arrM_tmp];
        NSArray *tempId = [setStation allObjects];
        NSMutableArray *IDs = [NSMutableArray array];
        for (int i=0; i<[tempId count]; i++)
        {
            NSString *tmpStation = @"";
            @try {
                tmpStation = [tempId[i] uppercaseString];
            }
            @catch (NSException *exception)
            {
                tmpStation = tempId[i];
            }
            
            if ([tempId[i] isNotEqualTo:@""])
            {
                /*if ([tmpStation isNotEqualTo:@"STATION ID"] && [tmpStation isNotEqualTo:@"SITE_ID"] && [tmpStation isNotEqualTo:@"STATION_ID"])
                {
                    [IDs addObject:tempId[i]];
                }*/
                [IDs addObject:tempId[i]];
            }
            else
            {
                if (![IDs containsObject:@"BLANK"])
                {
                    [IDs addObject:@"BLANK"];
                }
            }
        }
        [m_configDictionary setObject:IDs forKey:k_dic_Station_ID];
    }
    else
    {
        [m_configDictionary setObject:@"" forKey:k_dic_Station_ID];
    }
     
    
    //Special Build Name
    if (n_SpecialBuildName_Col>=0)
    {
        NSArray *arrayBuildN = _dataReverse[n_SpecialBuildName_Col];
        NSMutableArray *arrM_tmp = [NSMutableArray array];
        for (int i=tb_data_start; i<[arrayBuildN count]; i++)
        {
            [arrM_tmp addObject:arrayBuildN[i]];
        }
        
        NSSet *setBuild = [NSSet setWithArray:arrM_tmp];
        NSArray *tempBuildN = [setBuild allObjects];
        NSMutableArray *BuildNs = [NSMutableArray array];
        for (int i=0; i<[tempBuildN count]; i++)
        {
            NSString *tmpBuild = @"";
            @try {
                tmpBuild = [tempBuildN[i] uppercaseString];
            }
            @catch (NSException *exception)
            {
                tmpBuild = tempBuildN[i];
            }
            
            if ([tempBuildN[i] isNotEqualTo:@""] )
            {
                //if ([tmpBuild isNotEqualTo:@"SPECIAL BUILD NAME"])
                {
                    [BuildNs addObject:tempBuildN[i]];
                }
                
            }
            else
            {
                if (![BuildNs containsObject:@"BLANK"])
                {
                    [BuildNs addObject:@"BLANK"];
                }
            }
        }
        [m_configDictionary setObject:BuildNs forKey:k_dic_Special_Build_Name];
    }
    else
    {
        [m_configDictionary setObject:@"" forKey:k_dic_Special_Build_Name];
    }
    
    
    //Special Build Description
    if (n_Special_Build_Descrip_Col>=0)
    {
           NSArray *arrayBuildD = _dataReverse[n_Special_Build_Descrip_Col];
            NSMutableArray *arrM_tmp = [NSMutableArray array];
            for (int i=tb_data_start; i<[arrayBuildD count]; i++)
            {
                [arrM_tmp addObject:arrayBuildD[i]];
            }
        
           NSSet *setBuildD = [NSSet setWithArray:arrM_tmp];
           NSArray *tempBuildD = [setBuildD allObjects];
           NSMutableArray *BuildDe = [NSMutableArray array];
           for (int i=0; i<[tempBuildD count]; i++)
           {
               NSString *tmpBuildD = @"";
               @try {
                   tmpBuildD = [tempBuildD[i] uppercaseString];
               }
               @catch (NSException *exception)
               {
                   tmpBuildD = tempBuildD[i];
               }
               
               if ([tempBuildD[i] isNotEqualTo:@""])
               {
                   //if ([tmpBuildD isNotEqualTo:@"SPECIAL BUILD DESCRIPTION"])
                   //{
                       [BuildDe addObject:tempBuildD[i]];
                   //}
               }
               else
               {
                   if (![BuildDe containsObject:@"BLANK"])
                   {
                       [BuildDe addObject:@"BLANK"];
                   }
               }
           }
           [m_configDictionary setObject:BuildDe forKey:k_dic_Special_Build_Desc];
    }
    else
    {
        [m_configDictionary setObject:@"" forKey:k_dic_Special_Build_Desc];
    }
   
    
    //Product
    if (n_Product_Col == 900001)
    {
        [m_configDictionary setObject:@"" forKey:k_dic_Product];
    }
    else if (n_Product_Col>=0)
    {
        NSArray *arrayProduct = _dataReverse[n_Product_Col];
        
        NSMutableArray *Produc = [NSMutableArray array];
        for (int i=tb_data_start; i<[arrayProduct count]; i++)
        {
            NSString *tmpProduct = @"";
            @try {
                tmpProduct = [arrayProduct[i] uppercaseString];
            }
            @catch (NSException *exception)
            {
                tmpProduct = arrayProduct[i];
            }
            
            if ([arrayProduct[i] isNotEqualTo:@""] )
            {
                //if ([tmpProduct isNotEqualTo:@"PRODUCT"])
                //{
                    [Produc addObject:arrayProduct[i]];
                //}
            }
            else
            {
                if (![Produc containsObject:@"BLANK"])
                {
                    [Produc addObject:@"BLANK"];
                }
            }
        }
        
        NSSet *setProduct = [NSSet setWithArray:Produc];
        NSArray *tempProduct = [setProduct allObjects];
        [m_configDictionary setObject:tempProduct forKey:k_dic_Product];
    }
    else
    {
        [m_configDictionary setObject:@"" forKey:k_dic_Product];
    }
    
    
    //channel id
    if (n_SlotId_Col == 900005)
    {
        [m_configDictionary setObject:@[@""] forKey:k_dic_Channel_ID];
    }
    else if(b_isCustomCSV)
    {
        if (n_SlotId_Col>0)
        {
            [m_configDictionary setObject:[NSNumber numberWithInt:n_SlotId_Col] forKey:k_dic_Channel_ID_Index];
            
            NSArray *arraySlot = _dataReverse[n_SlotId_Col];
            NSMutableArray *slots = [NSMutableArray array];
            for (int i=tb_data_start; i<[arraySlot count]; i++)
             {
                 if ([arraySlot[i] isNotEqualTo:@""])
                 {
                    [slots addObject:arraySlot[i]];
                 }
                 else
                 {
                     if (![slots containsObject:@"BLANK"])
                     {
                         [slots addObject:@"BLANK"];
                     }
                 }
             }
            NSSet *set = [NSSet setWithArray:slots];
            NSArray *slots_id = [set allObjects];
            [m_configDictionary setObject:slots_id forKey:k_dic_Channel_ID];
        }
        else
        {
            [m_configDictionary setObject:@"" forKey:k_dic_Channel_ID];
        }
    }
    else
    {
        int index_channelId = -1;
        NSString *keyWord =  @"FIXTURE CHANNEL ID";
        NSString *keyWord2 = @"FIXTURE INITILIZATION SLOT_ID";//@"Fixture INITIALIZATION SLOT_ID";
        NSString *keyWord3 = @"FIXTURE RESET CALC FIXTURE_CHANNEL";//@"Fixture Reset CALC fixture_channel";
        NSString *keyWord4 = @"HEAD ID";//@"Head Id";
        NSString *keyWord5 = @"FIXTURE_CHANNEL CHANNEL CHANNEL_ID";
        NSString *keyWord6 = @"FIXTURE CHANNEL CHANNEL_ID";
        NSString *keyWord7 = @"CHANNEL ID";
        NSString *keyWord8 = @"CHANNEL_ID";
        NSString *keyWord9 = @"SLOT ID";
        NSString *keyWord10 = @"SLOT_ID";
        NSString *keyWord11 = @"FIXTURE_SETUP CHANNEL CHANNEL_ID";
        
        NSString *keyWord12 = @"FIXTURE INITIALIZATION SLOT_ID";
        
        NSString *keyWord13 = @"GET SLOT_ID";
        NSString *keyWord14 = @"GET HEAD ID";
        NSString *keyWord15 = @"FIXTURE GET SLOT_ID";
        NSString *keyWord16 = @"SLOT-ID";
        NSString *keyWord17 = @"GET HEAD_ID";
        
        NSString *keyWord18 = @"CHANNEL_D";
        NSString *keyWord19 = @"HEAD_ID";
        
        NSString *keyWord20 = @"SLOT";
        NSString *keyWord21 = @"CHANNEL";
        
        
        
        
        
        

        
        for (int i=0; i<[_ListAllItemNameArr count]; i++)
          {
              if ([[_ListAllItemNameArr[i] uppercaseString] containsString:keyWord] ||
                  [[_ListAllItemNameArr[i] uppercaseString] containsString:keyWord2]||
                  [[_ListAllItemNameArr[i] uppercaseString] containsString:keyWord3]||
                  [[_ListAllItemNameArr[i] uppercaseString] containsString:keyWord4] ||
                  [[_ListAllItemNameArr[i] uppercaseString] containsString:keyWord5] ||
                  [[_ListAllItemNameArr[i] uppercaseString] containsString:keyWord6] ||
                  [[_ListAllItemNameArr[i] uppercaseString] containsString:keyWord7] ||
                  [[_ListAllItemNameArr[i] uppercaseString] containsString:keyWord8] ||
                  [[_ListAllItemNameArr[i] uppercaseString] containsString:keyWord9] ||
                  [[_ListAllItemNameArr[i] uppercaseString] containsString:keyWord10] ||
                  [[_ListAllItemNameArr[i] uppercaseString] containsString:keyWord11] ||
                  [[_ListAllItemNameArr[i] uppercaseString] containsString:keyWord12] ||
                  [[_ListAllItemNameArr[i] uppercaseString] containsString:keyWord13] ||
                  [[_ListAllItemNameArr[i] uppercaseString] containsString:keyWord14] ||
                  [[_ListAllItemNameArr[i] uppercaseString] containsString:keyWord15] ||
                  [[_ListAllItemNameArr[i] uppercaseString] containsString:keyWord16] ||
                  [[_ListAllItemNameArr[i] uppercaseString] containsString:keyWord17] ||
                  [[_ListAllItemNameArr[i] uppercaseString] containsString:keyWord18] ||
                  [[_ListAllItemNameArr[i] uppercaseString] containsString:keyWord19] ||
                  [[_ListAllItemNameArr[i] uppercaseString] containsString:keyWord20] ||
                  [[_ListAllItemNameArr[i] uppercaseString] containsString:keyWord21]
                  )
              {
                  index_channelId = i;
                  break;
              }
              
          }
        if (index_channelId == -1)
        {
            [self AlertBox:@"Warning!!!" withInfo:@"Cant locate the fixture CHANNEL/SLOT/HEAD ID parameter. Please use “Channel_ID” or “Head_ID” or “SLOT_ID” in the Insight CSV file name !!!"];
            
            [m_configDictionary setObject:[NSNumber numberWithInt:index_channelId] forKey:k_dic_Channel_ID_Index];
            [m_configDictionary setObject:@[@"NULL"] forKey:k_dic_Channel_ID];
        }
        else
        {
            index_channelId = index_channelId+ n_Start_Data_Col;
            [m_configDictionary setObject:[NSNumber numberWithInt:index_channelId] forKey:k_dic_Channel_ID_Index];
            if (index_channelId>=n_Start_Data_Col)
            {
                NSArray *arrayChannel = _dataReverse[index_channelId];
                NSMutableArray *channels = [NSMutableArray array];
                for (int i=tb_data_start; i<[arrayChannel count]; i++)
                {
                     if ([arrayChannel[i] isEqualTo:@""])
                     {
                         //[channels addObject:@""];
                         if (![channels containsObject:@"BLANK"])
                         {
                             [channels addObject:@"BLANK"];
                         }
                     }
                    else
                    {
                        [channels addObject:arrayChannel[i]];
                        //[channels addObject:[NSString stringWithFormat:@"slot:%@",arrayChannel[i]]];
                    }
                }
                NSSet *setChannel = [NSSet setWithArray:channels];
                NSArray *channelIDs = [setChannel allObjects];
                [m_configDictionary setObject:channelIDs forKey:k_dic_Channel_ID];
            }
            else
            {
                [self AlertBox:@"Warning!" withInfo:@"The data has no Channel ID!!!"];
                [m_configDictionary setObject:@[@"NULL"] forKey:k_dic_Channel_ID];
            }
        }
    }
    
    //diags version
     if (n_Diags_Version_Col>0)
     {
         NSArray *arrayVer = _dataReverse[n_Diags_Version_Col];
        
         NSMutableArray *vers = [NSMutableArray array];
         for (int i=tb_data_start; i<[arrayVer count]; i++)
         {
             if ([arrayVer[i] isNotEqualTo:@""] )
             {
                [vers addObject:arrayVer[i]];
                 
             }
             else
             {
                 if (![vers containsObject:@"BLANK"])
                 {
                     [vers addObject:@"BLANK"];
                 }
                 
             }
         }
         
         NSSet *set = [NSSet setWithArray:vers];
         NSArray *tempVer = [set allObjects];
         [m_configDictionary setObject:tempVer forKey:k_dic_Diags_Version];
     }
     else
     {
         [m_configDictionary setObject:@"" forKey:k_dic_Diags_Version];
     }
    
    //OS_VERSION
     if (n_OS_VERSION_Col>0)
     {
         NSArray *arrayVer = _dataReverse[n_OS_VERSION_Col];
         
         NSMutableArray *vers = [NSMutableArray array];
         for (int i=tb_data_start; i<[arrayVer count]; i++)
         {
             if ([arrayVer[i] isNotEqualTo:@""])
             {
                [vers addObject:arrayVer[i]];
                 
             }
             else
             {
                 if (![vers containsObject:@"BLANK"])
                 {
                     [vers addObject:@"BLANK"];
                 }
             }
         }
         NSSet *set = [NSSet setWithArray:vers];
         NSArray *tempVer = [set allObjects];
         [m_configDictionary setObject:tempVer forKey:k_dic_OS_Version];
     }
     else
     {
         [m_configDictionary setObject:@"" forKey:k_dic_OS_Version];
     }
    
     // station id & channel id
     /*if (index_channelId>0)
     {
         NSMutableArray *staionChannel = [NSMutableArray array];
         NSArray *arrayChannel = _dataReverse[index_channelId];
         for (int i=27; i<[arrayStations count]; i++)  //从第7行开始
         {
             [staionChannel addObject:[NSString stringWithFormat:@"%@ & %@",arrayStations[i],arrayChannel[i]]];
         }
        
         NSSet *setStationChannel = [NSSet setWithArray:staionChannel];
         NSArray *stationChannelID = [setStationChannel allObjects];
         [m_configDictionary setObject:stationChannelID forKey:k_dic_Station_Channel_ID];
     }
    else
    {
         [m_configDictionary setObject:@[@"NULL"] forKey:k_dic_Station_Channel_ID];
    }
    */
    
    
}

#pragma mark TableView Datasource & delegate

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [_data count];
}


-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString *columnIdentifier = [tableColumn identifier];
    NSTableCellView *view = [_dataTableView makeViewWithIdentifier:columnIdentifier owner:self];
    NSUInteger index = -1;
    if ([columnIdentifier isEqualToString:identifier_index])
    {
     
        index = tb_index;
        NSArray *subviews = [view subviews];
        NSTextField *txtField = subviews[0];
        if ([_colorRedIndex count]>0 || [_colorGreenIndex count]>0 || [_colorGrayIndex count]>0)
        {
            int index_number = [_data[row][tb_index] intValue] -1;
            if ([_colorGreenIndex containsObject:[NSNumber numberWithInt:index_number]])
              {
                 txtField.drawsBackground = YES;
                 txtField.backgroundColor = [NSColor systemGreenColor];
                  txtField.textColor = [NSColor colorWithSRGBRed:0 green:0 blue:0 alpha:100];
              }

            if ([_colorRedIndex containsObject:[NSNumber numberWithInt:index_number]])
               {
                  txtField.drawsBackground = YES;
                  txtField.backgroundColor = [NSColor systemRedColor];
                   txtField.textColor = [NSColor colorWithSRGBRed:0 green:0 blue:0 alpha:100];
               }
            if ([_colorGrayIndex containsObject:[NSNumber numberWithInt:index_number]])
               {
                   txtField.drawsBackground = YES;
                   txtField.backgroundColor = [NSColor grayColor];
                   txtField.textColor = [NSColor whiteColor];
               }
        }
        else
        {
            txtField.drawsBackground = NO;
            txtField.textColor= NSColor.labelColor;
        }
    }
    if ([columnIdentifier isEqualToString:identifier_item])
    {
        index = tb_item;
        NSArray *subviews = [view subviews];
        NSTextField *txtField = subviews[0];

        if (n_double_click == row)
        {
            
            [txtField setEditable:YES];
            [txtField setBordered:NO];
        }
        else
        {
            //NSLog(@"===========n_double_click>>>> %zd  NO",n_double_click);
            [txtField setEditable:NO];
            [txtField setBordered:NO];
        }

//        txtField.tag = row;
//        txtField.target = self;
//        [txtField setAction:@selector(btnClickItem:)];
        
    }
    if ([columnIdentifier isEqualToString:identifier_low]){
        index = tb_lower;

    }
    if ([columnIdentifier isEqualToString:identifier_upper]){
        index = tb_upper;
    }
    if ([columnIdentifier isEqualToString:identifier_unit]){
        index = tb_measurement_unit;
    }
    if ([columnIdentifier isEqualToString:identifier_lsl]){
        index = tb_lsl;
    }
    if ([columnIdentifier isEqualToString:identifier_usl]) {
        index = tb_usl;
    }
    if ([columnIdentifier isEqualToString:identifier_apply]) {
        NSArray *subviews = [view subviews];
        NSButton *checkBoxField = subviews[0];
        checkBoxField.tag = row;
        checkBoxField.target = self;
        [checkBoxField setAction:@selector(btnClickApply:)];
        
        index = tb_apply;
        if ([[_data objectAtIndex:row] count]>index)
        {
            [checkBoxField setState:[[_data objectAtIndex:row][index] intValue]];
        }
        return view;
        
    }
    if ([columnIdentifier isEqualToString:identifier_keynote]) {
        NSArray *subviews = [view subviews];
        NSButton *checkBoxField = subviews[0];
        checkBoxField.tag = row;
        checkBoxField.target = self;
        [checkBoxField setAction:@selector(btnClickKeynoteApply:)];
        
        index = tb_keynote;
        if ([[_data objectAtIndex:row] count]>index)
        {
            [checkBoxField setState:[[_data objectAtIndex:row][index] intValue]];
        }
        return view;
        
    }
    if ([columnIdentifier isEqualToString:identifier_description]) {
         index = tb_description;
    }
    if ([columnIdentifier isEqualToString:identifier_cpknew])
    {
        index = tb_cpk_new;
        NSString *cpk_new_data = [_data objectAtIndex:row][index];
        NSArray *subviews = [view subviews];
        NSTextField *txtField = subviews[0];
        txtField.drawsBackground = YES;
        
        if ([cpk_new_data isNotEqualTo:@""] && ([self isPureInt:cpk_new_data] ||[self isPureFloat:cpk_new_data]))
        {
            float cpkL = [[m_configDictionary valueForKey:cpk_Lowthl] floatValue];
            float cpkH = [[m_configDictionary valueForKey:cpk_Highthl] floatValue];
            float cpk_new_val = [cpk_new_data floatValue];
            if (cpk_new_val> cpkH)
            {
                txtField.backgroundColor = [NSColor systemYellowColor];
                txtField.textColor = [NSColor colorWithSRGBRed:0 green:0 blue:0 alpha:100];
            }
            else if(cpk_new_val< cpkL)
            {
                txtField.backgroundColor = [NSColor redColor];
            }
            else
            {
                txtField.backgroundColor = [NSColor systemGreenColor];
                txtField.textColor = [NSColor colorWithSRGBRed:0 green:0 blue:0 alpha:100];
            }
            
        }
        else
        {
            txtField.drawsBackground = NO;
            txtField.textColor= NSColor.labelColor;
        }
        
        
    }
    if ([columnIdentifier isEqualToString:identifier_command]) {
         index = tb_command;
    }
    if ([columnIdentifier isEqualToString:identifier_reviewer]) {
         index = tb_reviewer;
    }
    if ([columnIdentifier isEqualToString:identifier_date]) {
         index = tb_date;
    }
    if ([columnIdentifier isEqualToString:identifier_bmc]) {
         index = tb_bmc;
    }
    if ([columnIdentifier isEqualToString:identifier_comment]) {
         index = tb_comment;
    }
    if ([columnIdentifier isEqualToString:identifier_cpk_orig]) {
         index = tb_cpk_orig;
        NSArray *subviews = [view subviews];
        NSTextField *txtField = subviews[0];
        
        if ([_colorRedIndexCpk count]>0 || [_colorGreenIndexCpk count]>0 || [_colorYellowIndexCpk count]>0)
        {
            int index_number = [_data[row][tb_index] intValue] -1;
            if ([_colorRedIndexCpk containsObject: [NSNumber numberWithInt:index_number] ])
            {
                txtField.drawsBackground = YES;
                txtField.backgroundColor = [NSColor systemRedColor];
            }else if ([_colorGreenIndexCpk containsObject:[NSNumber numberWithInt:index_number]])
            {
                txtField.drawsBackground = YES;
                txtField.backgroundColor = [NSColor systemGreenColor];
                txtField.textColor = [NSColor colorWithSRGBRed:0 green:0 blue:0 alpha:100];
            }else if ([_colorYellowIndexCpk containsObject:[NSNumber numberWithInt:index_number]])
            {
                txtField.drawsBackground = YES;
                txtField.backgroundColor = [NSColor systemYellowColor];
                txtField.textColor = [NSColor colorWithSRGBRed:0 green:0 blue:0 alpha:100];
                
            }
            else
            //if (![_colorRedIndexCpk containsObject:@(index_number)] && ![_colorGreenIndexCpk containsObject:@(index_number)] && ![_colorYellowIndexCpk containsObject:@(index_number)])
             {
                 txtField.drawsBackground = NO;
                 //txtField.backgroundColor = [NSColor whiteColor];
             }
            
        }
        else
        {
            txtField.drawsBackground = NO;
            //txtField.backgroundColor = [NSColor whiteColor];
        }
        
    }
//    if (index == -1)
//    {
//        return nil;
//    }

    if ([[_data objectAtIndex:row] count]>index)
    {
        [[view textField] setStringValue:[_data objectAtIndex:row][index]];
    }
    else
    {
         [[view textField] setStringValue:@""];
    }
    
    
    return view;
}

-(NSMutableDictionary*)mappingFilterArray:(NSString*) nstrId {
    
    int index = -1;
    NSMutableDictionary* retArray = nil;
    if ([nstrId isEqualToString:identifier_index])
    {
        index = tb_index;
        retArray = indexfilterFlag;
    }
    if ([nstrId isEqualToString:identifier_unit]){
        index = tb_measurement_unit;
        retArray = unitfilterFlag;
    }
    if ([nstrId isEqualToString:identifier_reviewer]) {
         index = tb_reviewer;
        retArray = reviewerfilterFlag;
    }
    if([nstrId isEqualToString:identifier_keynote]){
        
        index = tb_keynote;
        retArray = reviewerKFlag;
    }
    if ([nstrId isEqualToString:identifier_bmc]) {
         index = tb_bmc;
        retArray = bmfilterFlag;
    }
    if ([nstrId isEqualToString:identifier_cpk_orig]) {
         index = tb_cpk_orig;
        retArray =  cpk_origfilterFlag;
    }
    if ([nstrId isEqualToString:identifier_usl]) {
         index = tb_usl;
        retArray =  uslfilterFlag;
    }
    if ([nstrId isEqualToString:identifier_lsl]) {
         index = tb_lsl;
        retArray =  lslfilterFlag;
    }
    
    return retArray;
}
-(int32_t)mappingColumname:(NSString*) nstrId {
    
    int index = -1;
    if ([nstrId isEqualToString:identifier_index])
    {
        index = tb_index;
    }
    if ([nstrId isEqualToString:identifier_item])
    {
        index = tb_item;
    }
    if ([nstrId isEqualToString:identifier_low]){
        index = tb_lower;
    }
    if ([nstrId isEqualToString:identifier_upper]){
        index = tb_upper;
    }
    if ([nstrId isEqualToString:identifier_unit]){
        index = tb_measurement_unit;
    }
    if ([nstrId isEqualToString:identifier_lsl]){
        index = tb_lsl;
    }
    if ([nstrId isEqualToString:identifier_usl]) {
        index = tb_usl;
    }
    if ([nstrId isEqualToString:identifier_apply]) {
        index = tb_apply;
    }
    if ([nstrId isEqualToString:identifier_keynote]) {
        index = tb_keynote;
    }
    if ([nstrId isEqualToString:identifier_description]) {
         index = tb_description;
    }
    if ([nstrId isEqualToString:identifier_cpknew])
    {
        index = tb_cpk_new;
    }
    if ([nstrId isEqualToString:identifier_command]) {
         index = tb_command;
    }
    if ([nstrId isEqualToString:identifier_reviewer]) {
         index = tb_reviewer;
    }
    if ([nstrId isEqualToString:identifier_date]) {
         index = tb_date;
    }
    if ([nstrId isEqualToString:identifier_bmc]) {
         index = tb_bmc;
    }
    if ([nstrId isEqualToString:identifier_comment]) {
         index = tb_comment;
    }
    if ([nstrId isEqualToString:identifier_cpk_orig]) {
         index = tb_cpk_orig;
    }
    
    return index;
}
- (void)tableView:(NSTableView *)tableView setObjectValue:(nullable id)object forTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSLog(@"====edit:  %@",object);
 

    NSString *col_identifier = [tableColumn identifier];
    NSLog(@">>edit row: %zd , col_identifier: %@",row,col_identifier);
    
    if([col_identifier isEqualToString:identifier_usl]){
      
        
        filterSourceData[row][tb_usl] =object;
    }
    else if([col_identifier isEqualToString:identifier_lsl]){
        filterSourceData[row][tb_usl] =object;
 
    }

        
           
}

-(void)tableView:(NSTableView *)tableView didDragTableColumn:(NSTableColumn *)tableColumn
{
    [self resizeTableViewHeader];
   
}


- (void)tableViewColumnDidResize:(NSNotification *)notification
{
    [self resizeTableViewHeader];
    
}
- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    //NSLog(@">tableViewSelectionDidChange: %@",notification);
}
- (void)tableViewColumnDidMove:(NSNotification *)notification
{
    //NSLog(@">tableViewColumnDidMove: %@",notification);
}

-(void)resizeTableViewHeader
{
    
    for (int col = 0; col<[helpInfo_name count]; col ++)
    {
        NSString *col_identifier = [[[self.dataTableView tableColumns] objectAtIndex:col] identifier];
        if([col_identifier isNotEqualTo:identifier_item]&& [col_identifier isNotEqualTo:identifier_unit])
        {
            NSRect rect = [self.tbViewHeader headerRectOfColumn:col];
            [dicHeaderName setObject:[NSValue valueWithRect:rect] forKey:col_identifier];
            [[dicMouseFunc valueForKey:col_identifier] setFrame:rect];
            [self.tbViewHeader addSubview:[dicMouseFunc valueForKey:col_identifier]];
        }
    }
}


- (BOOL)isAllNum:(NSString *)string{
    unichar c;
    for (int i=0; i<string.length; i++) {
        c=[string characterAtIndex:i];
        if (!isdigit(c)) {
            return NO;
        }
    }
    return YES;
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



-(BOOL)isPureNumandCharacters:(NSString *)string
{
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
    if(string.length > 0)
    {
        return NO;
    }
    return YES;
 

}

-(BOOL)isOnlyhasNumberAndpointWithString:(NSString *)string{
    NSCharacterSet *cs=[[NSCharacterSet characterSetWithCharactersInString:NUMBERS] invertedSet];
    NSString *filter=[[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    return [string isEqualToString:filter];

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

- (void)controlTextDidBeginEditing:(NSNotification *)obj
{
    NSInteger row =self.dataTableView.selectedRow;
    editLimitRow = row;
    NSLog(@"===edit==> row: %zd",row);
//    NSTextField *textF =obj.object;
//    NSInteger col = [self.dataTableView columnForView:textF];
//    if (col == 5 || col == 6 || col == 8)
//    {
//        _data[editLimitRow][tb_apply] = [NSNumber numberWithInt:0];
//        [self.dataTableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:row] columnIndexes:[NSIndexSet indexSetWithIndex:7]];
//    }
    
    
}

-(void)controlTextDidChange:(NSNotification *)obj
{
    NSTextField *textF =obj.object;
    NSInteger row =self.dataTableView.selectedRow;
    NSInteger col = [self.dataTableView columnForView:textF];
    n_reviewer_col = col;
    //NSString *identifier = self.dataTableView.tableColumns[col].identifier;
    //NSLog(@"===edit==>identifier: %@   row:%zd  col:%zd  %@",identifier,row,col,textF.stringValue);
    NSString *col_identifier = [[[self.dataTableView tableColumns] objectAtIndex:col] identifier];
    //NSString *key = [NSString stringWithFormat:@"%zd-%zd",row,col];
    //[_textEditLimitDic setValue:textF.stringValue forKey:key];
    if ([col_identifier isEqualToString:identifier_lsl] || [col_identifier isEqualToString:identifier_usl])  //if (col == col edit_new_lsl || col == col edit_new_usl)
    {
        if ([textF.stringValue isEqualToString:@"N"] || [textF.stringValue isEqualToString:@"NA"])
        {
            if ([col_identifier isEqualToString:identifier_lsl]) //(col == col edit_new_lsl)
            {
                if ([textF.stringValue isEqualToString:@"NA"])
                {
                     _data[editLimitRow][tb_lsl] = [NSString stringWithFormat:@"%@",[textF stringValue]];
                    filterSourceData[[_data[editLimitRow][tb_index] intValue]  - 1][tb_lsl] =[NSString stringWithFormat:@"%@",[textF stringValue]];
                }
            }
            if ([col_identifier isEqualToString:identifier_usl]) //(col == col edit_new_usl)
            {
                if ([textF.stringValue isEqualToString:@"NA"])
                {
                     _data[editLimitRow][tb_usl] = [NSString stringWithFormat:@"%@",[textF stringValue]];
                    filterSourceData[[_data[editLimitRow][tb_index] intValue]  - 1][tb_usl] =[NSString stringWithFormat:@"%@",[textF stringValue]];
                }
            }
                
            
            _data[editLimitRow][tb_reviewer] = @"";
            _data[editLimitRow][tb_date] = @"";
            return;
        }
        if(![self isOnlyhasNumberAndpointWithString:textF.stringValue])
        {
            [self AlertBox:@"Error:014" withInfo:@"Please input number type or NA!"];
            _data[editLimitRow][col+2] = @"";
            [self.dataTableView reloadData];
            return;
        }

        if (row ==-1)
        {
        }
        else
        {
            editLimitRow = row;
        }
        if (row>=0 && row<[_data count])
        {
            //NSLog(@"===edit==>identifier  : %@   row:%zd  col:%zd  %@",identifier,editLimitRow,col+3,textF.stringValue);
          
            if([col_identifier isEqualToString:identifier_lsl])//(col == col edit_new_lsl)
            {
                 _data[editLimitRow][tb_lsl] = [NSString stringWithFormat:@"%@",[textF stringValue]];
                filterSourceData[[_data[editLimitRow][tb_index] intValue]  - 1][tb_lsl] =[NSString stringWithFormat:@"%@",[textF stringValue]];
            }
            if([col_identifier isEqualToString:identifier_usl]) //(col == col edit_new_usl)
            {
                 _data[editLimitRow][tb_usl] = [NSString stringWithFormat:@"%@",[textF stringValue]];
                filterSourceData[[_data[editLimitRow][tb_index] intValue]  - 1][tb_usl] =[NSString stringWithFormat:@"%@",[textF stringValue]];
            }
           
            _data[editLimitRow][tb_reviewer] = @"";
            _data[editLimitRow][tb_date] = @"";
            //_data[editLimitRow][tb_apply] = [NSNumber numberWithInt:0];
            //[self.dataTableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:row] columnIndexes:[NSIndexSet indexSetWithIndex:7]];
            
        }
        
        
    }
    
    if ([col_identifier isEqualToString:identifier_reviewer] || [col_identifier isEqualToString:identifier_date]) //(col == col edit_reviewer_name || col == col edit_review_date)
    {
        if (row ==-1)
        {
        }
        else
        {
            editLimitRow = row;
        }
        if (row>=0 && row<[_data count])
        {
           // NSLog(@"=====00>identifier  : %@   row:%zd  col:%zd  %@",identifier,editLimitRow,col+3,textF.stringValue);
            if ([[textF stringValue] isNotEqualTo:@""])
            {
                _data[editLimitRow][col+3] = [NSString stringWithFormat:@"%@",[textF stringValue]];
                   if([col_identifier isEqualToString:identifier_reviewer])//(col == col edit_reviewer_name)
                   {
                       NSDateFormatter* DateFomatter = [[NSDateFormatter alloc] init];
                       [DateFomatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                       NSTimeZone *timezone = [[NSTimeZone alloc] initWithName:@"PST"];
                       [DateFomatter setTimeZone:timezone];
                       NSString* systemTime = [DateFomatter stringFromDate:[NSDate date]];
                       _data[editLimitRow][tb_date] = systemTime;
                   }
            }

        }
        
    }
    
    if ([col_identifier isEqualToString:identifier_comment])//(col == col edit_comment)
    {
        if (row ==-1)
       {
       }
       else
       {
           editLimitRow = row;
       }
        if (row>=0 && row<[_data count])
        {
            if ([[textF stringValue] isNotEqualTo:@""])
            {
                _data[editLimitRow][tb_comment] = [NSString stringWithFormat:@"%@",[textF stringValue]];
                b_ClearComment = NO;
            }
            else
            {
                _data[editLimitRow][tb_comment] = [NSString stringWithFormat:@"%@",[textF stringValue]];
                b_ClearComment = YES;
            }
            //_data[editLimitRow][tb_apply] = [NSNumber numberWithInt:0];
            //[self.dataTableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:row] columnIndexes:[NSIndexSet indexSetWithIndex:7]];
            
        }
        
        
    }
    
    
     
    
}
-(void)mouseEntered:(NSEvent *)event
{
    //NSLog(@"====>>>>%@",event);
}
-(void)mouseMoved:(NSEvent *)event
{
    //NSLog(@"====>>>>%@",event);
}

- (void)keyDown:(NSEvent *)event
{
    [m_configDictionary setValue:[NSNumber numberWithBool:NO] forKey:kInputRangeFlag];
    if (![self.dataTableView isAccessibilityFocused])
    {
        unichar key = [[event charactersIgnoringModifiers] characterAtIndex:0];
        NSString *identifier = self.dataTableView.tableColumns[n_reviewer_col].identifier;
        NSLog(@">.>key :%hu   %@",key,identifier);

        return;
    }
    
    if(![self.dataTableView selectedCell])
    {
        
        if (event.isCommandDown)
        {
            if ([event.characters isEqual:@"c"])  //copy
            {
                if([self.dataTableView selectedRow] == -1 && [self.dataTableView selectedColumn] == -1)
                {
                    return;
                }
                NSLog(@">>copy ");
            }
            else if ([event.characters isEqual:@"v"])  //paste
            {
                if(!enableEditing)
                {
                    return;
                }
                NSLog(@">>paste ");
                [self.dataTableView reloadData];
                //[self paste:nil];
            }
            else if ([event.characters isEqual:@"x"])  //cut
            {
                if(([self.dataTableView selectedRow] == -1 && [self.dataTableView selectedColumn] == -1) || !enableEditing)
                {
                    return;
                }
                NSLog(@">>cut ");
                [self.dataTableView reloadData];
               // [self cut:nil];
            }
            else if ([event.characters isEqual:@"z"])  // undo
            {
                [self.undoManager undo];
                NSLog(@">>undo ");
            }
            else if (event.isShiftDown && [event.characters isEqual:@"z"])  // redo
            {
                [self.undoManager redo];
                NSLog(@">>redo ");
            }
            else
            {
                return;
            }
        }
        else if (event.isShiftDown)
        {
            NSLog(@"isShiftDown");
        }
        else if (event.isOptionDown)
        {
            NSLog(@"isOptionDown");
        }
        else if (event.isControlDown)
        {
            NSLog(@"isControlDown");
        }
        else
        {
            unichar key = [[event charactersIgnoringModifiers] characterAtIndex:0];
            if(key == NSDeleteCharacter)
            {
                if(([self.dataTableView selectedRow] == -1 && [self.dataTableView selectedColumn] == -1)|| !enableEditing)
                {
                    return;
                }
                //[self delete:nil];
                NSLog(@">>delete :%x",key);
                [self.dataTableView reloadData];
                return;
            }
            if(key == 0xf700)
            {
                NSLog(@"=>>%@  %@",[m_configDictionary valueForKey:kRetestSeg],[m_configDictionary valueForKey:kRemoveFailSeg]);
                if(([self.dataTableView selectedRow] == -1 && [self.dataTableView selectedColumn] == -1)|| !enableEditing)
                {
                    return;
                }
                NSInteger selectRow = [self.dataTableView selectedRow]-1;
                if (selectRow < 0)
                {
                    selectRow = [self.dataTableView selectedRow];
                }
                
                _data[selectRow][tb_color_by_left]= [NSNumber numberWithInteger:selectColorBoxIndex];  //设置color By左边那个,给python生成图表用
                 _data[selectRow][tb_color_by_right]= [NSNumber numberWithInteger:selectColorBoxIndex2];  //设置color By左边那个,给python生成图表用
                 NSString *typeZoom = [m_configDictionary valueForKey:kzoom_type];
                 _data[selectRow][tb_zoom_type] = typeZoom;
                 NSString *bins = [m_configDictionary valueForKey:kBins];
                 _data[selectRow][tb_bins] = bins;
                
                NSInteger rowActual = 0;
                for (NSInteger i= 0; i<[_ListAllItemNameArr count]; i++)  //当UI 选择search 的时候，数据变了，row 也变了，要找到对应值
                {
                    if ([_ListAllItemNameArr[i] isEqualToString:_data[selectRow][1]])
                    {
                        rowActual = i;
                        break;
                    }
                }
                
                
                tbDataTableSelectItemRow = rowActual;
                click_tb_row = selectRow;
                //click_tb_row = rowActual;
                if (selectColorBoxIndex > 0 ) //color by 打开，用color by 那边发指令给python
                {
                    if (n_firstItemClick ==0|| n_firstItemClick ==1)
                    {
                        NSString *choose_item_name = [_indexItemNameDic valueForKey:[NSString stringWithFormat:@"%zd",rowActual]];
                        [m_configDictionary setValue:[NSNumber numberWithInteger:rowActual] forKey:kChooseItemIndex];
                        [m_configDictionary setValue:choose_item_name forKey:kChooseItemName];
                        n_firstItemClick =10;
                    }
                    //NSDictionary *dic = [NSDictionary dictionaryWithObject:[m_configDictionary valueForKey:K_dic_ApplyBoxCheck] forKey:applyBoxCheck];
                    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationClickPlotTable object:nil userInfo:nil];
                }
                else if(selectColorBoxIndex2>0 )
                {
                    if (n_firstItemClick ==0|| n_firstItemClick ==1)
                    {
                        NSString *choose_item_name = [_indexItemNameDic valueForKey:[NSString stringWithFormat:@"%zd",rowActual]];
                        [m_configDictionary setValue:[NSNumber numberWithInteger:rowActual] forKey:kChooseItemIndex];
                        [m_configDictionary setValue:choose_item_name forKey:kChooseItemName];
                        n_firstItemClick =10;
                    }
                    
                     [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationClickPlotTable2 object:nil userInfo:nil];
                }
                else  // color by 关闭。直接发指令给python
                {
                    NSString * itemName = [self combineItemName:[_indexItemNameDic valueForKey:[NSString stringWithFormat:@"%zd",rowActual]]];
                    NSLog(@"=>down key :%x row: %ld   item name: %@",key,rowActual,itemName);
                    
                    // 写发送代码
                    // NSMutableArray *itemArray = _dataReverse[selectRow+n_Start_Data_Col];
                    NSString *itemName_0 = [NSString stringWithFormat:@"%@_XY",[m_configDictionary valueForKey:kChooseItemName]];
                    NSInteger row_0 =  [[m_configDictionary valueForKey:kChooseItemIndex] integerValue];
                    NSMutableArray * itemData_0 = [self calculateData:row_0];
                    NSMutableArray * itemData = [self calculateData:rowActual];
                    itemData_0[tb_correlation_xy] = itemName_0;
                    itemData[tb_correlation_xy] = itemName_0;
                    
                    if ([[m_configDictionary valueForKey:kInputRangeFlag] boolValue])
                    {
                        NSString *rangelsl = [m_configDictionary valueForKey:krangelsl];
                        NSString *rangeusl = [m_configDictionary valueForKey:krangeusl];
                        itemData_0[tb_range_lsl] = rangelsl;
                        itemData_0[tb_range_usl] = rangeusl;
                        itemData[tb_range_lsl] = rangelsl;
                        itemData[tb_range_usl] = rangeusl;
                        NSLog(@">>>range: %@,%@",rangelsl,rangeusl);
                    }
                    else
                    {
                        NSString *rangelsl = itemData[tb_lower];
                        NSString *rangeusl = itemData[tb_upper];
                        itemData_0[tb_range_lsl] = rangelsl;
                        itemData_0[tb_range_usl] = rangeusl;
                        itemData[tb_range_lsl] = rangelsl;
                        itemData[tb_range_usl] = rangeusl;
                        NSLog(@".>>>range: %@,%@",rangelsl,rangeusl);

                    }
                    
                    [self sendDataToRedis:itemName_0 withData:itemData_0];
                    [self sendDataToRedis:itemName withData:itemData];
                    [self sendCpkZmqMsg:itemName];
                    [self sendBoxZmqMsg:itemName];
                    [self sendCorrelationZmqMsg:itemName];
                    [self sendScatterZmqMsg:itemName];
                }
                return;
            }
            if(key == 0xf701)
            {
                NSLog(@"==>%@  %@",[m_configDictionary valueForKey:kRetestSeg],[m_configDictionary valueForKey:kRemoveFailSeg]);
                if(([self.dataTableView selectedRow] == -1 && [self.dataTableView selectedColumn] == -1)|| !enableEditing)
                {
                    return;
                }
                NSInteger selectRow = [self.dataTableView selectedRow]+1;
                if (selectRow >= [_data count])
                {
                    selectRow = [self.dataTableView selectedRow];
                }
                
                _data[selectRow][tb_color_by_left]= [NSNumber numberWithInteger:selectColorBoxIndex];  //设置color By左边那个,给python生成图表用
                _data[selectRow][tb_color_by_right]= [NSNumber numberWithInteger:selectColorBoxIndex2];  //设置color By right那个,给python生成图表用
                NSString *typeZoom = [m_configDictionary valueForKey:kzoom_type];
                _data[selectRow][tb_zoom_type] = typeZoom;
                NSString *bins = [m_configDictionary valueForKey:kBins];
                _data[selectRow][tb_bins] = bins;
                
                
                NSInteger rowActual = 0;
                for (NSInteger i= 0; i<[_ListAllItemNameArr count]; i++)  //当UI 选择search 的时候，数据变了，row 也变了，要找到对应值
                {
                    if ([_ListAllItemNameArr[i] isEqualToString:_data[selectRow][1]])
                    {
                        rowActual = i;
                        break;
                    }
                }
                
                tbDataTableSelectItemRow = rowActual;
                //click_tb_row = rowActual;
                click_tb_row = selectRow;
                if (selectColorBoxIndex > 0) //color by 打开，用color by 那边发指令给python
                {
                    if (n_firstItemClick ==0|| n_firstItemClick ==1)
                    {
                        NSString *choose_item_name = [_indexItemNameDic valueForKey:[NSString stringWithFormat:@"%zd",rowActual]];
                        [m_configDictionary setValue:[NSNumber numberWithInteger:rowActual] forKey:kChooseItemIndex];
                        [m_configDictionary setValue:choose_item_name forKey:kChooseItemName];
                        n_firstItemClick =10;
                    }
                    
                   // NSDictionary *dic = [NSDictionary dictionaryWithObject:[m_configDictionary valueForKey:K_dic_ApplyBoxCheck] forKey:applyBoxCheck];
                    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationClickPlotTable object:nil userInfo:nil];
                }
                else if(selectColorBoxIndex2>0)
                {
                    if (n_firstItemClick ==0|| n_firstItemClick ==1)
                    {
                        NSString *choose_item_name = [_indexItemNameDic valueForKey:[NSString stringWithFormat:@"%zd",rowActual]];
                        [m_configDictionary setValue:[NSNumber numberWithInteger:rowActual] forKey:kChooseItemIndex];
                        [m_configDictionary setValue:choose_item_name forKey:kChooseItemName];
                        n_firstItemClick =10;
                    }
                    
                     [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationClickPlotTable2 object:nil userInfo:nil];
                }
                else  // color by 关闭。直接发指令给python
                {
                    NSString * itemName = [self combineItemName:[_indexItemNameDic valueForKey:[NSString stringWithFormat:@"%zd",rowActual]]];
                    NSLog(@"====>down key :%x row: %ld   item name: %@",key,rowActual,itemName);
                     //写发送代码
                    // NSMutableArray *itemArray = _dataReverse[selectRow+n_Start_Data_Col];
                    //NSLog(@"--ClickOnTableView--:%zd  selectColorBoxIndex:%d, item name : %@",selectRow,selectColorBoxIndex,itemName);
                    NSString *itemName_0 = [NSString stringWithFormat:@"%@_XY",[m_configDictionary valueForKey:kChooseItemName]];
                    NSInteger row_0 =  [[m_configDictionary valueForKey:kChooseItemIndex] integerValue];
                    NSMutableArray * itemData_0 = [self calculateData:row_0];
                    NSMutableArray * itemData = [self calculateData:rowActual];
                    itemData_0[tb_correlation_xy] = itemName_0;
                    itemData[tb_correlation_xy] = itemName_0;
                    
                    
                    if ([[m_configDictionary valueForKey:kInputRangeFlag] boolValue])
                    {
                        NSString *rangelsl = [m_configDictionary valueForKey:krangelsl];
                        NSString *rangeusl = [m_configDictionary valueForKey:krangeusl];
                        itemData_0[tb_range_lsl] = rangelsl;
                        itemData_0[tb_range_usl] = rangeusl;
                        itemData[tb_range_lsl] = rangelsl;
                        itemData[tb_range_usl] = rangeusl;
                        NSLog(@">>range: %@,%@",rangelsl,rangeusl);
                    }
                    else
                    {
                        NSString *rangelsl = itemData[tb_lower];
                        NSString *rangeusl = itemData[tb_upper];
                        itemData_0[tb_range_lsl] = rangelsl;
                        itemData_0[tb_range_usl] = rangeusl;
                        itemData[tb_range_lsl] = rangelsl;
                        itemData[tb_range_usl] = rangeusl;
                        NSLog(@".>>range: %@,%@",rangelsl,rangeusl);

                    }

                    [self sendDataToRedis:itemName_0 withData:itemData_0];
                    [self sendDataToRedis:itemName withData:itemData];
                    [self sendCpkZmqMsg:itemName];
                    [self sendBoxZmqMsg:itemName];
                    [self sendCorrelationZmqMsg:itemName];
                    [self sendScatterZmqMsg:itemName];
                   
                }

                return;
            }
            NSLog(@"no shorcut: %x",key);
        }
    }
    else
    {
        NSLog(@"nothing");
    }
}

#pragma mark luanch function methods
-(void)launch_calculate_test
{
    [startPython Lanuch_calculate];
    calculateClient = [[Client alloc] init];   // connect calculate zmq for calculate.py
    [calculateClient CreateRPC:calculate_zmq_addr withSubscriber:nil];
    [calculateClient setTimeout:20*1000];
}

-(void)launch_retest_plot
{
    [startPython Lanuch_retest_plot];
    retestPlotClient = [[Client alloc] init];   //
    [retestPlotClient CreateRPC:retest_plot_zmq_addr withSubscriber:nil];
    [retestPlotClient setTimeout:20*1000];
}
-(void)launch_yield_rate
{
    [startPython Lanuch_yield_rate];
    retestRateClient = [[Client alloc] init];   // connect calculate zmq for calculate.py
    [retestRateClient CreateRPC:retest_rate_zmq_addr withSubscriber:nil];
    [retestRateClient setTimeout:20*1000];
}



-(void)notifySetImage:(NSString *)path
{
    //NSDictionary *dic = [NSDictionary dictionaryWithObject:path forKey:imagePath];
    //[[NSNotificationCenter defaultCenter]postNotificationName:kNotificationSetCpkImage object:nil userInfo:dic];
}


#pragma mark NSSplitViewDelegate methods

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview
{
    if (subview == self.leftPane)
    {
        return YES;
    }
    else if (subview == self.rightPanel)
    {
        return YES;
    }
    
    return NO;
}


-(void)LoadSubView:(NSView *)view
{
    [[leftViewMain superview] replaceSubview:leftViewMain with:view];
    [view setFrame:[leftViewMain frame]];
    leftViewMain = view;
    //[self loadView];
}
//
-(void)setLoadCsvView:(NSView *)view
{
    [self replaceView:csvViewMain with:view];
    csvViewMain =view;
}
-(void)replaceView:(NSView *)oldView with:(NSView *)newView
{
    [newView setFrame:[oldView frame]];
    [[oldView superview] addSubview:newView];
    [[oldView superview] replaceSubview:oldView with:newView];
    [oldView setHidden:YES];
}

@end
