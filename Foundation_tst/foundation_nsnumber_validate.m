#import "foundation_validate.h"

static void number_int(test_t *test)
{
  NSNumber *n1, *n2, *n3, *nmax, *nmin;
  n1= [NSNumber numberWithInt:2048578];
  n2= [ALLOC(NSNumber) initWithInt:2048578];
  n3= [NSNumber numberWithInt:-1048576];
  TASSERT_EQUALS_OBJ(test, n1, n2);
  TASSERT_NOTEQUALS_OBJ(test, n2, n3);
  TASSERT_EQUALS_LLD(test, [n1 intValue], 2048578);
  TASSERT_EQUALS_LLD(test, [n2 intValue], 2048578);
  TASSERT_EQUALS_LLD(test, [n3 intValue], -1048576);
  RELEASE(n2);
  nmax= [NSNumber numberWithInt:INT_MAX];
  nmin= [NSNumber numberWithInt:INT_MIN];

  TASSERT_EQUALS_LLD(test, [nmax boolValue             ], YES       );
  TASSERT_EQUALS_LLD(test, [nmin boolValue             ], YES       );
  TASSERT_EQUALS_LLD(test, [nmax charValue             ], CHAR_MAX  );
  TASSERT_EQUALS_LLD(test, [nmin charValue             ], CHAR_MIN  );
  TASSERT_EQUALS_LLD(test, [nmax shortValue            ], SHRT_MAX  );
  TASSERT_EQUALS_LLD(test, [nmin shortValue            ], SHRT_MIN  );
  TASSERT_EQUALS_LLD(test, [nmax intValue              ], INT_MAX   );
  TASSERT_EQUALS_LLD(test, [nmin intValue              ], INT_MIN   );
  TASSERT_EQUALS_LLD(test, [nmax longValue             ], INT_MAX   );
  TASSERT_EQUALS_LLD(test, [nmin longValue             ], INT_MIN   );
  TASSERT_EQUALS_LLD(test, [nmax longLongValue         ], INT_MAX   );
  TASSERT_EQUALS_LLD(test, [nmin longLongValue         ], INT_MIN   );
  TASSERT_EQUALS_LLD(test, [nmax unsignedIntValue      ], INT_MAX   );
  TASSERT_EQUALS_LLD(test, [nmin unsignedIntValue      ], 0         );
  TASSERT_EQUALS_LLD(test, [nmax unsignedShortValue    ], USHRT_MAX );
  TASSERT_EQUALS_LLD(test, [nmin unsignedShortValue    ], 0         );
  TASSERT_EQUALS_LLD(test, [nmax unsignedLongValue     ], INT_MAX   );
  TASSERT_EQUALS_LLD(test, [nmin unsignedLongValue     ], 0         );
  TASSERT_EQUALS_LLD(test, [nmax unsignedLongLongValue ], INT_MAX   );
  TASSERT_EQUALS_LLD(test, [nmin unsignedLongLongValue ], 0         );
  TASSERT_EQUALS_DBL(test, [nmax doubleValue           ], INT_MAX   );
  TASSERT_EQUALS_DBL(test, [nmin doubleValue           ], INT_MIN   );
  TASSERT_EQUALS_DBL(test, [nmax floatValue            ], INT_MAX   );
  TASSERT_EQUALS_DBL(test, [nmin floatValue            ], INT_MIN   );
  TASSERT_EQUALS_OBJ(test, [nmax stringValue           ], (FMT(@"%d", INT_MAX)));
  TASSERT_EQUALS_OBJ(test, [nmin stringValue           ], (FMT(@"%d", INT_MIN)));
}

