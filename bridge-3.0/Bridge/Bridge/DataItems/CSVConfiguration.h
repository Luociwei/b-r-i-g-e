//
//  CSVConfiguration.h
//  
//

#import <Foundation/Foundation.h>

@interface CSVConfiguration : NSObject <NSCopying>

@property NSStringEncoding encoding;
@property NSString *columnSeparator;
@property NSString *quoteCharacter;
@property NSString *escapeCharacter;
@property NSString *decimalMark;
@property BOOL firstRowAsHeader;

+(NSArray<NSArray*>*)supportedEncodings;

@end
