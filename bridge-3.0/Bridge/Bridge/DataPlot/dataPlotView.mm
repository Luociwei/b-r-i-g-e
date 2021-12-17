//
//  dataPlotView.m
//  CPK_Test
//
//  Created by RyanGao on 2020/6/25.
//  Copyright © 2020 RyanGao. All rights reserved.
//


#import "dataPlotView.h"
#import "defineHeader.h"
#import "SCRedis.framework/Headers/RedisInterface.hpp"
#import "SCZmq.framework/Headers/Client.h"
#import "SCNSEventEx.framework/Headers/NSEventEx.h"
#import "reportSettingCfg.h"
#import "keynoteSetting.h"
#import "keynote_skip_setting.h"
#import "reportTags.h"
#import "SCopensslSha1.framework/Headers/sha.h"
#import "yieldRetestRate.h"
#import "showDataControl.h"
#import "SCMouseFunction.h"
#import "NSPopover+Message.h"
#import <CoreGraphics/CGImage.h>
#import <Quartz/Quartz.h>

NSMutableDictionary *m_configDictionary;
NSInteger tbDataTableSelectItemRow;

NSMutableArray *_dataReverse;
NSMutableArray *_rawData;
int selectColorBoxIndex;   //left color by
int selectColorBoxIndex2;  //right color by


extern RedisInterface *myRedis;

extern Client *boxClient;
extern Client *cpkClient;
extern Client *correlationClient;
extern Client *calculateClient;
Client *reportExcelClient;  //excel
Client *reportKeynoteClient;
Client *reportTagsClient;

extern Client *copyImageClient;  //
extern Client *scatterClient;


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
extern int n_passdata;



@interface dataPlotView ()
{
    NSMutableArray * lastItemSelectColorTbLeft;   //记录上次结果
    NSMutableArray * lastItemSelectColorTbRight;   //记录上次结果
    
    NSInteger lastTbDataTableSelectItemRow;//记录上次结果
    NSString *desktopPath;
    NSString *userDocuments;
    
    int n_select_x;
    int n_select_y;
    NSArray *colorByName;
    NSArray *filterItemNames;
    NSString *inputLSL;
    NSString *inputUSL;
    int last_SilderL;
    int last_SilderR;
    int last_SilderScatter;
    
    CGFloat _lastCpkPaneWidth;
    CGFloat _lastCorrelationPaneWidth;
    CGFloat _lastScatterPaneWidth;
    CGFloat _lastSettingPaneWidth;
    CGFloat _lastFilter1PaneWidth;
    CGFloat _lastFilter2PaneWidth;
    CGFloat _lastPaneWidth;
    
    CGFloat _cpkPercentage;
    CGFloat _correlationPercentage;
    CGFloat _scatterPercentage;
    CGFloat _settingPanelPercentage;
    CGFloat _filter1lPercentage;
    CGFloat _filter2lPercentage;
    BOOL b_setRangeTxt;
    int n_flag_scatterBtn;
    int n_flag_cpkBtn;
    
    BOOL is_BoxPlot;
    
    BOOL b_loadCustomCsv;
    
}
@property (nonatomic,strong)NSMutableArray *data;  //left color by data
@property (nonatomic,strong)NSMutableArray *data2;  //right color by data

@property(strong) reportSettingCfg *reportSetWin;
@property(strong) keynoteSetting  *keynoteSetWin;
//@property(strong) keynoteItemSkipSetting  *keynoteItemSkipWin;
@property(strong) keynote_skip_setting  *keynoteskipSettingWin;
@property(strong) reportTags  *reportTagsWin;
@property(strong)yieldRetestRate *yieldRetestWin;
@property(strong)showDataControl *showDatatWin;

@end

@implementation dataPlotView

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        
        
        _data = [[NSMutableArray alloc]init];
        _data2 = [[NSMutableArray alloc]init];
        m_configDictionary = [[NSMutableDictionary alloc]init];
        _rawData = [[NSMutableArray alloc]init];
        _dataReverse = [[NSMutableArray alloc]init];
        tbDataTableSelectItemRow = -1;
        lastTbDataTableSelectItemRow = -1;
        selectColorBoxIndex = 0;  //left
        selectColorBoxIndex2 = 0;  //right
        lastItemSelectColorTbLeft = [NSMutableArray array];
        lastItemSelectColorTbRight = [NSMutableArray array];
        
        n_select_x=0;
        n_select_y=0;
        
        
        colorByName = @[Off,Version,Station_ID,Special_Build_Name,Special_Build_Descrip,Product,Channel_ID,Diags_Version,OS_VERSION];
        
        filterItemNames=@[Version,Station_ID,Special_Build_Name,Special_Build_Descrip,Product,Channel_ID,Diags_Version,OS_VERSION];
        
        
        is_BoxPlot = NO;
        b_setRangeTxt = NO;
        n_flag_scatterBtn = 0;
        n_flag_cpkBtn = 0;
        b_loadCustomCsv = NO;
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnNotification:) name:kNotificationHidenAllWindows object:nil];
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_colorByTableView setDelegate:self];
    
    [_colorByTableView setAllowsMultipleSelection:YES];
    
    [_colorByTableView setDataSource:self];
    [_colorByTableView2 setDelegate:self];
    
    [_colorByTableView2 setAllowsMultipleSelection:YES];
    [_colorByTableView2 setDataSource:self];
    [self initColorTabView:nil];
    [_progressExcel setHidden:YES];
    //[_progressBarExcel setHidden:YES];
    [_progressKeynote setHidden:YES];
    //[_progressBarKeynote setHidden:YES];
    [_cpkSaveButton setHidden:NO];
    [_correlationSaveButton setHidden:NO];
    NSString *savepath =[[NSBundle mainBundle]pathForResource:@"for_filesave.png" ofType:nil];
    NSImage *saveIcon = [[NSImage alloc]initWithContentsOfFile:savepath];
        dispatch_async(dispatch_get_main_queue(), ^{
           [self.cpkSaveButton setImage:saveIcon];
           [self.correlationSaveButton setImage:saveIcon];
            [self.scatterSaveButton setImage:saveIcon];
       });
    
    
    desktopPath = [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    userDocuments = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];

    [m_configDictionary setValue:[NSNumber numberWithBool:NO] forKey:K_dic_ApplyBoxCheck];
    [m_configDictionary setValue:[NSNumber numberWithBool:NO] forKey:K_dic_Load_Csv_Finished];
    
    [m_configDictionary setValue:@"" forKey:krangelsl];
    [m_configDictionary setValue:@"" forKey:krangeusl];
    [m_configDictionary setValue:[NSNumber numberWithBool:NO] forKey:kInputRangeFlag];
    
    //left color by
    [self.colorByTableView setTarget:self];
    [self.colorByTableView setDoubleAction:@selector(DblClickOnTableView:)];
    [self.colorByTableView setAction:@selector(DblClickOnTableView:)];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DblClickOnTableView:) name:kNotificationClickPlotTable object:nil];
    //right color by
    [self.colorByTableView2 setTarget:self];
    [self.colorByTableView2 setDoubleAction:@selector(DblClickOnTableView2:)];
    [self.colorByTableView2 setAction:@selector(DblClickOnTableView2:)];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DblClickOnTableView2:) name:kNotificationClickPlotTable2 object:nil];
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(ClickOnSelectXY:) name:kNotificationClickPlotTable_selectXY object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(initColorTabView:) name:kNotificationInitColorTable object:nil];
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setUiImage:) name:kNotificationSetCpkImage object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setUiImage:) name:kNotificationSetCorrelationImage object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setUiImage:) name:kNotificationSetScatterImage object:nil];
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setReportButton:) name:kNotificationGenerateExcel object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(addExcelHash:) name:kNotificationAddExcelHash object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setReportButton:) name:kNotificationGenerateKeynote object:nil];
    //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(settingTableViewData:) name:kNotificationRetestRate object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setReportButton:) name:kNotificationToLoadCsv object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setReportButton:) name:kNotificationToLocalLoadCsv object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setRangeLSLandUSL:) name:kNotificationSetRangeLslUsl object:nil];
    
    [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(OnTimer:) userInfo:nil repeats:YES];
    [self.sliderL setHidden:YES];
    self.sliderL.floatValue = 50;
    last_SilderL = 50;
    [self.sliderR setHidden:YES];
    self.sliderR.floatValue = 50;
    last_SilderR = 50;
    
    self.sliderScatter.floatValue = 50;
    last_SilderScatter = 50;
    
    [self.rangeLsl setHidden:YES];
    [self.rangeUsl setHidden:YES];
    [self.rangeTxtLsl setHidden:YES];
    [self.rangeTxtUsl setHidden:YES];
    
    [self.cpkViewWin setHidden:NO];
    [self.correlationViewWin setHidden:NO];
    [self.scatterViewWin setHidden:NO];
    
    
    [m_configDictionary setValue:[NSString stringWithFormat:@"%@",@"limit"] forKey:kzoom_type];
    
     _showDatatWin=[[showDataControl alloc]initWithWindowNibName:@"showDataControl"];
    [_showDatatWin.window orderFront:nil];
    [_showDatatWin.window close];
    
    
    [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskKeyDown handler:^NSEvent * _Nullable(NSEvent * _Nonnull aEvent) {
    [self keyDown:aEvent];
    return aEvent;
    }];
    
    [self.checkPDF setAlphaValue:0.9];
    [self.checkCDF setAlphaValue:0.9];
    [self.checkPDF setState:0];
    [self.checkCDF setState:0];
    [self sendStringToRedis:KSetPDF withData:@"0"];
    [self sendStringToRedis:KSetCDF withData:@"0"];
    
    
    self.cpkBoxView.imageScaling = NSImageScaleProportionallyUpOrDown;
    self.cpkImageView.imageScaling = NSImageScaleProportionallyUpOrDown;
    self.correlationImageView.imageScaling = NSImageScaleProportionallyUpOrDown;
    self.scatterImageMapView.imageScaling = NSImageScaleProportionallyUpOrDown;
    [self.sliderL setAlphaValue:0.9];
    [self.sliderR setAlphaValue:0.9];
    [self.sliderScatter setAlphaValue:0.9];
    
    [self.cpkSaveButton setAlphaValue:1];
    [self.correlationSaveButton setAlphaValue:1];
    [self.scatterSaveButton setAlphaValue:1];
    
    [self.cpkFitScreen setAlphaValue:1];
    [self.correlationFitScreen setAlphaValue:1];
    [self.scatterFitScreen setAlphaValue:1];
    
    self.scrollViewLeft.backgroundColor = [NSColor colorWithWhite:0.5 alpha:0.8];
    self.scrollViewRight.backgroundColor = [NSColor colorWithWhite:0.5 alpha:0.8];
    self.scatterScrollView.backgroundColor = [NSColor colorWithWhite:0.5 alpha:0.8];
    self.clipViewLeft.backgroundColor = [NSColor colorWithWhite:0.5 alpha:1];
    self.clipViewRight.backgroundColor = [NSColor colorWithWhite:0.5 alpha:1];
    self.clipViewScatter.backgroundColor = [NSColor colorWithWhite:0.5 alpha:1];
    
    [self defineSplitSize];
    startPython = [[StartUp alloc] init];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(forMouseEnter:) name:kNotificationMouseEnter object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(forMouseEnter:) name:kNotificationMouseExit object:nil];
    
    SCMouseFunction *viewBtn = [[SCMouseFunction alloc] initWithID:kReport_tags];
    [viewBtn setFrame:[self.btnReportTags frame]];
    [self.btnSettingView addSubview:viewBtn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResize:) name:NSWindowDidResizeNotification object:nil];
    
    
    
    NSDistributedNotificationCenter *center =
        [NSDistributedNotificationCenter defaultCenter];
        NSString *observedObject = @"com.vito.notification";
        [center addObserver: self
                   selector: @selector(callbackWithNotification:)
                       name: nil/*@"PiaoYun Notification"*/
                     object: observedObject];
}


- (void)callbackWithNotification:(NSNotification *)nf;
{
    if([nf.name isEqualToString:@"post-json"]){
    
        NSLog(@"Notification Received2 %@",[nf userInfo][@"info"]);
        
        NSString * limitfile =[NSString stringWithFormat:@"%@",[nf userInfo][@"info"]];
        
        NSArray* datas =  [limitfile componentsSeparatedByString:NSLocalizedString(@"^&^", nil)];
        
        if([datas count] >=2){
            
            if ([datas[0] isEqualToString:@"box_finish"]) {
                
                [self setCpkBoxImage:@"/tmp/CPK_Log/temp/cpkbox.png"];
            }
        }
    }
}

-(void)forMouseEnter:(NSNotification *)nf
{
    NSString * name = [nf name];
    if ([ name isEqualToString:kNotificationMouseEnter])
    {
        NSDictionary* info = [nf userInfo];
        NSString * myId = [info valueForKey:ktbHeaderID];
        if ([myId isEqualToString:kReport_tags])
        {
            [NSPopover showRelativeToRect:[self.btnReportTags frame]
                                   ofView:[self.btnSettingView superview]
                            preferredEdge:NSMaxXEdge
                                   string:helpInfo_Report_tags
                                 maxWidth:300.0];
        }
        
    }
    if ([ name isEqualToString:kNotificationMouseExit])
    {
        NSDictionary* info = [nf userInfo];
        NSString * myId = [info valueForKey:ktbHeaderID];
        if ([myId isEqualToString:kReport_tags])
        {
            [self closePopoverMsg];
        }
        
    }
}

- (void)closePopoverMsg
{
    [NSPopover closeRelativeToRect:[self.btnReportTags frame]
                           ofView:[self.btnSettingView superview]
                    preferredEdge:NSMaxXEdge
                           string:@""
                         maxWidth:0.0];;
}

