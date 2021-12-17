//
//  yieldRetestRate.m
//  Bridge
//
//  Created by RyanGao on 2020/7/31.
//  Copyright © 2020 RyanGao. All rights reserved.
//

#import "yieldRetestRate.h"
//#import "../SCparseCSV.framework/Headers/parseCSV.h"
#import "parseCSV.h"
#import "SCRedis.framework/Headers/RedisInterface.hpp"
#import "dataPlotView.h"
#import "defineHeader.h"
#import "SCZmq.framework/Headers/Client.h"
#import "defineHeader.h"
#import "DMPaletteContainer.h"
#import "DMPaletteSectionView.h"

extern Client *copyImageClient;

@interface yieldRetestRate ()
{
    DMPaletteContainer*     container;
}

@property (weak) IBOutlet NSTableView *yieldTabelView;
@property (nonatomic,strong)NSMutableArray *yieldData;
@property (weak) IBOutlet NSTableView *retestTableView;
@property (nonatomic,strong)NSMutableArray *retestData;
@property (weak) IBOutlet NSTableView *failTableView;
@property (nonatomic,strong)NSMutableArray *failData;
@property (weak) IBOutlet NSTableView *cpkRangeTableView;
@property (nonatomic,strong)NSMutableArray *cpkRangeData;
@property (weak) IBOutlet NSTableView *retestByFixtureTableView;
@property (nonatomic,strong)NSMutableArray *retestByFixtureData;

@end

@implementation yieldRetestRate

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        _yieldData = [[NSMutableArray alloc]init];
        _retestData = [[NSMutableArray alloc]init];
        _failData = [[NSMutableArray alloc]init];
        _cpkRangeData = [[NSMutableArray alloc]init];
        _retestByFixtureData = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    NSView* destinationView = self.imageShowView;
    NSRect bound = NSMakeRect(10, 10, NSWidth(destinationView.frame)-20, NSHeight(destinationView.frame)-10);
    container = [[DMPaletteContainer alloc] initWithFrame:bound];
    [self.imageShowView addSubview:container];
    container.sectionViews = [NSArray arrayWithObjects:
                              [[DMPaletteSectionView alloc] initWithContentView:self.showImage1 andTitle:@"1:"],[[DMPaletteSectionView alloc] initWithContentView:self.showImage2 andTitle:@"2:"],
                              [[DMPaletteSectionView alloc] initWithContentView:self.showImage3 andTitle:@"3:"],
                               [[DMPaletteSectionView alloc] initWithContentView:self.showImage4 andTitle:@"4:"],[[DMPaletteSectionView alloc] initWithContentView:self.showImage5 andTitle:@"5:"],[[DMPaletteSectionView alloc] initWithContentView:self.showImage6 andTitle:@"6:"],[[DMPaletteSectionView alloc] initWithContentView:self.showImage7 andTitle:@"7:"],nil];
    
    
    // [_yieldWin setLevel:kCGFloatingWindowLevel];
     [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(OnTimer:) userInfo:nil repeats:YES];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(readCsvData:) name:kNotificationRetestRate object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setUiImage:) name:kNotificationSetRetestImage object:nil];

    [self loadYieldData];
    [self loadRetestData];
    [self loadFailData];
    [self loadCpkRangeData];
    [self loadRetestByFixtureData];
    
    
    NSString *savepath =[[NSBundle mainBundle]pathForResource:@"for_filesave.png" ofType:nil];
    NSImage *saveIcon = [[NSImage alloc]initWithContentsOfFile:savepath];
        dispatch_async(dispatch_get_main_queue(), ^{
           [self.btnCopy1 setImage:saveIcon];
           [self.btnCopy2 setImage:saveIcon];
           [self.btnCopy3 setImage:saveIcon];
           [self.btnCopy4 setImage:saveIcon];
           [self.btnCopy5 setImage:saveIcon];
           [self.btnCopy6 setImage:saveIcon];
           [self.btnCopy7 setImage:saveIcon];
       });
    
}

