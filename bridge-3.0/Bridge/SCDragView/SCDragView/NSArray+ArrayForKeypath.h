//
//  NSArray+ArrayForKeypath.h
//  Photoroute
//
//

#import <Foundation/Foundation.h>

@interface NSArray (ArrayForKeypath)
-(NSArray*)arrayForValuesWithKey:(NSString*)key;
-(NSArray*)stringArrayForValuesWithKey:(NSString*)key;
-(NSArray*)flatStringArrayForValuesWithKey:(NSString*)key followingChildKey:(NSString*)childKey;
-(id)objectWithValue:(NSString*)value forKey:(NSString*)key andChildrenKey:(NSString*)childKey;
@end
