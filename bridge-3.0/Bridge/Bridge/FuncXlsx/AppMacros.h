//
//  AppMacros.h
//
//  Created by RyanGao on 2020/6/25.
//  Copyright © 2020 RyanGao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#ifndef AppMacros_h
#define AppMacros_h

#ifdef DEBUG
	#define DBLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
	#define DBLog(...) {}
#endif

#endif /* AppMacros_h */
