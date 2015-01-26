#import "Foundation_Private.h"

void NSLog(NSString *format,...)
{
    va_list arguments;
    va_start(arguments, format);
    NSLogv(format, arguments);
    va_end(arguments);
}
void NSLogv(NSString *format,va_list args)
{
    #warning TODO NSLogv
}

SEL NSSelectorFromString(NSString *selectorName)
{
    if(selectorName == nil) {
        return nil;
    }
    return sel_registerName([selectorName UTF8String]);
}

NSString *NSStringFromSelector(SEL selector)
{
    if(!selector) {
        return nil;
    }
    const char* selectorName= sel_getName(selector);
    return AUTORELEASE(CCreateStringWithBytes(NSUTF8StringEncoding, selectorName, strlen(selectorName)));
}

Class NSClassFromString(NSString *className)
{
    if(className == nil) {
        return nil;
    }
    return objc_lookUpClass([className UTF8String]);
}

NSString *NSStringFromClass(Class cls)
{
    if(cls == nil) {
        return nil;
    }
    const char* className= class_getName(cls);
    return AUTORELEASE(CCreateStringWithBytes(NSUTF8StringEncoding, className, strlen(className)));
}


id NSAllocateObject(Class cls, NSUInteger extraBytes, NSZone *zone)
{
    id ret;
    ret= calloc(1, class_getInstanceSize(cls) + extraBytes);
    object_setClass(ret, cls);
    // TODO: C++ constructor calling
    return ret;
}
