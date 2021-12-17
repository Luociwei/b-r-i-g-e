//
//  testPlanSource.m
//  Bridge
//
//  Created by vito xie on 2021/5/22.
//  Copyright © 2021 RyanGao. All rights reserved.
//
#import "defineHeader.h"
#import "testPlanSource.h"

@implementation testPlanSource{
    
    NSString* nameType;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo >)sender
 
{
    [self lockFocusIfCanDraw];
    

    return NSDragOperationLink;
 
}
 
-(void)isProfile:(bool)flag{
    
    if (flag) {
        nameType = @"profile";
    }else{
        nameType = @"limit";
    }
}


- (BOOL)prepareForDragOperation:(id <NSDraggingInfo >)sender
 
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"focus" object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationLimitMergerShowUp object:nil userInfo:nil];
    return YES;
 
}
 
-(void)AlertBox:(NSString *)msgTxt withInfo:(NSString *)strmsg
{
    NSAlert * alert = [[NSAlert alloc] init];
    alert.messageText = msgTxt;
    alert.informativeText = strmsg;
    [alert runModal];
}
 
- (BOOL)performDragOperation:(id <NSDraggingInfo >)sender
 
{
 
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
    
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
    
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
        
        
       
        if ([files count] ==1) {
            NSString * profileFile =files[0];
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"LoadMsg" object:nil userInfo:@{@"type":nameType,@"file":profileFile}];

        }
        else{
            [self AlertBox:@"Profile Error" withInfo:@"Please Drag a Profile !!!!"];
            
        }

    }
    return YES;
 
}

@end
