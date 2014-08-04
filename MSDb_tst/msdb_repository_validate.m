// msdb_repository_validate.m, ecb, 140101

#include "MSDb_Private.h"
#include "MHRepositoryKit.h"
#include "msdb_validate.h"
#import "MHRepository.i"

static inline int tst_rep_nu(id dbParams, id x, BOOL save)
{
  int err= 0;
  id db; MSMutableDictionary *all; MSObi *root= NULL;
  id ctx,nx,prefix; NSUInteger lineBeg,nextLineBeg, lineEnd,l; NSRange rg;
  id dbObi; _btypedValue tv; MSOValue *v;
  if (!(db= [[MSOdb alloc] initWithParameters:dbParams])) {
    NSLog(@"C1: no db %@",[dbParams objectForLazyKey:@"database"]); err++;}
  all= [db decodeObis:x root:&root];
  ctx= [MSDictionary dictionaryWithObjectsAndKeys:db,MSContextOdb,
    [NSNumber numberWithBool:YES],MSContextSystemNames,
    [NSNumber numberWithBool:YES],MSContextCompleteness,
    //[NSNumber numberWithBool:YES],@"Strict",
    //[NSNumber numberWithBool:YES],@"Small" ,
    nil];
  if (save) {
//NSLog(@"systems before:%@",[[db systemObisByOid] descriptionInContext:ctx]);
//NSLog(@"system 103 %@",[db systemObiWithOid:[MSOid oidWithValue:103]]);
    [db changeObis:all];
//NSLog(@"SAVED1: %@",root);
//NSLog(@"all: %@",[all descriptionInContext:ctx]);
//NSLog(@"systems:%@",[[db systemObisByOid] descriptionInContext:ctx]);
//NSLog(@"oui:%@",[[db systemObiWithOid:[MSOid oidWithValue:2341]] descriptionInContext:ctx]);
    nx= [[db systemObisByOid] descriptionInContext:ctx];
  //nx= [all descriptionInContext:ctx];
    [nx getLineStart:NULL end:&nextLineBeg contentsEnd:NULL forRange:NSMakeRange(0,1)];
    nx= [nx substringFromIndex:nextLineBeg];
//NSLog(@"nx:\n %@",nx);
    if (!ISEQUAL(x,nx)) {
      prefix= [x commonPrefixWithString:nx options:NSLiteralSearch];
      NSLog(@"C5: not the same at index (%lu +) %lu",nextLineBeg,(l= [prefix length]));
      NSLog(@"prefix:\n %@",prefix);
      rg= l>1 ? NSMakeRange(l-1, 2) : NSMakeRange(l, 1);
      if (l<[x length]) {
        [x getLineStart:&lineBeg end:NULL contentsEnd:&lineEnd forRange:rg];
        NSLog(@"original: %@",[x  substringWithRange:NSMakeRange(lineBeg, lineEnd-lineBeg)]);}
      if (l<[nx length]) {
        [nx getLineStart:&lineBeg end:NULL contentsEnd:&lineEnd forRange:rg];
        NSLog(@"new:      %@",[nx substringWithRange:NSMakeRange(lineBeg, lineEnd-lineBeg)]);}
      err++;}}
  dbObi= [db systemObiWithOid:MSObiDatabaseId];
  tv.t= RETAIN([MSString UUIDString]);
  v= [MSOValue valueWithCid:MSCarURNId state:MSAdd type:T8 value:tv];
  [dbObi setValue:v];
  [db changeObi:dbObi];
//NSLog(@"dbObi:%@",[dbObi descriptionInContext:ctx]);
  RELEAZEN(db);
  return err;
}

