#import "FoundationCompatibility_Private.h"

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
        return NULL;
    }
    return sel_registerName([selectorName UTF8String]);
}

NSString *NSStringFromSelector(SEL selector)
{
    if(!selector) {
        return nil;
    }
    const char* selectorName= sel_getName(selector);
    return AUTORELEASE((id)CCreateStringWithBytes(NSUTF8StringEncoding, selectorName, strlen(selectorName)));
}

Class NSClassFromString(NSString *className)
{
    if(className == nil) {
        return nil;
    }
    const char *clsName = [className UTF8String];
    return objc_lookUpClass(clsName);
}

NSString *NSStringFromClass(Class cls)
{
    if(cls == nil) {
        return nil;
    }
    const char* className= class_getName(cls);
    return AUTORELEASE((id)CCreateStringWithBytes(NSUTF8StringEncoding, className, strlen(className)));
}


id NSAllocateObject(Class cls, NSUInteger extraBytes, NSZone *zone)
{
    id ret;
    ret= calloc(1, class_getInstanceSize(cls) + extraBytes);
    object_setClass(ret, cls);
    // TODO: C++ constructor calling
    return ret;
}

void NSDeallocateObject(id object)
{
    free(object);
}
