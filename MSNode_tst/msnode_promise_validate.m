#import "msnode_validate.h"

static MSPromise* _promise_chain_success(id result, MSHandlerArg *args)
{
  test_t *test= (test_t *)args[0].ptr;
  TASSERT_EQUALS_LLD(test, *args[2].i4Ptr, args[1].i4);
  TASSERT_EQUALS_OBJ(test, result, @"chain");
  (*args[2].i4Ptr)++;
  return [MSPromise promiseResolved:@"result"];
}
static MSPromise* _promise_chain_break(id result, MSHandlerArg *args)
{
  test_t *test= (test_t *)args[0].ptr;
  TASSERT_EQUALS_LLD(test, *args[2].i4Ptr, args[1].i4);
  TASSERT_EQUALS_OBJ(test, result, @"result");
  (*args[2].i4Ptr)++;
  return [MSPromise promiseRejected:@"reason"];
}
static MSPromise* _promise_chain_breakreject(id reason, MSHandlerArg *args)
{
  test_t *test= (test_t *)args[0].ptr;
  TASSERT_EQUALS_LLD(test, *args[2].i4Ptr, args[1].i4);
  TASSERT_EQUALS_OBJ(test, reason, @"reason");
  (*args[2].i4Ptr)++;
  return nil;
}
static MSPromise* _promise_eventorder_success(id result, MSHandlerArg *args)
{
  test_t *test= (test_t *)args[0].ptr;
  TASSERT_EQUALS_LLD(test, *args[2].i4Ptr, args[1].i4);
  TASSERT_EQUALS_OBJ(test, result, @"result");
  (*args[2].i4Ptr)++;
  return nil;
}
static MSPromise* _promise_eventorder_reject(id reason, MSHandlerArg *args)
{
  test_t *test= (test_t *)args[0].ptr;
  TASSERT_EQUALS_LLD(test, *args[2].i4Ptr, args[1].i4);
  TASSERT_EQUALS_OBJ(test, reason, @"reason");
  (*args[2].i4Ptr)--;
  return nil;
}

/////
// event order
static void promise_eventorder(test_t *test)
{
  NEW_POOL;
  MSPromise *a; int state= 0;

  state= 0;
  a= [MSPromise promise];
  a= [a then:_promise_eventorder_success args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(0), MSMakeHandlerArg(&state)];
  a= [a then:_promise_eventorder_success args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(1), MSMakeHandlerArg(&state)];
  a= [a catch:_promise_eventorder_reject args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(-10), MSMakeHandlerArg(&state)];
  a= [a catch:_promise_eventorder_reject args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(-10), MSMakeHandlerArg(&state)];
  [a resolve:@"result"];
  TASSERT_EQUALS_LLD(test, state, 2);

  state= 0;
  a= [MSPromise promise];
  a= [a then:_promise_eventorder_success args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(0), MSMakeHandlerArg(&state)];
  [a resolve:@"result"];
  a= [a then:_promise_eventorder_success args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(1), MSMakeHandlerArg(&state)];
  a= [a catch:_promise_eventorder_reject args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(-10), MSMakeHandlerArg(&state)];
  a= [a catch:_promise_eventorder_reject args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(-10), MSMakeHandlerArg(&state)];
  TASSERT_EQUALS_LLD(test, state, 2);

  state= 0;
  a= [MSPromise promise];
  a= [a then:_promise_eventorder_success args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(10), MSMakeHandlerArg(&state)];
  a= [a then:_promise_eventorder_success args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(10), MSMakeHandlerArg(&state)];
  a= [a catch:_promise_eventorder_reject args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(0), MSMakeHandlerArg(&state)];
  a= [a catch:_promise_eventorder_reject args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(-1), MSMakeHandlerArg(&state)];
  [a reject:@"reason"];
  TASSERT_EQUALS_LLD(test, state, -2);

  state= 0;
  a= [MSPromise promise];
  a= [a then:_promise_eventorder_success args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(10), MSMakeHandlerArg(&state)];
  a= [a then:_promise_eventorder_success args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(10), MSMakeHandlerArg(&state)];
  a= [a catch:_promise_eventorder_reject args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(0), MSMakeHandlerArg(&state)];
  [a reject:@"reason"];
  [a catch:_promise_eventorder_reject args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(-1), MSMakeHandlerArg(&state)];
  TASSERT_EQUALS_LLD(test, state, -2);

  KILL_POOL;
}
//
/////

/////
// chaining
static void promise_chain(test_t *test)
{
  NEW_POOL;
  MSPromise *a, *b, *c; int state= 0;

  state= 0;
  a= [MSPromise promise];
  a= [a then:_promise_chain_success      args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(0), MSMakeHandlerArg(&state)];
  a= [a then:_promise_eventorder_success args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(1), MSMakeHandlerArg(&state)];
  a= [a catch:_promise_eventorder_reject args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(-10), MSMakeHandlerArg(&state)];
  [a resolve:@"chain"];
  TASSERT_EQUALS_LLD(test, state, 3);

  state= 0;
  a= [MSPromise promise];
  a= [a then:_promise_chain_success      args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(0), MSMakeHandlerArg(&state)];
  a= [a then:_promise_chain_break        args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(1), MSMakeHandlerArg(&state)];
  a= [a catch:_promise_chain_breakreject args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(2), MSMakeHandlerArg(&state)];
  [a resolve:@"chain"];
  TASSERT_EQUALS_LLD(test, state, 3);

  KILL_POOL;
}
//
/////

test_t msnode_promise[]= {
  {"promise", NULL, promise_eventorder},
  {"chain"  , NULL, promise_chain},
  {NULL}};
