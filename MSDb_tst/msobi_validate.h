// msobi_validate.h, ecb, 140101

#import "msfoundation_validate.h"

int msobi_validate(void);

static inline int testObi(BOOL alone)
  {
  int err= 0;
  if (alone)
    printf("**********    Test of the  Microstep MSObi Library    **********\n\n");
  err= //testFoundation(NO) +
       msobi_validate()   +
       0;
  if (alone) {
    if (!err)
      printf("\n********** ALL THE TESTS ARE SUCCESSFUL !!!           **********\n\n");
    else
      printf("\n** FAIL *** FAIL *** FAIL *** FAIL *** FAIL *** FAIL *** FAIL **\n\n");}
  return err;
  }
