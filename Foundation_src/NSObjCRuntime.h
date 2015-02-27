@class NSString, NSZone;

FoundationExtern void       NSLog(NSString *format,...);
FoundationExtern void       NSLogv(NSString *format,va_list args);

FoundationExtern SEL        NSSelectorFromString(NSString *selectorName);
FoundationExtern NSString * NSStringFromSelector(SEL selector);

FoundationExtern Class      NSClassFromString(NSString *className);
FoundationExtern NSString * NSStringFromClass(Class cls);

FoundationExtern Protocol * NSProtocolFromString (NSString *namestr);
FoundationExtern NSString * NSStringFromProtocol(Protocol *proto);

FoundationExtern id         NSAllocateObject(Class cls, NSUInteger extraBytes, NSZone *zone);
FoundationExtern void       NSDeallocateObject(id object);

FoundationExtern const char * NSGetSizeAndAlignment(const char *typePtr, NSUInteger *sizep, NSUInteger *alignp);
