

#import "NSPopover+Message.h"


@interface COICOPopoverView : NSView {
    NSColor *backgroundColour;
}

@property (nonatomic, retain) NSColor *backgroundColour;

@end


@implementation COICOPopoverView

@synthesize backgroundColour;

- (void)drawRect:(NSRect)aRect {
    if (self.backgroundColour == nil) {
        [self setBackgroundColour:[NSColor controlBackgroundColor]];
    }
    
    NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:backgroundColour
                                                         endingColor:[NSColor controlBackgroundColor]];
    
    NSRect drawingRect = [self frame];
    drawingRect.origin.x = 0;
    drawingRect.origin.y = 0;
    
    NSBezierPath *border = [NSBezierPath bezierPathWithRoundedRect:drawingRect
                                                           xRadius:5.0
                                                           yRadius:5.0];
    [gradient drawInBezierPath:border angle:270.0];
    
    [super drawRect:aRect];
}

@end

@implementation NSPopover (Message)

+ (void) showRelativeToRect:(NSRect)rect
                     ofView:(NSView *)view
              preferredEdge:(NSRectEdge)edge
                     string:(NSString *)string
                   maxWidth:(float)width {
    
    [NSPopover showRelativeToRect:rect
                           ofView:view
                    preferredEdge:edge
                           string:string
                  backgroundColor:[NSColor systemYellowColor] //[NSColor controlBackgroundColor]
                         maxWidth:width];
}

+ (void) showRelativeToRect:(NSRect)rect
                     ofView:(NSView *)view
              preferredEdge:(NSRectEdge)edge
                     string:(NSString *)string
            backgroundColor:(NSColor *)backgroundColor
                   maxWidth:(float)width {
    
    [NSPopover showRelativeToRect:rect
                           ofView:view
                    preferredEdge:edge
                           string:string
                  backgroundColor:backgroundColor
                  foregroundColor:[NSColor systemBlueColor]    //[NSColor controlTextColor]
                             font:[NSFont fontWithName:@"Arial Italic" size:12]    //[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]
                         maxWidth:width];
}

+ (void) showRelativeToRect:(NSRect)rect
                     ofView:(NSView *)view
              preferredEdge:(NSRectEdge)edge
                     string:(NSString *)string
            backgroundColor:(NSColor *)backgroundColor
            foregroundColor:(NSColor *)foregroundColor
                       font:(NSFont *)font
                   maxWidth:(float)width {
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string
                                                                                         attributes:@{
                                                                                NSFontAttributeName: font,
                                                                     NSForegroundColorAttributeName: foregroundColor }];
    
    [NSPopover showRelativeToRect:rect
                           ofView:view
                    preferredEdge:edge
                 attributedString:attributedString
                  backgroundColor:backgroundColor
                         maxWidth:width];
}

+ (void) showRelativeToRect:(NSRect)rect
                     ofView:(NSView *)view
              preferredEdge:(NSRectEdge)edge
           attributedString:(NSAttributedString *)attributedString
            backgroundColor:(NSColor *)backgroundColor
                   maxWidth:(float)width {
    
    float padding = 15;
    
    NSRect containerRect = [attributedString boundingRectWithSize:NSMakeSize(width, 0)
                                                          options:NSStringDrawingUsesLineFragmentOrigin];
    containerRect.size.width = containerRect.size.width *= (25/(containerRect.size.width+2)+1);
    
    NSSize size = containerRect.size;
    NSSize popoverSize = NSMakeSize(containerRect.size.width + (padding * 2), containerRect.size.height + (padding * 2));
    
    containerRect = NSMakeRect(0, 0, popoverSize.width, popoverSize.height);
    
#if __has_feature(objc_arc)
    NSTextField *label = [[NSTextField alloc] initWithFrame:NSMakeRect(padding, padding, size.width, size.height)];
#else
    NSTextField *label = [[[NSTextField alloc] initWithFrame:NSMakeRect(padding, padding, size.width, size.height)] retain];
#endif

    
    [label setBezeled:NO];
    [label setDrawsBackground:NO];
    [label setEditable:NO];
    [label setSelectable:NO];
    [label setAttributedStringValue:attributedString];
    [[label cell] setLineBreakMode:NSLineBreakByWordWrapping];

#if __has_feature(objc_arc)
    COICOPopoverView *container = [[COICOPopoverView alloc] initWithFrame:containerRect];
#else
    COICOPopoverView *container = [[[COICOPopoverView alloc] initWithFrame:containerRect] retain];
#endif
    
    [container setBackgroundColour:backgroundColor];
    [container addSubview:label];
    [label setBounds:NSMakeRect(padding, padding, size.width, size.height)];
    [container awakeFromNib];
    
#if __has_feature(objc_arc)
    NSViewController *controller = [[NSViewController alloc] init];
#else
    NSViewController *controller = [[[NSViewController alloc] init] retain];
#endif
    [controller setView:container];
    
#if __has_feature(objc_arc)
    NSPopover *popover = [[NSPopover alloc] init];
#else
    NSPopover *popover = [[[NSPopover alloc] init] retain];
#endif
    [popover setContentSize:popoverSize];
    [popover setContentViewController:controller];
    [popover setAnimates:YES];
    [popover setBehavior:NSPopoverBehaviorSemitransient];
    [popover showRelativeToRect:rect
                         ofView:view
                  preferredEdge:edge];
#if !__has_feature(objc_arc)
    [popover release];
    [controller release];
    [container release];
    [label release];
#endif
}

