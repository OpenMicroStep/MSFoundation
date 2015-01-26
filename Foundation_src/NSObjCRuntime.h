@class NSString, NSZone;

FOUNDATION_EXPORT void       NSLog(NSString *format,...);
FOUNDATION_EXPORT void       NSLogv(NSString *format,va_list args);

FOUNDATION_EXPORT SEL        NSSelectorFromString(NSString *selectorName);
FOUNDATION_EXPORT NSString * NSStringFromSelector(SEL selector);

FOUNDATION_EXPORT Class      NSClassFromString(NSString *className);
FOUNDATION_EXPORT NSString * NSStringFromClass(Class cls);

FOUNDATION_EXPORT id         NSAllocateObject(Class cls, NSUInteger extraBytes, NSZone *zone);
FOUNDATION_EXPORT void       NSDeallocateObject(id object);