- (void)keyDown:(NSEvent *)event
{
    
    if ([self.colorByTableView isAccessibilityFocused])
    {
        unichar key = [[event charactersIgnoringModifiers] characterAtIndex:0];
        NSLog(@">key down color by: %hu",key);
        BOOL b_commandDown = NO;
        if (event.isCommandDown)
        {
            b_commandDown = YES;
        }
        
        BOOL b_shiftDown = NO;
        if (event.isShiftDown)
        {
            b_shiftDown = YES;
        }
        if(key == 0xf700)
        {
            NSInteger selectRow = [self.colorByTableView selectedRow]-1;
            if (selectRow < 0)
            {
                selectRow = [self.colorByTableView selectedRow];
            }
            [self keyMoveFilter1:selectRow withShiftDown:b_shiftDown];
        }
        else if (key == 0xf701)
        {
            NSInteger selectRow = [self.colorByTableView selectedRow]+1;
            if (selectRow >= [_data count])
            {
                selectRow = [self.colorByTableView selectedRow];
            }
            [self keyMoveFilter1:selectRow withShiftDown:b_shiftDown];
        }
        else if(key == 0x0061 && b_commandDown)
        {
            NSInteger selectRow = [self.colorByTableView selectedRow];
            [self FilterBy1_commandA:selectRow];
        }
      
    }
    else if ([self.colorByTableView2 isAccessibilityFocused])
    {
        unichar key = [[event charactersIgnoringModifiers] characterAtIndex:0];
        
        BOOL b_commandDown = NO;
        if (event.isCommandDown)
        {
            b_commandDown = YES;
        }
        
        BOOL b_shiftDown = NO;
        if (event.isShiftDown)
        {
            b_shiftDown = YES;
        }
        if(key == 0xf700)
        {
            NSInteger selectRow = [self.colorByTableView2 selectedRow]-1;
            if (selectRow < 0)
            {
                selectRow = [self.colorByTableView2 selectedRow];
            }
            [self keyMoveFilter2:selectRow withShiftDown:b_shiftDown];
        }
        else if (key == 0xf701)
        {
            NSInteger selectRow = [self.colorByTableView2 selectedRow]+1;
            if (selectRow >= [_data2 count])
            {
                selectRow = [self.colorByTableView2 selectedRow];
            }
            [self keyMoveFilter2:selectRow withShiftDown:b_shiftDown];
        }
        else if(key == 0x0061 && b_commandDown)
        {
            NSInteger selectRow = [self.colorByTableView selectedRow];
            [self FilterBy2_commandA:selectRow];
        }
       
    }
}
-(NSMutableArray *)getNeedDeletDataIndex  //更具UI retest 和remove fail 按钮，移除相关index 数据
{
    NSString *opt1 = [m_configDictionary valueForKey:kRetestSeg];
    NSString *opt2 = [m_configDictionary valueForKey:kRemoveFailSeg];
    NSString *dic_key = [NSString stringWithFormat:@"%@&%@",opt1,opt2];
    NSMutableArray *indexArr = [m_configDictionary valueForKey:dic_key];
    //NSLog(@"====>>>>>delet: %@",indexArr);
    return indexArr;
}
- (void)OnNotification:(NSNotification *)nf
{
    NSString * name = [nf name];
    if([name isEqualToString:kNotificationHidenAllWindows])
    {
        [_yieldRetestWin.window orderOut:nil];
        [_showDatatWin.window orderOut:nil];
        [_reportTagsWin.window orderOut:nil];
        
    }
    
}
-(void)OnTimer:(NSTimer *)timer
{
    NSString *pathcpk =@"/tmp/CPK_Log/temp/.logcpk.txt";// [NSString stringWithFormat:@"%@/CPK_Log/temp/.logcpk.txt",desktopPath];
    NSString *logcpk = [NSString stringWithContentsOfFile:pathcpk encoding:NSUTF8StringEncoding error:nil];
    if ([logcpk containsString:@"PASS"]|| [logcpk containsString:@"FAIL"])
    {
        [@"none" writeToFile:pathcpk atomically:YES encoding:NSUTF8StringEncoding error:nil];
        NSString *path = @"/tmp/CPK_Log/temp/cpk.png";//[NSString stringWithFormat:@"%@/CPK_Log/temp/cpk.png",desktopPath];
        NSDictionary *dic = [NSDictionary dictionaryWithObject:path forKey:imagePath];
        [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationSetCpkImage object:nil userInfo:dic];
        NSLog(@">set cpk pic.");
    }
    
    NSString *pathcpknew = @"/tmp/CPK_Log/temp/.cpknew.txt";
    NSString *logcpknew = [NSString stringWithContentsOfFile:pathcpknew encoding:NSUTF8StringEncoding error:nil];
    if ([logcpknew containsString:@"DONE,"])
    {
        [@"" writeToFile:pathcpknew atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        NSString *logcpknewwhat = [NSString stringWithContentsOfFile:pathcpknew encoding:NSUTF8StringEncoding error:nil];
        NSArray *subArr = [logcpknew componentsSeparatedByString:@","];
        NSDictionary *dic = [NSDictionary dictionaryWithObject:subArr[1] forKey:cpkNewNumber];
        [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationSetCpkNew object:nil userInfo:dic];

    }
    
    NSString *pathcor = @"/tmp/CPK_Log/temp/.logcor.txt";//[NSString stringWithFormat:@"%@/CPK_Log/temp/.logcor.txt",desktopPath];
    NSString *logcor = [NSString stringWithContentsOfFile:pathcor encoding:NSUTF8StringEncoding error:nil];
    if ([logcor containsString:@"PASS"]||[logcor containsString:@"FAIL"])
    {
        [@"none" writeToFile:pathcor atomically:YES encoding:NSUTF8StringEncoding error:nil];
        NSString *path = @"/tmp/CPK_Log/temp/correlation.png";//[NSString stringWithFormat:@"%@/CPK_Log/temp/correlation.png",desktopPath];
        NSDictionary *dic = [NSDictionary dictionaryWithObject:path forKey:imagePath];
        [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationSetCorrelationImage object:nil userInfo:dic];
        NSLog(@">set correlation pic.");
    }
    NSString *pathscatter = @"/tmp/CPK_Log/temp/.logscatter.txt";//[NSString stringWithFormat:@"%@/CPK_Log/temp/.logscatter.txt",desktopPath];
    NSString *logscatter = [NSString stringWithContentsOfFile:pathscatter encoding:NSUTF8StringEncoding error:nil];
    if ([logscatter containsString:@"PASS"]||[logscatter containsString:@"FAIL"])
    {
        [@"none" writeToFile:pathscatter atomically:YES encoding:NSUTF8StringEncoding error:nil];
        NSString *path = @"/tmp/CPK_Log/temp/scatter.png";//[NSString stringWithFormat:@"%@/CPK_Log/temp/scatter.png",desktopPath];
        NSDictionary *dic = [NSDictionary dictionaryWithObject:path forKey:imagePath];
        [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationSetScatterImage object:nil userInfo:dic];
       // NSLog(@">set scatter pic.");
    }
    
    NSString *pathcalc = @"/tmp/CPK_Log/temp/.logcalc.txt";//[NSString stringWithFormat:@"%@/CPK_Log/temp/.logcalc.txt",desktopPath];
    NSString *logcalc = [NSString stringWithContentsOfFile:pathcalc encoding:NSUTF8StringEncoding error:nil];
    BOOL isFinished = [[m_configDictionary valueForKey:K_dic_Load_Csv_Finished] boolValue];
    if ([logcalc containsString:@"PASS"] && isFinished)
    {
        // update UI display
        NSLog(@"find PASS ????");
         [@"none" writeToFile:pathcalc atomically:YES encoding:NSUTF8StringEncoding error:nil];
        NSString *path = @"/tmp/CPK_Log/temp/calculate_param.csv";//[NSString stringWithFormat:@"%@/CPK_Log/temp/calculate_param.csv",desktopPath];
        NSDictionary *dic = [NSDictionary dictionaryWithObject:path forKey:paramPath];
        [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationSetParameters object:nil userInfo:dic];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationIndicatorMsg object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Cpk & Bimodality metrics & Build Summary reports done",kStartupMsg,[NSNumber numberWithInt:MSG_LEVEL_NORMAL],kStartupLevel, [NSNumber numberWithFloat:8/10], kStartupPercentage,nil]];
        [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationCloseStartUp object:nil userInfo:nil];
        
    }
    
    NSString *pathretest = @"/tmp/CPK_Log/temp/.logretest.txt";//[NSString stringWithFormat:@"%@/CPK_Log/temp/.logretest.txt",desktopPath];
    NSString *logretest = [NSString stringWithContentsOfFile:pathretest encoding:NSUTF8StringEncoding error:nil];
       if ([logretest containsString:@"Finished"])
       {
         [@"none" writeToFile:pathretest atomically:YES encoding:NSUTF8StringEncoding error:nil];
         [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationRetestRate object:nil userInfo:nil];
       }
       
    
    NSString *pathexcel = @"/tmp/CPK_Log/temp/.excel.txt";//
    NSString *logexcel = [NSString stringWithContentsOfFile:pathexcel encoding:NSUTF8StringEncoding error:nil];

    if ([logexcel containsString:@"Finished"])
    {
        //[[NSNotificationCenter defaultCenter]postNotificationName:kNotificationShowProgressUp object:nil userInfo:@{@"info":@"excel report generate finish",@"progress":@(100),@"title":@"excel report" }];
   
      [@"none" writeToFile:pathexcel atomically:YES encoding:NSUTF8StringEncoding error:nil];
      NSArray *limit_path = [logexcel componentsSeparatedByString:@","];
        NSString *path_limit_file = @"NULL";
        if ([limit_path count]>1)
        {
            path_limit_file = [limit_path[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        }
      NSDictionary *dic = [NSDictionary dictionaryWithObject:path_limit_file forKey:limit_update_path];
      [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationAddExcelHash object:nil userInfo:dic];
        
        //[NSThread sleepForTimeInterval:2];
        //[[NSNotificationCenter defaultCenter]postNotificationName:kNotificationCloseProgressUp object:nil userInfo:nil];
    }
    
    NSString *pathexcel_hash = @"/tmp/CPK_Log/temp/.excel_hash.txt";//[NSString stringWithFormat:@"%@/CPK_Log/temp/.excel_hash.txt",desktopPath];
    NSString *logexcel_hash = [NSString stringWithContentsOfFile:pathexcel_hash encoding:NSUTF8StringEncoding error:nil];
    if ([logexcel_hash containsString:@"Finished"])
    {
      [@"none" writeToFile:pathexcel_hash atomically:YES encoding:NSUTF8StringEncoding error:nil];
      [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationGenerateExcel object:nil userInfo:nil];
    }
    
    
    NSString *pathkeynote = @"/tmp/CPK_Log/temp/.keynote.txt";//[NSString stringWithFormat:@"%@/CPK_Log/temp/.keynote.txt",desktopPath];
    NSString *logkeynote = [NSString stringWithContentsOfFile:pathkeynote encoding:NSUTF8StringEncoding error:nil];

    if ([logkeynote containsString:@"Finished"])
    {
        
      [@"none" writeToFile:pathkeynote atomically:YES encoding:NSUTF8StringEncoding error:nil];
      [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationGenerateKeynote object:nil userInfo:nil];
    
       
    }
    
    
    NSString *modulePath = [NSString stringWithFormat:@"%@/.errormodule.txt",userDocuments];
    NSString *logmodule = [NSString stringWithContentsOfFile:modulePath encoding:NSUTF8StringEncoding error:nil];
    if ([logmodule length]>0)
    {
        [self AlertBox:@"Import Pyhton module Error!!!" withInfo:logmodule];
        [@"" writeToFile:modulePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    
    NSString *pathreporttags = @"/tmp/CPK_Log/temp/.reporttags.txt";
    NSString *logreporttags = [NSString stringWithContentsOfFile:pathreporttags encoding:NSUTF8StringEncoding error:nil];
    if ([logreporttags containsString:@"Finished"])
    {
        
        //[[NSNotificationCenter defaultCenter]postNotificationName:kNotificationShowProgressUp object:nil userInfo:@{@"info":@"tags report generate finish",@"progress":@(100),@"title":@"Tags report" }];
        [NSThread sleepForTimeInterval:1];
        [@"none" writeToFile:pathreporttags atomically:YES encoding:NSUTF8StringEncoding error:nil];
        NSString *cmdKillPythonLaunch = @"ps -ef |grep -i python |grep -i report_targs_test |grep -v grep|awk '{print $2}' |xargs kill -9";
        system([cmdKillPythonLaunch UTF8String]);
        
        NSString *tags_path = [m_configDictionary valueForKey: KreportTagsExcelPath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isExist = [fileManager fileExistsAtPath:tags_path];
        if (isExist)
        {
            [self AlertBox:@"Save Report Tags Excel successful." withInfo:tags_path];
        }
        else
        {
            [self AlertBox:@"Save Report Tags Excel Failed." withInfo:tags_path];
        }
        
        //[[NSNotificationCenter defaultCenter]postNotificationName:kNotificationCloseProgressUp object:nil userInfo:nil];
    }
    
//    NSString *pathretest_plot =@"/tmp/CPK_Log/retest/.retest_plot.txt";
//    NSString *logContext_plot = [NSString stringWithContentsOfFile:pathretest_plot encoding:NSUTF8StringEncoding error:nil];
//    if ([logContext_plot containsString:@"Finished"])
//    {
//        [@"none" writeToFile:pathretest_plot atomically:YES encoding:NSUTF8StringEncoding error:nil];
//        [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationSetRetestImage object:nil userInfo:nil];
//        [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationRetestRate object:nil userInfo:nil];
//    }
    
}

-(void)updateBuildSummaryWin:(int)x
{
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationSetRetestImage object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationRetestRate object:nil userInfo:nil];
}
-(void)initColorTabView:(NSNotification *)nf
{
    //NSDictionary* info = [nf userInfo];
    if ([[nf name] isEqualToString:kNotificationInitColorTable])
    {
        [self.retestSegment setSelectedSegment:1];
        [self.removeFailSegment setSelectedSegment:0];
        [self.zoomTypeSeg setSelectedSegment:0];
        [m_configDictionary setValue:[self switchZoomDataLimit:0] forKey:kzoom_type];
        [self.plotTypeSeg setSelectedSegment:0];
        [m_configDictionary setValue:[self switchRetest:1] forKey:kRetestSeg];
        [m_configDictionary setValue: [self switchRemoveFail:0] forKey:kRemoveFailSeg];
        NSLog(@"Init> %@ %@",[m_configDictionary valueForKey:kRetestSeg],[m_configDictionary valueForKey:kRemoveFailSeg]);
        [self.txtBins setIntValue:250];
        [m_configDictionary setValue:[NSString stringWithFormat:@"%@",@"250"] forKey:kBins];
        
        [self.colorByBox removeAllItems];
        [self.colorByBox addItemsWithObjectValues:colorByName];
        [self.colorByBox selectItemAtIndex:0];
        [_data removeAllObjects];
        
        
        
        [self.colorByBox2 removeAllItems];
        [self.colorByBox2 addItemsWithObjectValues:colorByName];
        [self.colorByBox2 selectItemAtIndex:0];
        [_data2 removeAllObjects];
        
        NSString *picPath =[[NSBundle mainBundle]pathForResource:@"none_pic.png" ofType:nil];
        
        [self setCpkBoxImage:picPath];
        [self setCpkImage:picPath];
        [self setCorrelationImage:picPath];
        [m_configDictionary setValue:@[Off] forKey:kSelectColorByTableRowsLeft];
        [m_configDictionary setValue:@[Off] forKey:kSelectColorByTableRowsRight];
        [_data removeAllObjects];
        [_data2 removeAllObjects];
        selectColorBoxIndex = 0;
        selectColorBoxIndex2 = 0;
        [self.colorByTableView reloadData];
        [self initSplitScatter];
        [self setRangeCtlHidden:YES];
        
        [self.colorByTableView reloadData];
        [self.colorByTableView2 reloadData];
        
        [self.checkPDF setState:0];
        [self.checkCDF setState:0];
        [self sendStringToRedis:KSetPDF withData:@"0"];
        [self sendStringToRedis:KSetCDF withData:@"0"];
    }
}




-(void)setUiImage:(NSNotification *)nf
{
    NSString * name = [nf name];
    if ([ name isEqualToString:kNotificationSetCpkImage])
    {
        NSDictionary * dic = [nf userInfo];
        NSString * path = [dic valueForKey:imagePath];
        [self setCpkImage:path];
        
        
        //
        
        
        
    }
    else if([ name isEqualToString:kNotificationSetCorrelationImage])
    {
        NSDictionary * dic = [nf userInfo];
        NSString * path = [dic valueForKey:imagePath];
        [self setCorrelationImage:path];
    }
    else if([ name isEqualToString:kNotificationSetScatterImage])
    {
        NSDictionary * dic = [nf userInfo];
        NSString * path = [dic valueForKey:imagePath];
        [self setScatterImage:path];
    }
}

-(void)addExcelHash:(NSNotification *)nf
{
    NSString * name = [nf name];
    NSDictionary* info = [nf userInfo];
    if ([ name isEqualToString:kNotificationAddExcelHash])
    {
        NSString *hash_Path = @"/tmp/CPK_Log/temp/data_hash.csv";//[NSString stringWithFormat:@"%@/CPK_Log/temp/data_hash.csv",desktopPath];
        NSString *str = [NSString stringWithContentsOfFile:hash_Path encoding:NSUTF8StringEncoding error:nil];
        NSString *limit_update_excel_path = [info valueForKey:limit_update_path];
        
        NSString *update_limit_tmp_csv = @"/tmp/CPK_Log/temp/update_limit_temp_for_hash.csv";//[NSString stringWithFormat:@"%@/CPK_Log/temp/update_limit_temp_for_hash.csv",desktopPath];  //把Limit Update 转换成csv，方便计算Excel 第一个sheet的hash code，写入到第二个sheet,目的是只计算第一个sheet的内容，因为第二个sheet 要写入hash 值，所以内容会变化
        NSFileManager *manager = [NSFileManager defaultManager];
        [manager removeItemAtPath:update_limit_tmp_csv error:nil];
        
        
         /* [self changeXlsxTocsv:limit_update_excel_path toTxt:update_limit_tmp_csv];
          [NSThread sleepForTimeInterval:1.5];
          if (![manager fileExistsAtPath:update_limit_tmp_csv])
          {
              for (int i=0; i<5; i++)
              {
                  [self changeXlsxTocsv:limit_update_excel_path toTxt:update_limit_tmp_csv];
                  [NSThread sleepForTimeInterval:3*i];
                  if ([manager fileExistsAtPath:update_limit_tmp_csv])
                  {
                      break;
                  }
              }
          }
        */
        NSMutableArray *msgArraycsv = [NSMutableArray arrayWithObjects:limit_update_excel_path,update_limit_tmp_csv,nil];
        NSString *itemNameCsv = @"excel_limit_update_to_csv_report";
        [self sendDataToRedis:itemNameCsv withData:msgArraycsv];
        [self sendExcelZmqMsg:itemNameCsv];
        
        for (int i=0; i<30; i++)
        {
            [NSThread sleepForTimeInterval:2.0];
            if ([manager fileExistsAtPath:update_limit_tmp_csv])
            {
                break;
            }
            if (i==59)
            {
                [self sendDataToRedis:itemNameCsv withData:msgArraycsv];
                [self sendExcelZmqMsg:itemNameCsv];
                
                for (int j=0; j<60; i++)
                {
                    [NSThread sleepForTimeInterval:2.0];
                    if ([manager fileExistsAtPath:update_limit_tmp_csv])
                    {
                        break;
                    }
                    
                    if(j==59)
                    {
                        [self AlertBox:@"Error:018" withInfo:@"Limit Update Excel file sheet1 calculate hash code error.!!!"];
                        return;
                    }
                    
                }
                
            }
        }
        
        NSString * excel_sheet1_hash = [self opensslSha1FilePath:update_limit_tmp_csv];
        NSString *hash_content = [ NSString stringWithFormat:@"%@7,%@,%@",str,[limit_update_excel_path lastPathComponent],excel_sheet1_hash];
        [hash_content writeToFile:hash_Path atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        NSString *update_limit_path = [NSString stringWithFormat:@"%@/CPK_Log",desktopPath];
        NSString *push2git =  [m_configDictionary valueForKey:kpush2GitHub];
        NSString *gitAddr =  [m_configDictionary valueForKey:kgitWebAddr];
        NSString *gitComment =  [m_configDictionary valueForKey:kgitComment];
        
        NSMutableArray *msgArray = [NSMutableArray arrayWithObjects:hash_Path,update_limit_path,push2git,gitAddr,gitComment,nil];
        NSString *itemName = @"generate_excel_sheet1_hash";
        NSLog(@">generate excel sheet1 hash: name: %@,msgArray:%@",itemName,msgArray);
        [self sendDataToRedis:itemName withData:msgArray];
        [self sendExcelZmqMsg:itemName];
        
    }
}

/*
-(void)changeXlsxTocsv:(NSString *)excelpath toTxt:(NSString *)txtpath
{
    NSString *launchPath = [self taskLaunchPath];
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
-(void)setReportButton:(NSNotification *)nf
{
    NSString * name = [nf name];
    if ([ name isEqualToString:kNotificationGenerateExcel])
    {
        [_btn_report_excel setEnabled:YES];
        [_progressExcel stopAnimation:nil];
        
        [_progressExcel setHidden:YES];
        //[_progressBarExcel setHidden:YES];
        NSString *cmdKillPythonLaunch = @"ps -ef |grep -i python |grep -i report_excel_test.py |grep -v grep|awk '{print $2}' |xargs kill -9";
        system([cmdKillPythonLaunch UTF8String]);
        
        NSString *nameExcel = [NSString stringWithContentsOfFile:@"/tmp/CPK_Log/temp/.excelreportname.txt" encoding:NSUTF8StringEncoding error:nil];
        NSString *namePath = [NSString stringWithFormat:@"%@/CPK_Log/%@",desktopPath,nameExcel];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isExist = [fileManager fileExistsAtPath:namePath];
        if (isExist)
        {
            [self AlertBox:@"Save Excel successful." withInfo:namePath];
        }
        else
        {
            [self AlertBox:@"Save Excel Failed." withInfo:namePath];
        }
        
        
    }
    else if ([ name isEqualToString:kNotificationGenerateKeynote])
    {
        [_btn_report_keynote setEnabled:YES];
        [_progressKeynote stopAnimation:nil];
        [_progressKeynote setHidden:YES];
        //[_progressBarKeynote setHidden:YES];
        
        NSString *cmdKillPythonLaunch = @"ps -ef |grep -i python |grep -i report_keynote_test |grep -v grep|awk '{print $2}' |xargs kill -9";
        NSString *cmdKillKeynote = @"ps -ef |grep -i Keynote |grep -i Keynote |grep -v grep|awk '{print $2}' |xargs kill -9";
        system([cmdKillPythonLaunch UTF8String]);
        system([cmdKillKeynote UTF8String]);
        
        NSString *nameKeynote = [NSString stringWithContentsOfFile:@"/tmp/CPK_Log/temp/.keynotereportname.txt" encoding:NSUTF8StringEncoding error:nil];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isExist = [fileManager fileExistsAtPath:nameKeynote];
        if (isExist)
        {
            [self AlertBox:@"Save Keynote successful." withInfo:nameKeynote];
        }
        else
        {
            [self AlertBox:@"Save Keynote Failed." withInfo:nameKeynote];
        }
        
    }
    
    else if ([ name isEqualToString:kNotificationToLoadCsv])
    {
        [_btn_report_keynote setEnabled:YES];
        [_btn_report_excel setEnabled:YES];
        b_loadCustomCsv = NO;
        NSLog(@">**b_loadCustomCsv: %d",b_loadCustomCsv);
    }
    else if ([ name isEqualToString:kNotificationToLocalLoadCsv])
    {
        //[_btn_report_excel setEnabled:NO];
        //[_btn_report_keynote setEnabled:NO];
        b_loadCustomCsv = YES;
        NSLog(@">**b_loadCustomCsv: %d",b_loadCustomCsv);
        
    }
}

-(void)setRangeLSLandUSL:(NSNotification *)nf
{
    [m_configDictionary setValue:[NSNumber numberWithBool:NO] forKey:kInputRangeFlag];
    NSDictionary * dic = [nf userInfo];
    NSString *lsl = [dic valueForKey:krangelsl];
    NSString *usl = [dic valueForKey:krangeusl];
    dispatch_async(dispatch_get_main_queue(), ^{
    [self.rangeTxtLsl setStringValue:lsl];
    [self.rangeTxtUsl setStringValue:usl];
    });
    inputUSL = usl;
    inputLSL = lsl;
    
}

-(void)sendDataToRedis:(NSString *)name withData:(NSMutableArray *)arrData
{
    if (myRedis)
    {
         myRedis->SetString([name UTF8String],[[NSString stringWithFormat:@"%@",arrData] UTF8String]);
    }
    else
    {
        [self AlertBox:@"Error:027" withInfo:@"Redis server is shut down!"];
    }
    //NSLog(@"--->>set name to redis:%@  %@",name,arrData);
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

-(NSString *)sendBoxZmqMsg:(NSString *)name
{
    int ret = [boxClient SendCmd:name];
    if (ret > 0)
    {
        NSString * response = [boxClient RecvRquest:1024];
        if (!response)
        {
            NSLog(@"zmq for Box(Plot) python error");
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
            NSLog(@"zmq for  Cpk(Plot) python error");
        }
        NSLog(@"app->get response from python: %@",response);
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
    
    
    int ret = [correlationClient SendCmd:name];
    if (ret > 0)
    {
        NSString * response = [correlationClient RecvRquest:1024];
        if (!response)
        {
            NSLog(@"zmq for Correlation (Plot) python error");
        }
        NSLog(@"app->get response from python: %@",response);
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
    NSLog(@">set send Scatter Zmq Msg:%@",name);
    int ret = [scatterClient SendCmd:name];
    if (ret > 0)
    {
        NSString * response = [scatterClient RecvRquest:1024];
        if (!response)
        {
            NSLog(@"zmq for Scatter(Plot) python error");
        }
        NSLog(@"app->scatter get response from python: %@",response);
        return response;
    }
    return nil;
}

-(NSString *)sendExcelZmqMsg:(NSString *)name  //excel zmq
{
    int ret = [reportExcelClient SendCmd:name];
    if (ret > 0)
    {
        NSString * response = [reportExcelClient RecvRquest:1024];
        if (!response)
        {
            NSLog(@"zmq excel for python error");
        }
        NSLog(@"app->get response from excel python: %@",response);
        return response;
    }
    return nil;
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

-(NSString *)sendKeynoteZmqMsg:(NSString *)name  //keynote zmq
{
    int ret = [reportKeynoteClient SendCmd:name];
    if (ret > 0)
    {
        NSString * response = [reportKeynoteClient RecvRquest:1024];
        if (!response)
        {
            NSLog(@"zmq keynote for python error");
        }
        NSLog(@"app->get response from keynote python: %@",response);
        return response;
    }
    return nil;
}

-(NSString *)combineItemName:(NSString *)name
{
    NSString *str_name = @"";
    // 传过来的的name 后面已经有##，因name 是自动往后拼接的##
    str_name = [NSString stringWithFormat:@"%@%@&%@",name,[m_configDictionary valueForKey:kRetestSeg],[m_configDictionary valueForKey:kRemoveFailSeg]];
    return str_name;
}

-(void)toClickOnTableView:(NSNotification *)nf
{
    
}


-(void)ClickOnSelectXY:(NSNotification *)nf
{
    NSDictionary * dic = [nf userInfo];
    int xy = [[dic valueForKey:selectXY] intValue];
    [self getTwoColorTableDataAndSend:xy];
}

-(IBAction)DblClickOnTableView:(id )sender
{

    NSInteger row = [self.colorByTableView selectedRow];
    [self FilterBy1:row];
    
    
    
}



-(void)FilterBy1:(NSInteger)row
{
    if (row == -1 && selectColorBoxIndex2 == 0)
    {
        //NSLog(@"--select item is wrong--++-!!!");
        [self AlertBox:@"Warning." withInfo:@"Please select Filter By 1 item firstly!"];
        return;
    }
    bool checkApplyBox = [[m_configDictionary valueForKey:K_dic_ApplyBoxCheck] boolValue];
    NSMutableArray *selectItem = [NSMutableArray array];
    NSIndexSet *rowIndexes = [self.colorByTableView selectedRowIndexes];
    NSLog(@">.>select: %@",rowIndexes);
    if ([rowIndexes count]) {
        [rowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
            [selectItem addObject:_data[idx]];
        }];
        [m_configDictionary setValue:selectItem forKey:kSelectColorByTableRowsLeft];
        if (tbDataTableSelectItemRow>=0)
        {
            NSMutableArray *selectItemColorTbRight = [NSMutableArray arrayWithArray:[m_configDictionary valueForKey:kSelectColorByTableRowsRight]];

            if ([selectItem isNotEqualTo:lastItemSelectColorTbLeft] || lastTbDataTableSelectItemRow!= tbDataTableSelectItemRow|| selectItemColorTbRight !=lastItemSelectColorTbRight ||checkApplyBox)  //判断是否点击相同的item，如果是相同item，就直接返回
            {
                lastItemSelectColorTbLeft = selectItem;
                lastItemSelectColorTbRight = selectItemColorTbRight;
                lastTbDataTableSelectItemRow = tbDataTableSelectItemRow;
            }
            else
            {
                lastItemSelectColorTbLeft = selectItem;
                lastItemSelectColorTbRight = selectItemColorTbRight;
                lastTbDataTableSelectItemRow = tbDataTableSelectItemRow;
                NSLog(@"=====click the same items");
                return;
            }
            
            [self getTwoColorTableDataAndSend:-1];
            
            [self setBoxData];
            
            
            
            
        }
        else
        {
            [self AlertBox:@"Warning!!!" withInfo:@"Please select item firstly!!!"];
        }
    }
    else
    {
        NSLog(@">>> %@",Off);
        [m_configDictionary setValue:@[Off] forKey:kSelectColorByTableRowsLeft];
    }
}
-(void) setBoxData{
    
    if(is_BoxPlot ){
        
//        NSDictionary* filterInfos= [self generateFilterDic];
//        NSString* filterDatas= [self getFilterDatasWithFilter:tbDataTableSelectItemRow withFilter:filterInfos];
//        [self sendCpkZmqMsg:[NSString stringWithFormat:@"box_caculate^&^%@",filterDatas]];
    }
}
-(NSDictionary*) generateFilterDic
{
    NSMutableDictionary* ret = [[NSMutableDictionary alloc] init];
    
    NSString * key = [self.colorByBox stringValue];
    NSString * key2 = [self.colorByBox2 stringValue];
    

    
    [ret setValue:m_configDictionary[kSelectColorByTableRowsLeft] forKey:key];
    [ret setValue:m_configDictionary[kSelectColorByTableRowsRight] forKey:key2];
    
    return ret;
    
}
-(void)FilterBy1_commandA:(NSInteger)row
{
    if (row == -1 && selectColorBoxIndex2 == 0)
    {
        [self AlertBox:@"Warning." withInfo:@"Please select Filter By 1 item firstly!"];
        return;
    }
    bool checkApplyBox = [[m_configDictionary valueForKey:K_dic_ApplyBoxCheck] boolValue];
    NSMutableArray *selectItem = [NSMutableArray array];
    NSIndexSet *rowIndexes = [self.colorByTableView selectedRowIndexes];
    if ([rowIndexes count])
    {
        for (int i=0; i<[_data count]; i++)
        {
            [selectItem addObject:_data[i]];
        }
        
        [m_configDictionary setValue:selectItem forKey:kSelectColorByTableRowsLeft];
        if (tbDataTableSelectItemRow>=0)
        {
            NSMutableArray *selectItemColorTbRight = [NSMutableArray arrayWithArray:[m_configDictionary valueForKey:kSelectColorByTableRowsRight]];

            if ([selectItem isNotEqualTo:lastItemSelectColorTbLeft] || lastTbDataTableSelectItemRow!= tbDataTableSelectItemRow|| selectItemColorTbRight !=lastItemSelectColorTbRight ||checkApplyBox)  //判断是否点击相同的item，如果是相同item，就直接返回
            {
                lastItemSelectColorTbLeft = selectItem;
                lastItemSelectColorTbRight = selectItemColorTbRight;
                lastTbDataTableSelectItemRow = tbDataTableSelectItemRow;
            }
            else
            {
                lastItemSelectColorTbLeft = selectItem;
                lastItemSelectColorTbRight = selectItemColorTbRight;
                lastTbDataTableSelectItemRow = tbDataTableSelectItemRow;
                NSLog(@"=====click the same items");
                return;
            }
            
            [self getTwoColorTableDataAndSend:-1];
            
        }
        else
        {
            [self AlertBox:@"Warning!!!" withInfo:@"Please select item firstly!!!"];
        }
    }
    else
    {
        NSLog(@">>> %@",Off);
        [m_configDictionary setValue:@[Off] forKey:kSelectColorByTableRowsLeft];
    }
}

-(void)keyMoveFilter1:(NSInteger)row withShiftDown:(BOOL)status
{
    if (row == -1 && selectColorBoxIndex2 == 0)
    {
        return;
    }
    bool checkApplyBox = [[m_configDictionary valueForKey:K_dic_ApplyBoxCheck] boolValue];
    NSMutableArray *selectItem = [NSMutableArray array];
    NSIndexSet *rowIndexes = [self.colorByTableView selectedRowIndexes];
    NSLog(@">select row: %zd",[rowIndexes count]);
    if ([rowIndexes count])
        {
            if (status)
            {
                [rowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                    [selectItem addObject:_data[idx]];
                }];
            }
            
        [selectItem addObject:_data[row]];
        [m_configDictionary setValue:selectItem forKey:kSelectColorByTableRowsLeft];
        if (tbDataTableSelectItemRow>=0)
        {
            NSMutableArray *selectItemColorTbRight = [NSMutableArray arrayWithArray:[m_configDictionary valueForKey:kSelectColorByTableRowsRight]];

            if ([selectItem isNotEqualTo:lastItemSelectColorTbLeft] || lastTbDataTableSelectItemRow!= tbDataTableSelectItemRow|| selectItemColorTbRight !=lastItemSelectColorTbRight ||checkApplyBox)  //判断是否点击相同的item，如果是相同item，就直接返回
            {
                lastItemSelectColorTbLeft = selectItem;
                lastItemSelectColorTbRight = selectItemColorTbRight;
                lastTbDataTableSelectItemRow = tbDataTableSelectItemRow;
            }
            else
            {
                lastItemSelectColorTbLeft = selectItem;
                lastItemSelectColorTbRight = selectItemColorTbRight;
                lastTbDataTableSelectItemRow = tbDataTableSelectItemRow;
                NSLog(@"=click the same items");
                return;
            }
            
            [self getTwoColorTableDataAndSend:-1 withLeftRow:row withRightRow:0];
            
        }
        else
        {
            [self AlertBox:@"Warning!!!" withInfo:@"Please select item firstly!!!."];
        }
    }
}

-(void)FilterBy2:(NSInteger)row
{
    if (row == -1 && selectColorBoxIndex==0) {
        //NSLog(@"--select item is wrong- 2--!!!");
        [self AlertBox:@"Warning." withInfo:@"Please select Filter By 2 item firstly!"];
        return;
    }
    
    bool checkApplyBox = [[m_configDictionary valueForKey:K_dic_ApplyBoxCheck] boolValue];

    NSMutableArray *selectItem = [NSMutableArray array];
    NSIndexSet *rowIndexes = [self.colorByTableView2 selectedRowIndexes];
    if ([rowIndexes count])
    {
        [rowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop)
        {
                [selectItem addObject:_data2[idx]];
            }];

        [m_configDictionary setValue:selectItem forKey:kSelectColorByTableRowsRight];
        
        if (tbDataTableSelectItemRow>=0)
        {
                NSMutableArray *selectItemColorTbLeft = [NSMutableArray arrayWithArray:[m_configDictionary valueForKey:kSelectColorByTableRowsLeft]];
                if ([selectItem isNotEqualTo:lastItemSelectColorTbRight] ||[selectItemColorTbLeft isNotEqualTo:lastItemSelectColorTbLeft] ||lastTbDataTableSelectItemRow!= tbDataTableSelectItemRow||checkApplyBox)  //判断是否点击相同的item，如果是相同item，就直接返回
                {
                    lastItemSelectColorTbLeft = selectItemColorTbLeft;
                    lastItemSelectColorTbRight = selectItem;
                    lastTbDataTableSelectItemRow = tbDataTableSelectItemRow;
                }
                else
                {
                    lastItemSelectColorTbLeft = selectItemColorTbLeft;
                    lastItemSelectColorTbRight = selectItem;
                    lastTbDataTableSelectItemRow = tbDataTableSelectItemRow;
                    NSLog(@"=====click the same items");
                    return;
                }
                
                
            [self getTwoColorTableDataAndSend:-1];
            
            [self setBoxData];
                
            }
        else
        {
            [self AlertBox:@"Warning!!!" withInfo:@"Please select item firstly!!!"];
        }
            
    }
    else
    {
        NSLog(@"==>>> %@",Off);
        [m_configDictionary setValue:@[Off] forKey:kSelectColorByTableRowsLeft];
    }
}

-(void)FilterBy2_commandA:(NSInteger)row
{
    if (row == -1 && selectColorBoxIndex==0) {
        [self AlertBox:@"Warning." withInfo:@"Please select Filter By 2 item firstly!"];
        return;
    }
    
    bool checkApplyBox = [[m_configDictionary valueForKey:K_dic_ApplyBoxCheck] boolValue];

    NSMutableArray *selectItem = [NSMutableArray array];
    NSIndexSet *rowIndexes = [self.colorByTableView2 selectedRowIndexes];
    if ([rowIndexes count])
    {
        for (int i=0; i<[_data2 count]; i++)
        {
            [selectItem addObject:_data2[i]];
        }

        [m_configDictionary setValue:selectItem forKey:kSelectColorByTableRowsRight];
        
        if (tbDataTableSelectItemRow>=0)
        {
                NSMutableArray *selectItemColorTbLeft = [NSMutableArray arrayWithArray:[m_configDictionary valueForKey:kSelectColorByTableRowsLeft]];
                if ([selectItem isNotEqualTo:lastItemSelectColorTbRight] ||[selectItemColorTbLeft isNotEqualTo:lastItemSelectColorTbLeft] ||lastTbDataTableSelectItemRow!= tbDataTableSelectItemRow||checkApplyBox)  //判断是否点击相同的item，如果是相同item，就直接返回
                {
                    lastItemSelectColorTbLeft = selectItemColorTbLeft;
                    lastItemSelectColorTbRight = selectItem;
                    lastTbDataTableSelectItemRow = tbDataTableSelectItemRow;
                }
                else
                {
                    lastItemSelectColorTbLeft = selectItemColorTbLeft;
                    lastItemSelectColorTbRight = selectItem;
                    lastTbDataTableSelectItemRow = tbDataTableSelectItemRow;
                    NSLog(@"=====click the same items");
                    return;
                }
                
                
            [self getTwoColorTableDataAndSend:-1];
            //[self getTwoColorTableDataAndSend:-1 withLeftRow:0 withRightRow:row];
                
            }
        else
        {
            [self AlertBox:@"Warning!!!" withInfo:@"Please select item firstly!!!"];
        }
            
    }
    else
    {
        NSLog(@"==>>> %@",Off);
        [m_configDictionary setValue:@[Off] forKey:kSelectColorByTableRowsLeft];
    }
}

-(void)keyMoveFilter2:(NSInteger)row withShiftDown:(BOOL)status
{
    if (row == -1 && selectColorBoxIndex==0) {
        return;
    }
    
    bool checkApplyBox = [[m_configDictionary valueForKey:K_dic_ApplyBoxCheck] boolValue];

    NSMutableArray *selectItem = [NSMutableArray array];
    NSIndexSet *rowIndexes = [self.colorByTableView2 selectedRowIndexes];
    if ([rowIndexes count])
    {
        if (status)
        {
            [rowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop)
            {
                    [selectItem addObject:_data2[idx]];
                }];
        }
    [selectItem addObject:_data2[row]];
    [m_configDictionary setValue:selectItem forKey:kSelectColorByTableRowsRight];
        if (tbDataTableSelectItemRow>=0)
        {
                NSMutableArray *selectItemColorTbLeft = [NSMutableArray arrayWithArray:[m_configDictionary valueForKey:kSelectColorByTableRowsLeft]];
                if ([selectItem isNotEqualTo:lastItemSelectColorTbRight] ||[selectItemColorTbLeft isNotEqualTo:lastItemSelectColorTbLeft] ||lastTbDataTableSelectItemRow!= tbDataTableSelectItemRow||checkApplyBox)  //判断是否点击相同的item，如果是相同item，就直接返回
                {
                    lastItemSelectColorTbLeft = selectItemColorTbLeft;
                    lastItemSelectColorTbRight = selectItem;
                    lastTbDataTableSelectItemRow = tbDataTableSelectItemRow;
                }
                else
                {
                    lastItemSelectColorTbLeft = selectItemColorTbLeft;
                    lastItemSelectColorTbRight = selectItem;
                    lastTbDataTableSelectItemRow = tbDataTableSelectItemRow;
                    NSLog(@"=====click the same items");
                    return;
                }
                
            [self getTwoColorTableDataAndSend:-1 withLeftRow:0 withRightRow:row];
                
            }
        else
        {
            [self AlertBox:@"Warning!!!" withInfo:@"Please select item firstly!!!."];
        }
    }
}

-(void)DblClickOnTableView2:(id )sender
{
    NSInteger row = [self.colorByTableView2 selectedRow];
    [self FilterBy2:row];
    
}


-(NSArray*)combineMutiArray:(NSMutableArray *)arrayLeft withArray:(NSMutableArray *)arrayRight withDeleteArray:(NSMutableArray *)array3
{
       NSPredicate * filterPredicate_same = [NSPredicate predicateWithFormat:@"SELF IN %@",arrayLeft];
       NSArray * filter_no = [arrayRight filteredArrayUsingPredicate:filterPredicate_same];
//       NSLog(@"%@",filter_no);
       NSPredicate * filterPredicate1 = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",arrayLeft];
       NSArray * filter1 = [arrayRight filteredArrayUsingPredicate:filterPredicate1];
       //找到在arr1中不在数组arr2中的数据
       NSPredicate * filterPredicate2 = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",arrayRight];
       NSArray * filter2 = [arrayLeft filteredArrayUsingPredicate:filterPredicate2];
       //拼接数组
       NSMutableArray *array = [NSMutableArray arrayWithArray:filter1];
       [array addObjectsFromArray:filter2];
       
       NSArray *result = [[filter_no arrayByAddingObjectsFromArray:array] arrayByAddingObjectsFromArray:array3];
       //NSLog(@"==> %@",result);
       return result;
      //    NSPredicate * filter_same = [NSPredicate predicateWithFormat:@"SELF IN %@",selectItemColorTbItemLeft];  //找到相同元素
      //    NSArray * filter_selectItemColorTbItem = [selectItemColorTbItemRight filteredArrayUsingPredicate:filter_same];
}
-(NSDictionary*) getMappingFilterIndex:(NSString*)title{
    
    NSMutableDictionary* ret = [[NSMutableDictionary alloc] init];
    if ([title isEqualToString:Off])
    {
        
        ret[@"Key"] = @"Off";
        ret[@"Childs"] = @[Off];
        ret[@"Index"] = @(0);
        
        
    }
    else if ([title isEqualToString:Version])
    {
        
        ret[@"Key"] = Version;
        ret[@"Childs"] = [m_configDictionary valueForKey:k_dic_Version];;
        ret[@"Index"] = @(n_Version_Col);
        
     
         
    }
    else if ([title isEqualToString:Station_ID])
    {
       
        
        ret[@"Key"] = Station_ID;
        ret[@"Childs"] = [m_configDictionary valueForKey:k_dic_Station_ID];;
        ret[@"Index"] = @(n_StationID_Col);
        
       
    }
    else if ([title isEqualToString:Special_Build_Name])
    {
        
        ret[@"Key"] = Special_Build_Name;
        ret[@"Childs"] = [m_configDictionary valueForKey:k_dic_Special_Build_Name];;
        ret[@"Index"] = @(n_SpecialBuildName_Col);
        
       
        
    }
    else if ([title isEqualToString:Special_Build_Descrip])
    {
        
        ret[@"Key"] = Special_Build_Descrip;
        ret[@"Childs"] = [m_configDictionary valueForKey:k_dic_Special_Build_Desc];;
        ret[@"Index"] = @(n_Special_Build_Descrip_Col);
        
        
        
        
    }
    else if ([title isEqualToString:Product])
    {
        
        ret[@"Key"] = Product;
        ret[@"Childs"] = [m_configDictionary valueForKey:k_dic_Product];;
        ret[@"Index"] = @(n_Product_Col);
        
        
       
        
    }
    else if ([title isEqualToString:Channel_ID])
    {
        ret[@"Key"] = Channel_ID;
        ret[@"Childs"] = [m_configDictionary valueForKey:k_dic_Channel_ID];;
        ret[@"Index"] = @([[m_configDictionary valueForKey:k_dic_Channel_ID_Index] intValue]);
        
        
        
    }
    
    else if ([title isEqualToString:Diags_Version])
     {
         
         ret[@"Key"] = Diags_Version;
         ret[@"Childs"] = [m_configDictionary valueForKey:k_dic_Diags_Version];;
         ret[@"Index"] = @(n_Diags_Version_Col);
         
     }
     else if ([title isEqualToString:OS_VERSION])
     {
         ret[@"Key"] = OS_VERSION;
         ret[@"Childs"] = [m_configDictionary valueForKey:k_dic_OS_Version];;
         ret[@"Index"] = @(n_OS_VERSION_Col);
         
     }
    return ret;
}
-(void)getFilterInfos:(bool) isAll
{
    if(isAll){
        
        
        for (int i=0; i < [_dataReverse count]; i++) {
            
            NSString * BM = nil;
            if ([m_configDictionary[@"KCheckedBMStates"] containsObject:@(i)] ) {
                BM = @"YES";
                NSString * info = [self getFilterDatas:i ];
                NSString * itemname= _dataReverse[i][tb_item];
                [self sendKeynoteZmqMsg:[NSString stringWithFormat:@"caculate^&^%@^&^%@^&^%d^&^%d^&^%@",itemname , info,i+1,[_dataReverse count],BM]];
            }
            
            
        }
    }
    else{
        NSArray* checkedItemRows =m_configDictionary[@"KCheckedItems"];
        
        for (int i=0; i < [checkedItemRows count]; i++) {
            
            NSString * BM = nil;
            if ([m_configDictionary[@"KCheckedBMStates"] containsObject:checkedItemRows[i]] ) {
                BM = @"YES";
                NSString * info = [self getFilterDatas:[checkedItemRows[i] intValue] ];
                NSString * itemname= m_configDictionary[@"KCheckedItemNames"][i];
                [self sendKeynoteZmqMsg:[NSString stringWithFormat:@"caculate^&^%@^&^%@^&^%d^&^%d^&^%@",itemname , info,i+1,[checkedItemRows count],BM]];
            }
            
            
        }
    }
    
}

-(NSString*)getFilterDatas:(int) ItemRow  //计算两个filter 选择的值
{


    NSMutableArray *delectArrIndex = [self getNeedDeletDataIndex];


   
    NSMutableDictionary *BMCheckDataDic = [[NSMutableDictionary alloc] init];
    for (int i=0; i<[filterItemNames count]; i++) {
        
        if([filterItemNames[i] isEqualToString:Diags_Version]){
            
            NSLog(@"");
        }
        NSDictionary* set= [self getMappingFilterIndex:filterItemNames[i]];
        if ([set[@"Index"] isEqualTo:@(-1) ]) {
            NSMutableDictionary* setRet = [[NSMutableDictionary alloc] init];
            
            setRet[@"Data"]=nil;
            setRet[@"Title"]=set[@"Key"];
            setRet[@"Child"]=nil;
            
            
            NSString * keyName= [NSString stringWithFormat:@"%@%@",setRet[@"Title"],setRet[@"Child"] ];
            BMCheckDataDic[keyName ] =setRet;
            continue;
        }
        NSMutableArray *tmp = [NSMutableArray array];
        NSArray *itemsArr = _dataReverse[[set[@"Index"] intValue]];
        
        
        NSInteger itemRow_0 = ItemRow;// [[m_configDictionary valueForKey:kChooseItemIndex] integerValue];
        bool isStartData =false;
        
        for (int j =0; j<[itemsArr count]; j++)
        {
            if(![delectArrIndex containsObject:@(j)]){
                
                int okrow = j;
                if ([_dataReverse[itemRow_0+n_Start_Data_Col][okrow] isEqualTo:Start_Data]) {
                    isStartData = true;
                    continue;;
                }
                
                if (isStartData) {
                    
                    for (int m=0;m< [set[@"Childs"] count];m++)
                    {
                        NSString * keyName= [NSString stringWithFormat:@"%@@%@",set[@"Key"],set[@"Childs"][m] ];
                        
                        if(![[BMCheckDataDic allKeys] containsObject:keyName]){
                            NSMutableDictionary* setRet = [[NSMutableDictionary alloc] init];
                            
                            setRet[@"Data"]=[NSMutableArray array];
                            setRet[@"Title"]=set[@"Key"];
                            setRet[@"Child"]=set[@"Childs"][m];
                            
                            BMCheckDataDic[keyName ] =setRet;
                        }
                        
                        if (([set[@"Childs"][m] isEqualTo:@"BLANK"] and [itemsArr[j] isEqualTo:@""]) or [itemsArr[j] isEqualTo:set[@"Childs"][m]])
                        {
                            
                            if ([_dataReverse[itemRow_0+n_Start_Data_Col] count]>okrow)
                            {
                                [BMCheckDataDic[keyName][@"Data"] addObject:_dataReverse[itemRow_0+n_Start_Data_Col][okrow]];
                            }
                            else
                            {
                                [BMCheckDataDic[keyName ][@"Data"] addObject:@""];
                            }
                        }
                        
                    }
                }
            }
        }
    }

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:BMCheckDataDic options:0 error:nil];

    NSString *strJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    return strJson;
    

}

-(NSDictionary*) getMappingFilterIndexWithFilter:(NSString*)title withChilds:(NSArray*) childs {
    
    NSMutableDictionary* ret = [[NSMutableDictionary alloc] init];
    if ([title isEqualToString:Off])
    {
        
        ret[@"Key"] = @"Off";
        ret[@"Childs"] = @[Off];
        ret[@"Index"] = @(0);
        
        
    }
    else if ([title isEqualToString:Version])
    {
        
        ret[@"Key"] = Version;
        ret[@"Childs"] = childs;
        ret[@"Index"] = @(n_Version_Col);
        
     
         
    }
    else if ([title isEqualToString:Station_ID])
    {
       
        
        ret[@"Key"] = Station_ID;
        ret[@"Childs"] =childs;
        ret[@"Index"] = @(n_StationID_Col);
        
       
    }
    else if ([title isEqualToString:Special_Build_Name])
    {
        
        ret[@"Key"] = Special_Build_Name;
        ret[@"Childs"] = childs;
        ret[@"Index"] = @(n_SpecialBuildName_Col);
        
       
        
    }
    else if ([title isEqualToString:Special_Build_Descrip])
    {
        
        ret[@"Key"] = Special_Build_Descrip;
        ret[@"Childs"] = childs;
        ret[@"Index"] = @(n_Special_Build_Descrip_Col);
        
        
        
        
    }
    else if ([title isEqualToString:Product])
    {
        
        ret[@"Key"] = Product;
        ret[@"Childs"] = childs;
        ret[@"Index"] = @(n_Product_Col);
        
        
       
        
    }
    else if ([title isEqualToString:Channel_ID])
    {
        ret[@"Key"] = Channel_ID;
        ret[@"Childs"] = childs;
        ret[@"Index"] = @([[m_configDictionary valueForKey:k_dic_Channel_ID_Index] intValue]);
        
        
        
    }
    
    else if ([title isEqualToString:Diags_Version])
     {
         
         ret[@"Key"] = Diags_Version;
         ret[@"Childs"] = childs;
         ret[@"Index"] = @(n_Diags_Version_Col);
         
     }
     else if ([title isEqualToString:OS_VERSION])
     {
         ret[@"Key"] = OS_VERSION;
         ret[@"Childs"] = childs;
         ret[@"Index"] = @(n_OS_VERSION_Col);
         
     }
    return ret;
}
-(NSString*)getFilterDatasWithFilter:(int) ItemRow withFilter:(NSDictionary*)filterchilds //计算两个filter 选择的值
{


    NSMutableArray *delectArrIndex = [self getNeedDeletDataIndex];

    NSMutableDictionary *BMCheckDataDic = [[NSMutableDictionary alloc] init];
    
    NSArray* fItemNames = [filterchilds allKeys];
    
    for (int i=0; i<[fItemNames count]; i++) {
        
       
        NSDictionary* set= [self getMappingFilterIndexWithFilter:fItemNames[i] withChilds: filterchilds[fItemNames[i]]];
        if ([set[@"Index"] isEqualTo:@(-1) ]) {
            NSMutableDictionary* setRet = [[NSMutableDictionary alloc] init];
            
            setRet[@"Data"]=nil;
            setRet[@"Title"]=set[@"Key"];
            setRet[@"Child"]=nil;
            
            NSString * keyName= [NSString stringWithFormat:@"%@%@",setRet[@"Title"],setRet[@"Child"] ];
            BMCheckDataDic[keyName ] =setRet;
            continue;
        }
        NSMutableArray *tmp = [NSMutableArray array];
        NSArray *itemsArr = _dataReverse[[set[@"Index"] intValue]];
        
        
        NSInteger itemRow_0 = ItemRow;// [[m_configDictionary valueForKey:kChooseItemIndex] integerValue];
        bool isStartData =false;
        
        for (int j =0; j<[itemsArr count]; j++)
        {
            if(![delectArrIndex containsObject:@(j)]){
                
                int okrow = j;
                if ([_dataReverse[itemRow_0+n_Start_Data_Col][okrow] isEqualTo:Start_Data]) {
                    isStartData = true;
                    continue;;
                }
                
                if (isStartData) {
                    
                    for (int m=0;m< [set[@"Childs"] count];m++)
                    {
                        NSString * keyName= [NSString stringWithFormat:@"%@@%@",set[@"Key"],set[@"Childs"][m] ];
                        
                        if(![[BMCheckDataDic allKeys] containsObject:keyName]){
                            NSMutableDictionary* setRet = [[NSMutableDictionary alloc] init];
                            
                            setRet[@"Data"]=[NSMutableArray array];
                            setRet[@"Title"]=set[@"Key"];
                            setRet[@"Child"]=set[@"Childs"][m];
                            
                            BMCheckDataDic[keyName ] =setRet;
                        }
                        
                        if (([set[@"Childs"][m] isEqualTo:@"BLANK"] and [itemsArr[j] isEqualTo:@""]) or [itemsArr[j] isEqualTo:set[@"Childs"][m]])
                        {
                            
                            if ([_dataReverse[itemRow_0+n_Start_Data_Col] count]>okrow)
                            {
                                [BMCheckDataDic[keyName][@"Data"] addObject:_dataReverse[itemRow_0+n_Start_Data_Col][okrow]];
                            }
                            else
                            {
                                [BMCheckDataDic[keyName ][@"Data"] addObject:@""];
                            }
                        }
                    }
                }
            }
        }
    }

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:BMCheckDataDic options:0 error:nil];

    NSString *strJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    return strJson;
    

}

-(void)getTwoColorTableDataAndSend:(int)xy  //计算两个filter 选择的值
{
    
    if (selectColorBoxIndex ==0 && selectColorBoxIndex2 == 0)
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationClickOneItem object:nil userInfo:nil];
        return;
    }
    
    NSMutableArray *delectArrIndex = [self getNeedDeletDataIndex];

    NSArray *selectItemColorTbItemLeft = [m_configDictionary valueForKey:kSelectColorByTableRowsLeft];
    NSArray *selectItemColorTbItemRight = [m_configDictionary valueForKey:kSelectColorByTableRowsRight];
    
    NSArray *itemsArr = _dataReverse[selectColorBoxIndex];  //left
    NSUInteger itemCountL = [itemsArr count];
    NSUInteger selectCountL = [selectItemColorTbItemLeft count];
    NSMutableArray *itemDataIndexLeft = [NSMutableArray array];
    NSInteger row_left = [self.colorByTableView selectedRow];
    if (selectColorBoxIndex >0 && row_left>= 0)
    {
        for (int i=0; i<selectCountL; i++)  // color by table select item,显示item名字
        {
            NSMutableArray *tmp = [NSMutableArray array];
            for (int j =0; j<itemCountL; j++)
            {
                if (j<tb_data_start)
                {
                    [tmp addObject:[NSNumber numberWithInt:j]];
                }
                else
                {
                    if ([selectItemColorTbItemLeft[i] isEqualTo:@"BLANK"])
                    {
                        if ([itemsArr[j] isEqualTo:@""])
                        {
                            [tmp addObject:[NSNumber numberWithInt:j]];
                        }
                    }
                    else
                    {
                        if ([itemsArr[j] isEqualTo:selectItemColorTbItemLeft[i]])
                        {
                            [tmp addObject:[NSNumber numberWithInt:j]];
                        }
                    }
                    
                }
                
            }
            [itemDataIndexLeft addObject:tmp];
        }
    }
    else
    {
        for (int i=0; i<selectCountL; i++)  // color by table select item,显示item名字
        {
            NSMutableArray *tmp = [NSMutableArray array];
            for (int j =0; j<itemCountL; j++)
            {
                [tmp addObject:[NSNumber numberWithInt:j]];
            }
            [itemDataIndexLeft addObject:tmp];
        }
        
    }

    
   // NSLog(@"=====item index left: %@",itemDataIndexLeft);
    
    NSArray *itemsArr2 = _dataReverse[selectColorBoxIndex2];  //right
    NSUInteger itemCountR = [itemsArr2 count];
    NSUInteger selectCountR = [selectItemColorTbItemRight count];
    NSMutableArray *itemDataIndexRight = [NSMutableArray array];
    NSInteger row_right = [self.colorByTableView2 selectedRow];
    if (selectColorBoxIndex2>0 && row_right>=0)
    {
        for (int i=0; i<selectCountR; i++)  // color by table select item,显示item名字
        {
            NSMutableArray *tmp = [NSMutableArray array];
            for (int j =0; j<itemCountR; j++)
            {
                if (j<tb_data_start)
                {
                    [tmp addObject:[NSNumber numberWithInt:j]];
                }
                else
                {
                    if ([selectItemColorTbItemRight[i] isEqualTo:@"BLANK"])
                    {
                        if ([itemsArr2[j] isEqualTo:@""])
                        {
                            [tmp addObject:[NSNumber numberWithInt:j]];
                        }
                    }
                    else
                    {
                        if ([itemsArr2[j] isEqualTo:selectItemColorTbItemRight[i]])
                        {
                            [tmp addObject:[NSNumber numberWithInt:j]];
                        }
                    }
                }
            }
            [itemDataIndexRight addObject:tmp];
        }
    }
    else
    {
        for (int i=0; i<selectCountR; i++)  // color by table select item,显示item名字
        {
            NSMutableArray *tmp = [NSMutableArray array];
            for (int j =0; j<itemCountR; j++)
            {
                [tmp addObject:[NSNumber numberWithInt:j]];
            }
            [itemDataIndexRight addObject:tmp];
        }
    }
    //NSLog(@"=====item index right: %@",itemDataIndexRight);
    
    
    NSMutableArray *selectItemsIndex = [NSMutableArray array];
    NSMutableArray *selectItemsName = [NSMutableArray array];
    for (int m = 0; m<[itemDataIndexLeft count]; m++)
    {
        for (int n = 0; n<[itemDataIndexRight count]; n++)
        {
            NSPredicate * filter_same = [NSPredicate predicateWithFormat:@"SELF IN %@",itemDataIndexLeft[m]];  //找到相同元素
            NSArray * filter_selectItem = [itemDataIndexRight[n] filteredArrayUsingPredicate:filter_same];
            [selectItemsIndex addObject:filter_selectItem];
            [selectItemsName addObject:[NSString stringWithFormat:@"%@&%@",selectItemColorTbItemLeft[m],selectItemColorTbItemRight[n]]];
        }
    }
    
    //NSLog(@"=====>select item index: %@",selectItemsIndex);
    NSMutableArray *itemsData_0 = [NSMutableArray array];
    NSInteger itemRow_0 =  [[m_configDictionary valueForKey:kChooseItemIndex] integerValue];
    
    NSMutableArray *itemsData = [NSMutableArray array];
    NSMutableArray *snData = [NSMutableArray array];
    NSMutableString *colorItemName = [NSMutableString string];
    for (int k = 0; k<[selectItemsIndex count]; k++)
    {
        
        //NSLog(@"====<<keep>>: %@",selectItemsIndex[k]);
        //NSLog(@"====<<delete>>: %@",delectArrIndex);
        
        int last_selectItemsIndex = -1;
        for (int h = 0; h<[selectItemsIndex[k] count]; h++)
        {
            if (last_selectItemsIndex == [selectItemsIndex[k][h] intValue])  //去掉重复的
            {
                continue;
            }
             if (![delectArrIndex containsObject:selectItemsIndex[k][h]])  //在index delete 列没有的元素
             {
                 int okrow = [selectItemsIndex[k][h] intValue];
                 
                 if ([_dataReverse[tbDataTableSelectItemRow+n_Start_Data_Col] count]>okrow)
                 {
                     [itemsData addObject:_dataReverse[tbDataTableSelectItemRow+n_Start_Data_Col][okrow]];
                     [snData addObject:_dataReverse[n_SerialNumber][okrow]];
                     
                 }
                 else
                 {
                     [itemsData addObject:@""];
                     [snData addObject:@""];
                 }
                 
                 if ([_dataReverse[itemRow_0+n_Start_Data_Col] count]>okrow)
                 {
                     [itemsData_0 addObject:_dataReverse[itemRow_0+n_Start_Data_Col][okrow]];
                 }
                 else
                 {
                     [itemsData_0 addObject:@""];
                 }
                 //NSLog(@"===??>>>> %@",_dataReverse[tbDataTableSelectItemRow+n_Start_Data_Col][okrow]);
             }
            last_selectItemsIndex = [selectItemsIndex[k][h] intValue];
        }
        [itemsData addObject:End_Data];
        [snData addObject:End_Data];
        [itemsData_0 addObject:End_Data];
        
        [colorItemName appendString:[NSString stringWithFormat:@"%@##",selectItemsName[k]]];
    }
    
    //NSLog(@"===>>?>>>> %@",itemsData);
    NSString * itemName = [self combineItemName:colorItemName];
    if (xy==-1)
    {
        // do nothing
    }
    else
    {
        itemName = [NSString stringWithFormat:@"%@$$%d",itemName,xy];
    }
    NSLog(@"======send item name to redis: %@   itemsData count:%zd",itemName,[itemsData count]);
    
    itemsData[tb_color_by_left]= [NSNumber numberWithInteger:selectColorBoxIndex];  //设置color By左边那个,给python生成图表用
    itemsData[tb_color_by_right]= [NSNumber numberWithInteger:selectColorBoxIndex2];  //设置color By左边那个,给python生成图表用
    NSString *typeZoom = [m_configDictionary valueForKey:kzoom_type];
    itemsData[tb_zoom_type] = typeZoom;
    NSString *bins = [m_configDictionary valueForKey:kBins];
    itemsData[tb_bins] = bins;
    
    
    itemsData_0[tb_color_by_left]= [NSNumber numberWithInteger:selectColorBoxIndex];  //设置color By左边那个,给python生成图表用
    itemsData_0[tb_color_by_right]= [NSNumber numberWithInteger:selectColorBoxIndex2];  //设置color By左边那个,给python生成图表用
    itemsData_0[tb_zoom_type] = typeZoom;
    itemsData_0[tb_bins] = bins;
    
    NSString *itemName_0 = [NSString stringWithFormat:@"%@_XY",[m_configDictionary valueForKey:kChooseItemName]];
    
    itemsData[tb_correlation_xy] = itemName_0;
    itemsData_0[tb_correlation_xy] = itemName_0;
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:snData,kSerial_number,itemsData,kData_Value, nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationShowData object:nil userInfo:dic];
    
    if (b_setRangeTxt)
    {
        b_setRangeTxt = NO;
        NSString *rangelsl = [m_configDictionary valueForKey:krangelsl];
        NSString *rangeusl = [m_configDictionary valueForKey:krangeusl];
        itemsData_0[tb_range_lsl] = rangelsl;
        itemsData_0[tb_range_usl] = rangeusl;
        itemsData[tb_range_lsl] = rangelsl;
        itemsData[tb_range_usl] = rangeusl;
        NSLog(@">.>>>range: %@,%@",rangelsl,rangeusl);
        NSDictionary *dic2 = [NSDictionary dictionaryWithObjectsAndKeys:rangelsl,krangelsl,rangeusl,krangeusl, nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationSetRangeLslUsl object:nil userInfo:dic2];
    }
    else
    {
        NSString *rangelsl = itemsData[tb_lower];
        NSString *rangeusl = itemsData[tb_upper];
        itemsData_0[tb_range_lsl] = rangelsl;
        itemsData_0[tb_range_usl] = rangeusl;
        itemsData[tb_range_lsl] = rangelsl;
        itemsData[tb_range_usl] = rangeusl;
        NSLog(@".>.>>>range: %@,%@",rangelsl,rangeusl);
        NSDictionary *dic2 = [NSDictionary dictionaryWithObjectsAndKeys:rangelsl,krangelsl,rangeusl,krangeusl, nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationSetRangeLslUsl object:nil userInfo:dic2];

    }
    
    
    
    [self sendDataToRedis:itemName_0 withData:itemsData_0];
    [self sendDataToRedis:itemName withData:itemsData];
    [self sendCpkZmqMsg:itemName];
    [self sendBoxZmqMsg:itemName];
    [self sendCorrelationZmqMsg:itemName];
    [self sendScatterZmqMsg:itemName];
    
}

-(void)getTwoColorTableDataAndSend:(int)xy withLeftRow:(NSInteger)row_left withRightRow:(NSInteger)row_right
{
    if (selectColorBoxIndex ==0 && selectColorBoxIndex2 == 0)
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationClickOneItem object:nil userInfo:nil];
        return;
    }
    
    NSMutableArray *delectArrIndex = [self getNeedDeletDataIndex];

    NSArray *selectItemColorTbItemLeft = [m_configDictionary valueForKey:kSelectColorByTableRowsLeft];
    NSArray *selectItemColorTbItemRight = [m_configDictionary valueForKey:kSelectColorByTableRowsRight];
    
    
    
    NSArray *itemsArr = _dataReverse[selectColorBoxIndex];  //left
    NSUInteger itemCountL = [itemsArr count];
    NSUInteger selectCountL = [selectItemColorTbItemLeft count];
    NSMutableArray *itemDataIndexLeft = [NSMutableArray array];
    //NSInteger row_left = [self.colorByTableView selectedRow];
    if (!row_left)
    {
        row_left = [self.colorByTableView selectedRow];
    }
    
    if (selectColorBoxIndex >0 && row_left>= 0)
    {
        for (int i=0; i<selectCountL; i++)  // color by table select item,显示item名字
        {
            NSMutableArray *tmp = [NSMutableArray array];
            for (int j =0; j<itemCountL; j++)
            {
                if (j<tb_data_start)
                {
                    [tmp addObject:[NSNumber numberWithInt:j]];
                }
                else
                {
                    if ([selectItemColorTbItemLeft[i] isEqualTo:@"BLANK"])
                    {
                        if ([itemsArr[j] isEqualTo:@""])
                        {
                            [tmp addObject:[NSNumber numberWithInt:j]];
                        }
                    }
                    else
                    {
                        if ([itemsArr[j] isEqualTo:selectItemColorTbItemLeft[i]])
                        {
                            [tmp addObject:[NSNumber numberWithInt:j]];
                        }
                    }
                }
                
            }
            [itemDataIndexLeft addObject:tmp];
        }
    }
    else
    {
        for (int i=0; i<selectCountL; i++)  // color by table select item,显示item名字
        {
            NSMutableArray *tmp = [NSMutableArray array];
            for (int j =0; j<itemCountL; j++)
            {
                [tmp addObject:[NSNumber numberWithInt:j]];
            }
            [itemDataIndexLeft addObject:tmp];
        }
        
    }

    
   // NSLog(@"=====item index left: %@",itemDataIndexLeft);
    
    NSArray *itemsArr2 = _dataReverse[selectColorBoxIndex2];  //right
    NSUInteger itemCountR = [itemsArr2 count];
    NSUInteger selectCountR = [selectItemColorTbItemRight count];
    NSMutableArray *itemDataIndexRight = [NSMutableArray array];
    if (!row_right)
    {
        row_right = [self.colorByTableView2 selectedRow];
    }
    
    if (selectColorBoxIndex2>0 && row_right>=0)
    {
        for (int i=0; i<selectCountR; i++)  // color by table select item,显示item名字
        {
            NSMutableArray *tmp = [NSMutableArray array];
            for (int j =0; j<itemCountR; j++)
            {
                if (j<tb_data_start)
                {
                    [tmp addObject:[NSNumber numberWithInt:j]];
                }
                else
                {
                    if ([selectItemColorTbItemRight[i] isEqualTo:@"BLANK"])
                    {
                        if ([itemsArr2[j] isEqualTo:@""])
                        {
                            [tmp addObject:[NSNumber numberWithInt:j]];
                        }
                    }
                    else
                    {
                        if ([itemsArr2[j] isEqualTo:selectItemColorTbItemRight[i]])
                        {
                            [tmp addObject:[NSNumber numberWithInt:j]];
                        }
                    }
                }
                
            }
            [itemDataIndexRight addObject:tmp];
        }
    }
    else
    {
        for (int i=0; i<selectCountR; i++)  // color by table select item,显示item名字
        {
            NSMutableArray *tmp = [NSMutableArray array];
            for (int j =0; j<itemCountR; j++)
            {
                [tmp addObject:[NSNumber numberWithInt:j]];
            }
            [itemDataIndexRight addObject:tmp];
        }
    }

    NSMutableArray *selectItemsIndex = [NSMutableArray array];
    NSMutableArray *selectItemsName = [NSMutableArray array];
    for (int m = 0; m<[itemDataIndexLeft count]; m++)
    {
        for (int n = 0; n<[itemDataIndexRight count]; n++)
        {
            NSPredicate * filter_same = [NSPredicate predicateWithFormat:@"SELF IN %@",itemDataIndexLeft[m]];  //找到相同元素
            NSArray * filter_selectItem = [itemDataIndexRight[n] filteredArrayUsingPredicate:filter_same];
            [selectItemsIndex addObject:filter_selectItem];
            [selectItemsName addObject:[NSString stringWithFormat:@"%@&%@",selectItemColorTbItemLeft[m],selectItemColorTbItemRight[n]]];
        }
    }
    
    //NSLog(@"=====>select item index: %@",selectItemsIndex);
    NSMutableArray *itemsData_0 = [NSMutableArray array];
    NSInteger itemRow_0 =  [[m_configDictionary valueForKey:kChooseItemIndex] integerValue];
    
    NSMutableArray *itemsData = [NSMutableArray array];
    NSMutableArray *snData = [NSMutableArray array];
    NSMutableString *colorItemName = [NSMutableString string];
    for (int k = 0; k<[selectItemsIndex count]; k++)
    {
        
        //NSLog(@"====<<keep>>: %@",selectItemsIndex[k]);
        //NSLog(@"====<<delete>>: %@",delectArrIndex);
        
        int last_selectItemsIndex = -1;
        for (int h = 0; h<[selectItemsIndex[k] count]; h++)
        {
            if (last_selectItemsIndex == [selectItemsIndex[k][h] intValue])  //去掉重复的
            {
                continue;
            }
             if (![delectArrIndex containsObject:selectItemsIndex[k][h]])  //在index delete 列没有的元素
             {
                 int okrow = [selectItemsIndex[k][h] intValue];
                 
                 if ([_dataReverse[tbDataTableSelectItemRow+n_Start_Data_Col] count]>okrow)
                 {
                     [itemsData addObject:_dataReverse[tbDataTableSelectItemRow+n_Start_Data_Col][okrow]];
                     [snData addObject:_dataReverse[n_SerialNumber][okrow]];
                 }
                 else
                 {
                     [itemsData addObject:@""];
                     [snData addObject:@""];
                 }
                 
                 if ([_dataReverse[itemRow_0+n_Start_Data_Col] count]>okrow)
                 {
                     [itemsData_0 addObject:_dataReverse[itemRow_0+n_Start_Data_Col][okrow]];
                 }
                 else
                 {
                     [itemsData_0 addObject:@""];
                 }
                 
                 //NSLog(@"===??>>>> %@",_dataReverse[tbDataTableSelectItemRow+n_Start_Data_Col][okrow]);
             }
            last_selectItemsIndex = [selectItemsIndex[k][h] intValue];
        }
        [itemsData addObject:End_Data];
        [snData addObject:End_Data];
        [itemsData_0 addObject:End_Data];
        [colorItemName appendString:[NSString stringWithFormat:@"%@##",selectItemsName[k]]];
    }
    //NSLog(@"===>>?>>>> %@",itemsData);
    NSString * itemName = [self combineItemName:colorItemName];
    if (xy==-1)
    {
        // do nothing
    }
    else
    {
        itemName = [NSString stringWithFormat:@"%@$$%d",itemName,xy];
    }
    
    NSLog(@"======send item name to redis: %@   itemsData count:%zd",itemName,[itemsData count]);
    
    itemsData[tb_color_by_left]= [NSNumber numberWithInteger:selectColorBoxIndex];  //设置color By左边那个,给python生成图表用
    itemsData[tb_color_by_right]= [NSNumber numberWithInteger:selectColorBoxIndex2];  //设置color By左边那个,给python生成图表用
    NSString *typeZoom = [m_configDictionary valueForKey:kzoom_type];
    itemsData[tb_zoom_type] = typeZoom;
    NSString *bins = [m_configDictionary valueForKey:kBins];
    itemsData[tb_bins] = bins;
    
    itemsData_0[tb_color_by_left]= [NSNumber numberWithInteger:selectColorBoxIndex];  //设置color By左边那个,给python生成图表用
    itemsData_0[tb_color_by_right]= [NSNumber numberWithInteger:selectColorBoxIndex2];  //设置color By左边那个,给python生成图表用
    itemsData_0[tb_zoom_type] = typeZoom;
    itemsData_0[tb_bins] = bins;
    
    NSString *itemName_0 = [NSString stringWithFormat:@"%@_XY",[m_configDictionary valueForKey:kChooseItemName]];
    itemsData[tb_correlation_xy] = itemName_0;
    itemsData_0[tb_correlation_xy] = itemName_0;
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:snData,kSerial_number,itemsData,kData_Value, nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationShowData object:nil userInfo:dic];
    
    
    if (b_setRangeTxt)
    {
        b_setRangeTxt = NO;
        NSString *rangelsl = [m_configDictionary valueForKey:krangelsl];
        NSString *rangeusl = [m_configDictionary valueForKey:krangeusl];
        itemsData_0[tb_range_lsl] = rangelsl;
        itemsData_0[tb_range_usl] = rangeusl;
        itemsData[tb_range_lsl] = rangelsl;
        itemsData[tb_range_usl] = rangeusl;
        NSLog(@">>>>>range: %@,%@",rangelsl,rangeusl);
        NSDictionary *dic2 = [NSDictionary dictionaryWithObjectsAndKeys:rangelsl,krangelsl,rangeusl,krangeusl, nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationSetRangeLslUsl object:nil userInfo:dic2];
    }
    else
    {
        NSString *rangelsl = itemsData[tb_lower];
        NSString *rangeusl = itemsData[tb_upper];
        itemsData_0[tb_range_lsl] = rangelsl;
        itemsData_0[tb_range_usl] = rangeusl;
        itemsData[tb_range_lsl] = rangelsl;
        itemsData[tb_range_usl] = rangeusl;
        NSLog(@".>>>>>range: %@,%@",rangelsl,rangeusl);
        NSDictionary *dic2 = [NSDictionary dictionaryWithObjectsAndKeys:rangelsl,krangelsl,rangeusl,krangeusl, nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationSetRangeLslUsl object:nil userInfo:dic2];
    }
    
    [self sendDataToRedis:itemName_0 withData:itemsData_0];
    [self sendDataToRedis:itemName withData:itemsData];
    [self sendCpkZmqMsg:itemName];
    [self sendBoxZmqMsg:itemName];
    [self sendCorrelationZmqMsg:itemName];
    [self sendScatterZmqMsg:itemName];
    
}


-(void)notifySetImage:(NSString *)path
{
    NSDictionary *dic = [NSDictionary dictionaryWithObject:path forKey:imagePath];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationSetCpkImage object:nil userInfo:dic];
}



-(void)setCpkBoxImage:(NSString *)path
{
     NSImage *imageCPKBox = [[NSImage alloc]initWithContentsOfFile:path];
     dispatch_async(dispatch_get_main_queue(), ^{
        [self.cpkBoxView setImage:imageCPKBox];
    });
}

-(void)setCpkImage:(NSString *)path
{
     NSImage *imageCPK = [[NSImage alloc]initWithContentsOfFile:path];
     dispatch_async(dispatch_get_main_queue(), ^{
        [self.cpkImageView setImage:imageCPK];
    });
}
-(void)setCorrelationImage:(NSString *)path
{
     NSImage *imageCorrelation = [[NSImage alloc]initWithContentsOfFile:path];
     dispatch_async(dispatch_get_main_queue(), ^{
         [self.correlationImageView setImage:imageCorrelation];
    });
}
-(void)setScatterImage:(NSString *)path
{
     NSImage *imageCorrelation = [[NSImage alloc]initWithContentsOfFile:path];
     dispatch_async(dispatch_get_main_queue(), ^{
         [self.scatterImageMapView setImage:imageCorrelation];
    });
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

-(NSString*)switchRetest:(NSInteger)num
{
    NSString *value = @"";
    switch (num) {
        case 0:
            value = vRetestFirst;
            break;
        case 1:
            value = vRetestAll;
            break;
        case 2:
            value = vRetestLast;
            break;
        default:
            break;
    }
    return value;
}


-(NSString*)switchRemoveFail:(NSInteger)num
{
    NSString *value = @"";
    switch (num) {
        case 0:
            value = vRemoveFailYes;
            break;
        case 1:
            value = vRemoveFailNo;
            break;
        default:
            break;
    }
    return value;
}

-(NSString*)switchZoomDataLimit:(NSInteger)num
{
    NSString *value = @"";
    switch (num) {
        case 0:
            value = @"limit";
            break;
        case 1:
            value = @"data";
            break;
        case 2:
            value = @"range";
            break;
        default:
            break;
    }
    return value;
}

-(int)indexOfColorByItem:(NSString*)item
{
    for (int i=0; i<[colorByName count]; i++)
    {
        if ([colorByName[i] isEqualToString:item])
        {
            return i;
        }
    }
    return 0;
}
// Version,Station_ID,Special_Build_Name,Special_Build_Descrip,Product,Channel_ID
- (IBAction)selectColorByBoxAction:(id)sender {
    NSString *title = [(NSComboBox *)sender stringValue];
    NSLog(@"=>title: %@",title);
    [self sendDataToRedis:@"select_filter_by_1" withData:[NSMutableArray arrayWithObject:title]];
    int n_index = [self indexOfColorByItem:title];
    if (n_index>0)
    {
        [self.colorByBox2 removeAllItems];
        [self.colorByBox2 addItemsWithObjectValues:colorByName];
        [self.colorByBox2 removeItemAtIndex:n_index];
    }

    [_data removeAllObjects];
    if ([title isEqualToString:Off])
    {
        [_data removeAllObjects];
        [m_configDictionary setValue:@[Off] forKey:kSelectColorByTableRowsLeft];
        
        selectColorBoxIndex = 0;
        [self.colorByBox2 removeAllItems];
        [self.colorByBox2 addItemsWithObjectValues:colorByName];
        [self getTwoColorTableDataAndSend:-1];
        
    }
    else if ([title isEqualToString:Version])
    {
        if (n_Version_Col>=0)
        {
            selectColorBoxIndex = n_Version_Col;
            NSMutableArray *vers = [m_configDictionary valueForKey:k_dic_Version];
            if ([vers count]>0)
            {
                _data = [NSMutableArray arrayWithArray:vers];
                if (tbDataTableSelectItemRow>=0)
                {
                    //NSLog(@"---data table select row: %zd , %@",tbDataTableSelectItemRow,_dataReverse[Version_Col]);
                }
                
            }
        }
        else
        {
            selectColorBoxIndex = 0;
            [_data removeAllObjects];
        }
      
         
    }
    else if ([title isEqualToString:Station_ID])
    {
        if (n_StationID_Col>=0)
        {
            selectColorBoxIndex = n_StationID_Col;
            NSMutableArray *IDs = [m_configDictionary valueForKey:k_dic_Station_ID];
            if ([IDs count]>0) {
                _data = [NSMutableArray arrayWithArray:IDs];
                if (tbDataTableSelectItemRow>=0)
                {
                    //NSLog(@"---data table select row: %zd , %@",tbDataTableSelectItemRow,_dataReverse[StationID_Col]);
                }
            }
        }
        else
        {
            selectColorBoxIndex = 0;
            [_data removeAllObjects];
        }
        
       
    }
    else if ([title isEqualToString:Special_Build_Name])
    {
        if (n_SpecialBuildName_Col>=0)
        {
            selectColorBoxIndex = n_SpecialBuildName_Col;
            NSMutableArray *BuildN = [m_configDictionary valueForKey:k_dic_Special_Build_Name];
            if ([BuildN count]>0) {
                _data = [NSMutableArray arrayWithArray:BuildN];
                if (tbDataTableSelectItemRow>=0)
                {
                    //NSLog(@"---data table select row: %zd , %@",tbDataTableSelectItemRow,_dataReverse[SpecialBuildName_Col]);
                }
            }
        }
        else
        {
            selectColorBoxIndex = 0;
            [_data removeAllObjects];
        }
        
       
        
    }
    else if ([title isEqualToString:Special_Build_Descrip])
    {
        if (n_Special_Build_Descrip_Col >=0)
        {
            selectColorBoxIndex = n_Special_Build_Descrip_Col;
            NSMutableArray *BuildN = [m_configDictionary valueForKey:k_dic_Special_Build_Desc];
            if ([BuildN count]>0) {
                _data = [NSMutableArray arrayWithArray:BuildN];
                if (tbDataTableSelectItemRow>=0)
                {
                    //NSLog(@"---data table select row: %zd , %@",tbDataTableSelectItemRow,_dataReverse[SpecialBuildName_Col]);
                }
            }
        }
        else
        {
            selectColorBoxIndex = 0;
            [_data removeAllObjects];
        }
        
        
        
    }
    else if ([title isEqualToString:Product])
    {
        if (n_Product_Col>=0)
        {
            selectColorBoxIndex = n_Product_Col;
            NSMutableArray *BuildN = [m_configDictionary valueForKey:k_dic_Product];
            if ([BuildN count]>0) {
                _data = [NSMutableArray arrayWithArray:BuildN];
                if (tbDataTableSelectItemRow>=0)
                {
                    //NSLog(@"---data table select row: %zd , %@",tbDataTableSelectItemRow,_dataReverse[SpecialBuildName_Col]);
                }
            }
        }
        else
        {
            selectColorBoxIndex = 0;
            [_data removeAllObjects];
        }
        
       
        
    }
    else if ([title isEqualToString:Channel_ID])
    {
        int selRow = [[m_configDictionary valueForKey:k_dic_Channel_ID_Index] intValue];
        if (selRow>=0)
        {
            selectColorBoxIndex = selRow;
            NSMutableArray *channelId = [m_configDictionary valueForKey:k_dic_Channel_ID];
            if ([channelId count]>0) {
                NSLog(@"<<<--->>> %@   %zd",channelId,[channelId count]);
                _data = [NSMutableArray arrayWithArray:channelId];
               
                if (tbDataTableSelectItemRow>=0)
                {
                   
                    if (selRow>0)
                    {
                        //NSLog(@"---data table select row: %zd , %@",tbDataTableSelectItemRow,_dataReverse[selRow]);
                    }
                    
                }
            }
        }
        else
        {
            selectColorBoxIndex = 0;
            [_data removeAllObjects];
        }
        
    }
    
    else if ([title isEqualToString:Diags_Version])
     {
         if (n_Diags_Version_Col>0)
         {
             selectColorBoxIndex = n_Diags_Version_Col;
             NSMutableArray *diagsN = [m_configDictionary valueForKey:k_dic_Diags_Version];
             if ([diagsN count]>0) {
                 _data = [NSMutableArray arrayWithArray:diagsN];
                 if (tbDataTableSelectItemRow>=0)
                 {
                     //NSLog(@"---data table select row: %zd , %@",tbDataTableSelectItemRow,_dataReverse[SpecialBuildName_Col]);
                 }
             }
         }
         else
         {
             selectColorBoxIndex = 0;
             [_data removeAllObjects];
         }
         
     }
     else if ([title isEqualToString:OS_VERSION])
     {
         if (n_OS_VERSION_Col>0)
         {
             selectColorBoxIndex = n_OS_VERSION_Col;
             NSMutableArray *OSVer = [m_configDictionary valueForKey:k_dic_OS_Version];
             if ([OSVer count]>0) {
                 _data = [NSMutableArray arrayWithArray:OSVer];
                 if (tbDataTableSelectItemRow>=0)
                 {
                     //NSLog(@"---data table select row: %zd , %@",tbDataTableSelectItemRow,_dataReverse[SpecialBuildName_Col]);
                 }
             }
         }
         else
         {
             selectColorBoxIndex = 0;
             [_data removeAllObjects];
         }
         
     }
    /*else if ([title isEqualToString:Station_Channel_ID])
    {
        int selRow = [[m_configDictionary valueForKey:k_dic_Channel_ID_Index] intValue];
        selectColorBoxIndex = StationID_Col*10000+selRow;   //取出来的时候除以10000，结果是station id，余就是channel id
        NSMutableArray *station_channelId = [m_configDictionary valueForKey:k_dic_Station_Channel_ID];
        if ([station_channelId count]>0) {
            _data = [NSMutableArray arrayWithArray:station_channelId];
            if (tbDataTableSelectItemRow>=0)
            {
                //NSLog(@"---data table select row: %zd , %@",tbDataTableSelectItemRow,_dataReverse[tbsDataTableSelectItemRow]);
            }
        }
        
    }*/
        
//        if ([self.color_dicDatas.allKeys containsObject:title]) {
//
//            self.color_datas =[self.color_dicDatas objectForKey:title];
//        }else{
//            self.color_datas =nil;
//        }
    [self.colorByTableView reloadData];
    NSDictionary *dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:selectColorBoxIndex] forKey:select_Color_Box_left];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationSetColorByLeft object:nil userInfo:dic];
}

- (IBAction)selectColorByBoxAction2:(id)sender
{
    
    NSString *title = [(NSComboBox *)sender stringValue];
    NSLog(@"=>title2: %@",title);
    [self sendDataToRedis:@"select_filter_by_2" withData:[NSMutableArray arrayWithObject:title]];
    int n_index = [self indexOfColorByItem:title];
    if (n_index>0)
    {
        [self.colorByBox removeAllItems];
        [self.colorByBox addItemsWithObjectValues:colorByName];
        [self.colorByBox removeItemAtIndex:n_index];
    }
    
     [_data2 removeAllObjects];
    if ([title isEqualToString:Off])
    {
        [_data2 removeAllObjects];
        selectColorBoxIndex2 = 0;
        [m_configDictionary setValue:@[Off] forKey:kSelectColorByTableRowsRight];
        
        [self.colorByBox removeAllItems];
        [self.colorByBox addItemsWithObjectValues:colorByName];
        [self getTwoColorTableDataAndSend:-1];
    }
    else if ([title isEqualToString:Version])
    {
        if (n_Version_Col>=0)
        {
            selectColorBoxIndex2 = n_Version_Col;
                   NSMutableArray *vers = [m_configDictionary valueForKey:k_dic_Version];
                   if ([vers count]>0) {
                       _data2 = [NSMutableArray arrayWithArray:vers];
                       if (tbDataTableSelectItemRow>=0)
                       {
                           //NSLog(@"---data table select row: %zd , %@",tbDataTableSelectItemRow,_dataReverse[Version_Col]);
                       }
                   }
        }
        else
        {
            selectColorBoxIndex2 = 0;
            [_data2 removeAllObjects];
        }
       
    }
    else if ([title isEqualToString:Station_ID])
    {
        if (n_StationID_Col>=0)
        {
            selectColorBoxIndex2 = n_StationID_Col;
            NSMutableArray *IDs = [m_configDictionary valueForKey:k_dic_Station_ID];
            if ([IDs count]>0) {
                _data2 = [NSMutableArray arrayWithArray:IDs];
                if (tbDataTableSelectItemRow>=0)
                {
                    //NSLog(@"---data table select row: %zd , %@",tbDataTableSelectItemRow,_dataReverse[StationID_Col]);
                }
            }
        }
        else
        {
            selectColorBoxIndex2 = 0;
            [_data2 removeAllObjects];
        }
        
    }
    else if ([title isEqualToString:Special_Build_Name])
    {
        if (n_SpecialBuildName_Col>=0)
        {
            selectColorBoxIndex2 = n_SpecialBuildName_Col;
            NSMutableArray *BuildN = [m_configDictionary valueForKey:k_dic_Special_Build_Name];
            if ([BuildN count]>0) {
                _data2 = [NSMutableArray arrayWithArray:BuildN];
                if (tbDataTableSelectItemRow>=0)
                {
                    //NSLog(@"---data table select row: %zd , %@",tbDataTableSelectItemRow,_dataReverse[SpecialBuildName_Col]);
                }
            }
        }
        else
        {
            selectColorBoxIndex2 = 0;
            [_data2 removeAllObjects];
        }
        
        
    }
    else if ([title isEqualToString:Special_Build_Descrip])
    {
        if (n_Special_Build_Descrip_Col>=0)
        {
            selectColorBoxIndex2 = n_Special_Build_Descrip_Col;
            NSMutableArray *BuildN = [m_configDictionary valueForKey:k_dic_Special_Build_Desc];
            if ([BuildN count]>0) {
                _data2 = [NSMutableArray arrayWithArray:BuildN];
                if (tbDataTableSelectItemRow>=0)
                {
                    //NSLog(@"---data table select row: %zd , %@",tbDataTableSelectItemRow,_dataReverse[SpecialBuildName_Col]);
                }
            }
        }
        else
        {
            selectColorBoxIndex2 = 0;
            [_data2 removeAllObjects];
        }
        
        
    }
    else if ([title isEqualToString:Product])
    {
        if (n_Product_Col>=0)
        {
            selectColorBoxIndex2 = n_Product_Col;
            NSMutableArray *BuildN = [m_configDictionary valueForKey:k_dic_Product];
            if ([BuildN count]>0) {
                _data2 = [NSMutableArray arrayWithArray:BuildN];
                if (tbDataTableSelectItemRow>=0)
                {
                    //NSLog(@"---data table select row: %zd , %@",tbDataTableSelectItemRow,_dataReverse[SpecialBuildName_Col]);
                }
            }
        }
        else
        {
            selectColorBoxIndex2 = 0;
            [_data2 removeAllObjects];
        }
        
        
    }
    else if ([title isEqualToString:Channel_ID])
    {
        int selRow = [[m_configDictionary valueForKey:k_dic_Channel_ID_Index] intValue];
        if (selRow>=0)
        {
            selectColorBoxIndex2 = selRow;
            NSMutableArray *channelId = [m_configDictionary valueForKey:k_dic_Channel_ID];
            if ([channelId count]>0) {
                NSLog(@"<<<--->>> %@   %zd",channelId,[channelId count]);
                _data2 = [NSMutableArray arrayWithArray:channelId];
               
                if (tbDataTableSelectItemRow>=0)
                {
                   
                    if (selRow>0)
                    {
                        //NSLog(@"---data table select row: %zd , %@",tbDataTableSelectItemRow,_dataReverse[selRow]);
                    }
                    
                }
            }
        }
        else
        {
            selectColorBoxIndex2 = 0;
            [_data2 removeAllObjects];
        }
        
    }
    
    else if ([title isEqualToString:Diags_Version])
     {
         if (n_Diags_Version_Col>0)
         {
             selectColorBoxIndex2 = n_Diags_Version_Col;
             NSMutableArray *diagsN = [m_configDictionary valueForKey:k_dic_Diags_Version];
             if ([diagsN count]>0) {
                 _data2 = [NSMutableArray arrayWithArray:diagsN];
                 if (tbDataTableSelectItemRow>=0)
                 {
                     //NSLog(@"---data table select row: %zd , %@",tbDataTableSelectItemRow,_dataReverse[SpecialBuildName_Col]);
                 }
             }
         }
         else
         {
             selectColorBoxIndex2 = 0;
             [_data2 removeAllObjects];
         }
         
     }
    else if ([title isEqualToString:OS_VERSION])
     {
         if (n_OS_VERSION_Col>0)
         {
             selectColorBoxIndex2 = n_OS_VERSION_Col;
             NSMutableArray *OSVer = [m_configDictionary valueForKey:k_dic_OS_Version];
             if ([OSVer count]>0) {
                 _data2 = [NSMutableArray arrayWithArray:OSVer];
                 if (tbDataTableSelectItemRow>=0)
                 {
                     //NSLog(@"---data table select row: %zd , %@",tbDataTableSelectItemRow,_dataReverse[SpecialBuildName_Col]);
                 }
             }
         }
         else
         {
             selectColorBoxIndex2 = 0;
             [_data2 removeAllObjects];
         }
         
     }
    

    [self.colorByTableView2 reloadData];
    NSDictionary *dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:selectColorBoxIndex2] forKey:select_Color_Box_Right];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationSetColorByRight object:nil userInfo:dic];
}

