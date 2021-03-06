// msdb_repository_validate.m, ecb, 140101

#import "msdb_validate.h"
#import "MHRepositoryKit.h"
#import "MHRepository.i"

static inline int tst_rep_nu(id dbParams, id x, BOOL save)
{
  int err= 0;
  id db; MSDictionary *all; MSObi *root= NULL;
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
//NSLog(@"system 103 %@",[db systemObiWithOid:[MSOid oidWithLongLongValue:103]]);
    [db changeObis:all];
//NSLog(@"SAVED1: %@",root);
//NSLog(@"all: %@",[all descriptionInContext:ctx]);
//NSLog(@"systems:%@",[[db systemObisByOid] descriptionInContext:ctx]);
//NSLog(@"oui:%@",[[db systemObiWithOid:[MSOid oidWithLongLongValue:2341]] descriptionInContext:ctx]);
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
  MSUShort dbNo; id servURN,persURN,devURN,devProfileURN,appURN,autURN,rightID,rightID2;
  MSDictionary *dos,*dret;
  id rep= nil;
  if (!(dbNo= [MHRepository openRepositoryDatabaseWithParameters:dbParams])) {
    NSLog(@"D1: no open %@",dbParams); err++;}
  if (!err) {
    id c,cpwd,login;
    login= @"admin"; c= @"challenge";
    // printf "challengehpwd" | openssl sha512 |  tr '[:lower:]' '[:upper:]'
    cpwd= @"51038EA994EF520B32963015499C4E0DBA500833BED9F47186AE0EFA4F9B2A68"
          @"122F85C875E33CCB5F296B95411E2DB8DF8E0B82F0EDE3724148B809DD90DD85";
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
    id servs;
    if      (![(servs= [rep managedServices:0]) count]) {
      NSLog(@"D10 managedServices %@",servs); err++;}
    else if (![(servs= [rep managedServices:1]) count]) {
      NSLog(@"D11 managedServices %@",servs); err++;}
    else if (![(servs= [rep managedServices:2]) count]) {
      NSLog(@"D12 managedServices %@",servs); err++;}
    else servURN= [servs objectAtIndex:0];}
  if (!err) {
    id os= [rep queryInstancesOfEntity:MSREntServiceLib withCars:nil];
    if (![os containsObject:servURN]) {
      NSLog(@"D13 queryInstancesOfEntity Service: %@",os); err++;}}
  if (!err) {
    id os,x,cars;
    cars= [MSDictionary dictionaryWithKey:MSRCarAdministratorLib andObject:(x= persURN)];
    os= [rep queryInstancesOfEntity:MSREntServiceLib withCars:cars];
    if (![os containsObject:servURN]) {
      NSLog(@"D14 queryInstancesOfEntity Service of %@: %@",x,os); err++;}}
  // QUERY PERSON
  if (!err) {
    id os;
/*
os= [rep queryInstancesOfEntity:MSREntPersonLib withCars:
  [MSDictionary dictionaryWithKeysAndObjects:MSCarMiddleNameLib,[MSArray array], nil]];
NSLog(@"Person []: %@ %@",os,[rep informationsWithKeys:MSCarMiddleNameLib forRefs:os]);
os= [rep queryInstancesOfEntity:MSREntPersonLib withCars:
  [MSDictionary dictionaryWithKeysAndObjects:MSCarMiddleNameLib,@"", nil]];
NSLog(@"Person '': %@ %@",os,[rep informationsWithKeys:MSCarMiddleNameLib forRefs:os]);
os= [rep queryInstancesOfEntity:MSREntPersonLib withCars:
  [MSDictionary dictionaryWithKeysAndObjects:MSCarMiddleNameLib,[NSNull null], nil]];
NSLog(@"Person null: %@ %@",os,[rep informationsWithKeys:MSCarMiddleNameLib forRefs:os]);
*/
    os= [rep queryInstancesOfEntity:MSREntPersonLib withCars:nil];
//NSLog(@"Person all: %@ %@",os,[rep informationsWithKeys:MSCarMiddleNameLib forRefs:os]);
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
  // accept reference==""
  if (!err) {
    dret= [rep removeValue:@"" forKey:MSRCarParentServiceLib onObject:servURN];
    if (!dret) {
      NSLog(@"D15 removeValue: is not supposed to be ok %@",dret); err++;}
    dret= [rep addValue:@"" forKey:MSRCarParentServiceLib onObject:servURN];
    if (!dret) {
      NSLog(@"D16 addValue: is not supposed to be ok %@",dret); err++;}
    dret= [rep addValue:[MSArray array] forKey:MSRCarParentServiceLib onObject:servURN];
    if (dret) {
      NSLog(@"D17 addValue:[] %@",dret); err++;}
    }
  // CREATE PERSON (AND DELETE but TODO: not disabled)
  if (!err) {
    id pURN,x,person= [MSDictionary dictionaryWithKeysAndObjects:
      //MSCarURNLib,          @"new URN 8",
      MSCarFirstNameLib,      @"first",
      MSCarMiddleNameLib,     @"middle",
      MSCarLastNameLib,       @"administrator",//@"last",
      MSCarLoginLib,          @"new new login",
      MSCarHashedPasswordLib, @"pwd",
      MSCarResetPasswordLib,  MSTrue, // @"YES",
      //MSCarEntityLib,       MSREntServiceLib,
      //MSCarLabelLib,        @"non authorisée sur Person",
      //@"a bad car",         @"a value",
      nil];
    dret= [rep createPerson:person inService:servURN]; // servURN
    if (!(pURN= [dret objectForKey:MSCarURNLib])) {
      NSLog(@"40 create error:%@",dret); err++;}
//NSLog(@"pers URN %@",pURN);
    dos= [rep informationsWithKeys:MSRCarMemberLib forRefs:servURN];
    if (![(x= [(MSDictionary*)[dos objectForKey:servURN] objectForKey:MSRCarMemberLib]) containsObject:pURN]) {
      NSLog(@"41 not in members: %@",x); err++;}
    // MATCHING
    if (!err) {
      MSDictionary *ps= [MSDictionary mutableDictionaryWithKeysAndObjects:
      //MSCarLoginLib,          @"admin",
      //MSCarHashedPasswordLib, @"pwd",
        MSCarFirstNameLib,      @"Répository",
        MSCarLastNameLib,       @"not matching with last name", nil];
      x= [rep matchingPersons:ps];
      if ([x count]!=2) {
        NSLog(@"D43 matching error:%@",x); err++;}
      [ps removeObjectForKey:MSCarFirstNameLib];
      [ps setObject:@"pwd" forKey:MSCarHashedPasswordLib];
      x= [rep matchingPersons:ps];
      if ([x count]!=2) {
        NSLog(@"D44 matching error:%@",x); err++;}
      [ps removeObjectForKey:MSCarHashedPasswordLib];
      [ps setObject:@"admin" forKey:MSCarLoginLib];
      x= [rep matchingPersons:ps];
      if ([x count]!=2) {
        NSLog(@"D45 matching error:%@",x); err++;}
      [ps setObject:@"administrator" forKey:MSCarLastNameLib];
      x= [rep matchingPersons:ps];
      if ([x count]!=3) {
        NSLog(@"D46 matching error:%@",x); err++;}}
    // REMOVE
    if (!err && (dret= [rep removeValue:NULL forKey:MSRCarMemberLib onObject:servURN])) {
      NSLog(@"D47 remove NULL error:%@",dret); err++;}
    if (!err && (dret= [rep removeValue:[MSArray array] forKey:MSRCarMemberLib onObject:servURN])) {
      NSLog(@"D48 remove [] error:%@",dret); err++;}
    if (!err && (dret= [rep removeValue:pURN forKey:MSRCarMemberLib onObject:servURN])) {
      NSLog(@"D49 remove error:%@",dret); err++;}
    if (!err && (dret= [rep changeObjectsAndValues:[MSDictionary dictionaryWithKey:pURN andObject:@"Delete"]])) {
      NSLog(@"D50 delete error:%@",dret); err++;}}
  // CREATE DEVICE
  devURN= nil;
  if (!err) {
    id dev= [MSDictionary dictionaryWithKeysAndObjects:
      MSCarEntityLib, MSREntDeviceLib,
      MSCarLabelLib, @"my beautifull device",
      MSRCarSerialNumberLib, @"my beautifull serial",
      MSRCarOutOfOrderLib, MSFalse,
      nil];
     dret= [rep createObject:dev];
    if (!(devURN= [dret objectForKey:MSCarURNLib])) {
      NSLog(@"D51 create error:%@",dret); err++;}}
  // CREATE APPLICATION
  appURN= nil;
  if (!err) {
    id app= [MSDictionary dictionaryWithKeysAndObjects:
      MSCarEntityLib, MSREntApplicationLib,
      MSCarLabelLib, @"my beautifull application",
      nil];
     dret= [rep createObject:app];
    if (!(appURN= [dret objectForKey:MSCarURNLib])) {
      NSLog(@"D55 create error:%@",dret); err++;}}
//NSLog(@"+++++ app:%@",appURN);
  // CREATE DEVICE PROFILE
  devProfileURN= nil;
  if (!err) {
    id devProfile= [MSDictionary dictionaryWithKeysAndObjects:
      MSCarEntityLib, MSREntDeviceProfileLib,
      MSCarLabelLib, @"my beautifull device profille",
      MSRCarDeviceLib, devURN,
      nil];
     dret= [rep createSubobject:devProfile forObject:appURN andLink:MSRCarSubDeviceProfileLib];
    if (!(devProfileURN= [dret objectForKey:MSCarURNLib])) {
      NSLog(@"D56 create error:%@",dret); err++;}}
  // CREATE AUTHORIZATION
  autURN= nil;
  if (!err) {
    id aut= [MSDictionary dictionaryWithKeysAndObjects:
      MSCarEntityLib, MSREntAuthorizationLib,
      MSCarLabelLib, @"my beautifull autorization",
      nil];
     dret= [rep createObject:aut]; // servURN
    if (!(autURN= [dret objectForKey:MSCarURNLib])) {
      NSLog(@"D57 create error:%@",dret); err++;}}
//NSLog(@"+++++ auth:%@",autURN);
  // CREATE RIGHT
  rightID= nil;
  if (!err) {
    id right= [MSDictionary dictionaryWithKeysAndObjects:
      MSCarEntityLib, MSREntRightLib,
      MSCarLabelLib, @"my beautifull right",
      MSRCarActionLib, MSRObiUseLib, // servURN pour error
      MSRCarApplicationLib, appURN,
      MSRCarDeviceProfileLib, devProfileURN,
      nil];
     dret= [rep createSubobject:right forObject:autURN andLink:MSRCarSubRightLib];
    if (!(rightID= [dret objectForKey:MSCarURNLib])) {
      NSLog(@"D58 create error:%@\naut: %@\nright: %@",dret,autURN,right); err++;}}
//rightID= [MSDecimal decimalWithLongLong:[rightID longLongValue]];
//NSLog(@"+++++ right:%@ %@",[rightID class],rightID);
  // CREATE RIGHT 2 WITH NO DEVICE PROFILE
  rightID2= nil;
  if (!err) {
    id right= [MSDictionary dictionaryWithKeysAndObjects:
      MSCarEntityLib, MSREntRightLib,
      MSCarLabelLib, @"my beautifull right 2",
      MSRCarActionLib, MSRObiUseLib,
      MSRCarApplicationLib, appURN,
      nil];
     dret= [rep createSubobject:right forObject:autURN andLink:MSRCarSubRightLib];
    if (!(rightID2= [dret objectForKey:MSCarURNLib])) {
      NSLog(@"D59 create error:%@\naut: %@\nright: %@",dret,autURN,right); err++;}}
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
    id cars= [MSDictionary dictionaryWithKey:MSRCarSubRightLib andObject:rightID];
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
    MSDictionary *as= [rep rightsForApplicationURN:appURN];
    if (![[(NSDictionary*)[as objectForKey:rightID] objectForKey:MSRCarApplicationLib] containsObject:appURN]) {
      NSLog(@"D74 rightsForApplicationURN %@ %@",appURN,[(NSDictionary*)[as objectForKey:rightID] objectForKey:MSRCarApplicationLib]); err++;}}
//id b= [rep authorizationBunchsForDeviceURN:devURN];
//NSLog(@"authorizationBunchsForDeviceURN %@ %@",devURN,b);
  // DELETE ADMINISTRATOR TO autURN AUTHORIZATION
  if (!err) {
    id error;
    if ((error= [rep removeAuthenticables:[NSArray arrayWithObjects:appURN,persURN,nil]
                          ofAuthorization:autURN])) {
      NSLog(@"D75 remove member to authorization, error %@",error); err++;}}
  // DELETE LINK FROM RIGHT TO DEVICE PROFILE
  if (devProfileURN && rightID) {
    if ((dret= [rep changeObjectsAndValues:[MSDictionary dictionaryWithKey:rightID  andObject:
                 [MSDictionary dictionaryWithKey:MSRCarDeviceProfileLib andObject:
                 [MSCouple coupleWithFirstMember:@"Remove" secondMember:devProfileURN]]]])) {
      NSLog(@"D77 delete error:%@",dret); err++;}}
  // DELETE DEVICE PROFILE
  if (devProfileURN) {
    if ((dret= [rep changeObjectsAndValues:[MSDictionary dictionaryWithKey:appURN andObject:
                 [MSDictionary dictionaryWithKey:MSRCarSubDeviceProfileLib andObject:
                 [MSCouple coupleWithFirstMember:@"Remove" secondMember:devProfileURN]]]])) {
      NSLog(@"D77 delete error:%@",dret); err++;}
    else if ((dret= [rep changeObjectsAndValues:[MSDictionary dictionaryWithKey:devProfileURN andObject:@"Delete"]])) {
      NSLog(@"D78 delete error:%@",dret); err++;}}
  // DELETE APPLICATION autURN -(right)-> rightID -(application)-> appURN
  if (appURN) {
    if (rightID && rightID2 && (dret= [rep changeObjectsAndValues:[MSDictionary dictionaryWithKeysAndObjects:
          rightID,
            [MSDictionary dictionaryWithKey:MSRCarApplicationLib andObject:
            [MSCouple coupleWithFirstMember:@"Remove" secondMember:appURN]],
          rightID2,
            [MSDictionary dictionaryWithKey:MSRCarApplicationLib andObject:
            [MSCouple coupleWithFirstMember:@"Remove" secondMember:appURN]],
          nil]])) {
      NSLog(@"D80 delete error:%@",dret); err++;}
    if ((dret= [rep changeObjectsAndValues:[MSDictionary dictionaryWithKey:appURN andObject:@"Delete"]])) {
      NSLog(@"D81 delete error:%@",dret); err++;}}
  // DELETE RIGHT
  if (rightID) {
    if (autURN && (dret= [rep changeObjectsAndValues:[MSDictionary dictionaryWithKey:autURN andObject:
          [MSDictionary dictionaryWithKey:MSRCarSubRightLib andObject:
          [MSCouple coupleWithFirstMember:@"Remove" secondMember:rightID]]]])) {
      NSLog(@"D82 delete error:%@",dret); err++;}
    if ((dret= [rep changeObjectsAndValues:[MSDictionary dictionaryWithKey:rightID andObject:@"Delete"]])) {
      NSLog(@"D83 delete error:%@",dret); err++;}}
  // DELETE RIGHT 2
  if (rightID2) {
    if (autURN && (dret= [rep changeObjectsAndValues:[MSDictionary dictionaryWithKey:autURN andObject:
          [MSDictionary dictionaryWithKey:MSRCarSubRightLib andObject:
          [MSCouple coupleWithFirstMember:@"Remove" secondMember:rightID2]]]])) {
      NSLog(@"D84 delete error:%@",dret); err++;}
    if ((dret= [rep changeObjectsAndValues:[MSDictionary dictionaryWithKey:rightID2 andObject:@"Delete"]])) {
      NSLog(@"D85 delete error:%@",dret); err++;}}
  // DELETE AUTORIZATION
  if (autURN) {
    if ((dret= [rep changeObjectsAndValues:[MSDictionary dictionaryWithKey:autURN andObject:@"Delete"]])) {
      NSLog(@"D86 delete error:%@",dret); err++;}}
  // DELETE DEVICE
  if (devURN) {
    if ((dret= [rep changeObjectsAndValues:[MSDictionary dictionaryWithKey:devURN andObject:@"Delete"]])) {
      NSLog(@"D87 delete error:%@",dret); err++;}}
  // DELETE LINKED PERSON NOT POSSIBLE
  if (!err) {
    id error= [rep changeObjectsAndValues:[MSDictionary dictionaryWithKey:persURN andObject:@"Delete"]];
    if (!error) {
      NSLog(@"D90 %@ a été supprimé alors qu'il était lié à son service delete error:%@",persURN,error); err++;}}
  if (dbNo && ![MHRepository closeRepositoryDatabase:dbNo]) {
    NSLog(@"D99: no close %d",dbNo); err++;}
  return err;
}

