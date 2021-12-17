//
//  StartUpInfor.m
//  GUI
//
//  Created by Ryan on 8/27/15.
//  Copyright (c) 2015 ___sc Automation___. All rights reserved.
//

#import "StartUp.h"
#include <Foundation/Foundation.h>


@implementation StartUp

-(id)init
{
    self= [super init];
    if (self) {
        system("/usr/bin/ulimit -n 8192");
    }
    return self;
}

-(BOOL)OpenRedisServer
{
    NSString *file_cli = [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"redis-cli"] stringByReplacingOccurrencesOfString:@" " withString:@"\\ "];
    
    file_cli = [file_cli stringByReplacingOccurrencesOfString:@"(" withString:@"\\("];
    file_cli = [file_cli stringByReplacingOccurrencesOfString:@")" withString:@"\\)"];
    
    NSString *cli_shutdown = [NSString stringWithFormat:@"%@ -p 6379 shutdown",file_cli];
    system([cli_shutdown UTF8String]);
    
    [NSThread sleepForTimeInterval:0.2];
    system([cli_shutdown UTF8String]);
    [NSThread sleepForTimeInterval:0.4];
    
    NSString *killRedis = @"ps -ef |grep -i redis-server |grep -v grep|awk '{print $2}' |xargs kill -9";
    system([killRedis UTF8String]);
    system([killRedis UTF8String]);
    [NSThread sleepForTimeInterval:0.2];
    //NSString *file = [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"redis-server&"] stringByReplacingOccurrencesOfString:@" " withString:@"\\ "];
    NSString *file_config = [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"redis.conf"] stringByReplacingOccurrencesOfString:@" " withString:@"\\ "];
    NSString *file = [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"redis-server"] stringByReplacingOccurrencesOfString:@" " withString:@"\\ "];
    
    file = [NSString stringWithFormat:@"%@ %@",file,file_config];
    
    file = [file stringByReplacingOccurrencesOfString:@"(" withString:@"\\("];
    file = [file stringByReplacingOccurrencesOfString:@")" withString:@"\\)"];
    system([file UTF8String]);
    
    NSString *cli_cmd1 = [NSString stringWithFormat:@"%@ config set stop-writes-on-bgsave-error no",file_cli];
    system([cli_cmd1 UTF8String]);
    
    NSString *cli_cmd2 = [NSString stringWithFormat:@"%@ config set stop-writes-on-bgsave-error no",file_cli];
    system([cli_cmd2 UTF8String]);
    
    
    
//    for (int i=0; i<10; i++)
//    {
//        NSString *killRedis = @"ps -ef |grep -i redis-server |grep -v grep|awk '{print $2}' |xargs kill -9";
//        system([killRedis UTF8String]);
//    }
//     [NSThread sleepForTimeInterval:0.2];
    
    
    //NSString *file = [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"redis-server&"] stringByReplacingOccurrencesOfString:@" " withString:@"\\ "];

    //system([file UTF8String]);
    
    [NSThread sleepForTimeInterval:0.2];
    NSString *cli_Path = [NSString stringWithFormat:@"%@ flushall",file_cli];
    for (int i=0; i<2; i++)
        system([cli_Path UTF8String]);
    return true;
}
-(void)Lanuch_limit_merge
{
    NSString * cmd = @"/Library/Frameworks/Python.framework/Versions/3.9/bin/python3.9";
    NSString * arg = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"limit_merge_test.py"];
    NSString *logCmd = @"ps -ef |grep -i python |grep -i limit_merge_test.py |grep -v grep|awk '{print $2}' | xargs kill -9";
    system([logCmd UTF8String]); //
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:arg])
    {
        arg = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"cpk_test.pyc"];
        logCmd = @"ps -ef |grep -i python |grep -i limit_merge_test |grep -v grep|awk '{print $2}' | xargs kill -9";
        system([logCmd UTF8String]);
    }
         
    [self execute_withTask:cmd withPython:arg];
    
}
-(void)Lanuch_atlas_report{
    
    NSString * cmd = @"/Library/Frameworks/Python.framework/Versions/3.9/bin/python3.9";
    NSString * arg = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"atlas2_test.py"];
    NSString *logCmd = @"ps -ef |grep -i python |grep -i atlas2_test.py |grep -v grep|awk '{print $2}' | xargs kill -9";
    system([logCmd UTF8String]); //
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:arg])
    {
        arg = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"atlas2_test.pyc"];
        logCmd = @"ps -ef |grep -i python |grep -i atlas2_test |grep -v grep|awk '{print $2}' | xargs kill -9";
        system([logCmd UTF8String]);
    }
         
    [self execute_withTask:cmd withPython:arg];
}