-(int)loadYieldData
{
    [_yieldData removeAllObjects];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExist = [fileManager fileExistsAtPath:KYieldRatePath];
    if (isExist)
    {
        CSVParser *csv = [[CSVParser alloc]init];
        if ([csv openFile:KYieldRatePath])
        {
            _yieldData = [csv parseFile];
        }
        if (!_yieldData.count)
        {
            NSLog(@"-no yield data");
            return -2;
        }
        [self.yieldTabelView reloadData];
        return 0;
    }
    else
    {
        [self.yieldTabelView reloadData];
        return -1;
    }
}

-(int)loadRetestData
{
    [_retestData removeAllObjects];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExist = [fileManager fileExistsAtPath:KRetestPath];
    if (isExist)
    {
        CSVParser *csv = [[CSVParser alloc]init];
        if ([csv openFile:KRetestPath])
        {
            _retestData = [csv parseFile];
        }
        if (!_retestData.count)
        {
            NSLog(@"-no retest data");
            return -2;
        }
        [self.retestTableView reloadData];
        return 0;
    }
    else
    {
        [self.retestTableView reloadData];
        return -1;
    }
}

-(int)loadFailData
{
    [_failData removeAllObjects];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExist = [fileManager fileExistsAtPath:KFailPath];
    if (isExist)
    {
        CSVParser *csv = [[CSVParser alloc]init];
        if ([csv openFile:KFailPath])
        {
            _failData = [csv parseFile];
        }
        if (!_failData.count)
        {
            NSLog(@"-no fail data");
            return -2;
        }
        [self.failTableView reloadData];
        return 0;
    }
    else
    {
        [self.failTableView reloadData];
        return -1;
    }
}

-(int)loadCpkRangeData
{
    [_cpkRangeData removeAllObjects];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExist = [fileManager fileExistsAtPath:KCpkRangePath];
    if (isExist)
    {
        CSVParser *csv = [[CSVParser alloc]init];
        if ([csv openFile:KCpkRangePath])
        {
            _cpkRangeData = [csv parseFile];
        }
        if (!_cpkRangeData.count)
        {
            NSLog(@"-no cpk Range data");
            return -2;
        }
        [self.cpkRangeTableView reloadData];
        return 0;
    }
    else
    {
        [self.cpkRangeTableView reloadData];
        return -1;
    }
}

-(int)loadRetestByFixtureData
{
    [_retestByFixtureData removeAllObjects];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExist = [fileManager fileExistsAtPath:KRetestByFixturePath];
    if (isExist)
    {
        CSVParser *csv = [[CSVParser alloc]init];
        if ([csv openFile:KRetestByFixturePath])
        {
            _retestByFixtureData = [csv parseFile];
        }
        if (!_retestByFixtureData.count)
        {
            NSLog(@"-no retest by fixture data");
            return -2;
        }
        [self.retestByFixtureTableView reloadData];
        return 0;
    }
    else
    {
        [self.retestByFixtureTableView reloadData];
        return -1;
    }
}

