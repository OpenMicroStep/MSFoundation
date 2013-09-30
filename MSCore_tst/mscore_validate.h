// mscore_validate.h, ecb, 11/09/13

int mscore_c_validate(void);
int mscore_carray_validate(void);
int mscore_cbuffer_validate(void);

static inline int testCore(BOOL alone)
  {
  int err= 0;
  if (alone) {
    printf("********** Test of the Microstep MSCore Library **********\n");
    #ifdef MSCORE_STANDALONE
    printf("********** MSCORE_STANDALONE\n\n");
    #else
    printf("********** MSCORE\n\n");
    #endif
    }
  err= mscore_c_validate      () +
       mscore_carray_validate () +
       mscore_cbuffer_validate();
  if (alone) {
    if (!err)
      printf("\n********** ALL THE TESTS ARE SUCCESSFUL !!!     **********\n\n");
    else
      printf("\n**** FAIL *** FAIL *** FAIL *** FAIL *** FAIL *** FAIL ***\n\n");}
  return err;
  }
