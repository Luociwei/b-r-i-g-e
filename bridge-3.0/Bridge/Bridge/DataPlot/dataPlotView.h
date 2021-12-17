//
//  dataPlotView.h
//  CPK_Test
//
//  Created by RyanGao on 2020/6/25.
//  Copyright © 2020 RyanGao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <stdio.h>
#import <stdlib.h>
#import "SCImageView.framework/Headers/ZRRImageClipView.h"
#import "SCDragView.framework/Headers/SCDragViewChild.h"
#import "SCDragView.framework/Headers/SCDragView.h"
#import "StartUp.framework/Headers/StartUp.h"

NS_ASSUME_NONNULL_BEGIN

@interface dataPlotView : NSViewController<NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate>
{
    StartUp * startPython;
}

@property (weak) IBOutlet NSTableView *colorByTableView;
@property (weak) IBOutlet NSComboBox *colorByBox;
- (IBAction)selectColorByBoxAction:(id)sender;
@property (weak) IBOutlet NSTableView *colorByTableView2;
@property (weak) IBOutlet NSComboBox *colorByBox2;
- (IBAction)selectColorByBoxAction2:(id)sender;

@property (weak) IBOutlet NSImageView *cpkBoxView;

@property (weak) IBOutlet NSImageView *cpkImageView;
@property (weak) IBOutlet NSImageView *correlationImageView;

@property (weak) IBOutlet NSSegmentedControl *retestSegment;
- (IBAction)clickRetestSegmentAction:(id)sender;

@property (weak) IBOutlet NSSegmentedControl *removeFailSegment;
- (IBAction)clickRemoveFailSegmentAction:(id)sender;
- (IBAction)btnShowData:(id)sender;
- (IBAction)clickZoomType:(id)sender;
@property (weak) IBOutlet NSSegmentedControl *zoomTypeSeg;
@property (weak) IBOutlet NSSegmentedControl *plotTypeSeg;

@property (weak) IBOutlet NSTextField *txtBins;
- (IBAction)setTxtBinsValue:(id)sender;

- (IBAction)btnSelectX:(id)sender;
- (IBAction)btnSelectY:(id)sender;
@property (weak) IBOutlet NSButton *buttonShowYield;
- (IBAction)btnShowYield:(id)sender;

- (IBAction)btnReport:(id)sender;  //keynote
- (IBAction)btnReportExcel:(id)sender;
@property (strong) IBOutlet NSView *customerMainView;
@property (strong) IBOutlet NSScrollView *scrollViewLeft;
@property (strong) IBOutlet NSScrollView *scrollViewRight;
@property (strong) IBOutlet ZRRImageClipView *clipViewLeft;
@property (strong) IBOutlet ZRRImageClipView *clipViewRight;
@property (strong) IBOutlet ZRRImageClipView *clipViewScatter;

@property (strong) IBOutlet NSImageView *scatterImageMapView;

@property (weak) IBOutlet NSView *customerViewL;
@property (weak) IBOutlet NSSlider *sliderL;
- (IBAction)sliderActionL:(id)sender;
@property (weak) IBOutlet NSView *customerViewR;
@property (weak) IBOutlet NSSlider *sliderR;
- (IBAction)sliderActionR:(id)sender;
@property (weak) IBOutlet NSProgressIndicator *progressExcel;


@property (weak) IBOutlet NSProgressIndicator *progressKeynote;


@property (weak) IBOutlet NSButton *btn_report_excel;
@property (weak) IBOutlet NSButton *btn_report_keynote;

@property (strong) IBOutlet NSButton *cpkSaveButton;
@property (strong) IBOutlet NSButton *correlationSaveButton;
@property (strong) IBOutlet NSButton *scatterSaveButton;

- (IBAction)clickSaveButton:(NSButton *)sender;

@property (strong) IBOutlet NSTextField *rangeLsl;
@property (strong) IBOutlet NSTextField *rangeUsl;
@property (strong) IBOutlet NSTextField *rangeTxtLsl;
@property (strong) IBOutlet NSTextField *rangeTxtUsl;
- (IBAction)btCorrelationScatterPlot:(id)sender;


@property (weak) IBOutlet NSSplitView *SpliterBox;

- (IBAction)btTxtLsl:(NSTextField *)sender;
- (IBAction)btTxtUsl:(NSTextField *)sender;

- (IBAction)fitTpScreenActionLeft:(id)sender;
- (IBAction)zoomOutActionLeft:(id)sender;
- (IBAction)zoomInActionLeft:(id)sender;
@property (strong) IBOutlet NSButton *sliderScatter;
- (IBAction)clickSliderScatter:(id)sender;
@property (strong) IBOutlet NSScrollView *scatterScrollView;
- (IBAction)fittoScreenActionScatter:(id)sender;


- (IBAction)fitToScreenActionRight:(id)sender;
- (IBAction)zoomOutActionRight:(id)sender;
- (IBAction)zoomInActionRight:(id)sender;
- (IBAction)clickReportTags:(id)sender;

@property (weak) IBOutlet NSView *cpkViewWin;
@property (weak) IBOutlet NSView *correlationViewWin;
@property (weak) IBOutlet NSView *scatterViewWin;
@property (weak) IBOutlet NSSplitView *splitPlotView;
@property (weak) IBOutlet NSView *settingViewWin;
@property (weak) IBOutlet NSView *filter1ViewWin;
@property (weak) IBOutlet NSView *filter2ViewWin;
@property (strong) IBOutlet NSButton *cpkFitScreen;
@property (strong) IBOutlet NSButton *correlationFitScreen;
@property (strong) IBOutlet NSButton *scatterFitScreen;
@property (weak) IBOutlet NSButton *checkPDF;
- (IBAction)checkActionPDF:(id)sender;
@property (weak) IBOutlet NSButton *checkCDF;
- (IBAction)checkActionCDF:(id)sender;
@property (strong) IBOutlet NSButton *btnReportTags;
@property (strong) IBOutlet NSView *btnSettingView;


@property (weak) IBOutlet NSButton *btActionTest;
- (IBAction)bt_Test:(id)sender;

@end

NS_ASSUME_NONNULL_END
