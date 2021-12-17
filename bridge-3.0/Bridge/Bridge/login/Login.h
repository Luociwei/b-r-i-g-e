//
//  Login.h
//  Bridge
//
//  Created by vito xie on 2021/5/28.
//  Copyright © 2021 RyanGao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface Login : NSWindowController
-(bool) isLogin;
-(void) setNextShowMessage:(NSString*) name;
@end

NS_ASSUME_NONNULL_END