-(void)Lanuch_box
{
    NSString * cmd = @"/Library/Frameworks/Python.framework/Versions/3.9/bin/python3.9";
    NSString * arg = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"box_test.py"];
    NSString *logCmd = @"ps -ef |grep -i python |grep -i box_test.py |grep -v grep|awk '{print $2}' | xargs kill -9";
    system([logCmd UTF8String]); //
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:arg])
    {
        arg = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"box_test.pyc"];
        logCmd = @"ps -ef |grep -i python |grep -i box_test |grep -v grep|awk '{print $2}' | xargs kill -9";
        system([logCmd UTF8String]);
    }
         
    [self execute_withTask:cmd withPython:arg];
    
}

-(void)Lanuch_cpk
{
    NSString * cmd = @"/Library/Frameworks/Python.framework/Versions/3.9/bin/python3.9";
    NSString * arg = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"cpk_test.py"];
    NSString *logCmd = @"ps -ef |grep -i python |grep -i cpk_test.py |grep -v grep|awk '{print $2}' | xargs kill -9";
    system([logCmd UTF8String]); //
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:arg])
    {
        arg = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"cpk_test.pyc"];
        logCmd = @"ps -ef |grep -i python |grep -i cpk_test |grep -v grep|awk '{print $2}' | xargs kill -9";
        system([logCmd UTF8String]); 
    }
         
    [self execute_withTask:cmd withPython:arg];
    
}

-(void)Lanuch_correlation
{
    NSString * cmd = @"/Library/Frameworks/Python.framework/Versions/3.9/bin/python3.9";
    NSString * arg = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"correlation_test.py"];
    NSString *logCmd = @"ps -ef |grep -i python |grep -i correlation_test.py |grep -v grep|awk '{print $2}' |xargs kill -9";
    system([logCmd UTF8String]);  //
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:arg])
    {
        arg = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"correlation_test.pyc"];
        logCmd = @"ps -ef |grep -i python |grep -i correlation_test |grep -v grep|awk '{print $2}' |xargs kill -9";
        system([logCmd UTF8String]);  //
    }
    
    
    [self execute_withTask:cmd withPython:arg];
}

-(void)Lanuch_scatter
{
    NSString * cmd = @"/Library/Frameworks/Python.framework/Versions/3.9/bin/python3.9";
    NSString * arg = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"scatter_test.py"];
    NSString *logCmd = @"ps -ef |grep -i python |grep -i scatter_test.py |grep -v grep|awk '{print $2}' |xargs kill -9";
    system([logCmd UTF8String]);  //
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:arg])
    {
        arg = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"scatter_test.pyc"];
        logCmd = @"ps -ef |grep -i python |grep -i scatter_test |grep -v grep|awk '{print $2}' |xargs kill -9";
        system([logCmd UTF8String]);  //
    }
    
    
    [self execute_withTask:cmd withPython:arg];
}

-(void)Lanuch_calculate
{
    NSString * cmd = @"/Library/Frameworks/Python.framework/Versions/3.9/bin/python3.9";
    NSString * arg = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"calculate_test.py"];;
    NSString *logCmd = @"ps -ef |grep -i python |grep -i calculate_test.py |grep -v grep|awk '{print $2}' |xargs kill -9";
    system([logCmd UTF8String]);
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:arg])
    {
         arg = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"calculate_test.pyc"];;
         logCmd = @"ps -ef |grep -i python |grep -i calculate_test |grep -v grep|awk '{print $2}' |xargs kill -9";
        system([logCmd UTF8String]);
        
    }
    
    [self execute_withTask:cmd withPython:arg];
}

