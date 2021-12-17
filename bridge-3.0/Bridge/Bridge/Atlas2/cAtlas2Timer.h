//
//  cAtlas2Timer.h
//  Bridge
//
//  Created by vito xie on 2021/9/3.
//  Copyright © 2021 RyanGao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface cAtlas2Timer : NSWindowController{
    
    NSString * folder ;
}
@property (weak) IBOutlet NSTableView *tmtableView;
-(void)reset;
@end

NS_ASSUME_NONNULL_END