- (IBAction)clickRetestSegmentAction:(id)sender
{
    if ([_dataReverse count]<1)
    {
        [self AlertBox:@"Error:019" withInfo:@"no data to load."];
        return;
    }
    
    NSInteger ret = self.retestSegment.selectedSegment;
    NSLog(@"==%zd",ret);
    [m_configDictionary setValue:[self switchRetest:ret] forKey:kRetestSeg];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationClickOneItem object:nil userInfo:nil];
}
- (IBAction)clickZoomType:(id)sender
{
    if ([_dataReverse count]<1)
    {
        [self AlertBox:@"Error:019" withInfo:@"no data to load."];
        return;
    }
    
    NSInteger ret = self.zoomTypeSeg.selectedSegment;
    if(ret >1)
    {
        [self setRangeCtlHidden:NO];
    }
    else
    {
        [self setRangeCtlHidden:YES];
        
    }
    [m_configDictionary setValue:[self switchZoomDataLimit:ret] forKey:kzoom_type];
    [m_configDictionary setValue:inputLSL forKey:krangelsl];
    [m_configDictionary setValue:inputUSL forKey:krangeusl];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationClickOneItem object:nil userInfo:nil];
    
}

-(void)setRangeCtlHidden:(BOOL)status
{
    [self.rangeLsl setHidden:status];
    [self.rangeUsl setHidden:status];
    [self.rangeTxtLsl setHidden:status];
    [self.rangeTxtUsl setHidden:status];
}

