// msdb_obi_validate.m, ecb, 140101

#include "msdb_validate.h"

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
  o1= [MSOid oidWithValue:1];  // 1 oid: obi id
  u1= [MSUid uidWithUid:o1];       // uid: union d'oid. u1= (o1)
  o2= [MSArray arrayWithObject:[MSOid oidWithValue:1]];
  u2= [MSUid uidWithUid:o2];       // u2= (o1)
  if (!_eq(1, YES, u1, u2)) err++; // [1]==[1]
  u2= [MSUid uidWithUid:[MSOid oidWithValue:-1]];
  if (!_eq(2, NO, u1, u2)) err++;  // [1]!=[-1]
  [u1 addUid:u2];
  if (!_eq(3, NO, u1, u2)) err++;  // [1,-1]!=[-1]
  [u2 addUid:u1];
  if (!_eq(4, YES, u1, u2)) err++; // [1,-1]==[-1,1]
  o1= MSCreateString("ASystemName");
  [u1 addUid:o1];
  RELEASE(o1);
  if (!_eq(5, NO, u1, u2)) err++;  // [1,-1,ASystemName]!=[-1,1]
  [u1 addUid:@"ASystemName"];
  [u2 addUid:@"ASystemName"];
  if (!_eq(6, YES, u1, u2)) err++; // [1,-1,ASystemName]==[-1,1,ASystemName]
  [u1 addUid:@"d"];
  o1= MSCreateString("d");
  [u2 addUid:[MSArray arrayWithObject:[NSArray arrayWithObject:o1]]];
  RELEASE(o1);
  if (!_eq(7, YES, u1, u2)) err++; // [1,-1,ASystemName,d]==[-1,1,ASystemName,d]
  [u1 addUid:u2];
  if (!_eq(8, YES, u1, u2)) err++; // [1,-1,ASystemName,d]==[-1,1,ASystemName,d]
  return err;
  }

static inline int tst_obi_nu(id dbParams)
{
  int err= 0;
  id db,ctx,strId,x; MSObi *o,*theDb; MSUid *ids;
  if (!(db= [[MSOdb alloc] initWithParameters:dbParams])) {
    NSLog(@"B1: no db %@",[dbParams objectForLazyKey:@"database"]); err++;}
  ctx= [MSDictionary dictionaryWithObjectsAndKeys:db,MSContextOdb,
    [NSNumber numberWithBool:YES],MSContextSystemNames,
    [NSNumber numberWithBool:YES],MSContextCompleteness,
    //[NSNumber numberWithBool:YES],@"Strict",
    //[NSNumber numberWithBool:YES],@"Small" ,
    nil];
  o= [db systemObiWithOid:MSCarSystemNameId];
  if (!o) {
    NSLog(@"B2: no MSCarSystemNameId %@",[o descriptionInContext:ctx]); err++;}
  // Recherche de tous les types, ie ayant pour caractéristique 'entity' l'entity 'Typ'
  ids= [db oidsWithCars:[MSDictionary dictionaryWithKeysAndObjects:
    MSCarEntityId,MSEntTypId,nil]];
  strId= [[db systemObiWithName:@"STR"] oid];
  if (![ids containsVid:strId]) {
    NSLog(@"B3: no STR Typ %@",[ids descriptionInContext:ctx]); err++;}
  x= [db fillIds:MSObiDatabaseId withCars:nil];
NSLog(@"X0: %ld",[x count]);
  theDb= [(MSDictionary*)x objectForKey:MSObiDatabaseId];
//theDb= [[db fillIds:MSObiDatabaseId withCars:nil] objectForKey:MSObiDatabaseId];
  if (!theDb) {
    NSLog(@"B4: no DB Obi %@",MSObiDatabaseId); err++;}
NSLog(@"XA newOidValue: %lld",[db newOidValue:1234]);
//NSLog(@"XB car next oid: %@",[[db systemObiWithOid:MSCarNextOidId] descriptionInContext:ctx]);
//NSLog(@"X1: %@",[theDb class]);
//NSLog(@"X2 db: %@",[[db systemObiWithOid:MSObiDatabaseId] descriptionInContext:ctx]);
o= [db systemObiWithOid:MSEntEntId]; // MSEntEntId MSCarSystemNameId
//NSLog(@"X3: %@",[o descriptionInContext:ctx]);
ids= [MSUid uidWithUid:MSCarSystemNameId];
[ids addUid:MSEntEntId];
//NSLog(@"X4: %@",[ids descriptionInContext:ctx]);
ids= [MSUid uidWithUid:[[db systemObisByOid] allKeys]];
NSLog(@"X5: %@",ids);
NSLog(@"X6: %@",[ids descriptionInContext:ctx]);
  RELEAZEN(db);
  return err;
}

