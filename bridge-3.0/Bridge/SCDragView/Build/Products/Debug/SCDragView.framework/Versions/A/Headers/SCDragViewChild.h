//
//  SCDragViewChild.h
//  exchangeExport
//
//

#import <Cocoa/Cocoa.h>


@class SCDragView;

@interface SCDragViewChild : NSView {
    BOOL dragging;
}

@property (strong) id userObject;
@property (strong) SCDragView* parentView;
@property (assign, nonatomic) NSInteger positionIndex;
@property (assign) NSInteger currentPos;

@end
