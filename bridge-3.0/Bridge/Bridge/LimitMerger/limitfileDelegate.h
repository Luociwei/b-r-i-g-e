//
//  limitfileDelegate.h
//  Bridge
//
//  Created by vito xie on 2021/5/20.
//  Copyright © 2021 RyanGao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface limitfileDelegate : NSViewController<NSTableViewDataSource, NSTableViewDelegate>{
    NSMutableArray* data;
    NSTableView* view1;
}
- (instancetype)initWithView:(NSTableView*)view;
-(void)setData:(NSArray*)data;
-(bool)isDataLoaded;

-(void)setRedData:(NSArray*)Indata withYellowData:(NSArray*) yellowData withGreenData:(NSArray*) greenData withGrayData:(NSArray*) grayData;
-(NSArray*)getData;
@end

NS_ASSUME_NONNULL_END
