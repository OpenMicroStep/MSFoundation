#import "foundation_validate.h"

#define NSDATE_TEST_EPSILON 0.000001
#define NSDATE_TEST_NOW_EPSILON 0.1

static void date_mixed(test_t *test)
{
  NEW_POOL;
  NSDate *d0, *d1, *d2, *d3, *d4, *d5, *d6, *d7, *d8, *d9, *df, *dp;
  NSDate *i0, *i1, *i2, *i3, *i4, *i5, *i6, *i7, *i8, *i9;

  d0= [NSDate dateWithTimeIntervalSinceNow:-123.0];
  d1= [NSDate date];
  d2= [NSDate dateWithTimeIntervalSinceReferenceDate:[d1 timeIntervalSinceReferenceDate] + 321.0];
  d3= [NSDate dateWithTimeIntervalSinceReferenceDate:0];
  d4= [NSDate dateWithTimeIntervalSinceReferenceDate:-NSTimeIntervalSince1970];
  d5= [NSDate dateWithTimeIntervalSinceReferenceDate:461662501.373902];
  d6= [NSDate dateWithTimeIntervalSince1970:0];
  d7= [NSDate dateWithTimeIntervalSince1970:NSTimeIntervalSince1970];
  d8= [NSDate dateWithTimeIntervalSince1970:1439970532]; // 2015-08-19 07:48:52 +0000
  d9= [NSDate dateWithTimeIntervalSince1970:340308817]; // 1980-10-13 18:13:37 +0000
  usleep(10);

  i0= [[NSDate alloc] initWithTimeIntervalSinceNow:-123.0];
  i1= [[NSDate alloc] init];
  i2= [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:[d1 timeIntervalSinceReferenceDate] + 321.0];
  i3= [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:0];
  i4= [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:-NSTimeIntervalSince1970];
  i5= [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:461662501.373902];
  i6= [[NSDate alloc] initWithTimeIntervalSince1970:0];
  i7= [[NSDate alloc] initWithTimeIntervalSince1970:NSTimeIntervalSince1970];
  i8= [[NSDate alloc] initWithTimeIntervalSince1970:1439970532]; // 2015-08-19 07:48:52 +0000
  i9= [[NSDate alloc] initWithTimeIntervalSince1970:340308817]; // 1980-10-13 18:13:37 +0000

  df= [NSDate distantFuture];
  dp= [NSDate distantPast];

  // isEqual
  TASSERT_NOTEQUALS_OBJ(test, d1, d2);
  TASSERT_NOTEQUALS_OBJ(test, d2, d3);
  TASSERT_NOTEQUALS_OBJ(test, d3, d4);
  TASSERT_NOTEQUALS_OBJ(test, d4, d5);
  TASSERT_NOTEQUALS_OBJ(test, d5, d6);
  TASSERT_NOTEQUALS_OBJ(test, d7, d8);
  TASSERT_NOTEQUALS_OBJ(test, d8, d9);

  TASSERT_NOTEQUALS_OBJ(test, i1, i2);
  TASSERT_NOTEQUALS_OBJ(test, i2, i3);
  TASSERT_NOTEQUALS_OBJ(test, i3, i4);
  TASSERT_NOTEQUALS_OBJ(test, i4, i5);
  TASSERT_NOTEQUALS_OBJ(test, i5, i6);
  TASSERT_NOTEQUALS_OBJ(test, i7, i8);
  TASSERT_NOTEQUALS_OBJ(test, i8, i9);

  TASSERT_EQUALS_OBJ(test, d3, i3);
  TASSERT_EQUALS_OBJ(test, d4, i4);
  TASSERT_EQUALS_OBJ(test, d5, i5);
  TASSERT_EQUALS_OBJ(test, d6, i6);
  TASSERT_EQUALS_OBJ(test, d7, i7);
  TASSERT_EQUALS_OBJ(test, d8, i8);
  TASSERT_EQUALS_OBJ(test, d9, i9);

  TASSERT_NOTEQUALS_OBJ(test, df, d1);
  TASSERT_NOTEQUALS_OBJ(test, dp, d1);
  TASSERT_NOTEQUALS_OBJ(test, dp, df);

  // compare
  TASSERT_EQUALS_LLD(test, [d0 compare:d1], NSOrderedAscending);
  TASSERT_EQUALS_LLD(test, [d1 compare:d2], NSOrderedAscending);
  TASSERT_EQUALS_LLD(test, [d2 compare:d3], NSOrderedDescending);
  TASSERT_EQUALS_LLD(test, [d3 compare:d4], NSOrderedDescending);
  TASSERT_EQUALS_LLD(test, [d4 compare:d5], NSOrderedAscending);
  TASSERT_EQUALS_LLD(test, [d5 compare:d6], NSOrderedDescending);
  TASSERT_EQUALS_LLD(test, [d6 compare:d7], NSOrderedAscending);
  TASSERT_EQUALS_LLD(test, [d7 compare:d8], NSOrderedAscending);
  TASSERT_EQUALS_LLD(test, [d8 compare:d9], NSOrderedDescending);
  TASSERT_EQUALS_LLD(test, [d9 compare:d7], NSOrderedAscending);

  TASSERT_EQUALS_LLD(test, [d3 compare:i3], NSOrderedSame);
  TASSERT_EQUALS_LLD(test, [d4 compare:i4], NSOrderedSame);
  TASSERT_EQUALS_LLD(test, [d5 compare:i5], NSOrderedSame);
  TASSERT_EQUALS_LLD(test, [d6 compare:i6], NSOrderedSame);
  TASSERT_EQUALS_LLD(test, [d7 compare:i7], NSOrderedSame);
  TASSERT_EQUALS_LLD(test, [d8 compare:i8], NSOrderedSame);
  TASSERT_EQUALS_LLD(test, [d9 compare:i9], NSOrderedSame);

  TASSERT_EQUALS_LLD(test, [df compare:d1], NSOrderedDescending);
  TASSERT_EQUALS_LLD(test, [df compare:dp], NSOrderedDescending);
  TASSERT_EQUALS_LLD(test, [dp compare:d1], NSOrderedAscending);
  TASSERT_EQUALS_LLD(test, [dp compare:df], NSOrderedAscending);
  TASSERT_EQUALS_LLD(test, [df compare:i6], NSOrderedDescending);
  TASSERT_EQUALS_LLD(test, [dp compare:i6], NSOrderedAscending);
  TASSERT_EQUALS_LLD(test, [i6 compare:df], NSOrderedAscending);
  TASSERT_EQUALS_LLD(test, [i6 compare:dp], NSOrderedDescending);

  // Time intervals
  TASSERT_NEAR_DBL(test, [i3 timeIntervalSinceReferenceDate], 0.0, NSDATE_TEST_EPSILON);
  TASSERT_NEAR_DBL(test, [d4 timeIntervalSinceReferenceDate], -NSTimeIntervalSince1970, NSDATE_TEST_EPSILON);
  TASSERT_NEAR_DBL(test, [i5 timeIntervalSinceReferenceDate], 461662501.373902, NSDATE_TEST_EPSILON);
  TASSERT_NEAR_DBL(test, [d6 timeIntervalSinceReferenceDate], -NSTimeIntervalSince1970, NSDATE_TEST_EPSILON);
  TASSERT_NEAR_DBL(test, [i7 timeIntervalSinceReferenceDate], 0.0, NSDATE_TEST_EPSILON);
  TASSERT_NEAR_DBL(test, [d8 timeIntervalSinceReferenceDate], 461663332.0, NSDATE_TEST_EPSILON);
  TASSERT_NEAR_DBL(test, [i9 timeIntervalSinceReferenceDate], -637998383.0, NSDATE_TEST_EPSILON);

  TASSERT_NEAR_DBL(test, [i3 timeIntervalSince1970], NSTimeIntervalSince1970, NSDATE_TEST_EPSILON);
  TASSERT_NEAR_DBL(test, [d4 timeIntervalSince1970], 0.0, NSDATE_TEST_EPSILON);
  TASSERT_NEAR_DBL(test, [i5 timeIntervalSince1970], 1439969701.373902, NSDATE_TEST_EPSILON);
  TASSERT_NEAR_DBL(test, [d6 timeIntervalSince1970], 0.0, NSDATE_TEST_EPSILON);
  TASSERT_NEAR_DBL(test, [i7 timeIntervalSince1970], NSTimeIntervalSince1970, NSDATE_TEST_EPSILON);
  TASSERT_NEAR_DBL(test, [d8 timeIntervalSince1970], 1439970532.0, NSDATE_TEST_EPSILON);
  TASSERT_NEAR_DBL(test, [i9 timeIntervalSince1970], 340308817.0, NSDATE_TEST_EPSILON);

  TASSERT_NEAR_DBL(test, [i3 timeIntervalSinceDate:i4], NSTimeIntervalSince1970, NSDATE_TEST_EPSILON);
  TASSERT_NEAR_DBL(test, [d4 timeIntervalSinceDate:d5], -1439969701.373902, NSDATE_TEST_EPSILON);
  TASSERT_NEAR_DBL(test, [i5 timeIntervalSinceDate:i6], 1439969701.373902, NSDATE_TEST_EPSILON);
  TASSERT_NEAR_DBL(test, [d6 timeIntervalSinceDate:d7], -978307200.0, NSDATE_TEST_EPSILON);
  TASSERT_NEAR_DBL(test, [i7 timeIntervalSinceDate:i8], -461663332.0, NSDATE_TEST_EPSILON);
  TASSERT_NEAR_DBL(test, [d8 timeIntervalSinceDate:d9], 1099661715.0, NSDATE_TEST_EPSILON);
  TASSERT_NEAR_DBL(test, [i9 timeIntervalSinceDate:i3], -637998383.0, NSDATE_TEST_EPSILON);

  TASSERT_NEAR_DBL(test, [d1 timeIntervalSinceNow], 0, NSDATE_TEST_NOW_EPSILON);
  TASSERT_NEAR_DBL(test, [i1 timeIntervalSinceNow], 0, NSDATE_TEST_NOW_EPSILON);
  TASSERT_NOTNEAR_DBL(test, [d8 timeIntervalSinceNow], 0, 1000.0);
  TASSERT_NOTNEAR_DBL(test, [i9 timeIntervalSinceNow], 0, 1000.0);

  // Earlier & Later
  TASSERT_EQUALS_OBJ(test, [d0 earlierDate:d1], d0);
  TASSERT_EQUALS_OBJ(test, [d1 earlierDate:d0], d0);
  TASSERT_EQUALS_OBJ(test, [dp earlierDate:d0], dp);
  TASSERT_EQUALS_OBJ(test, [d6 earlierDate:dp], dp);
  TASSERT_EQUALS_OBJ(test, [dp earlierDate:df], dp);
  TASSERT_NOTEQUALS_OBJ(test, [dp earlierDate:df], df);

  TASSERT_EQUALS_OBJ(test, [d0 laterDate:d1], d1);
  TASSERT_EQUALS_OBJ(test, [d1 laterDate:d0], d1);
  TASSERT_EQUALS_OBJ(test, [df laterDate:d0], df);
  TASSERT_EQUALS_OBJ(test, [d6 laterDate:df], df);
  TASSERT_EQUALS_OBJ(test, [dp laterDate:df], df);
  TASSERT_NOTEQUALS_OBJ(test, [dp laterDate:df], dp);

  // dateByAddingTimeInterval
  d2= [d1 dateByAddingTimeInterval:321.0];
  d0= [d2 dateByAddingTimeInterval:-123.0 - 321.0];
  TASSERT_NEAR_DBL(test, [d0 timeIntervalSinceReferenceDate], [i0 timeIntervalSinceReferenceDate], NSDATE_TEST_NOW_EPSILON);
  TASSERT_NEAR_DBL(test, [d2 timeIntervalSinceReferenceDate], [i2 timeIntervalSinceReferenceDate], NSDATE_TEST_NOW_EPSILON);

  RELEASE(i0);
  RELEASE(i1);
  RELEASE(i2);
  RELEASE(i3);
  RELEASE(i4);
  RELEASE(i5);
  RELEASE(i6);
  RELEASE(i7);
  RELEASE(i8);
  RELEASE(i9);
  KILL_POOL;
}

test_t foundation_date[]= {
  {"mixed"    ,NULL,date_mixed,INTITIALIZE_TEST_T_END},
  {NULL}};