-(void)readCsvData:(NSNotification *)nf
{
    
    [self loadYieldData];
    [self loadRetestData];
    [self loadFailData];
    [self loadCpkRangeData];
    [self loadRetestByFixtureData];
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    NSString *identify = [tableView identifier];
    if ([identify isEqualToString:@"yield_rate"])
    {
        return [_yieldData count];
    }
    else if([identify isEqualToString:@"retest_top5"])
    {
        return [_retestData count];
    }
    else if([identify isEqualToString:@"fail_top5"])
    {
        return [_failData count];
    }
    else if([identify isEqualToString:@"cpk_range"])
    {
        return [_cpkRangeData count];
    }
    else if([identify isEqualToString:@"retest_by_fixture"])
    {
        return [_retestByFixtureData count];
    }
    else
    {
        return 0;
    }
    
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString *tb_identifier = [tableView identifier];
    if ([tb_identifier isEqualToString:@"yield_rate"])
    {
            NSString *columnIdentifier = [tableColumn identifier];
            NSTableCellView *view = [_yieldTabelView makeViewWithIdentifier:columnIdentifier owner:self];
           NSUInteger index = -1;
           
           if ([columnIdentifier isEqualToString:@"stationid"])
           {
               index = 0;
           }
            if ([columnIdentifier isEqualToString:@"testcount"])
            {
                index = 1;
            }
           if ([columnIdentifier isEqualToString:@"pass"])
             {
                 index = 2;
             }
           if ([columnIdentifier isEqualToString:@"fail"])
             {
                 index = 3;
             }
           if ([columnIdentifier isEqualToString:@"retestcount"])
             {
                 index = 4;
             }
           if ([columnIdentifier isEqualToString:@"yieldpercentage"])
             {
                 index = 5;
             }
           if ([columnIdentifier isEqualToString:@"retestrate"])
              {
                  index = 6;
              }
           if ([columnIdentifier isEqualToString:@"failrate"])
              {
                  index = 7;
              }
           
           if ([[_yieldData objectAtIndex:row] count]>index)
           {
               [[view textField] setStringValue:[_yieldData objectAtIndex:row][index]];
           }
           else
           {
                [[view textField] setStringValue:@""];
           }
           return view;
            
    }
    else if ([tb_identifier isEqualToString:@"retest_top5"])
    {
        NSString *columnIdentifier = [tableColumn identifier];
        NSTableCellView *view = [_retestTableView makeViewWithIdentifier:columnIdentifier owner:self];
       NSUInteger index = -1;
       
       if ([columnIdentifier isEqualToString:@"col_1"])
       {
           index = 0;
       }
        if ([columnIdentifier isEqualToString:@"col_2"])
        {
            index = 1;
        }
       if ([columnIdentifier isEqualToString:@"col_3"])
         {
             index = 2;
         }
       if ([[_retestData objectAtIndex:row] count]>index)
       {
           [[view textField] setStringValue:[_retestData objectAtIndex:row][index]];
       }
       else
       {
            [[view textField] setStringValue:@""];
       }
       return view;
    }
    else if ([tb_identifier isEqualToString:@"fail_top5"])
    {
        NSString *columnIdentifier = [tableColumn identifier];
        NSTableCellView *view = [_failTableView makeViewWithIdentifier:columnIdentifier owner:self];
       NSUInteger index = -1;
       
       if ([columnIdentifier isEqualToString:@"col_1"])
       {
           index = 0;
       }
        if ([columnIdentifier isEqualToString:@"col_2"])
        {
            index = 1;
        }
       if ([columnIdentifier isEqualToString:@"col_3"])
         {
             index = 2;
         }
       if ([[_failData objectAtIndex:row] count]>index)
       {
           [[view textField] setStringValue:[_failData objectAtIndex:row][index]];
       }
       else
       {
            [[view textField] setStringValue:@""];
       }
       return view;
    }
    else if ([tb_identifier isEqualToString:@"cpk_range"])
    {
        NSString *columnIdentifier = [tableColumn identifier];
        NSTableCellView *view = [_cpkRangeTableView makeViewWithIdentifier:columnIdentifier owner:self];
       NSUInteger index = -1;
       
       if ([columnIdentifier isEqualToString:@"col_1"])
       {
           index = 0;
       }
        if ([columnIdentifier isEqualToString:@"col_2"])
        {
            index = 1;
        }
       if ([columnIdentifier isEqualToString:@"col_3"])
         {
             index = 2;
         }
        if ([columnIdentifier isEqualToString:@"col_4"])
          {
              index = 3;
          }
        if ([columnIdentifier isEqualToString:@"col_5"])
          {
              index = 4;
          }
       if ([[_cpkRangeData objectAtIndex:row] count]>index)
       {
           [[view textField] setStringValue:[_cpkRangeData objectAtIndex:row][index]];
       }
       else
       {
            [[view textField] setStringValue:@""];
       }
       return view;
    }
    else if ([tb_identifier isEqualToString:@"retest_by_fixture"])
    {
        NSString *columnIdentifier = [tableColumn identifier];
        NSTableCellView *view = [_retestByFixtureTableView makeViewWithIdentifier:columnIdentifier owner:self];
       NSUInteger index = -1;
       
       if ([columnIdentifier isEqualToString:@"col_1"])
       {
           index = 0;
       }
        if ([columnIdentifier isEqualToString:@"col_2"])
        {
            index = 1;
        }
       if ([columnIdentifier isEqualToString:@"col_3"])
         {
             index = 2;
         }
        if ([columnIdentifier isEqualToString:@"col_4"])
          {
              index = 3;
          }
        if ([columnIdentifier isEqualToString:@"col_5"])
          {
              index = 4;
          }
        if ([columnIdentifier isEqualToString:@"col_6"])
          {
              index = 5;
          }
        if ([columnIdentifier isEqualToString:@"col_7"])
          {
              index = 6;
          }
       if ([[_retestByFixtureData objectAtIndex:row] count]>index)
       {
           [[view textField] setStringValue:[_retestByFixtureData objectAtIndex:row][index]];
       }
       else
       {
            [[view textField] setStringValue:@""];
       }
       return view;
    }
    else
    {
        NSString *columnIdentifier = [tableColumn identifier];
        NSTableCellView *view = [_cpkRangeTableView makeViewWithIdentifier:columnIdentifier owner:self];
        [[view textField] setStringValue:@""];
        return view;
    }
    
}

