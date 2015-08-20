#import "foundation_validate.h"
#import "MSTests.h"

test_t FoundationTests[]= {
  {"NSNull"           ,foundation_null      ,NULL,INTITIALIZE_TEST_T_END},
  {"NSObject"         ,foundation_object    ,NULL,INTITIALIZE_TEST_T_END},
  {"NSAutoreleasePool",foundation_pool      ,NULL,INTITIALIZE_TEST_T_END},
  {"NSArray"          ,foundation_array     ,NULL,INTITIALIZE_TEST_T_END},
  {"NSData"           ,foundation_data      ,NULL,INTITIALIZE_TEST_T_END},
  {"NSDate"           ,foundation_date      ,NULL,INTITIALIZE_TEST_T_END},
  {"NSDictionary"     ,foundation_dictionary,NULL,INTITIALIZE_TEST_T_END},
  {"NSString"         ,foundation_string    ,NULL,INTITIALIZE_TEST_T_END},
  {"NSNumber"         ,foundation_number    ,NULL,INTITIALIZE_TEST_T_END},
  {NULL}};