static inline int tst_rep(id dbParams)
{
  int err= 0;
  MSUShort dbNo; id servUrn,persUrn; MSDictionary *dos;
  id rep;
  if (!(dbNo= [MHRepository openRepositoryDatabaseWithParameters:dbParams])) {
    NSLog(@"D1: no open %@",dbParams); err++;}
  if (!err) {
    id c,cpwd,login;
    login= @"repository"; c= @"challenge";
    cpwd= @"ECED7DD19C30EEE2B26E3B673DAA4A9FDFB5F7D99F4B2DD0FBBDE4B5EC935367"
           "BF4CC37315587B9BE940CF00315EAB3A05D8ECF397D447FE478332568256F1F9";
    rep= [[MHRepository alloc] initWithChallenge:c challengedPassword:cpwd forLogin:login];
    if (!rep) {
      NSLog(@"D2: not logged %@",login); err++;}}
  persUrn= @"an urn";
  servUrn= @"Service 861 urn";
  if (!err) {
    id cars,refs,infos;
    cars= [MSArray arrayWithObjects:@"first name",@"last name",nil];
    refs= [MSArray arrayWithObjects:persUrn,nil]; // 10451 an urn
    infos= [rep informationsWithKeys:cars forRefs:refs];
//NSLog(@"infos %@",infos);
    }
  if (!err) {
    id servs= [rep managedServices:NO];
NSLog(@"managedServices %@",servs);
    }
  if (!err) {
    id os,x,cars;
    os= [rep queryInstancesOfEntity:MSREntServiceLib withCars:nil];
NSLog(@"queryInstancesOfEntity Service: %@",os);
    cars= [MSDictionary dictionaryWithKey:MSRCarAdministratorLib andObject:(x= persUrn)];
    os= [rep queryInstancesOfEntity:MSREntServiceLib withCars:cars];
NSLog(@"queryInstancesOfEntity Service of %@: %@",x,os);
    os= [rep queryInstancesOfEntity:MSREntPersonLib withCars:nil];
NSLog(@"queryInstancesOfEntity Person: %@",os);
    cars= [MSDictionary dictionaryWithKey:MSCarLastNameLib andObject:(x= @"last 462")];
    os= [rep queryInstancesOfEntity:MSREntPersonLib withCars:cars];
NSLog(@"queryInstancesOfEntity Person with last name %@: %@",x,os);
    }
  if (!err) {
    id as= [rep authorizationUrnsForSoftwareContextOrApplicationUrns:@"Application 1261 urn"];
NSLog(@"authorizations %@",as);
    }
  if (!err) {
    id as= [rep rightsForApplicationUrn:@"Application 1261 urn"];
NSLog(@"rightsForApplicationUrn %@",[(MSDictionary*)as allKeys]);
    }
  if (!err) {
    id os,error= [rep changeValues:[MSDictionary dictionaryWithKey:persUrn andObject:@"Delete"]];
NSLog(@"delete error:%@",error);
    os= [rep queryInstancesOfEntity:MSREntPersonLib withCars:nil];
NSLog(@"deleted ? Person: %@",os);
    }
  if (!err) {
    id error;
    dos= [rep informationsWithKeys:MSRCarAdministratorLib forRefs:servUrn];
NSLog(@"before Service: %@",[dos objectForKey:servUrn]);
    error= [rep removeValue:persUrn forKey:MSRCarAdministratorLib onObject:servUrn];
NSLog(@"remove error:%@",error);
    dos= [rep informationsWithKeys:MSRCarAdministratorLib forRefs:servUrn];
NSLog(@"removed ? Service: %@",[dos objectForKey:servUrn]);
    }
  if (!err) {
    id error;
    error= [rep addValue:persUrn forKey:MSRCarAdministratorLib onObject:servUrn];
NSLog(@"add error:%@",error);
    dos= [rep informationsWithKeys:MSRCarAdministratorLib forRefs:servUrn];
NSLog(@"added ? Service: %@",[dos objectForKey:servUrn]);
    }
  if (dbNo && ![MHRepository closeRepositoryDatabase:dbNo]) {
    NSLog(@"D99: no close %d",dbNo); err++;}
  return err;
}

int msdb_repository_validate(void)
  {
  int err= 0; clock_t t0= clock(), t1; double seconds;

  id dbParams= [MSDictionary dictionaryWithKeysAndObjects:
    @"host",     @"localhost",
    @"port",     [NSNumber numberWithInt:8889],
    @"user",     @"root",
    @"pwd",      @"root",
    @"socket",   @"/Applications/MAMP/tmp/mysql/mysql.sock",
    @"adaptor",  @"mysql",
    @"database", @"Repository",
  //@"database", @"Spaf-Prod-11",
    nil];

//err+= tst_rep_nu(dbParams,THE_DEFAULT_REPOSITORY_DB,YES);
  err+= tst_rep(dbParams);

  t1= clock(); seconds= (double)(t1-t0)/CLOCKS_PER_SEC;
  fprintf(stdout, "=> %-14s validate: %s (%.3f s)\n","MSRepository",(err?"FAIL":"PASS"),seconds);
  return err;
  }