- (IBAction)btOK:(id)sender
{
    [self.yieldWin close];
    
}

-(void)OnTimer:(NSTimer *)timer
{
    NSString *pathretest =@"/tmp/CPK_Log/retest/.retest_plot.txt";
    NSString *logContext = [NSString stringWithContentsOfFile:pathretest encoding:NSUTF8StringEncoding error:nil];
    if ([logContext containsString:@"Finished"])
    {
        [@"none" writeToFile:pathretest atomically:YES encoding:NSUTF8StringEncoding error:nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationSetRetestImage object:nil userInfo:nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationRetestRate object:nil userInfo:nil];
    }
}

-(void)setUiImage:(NSNotification *)nf
{
    NSString * name = [nf name];
    if ([ name isEqualToString:kNotificationSetRetestImage])
    {
        NSArray *path_file = @[retest_pie_png,daily_all_retest_summary_png,daily_retest_summary_png,retest_vs_station_id_png,retest_vs_version_png,fail_pareto_png,retest_pareto_png,@"",@"",@"",@""];
        for(int i = 1;i<8;i++)
        {
            [self setRetestImage:path_file[i-1] withId:i];
        }
        
    }
}


-(void)setRetestImage:(NSString *)path withId:(int) x_id
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExist = [fileManager fileExistsAtPath:path];
    if (!isExist)
    {
        path = @"/tmp/CPK_Log/retest/.none_pic.png";
    }
     NSImage *image_Path = [[NSImage alloc]initWithContentsOfFile:path];
     dispatch_async(dispatch_get_main_queue(), ^{
         switch (x_id)
         {
             case 1:
                [self.imagePng1 setImage:image_Path];
                 break;
             case 2:
                 [self.imagePng2 setImage:image_Path];
                 break;
             case 3:
                 [self.imagePng3 setImage:image_Path];
                 break;
             case 4:
                 [self.imagePng4 setImage:image_Path];
                 break;
             case 5:
                 [self.imagePng5 setImage:image_Path];
                 break;
             case 6:
                 [self.imagePng6 setImage:image_Path];
                 break;
             case 7:
                 [self.imagePng7 setImage:image_Path];
                 break;
             default:
                 break;
         }
        
    });
}



- (IBAction)clickActionCopy7:(id)sender
{
    [self copyPicFunction:6];
}

- (IBAction)clickActionCopy6:(id)sender
{

    [self copyPicFunction:5];
}

- (IBAction)clickActionCopy5:(id)sender {

    [self copyPicFunction:4];
}

- (IBAction)clickActionCopy4:(id)sender {

    [self copyPicFunction:3];
}

- (IBAction)clickActionCopy3:(id)sender {
    [self copyPicFunction:2];
}

- (IBAction)clickActionCopy2:(id)sender {
    [self copyPicFunction:1];
}

- (IBAction)clickActionCopy1:(id)sender {
    [self copyPicFunction:0];
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

-(void)copyPicFunction:(int)index_pic
{
    NSArray *path_file = @[retest_pie_png,daily_all_retest_summary_png,daily_retest_summary_png,retest_vs_station_id_png,retest_vs_version_png,fail_pareto_png,retest_pareto_png,@"",@"",@"",@""];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExist = [fileManager fileExistsAtPath:path_file[index_pic]];
    NSString * path_png = path_file[index_pic];
    if (!isExist)
    {
        path_png = @"/tmp/CPK_Log/retest/.none_pic.png";
    }
    NSString *name = [NSString stringWithFormat:@"copy-image$$%@",path_png];
    [self sendCopyImageZmqMsg:name];
}

@end
