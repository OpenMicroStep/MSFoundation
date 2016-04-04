#include "msfoundation_validate.h"

testdef_t MSFoundationTests[]= {
  {"MSArray"     ,msfoundation_array     ,NULL},
  {"MSBuffer"    ,msfoundation_buffer    ,NULL},
  {"MSColor"     ,msfoundation_color     ,NULL},
  {"MSCouple"    ,msfoundation_couple    ,NULL},
  {"MSDate"      ,msfoundation_date      ,NULL},
  {"MSDecimal"   ,msfoundation_decimal   ,NULL},
  {"MSDictionary",msfoundation_dictionary,NULL},
  {"MSString"    ,msfoundation_string    ,NULL},
  {"Async"       ,msfoundation_async     ,NULL},
  {"MSTE"        ,msfoundation_mste      ,NULL},
  {"JSON"        ,msfoundation_json      ,NULL},
  {NULL}};
