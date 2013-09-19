// mscore_validate.h, ecb, 11/09/13

int mscore_carray_validate(void);

static inline int test()
  {
  int err= 0;
  printf("********** Test of the Microstep MSCore Library **********\n");
  #ifdef MSCORE_STANDALONE
  printf("********** MSCORE_STANDALONE\n");
  #else
  printf("********** MSCORE\n");
  #endif
  if (!(err= mscore_carray_validate()))
    printf("\n********** ALL THE TESTS ARE SUCCESSFUL !!!     **********\n");
  return err;
  }