static void number_double(test_t *test)
{
  NSNumber *n1, *n2, *n3, *nmax, *nmin;
  NSNumber *i1, *i2, *i3;

  n1= [NSNumber numberWithDouble:1.1];
  n2= [NSNumber numberWithDouble:1.5];
  n3= [NSNumber numberWithDouble:1.6];
  i1= [[NSNumber alloc] initWithDouble:1.1];
  i2= [[NSNumber alloc] initWithDouble:1.5];
  i3= [[NSNumber alloc] initWithDouble:1.6];
  nmax= [NSNumber numberWithDouble:+DBL_MAX];
  nmin= [NSNumber numberWithDouble:-DBL_MAX];

  TASSERT_EQUALS_OBJ(test, n1, i1);
  TASSERT_EQUALS_OBJ(test, n2, i2);
  TASSERT_EQUALS_OBJ(test, n3, i3);
  TASSERT_EQUALS_OBJ(test, i1, n1);
  TASSERT_EQUALS_OBJ(test, i2, n2);
  TASSERT_EQUALS_OBJ(test, i3, n3);

#ifndef MSFOUNDATION_FORCOCOA
  // TODO: documentation
  // MicroStep changed the simple cast behavior to the limit to type boundaries behavior
  // integer -> integer types are constrained to type boundaries
  // real -> integer types are rounded before beeing constrained to type boundaries
  TASSERT_EQUALS_LLD(test, [nmax boolValue        ], YES      );
  TASSERT_EQUALS_LLD(test, [nmin boolValue        ], YES      );
  TASSERT_EQUALS_LLD(test, [nmin charValue        ], CHAR_MIN );
  TASSERT_EQUALS_LLD(test, [nmax shortValue       ], SHRT_MAX );
  TASSERT_EQUALS_LLD(test, [nmin intValue         ], INT_MIN  );
  TASSERT_EQUALS_LLD(test, [nmin longLongValue    ], LLONG_MIN);
  TASSERT_EQUALS_LLD(test, [nmax longLongValue    ], LLONG_MAX);
  TASSERT_EQUALS_LLD(test, [n2 charValue          ], 2        );
  TASSERT_EQUALS_LLD(test, [n3 shortValue         ], 2        );
  TASSERT_EQUALS_LLD(test, [n2 longValue          ], 2        );
  TASSERT_EQUALS_LLD(test, [n3 longLongValue      ], 2        );
#else
  // cocoa simply cast the raw value
  TASSERT_EQUALS_LLD(test, [nmax boolValue        ], (BOOL)     [nmax doubleValue]);
  TASSERT_EQUALS_LLD(test, [nmin boolValue        ], (BOOL)     [nmin doubleValue]);
  TASSERT_EQUALS_LLD(test, [nmin charValue        ], (char)     [nmin doubleValue]);
  TASSERT_EQUALS_LLD(test, [nmax shortValue       ], (short)    [nmax doubleValue]);
  TASSERT_EQUALS_LLD(test, [nmin intValue         ], (int)      [nmin doubleValue]);
  TASSERT_EQUALS_LLD(test, [nmin longLongValue    ], (long long)[nmin doubleValue]);
  TASSERT_EQUALS_LLD(test, [n2 charValue          ], 1        );
  TASSERT_EQUALS_LLD(test, [n3 shortValue         ], 1        );
  TASSERT_EQUALS_LLD(test, [n2 longValue          ], 1        );
  TASSERT_EQUALS_LLD(test, [n3 longLongValue      ], 1        );
#endif
  TASSERT_EQUALS_DBL(test, [nmax doubleValue      ], +DBL_MAX);
  TASSERT_EQUALS_DBL(test, [nmin doubleValue      ], -DBL_MAX);
  TASSERT_EQUALS_LLD(test, [n1 boolValue  ], YES);
  TASSERT_EQUALS_LLD(test, [n1 intValue   ], 1  );
  TASSERT_EQUALS_DBL(test, [n1 doubleValue], 1.1);
  TASSERT_EQUALS_DBL(test, [n2 doubleValue], 1.5);
  TASSERT_EQUALS_DBL(test, [n3 doubleValue], 1.6);

  RELEASE(i1); RELEASE(i2); RELEASE(i3);
}
static void number_compare(test_t *test)
{
  TASSERT_EQUALS_LLD(test, [[NSNumber numberWithUnsignedLongLong:ULLONG_MAX] compare:[NSNumber numberWithUnsignedLongLong:ULLONG_MAX]], NSOrderedSame);
  TASSERT_EQUALS_LLD(test, [[NSNumber numberWithUnsignedLongLong:ULLONG_MAX] compare:[NSNumber numberWithLongLong:LLONG_MAX]], NSOrderedDescending);
  TASSERT_EQUALS_LLD(test, [[NSNumber numberWithLongLong:LLONG_MAX] compare:[NSNumber numberWithUnsignedLongLong:ULLONG_MAX]], NSOrderedAscending);
  TASSERT_EQUALS_LLD(test, [[NSNumber numberWithInt:1] compare:[NSNumber numberWithDouble:1.5]], NSOrderedAscending);
  TASSERT_EQUALS_LLD(test, [[NSNumber numberWithInt:2] compare:[NSNumber numberWithDouble:1.5]], NSOrderedDescending);
  TASSERT_EQUALS_LLD(test, [[NSNumber numberWithInt:2] compare:[NSNumber numberWithDouble:2.0]], NSOrderedSame);
  TASSERT_EQUALS_LLD(test, [[NSNumber numberWithInt:2] compare:[NSNumber numberWithInt:2]], NSOrderedSame);
  TASSERT_EQUALS_LLD(test, [[NSNumber numberWithInt:10] compare:[NSNumber numberWithInt:5]], NSOrderedDescending);
  TASSERT_EQUALS_LLD(test, [[NSNumber numberWithInt:49] compare:[NSNumber numberWithInt:50]], NSOrderedAscending);
  TASSERT_EQUALS_LLD(test, [[NSNumber numberWithBool:YES] compare:[NSNumber numberWithBool:YES]], NSOrderedSame);
  TASSERT_EQUALS_LLD(test, [[NSNumber numberWithBool:YES] compare:[NSNumber numberWithBool:NO]], NSOrderedDescending);
  TASSERT_EQUALS_LLD(test, [[NSNumber numberWithBool:NO] compare:[NSNumber numberWithBool:YES]], NSOrderedAscending);
  TASSERT_EQUALS_LLD(test, [[NSNumber numberWithBool:YES] compare:[NSNumber numberWithInt:1]], NSOrderedSame);
  TASSERT_EQUALS_LLD(test, [[NSNumber numberWithBool:YES] compare:[NSNumber numberWithInt:-1]], NSOrderedDescending);
  TASSERT_EQUALS_LLD(test, [[NSNumber numberWithBool:NO] compare:[NSNumber numberWithInt:10]], NSOrderedAscending);
}

