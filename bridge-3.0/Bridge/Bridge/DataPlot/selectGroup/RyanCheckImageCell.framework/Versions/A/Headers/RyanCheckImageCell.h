
#import <Cocoa/Cocoa.h>

@interface RyanCheckImageCell : NSButtonCell
{
    BOOL isChecked;
    NSImage* checkTetstImage[2];
    NSImage* checkGroupImage[2];
    int x_pos;
}

@property (readwrite,assign) BOOL isChecked;
-(void)setXpos:(int)x;

@end



@protocol EntryIndexProtocol
-(NSArray *)getEntryIndex;
-(void)setEntryIndex:(NSArray *)aEntryIndex;
@end


@protocol IconClickProtocol
-(void)iconCilcked:(id)sender;
@end

@interface GroupEntry : NSObject <EntryIndexProtocol>
@property (readwrite,copy) NSString *name;
@property (readwrite,copy) NSString *nameGroup;
@property (readwrite,copy) NSString *csvLine;

@property (readwrite,copy) NSMutableArray *strArray;
@property (readwrite,assign) bool isExpand;

@property (readwrite,copy) NSString *iD;
@property (readwrite,copy) NSString *name_flag;
@property (readwrite,copy) NSString *name_flag2;
@property (readwrite,copy) NSString *name_flag3;
@property (readwrite,assign) bool isChecked;
@property (readwrite,copy) NSColor *textColor;
//@property (nonatomic) NSArray *entryIndex;
@end

@interface SubNameEntry : NSObject <EntryIndexProtocol>
@property (readwrite,copy) NSString *name;
@property (readwrite,copy) NSString *nameGroup;
@property (readwrite,copy) NSString *csvLine;

@property (readwrite,copy) NSMutableArray *strArray;
@property (readwrite,assign) bool isExpand;

@property (readwrite,copy) NSString *iD;
@property (readwrite,copy) NSString *name_flag;
@property (readwrite,copy) NSString *name_flag2;
@property (readwrite,copy) NSString *name_flag3;
@property (readwrite,assign) bool isChecked;
@property (readwrite,copy) NSColor *textColor;
//@property (nonatomic) NSArray *entryIndex;
@end

@interface SubSubNameEntry : NSObject <EntryIndexProtocol>
@property (readwrite,copy) NSString *name;
@property (readwrite,copy) NSString *nameGroup;
@property (readwrite,copy) NSString *csvLine;

@property (readwrite,copy) NSString *iD;
@property (readwrite,copy) NSString *name_flag;
@property (readwrite,copy) NSString *name_flag2;
@property (readwrite,copy) NSString *name_flag3;
@property (readwrite,assign) bool isChecked;
@property (readwrite,copy) NSColor *textColor;
//@property (nonatomic) NSArray *entryIndex;
@end

@interface BlockImageIcon : NSImageCell

@property (strong) IBOutlet id<IconClickProtocol> delegate;
@end