- (IBAction)btnShowData:(id)sender {
    if ([_dataReverse count]<1)
    {
        [self AlertBox:@"Error:019" withInfo:@"no data to load."];
        return;
    }
    
    
    if ([_showDatatWin.window isVisible]==0)
    {
        if (!_showDatatWin)
        {
            _showDatatWin=[[showDataControl alloc]initWithWindowNibName:@"showDataControl"];
        }
        [_showDatatWin.window orderFront:nil];
    }
    //just for test
   // NSString *picPath =[[NSBundle mainBundle]pathForResource:@"1.png" ofType:nil];
   // [self setCpkImage:picPath];
   // picPath =[[NSBundle mainBundle]pathForResource:@"2.png" ofType:nil];
   // [self setCorrelationImage:picPath];
}

- (IBAction)clickRemoveFailSegmentAction:(id)sender
{
    if ([_dataReverse count]<1)
    {
        [self AlertBox:@"Error:019" withInfo:@"no data to load."];
        return;
    }
    
    NSInteger ret = self.removeFailSegment.selectedSegment;
    NSLog(@"== %zd",ret);
    [m_configDictionary setValue:[self switchRemoveFail:ret] forKey:kRemoveFailSeg];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationClickOneItem object:nil userInfo:nil];
    
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
    FILE* file = fopen([path UTF8String], "rb");
    if (path && file)
    {
        
        
        
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

-(NSString *)clickApply2NewCsv
{
    NSString *csv_temp_Item_Path = @"/tmp/CPK_Log/Temp/Excel_data_temp_select_apply.csv";
    NSMutableArray *csvTmpItem = [NSMutableArray array];
    int i_col=0;
    for(NSMutableArray *lineArray in _dataReverse)
    {
        if (i_col >= n_Start_Data_Col)
        {
            if ([lineArray[tb_apply] intValue]==1)
            {
                [csvTmpItem addObject:_dataReverse[i_col]];
            }
        }
        else
        {
            [csvTmpItem addObject:_dataReverse[i_col]];
        }
        i_col++;
    }
    
    NSMutableArray *csvInsight = [NSMutableArray arrayWithArray:[self reverseArray:csvTmpItem]];
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
    [csvStr writeToFile:csv_temp_Item_Path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error)
    {
        NSLog(@"write apply csv failed: %@",csv_temp_Item_Path);
    }
    else
    {
        NSLog(@"write apply csv successful: %@",csv_temp_Item_Path);
    }
    return csv_temp_Item_Path;
}

- (IBAction)btnReportExcel:(id)sender
{
//    [@"none" writeToFile:[NSString stringWithFormat:@"%@/CPK_Log/temp/.excel.txt",desktopPath] atomically:YES encoding:NSUTF8StringEncoding error:nil];
//    [@"none" writeToFile:[NSString stringWithFormat:@"%@/CPK_Log/temp/.excel_hash.txt",desktopPath] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [@"none" writeToFile:@"/tmp/CPK_Log/temp/.excel.txt" atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [@"none" writeToFile:@"/tmp/CPK_Log/temp/.excel_hash.txt" atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    if ([_dataReverse count]<1)
    {
        [self AlertBox:@"Error:019" withInfo:@"no data to load."];
        return;
    }
    
    if (n_passdata<4)
    {
        //[self AlertBox:@"Warning" withInfo:@"PASS data less than 3, it can not calculate cpk value."];
        //return;
    }
    
    NSString *cmdKillPythonLaunch = @"ps -ef |grep -i python |grep -i report_excel_test.py |grep -v grep|awk '{print $2}' |xargs kill -9";
    system([cmdKillPythonLaunch UTF8String]);
    //NSString *cmdKillExcel = @"ps -ef |grep -i Excel |grep -i Excel |grep -v grep|awk '{print $2}' |xargs kill -9";
    //system([cmdKillExcel UTF8String]);
    
    [startPython Lanuch_excel_report];
    reportExcelClient = [[Client alloc] init];
    [reportExcelClient CreateRPC:excel_report_zmq_addr withSubscriber:nil];
    [reportExcelClient setTimeout:20*1000];
    
    if(!_reportSetWin)
    {
        _reportSetWin=[[reportSettingCfg alloc]initWithWindowNibName:@"reportSettingCfg"];
    }
    
    NSModalResponse result = [NSApp runModalForWindow:_reportSetWin.window];
    if (result == NSModalResponseOK)
    {
        NSMutableString *strCsv = [NSMutableString string];
        NSMutableString *new_USL = [NSMutableString string];
        NSMutableString *new_LSL = [NSMutableString string];
        NSString *reviewer_n;
        NSMutableString *update_Date = [NSMutableString string];
        
        NSDateFormatter* DateFomatter = [[NSDateFormatter alloc] init];
        [DateFomatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSTimeZone *timezone = [[NSTimeZone alloc] initWithName:@"PST"];
        [DateFomatter setTimeZone:timezone];
        NSString* systemTime = [DateFomatter stringFromDate:[NSDate date]];
        NSString *modify_date = @"";
        [strCsv appendString:@"index,item,low,upper,new_lsl,new_usl,apply,reviewer,date,comment\n"];
        NSMutableString * newLimitStr = [NSMutableString string];
        
         int i=0;
         int falgApplly = 0;
         int flagApply2 = 0;
         int flagnewLimit = 0;
          for(NSMutableArray *lineArray in _dataReverse)
          {
              if (i>=n_Start_Data_Col)
              {
                  if ([lineArray[tb_apply] intValue]==0 && ([lineArray[tb_lsl] isNotEqualTo:@""] || [lineArray[tb_usl] isNotEqualTo:@""]) &&[lineArray[tb_reviewer] isEqualToString:@""])
                  {
                      falgApplly = 1;
                  }
                  if ([lineArray[tb_apply] intValue]==1)
                  {
                      flagApply2 ++;
                  }
                  if ([lineArray[tb_lsl] isNotEqualTo:@""] || [lineArray[tb_usl] isNotEqualTo:@""])
                  {
                      flagnewLimit ++;
                  }
                  
                  NSString *new_lsl_str = lineArray[tb_lsl];
                  NSString *new_usl_str = lineArray[tb_usl];
                  //NSLog(@"--->>new_lsl_str : %@ new_usl_str: %@",new_lsl_str,new_usl_str);
                  if ([self isPureFloat:new_lsl_str] && [self isPureInt:new_lsl_str] && [self isPureInt:new_usl_str] && [self isPureFloat:new_usl_str])
                  {
                      float newL = [new_lsl_str floatValue];
                      float newU = [new_usl_str floatValue];
                      if (newL>newU)
                      {
                          [newLimitStr appendFormat:@"Index:%d, Item:%@\nLSL: %@, USL: %@\n\n",i-n_Start_Data_Col+1,lineArray[tb_item],new_lsl_str,new_usl_str];
                      }
                      
                  }
                  else if (([new_lsl_str length]>0 && [new_usl_str isEqualToString:@""]) || ([new_usl_str length]>0 && [new_lsl_str isEqualToString:@""]))
                  {
                      [newLimitStr appendFormat:@"Index:%d, Item:%@\nLSL: %@, USL: %@\n\n",i-n_Start_Data_Col+1,lineArray[tb_item],new_lsl_str,new_usl_str];
                  }
                  
                  
                  if ([lineArray[tb_reviewer] isNotEqualTo:@""])
                  {
                      reviewer_n = lineArray[tb_reviewer];
                  }
                  //else if ([lineArray[tb_date] isNotEqualTo:@""])
                  else if ([lineArray[tb_lsl] isNotEqualTo:@""] || [lineArray[tb_usl] isNotEqualTo:@""])
                  {
                      reviewer_n = [m_configDictionary valueForKey:kuserName];
                  }
                  else
                  {
                      reviewer_n = @"";
                  }
                  
                  if ([lineArray[tb_date] isEqualToString:@""])
                  {
                      if ([reviewer_n isNotEqualTo:@""])
                      {
                          modify_date = systemTime;
                      }
                      else
                      {
                          modify_date = @"";
                      }
                  }
                  else
                  {
                      modify_date = lineArray[tb_date];
                  }
                  
                  NSString * strComment = [lineArray[tb_comment] stringByReplacingOccurrencesOfString:@"," withString:@" "];
                  NSString *arrString = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@,%@\n",lineArray[tb_index],lineArray[tb_item],lineArray[tb_lower],lineArray[tb_upper],lineArray[tb_lsl],lineArray[tb_usl],lineArray[tb_apply],reviewer_n,modify_date,strComment];
                  
                  [strCsv appendString:arrString];
                  [new_USL appendString:[NSString stringWithFormat:@"%@,",lineArray[tb_usl]]];
                  [new_LSL appendString:[NSString stringWithFormat:@"%@,",lineArray[tb_lsl]]];
                  [update_Date appendString:[NSString stringWithFormat:@"%@,",modify_date]];

              }
              
              i++;
          }
             
        NSString *csv_Path = @"/tmp/CPK_Log/temp/item_limit.csv";//[NSString stringWithFormat:@"%@/CPK_Log/temp/item_limit.csv",desktopPath];
        [strCsv writeToFile:csv_Path atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        // =========hash code=====
        //NSString *csv_path1 = [m_configDictionary valueForKey:Load_Csv_Path];
        //NSString *csv_path2_local = [m_configDictionary valueForKey:Load_Local_Csv_Path];
        NSString *csv_data_Path = @"";
        if (b_loadCustomCsv)
        {
            csv_data_Path = kcustomToInsightCsv;
        }
        else
        {
            csv_data_Path = [m_configDictionary valueForKey:Load_Csv_Path];
        }
        
        
        if (!csv_data_Path || [csv_data_Path isEqualToString:@""])
        {
            csv_data_Path = kcustomToInsightCsv;
            NSFileManager *fileManager = [NSFileManager defaultManager];
            BOOL isExist1 = [fileManager fileExistsAtPath:csv_data_Path];
            if (!isExist1)
            {
                [self AlertBox:@"Error:019" withInfo:@"raw data csv file not exist!"];
                return;
            }
        }
        
        NSString *itemName = @"generate_excel";
        
        NSMutableString *hashCsv = [NSMutableString string];
        [hashCsv appendString:@"index,item,ssh code\n"];
        NSString *csv_data_Name = [csv_data_Path lastPathComponent];

        [hashCsv appendString:[NSString stringWithFormat:@"1,Data CSV Name Hash:%@,%@\n",csv_data_Name,[self opensslSha1:csv_data_Name]]];
        [hashCsv appendString:[NSString stringWithFormat:@"2,Data CSV File Hash :%@,%@\n",csv_data_Path,[self opensslSha1FilePath:csv_data_Path]]];
        NSFileManager* manager = [NSFileManager defaultManager];
        unsigned long long csv_data_size= [[manager attributesOfItemAtPath:csv_data_Path error:nil] fileSize];
        [hashCsv appendString:[NSString stringWithFormat:@"3,Data CSV Size(Exact %llu Bytes),%@\n",csv_data_size,[self opensslSha1:[NSString stringWithFormat:@"%llu",csv_data_size]]]];
        
        NSRange deleteusl = {[new_USL length] - 1, 1};
        [new_USL deleteCharactersInRange:deleteusl];  //删除最后一个逗号
        [hashCsv appendString:[NSString stringWithFormat:@"4,\"New USL\" column hash,%@\n",[self opensslSha1:new_USL]]];
        
        NSRange deletelsl = {[new_LSL length] - 1, 1};
        [new_LSL deleteCharactersInRange:deletelsl];  //删除最后一个逗号
        [hashCsv appendString:[NSString stringWithFormat:@"5,\"New LSL\" column hash,%@\n",[self opensslSha1:new_LSL]]];
        
        NSRange deletedate = {[update_Date length] - 1, 1};
        [update_Date deleteCharactersInRange:deletedate];  //删除最后一个逗号
        [hashCsv appendString:[NSString stringWithFormat:@"6,\"Date\" column hash,%@\n",[self opensslSha1:update_Date]]];
        
        NSString *hash_Path = @"/tmp/CPK_Log/temp/data_hash.csv";//[NSString stringWithFormat:@"%@/CPK_Log/temp/data_hash.csv",desktopPath];
        [hashCsv writeToFile:hash_Path atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        //=========================
        if ([newLimitStr length]>0)
        {
            [self AlertBox:@"Below items limit reverse, or no input new LSL or new USL!!!" withInfo:[NSString stringWithFormat:@"%@",newLimitStr]];
            
            system([cmdKillPythonLaunch UTF8String]);
            return;
        }
        
        NSString *exportAllItems = [m_configDictionary valueForKey:kexportAllItems];
        NSString *exportPassItems = [m_configDictionary valueForKey:kexportPassItems];
        NSString *onlyexportlimitupdated = [m_configDictionary valueForKey:konlyLimitUpdated];
        
        if ([onlyexportlimitupdated isEqualToString:@"1"])
        {
            if (flagApply2 != flagnewLimit || flagApply2 == 0)
            {
                [self AlertBox:@"Error:028" withInfo:@"You did not click apply button."];
                system([cmdKillPythonLaunch UTF8String]);
                return;
            }
            NSString *tempPath = [self clickApply2NewCsv];
            exportAllItems = @"1";
            csv_data_Path = tempPath;
        }
        
        if (falgApplly == 1)
        {
            int ret = [self AlertBoxWith2Button:@"Warning!" withInfo:@"You have updated some items limits, but didn't click apply. You want to proceed with report generation?"];
            
            if (ret == 1001)  //cancel not load
            {
                system([cmdKillPythonLaunch UTF8String]);
                return;
            }
        }
        
        //[[NSNotificationCenter defaultCenter]postNotificationName:kNotificationSaveUIdata object:nil userInfo:nil];
        
        
        NSString *cpkLow = [m_configDictionary valueForKey:kcpkLowThd];
        NSString *cpkHigh = [m_configDictionary valueForKey:kcpkHighThd];
        NSString *populate = [m_configDictionary valueForKey:kpopulateDistri];
        
        NSString *userName = [m_configDictionary valueForKey:kuserName];
        NSString *projectName = [m_configDictionary valueForKey:kprojectName];
        NSString *targetBuild = [m_configDictionary valueForKey:ktargetBuild];
        
        NSString *cpk_path = [NSString stringWithFormat:@"%@/CPK_Log/",desktopPath];
        NSString *set_bin = [m_configDictionary valueForKey:kBins];
       
        NSString *push2git =  [m_configDictionary valueForKey:kpush2GitHub];
        NSString *gitAddr =  [m_configDictionary valueForKey:kgitWebAddr];
        NSString *gitComment =  [m_configDictionary valueForKey:kgitComment];
        NSString *p_val_status =  [m_configDictionary valueForKey:kp_val_status];
        
        NSMutableArray *msgArray = [NSMutableArray arrayWithObjects:exportAllItems,exportPassItems,cpkLow,cpkHigh,populate,userName,projectName,targetBuild,cpk_path,set_bin,csv_data_Path,push2git,gitAddr,gitComment,p_val_status,onlyexportlimitupdated,nil];
        
        //NSLog(@"====excel==name:%@  data:%@",itemName,msgArray);
        [self sendDataToRedis:itemName withData:msgArray];
        [self sendExcelZmqMsg:itemName];
        
        [_btn_report_excel setEnabled:NO];
        [_progressExcel setHidden:NO];
        //[_progressBarExcel setHidden:NO];
        
        [_progressExcel startAnimation:nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationShowProgressUp object:nil userInfo:@{@"info":@"start excel report",@"progress":@(10),@"title":@"excel report" }];
        
    } else if (result == NSModalResponseCancel)
    {
        system([cmdKillPythonLaunch UTF8String]);
        NSLog(@"====cancel==");
       // NSLog(@"=======hash code: %@",[self opensslSha1:@"hello worldrrrrr"]);
    }
   
    
}

- (IBAction)btnReport:(id)sender // keynote report
{
    //[@"none" writeToFile:[NSString stringWithFormat:@"%@/CPK_Log/temp/.keynote.txt",desktopPath] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [self AlertBox:@"Warning" withInfo:@"In order to generate Keynote report successfully, some system settings need to be made as below, otherwise you may see a crash.\n\n1- System Preferences > Apple ID > iCloud Drive options > uncheck Keynote & Numbers \n\n2-System Preferences > Security & Privacy > Privacy > Accessibility> Remove (-) “Bridge” and “Terminal” if they exist. After that, add back (+) “Bridge” and “Terminal” and save\n\n3- System Preferences > Security & Privacy >Privacy > Automation> Check all boxes under Bridge\n\nRecommended Keynote version 9.2 or Higher and Numbers version 6.2 or Higher (if use Numbers to Keynote chart option)  and OS version Big Sur 11.2.3 or Highe\n\nIf you still see a crash or cannot see Keynote Application Pop up, you can try below steps (especially on older OS and Keynote versions\n\n4- Please select “Python” option in Keynote report , then run one time and see if you successfully save Keynote report. If so, try choose “Keynote” option next time\n\nIf still see an issue, please contact support."];
    [@"none" writeToFile:@"/tmp/CPK_Log/temp/.keynote.txt" atomically:YES encoding:NSUTF8StringEncoding error:nil];
    if ([_dataReverse count]<1)
    {
        [self AlertBox:@"Error:019" withInfo:@"no data to load!"];
        return;
    }
    
    
    if (n_passdata<4)
    {
        //[self AlertBox:@"Warning" withInfo:@"PASS data less than 3, it can not calculate cpk value."];
        //return;
    }
    
    NSString *udfLanguageCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"][0];
    if (![udfLanguageCode containsString:@"en"])
    {
        [self AlertBox:@"Error:020" withInfo:@"Your Mac OS Language is not English version, it can not generate Keynote!!!\r\nPlease set your Mac OS Language to English!"];
        return;
    }
    
    NSString *cmdKillPythonLaunch = @"ps -ef |grep -i python |grep -i report_keynote_test |grep -v grep|awk '{print $2}' |xargs kill -9";
    NSString *cmdKillKeynote = @"ps -ef |grep -i Keynote |grep -i Keynote |grep -v grep|awk '{print $2}' |xargs kill -9";
    system([cmdKillPythonLaunch UTF8String]);
    system([cmdKillKeynote UTF8String]);
    [startPython Lanuch_keynote_report];
    reportKeynoteClient = [[Client alloc] init];   // connect keynote
    [reportKeynoteClient CreateRPC:keynote_report_zmq_addr withSubscriber:nil];
    
    [reportKeynoteClient setTimeout:20*1000];
    
    if (!_keynoteSetWin)
    {
        _keynoteSetWin = [[keynoteSetting alloc] initWithWindowNibName:@"keynoteSetting"];
    }
    
    NSString * cancelButton = [m_configDictionary valueForKey:Kkeynote_skip_setting_Cancel];
    
    if ([cancelButton isEqualTo:@"Cancel"])
    {
        [_keynoteSetWin initAllCtl];
    }
    [_keynoteSetWin initAllCtl];
    [_keynoteskipSettingWin initAllCtl];
    NSModalResponse result = [NSApp runModalForWindow:_keynoteSetWin.window];
    
   if (result == NSModalResponseOK)
   {
       
       
       int check_AdvancedYes = [[m_configDictionary valueForKey:KitemAdvancedYes] intValue];
       int check_AdvancedNo = [[m_configDictionary valueForKey:KitemAdvancedNo] intValue];
       int check_1aYes = [[m_configDictionary valueForKey:Kitem1aYes] intValue];
       int check_1aNo = [[m_configDictionary valueForKey:Kitem1aNo] intValue];
       int check_1bYes = [[m_configDictionary valueForKey:Kitem1bYes] intValue];
       int check_1bNo = [[m_configDictionary valueForKey:Kitem1bNo] intValue];
       NSString *cpkLow = [m_configDictionary valueForKey:kcpkKeynoteLowThd];
       
       NSString *projectName = [m_configDictionary valueForKey:kkeynotePrjName];
       NSString *targetBuild = [m_configDictionary valueForKey:kkeynoteBuild];
       NSString *plotCount = [m_configDictionary valueForKey:kkeynotePlotCount];
       
       
       NSString * plotType =[m_configDictionary valueForKey:kkeynotePlotType];
       
       NSString * isSkipSumary =[m_configDictionary valueForKey:kkeynoteSkipSummarySlid];
       
       //[self getFilterInfos:(check_1aNo ==1 ? true:false) ];
       //[self getFilterInfos:false ];
       //sleep(4);
       
       NSLog(@">keynote setting: %d,%d,%d,%d,%d,%d, %@,%@,%@,%@",check_AdvancedYes,check_AdvancedNo,check_1aYes,check_1aNo,check_1bYes,check_1bNo,cpkLow,plotCount,plotType,isSkipSumary);
       
       NSString *cpk_path = [NSString stringWithFormat:@"%@/CPK_Log/",desktopPath];
       NSString *set_bin = [m_configDictionary valueForKey:kBins];
       if (check_1aNo==0)
       {
           [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationShowProgressUp object:nil userInfo:@{@"info":@"OK pressed !!",@"progress":@(5),@"title":@"keynote report" }];
           
           int check_k = [[m_configDictionary valueForKey:kchooseUIK] intValue];
           if (check_k == 0)
           {
               [self AlertBox:@"Warning!!!" withInfo:@"You need click \"K\" cloumn check box!!!"];
               system([cmdKillPythonLaunch UTF8String]);
               system([cmdKillKeynote UTF8String]);
               return;
           }
           
           NSString *itemName = @"generate_keynote_1a_yes";
           NSString *cpkHigh = @"99999999.9";
           
           NSString *csv_data_Path = @"/tmp/CPK_Log/Temp/keynote_data_temp.csv";
           NSMutableArray *msgArray = [NSMutableArray arrayWithObjects:cpkLow,cpkHigh,cpk_path,set_bin,csv_data_Path,projectName,targetBuild,plotCount,plotType,isSkipSumary,nil];
           NSLog(@">keynote 1a yes,name:%@;data:%@",itemName,msgArray);
           [self sendDataToRedis:itemName withData:msgArray];
           [self sendKeynoteZmqMsg:itemName];
           [_btn_report_keynote setEnabled:NO];
           [_progressKeynote setHidden:NO];
           [_progressKeynote startAnimation:nil];
           //
           [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationShowProgressUp object:nil userInfo:@{@"info":@"start keynot report",@"progress":@(10),@"title":@"keynote report" }];
           
       }
       else if (check_1bYes==1)
       {
           [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationShowProgressUp object:nil userInfo:@{@"info":@"OK pressed !!",@"progress":@(5),@"title":@"keynote report" }];
           int check_biggerThanLowThd = [[m_configDictionary valueForKey:khasBiggerThanLowThd] intValue];
           if (check_biggerThanLowThd == 0)  // 全部数据 cpk 都小于lthd
           {
               NSString *itemName = @"generate_keynote_1b_yes";
               NSString *csv_data_Path = @"/tmp/CPK_Log/Temp/keynote_data_temp.csv";
               NSString *keynote_data_temp_select_k =@"/tmp/CPK_Log/Temp/keynote_data_temp_select_k.csv";
                
                 int check_skipOneLimitYes = 1;//[[m_configDictionary valueForKey:KskipOneLimitYes] intValue];
                 int check_skipOneLimitNo = 0;//[[m_configDictionary valueForKey:KskipOneLimitNo] intValue];
                 int check_skipHTHLDYes = 1;//[[m_configDictionary valueForKey:KskipHTHLDYes] intValue];
                 int check_skipHTHLDNo = 0;//[[m_configDictionary valueForKey:KskipHTHLDNo] intValue];
                 NSString *check_cpk_thhld = @"";
                 NSString *check_one_limit = @"";
                 if (check_skipHTHLDYes ==1)
                 {
                     check_cpk_thhld = @"yes";
                 }
                 if (check_skipHTHLDNo == 1)
                 {
                     check_cpk_thhld = @"no";
                 }
                 if (check_skipOneLimitYes == 1)
                 {
                     check_one_limit = @"yes";
                 }
                 if (check_skipOneLimitNo == 1)
                  {
                      check_one_limit = @"no";
                  }
                 
               NSString *cpkHigh = @"10.0";//[m_configDictionary valueForKey:kcpkKeynoteHighThd];
                 
                 
                NSMutableArray *msgArray = [NSMutableArray arrayWithObjects:cpkLow,cpkHigh,cpk_path,set_bin,csv_data_Path,keynote_data_temp_select_k,check_cpk_thhld,check_one_limit,projectName,targetBuild,plotCount,plotType,isSkipSumary,nil];
                NSLog(@">>keynote 1b yes directly,name:%@;data:%@",itemName,msgArray);
                [self sendDataToRedis:itemName withData:msgArray];
                [self sendKeynoteZmqMsg:itemName];
                [_btn_report_keynote setEnabled:NO];
                [_progressKeynote setHidden:NO];
               
                [_progressKeynote startAnimation:nil];
               [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationShowProgressUp object:nil userInfo:@{@"info":@"start keynote report(1bYes 1)",@"progress":@(10),@"title":@"keynote report" }];
               
           }
           else
           {
               [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationShowProgressUp object:nil userInfo:@{@"info":@"OK pressed !!",@"progress":@(5),@"title":@"keynote report" }];
               if (!_keynoteskipSettingWin)
               {
                   _keynoteskipSettingWin = [[keynote_skip_setting alloc] initWithWindowNibName:@"keynote_skip_setting"];
               }
               [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationReloadSkipSettingData object:nil userInfo:nil];
               
               NSModalResponse resultSkip = [NSApp runModalForWindow:_keynoteskipSettingWin.window];
               if (resultSkip == NSModalResponseOK)
                {
                    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationShowProgressUp object:nil userInfo:@{@"info":@"Skip Finish !!",@"progress":@(10),@"title":@"keynote report" }];
                   NSString *itemName = @"generate_keynote_1b_yes";
                    NSString *csv_data_Path = @"/tmp/CPK_Log/Temp/keynote_data_temp.csv";//[NSString stringWithFormat:@"%@/CPK_Log/Temp/keynote_data_temp.csv",desktopPath];
                    NSString *keynote_data_temp_select_k = @"/tmp/CPK_Log/Temp/keynote_data_temp_select_k.csv";//[NSString stringWithFormat:@"%@/CPK_Log/Temp/keynote_data_temp_select_k.csv",desktopPath];
                   
                    int check_skipOneLimitYes = [[m_configDictionary valueForKey:KskipOneLimitYes] intValue];
                    int check_skipOneLimitNo = [[m_configDictionary valueForKey:KskipOneLimitNo] intValue];
                    int check_skipHTHLDYes = [[m_configDictionary valueForKey:KskipHTHLDYes] intValue];
                    int check_skipHTHLDNo = [[m_configDictionary valueForKey:KskipHTHLDNo] intValue];
                    NSString *check_cpk_thhld = @"";
                    NSString *check_one_limit = @"";
                    if (check_skipHTHLDYes ==1)
                    {
                        check_cpk_thhld = @"yes";
                    }
                    if (check_skipHTHLDNo == 1)
                    {
                        check_cpk_thhld = @"no";
                    }
                    if (check_skipOneLimitYes == 1)
                    {
                        check_one_limit = @"yes";
                    }
                    if (check_skipOneLimitNo == 1)
                     {
                         check_one_limit = @"no";
                     }
                    
                    NSString *cpkHigh = [m_configDictionary valueForKey:kcpkKeynoteHighThd];
                    
                    
                   NSMutableArray *msgArray = [NSMutableArray arrayWithObjects:cpkLow,cpkHigh,cpk_path,set_bin,csv_data_Path,keynote_data_temp_select_k,check_cpk_thhld,check_one_limit,projectName,targetBuild,plotCount,plotType,isSkipSumary,nil];
                   NSLog(@">>keynote 1b yes,name:%@;data:%@",itemName,msgArray);
                   [self sendDataToRedis:itemName withData:msgArray];
                   [self sendKeynoteZmqMsg:itemName];
                   [_btn_report_keynote setEnabled:NO];
                   [_progressKeynote setHidden:NO];
                   [_progressKeynote startAnimation:nil];
                    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationShowProgressUp object:nil userInfo:@{@"info":@"start keynote report(1bYes 2)",@"progress":@(10),@"title":@"keynote report" }];
                }
           }
               
       }
       else if (check_1bNo==1)
       {
           if (!_keynoteskipSettingWin)
           {
               _keynoteskipSettingWin = [[keynote_skip_setting alloc] initWithWindowNibName:@"keynote_skip_setting"];
           }
           
           //[_keynoteskipSettingWin.window makeKeyAndOrderFront:nil];
           [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationReloadSkipSettingData object:nil userInfo:nil];
           NSModalResponse resultSkip = [NSApp runModalForWindow:_keynoteskipSettingWin.window];
           if (resultSkip == NSModalResponseOK)
           {
               NSLog(@">>>keynote skip item win ok");
               NSString *itemName = @"generate_keynote_1b_no";
               int check_skipOneLimitYes = [[m_configDictionary valueForKey:KskipOneLimitYes] intValue];
               int check_skipOneLimitNo = [[m_configDictionary valueForKey:KskipOneLimitNo] intValue];
               int check_skipHTHLDYes = [[m_configDictionary valueForKey:KskipHTHLDYes] intValue];
               int check_skipHTHLDNo = [[m_configDictionary valueForKey:KskipHTHLDNo] intValue];
               NSString *cpkHigh = [m_configDictionary valueForKey:kcpkKeynoteHighThd];
              
               NSString *csv_data_Path = @"/tmp/CPK_Log/Temp/keynote_data_temp.csv";
               NSString *keynote_data_temp_select_k = @"/tmp/CPK_Log/Temp/keynote_data_temp_select_k.csv";
               
               NSString *check_cpk_thhld = @"";
               NSString *check_one_limit = @"";
               if (check_skipHTHLDYes ==1)
               {
                   check_cpk_thhld = @"yes";
               }
               if (check_skipHTHLDNo == 1)
               {
                   check_cpk_thhld = @"no";
               }
               if (check_skipOneLimitYes == 1)
               {
                   check_one_limit = @"yes";
               }
               if (check_skipOneLimitNo == 1)
                {
                    check_one_limit = @"no";
                }
               
               
               NSMutableArray *msgArray = [NSMutableArray arrayWithObjects:cpkLow,cpkHigh,cpk_path,set_bin,csv_data_Path,keynote_data_temp_select_k,check_cpk_thhld,check_one_limit,projectName,targetBuild,plotCount,plotType,isSkipSumary,nil];
               NSLog(@"=>keynote 1b no,name:%@;data:%@",itemName,msgArray);
               [self sendDataToRedis:itemName withData:msgArray];
               [self sendKeynoteZmqMsg:itemName];
               [_btn_report_keynote setEnabled:NO];
               [_progressKeynote setHidden:NO];
               //[_progressBarKeynote setHidden:NO];
               [_progressKeynote startAnimation:nil];
               [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationShowProgressUp object:nil userInfo:@{@"info":@"start keynote report (1bNo)",@"progress":@(10),@"title":@"keynote report" }];
               
           }
           else if (resultSkip == NSModalResponseCancel)
           {
                NSLog(@"****keynote skip setting item will cancel****");
           }
       }
       
   }
   else if (result == NSModalResponseCancel)
   {
        system([cmdKillPythonLaunch UTF8String]);
        system([cmdKillKeynote UTF8String]);
        NSLog(@"***keynote cancel***");
   }
    
}

- (IBAction)btnShowYield:(id)sender
{
    if ([_dataReverse count]<1)
     {
         [self AlertBox:@"Error:019" withInfo:@"no data to load."];
         return;
     }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExist1 = [fileManager fileExistsAtPath:KbuildSummary];
    if (isExist1)
    {
        NSString *buidStr = [NSString stringWithContentsOfFile:KbuildSummary encoding:NSUTF8StringEncoding error:nil];
        [self AlertBox:@"Warning!" withInfo:[NSString stringWithFormat:@"%@\r\nIt will not generate retest report.",buidStr]];
    }
    
    if ([_yieldRetestWin.window isVisible]==0)
    {
        if (!_yieldRetestWin)
        {
            _yieldRetestWin=[[yieldRetestRate alloc]initWithWindowNibName:@"yieldRetestRate"];
        }
        [_yieldRetestWin.window orderFront:nil];
    }
    
}

- (IBAction)btnSelectY:(id)sender
{
    if ([_dataReverse count]<1)
    {
        [self AlertBox:@"Error:019" withInfo:@"no data to load."];
        return;
    }
    n_select_y ++;
    int y = n_select_y%2;
    NSDictionary *dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:y] forKey:btn_select_y];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationSelectY object:nil userInfo:dic];
    NSLog(@"====select y: %d",y);
    
}

