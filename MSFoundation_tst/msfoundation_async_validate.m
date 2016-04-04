// msfoundation_array_validate.m, ecb, 130911

#include "msfoundation_validate.h"

static void async_superaction(MSAsync *flux, id obj)
{
  [[flux context] setObject:@"1" forKey:obj];
  [[flux context] setObject:obj forKey:@"last"];
  [flux continue];
}

static void async_action_1(MSAsync *flux)
{
  async_superaction(flux, @"action_1");
}

static void async_action_2(MSAsync *flux)
{
  async_superaction(flux, @"action_2");
}

static BOOL async_condition(MSAsync *flux)
{
  MSDictionary *ctx= [flux context];
  NSNumber *yes= [ctx objectForKey:@"cnd"];
  BOOL cnd= ![yes boolValue];
  [ctx setObject:[NSNumber numberWithBool:cnd] forKey:@"cnd"];
  return cnd;
}

static BOOL async_condition_loop(MSAsync *flux)
{
  MSDictionary *ctx= [flux context];
  NSNumber *ctr= [ctx objectForKey:@"loop_cnd"];
  int i= [ctr intValue] + 1;
  [ctx setObject:[NSNumber numberWithInt:i] forKey:@"loop_cnd"];
  return i < 5;
}

static void async_loopaction(MSAsync *flux)
{
  [[flux context] setObject:@"1" forKey:[[flux context] objectForKey:@"loop_cnd"]];
  [[flux context] setObject:@"loopact" forKey:@"last"];
  [flux continue];
}

static void async_one(test_t *test)
{
  MSAsync *p;
  p= [MSAsync async];
  TASSERT(test, [[p context] isKindOfClass:[MSDictionary class]], "");
  TASSERT(test, [[p context] isMutable], "");
  TASSERT_EQUALS_LLD(test, [p state], MSAsyncDefining);
  [p setFirstElements:[MSAsyncElement asyncAction:async_action_1]];
  [p continue];
  TASSERT_EQUALS_OBJ(test, [p context], (@{
    @"action_1": @"1",
    @"last" : @"action_1",
  }));
}

static void async_two(test_t *test)
{
  MSAsync *p;
  p= [MSAsync async];
  TASSERT(test, [[p context] isKindOfClass:[MSDictionary class]], "");
  TASSERT(test, [[p context] isMutable], "");
  TASSERT_EQUALS_LLD(test, [p state], MSAsyncDefining);
  [p setFirstElements:@[
    [MSAsyncElement asyncAction:async_action_1],
    [MSAsyncElement asyncAction:async_action_2]
  ]];
  [p continue];
  TASSERT_EQUALS_OBJ(test, [p context], (@{
    @"action_1": @"1",
    @"action_2": @"1",
    @"last" : @"action_2",
  }));
}

static void async_super(test_t *test)
{
  MSAsync *p;
  p= [MSAsync async];
  TASSERT(test, [[p context] isKindOfClass:[MSDictionary class]], "");
  TASSERT(test, [[p context] isMutable], "");
  TASSERT_EQUALS_LLD(test, [p state], MSAsyncDefining);
  [p setFirstElements:@[
    [MSAsyncElement asyncSuperAction:async_superaction withObject:@"super1"],
    [MSAsyncElement asyncSuperAction:async_superaction withObject:@"super2"]
  ]];
  [p continue];
  TASSERT_EQUALS_OBJ(test, [p context], (@{
    @"super1": @"1",
    @"super2": @"1",
    @"last" : @"super2",
  }));
}


static void async_if(test_t *test)
{
  MSAsync *p;
  p= [MSAsync async];
  TASSERT(test, [[p context] isKindOfClass:[MSDictionary class]], "");
  TASSERT(test, [[p context] isMutable], "");
  TASSERT_EQUALS_LLD(test, [p state], MSAsyncDefining);
  [p setFirstElements:@[
    [MSAsyncElement asyncIf:async_condition
      then:[MSAsyncElement asyncSuperAction:async_superaction withObject:@"cnd_true"]],
    [MSAsyncElement asyncIf:async_condition
      then:[MSAsyncElement asyncSuperAction:async_superaction withObject:@"dont"]],
    [MSAsyncElement asyncIf:async_condition
      then:[MSAsyncElement asyncSuperAction:async_superaction withObject:@"cnd_true_again"]],
    [MSAsyncElement asyncIf:async_condition
      then:[MSAsyncElement asyncSuperAction:async_superaction withObject:@"dont"]
      else:[MSAsyncElement asyncSuperAction:async_superaction withObject:@"cnd_false_again"]]
  ]];
  [p continue];
  TASSERT_EQUALS_OBJ(test, [p context], (@{
    @"cnd_true": @"1",
    @"cnd_true_again": @"1",
    @"cnd_false_again": @"1",
    @"cnd": @NO,
    @"last" : @"cnd_false_again",
  }));
}

static void async_while(test_t *test)
{
  MSAsync *p;
  p= [MSAsync async];
  TASSERT(test, [[p context] isKindOfClass:[MSDictionary class]], "");
  TASSERT(test, [[p context] isMutable], "");
  TASSERT_EQUALS_LLD(test, [p state], MSAsyncDefining);
  [p setFirstElements:@[
    [MSAsyncElement asyncWhile:async_condition_loop
      do:[MSAsyncElement asyncAction:async_loopaction]]
  ]];
  [p continue];
  TASSERT_EQUALS_OBJ(test, [p context], (@{
    @"loop_cnd": @5,
    @1: @"1",
    @2: @"1",
    @3: @"1",
    @4: @"1",
    @"last" : @"loopact",
  }));
}