id localParameters(void);
int msdb_repository_validate(void)
  {
  int err= 0; clock_t t0= clock(), t1; double seconds;

  id dbParams= localParameters();

//err+= tst_rep_nu(dbParams,THE_DEFAULT_REPOSITORY_DB,YES);
  err+= tst_rep(dbParams);

  t1= clock(); seconds= (double)(t1-t0)/CLOCKS_PER_SEC;
  fprintf(stdout, "=> %-14s validate: %s (%.3f s)\n","MHRepository",(err?"FAIL":"PASS"),seconds);
  return err;
  }

id localParameters()
{
  MSDictionary *dbParams= [MSDictionary mutableDictionaryWithKeysAndObjects:
    @"host",     @"localhost",
    @"port",     [NSNumber numberWithInt:3306],
    @"socket",   @"/var/mysql/mysql.sock",
    @"user",     @"root",
    @"pwd",      @"root",
    @"adaptor",  @"mysql",
    @"database", @"repository",
    nil];
  id host= [[NSProcessInfo processInfo] hostName];
  if ([host isEqualToString:@"EcbNewBook"]) { // Parameters for SQL MAMP
    [dbParams setObject:[NSNumber numberWithInt:8889]              forKey:@"port"];
    [dbParams setObject:@"/Applications/MAMP/tmp/mysql/mysql.sock" forKey:@"socket"];
  //[dbParams setObject:@"Spaf-Prod-11"                            forKey:@"database"];
    }
  return dbParams;
}
