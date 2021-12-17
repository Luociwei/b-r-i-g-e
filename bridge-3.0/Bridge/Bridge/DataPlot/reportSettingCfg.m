//
//  reportSettingCfg.m
//  BDR_Tool
//
//  Created by RyanGao on 2020/7/5.
//  Copyright © 2020 RyanGao. All rights reserved.
//

#import "reportSettingCfg.h"
#import "defineHeader.h"
extern NSMutableDictionary *m_configDictionary;

@interface reportSettingCfg ()

@end

@implementation reportSettingCfg

-(void)initAllCtl
{
    
    
    [_buttonOK setEnabled:NO];
    [_lowTH setStringValue:@"1.5"];
    [_lowTH setEnabled:NO];
    [_highTH setStringValue:@"9999999.0"];
    [_highTH setEnabled:NO];
    
    [m_configDictionary setValue:@"1" forKey:kexportAllItems];
    [_exportAllItems setState:NSControlStateValueOn];
    [m_configDictionary setValue:@"0" forKey:kexportPassItems];
    [_exportAllItemsOutOf setState:NSControlStateValueOff];
    [m_configDictionary setValue:@"0" forKey:konlyLimitUpdated];
    [_onlyLimitUpdated setState:NSControlStateValueOff];
    
    
    [m_configDictionary setValue:@"1.5" forKey:kcpkLowThd];
    [m_configDictionary setValue:@"9999999.0" forKey:kcpkHighThd];
    
    [m_configDictionary setValue:@"0" forKey:kpopulateDistri];
    [self.populate setState:NSControlStateValueOff];
    [m_configDictionary setValue:@"0" forKey:kp_val_status];
    [self.p_val_Check setState:NSControlStateValueOff];
    [m_configDictionary setValue:@"" forKey:kuserName];
    [self.userName setStringValue:@""];
    [m_configDictionary setValue:@"" forKey:kprojectName];
    [self.projectName setStringValue:@""];
    [m_configDictionary setValue:@"" forKey:ktargetBuild];
    [self.TargetBuild setStringValue:@""];
    
    [_push2Git setState:0];
    [_gitAddress setEnabled:NO];
    [_gitComment setEnabled:NO];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    [_settingCfgWin setLevel:kCGFloatingWindowLevel];
    
    [self initAllCtl];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}
- (IBAction)btnOK:(id)sender
{
    NSString *low = [self.lowTH stringValue];
    NSString *high = [self.highTH stringValue];
    if (([self isPureInt:low] || [self isPureFloat:low]) && ([self isPureInt:high] || [self isPureFloat:high]))
    {
        float lowV = [low floatValue];
        float highV = [high floatValue];
        if (lowV>highV)
        {
            [self AlertBox:@"Error:024" withInfo:@"CPK high threshold should be bigger than CPK low threshold!"];
            return;
        }
        
        [m_configDictionary setValue:low forKey:kcpkLowThd];
        [m_configDictionary setValue:high forKey:kcpkHighThd];
        [m_configDictionary setValue:self.userName.stringValue forKey:kuserName];
        [m_configDictionary setValue:self.projectName.stringValue forKey:kprojectName];
        [m_configDictionary setValue:self.TargetBuild.stringValue forKey:ktargetBuild];
        
        int push2git_checkBox = (int)[self.push2Git state];
        [m_configDictionary setValue:[NSNumber numberWithInt:push2git_checkBox] forKey:kpush2GitHub];
        [m_configDictionary setValue:self.gitAddress.stringValue forKey:kgitWebAddr];
        [m_configDictionary setValue:self.gitComment.stringValue forKey:kgitComment];
        
        [NSApp stopModalWithCode:NSModalResponseOK];
        [[sender window] orderOut:self];
    }
    else
    {
        [self AlertBox:@"Error:016" withInfo:@"Please input a number."];
    }
    

    
}

-(void)AlertBox:(NSString *)msgTxt withInfo:(NSString *)strmsg
{
    NSAlert * alert = [[NSAlert alloc] init];
    alert.messageText = msgTxt;
    alert.informativeText = strmsg;
    [alert runModal];
}

- (IBAction)btnCancel:(id)sender
{
    [self initAllCtl];
    [NSApp stopModalWithCode:NSModalResponseCancel];
    [[sender window] orderOut:self];
}