- (IBAction)btnSelectX:(id)sender
{
    if ([_dataReverse count]<1)
    {
        [self AlertBox:@"Error:019" withInfo:@"no data to load."];
        return;
    }
    n_select_x ++;
    int x = n_select_x%2;
    NSDictionary *dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:x] forKey:btn_select_x];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationSelectX object:nil userInfo:dic];
    NSLog(@"====select x: %d",x);
}

- (IBAction)setTxtBinsValue:(id)sender
{
    if ([_dataReverse count]<1)
    {
        [self AlertBox:@"Error:019" withInfo:@"no data to load."];
        return;
    }
    //NSLog(@"==%@",[self.txtBins stringValue]);
    [m_configDictionary setValue:[self.txtBins stringValue] forKey:kBins];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationClickOneItem object:nil userInfo:nil];
}
-(void)controlTextDidEndEditing:(NSNotification *)obj
{
    if ([_dataReverse count]<1)
    {
        [self AlertBox:@"Error:019" withInfo:@"no data to load."];
        return;
    }
    NSTextField *textF =obj.object;
    if ([textF.identifier isEqualToString:@"bins"])
    {
        NSString *ret = [textF stringValue];
        NSLog(@"===edit bins: %@",ret);
        if ([self isAllNum:ret])
        {
            if ([ret intValue] <50 ||[ret intValue] >250)
            {
                [self AlertBox:@"error:021" withInfo:@"set bins range must between 50~250"];
                NSString *val = [m_configDictionary valueForKey:kBins];
                [self.txtBins setStringValue:val];
                return;
            }
            [m_configDictionary setValue:ret forKey:kBins];
            
        }
        else
        {
            [self AlertBox:@"Error:022" withInfo:@"Input Bins should be number!!!"];
            NSString *val = [m_configDictionary valueForKey:kBins];
            [self.txtBins setStringValue:val];
        }
    }
}


