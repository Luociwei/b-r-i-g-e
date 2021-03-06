//
//  JXArcCompatibilityMacros.h

//  Released under the BSD software licence.
//

#ifndef JXArcCompatibilityMacros_h
#define JXArcCompatibilityMacros_h

#ifdef __clang__
#define JX_STRONG strong
#else
#define JX_STRONG retain
#endif

/*
Porting help (pretty crude, could use improvement):
\[(.+) retain\]				JX_RETAIN(\1)
\[(.+) release\]			JX_RELEASE(\1)
\[(.+) autorelease\]		JX_AUTORELEASE(\1)

\(id\)([\w\d.]+|\[.+\])		JX_BRIDGED_CAST(id, \1)

\(__bridge ((CF|NS)\w+(\ \*)?)\)(\w+)		JX_BRIDGED_CAST(\1, \4)

 The above have usual problems with nesting. Don’t use them with “Replace all”!
*/

#if __has_feature(objc_arc)

#define JX_HAS_ARC 1
#define JX_RETAIN(_o) (_o)
#define JX_RELEASE(_o)
#define JX_AUTORELEASE(_o) (_o)

#define JX_BRIDGED_CAST(_type, _o) (__bridge _type)(_o)
#define JX_TRANSFER_OBJC_TO_CF(_type, _o) (__bridge_retained _type)(_o)
#define JX_TRANSFER_CF_TO_OBJC(_type, _o) (__bridge_transfer _type)(_o)

#else

#define JX_HAS_ARC 0
#define JX_RETAIN(_o) [(_o) retain]
#define JX_RELEASE(_o) [(_o) release]
#define JX_AUTORELEASE(_o) [(_o) autorelease]

#define JX_BRIDGED_CAST(_type, _o) (_type)(_o)
#define JX_TRANSFER_OBJC_TO_CF(_type, _o) (_type)((_o) ? CFRetain((CFTypeRef)(_o)) : NULL)
#define JX_TRANSFER_CF_TO_OBJC(_type, _o) [(_type)CFMakeCollectable(_o) autorelease]

#endif


#ifdef __clang__

#define JX_NEW_AUTORELEASE_POOL_WITH_NAME(_o) @autoreleasepool {
#define JX_END_AUTORELEASE_POOL_WITH_NAME(_o) }

#define JX_DRAIN_AUTORELEASE_POOL_WITH_NAME(_o)

#else

#define JX_NEW_AUTORELEASE_POOL_WITH_NAME(_o) NSAutoreleasePool *(_o) = [NSAutoreleasePool new];
#define JX_END_AUTORELEASE_POOL_WITH_NAME(_o) [(_o) drain];

#define JX_DRAIN_AUTORELEASE_POOL_WITH_NAME(_o) [(_o) drain]

#endif


#endif
