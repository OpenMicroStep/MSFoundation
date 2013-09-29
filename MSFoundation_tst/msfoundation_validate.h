// msfoundation_validate.h, ecb, 11/09/13

int msfoundation_array_validate(void);

static inline int test()
  {
  int err= 0;
  printf("********** Test of the Microstep MSFoundation Library **********\n\n");
  if (!(err= msfoundation_array_validate()) &&
      !(err= msfoundation_array_validate())
      )
    printf("\n********** ALL THE TESTS ARE SUCCESSFUL !!!           **********\n");
  return err;
  }