#pragma mark TableView Datasource & delegate

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    if (tableView== self.colorByTableView) { //left color by
        return [_data count];
    }
    else if(tableView== self.colorByTableView2) //right color by
    {
        return [_data2 count];
    }
    return -1;
    
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if (tableView == self.colorByTableView) {
        NSString *columnIdentifier = [tableColumn identifier];
         NSTableCellView *view = [_colorByTableView makeViewWithIdentifier:columnIdentifier owner:self];
        
         if ([_data count] > row)
         {
             [[view textField] setStringValue:_data[row]];
         }
         else
         {
              [[view textField] setStringValue:@"--"];
         }
         return view;
    }
    else if (tableView == self.colorByTableView2)
    {
        NSString *columnIdentifier = [tableColumn identifier];
           NSTableCellView *view = [_colorByTableView2 makeViewWithIdentifier:columnIdentifier owner:self];
          
           if ([_data2 count] > row)
           {
               [[view textField] setStringValue:_data2[row]];
           }
           else
           {
                [[view textField] setStringValue:@"--"];
           }
           return view;
    }
    return nil;
    
}

- (IBAction)sliderActionR:(id)sender
{
    if ([_dataReverse count]<1)
    {
       [self AlertBox:@"Error:019" withInfo:@"no data to load."];
       [self.sliderR setIntValue:50];
       return;
    }
    
    int scaleFactor = self.sliderR.intValue;
    if (scaleFactor==50)
    {
        [self.scrollViewRight magnifyToFitRect:self.scrollViewRight.bounds];
        last_SilderR = scaleFactor;
        [self.sliderR setIntValue:50];
        return;
    }
  
    if (last_SilderR>scaleFactor)
    {
        static const CGFloat kZoomInFactor = 0.7071068;
        [self.scrollViewRight setMagnification:self.scrollViewRight.magnification * kZoomInFactor];
    }
    else if(last_SilderR<scaleFactor)
    {
        static const CGFloat kZoomOutFactor = 1.414214;
        [self.scrollViewRight setMagnification:self.scrollViewRight.magnification * kZoomOutFactor];
    }
    last_SilderR = scaleFactor;
}

