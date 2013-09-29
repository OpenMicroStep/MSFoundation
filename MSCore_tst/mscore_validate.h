// mscore_validate.h, ecb, 11/09/13

int mscore_c_validate(void);
int mscore_carray_validate(void);
int mscore_cbuffer_validate(void);

static inline int test()
  {
  int err= 0;
  printf("********** Test of the Microstep MSCore Library **********\n");
  #ifdef MSCORE_STANDALONE
  printf("********** MSCORE_STANDALONE\n\n");
  #else
  printf("********** MSCORE\n\n");
  #endif
  if (
    //!(err= mscore_c_validate      ()) && A revoir sous win STANDALONE
      !(err= mscore_carray_validate ()) &&
      !(err= mscore_cbuffer_validate())
      )
    printf("\n********** ALL THE TESTS ARE SUCCESSFUL !!!     **********\n");
  return err;
  }