static id d1= @"3 // first test !\n"
@"  _id: 102\n"
@"  105: 1061\n"
@" // empty line \n"
@"  102: nom système\n"
@"  _end:\n";

static id d2= @"Ent // Test of Ent with inline gabs\n"
@"  _id: 1\n"
@"  nom système: Ent\n"
@"  gabarit: \n"
@"    Gab\n"
@"    _id: 1011\n"
@"    caractéristique: entité\n"
@"    _end:\n"
@"  gabarit: \n"
@"    Gab\n"
@"    _id: 1012\n"
@"    caractéristique: nom système\n"
@"    _end:\n"
@"  gabarit: \n"
@"    Gab\n"
@"    _id: 1013\n"
@"    caractéristique: gabarit\n"
@"    _end:\n"
@"  _end:\n";

static id d3= @""
@"  Car\n"
@"  _id: -4\n"
@"  nom système: first name\n"
@"  type: STR\n"
@"  _end:\n"

@"  Car\n"
@"  _id: -5\n"
@"  nom système: last name\n"
@"  type: STR\n"
@"  _end:\n"

@"  Ent\n"
@"  _id: -1\n"
@"  nom système: Person\n"
@"  gabarit: \n"
@"    Gab\n"
@"    _id: -2\n"
@"    caractéristique: first name\n"
@"    _end:\n"
@"  gabarit: \n"
@"    Gab\n"
@"    _id: -3\n"
@"    caractéristique: last name\n"
@"    _end:\n"
@"  _end:\n"
;
static inline int tst_obi_decode(id dbParams, id x, BOOL save)
{
  int err= 0;
  id db; MSMutableDictionary *all; MSObi *root= NULL;
  if (!(db= [[MSOdb alloc] initWithParameters:dbParams])) {
    NSLog(@"C1: no db %@",[dbParams objectForLazyKey:@"database"]); err++;}
  all= [db decodeObis:x root:&root];
  if (save) {
    [db changeObis:all];
NSLog(@"SAVED1: %@",root);
NSLog(@"SAVED2: %@",[db systemObiWithName:@"Person"]);
    }
  RELEAZEN(db);
  return err;
}

int msdb_obi_validate(void)
  {
  int err= 0; clock_t t0= clock(), t1; double seconds;

  id dbParams= [MSDictionary dictionaryWithKeysAndObjects:
    @"host",     @"localhost",
    @"port",     [NSNumber numberWithInt:8889],
    @"user",     @"root",
    @"pwd",      @"root",
    @"socket",   @"/Applications/MAMP/tmp/mysql/mysql.sock",
    @"adaptor",  @"mysql",
    @"database", @"Obi-nu",
  //@"database", @"Spaf-Prod-11",
    nil];

  err+= tst_uid();
  err+= tst_obi_nu(dbParams);
//err+= tst_obi_decode(dbParams,d1,NO);
//err+= tst_obi_decode(dbParams,d2,NO);
//err+= tst_obi_decode(dbParams,d3,YES);

  t1= clock(); seconds= (double)(t1-t0)/CLOCKS_PER_SEC;
  fprintf(stdout, "=> %-14s validate: %s (%.3f s)\n","MSObi",(err?"FAIL":"PASS"),seconds);
  return err;
  }
