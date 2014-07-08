// msfoundation_validate.h, ecb, 130911

#import "mscore_validate.h"

int msfoundation_array_validate     (void);
int msfoundation_buffer_validate    (void);
int msfoundation_color_validate     (void);
int msfoundation_couple_validate    (void);
int msfoundation_date_validate      (void);
int msfoundation_decimal_validate   (void);
int msfoundation_dictionary_validate(void);
int msfoundation_string_validate    (void);
int msfoundation_mste_validate    (void);

static inline int testFoundation(BOOL alone)
  {
  int err= 0;
  if (alone)
    printf("******* Test of the Microstep MSFoundation Framework %s *******\n\n",[[MSDate date] UTF8String]);
  err= testCore(NO) +
       msfoundation_array_validate()      +
       msfoundation_buffer_validate()     +
       msfoundation_color_validate()      +
       msfoundation_couple_validate()     +
       msfoundation_date_validate()       +
       msfoundation_decimal_validate()    +
       msfoundation_dictionary_validate() +
       msfoundation_string_validate()     +
       msfoundation_mste_validate()     +
       0;
  if (alone) {
    if (!err)
      printf("\n********************    ALL THE TESTS ARE SUCCESSFUL !!!    ********************\n\n");
    else
      printf("\n**** FAIL ***** FAIL ***** FAIL ***** FAIL ***** FAIL ***** FAIL ***** FAIL ****\n\n");}
  return err;
  }
