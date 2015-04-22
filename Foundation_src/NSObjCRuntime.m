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
  CString *s= CCreateString(0);
  CStringAppendFormatv(s, [format UTF8String], args);
  printf("%s\n", [(id)s UTF8String]);
  RELEASE((id)s);
}

static inline NSString *_stringFromCStr(const char *cstr) {
  return cstr ? AUTORELEASE((id)CCreateStringWithBytes(NSUTF8StringEncoding, cstr, strlen(cstr))) : nil;
}

SEL NSSelectorFromString(NSString *selectorName)
{
  return sel_registerName([selectorName UTF8String]);
}
NSString *NSStringFromSelector(SEL selector)
{
  return _stringFromCStr(sel_getName(selector));
}

Class NSClassFromString(NSString *className)
{
  return objc_lookUpClass([className UTF8String]);
}
NSString *NSStringFromClass(Class cls)
{
  return _stringFromCStr(class_getName(cls));
}

Protocol * NSProtocolFromString (NSString *protoName)
{
  return objc_getProtocol([protoName UTF8String]);
}
NSString * NSStringFromProtocol(Protocol *proto)
{
  return _stringFromCStr(protocol_getName(proto));
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

const char * NSGetSizeAndAlignment(const char *typePtr, NSUInteger *sizep, NSUInteger *alignp)
{
  if (typePtr) {
    if (*typePtr == '+' || *typePtr == '-') {
      typePtr++;}
    while ('0' <= *typePtr && *typePtr <= '9') {
      typePtr++;}
    typePtr= objc_skip_type_qualifiers (typePtr);
    if (sizep) {
      *sizep = objc_sizeof_type (typePtr);}
    if (alignp) {
      *alignp= objc_alignof_type (typePtr);}
    typePtr = objc_skip_typespec (typePtr);}
  return typePtr;
}
