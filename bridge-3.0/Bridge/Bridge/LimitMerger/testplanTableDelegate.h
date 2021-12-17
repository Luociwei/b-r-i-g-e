//
//  testplanTableDelegate.h
//  Bridge
//
//  Created by vito xie on 2021/5/20.
//  Copyright © 2021 RyanGao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface testplanTableDelegate :NSObject <NSTableViewDataSource, NSTableViewDelegate>{
    
    NSMutableArray* data;
    NSMutableArray* showdata;
    NSTableView* view;
}
- (instancetype)initWithView:(NSTableView*)view;
-(void)reset;
-(void)setData:(NSArray*)Indata withGreen:(NSArray*)Greendata withRed:(NSArray*)Reddata withGray:(NSArray*)Graydata withYellow:(NSArray*)Yellowdata withLimitData:(NSArray*)Limitdata;

-(void)setDataSingle:(NSArray*)Indata ;
-(void)setDataSingleInfo:(NSArray*)Greendata withYellow:(NSArray*)Yellowdata withGray:(NSArray*)Graydata  withLimitData:(NSArray*)Limitdata  withRed:(NSArray*)Reddata;
-(void)clickedRow;

-(NSString*) generateModifyInfo;
-(bool)Modify;
-(bool)ModifyAll;
-(bool)UnSyncLastStep;

-(bool)isDataLoaded;

-(NSArray*)getData;


- (void)showGreen;
- (void)showYellow;
- (void)showRedAndGray;
- (void)showAll;



@end


NS_ASSUME_NONNULL_END