+(void)closeRelativeToRect:(NSRect)rect
                    ofView:(NSView *)view
             preferredEdge:(NSRectEdge)edge
                    string:(NSString *)string
                  maxWidth:(float)width
{

    float padding = 0;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string
                                                                                         attributes:@{
                                                                                NSFontAttributeName: [NSFont systemFontOfSize:[NSFont smallSystemFontSize]],
                                                                     NSForegroundColorAttributeName: [NSFont systemFontOfSize:[NSFont smallSystemFontSize]] }];
    
    NSRect containerRect = [attributedString boundingRectWithSize:NSMakeSize(width, 0)
                                                          options:NSStringDrawingUsesLineFragmentOrigin];
    containerRect.size.width = containerRect.size.width *= (25/(containerRect.size.width+2)+1);
    
    NSSize size = containerRect.size;
    NSSize popoverSize = NSMakeSize(containerRect.size.width + (padding * 2), containerRect.size.height + (padding * 2));
    
    containerRect = NSMakeRect(0, 0, popoverSize.width, popoverSize.height);
    
#if __has_feature(objc_arc)
    NSTextField *label = [[NSTextField alloc] initWithFrame:NSMakeRect(padding, padding, size.width, size.height)];
#else
    NSTextField *label = [[[NSTextField alloc] initWithFrame:NSMakeRect(padding, padding, size.width, size.height)] retain];
#endif

    
    [label setBezeled:NO];
    [label setDrawsBackground:NO];
    [label setEditable:NO];
    [label setSelectable:NO];
    [label setAttributedStringValue:attributedString];
    [[label cell] setLineBreakMode:NSLineBreakByWordWrapping];

#if __has_feature(objc_arc)
    COICOPopoverView *container = [[COICOPopoverView alloc] initWithFrame:containerRect];
#else
    COICOPopoverView *container = [[[COICOPopoverView alloc] initWithFrame:containerRect] retain];
#endif
    
    [container setBackgroundColour:[NSColor systemYellowColor]] ;//[NSColor controlTextColor]];
    [container addSubview:label];
    [label setBounds:NSMakeRect(padding, padding, size.width, size.height)];
    [container awakeFromNib];
    
#if __has_feature(objc_arc)
    NSViewController *controller = [[NSViewController alloc] init];
#else
    NSViewController *controller = [[[NSViewController alloc] init] retain];
#endif
    [controller setView:container];
    
#if __has_feature(objc_arc)
    NSPopover *popover = [[NSPopover alloc] init];
#else
    NSPopover *popover = [[[NSPopover alloc] init] retain];
#endif
    [popover setContentSize:popoverSize];
    [popover setContentViewController:controller];
    [popover setAnimates:NO];
    [popover setBehavior:NSPopoverBehaviorSemitransient];
    [popover showRelativeToRect:rect
                         ofView:view
                  preferredEdge:edge];
    [popover close];
    
#if !__has_feature(objc_arc)
    [popover release];
    [controller release];
    [container release];
    [label release];
#endif
}

@end
