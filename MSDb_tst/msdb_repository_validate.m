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
      NSLog(@"prefix:\n%@",prefix);
      rg= l>1 ? NSMakeRange(l-1, 2) : NSMakeRange(l, 1);
      if (l<[x length]) {
        [x getLineStart:&lineBeg end:NULL contentsEnd:&lineEnd forRange:rg];
        NSLog(@"original: %@",[x  substringWithRange:NSMakeRange(lineBeg, lineEnd-lineBeg)]);}
      if (l<[nx length]) {
        [nx getLineStart:&lineBeg end:NULL contentsEnd:&lineEnd forRange:rg];
        NSLog(@"new:      %@",[nx substringWithRange:NSMakeRange(lineBeg, lineEnd-lineBeg)]);}
      NSLog(@"sufix old:\n%@",[x substringFromIndex:l]);
      NSLog(@"sufix new:\n%@",[nx substringFromIndex:l]);
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
  MSUShort dbNo; id servURN,persURN,appURN,autURN,rightID; MSDictionary *dos,*dret;
  id rep;
  if (!(dbNo= [MHRepository openRepositoryDatabaseWithParameters:dbParams])) {
    NSLog(@"D1: no open %@",dbParams); err++;}
  if (!err) {
    id c,cpwd,login;
    login= @"admin"; c= @"challenge";
    // printf "challengehpwd" | openssl sha512 |  tr '[:lower:]' '[:upper:]'
    cpwd= @"51038EA994EF520B32963015499C4E0DBA500833BED9F47186AE0EFA4F9B2A68"
           "122F85C875E33CCB5F296B95411E2DB8DF8E0B82F0EDE3724148B809DD90DD85";
    rep= [[MHRepository alloc] initWithChallenge:c challengedPassword:cpwd forLogin:login];
    if (!rep) {
      NSLog(@"D2: not logged %@",login); err++;}}
  persURN= nil;
  if (!err && !(persURN= [rep urn])) {
    NSLog(@"D3 no URN for connected login %@",rep); err++;
    }
  if (!err) {
    id cars,n; MSDictionary *infos,*info;
    cars= [MSArray arrayWithObjects:MSCarFirstNameLib,MSCarLastNameLib,nil];
    infos= [rep informationsWithKeys:cars forRefs:persURN];
    info= [infos objectForKey:persURN];
    n= [[info objectForKey:MSCarFirstNameLib] objectAtIndex:0];
    if (!ISEQUAL(@"repository", n)) {
      NSLog(@"D4 bad first name %@",n); err++;}
    n= [[info objectForKey:MSCarLastNameLib] objectAtIndex:0];
    if (!ISEQUAL(@"administrator", n)) {
      NSLog(@"D5 bad last name %@",n); err++;}}
  // QUERY SERVICE
  servURN= nil;
  if (!err) {
    id servs= [rep managedServices:NO];
    if (![servs count]) {
      NSLog(@"D10 managedServices %@",servs); err++;}
    else servURN= [servs objectAtIndex:0];}
  if (!err) {
    id os= [rep queryInstancesOfEntity:MSREntServiceLib withCars:nil];
    if (![os containsObject:servURN]) {
      NSLog(@"D11 queryInstancesOfEntity Service: %@",os); err++;}}
  if (!err) {
    id os,x,cars;
    cars= [MSDictionary dictionaryWithKey:MSRCarAdministratorLib andObject:(x= persURN)];
    os= [rep queryInstancesOfEntity:MSREntServiceLib withCars:cars];
    if (![os containsObject:servURN]) {
      NSLog(@"D12 queryInstancesOfEntity Service of %@: %@",x,os); err++;}}
  // QUERY PERSON
  if (!err) {
    id os= [rep queryInstancesOfEntity:MSREntPersonLib withCars:nil];
    if (![os containsObject:persURN]) {
      NSLog(@"D20 queryInstancesOfEntity Person: %@",os); err++;}}
  if (!err) {
    id os,x,cars;
    cars= [MSDictionary dictionaryWithKey:MSCarLastNameLib andObject:(x= @"administrator")];
    os= [rep queryInstancesOfEntity:MSREntPersonLib withCars:cars];
    if (![os containsObject:persURN]) {
      NSLog(@"D21 queryInstancesOfEntity Person with last name %@: %@",x,os); err++;}}
  // ADD / REMOVE PERSONNE AS MEMBER
  if (!err) {
    id error,x; BOOL inAtBeg= NO;
    dos= [rep informationsWithKeys:MSRCarMemberLib forRefs:servURN];
    if (![[(MSDictionary*)[dos objectForKey:servURN] objectForKey:MSRCarMemberLib] containsObject:persURN]) {
      if ((error= [rep addValue:persURN forKey:MSRCarMemberLib onObject:servURN])) {
        NSLog(@"D30 add error:%@",error); err++;}}
    else inAtBeg= YES;
    if (!err) {
      if ((error= [rep removeValue:persURN forKey:MSRCarMemberLib onObject:servURN])) {
        NSLog(@"D31 remove error:%@",error); err++;}}
    if (!err && inAtBeg) {
      if ((error= [rep addValue:persURN forKey:MSRCarMemberLib onObject:servURN])) {
        NSLog(@"D32 add error:%@",error); err++;}}
    if (!err && !ISEQUAL(dos, (x= [rep informationsWithKeys:MSRCarMemberLib forRefs:servURN]))) {
      NSLog(@"D14 add + remove != identity !\n%@\n%@",dos,x); err++;}}
  // CREATE PERSON (AND DELETE but TODO: not disabled)
  if (!err) {
    id pURN,x,person= [MSDictionary dictionaryWithKeysAndObjects:
      //MSCarURNLib,          @"new URN 8",
      MSCarFirstNameLib,      @"first",
      MSCarMiddleNameLib,     @"middle",
      MSCarLastNameLib,       @"last",
      MSCarLoginLib,          @"new login",
      MSCarHashedPasswordLib, @"pwd",
      MSCarResetPasswordLib,  @"YES",
      //MSCarEntityLib,       MSREntServiceLib,
      //MSCarLabelLib,        @"non authorisée sur Person",
      //@"a bad car",         @"a value",
      nil];
     dret= [rep createPerson:person inService:servURN]; // servURN
    if (!(pURN= [dret objectForKey:MSCarURNLib])) {
      NSLog(@"40 create error:%@",dret); err++;}
    dos= [rep informationsWithKeys:MSRCarMemberLib forRefs:servURN];
    if (![(x= [(MSDictionary*)[dos objectForKey:servURN] objectForKey:MSRCarMemberLib]) containsObject:pURN]) {
      NSLog(@"41 not in members: %@",x); err++;}
    if (!err && (dret= [rep removeValue:pURN forKey:MSRCarMemberLib onObject:servURN])) {
      NSLog(@"D42 remove error:%@",dret); err++;}
    if (!err && (dret= [rep changeValues:[MSDictionary dictionaryWithKey:pURN andObject:@"Delete"]])) {
      NSLog(@"D43 delete error:%@",dret); err++;}}
  // CREATE APPLICATION
  appURN= nil;
  if (!err) {
    id app= [MSDictionary dictionaryWithKeysAndObjects:
      MSCarEntityLib, MSREntApplicationLib,
      MSCarLabelLib, @"my beautifull application",
      nil];
     dret= [rep createObject:app];
    if (!(appURN= [dret objectForKey:MSCarURNLib])) {
      NSLog(@"D50 create error:%@",dret); err++;}}
