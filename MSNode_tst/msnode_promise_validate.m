#import "msnode_validate.h"

/////
// event order
static void _promise_eventorder_success(MSPromise *instigator, MSPromise *next, id result, MSHandlerArg *args)
{
  test_t *test= (test_t *)args[0].ptr;
  TASSERT_EQUALS_LLD(test, *args[2].i4Ptr, args[1].i4);
  TASSERT_EQUALS_OBJ(test, result, @"result");
  (*args[2].i4Ptr)++;
  [next resolve:result];
}
static void _promise_eventorder_reject(MSPromise *instigator, id reason, MSHandlerArg *args)
{
  test_t *test= (test_t *)args[0].ptr;
  TASSERT_EQUALS_LLD(test, *args[2].i4Ptr, args[1].i4);
  TASSERT_EQUALS_OBJ(test, reason, @"reason");
  (*args[2].i4Ptr)--;
}
static void promise_eventorder(test_t *test)
{
  NEW_POOL;
  MSPromise *a; int state= 0;

  state= 0;
  a= [MSPromise promise];
  [a then:_promise_eventorder_success args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(0), MSMakeHandlerArg(&state)];
  [a then:_promise_eventorder_success args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(1), MSMakeHandlerArg(&state)];
  [a catch:_promise_eventorder_reject args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(-10), MSMakeHandlerArg(&state)];
  [a catch:_promise_eventorder_reject args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(-10), MSMakeHandlerArg(&state)];
  [a resolve:@"result"];
  TASSERT_EQUALS_LLD(test, state, 2);

  state= 0;
  a= [MSPromise promise];
  [a then:_promise_eventorder_success args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(0), MSMakeHandlerArg(&state)];
  [a resolve:@"result"];
  [a then:_promise_eventorder_success args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(1), MSMakeHandlerArg(&state)];
  [a catch:_promise_eventorder_reject args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(-10), MSMakeHandlerArg(&state)];
  [a catch:_promise_eventorder_reject args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(-10), MSMakeHandlerArg(&state)];
  TASSERT_EQUALS_LLD(test, state, 2);

  state= 0;
  a= [MSPromise promise];
  [a then:_promise_eventorder_success args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(10), MSMakeHandlerArg(&state)];
  [a then:_promise_eventorder_success args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(10), MSMakeHandlerArg(&state)];
  [a catch:_promise_eventorder_reject args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(0), MSMakeHandlerArg(&state)];
  [a catch:_promise_eventorder_reject args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(-1), MSMakeHandlerArg(&state)];
  [a reject:@"reason"];
  TASSERT_EQUALS_LLD(test, state, -2);

  state= 0;
  a= [MSPromise promise];
  [a then:_promise_eventorder_success args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(10), MSMakeHandlerArg(&state)];
  [a then:_promise_eventorder_success args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(10), MSMakeHandlerArg(&state)];
  [a catch:_promise_eventorder_reject args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(0), MSMakeHandlerArg(&state)];
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
  b= [a chainableThen:_promise_eventorder_success args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(0), MSMakeHandlerArg(&state)];
  c= [b chainableThen:_promise_eventorder_success args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(1), MSMakeHandlerArg(&state)];
  [c then:_promise_eventorder_success args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(2), MSMakeHandlerArg(&state)];
  [a catch:_promise_eventorder_reject args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(-10), MSMakeHandlerArg(&state)];
  [b catch:_promise_eventorder_reject args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(-10), MSMakeHandlerArg(&state)];
  [c catch:_promise_eventorder_reject args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(-10), MSMakeHandlerArg(&state)];
  [a resolve:@"result"];
  TASSERT_EQUALS_LLD(test, state, 3);

  state= 0;
  a= [MSPromise promise];
  [a resolve:@"result"];
  b= [a chainableThen:_promise_eventorder_success args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(0), MSMakeHandlerArg(&state)];
  c= [b chainableThen:_promise_eventorder_success args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(1), MSMakeHandlerArg(&state)];
  [c then:_promise_eventorder_success args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(2), MSMakeHandlerArg(&state)];
  [a catch:_promise_eventorder_reject args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(-10), MSMakeHandlerArg(&state)];
  [b catch:_promise_eventorder_reject args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(-10), MSMakeHandlerArg(&state)];
  [c catch:_promise_eventorder_reject args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(-10), MSMakeHandlerArg(&state)];
  TASSERT_EQUALS_LLD(test, state, 3);

  state= 0;
  a= [MSPromise promise];
  b= [a chainableThen:_promise_eventorder_success args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(10), MSMakeHandlerArg(&state)];
  c= [b chainableThen:_promise_eventorder_success args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(10), MSMakeHandlerArg(&state)];
  [c then:_promise_eventorder_success args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(10), MSMakeHandlerArg(&state)];
  [c catch:_promise_eventorder_reject args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(0), MSMakeHandlerArg(&state)];
  [b catch:_promise_eventorder_reject args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(-1), MSMakeHandlerArg(&state)];
  [a catch:_promise_eventorder_reject args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(-2), MSMakeHandlerArg(&state)];
  [a reject:@"reason"];
  TASSERT_EQUALS_LLD(test, state, -3);

  state= -10;
  a= [MSPromise promise];
  [a reject:@"reason"];
  b= [a chainableThen:_promise_eventorder_success args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(10), MSMakeHandlerArg(&state)];
  c= [b chainableThen:_promise_eventorder_success args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(10), MSMakeHandlerArg(&state)];
  [c then:_promise_eventorder_success args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(10), MSMakeHandlerArg(&state)];
  [a catch:_promise_eventorder_reject args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(-10), MSMakeHandlerArg(&state)];
  [b catch:_promise_eventorder_reject args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(-11), MSMakeHandlerArg(&state)];
  [c catch:_promise_eventorder_reject args:3, MSMakeHandlerArg(test), MSMakeHandlerArg(-12), MSMakeHandlerArg(&state)];
  TASSERT_EQUALS_LLD(test, state, -13);

  KILL_POOL;
}
//
/////

test_t msnode_promise[]= {
  {"promise", NULL, promise_eventorder},
  {"chain"  , NULL, promise_chain},
  {NULL}};