- (IBAction)click_p_val:(id)sender
{
    [m_configDictionary setValue:[NSString stringWithFormat:@"%zd",[_p_val_Check state]] forKey:kp_val_status];
}

- (IBAction)clickPopulate:(id)sender
{
    [self AlertBox:@"Warning" withInfo:@"It will take long time and just for debug use when select this."];
    [self.populate setState:0];
    [m_configDictionary setValue:[NSString stringWithFormat:@"%zd",[_populate state]] forKey:kpopulateDistri];
}


- (IBAction)clickAllItemsOutOf:(id)sender
{
    [_exportAllItems setState:NSControlStateValueOff];
    [_exportAllItemsOutOf setState:NSControlStateValueOn];
    [_onlyLimitUpdated setState:NSControlStateValueOff];
    //NSLog(@"======1=>>> %zd",[_exportAllItems state]);
   // NSLog(@"======1=>>> %zd",[_exportAllItemsOutOf state]);
    [m_configDictionary setValue:[NSString stringWithFormat:@"%zd",[_exportAllItems state]] forKey:kexportAllItems];
    [m_configDictionary setValue:[NSString stringWithFormat:@"%zd",[_exportAllItemsOutOf state]] forKey:kexportPassItems];
    [m_configDictionary setValue:[NSString stringWithFormat:@"%zd",[_onlyLimitUpdated state]] forKey:konlyLimitUpdated];
    
    [_lowTH setEnabled:[_exportAllItemsOutOf state]];
    [_highTH setEnabled:[_exportAllItemsOutOf state]];
    
}

- (IBAction)clickAllItems:(id)sender
{
    [_exportAllItems setState:NSControlStateValueOn];
    [_exportAllItemsOutOf setState:NSControlStateValueOff];
    [_onlyLimitUpdated setState:NSControlStateValueOff];
   // NSLog(@"======2=>>> %zd",[_exportAllItems state]);
    //NSLog(@"======2=>>> %zd",[_exportAllItemsOutOf state]);
    [m_configDictionary setValue:[NSString stringWithFormat:@"%zd",[_exportAllItems state]] forKey:kexportAllItems];
    [m_configDictionary setValue:[NSString stringWithFormat:@"%zd",[_exportAllItemsOutOf state]] forKey:kexportPassItems];
    [m_configDictionary setValue:[NSString stringWithFormat:@"%zd",[_onlyLimitUpdated state]] forKey:konlyLimitUpdated];
    
    [_lowTH setEnabled:[_exportAllItemsOutOf state]];
    [_highTH setEnabled:[_exportAllItemsOutOf state]];
    
}

-(void)controlTextDidChange:(NSNotification *)obj
{
    //NSLog(@"---->>>controlTextDidChange");
    if (self.userName.stringValue.length &&self.projectName.stringValue.length&&self.TargetBuild.stringValue.length)
    {
        self.buttonOK.enabled = YES;
    }
    else
    {
        self.buttonOK.enabled = NO;
    }
}

-(BOOL)isPureInt:(NSString *)string
{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

-(BOOL)isPureFloat:(NSString *)string
{
    NSScanner* scan = [NSScanner scannerWithString:string];
    float val;
    return [scan scanFloat:&val] && [scan isAtEnd];
}

- (IBAction)clickPush2Git:(id)sender
{
    [self AlertBox:@"Warning" withInfo:@"Git function is under development!!! "];
    [self.push2Git setState:0];
    // int check = (int)[sender state];
    //[_gitAddress setEnabled:check];
    //[_gitComment setEnabled:check];
    
}
- (IBAction)btActionDefault:(id)sender
{
    [self initAllCtl];
}
- (IBAction)ClickOnlyLimitUpdate:(id)sender
{
    [_exportAllItems setState:NSControlStateValueOff];
    [_exportAllItemsOutOf setState:NSControlStateValueOff];
    [_onlyLimitUpdated setState:NSControlStateValueOn];
    [m_configDictionary setValue:[NSString stringWithFormat:@"%zd",[_exportAllItems state]] forKey:kexportAllItems];
    [m_configDictionary setValue:[NSString stringWithFormat:@"%zd",[_exportAllItemsOutOf state]] forKey:kexportPassItems];
    [m_configDictionary setValue:[NSString stringWithFormat:@"%zd",[_onlyLimitUpdated state]] forKey:konlyLimitUpdated];
}
@end