-(void)Lanuch_yield_rate
{
    NSString * cmd = @"/Library/Frameworks/Python.framework/Versions/3.9/bin/python3.9";
    NSString * arg = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"yield_rate_test.py"];;
    NSString *logCmd = @"ps -ef |grep -i python |grep -i yield_rate_test.py |grep -v grep|awk '{print $2}' |xargs kill -9";
    system([logCmd UTF8String]);
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:arg])
    {
         arg = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"yield_rate_test.pyc"];;
         logCmd = @"ps -ef |grep -i python |grep -i yield_rate_test |grep -v grep|awk '{print $2}' |xargs kill -9";
        system([logCmd UTF8String]);
        
    }
    
    [self execute_withTask:cmd withPython:arg];
    
}

-(void)Lanuch_excel_report
{
    NSString * cmd = @"/Library/Frameworks/Python.framework/Versions/3.9/bin/python3.9";
    NSString * arg = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"report_excel_test.py"];;
    NSString *logCmd = @"ps -ef |grep -i python |grep -i report_excel_test.py |grep -v grep|awk '{print $2}' |xargs kill -9";
    system([logCmd UTF8String]);
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:arg])
    {
        arg = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"report_excel_test.pyc"];;
        logCmd = @"ps -ef |grep -i python |grep -i report_excel_test |grep -v grep|awk '{print $2}' |xargs kill -9";
        system([logCmd UTF8String]);
        
    }
    
    [self execute_withTask:cmd withPython:arg];
}

-(void)Lanuch_hash_report
{
    NSString * cmd = @"/Library/Frameworks/Python.framework/Versions/3.9/bin/python3.9";
    NSString * arg = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"report_hash_test.py"];;
    NSString *logCmd = @"ps -ef |grep -i python |grep -i report_hash_test.py |grep -v grep|awk '{print $2}' |xargs kill -9";
    system([logCmd UTF8String]);
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:arg])
    {
        arg = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"report_hash_test.pyc"];;
        logCmd = @"ps -ef |grep -i python |grep -i report_hash_test |grep -v grep|awk '{print $2}' |xargs kill -9";
        system([logCmd UTF8String]);
        
    }
    
    [self execute_withTask:cmd withPython:arg];
    
}

-(void)Lanuch_keynote_report
{
    NSString * cmd = @"/Library/Frameworks/Python.framework/Versions/3.9/bin/python3.9";
    NSString * arg = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"report_keynote_test.py"];;
    NSString *logCmd = @"ps -ef |grep -i python |grep -i report_keynote_test.py |grep -v grep|awk '{print $2}' |xargs kill -9";
    system([logCmd UTF8String]);
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:arg])
    {
        arg = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"report_keynote_test.pyc"];;
        logCmd = @"ps -ef |grep -i python |grep -i report_keynote_test |grep -v grep|awk '{print $2}' |xargs kill -9";
        system([logCmd UTF8String]);
        
    }
    
    [self execute_withTask:cmd withPython:arg];
}


-(void)Lanuch_extra_func
{
    
    NSString * cmd = @"/Library/Frameworks/Python.framework/Versions/3.9/bin/python3.9";
    NSString * arg = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"extra_tiny_test.py"];;
    NSString *logCmd = @"ps -ef |grep -i python |grep -i extra_tiny_test.py |grep -v grep|awk '{print $2}' |xargs kill -9";
    system([logCmd UTF8String]);
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:arg])
    {
        arg = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"extra_tiny_test.pyc"];;
        logCmd = @"ps -ef |grep -i python |grep -i extra_tiny_test |grep -v grep|awk '{print $2}' |xargs kill -9";
        system([logCmd UTF8String]);  
        
    }
    
    [self execute_withTask:cmd withPython:arg];
    
}
-(void)Lanuch_retest_plot
{
    NSString * cmd = @"/Library/Frameworks/Python.framework/Versions/3.9/bin/python3.9";
    NSString * arg = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"retest_plot_test.py"];;
    NSString *logCmd = @"ps -ef |grep -i python |grep -i report_targs_test |grep -v grep|awk '{print $2}' |xargs kill -9";
    system([logCmd UTF8String]);
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:arg])
    {
        arg = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"retest_plot_test.pyc"];;
        logCmd = @"ps -ef |grep -i python |grep -i report_targs_test |grep -v grep|awk '{print $2}' |xargs kill -9";
        system([logCmd UTF8String]);
        
    }
    
    [self execute_withTask:cmd withPython:arg];
    
}
-(void)Lanuch_report_tags
{
    NSString * cmd = @"/Library/Frameworks/Python.framework/Versions/3.9/bin/python3.9";
    NSString * arg = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"report_targs_test.py"];;
    NSString *logCmd = @"ps -ef |grep -i python |grep -i report_targs_test |grep -v grep|awk '{print $2}' |xargs kill -9";
    system([logCmd UTF8String]);
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:arg])
    {
        arg = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"report_targs_test.pyc"];;
        logCmd = @"ps -ef |grep -i python |grep -i report_targs_test |grep -v grep|awk '{print $2}' |xargs kill -9";
        system([logCmd UTF8String]);
        
    }
    
    [self execute_withTask:cmd withPython:arg];
    
}

