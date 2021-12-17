//
//  Login.m
//  Bridge
//
//  Created by vito xie on 2021/5/28.
//  Copyright © 2021 RyanGao. All rights reserved.
//

#import "Login.h"

@interface Login ()

@end

@implementation Login{
    
    __weak IBOutlet NSTextField *username;
    __weak IBOutlet NSTextField *lable;
    __weak IBOutlet NSSecureTextField *passInput;
    NSString * name;
    NSString * password;
    bool isLoginFlag;
    
    
    NSString * nextMsg;
}

-(void) setNextShowMessage:(NSString*) name{
    
    nextMsg = [NSString stringWithFormat:@"%@",name];
}
-(bool) isLogin{
    
    return isLoginFlag;
}
- (void)windowDidLoad {
    [super windowDidLoad];
    isLoginFlag = false;
    
    if (isLoginFlag) {
        [lable setTextColor:[NSColor systemGreenColor]];
        lable.stringValue = @"Login Success !!";
    }
    else{
        [lable setTextColor:[NSColor systemRedColor]];
        lable.stringValue = @"Please login !!!";
    }
    username.stringValue = @"admin";
    
    [username setEditable:NO];
    
    
    
    
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)InputUser:(id)sender {
    NSTextField * textinput = sender;
    name = [username stringValue];
}
- (IBAction)InputPassword:(id)sender {
    
    [self doLogin:sender];
}

- (IBAction)doLogin:(id)sender {
    password = [passInput stringValue];
    if([password isEqualToString:@"admin"]){
        isLoginFlag = true;

    }
    else{
        
        
        isLoginFlag = false;
    }
    
    if (isLoginFlag) {
        [lable setTextColor:[NSColor systemGreenColor]];
        lable.stringValue = @"Login Success";
        [self.window close];
        [[NSNotificationCenter defaultCenter]postNotificationName:nextMsg object:nil userInfo:nil];
        
        [passInput setStringValue:@""];
        isLoginFlag = false;
        
        nextMsg = nil;
        lable.stringValue = @"Please login";
        
    }
    else{
        [lable setTextColor:[NSColor systemRedColor]];
        lable.stringValue = @"Please login";
    }
    
}



@end
