#import "foundation_validate.h"
#import "MSTests.h"

testdef_t FoundationTests[]= {
  {"NSObjcRuntime"    ,foundation_objcruntime,NULL},
  {"NSNull"           ,foundation_null      ,NULL},
  {"NSObject"         ,foundation_object    ,NULL},
  {"NSAutoreleasePool",foundation_pool      ,NULL},
  {"NSMethodSignature",foundation_methodsign,NULL},
  {"NSInvocation"     ,foundation_invocation,NULL},
  {"NSArray"          ,foundation_array     ,NULL},
  {"NSData"           ,foundation_data      ,NULL},
  {"NSDate"           ,foundation_date      ,NULL},
  {"NSDictionary"     ,foundation_dictionary,NULL},
  {"NSString"         ,foundation_string    ,NULL},
  {"NSScanner"        ,foundation_scanner   ,NULL},
  {"NSNumber"         ,foundation_number    ,NULL},
  {"NSValue"          ,foundation_value     ,NULL},
  {NULL}};
