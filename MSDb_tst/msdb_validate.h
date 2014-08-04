// msdb_validate.h, ecb, 140101

#import "msfoundation_validate.h"

int msdb_obi_validate(void);
int msdb_repository_validate(void);

static inline int testDb(BOOL alone)
  {
  int err= 0;
  if (alone)
    printf("**********    Test of the  Microstep MSObi Library    **********\n\n");
  err= //testFoundation(NO)           +
       //msdb_obi_validate()          +
       msdb_repository_validate()   +
       0;
  if (alone) {
    if (!err)
      printf("\n********** ALL THE TESTS ARE SUCCESSFUL !!!           **********\n\n");
    else
      printf("\n** FAIL *** FAIL *** FAIL *** FAIL *** FAIL *** FAIL *** FAIL **\n\n");}
  return err;
  }
