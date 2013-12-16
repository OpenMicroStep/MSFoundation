// mscore_validate.h, ecb, 130911

int mscore_c_validate          (void);
int mscore_carray_validate     (void);
int mscore_cbuffer_validate    (void);
int mscore_ccolor_validate     (void);
int mscore_ccouple_validate    (void);
int mscore_cdate_validate      (void);
int mapm_validate              (void);
int mscore_cdecimal_validate   (void);
int mscore_cdictionary_validate(void);

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
  MSSystemInitialize(0, NULL);
  err= mscore_c_validate          () +
       mscore_carray_validate     () +
       mscore_cbuffer_validate    () +
       mscore_ccolor_validate     () +
       mscore_ccouple_validate    () +
       mscore_cdate_validate      () +
       mapm_validate              () +
       mscore_cdecimal_validate   () +
       mscore_cdictionary_validate() +
       0;
  if (alone) {
    if (!err)
      printf("\n********** ALL THE TESTS ARE SUCCESSFUL !!!     **********\n\n");
    else
      printf("\n**** FAIL *** FAIL *** FAIL *** FAIL *** FAIL *** FAIL ***\n\n");}
  return err;
  }
