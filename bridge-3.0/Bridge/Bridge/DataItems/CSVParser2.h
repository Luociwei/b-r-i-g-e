//
//  CSVParser.h
//  CSVParser
//

#import <Foundation/Foundation.h>

@interface CSVParser2 : NSObject

+ (NSArray *)parseCSVIntoArrayOfDictionariesFromFile:(NSString *)path
                        withSeparatedCharacterString:(NSString *)character
                                quoteCharacterString:(NSString *)quote;

+ (NSArray *)parseCSVIntoArrayOfArraysFromFile:(NSString *)path
                  withSeparatedCharacterString:(NSString *)character
                          quoteCharacterString:(NSString *)quote;

+ (void)parseCSVIntoArrayOfDictionariesFromFile:(NSString *)path
                   withSeparatedCharacterString:(NSString *)character
                           quoteCharacterString:(NSString *)quote
                                      withBlock:(void (^)(NSArray *array, NSError *error))block;

+ (void)parseCSVIntoArrayOfArraysFromFile:(NSString *)path
             withSeparatedCharacterString:(NSString *)character
                     quoteCharacterString:(NSString *)quote
                                withBlock:(void (^)(NSArray *array, NSError *error))block;

@end
