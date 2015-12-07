// msdb_test.m, ecb, 140101

#import "msdb_validate.h"

EXTERN_TESTS_BASE

@implementation MSDBTestsContext
- (void)dealloc
{
  RELEASE(retained);
  RELEASE(adaptors);
  [super dealloc];
}
@end

LIBEXPORT testdef_t* TPrepare(test_t *test, testdef_t *definitions, void **context)
{
  NEW_POOL;
  NSArray *adaptors; testdef_t *adaptor_defs= NULL; NSUInteger i=0, len;
  MSArray *retained; MSDBTestsContext *ctx;
  ctx= [MSDBTestsContext new];
  retained= [MSArray new];
  adaptors= [NSArray arrayWithContentsOfFile:TFILE_NSPATH(test, @"config.plist")];
  if ((len= [adaptors count]) > 0) {
    adaptor_defs= MSCalloc(len + 1, sizeof(testdef_t), "TPrepare");
    for (i= 0; i < len; ++i) {
      CBuffer *cname; id adaptor, name;
      adaptor= [adaptors objectAtIndex:i];

      name= [adaptor objectForKey:@"name"];
      cname= CCreateBuffer(0);
      CBufferAppendSES(cname, SESFromString(name), NSUTF8StringEncoding);
      adaptor_defs[i].name= (char *)CBufferCString(cname);
      CArrayAddObject((CArray *)retained, (id)cname);
      RELEASE(cname);
      adaptor_defs[i].subTests= msdb_adaptor;
    }
    adaptor_defs[len].name= NULL;
  }
  else {
    TASSERT(test, [adaptors count] > 0, "at least adaptor test must be defined");
  }
  ctx->retained= retained;
  ASSIGN(ctx->adaptors, adaptors);
  *context= ctx;
  KILL_POOL;
  return adaptor_defs;
}

LIBEXPORT void TRun(test_t *t, void (*testfn)(test_t*), void *context)
{
  NEW_POOL;
  testfn(t);
  KILL_POOL;
}

LIBEXPORT void TFree(test_t *test, testdef_t *definitions, void *context)
{
  RELEASE((id)context);
}

testdef_t RootTests[] = {{NULL}};