//NSLog(@"+++++ app:%@",appURN);
  // CREATE AUTHORIZATION
  autURN= nil;
  if (!err) {
    id aut= [MSDictionary dictionaryWithKeysAndObjects:
      MSCarEntityLib, MSREntAuthorizationLib,
      MSCarLabelLib, @"my beautifull autorization",
      nil];
     dret= [rep createObject:aut]; // servURN
    if (!(autURN= [dret objectForKey:MSCarURNLib])) {
      NSLog(@"D51 create error:%@",dret); err++;}}
//NSLog(@"+++++ auth:%@",autURN);
  // CREATE RIGHT
  rightID= nil;
  if (!err) {
    id right= [MSDictionary dictionaryWithKeysAndObjects:
      MSCarEntityLib, MSREntRightLib,
      MSCarLabelLib, @"my beautifull right",
      MSRCarApplicationLib, appURN,
      nil];
     dret= [rep createSubobject:right forObject:autURN andLink:MSRCarRightLib];
    if (!(rightID= [dret objectForKey:MSCarURNLib])) {
      NSLog(@"D52 create error:%@",dret); err++;}}
//NSLog(@"+++++ right:%@ %@",[rightID class],rightID);
  // FIND APPLICATION
  if (!err) {
    id cars= [MSDictionary dictionaryWithKey:MSCarURNLib andObject:appURN];
    id os= [rep queryInstancesOfEntity:MSREntApplicationLib withCars:cars];
    if (![os containsObject:appURN]) {
      NSLog(@"D60 queryInstancesOfEntity App: %@",os); err++;}}
  // FIND AUTHORIZATION
  if (!err) {
    id cars= [MSDictionary dictionaryWithKey:MSCarURNLib andObject:autURN];
    id os= [rep queryInstancesOfEntity:MSREntAuthorizationLib withCars:cars];
    if (![os containsObject:autURN]) {
      NSLog(@"D61 queryInstancesOfEntity Auth: %@",os); err++;}}
  // FIND RIGHT
  if (!err) {
    id cars= [MSDictionary dictionaryWithKey:MSRCarRightLib andObject:rightID];
    id os= [rep queryInstancesOfEntity:MSREntAuthorizationLib withCars:cars];
    id aut= ![os count]?nil:[os objectAtIndex:0];
    if (!ISEQUAL(autURN,aut)) {
      NSLog(@"D62 queryInstancesOfEntity Right: %@",aut); err++;}}
  // ADD ADMINISTRATOR TO autURN AUTHORIZATION
  if (!err) {
    id error;
    if ((error= [rep addAuthenticables:appURN onAuthorization:autURN])) {
      NSLog(@"D70 add member to authorization, error %@",error); err++;}
    else if ((error= [rep removeAuthenticables:appURN ofAuthorization:autURN])) {
      NSLog(@"D71 remove member to authorization, error %@",error); err++;}
    else if ((error= [rep addAuthenticables:[NSArray arrayWithObjects:appURN,persURN,nil]
                          onAuthorization:autURN])) {
      NSLog(@"D72 add member to authorization, error %@",error); err++;}}
  // AUTHORIZATION
  if (!err) {
    id as= [rep authorizationURNsForSoftwareContextOrApplicationURNs:appURN];
    if (![as containsObject:autURN]) {
      NSLog(@"D73 authorizations %@ ne contient pas %@",as,autURN); err++;}}
  if (!err) {
    NSDictionary *as= [rep rightsForApplicationURN:appURN];
    if (![[(NSDictionary*)[as objectForKey:rightID] objectForKey:MSRCarApplicationLib] containsObject:appURN]) {
      NSLog(@"D74 rightsForApplicationURN %@ %@",appURN,[(NSDictionary*)[as objectForKey:rightID] objectForKey:MSRCarApplicationLib]); err++;}}
  // DELETE ADMINISTRATOR TO autURN AUTHORIZATION
  if (!err) {
    id error;
    if ((error= [rep removeAuthenticables:[NSArray arrayWithObjects:appURN,persURN,nil]
                          ofAuthorization:autURN])) {
      NSLog(@"D75 remove member to authorization, error %@",error); err++;}}
  // DELETE APPLICATION autURN -(right)-> rightID -(application)-> appURN
  if (appURN) {
    if (rightID && (dret= [rep changeValues:[MSDictionary dictionaryWithKey:rightID andObject:
          [MSDictionary dictionaryWithKey:MSRCarApplicationLib andObject:
          [MSCouple coupleWithFirstMember:@"Remove" secondMember:appURN]]]])) {
      NSLog(@"D80 delete error:%@",dret); err++;}
    if ((dret= [rep changeValues:[MSDictionary dictionaryWithKey:appURN andObject:@"Delete"]])) {
      NSLog(@"D81 delete error:%@",dret); err++;}}
  // DELETE RIGHT
  if (rightID) {
    if (autURN && (dret= [rep changeValues:[MSDictionary dictionaryWithKey:autURN andObject:
          [MSDictionary dictionaryWithKey:MSRCarRightLib andObject:
          [MSCouple coupleWithFirstMember:@"Remove" secondMember:rightID]]]])) {
      NSLog(@"D82 delete error:%@",dret); err++;}
    if ((dret= [rep changeValues:[MSDictionary dictionaryWithKey:rightID andObject:@"Delete"]])) {
      NSLog(@"D83 delete error:%@",dret); err++;}}
  // DELETE AUTORIZATION
  if (autURN) {
    if ((dret= [rep changeValues:[MSDictionary dictionaryWithKey:autURN andObject:@"Delete"]])) {
      NSLog(@"D84 delete error:%@",dret); err++;}}
  // DELETE LINKED PERSON NOT POSSIBLE
  if (!err) {
    id error= [rep changeValues:[MSDictionary dictionaryWithKey:persURN andObject:@"Delete"]];
    if (!error) {
      NSLog(@"D90 %@ a été supprimé alors qu'il était lié à son service delete error:%@",persURN,error); err++;}}
  if (dbNo && ![MHRepository closeRepositoryDatabase:dbNo]) {
    NSLog(@"D99: no close %d",dbNo); err++;}
  return err;
}

int msdb_repository_validate(void)
  {
  int err= 0; clock_t t0= clock(), t1; double seconds;

  id dbParams= [MSDictionary dictionaryWithKeysAndObjects:
    @"host",     @"localhost",
    @"port",     [NSNumber numberWithInt:3306],
    @"user",     @"root",
    @"pwd",      @"root",
    @"adaptor",  @"mysql",
    @"database", @"repository",
    @"socket",   @"/var/mysql/mysql.sock",

  //@"database", @"Spaf-Prod-11",
    nil];

//err+= tst_rep_nu(dbParams,THE_DEFAULT_REPOSITORY_DB,YES);
  err+= tst_rep(dbParams);

  t1= clock(); seconds= (double)(t1-t0)/CLOCKS_PER_SEC;
  fprintf(stdout, "=> %-14s validate: %s (%.3f s)\n","MSRepository",(err?"FAIL":"PASS"),seconds);
  return err;
  }
