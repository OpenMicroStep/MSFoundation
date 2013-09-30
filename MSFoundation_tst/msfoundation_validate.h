// msfoundation_validate.h, ecb, 11/09/13

#import "mscore_validate.h"

int msfoundation_array_validate(void);
int msfoundation_buffer_validate(void);

static inline int testFoundation(BOOL alone)
  {
  int err= 0;
  if (alone)
    printf("********** Test of the Microstep MSFoundation Library **********\n\n");
  err= testCore(NO) +
       msfoundation_array_validate () +
       msfoundation_buffer_validate();
  if (alone) {
    if (!err)
      printf("\n********** ALL THE TESTS ARE SUCCESSFUL !!!           **********\n\n");
    else
      printf("\n** FAIL *** FAIL *** FAIL *** FAIL *** FAIL *** FAIL *** FAIL **\n\n");}
  return err;
  }
