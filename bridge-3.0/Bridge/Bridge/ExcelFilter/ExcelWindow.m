//
//  ExcelWindow.m
//  Bridge
//
//  Created by macbook on 2021/3/1.
//  Copyright © 2021 RyanGao. All rights reserved.
//

#import "ExcelWindow.h"
#import "../DataPlot/defineHeader.h"
@interface ExcelWindow ()

@end

@implementation ExcelWindow
- (IBAction)OnClearAllExcelFilter:(id)sender {
    NSArray*buttons = [listView arrangedSubviews];
    for (int i=1; i<[buttons count]; i++) {
        [buttons[i] setState:true];
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationFilterClearMsg object:nil userInfo:nil];
    [self close];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.keys = [[NSMutableDictionary alloc] init];
//    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:listView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:[listView superview] attribute:NSLayoutAttributeLeading multiplier:5.0f constant:5.f];
//    [[listView superview] addConstraint:constraint];
    
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

-(void)reloadKeys:(NSArray*) keys withIdentify:(NSString*) identify{
    
    for (NSButton* item in [listView arrangedSubviews]) {

        [item removeFromSuperview];
        
    }
    
    self.identify = identify;
    
    if ([identify isEqualToString:@"bmc"]) {
        //identify = [identify uppercaseString];
        [filterWindo setTitle:[identify uppercaseString]];
    }
    else{
        [filterWindo setTitle:self.identify];
    }
    
    
    [self.keys removeAllObjects];
    
  
    
    for (NSString* keyname in keys) {
        [self.keys setValue:[keys valueForKey:keyname]  forKey:keyname];
    }
    
    
    
    NSInteger size = [self.keys count];
    
    
    [[listView superview] setAutoresizesSubviews:true];
    
    CGRect supersize = [[[listView superview] superview] frame];
    [listView setFrame:NSMakeRect(0,supersize.size.height,supersize.size.width ,22*([self.keys count]+1))];
    [[listView superview] setFrame:NSMakeRect(0,0,supersize.size.width ,supersize.size.height + 22*([self.keys count]+1))];
    
    NSMutableArray* reviewKeys = [NSMutableArray arrayWithArray:[[self.keys allKeys] copy]];
    
    [reviewKeys insertObject:@"All Selected" atIndex:0];
    
    [self.keys setValue:@(YES) forKey:@"All Selected"];
    
    for (int i =0;i< [reviewKeys count];i++ ) {
        
        NSString * keyname = [NSString stringWithFormat:@"%@",reviewKeys[i]];
        
        NSButton *btn0 = [NSButton buttonWithTitle:keyname target:self action:@selector(TestSend:)];
        
        [btn0 setFrame:NSMakeRect(0,0,10,20)];
        
        [btn0 setButtonType:NSButtonTypeSwitch];
        
        
        [btn0 setState:([[self.keys valueForKey:keyname] isEqual:@(YES)] ?  true:false) ];
        
        [btn0 setTag:i];
        
        [listView addArrangedSubview:btn0];
   
        if (i==0) {
            if([[self.keys allKeysForObject:@(YES)] count] == [self.keys count]){
                [btn0  setState:true];
            }else{
                [btn0  setState:false];
            }
        }
    }
    
    
    
    //[vScroler scrollPoint:NSMakePoint(0, 0)];
    [cipView scrollPoint:NSMakePoint(0, supersize.size.height + 22*([self.keys count]+1))];
 
}


- (void)awakeFromNib{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnNotification:) name:kNotificationFilterMsg object:nil];
    
    [filterWindo setLevel:kCGFloatingWindowLevel];
    [filterWindo center];
    filterWindo.backgroundColor = [NSColor whiteColor];
    [filterWindo setAccessibilityFocused:YES];
    
    
}
-(void)TestSend:(id)sender{
    NSButton * ower = sender;
    
    NSArray* buttons = [[ower superview] subviews];

    NSMutableDictionary* stateDic = [[NSMutableDictionary alloc] init];
    
    if ([ower tag] == 0) {
        
        for (int i=1; i<[buttons count]; i++) {
            
            [buttons[i] setState:[ower  state]];
            
            [stateDic setValue:[ower  state] ? @(YES):@(NO) forKey:[buttons[i] title] ];
        }
    }
    else{
        
        for (int i=1; i<[buttons count]; i++) {
           
            [stateDic setValue:[buttons[i]  state] ? @(YES):@(NO) forKey:[buttons[i] title] ];
            
        }
        
        if([[stateDic allKeysForObject:@(YES)] count] == [stateDic count]){
            [buttons[0]  setState:true];
        }else{
            [buttons[0]  setState:false];
        }
        
        
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationFilterMsg object:nil userInfo:@{@"identifier":self.identify,@"keys":stateDic}];

    
}
- (void)OnNotification:(NSNotification *)nf
{
//    NSString * name = [nf name];
//    if([name isEqualToString:kNotificationFilterMsg])
//    {
//        [self performSelectorOnMainThread:@selector(UpdateLog:) withObject:[nf userInfo] waitUntilDone:YES];
//        [[NSRunLoop currentRunLoop]runMode:NSDefaultRunLoopMode beforeDate:[NSDate date]];
//    }
}

@end
