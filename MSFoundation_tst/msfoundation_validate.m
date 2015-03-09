#include "msfoundation_validate.h"

test_t MSFoundationTests[]= {
  {"MSArray"     ,msfoundation_array     ,NULL,INTITIALIZE_TEST_T_END},
  {"MSBuffer"    ,msfoundation_buffer    ,NULL,INTITIALIZE_TEST_T_END},
  {"MSColor"     ,msfoundation_color     ,NULL,INTITIALIZE_TEST_T_END},
  {"MSCouple"    ,msfoundation_couple    ,NULL,INTITIALIZE_TEST_T_END},
  {"MSDate"      ,msfoundation_date      ,NULL,INTITIALIZE_TEST_T_END},
  {"MSDecimal"   ,msfoundation_decimal   ,NULL,INTITIALIZE_TEST_T_END},
  {"MSDictionary",msfoundation_dictionary,NULL,INTITIALIZE_TEST_T_END},
  {"MSString"    ,msfoundation_string    ,NULL,INTITIALIZE_TEST_T_END},
  {NULL}
  };