- (IBAction)sliderActionL:(id)sender
{
    if ([_dataReverse count]<1)
    {
       [self AlertBox:@"Error:019" withInfo:@"no data to load."];
        [self.sliderL setIntValue:50];
       return;
    }
    int scaleFactor = self.sliderL.intValue;
    if (scaleFactor ==50)
    {
        [self.scrollViewLeft magnifyToFitRect:self.scrollViewLeft.bounds];
        last_SilderL = scaleFactor;
        [self.sliderL setIntValue:50];
        return;
    }
    
    if (last_SilderL >scaleFactor)
    {
        static const CGFloat kZoomInFactor = 0.7071068;
        [self.scrollViewLeft setMagnification:self.scrollViewLeft.magnification * kZoomInFactor];
    }
    else if(last_SilderL < scaleFactor)
    {
        static const CGFloat kZoomOutFactor = 1.414214;
        [self.scrollViewLeft setMagnification:self.scrollViewLeft.magnification * kZoomOutFactor];
    }
    last_SilderL = scaleFactor;
    
}
- (IBAction)clickSaveButton:(NSButton *)sender
{
    if ([_dataReverse count]<1)
       {
           [self AlertBox:@"Error:019" withInfo:@"no data to load."];
           return;
       }
    
    NSInteger btnTag = sender.tag;
    if (btnTag == 0)
    {
        NSLog(@"--save cpk image");
        NSString *path = @"/tmp/CPK_Log/temp/cpk.png";//[NSString stringWithFormat:@"%@/CPK_Log/temp/cpk.png",desktopPath];
        NSString *name = [NSString stringWithFormat:@"copy-image$$%@",path];
        [self sendCopyImageZmqMsg:name];
    }
    else if (btnTag == 1)
    {
        NSLog(@"--save correlation image");
        NSString *path = @"/tmp/CPK_Log/temp/correlation.png";//[NSString stringWithFormat:@"%@/CPK_Log/temp/correlation.png",desktopPath];
        NSString *name = [NSString stringWithFormat:@"copy-image$$%@",path];
        [self sendCopyImageZmqMsg:name];
    }
    else if (btnTag == 2)
    {
        if(is_BoxPlot ){
            NSLog(@"--save box image");
            NSString *path = @"/tmp/CPK_Log/temp/cpkbox.png";//[NSString stringWithFormat:@"%@/CPK_Log/temp/scatter.png",desktopPath];
            NSString *name = [NSString stringWithFormat:@"copy-image$$%@",path];
            [self sendCopyImageZmqMsg:name];
            
        }
        else{
            NSLog(@"--save scatter image");
            NSString *path = @"/tmp/CPK_Log/temp/scatter.png";//[NSString stringWithFormat:@"%@/CPK_Log/temp/scatter.png",desktopPath];
            NSString *name = [NSString stringWithFormat:@"copy-image$$%@",path];
            [self sendCopyImageZmqMsg:name];
        }
        
    }
}

