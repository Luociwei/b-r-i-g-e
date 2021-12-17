//
//  NSArray+ArrayForKeypath.m
//  Photoroute
//
//

#import "NSArray+ArrayForKeypath.h"

@implementation NSArray (ArrayForKeypath)

-(NSArray*)arrayForValuesWithKey:(NSString *)key {
    NSMutableArray* keyPathArray = [NSMutableArray array];
    for (int i = 0; i < self.count; i++) {
        id elem = [self objectAtIndex:i];
        if ([elem valueForKey:key]) [keyPathArray addObject:[elem valueForKey:key]]; else [keyPathArray addObject:@""];
    }
    return [NSArray arrayWithArray:keyPathArray];
}

-(NSArray*)stringArrayForValuesWithKey:(NSString *)key {
    NSMutableArray* keyPathArray = [NSMutableArray array];
    for (int i = 0; i < self.count; i++) {
        id elem = [self objectAtIndex:i];
        if ([elem valueForKey:key]) {
            id val = [elem valueForKey:key];
            if ([val isKindOfClass:[NSNumber class]]) {
                val = [NSString stringWithFormat:@"%li", [val integerValue]];
            }
            [keyPathArray addObject:val];
        } else {
            [keyPathArray addObject:@""];
        }
    }
    return [NSArray arrayWithArray:keyPathArray];
}

-(NSArray*)flatStringArrayForValuesWithKey:(NSString *)key followingChildKey:(NSString *)childKey {
    NSMutableArray* keyPathArray = [NSMutableArray array];
    for (int i = 0; i < self.count; i++) {
        id elem = [self objectAtIndex:i];
        if ([elem valueForKey:key]) {
            id val = [elem valueForKey:key];
            if ([val isKindOfClass:[NSNumber class]]) {
                val = [NSString stringWithFormat:@"%li", [val integerValue]];
            }
            [keyPathArray addObject:val];
        } else {
            [keyPathArray addObject:@""];
        }
        if ([elem valueForKey:childKey] && [[elem valueForKey:childKey] count] > 0) {
            [keyPathArray addObjectsFromArray:[[elem valueForKey:childKey] flatStringArrayForValuesWithKey:key followingChildKey:childKey]];
        }
    }
    return [NSArray arrayWithArray:keyPathArray];
}

-(id)objectWithValue:(NSString *)value forKey:(NSString *)key andChildrenKey:(NSString *)childKey {
    for (int i = 0; i < self.count; i++) {
        id elem = [self objectAtIndex:i];
        if ([[elem valueForKey:key] isEqualToString:value]) {
            return elem;
        }
        if ([elem valueForKey:childKey] && [[elem valueForKey:childKey] count] > 0) {
            id childElem = [[elem valueForKey:childKey] objectWithValue:value forKey:key andChildrenKey:childKey];
            if (childElem) {
                return childElem;
            }
        }
    }
    return nil;
}

@end