static void async_parallel_action(MSAsync *flux, id obj)
{
  [[flux context] setObject:flux forKey:obj];
}

static void async_parallel(test_t *test)
{
  MSAsync *p;
  p= [MSAsync async];
  TASSERT(test, [[p context] isKindOfClass:[MSDictionary class]], "");
  TASSERT(test, [[p context] isMutable], "");
  TASSERT_EQUALS_LLD(test, [p state], MSAsyncDefining);
  [p setFirstElements:@[
    [MSAsyncElement asyncWithParallelElements:@[
      [MSAsyncElement asyncSuperAction:async_parallel_action withObject:@1],
      [MSAsyncElement asyncSuperAction:async_parallel_action withObject:@2],
      [MSAsyncElement asyncSuperAction:async_parallel_action withObject:@3],
      [MSAsyncElement asyncSuperAction:async_parallel_action withObject:@4]
    ]],
    [MSAsyncElement asyncSuperAction:async_superaction withObject:@"done"]
  ]];
  [p continue];
  TASSERT(test, [[[p context] objectForKey:@1] isKindOfClass:[MSAsync class]], "");
  TASSERT(test, [[[p context] objectForKey:@2] isKindOfClass:[MSAsync class]], "");
  TASSERT(test, [[[p context] objectForKey:@3] isKindOfClass:[MSAsync class]], "");
  TASSERT(test, [[[p context] objectForKey:@4] isKindOfClass:[MSAsync class]], "");
  TASSERT_EQUALS_LLD(test, [[p context] count], 4);
  [[[p context] objectForKey:@1] continue];
  [[[p context] objectForKey:@2] continue];
  [[[p context] objectForKey:@3] continue];
  [[[p context] objectForKey:@4] continue];
  TASSERT_EQUALS_LLD(test, [[[p context] objectForKey:@1] state], MSAsyncTerminated);
  TASSERT_EQUALS_LLD(test, [[[p context] objectForKey:@2] state], MSAsyncTerminated);
  TASSERT_EQUALS_LLD(test, [[[p context] objectForKey:@3] state], MSAsyncTerminated);
  TASSERT_EQUALS_LLD(test, [[[p context] objectForKey:@4] state], MSAsyncTerminated);
  TASSERT_EQUALS_OBJ(test, [[p context] objectForKey:@"last"], @"done");
  TASSERT_EQUALS_OBJ(test, [[p context] objectForKey:@"done"], @"1");
  TASSERT_EQUALS_LLD(test, [[p context] count], 6);
}

static void async_mixed(test_t *test)
{
  MSAsync *p;
  p= [MSAsync async];
  TASSERT(test, [[p context] isKindOfClass:[MSDictionary class]], "");
  TASSERT(test, [[p context] isMutable], "");
  TASSERT_EQUALS_LLD(test, [p state], MSAsyncDefining);
  [p setFirstElements:@[
    [MSAsyncElement asyncWhile:async_condition_loop
      do:@[
        @[
          [MSAsyncElement asyncSuperAction:async_parallel_action withObject:@"p1"],
          [MSAsyncElement asyncSuperAction:async_parallel_action withObject:@"p2"],
          [MSAsyncElement asyncSuperAction:async_parallel_action withObject:@"p3"],
          [MSAsyncElement asyncSuperAction:async_parallel_action withObject:@"p4"]
        ],
        [MSAsyncElement asyncAction:async_loopaction]
      ]
    ],
    [MSAsyncElement asyncSuperAction:async_superaction withObject:@"done"]
  ]];
  for (int i= 0; i < 1; ++i) {
    [p continue];
    for (int k= 0; k < 4; ++k) {
      TASSERT_EQUALS_LLD(test, [[[p context] objectForKey:@"loop_cnd"] intValue], k + 1);
      TASSERT(test, [[[p context] objectForKey:@"p1"] isKindOfClass:[MSAsync class]], "");
      TASSERT(test, [[[p context] objectForKey:@"p2"] isKindOfClass:[MSAsync class]], "");
      TASSERT(test, [[[p context] objectForKey:@"p3"] isKindOfClass:[MSAsync class]], "");
      TASSERT(test, [[[p context] objectForKey:@"p4"] isKindOfClass:[MSAsync class]], "");
      [[p context] setObject:@"barrier" forKey:@"last"];
      [[[p context] objectForKey:@"p1"] continue];
      [[[p context] objectForKey:@"p2"] continue];
      [[[p context] objectForKey:@"p3"] continue];
      TASSERT_EQUALS_OBJ(test, [[p context] objectForKey:@"last"], @"barrier");
      [[[p context] objectForKey:@"p4"] continue];
      TASSERT_EQUALS_OBJ(test, [[p context] objectForKey:@"last"], k < 3 ? @"loopact" : @"done");
    }
    TASSERT_EQUALS_OBJ(test, [[p context] objectForKey:@"done"], @"1");
  }
}

testdef_t msfoundation_async[]= {
  {"one"     ,NULL,async_one     },
  {"two"     ,NULL,async_two     },
  {"super"   ,NULL,async_super   },
  {"if"      ,NULL,async_if      },
  {"while"   ,NULL,async_while   },
  {"parallel",NULL,async_parallel},
  {"mixed"   ,NULL,async_mixed},
  {NULL}
};
