//
//  cAtlas2Funcs.h
//  Bridge
//
//  Created by vito xie on 2021/9/2.
//  Copyright © 2021 RyanGao. All rights reserved.
//

#import <Cocoa/Cocoa.h>


NS_ASSUME_NONNULL_BEGIN

@interface cAtlas2Funcs : NSWindowController{
    
    NSString * folder ;
}
@property (strong) IBOutlet NSWindow *atlas2window;

-(void)initZmqConnect;
-(void)reset;
@end

NS_ASSUME_NONNULL_END
