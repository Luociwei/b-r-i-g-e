//
//  CSVWriter.h
//
//

#import <Foundation/Foundation.h>
#import "CSVConfiguration.h"

@interface CSVWriter : NSObject

@property (readonly) NSArray *dataArray;
@property NSArray *columnsOrder;
@property CSVConfiguration *config;

-(instancetype)initWithDataArray:(NSArray *) dataArray columnsOrder:(NSArray *)columnsOrder configuration:(CSVConfiguration *)config;

-(NSString *)writeString;
-(NSData *)writeDataWithError:(NSError **) outError;

@end
