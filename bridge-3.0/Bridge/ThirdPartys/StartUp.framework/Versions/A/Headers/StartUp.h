//
//  StartUpInfor.h
//  GUI
//
//  Created by Ryan on 8/27/15.
//  Copyright (c) 2015 ___sc Automation___. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma once
@interface StartUp : NSObject

-(BOOL)OpenRedisServer;
-(void)Lanuch_limit_merge;

-(void)Lanuch_atlas_report;
-(void)Lanuch_box;
-(void)Lanuch_cpk;
-(void)Lanuch_correlation;
-(void)Lanuch_scatter;
-(void)Lanuch_calculate;
-(void)Lanuch_yield_rate;
-(void)Lanuch_excel_report;
-(void)Lanuch_hash_report;
-(void)Lanuch_keynote_report;
-(void)Lanuch_extra_func;
-(void)Lanuch_report_tags;
-(void)Lanuch_retest_plot;
-(void)ShutDown;

@end


