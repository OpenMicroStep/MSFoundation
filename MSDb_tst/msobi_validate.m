// msobi_validate.m, ecb, 140101

#include "MSObi_Private.h"
#include "msobi_validate.h"

static inline BOOL _eq(int no, BOOL eq, id u1, id u2)
{
  BOOL e= ISEQUAL(u1,u2);
  if (eq != e) {
    NSLog(@"A%d: %@ %@= %@",no,u1,(e?@"=":@"!"),u2);}
  return (eq == e);
}
static inline int tst_uid(void)
  {
  int err= 0;
  id o1,o2,u1,u2;
  o1= [MSOid oidWithLongValue:1];
  u1= [MSUid uidWithUid:o1];
  o2= [MSArray arrayWithObject:[MSOid oidWithLongValue:1]];
  u2= [MSUid uidWithUid:o2];
  if (!_eq(1, YES, u1, u2)) err++;
  u2= [MSUid uidWithUid:[MSOid oidWithLongValue:-1]];
  if (!_eq(2, NO, u1, u2)) err++;
  [u1 addUid:u2];
  if (!_eq(3, NO, u1, u2)) err++;
  [u2 addUid:u1];
  if (!_eq(4, YES, u1, u2)) err++;
  o1= (id)MSSCreate("ASystemName");
  [u1 addUid:o1];
  RELEASE(o1);
  if (!_eq(5, NO, u1, u2)) err++;
  [u1 addUid:@"ASystemName"];
  [u2 addUid:@"ASystemName"];
  if (!_eq(6, YES, u1, u2)) err++;
  [u1 addUid:@"d"];
  o1= (id)MSSCreate("d");
  [u2 addUid:[MSArray arrayWithObject:[NSArray arrayWithObject:o1]]];
  RELEASE(o1);
  if (!_eq(7, YES, u1, u2)) err++;
  [u1 addUid:u2];
  if (!_eq(8, YES, u1, u2)) err++;
  return err;
  }

static inline int tst_obi_nu(id dbParams)
{
  int err= 0;
  id db,o,ctx,ids,strId,theDb;
  if (!(db= [[MSOdb alloc] initWithParameters:dbParams])) {
    NSLog(@"B1: no db %@",[dbParams objectForLazyKey:@"database"]); err++;}
  ctx= [MSDictionary dictionaryWithObjectsAndKeys:db,@"Odb",
    //[NSNumber numberWithBool:YES],@"Strict",
    //[NSNumber numberWithBool:YES],@"Small" ,
    nil];
  o= [db systemObiWithOid:MSCarSystemNameId];
  if (!o) {
    NSLog(@"B2: no MSCarSystemNameId %@",[o descriptionInContext:ctx]); err++;}
  ids= [db oidsWithCars:[MSDictionary dictionaryWithKeysAndObjects:
    MSCarEntityId,MSEntTypId,nil]];
  strId= [[db systemObiWithName:@"STR"] oid];
  if (![ids containsVid:strId]) {
    NSLog(@"B3: no STR Typ %@",[ids descriptionInContext:ctx]); err++;}
  theDb= [db fillIds:MSObiDatabaseId withCars:nil];
NSLog(@"X1: %ld",[theDb count]);
  theDb= [(MSDictionary*)theDb objectForKey:MSObiDatabaseId];
//theDb= [[db fillIds:MSObiDatabaseId withCars:nil] objectForKey:MSObiDatabaseId];
  if (!theDb) {
    NSLog(@"B4: no DB Obi %@",MSObiDatabaseId); err++;}
NSLog(@"X1: %@",[theDb class]);
NSLog(@"X2: %@",[theDb descriptionInContext:ctx]);
o= [db systemObiWithOid:MSEntEntId]; // MSEntEntId MSCarSystemNameId
NSLog(@"X3: %@",[o descriptionInContext:ctx]);
o= [MSUid uidWithUid:MSCarSystemNameId];
//[o addUid:MSEntEntId];
NSLog(@"X4: %@",[o descriptionInContext:ctx]);
  RELEAZEN(db);
  return err;
}

static id d1= @"3 // first test !\n"
"  _id: 102\n"
"  105: 1061\n"
" // empty line \n"
"  102: nom système\n"
"  _end:\n";
static inline int tst_obi_decode(id dbParams, id x)
{
  int err= 0;
  id db;
  if (!(db= [[MSOdb alloc] initWithParameters:dbParams])) {
    NSLog(@"C1: no db %@",[dbParams objectForLazyKey:@"database"]); err++;}
  [db decodeObis:x];
  RELEAZEN(db);
  return err;
}

int msobi_validate(void)
  {
  int err= 0; clock_t t0= clock(), t1; double seconds;

  id dbParams= DICT @"localhost", @"host",
    [NSNumber numberWithInt:8889], @"port",
    @"root", @"user",@"root", @"pwd",
    @"/Applications/MAMP/tmp/mysql/mysql.sock", @"socket",
    @"mysql", @"adaptator",
    @"Obi-nu", @"database",
    //@"Spaf-Prod-11", @"database",
    CLOSE;

  err+= tst_uid();
  err+= tst_obi_nu(dbParams);
  err+= tst_obi_decode(dbParams,d1);

  t1= clock(); seconds= (double)(t1-t0)/CLOCKS_PER_SEC;
  fprintf(stdout, "=> %-14s validate: %s (%.3f s)\n","MSObi",(err?"FAIL":"PASS"),seconds);
  return err;
  }
