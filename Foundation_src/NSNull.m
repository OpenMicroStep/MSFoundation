#import "FoundationCompatibility_Private.h"

static NSNull *__singletonNSNull= nil;

@implementation NSNull
+ (void)load { __singletonNSNull= MSCreateObject(self); }
+ (BOOL)supportsSecureCoding { return YES; }

+ (id)new                               { return __singletonNSNull; }
+ (id)allocWithZone:(NSZone *)zone      { return __singletonNSNull; }
+ (id)alloc                             { return __singletonNSNull; }
+ (NSNull*)null                         { return __singletonNSNull; }

- (id)copyWithZone:(NSZone *)zone       { return __singletonNSNull; }

- (void)encodeWithCoder:(NSCoder *)aCoder {}
- (id)initWithCoder:(NSCoder *)aDecoder { return __singletonNSNull; }

- (oneway void)release {}
- (id)autorelease                       { return __singletonNSNull; }
- (id)retain                            { return __singletonNSNull; }
@end