-(int)execute_withTask:(NSString*) szcmd withPython:(NSString *)arg
{
    if (!szcmd) return -1;
    NSTask * task = [[NSTask alloc] init];
    [task setLaunchPath:szcmd];
    [task setArguments:[NSArray arrayWithObjects:arg, nil]];
    [task launch];
    return 0;
}

-(void)ShutDown
{
    NSString *file_cli = [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"redis-cli"] stringByReplacingOccurrencesOfString:@" " withString:@"\\ "];
      file_cli = [file_cli stringByReplacingOccurrencesOfString:@"(" withString:@"\\("];
      file_cli = [file_cli stringByReplacingOccurrencesOfString:@")" withString:@"\\)"];
    NSString *cli_Path = [NSString stringWithFormat:@"%@ flushall",file_cli];
    for (int i=0; i<10; i++)
        system([cli_Path UTF8String]);
    
     NSString *cli_shutdown = [NSString stringWithFormat:@"%@ -p 6379 shutdown",file_cli];
     system([cli_shutdown UTF8String]);
    
    
    NSString *logCmd1 = @"ps -ef |grep -i python |grep -i correlation_test |grep -v grep|awk '{print $2}' |xargs kill -9";
    system([logCmd1 UTF8String]);
    
    NSString *logCmd2 = @"ps -ef |grep -i python |grep -i cpk_test |grep -v grep|awk '{print $2}' | xargs kill -9";
    system([logCmd2 UTF8String]);
    
    NSString *logCmd3 = @"ps -ef |grep -i python |grep -i calculate_test |grep -v grep|awk '{print $2}' |xargs kill -9";
    system([logCmd3 UTF8String]);
    
    NSString *logCmd4 = @"ps -ef |grep -i python |grep -i report_excel_test |grep -v grep|awk '{print $2}' |xargs kill -9";
    system([logCmd4 UTF8String]);
    
    NSString *logCmd5 = @"ps -ef |grep -i python |grep -i report_hash_test |grep -v grep|awk '{print $2}' |xargs kill -9";
    system([logCmd5 UTF8String]);
    
    NSString *logCmd6 = @"ps -ef |grep -i python |grep -i report_keynote_test |grep -v grep|awk '{print $2}' |xargs kill -9";
    system([logCmd6 UTF8String]);
    
    NSString *logCmd7 = @"ps -ef |grep -i python |grep -i yield_rate_test |grep -v grep|awk '{print $2}' |xargs kill -9";
    system([logCmd7 UTF8String]);  //
    
    NSString *logCmd8 = @"ps -ef |grep -i python |grep -i scatter_test |grep -v grep|awk '{print $2}' |xargs kill -9";
    system([logCmd8 UTF8String]);
    
    NSString *logCmd9 = @"ps -ef |grep -i python |grep -i extra_tiny_test |grep -v grep|awk '{print $2}' |xargs kill -9";
    system([logCmd9 UTF8String]);
    
    NSString *logCmd10 = @"ps -ef |grep -i python |grep -i report_targs_test |grep -v grep|awk '{print $2}' |xargs kill -9";
    system([logCmd10 UTF8String]);
    
    NSString *killRedis = @"ps -ef |grep -i redis-server |grep -v grep|awk '{print $2}' |xargs kill -9";
    system([killRedis UTF8String]);
    
}

@end
