@class NSString, NSZone;

FoundationExtern void       NSLog(NSString *format,...);
FoundationExtern void       NSLogv(NSString *format,va_list args);

FoundationExtern SEL        NSSelectorFromString(NSString *selectorName);
FoundationExtern NSString * NSStringFromSelector(SEL selector);

FoundationExtern Class      NSClassFromString(NSString *className);
FoundationExtern NSString * NSStringFromClass(Class cls);

FoundationExtern id         NSAllocateObject(Class cls, NSUInteger extraBytes, NSZone *zone);
FoundationExtern void       NSDeallocateObject(id object);