-(NSString *)sendCopyImageZmqMsg:(NSString *)name
{
    
    int ret = [copyImageClient SendCmd:name];
    if (ret > 0)
    {
        NSString * response = [copyImageClient RecvRquest:1024];
        if (!response)
        {
            NSLog(@"zmq copy image for python error");
        }
        //NSLog(@"app->get response from copy image python: %@",response);
        return response;
    }
    return nil;
}


- (IBAction)clickReportTags:(id)sender
{
    [self closePopoverMsg];
    if ([_dataReverse count]<1)
    {
       [self AlertBox:@"Error:019" withInfo:@"no data to load."];
       return;
    }
 
    NSString *cmdKillPythonLaunch = @"ps -ef |grep -i python |grep -i report_targs_test |grep -v grep|awk '{print $2}' |xargs kill -9";
    system([cmdKillPythonLaunch UTF8String]);
    [startPython Lanuch_report_tags];
    reportTagsClient = [[Client alloc] init];   // connect keynote
    [reportTagsClient CreateRPC:report_tags_zmq_addr withSubscriber:nil];
    [reportTagsClient setTimeout:20*1000];
    
    if (!_reportTagsWin)
    {
        _reportTagsWin = [[reportTags alloc] initWithWindowNibName:@"reportTags"];
    }
    [_reportTagsWin.window orderFront:nil];
    
    
    
}

- (IBAction)zoomInActionRight:(id)sender
{
    if ([_dataReverse count]<1)
    {
       [self AlertBox:@"Error:019" withInfo:@"no data to load."];
       return;
    }
    static const CGFloat kZoomInFactor = 0.7071068;
    [self.scrollViewRight setMagnification:self.scrollViewRight.magnification * kZoomInFactor];
}

- (IBAction)zoomOutActionRight:(id)sender
{
    if ([_dataReverse count]<1)
    {
       [self AlertBox:@"Error:019" withInfo:@"no data to load."];
       return;
    }
    static const CGFloat kZoomOutFactor = 1.414214;
    [self.scrollViewRight setMagnification:self.scrollViewRight.magnification * kZoomOutFactor];
}

- (IBAction)fitToScreenActionRight:(id)sender
{
    if ([_dataReverse count]<1)
    {
       [self AlertBox:@"Error:019" withInfo:@"no data to load."];
       return;
    }
    [self.scrollViewRight magnifyToFitRect:self.scrollViewRight.bounds];
    self.sliderR.intValue = 50;
    last_SilderR = 50;
}

- (IBAction)fittoScreenActionScatter:(id)sender
{
    if ([_dataReverse count]<1)
    {
       [self AlertBox:@"Error:019" withInfo:@"no data to load."];
       return;
    }
    [self.scatterScrollView magnifyToFitRect:self.scatterScrollView.bounds];
    self.sliderScatter.intValue = 50;
    last_SilderScatter = 50;
    
}

- (IBAction)clickSliderScatter:(id)sender
{
    if ([_dataReverse count]<1)
    {
       [self AlertBox:@"Error:019" withInfo:@"no data to load."];
       [self.sliderScatter setIntValue:50];
       return;
    }
    
    int scaleFactor = self.sliderScatter.intValue;
    if (scaleFactor ==50)
    {
        [self.scatterScrollView magnifyToFitRect:self.scatterScrollView.bounds];
        last_SilderScatter = 50;
        [self.sliderScatter setIntValue:50];
        return;
    }
  
    if (last_SilderScatter>scaleFactor)
    {
        static const CGFloat kZoomInFactor = 0.7071068;
        [self.scatterScrollView setMagnification:self.scatterScrollView.magnification * kZoomInFactor];
    }
    else if(last_SilderScatter<scaleFactor)
    {
        static const CGFloat kZoomOutFactor = 1.414214;
        [self.scatterScrollView setMagnification:self.scatterScrollView.magnification * kZoomOutFactor];
    }
    last_SilderScatter = scaleFactor;
    
}

- (IBAction)zoomInActionLeft:(id)sender
{
    if ([_dataReverse count]<1)
    {
       [self AlertBox:@"Error:019" withInfo:@"no data to load."];
       return;
    }
    static const CGFloat kZoomOutFactor = 0.7071068;
    [self.scrollViewLeft setMagnification:self.scrollViewLeft.magnification * kZoomOutFactor];
    
}

- (IBAction)zoomOutActionLeft:(id)sender
{
    if ([_dataReverse count]<1)
    {
       [self AlertBox:@"Error:019" withInfo:@"no data to load."];
       return;
    }
    static const CGFloat kZoomOutFactor = 1.414214;
    [self.scrollViewLeft setMagnification:self.scrollViewLeft.magnification * kZoomOutFactor];
    
}

- (IBAction)fitTpScreenActionLeft:(id)sender
{
    if ([_dataReverse count]<1)
    {
       [self AlertBox:@"Error:019" withInfo:@"no data to load."];
       return;
    }
    [self.scrollViewLeft magnifyToFitRect:self.scrollViewLeft.bounds];
    self.sliderL.intValue = 50;
    last_SilderL = 50;
}


- (IBAction)btTxtUsl:(NSTextField *)sender
{
    if ([_dataReverse count]<1)
    {
       [self AlertBox:@"Error:019" withInfo:@"no data to load."];
       return;
    }
    NSString *usl = [sender stringValue];
    if ([usl length]==0)
    {
        return;
    }
    if ([self isPureInt:usl] || [self isPureFloat:usl] || [usl isEqualToString:@"NA"])
    {
        inputUSL = usl;
        
        if (([self isPureInt:inputLSL] || [self isPureFloat:inputLSL]) && ([self isPureInt:inputUSL] || [self isPureFloat:inputUSL]))
        {
            float n_lsl = [inputLSL floatValue];
            float n_usl = [inputUSL floatValue];
            if (n_lsl>n_usl)
            {
                [self AlertBox:@"Error:023" withInfo:@"LSL is bigger than USL!!!"];
                return;
            }
            [m_configDictionary setValue:inputLSL forKey:krangelsl];
            [m_configDictionary setValue:inputUSL forKey:krangeusl];
            [m_configDictionary setValue:[NSNumber numberWithBool:YES] forKey:kInputRangeFlag];
            b_setRangeTxt = YES;
            [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationClickOneItem object:nil userInfo:nil];
        }
        
    }
    else
    {
        [self AlertBox:@"Error:016" withInfo:@"Please input a number."];
    }
    
}

- (IBAction)btTxtLsl:(NSTextField *)sender
{
    if ([_dataReverse count]<1)
    {
       [self AlertBox:@"Error:019" withInfo:@"no data to load."];
       return;
    }
    NSString *lsl = [sender stringValue];
    if ([lsl length]==0)
    {
        return;
    }
    if ([self isPureInt:lsl] || [self isPureFloat:lsl] || [lsl isEqualToString:@"NA"])
    {
        inputLSL = lsl;
        if (([self isPureInt:inputLSL] || [self isPureFloat:inputLSL]) && ([self isPureInt:inputUSL] || [self isPureFloat:inputUSL]))
        {
            float n_lsl = [inputLSL floatValue];
            float n_usl = [inputUSL floatValue];
            if (n_lsl>n_usl)
            {
                [self AlertBox:@"Error:023" withInfo:@"LSL is bigger than USL!!!"];
                return;
            }
            [m_configDictionary setValue:inputLSL forKey:krangelsl];
            [m_configDictionary setValue:inputUSL forKey:krangeusl];
            [m_configDictionary setValue:[NSNumber numberWithBool:YES] forKey:kInputRangeFlag];
            b_setRangeTxt = YES;
            [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationClickOneItem object:nil userInfo:nil];
        }
    }
    else
    {
        [self AlertBox:@"Error:016" withInfo:@"Please input a number."];
    }
    
}
- (IBAction)btStripplot:(id)sender {
    
    is_BoxPlot = NO;
    n_flag_cpkBtn = 0;
    n_flag_scatterBtn =  1;
//
//    if(n_flag_scatterBtn !=1){
        [self.SpliterBox setHidden:NO];
        CGFloat panelWinth = self.customerMainView.frame.size.width;
        CGFloat offsetWidth = 10;
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
            context.allowsImplicitAnimation = YES;
            context.duration = 0.1; // seconds
            context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            [self.splitPlotView setPosition:0 ofDividerAtIndex:0];
            [self.splitPlotView setPosition:0 ofDividerAtIndex:1];
            [self.splitPlotView setPosition:900 ofDividerAtIndex:2];
            
            
            //[self.splitPlotView layoutSubtreeIfNeeded];
            
            [self.SpliterBox setPosition:900 ofDividerAtIndex:0];
            [self.SpliterBox setPosition:900 ofDividerAtIndex:1];
        }];
//        n_flag_scatterBtn =  1;
//    }
    
    
    
    
 //   n_flag_scatterBtn ++;
}
- (IBAction)btCorrelationPlots:(id)sender {
//    n_flag_scatterBtn =0;
//    is_BoxPlot = NO;
//
//    if(n_flag_cpkBtn!=1){
    
    is_BoxPlot = NO;
    n_flag_cpkBtn = 1;
    n_flag_scatterBtn =  0;
    
    [self initSplitScatter];
//        n_flag_cpkBtn = 1;
//    }
    
    
}
- (IBAction)btnClickBoxplot:(id)sender {
//    n_flag_scatterBtn =0;
//
//    n_flag_cpkBtn = 0;
//
//    if (is_BoxPlot != YES) {
    
    is_BoxPlot = YES;
    n_flag_cpkBtn = 0;
    n_flag_scatterBtn =  1;
        [self.SpliterBox setHidden:NO];
        CGFloat panelWinth = self.customerMainView.frame.size.width;
        CGFloat offsetWidth = 10;
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
            context.allowsImplicitAnimation = YES;
            context.duration = 0.1; // seconds
            context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            [self.splitPlotView setPosition:0 ofDividerAtIndex:0];
            [self.splitPlotView setPosition:0 ofDividerAtIndex:1];
            [self.splitPlotView setPosition:900 ofDividerAtIndex:2];
            
            
            //[self.splitPlotView layoutSubtreeIfNeeded];
            [self.SpliterBox setPosition:0 ofDividerAtIndex:0];
            [self.SpliterBox setPosition:900 ofDividerAtIndex:1];
        }];
//        is_BoxPlot = YES;
//    }
    
    
  
    
}


- (IBAction)btCorrelationScatterPlot:(id)sender
{

    
    NSInteger ret = self.plotTypeSeg.selectedSegment;
    is_BoxPlot = NO;
    if (ret ==0)
    {
        is_BoxPlot = NO;
        n_flag_scatterBtn=0;
        if (n_flag_cpkBtn >0)
        {
            return;
        }
        n_flag_cpkBtn ++;
        [self initSplitScatter];
    }
    else if (ret == 1)
    {
        is_BoxPlot = NO;
        n_flag_cpkBtn = 0;
        if (n_flag_scatterBtn>0)
        {
            return;
        }
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
            context.allowsImplicitAnimation = YES;
            context.duration = 0.1; // seconds
            context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            [self.splitPlotView setPosition:0 ofDividerAtIndex:0];
            [self.splitPlotView setPosition:0 ofDividerAtIndex:1];
            [self.splitPlotView layoutSubtreeIfNeeded];
        }];
        n_flag_scatterBtn ++;
    }
    
}



-(void)defineSplitSize
{
    _lastCpkPaneWidth = self.cpkViewWin.frame.size.width;
    _lastCorrelationPaneWidth = self.correlationViewWin.frame.size.width;
    _lastScatterPaneWidth = self.scatterViewWin.frame.size.width;
    _lastSettingPaneWidth =self.settingViewWin.frame.size.width;
    _lastFilter1PaneWidth = self.filter1ViewWin.frame.size.width;
    _lastFilter2PaneWidth =self.filter2ViewWin.frame.size.width;
    _lastPaneWidth = self.customerMainView.frame.size.width;

    _cpkPercentage = _lastCpkPaneWidth/_lastPaneWidth;
    _correlationPercentage = _lastCorrelationPaneWidth/_lastPaneWidth;
    _scatterPercentage = _lastScatterPaneWidth/_lastPaneWidth;
    _settingPanelPercentage = _lastSettingPaneWidth/_lastPaneWidth;
    _filter1lPercentage = _lastFilter1PaneWidth/_lastPaneWidth;
    _filter2lPercentage = _lastFilter2PaneWidth /_lastPaneWidth;
}

-(void)defineSplitSize2
{
    _lastScatterPaneWidth = self.scatterViewWin.frame.size.width;
    _lastCpkPaneWidth = _lastScatterPaneWidth/2;//self.cpkViewWin.frame.size.width;
    _lastCorrelationPaneWidth = _lastScatterPaneWidth/2;//self.correlationViewWin.frame.size.width;
    _lastScatterPaneWidth = 0;
    
    _lastSettingPaneWidth =self.settingViewWin.frame.size.width;
    _lastFilter1PaneWidth = self.filter1ViewWin.frame.size.width;
    _lastFilter2PaneWidth =self.filter2ViewWin.frame.size.width;
    _lastPaneWidth = self.customerMainView.frame.size.width;

    _cpkPercentage = _lastCpkPaneWidth/_lastPaneWidth;
    _correlationPercentage = _lastCorrelationPaneWidth/_lastPaneWidth;
    _scatterPercentage = _lastScatterPaneWidth/_lastPaneWidth;
    _settingPanelPercentage = _lastSettingPaneWidth/_lastPaneWidth;
    _filter1lPercentage = _lastFilter1PaneWidth/_lastPaneWidth;
    _filter2lPercentage = _lastFilter2PaneWidth /_lastPaneWidth;
}

-(void)initSplitScatter
{
    CGFloat panelWinth = self.customerMainView.frame.size.width;
    CGFloat offsetWidth = 10;
    
    CGFloat x0 = panelWinth*_cpkPercentage;
    CGFloat x1 = panelWinth*_correlationPercentage+ x0;
    CGFloat x2 = _scatterPercentage*panelWinth + x1;
    CGFloat x3 = _settingPanelPercentage*panelWinth + x2;
    CGFloat x4 = _filter1lPercentage*panelWinth + x3;
    CGFloat x5 = _filter2lPercentage*panelWinth+x4;
    NSLog(@"*** %f %f  %f %f  %f %f",x0,x1,x2,x3,x4,x5);
    

    
    
    [self.SpliterBox setPosition:0 ofDividerAtIndex:0];
    [self.SpliterBox setPosition:0 ofDividerAtIndex:1];
    
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.allowsImplicitAnimation = YES;
        context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        
 

        [self.splitPlotView setPosition:900 ofDividerAtIndex:2];
        
    }];
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.allowsImplicitAnimation = YES;
        context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        
 

        [self.splitPlotView setPosition:900 ofDividerAtIndex:1];
        
    }];
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.allowsImplicitAnimation = YES;
        context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        
 

        [self.splitPlotView setPosition:450 ofDividerAtIndex:0];
        
    }];
    
//    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
//        context.allowsImplicitAnimation = YES;
//        context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
//        [self.splitPlotView setPosition:panelWinth*_cpkPercentage ofDividerAtIndex:0];
//        [self.splitPlotView layoutSubtreeIfNeeded];
//    }];
//
//    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
//        context.allowsImplicitAnimation = YES;
//        context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
//        [self.splitPlotView setPosition:panelWinth*_correlationPercentage+ panelWinth*_cpkPercentage+offsetWidth ofDividerAtIndex:1];
//        [self.splitPlotView layoutSubtreeIfNeeded];
//    }];
 
    
    
}

-(void)moveSplitScatter
{
    CGFloat panelWinth = self.customerMainView.frame.size.width;
    CGFloat x0 = panelWinth*_cpkPercentage;
    CGFloat x1 = panelWinth*_correlationPercentage+ x0;
    CGFloat x2 = _scatterPercentage*panelWinth + x1;
    CGFloat x3 = _settingPanelPercentage*panelWinth + x2;
    CGFloat x4 = _filter1lPercentage*panelWinth + x3;
    CGFloat x5 = _filter2lPercentage*panelWinth+x4;

    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.allowsImplicitAnimation = YES;
        context.duration = 0.1; // seconds
        context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];

        [self.splitPlotView setPosition:0 ofDividerAtIndex:0];
        [self.splitPlotView layoutSubtreeIfNeeded];
    }];
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.allowsImplicitAnimation = YES;
        context.duration = 0.1; // seconds
        context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];

        [self.splitPlotView setPosition:0 ofDividerAtIndex:1];
   
        [self.splitPlotView layoutSubtreeIfNeeded];
    }];
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.allowsImplicitAnimation = YES;
        context.duration = 0.1; // seconds
        context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];

        [self.splitPlotView setPosition:x0+x1+x2 ofDividerAtIndex:2];
   
        [self.splitPlotView layoutSubtreeIfNeeded];
    }];
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.allowsImplicitAnimation = YES;
        context.duration = 0.1; // seconds
        context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
  
        [self.splitPlotView setPosition:x3 ofDividerAtIndex:3];
 
        [self.splitPlotView layoutSubtreeIfNeeded];
    }];
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.allowsImplicitAnimation = YES;
        context.duration = 0.1; // seconds
        context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        [self.splitPlotView setPosition:x4 ofDividerAtIndex:4];
        [self.splitPlotView layoutSubtreeIfNeeded];
    }];
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.allowsImplicitAnimation = YES;
        context.duration = 0.1; // seconds
        context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        [self.splitPlotView setPosition:x5 ofDividerAtIndex:5];
        [self.splitPlotView layoutSubtreeIfNeeded];
    }];
    
}
- (IBAction)checkActionPDF:(id)sender
{
    [self sendStringToRedis:KSetPDF withData:[NSString stringWithFormat:@"%zd",[self.checkPDF state]]];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationClickOneItem object:nil userInfo:nil];
}
- (IBAction)checkActionCDF:(id)sender
{
    [self sendStringToRedis:KSetCDF withData:[NSString stringWithFormat:@"%zd",[self.checkCDF state]]];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationClickOneItem object:nil userInfo:nil];
}
- (IBAction)bt_Test:(id)sender
{
   
    [self initSplitScatter];
}

- (void)windowDidResize:(NSNotification *)aNotification
{
    NSInteger ret = self.plotTypeSeg.selectedSegment;
    if (ret ==0)
    {
        [self defineSplitSize];
    }
    else if (ret ==1)
    {
        [self defineSplitSize2];
    }
}

/*-(void)viewDidLayout
{
    NSInteger ret = self.plotTypeSeg.selectedSegment;
    if (ret ==0)
    {
        [self defineSplitSize];
    }
    else if (ret ==1)
    {
        [self defineSplitSize2];
    }
}*/

@end
