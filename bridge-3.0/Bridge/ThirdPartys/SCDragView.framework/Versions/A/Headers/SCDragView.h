//
//  SCDragView.h
//  exchangeExport
//
//

#import <Cocoa/Cocoa.h>
#import "SCDragViewChild.h"

@interface SCDragView : NSView

-(NSSize)gridSize;
-(NSSize)minViewSize;
-(NSInteger)numberOfColumns;
-(NSInteger)numberOfRows;

-(void)addChildView:(SCDragViewChild*)childView;
-(void)removeChildView:(SCDragViewChild*)childView;
-(void)arrangeToGrid;

-(NSArray*)sortedChilds;
-(NSArray*)sortedUserObjects;

-(void)startDragForView:(SCDragViewChild*)childView;
-(void)stopDragForView:(SCDragViewChild*)childView;

-(NSPoint)pointForChild:(SCDragViewChild*)child andPos:(NSInteger)indexpos;
-(NSInteger)positionIndexForPoint:(NSPoint)point;

-(void)updateDragPos:(NSPoint)dragPoint;

-(id)childWithUserObject:(id)userObject;

-(void)removeAllChilds;

@property (readonly) BOOL isDragging;
@end