static void number_hash(test_t *test)
{
  TASSERT_EQUALS_LLU(test, [[NSNumber numberWithInt:1] hash], [[NSNumber numberWithDouble:1.0] hash]);
  TASSERT_EQUALS_LLU(test, [[NSNumber numberWithLongLong:1] hash], [[NSNumber numberWithInt:1] hash]);
  TASSERT_NOTEQUALS_LLU(test, [[NSNumber numberWithLongLong:2] hash], [[NSNumber numberWithInt:1] hash]);
  TASSERT_EQUALS_LLU(test, [[NSNumber numberWithBool:YES] hash], [[NSNumber numberWithInt:1] hash]);
  TASSERT_EQUALS_LLU(test, [[NSNumber numberWithBool: NO] hash], [[NSNumber numberWithInt:0] hash]);
  TASSERT_EQUALS_LLU(test, [[NSNumber numberWithUnsignedLongLong:10] hash], [[NSNumber numberWithInt:10] hash]);
  TASSERT_EQUALS_LLU(test, [[NSNumber numberWithUnsignedLong:5] hash], [[NSNumber numberWithChar:5] hash]);
}

testdef_t foundation_number[]= {
  {"int"     ,NULL,number_int     },
  {"double"  ,NULL,number_double  },
  {"compare" ,NULL,number_compare },
  {"hash"    ,NULL,number_hash    },
  {NULL}};
