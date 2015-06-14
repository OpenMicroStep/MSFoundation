/*
 
 MHMessenger.m
 
 This file is is a part of the MicroStep Framework.
 
 Initial copyright Herve MALAINGRE and Eric BARADAT (1996)
 Contribution from LOGITUD Solutions (logitud@logitud.fr) since 2011
 
 Geoffrey Guilbon : gguilbon@gmail.com
 Jean-Michel Berthéas : jean-michel.bertheas@club-internet.fr
 
 This software is a computer program whose purpose is to [describe
 functionalities and technical features of your software].
 
 This software is governed by the CeCILL-C license under French law and
 abiding by the rules of distribution of free software.  You can  use,
 modify and/ or redistribute the software under the terms of the CeCILL-C
 license as circulated by CEA, CNRS and INRIA at the following URL
 "http://www.cecill.info".
 
 As a counterpart to the access to the source code and  rights to copy,
 modify and redistribute granted by the license, users are provided only
 with a limited warranty  and the software's author,  the holder of the
 economic rights,  and the successive licensors  have only  limited
 liability.
 
 In this respect, the user's attention is drawn to the risks associated
 with loading,  using,  modifying and/or developing or reproducing the
 software by the user in light of its specific status of free software,
 that may mean  that it is complicated to manipulate,  and  that  also
 therefore means  that it is reserved for developers  and  experienced
 professionals having in-depth computer knowledge. Users are therefore
 encouraged to load and test the software's suitability as regards their
 requirements in conditions enabling the security of their systems and/or
 data to be ensured and,  more generally, to use and operate it in the
 same conditions as regards security.
 
 The fact that you are presently reading this means that you have had
 knowledge of the CeCILL-C license and that you accept its terms.
 
 */

#import <MSNode/MSNode.h>
#import <MHMessenger/MHMessenger.h>
#import <MHRepository/MHRepositoryApi.h>
#import "MHMessengerApp.h"

#define SESSION_PARAM_URN           @"__MH_SESS_URN__"

//mandatory flags
#define FLAG_FOUND_MAND_ENV_SENDER         0x1
#define FLAG_FOUND_MAND_ENV_RECIPIENTS     0x2
#define FLAG_FOUND_MAND_ENV_THREAD         0x4
#define FLAG_FOUND_MAND_ENV_CREATION_DATE  0x8
#define FLAG_FOUND_MAND_ENV_VALIDITY       0x10
#define FLAG_FOUND_MAND_ENV_PRIORITY       0x20
#define FLAG_FOUND_MAND_ENV_STATUS         0x40
#define FLAG_FOUND_MAND_ENV_CONTENT_TYPE   0x80

#define MANDATORY_FLAGS_SUM             (FLAG_FOUND_MAND_ENV_SENDER \
                                        | FLAG_FOUND_MAND_ENV_RECIPIENTS \
                                        | FLAG_FOUND_MAND_ENV_THREAD \
                                        | FLAG_FOUND_MAND_ENV_CREATION_DATE \
                                        | FLAG_FOUND_MAND_ENV_VALIDITY \
                                        | FLAG_FOUND_MAND_ENV_PRIORITY \
                                        | FLAG_FOUND_MAND_ENV_STATUS \
                                        | FLAG_FOUND_MAND_ENV_CONTENT_TYPE)
        
//additional flags
#define FLAG_FOUND_ENV_MESSAGE_ID          0x1 //set only on messenger
#define FLAG_FOUND_ENV_RECEIVING_DATE      0x2 //can be set on proxy
#define FLAG_FOUND_ENV_EXTERNAL_REF        0x4 //optional
#define FLAG_FOUND_ENV_ROUTE               0x8 //can be set on proxy

//repository keys
#define REPOSITORY_URN_KEY                  @"urn"
#define REPOSITORY_CERTIFICATE_KEY          @"certificate"
#define REPOSITORY_PUBLICKEY_KEY            @"public key"
#define REPOSITORY_MHM_AUTHORIZED_ELEMENTS  @"authorized elements"

// Session keys
#define SESSION_PARAM_ALLOWED_RECIPIENTS    @"allowedRecipients"

@implementation MHMessengerSession
- (void)dealloc
{
  [_senderURN release];
  [_recipientURN release];
  [_allowedRecipients release];
  [super dealloc];
}
- (NSString *)senderURN
{ return _senderURN; }
- (NSString *)recipientURN
{ return _recipientURN; }
- (void)setSenderURN:(NSString *)senderURN
{ ASSIGN(_senderURN, senderURN); }
- (void)setRecipientURN:(NSString *)recipientURN
{ ASSIGN(_recipientURN, recipientURN); }
- (NSArray *)allowedRecipients
{ return _allowedRecipients; }
- (void)setAllowedRecipients:(NSArray *)allowedRecipients
{ ASSIGN(_allowedRecipients, allowedRecipients); }
@end

@interface MHMessengerMessageURNMiddleware : NSObject <MSHttpMiddleware>
- (void)onTransaction:(MSHttpTransaction *)tr next:(id <MSHttpNextMiddleware>)next;
@end

@implementation MHMessengerMessageURNMiddleware
static BOOL _senderURNCallback(MSHttpClientResponse *response, NSString *error, void *arg);
static void _senderURNSet(id <MSHttpNextMiddleware> next);
static BOOL _recipientURNCallback(MSHttpClientResponse *response, NSString *error, void *arg);
static void _recipientURNCheck(id <MSHttpNextMiddleware> next, id allowedRecipients);
- (void)onTransaction:(MSHttpTransaction *)tr next:(id <MSHttpNextMiddleware>)next
{
  id session= [tr session];
  id senderURN= [session senderURN];
  if (!senderURN) {
    if ([session authenticationType] == MHNetRepositoryAuthenticatedByPublicKey) {
      [session setSenderURN:[session login]];
      _senderURNSet(next);}
    else {
      id request= [[session client] urnForLogin:[session login]];
      [request addHandler:_senderURNCallback context:next];}}
  else {
    _senderURNSet(next);}
}
static BOOL _senderURNCallback(MSHttpClientResponse *response, NSString *error, void *arg)
{
  id senderURN= [(id)response stringValue];
  if (senderURN){
    _senderURNSet((id)arg);}
  else {
    [[(id)arg transaction] write:MSHttpCodeInternalServerError string:@"Unable to find URN of the logged user"];}
  return NO;
}
static void _senderURNSet(id <MSHttpNextMiddleware> next)
{
  id session, allowedRecipients, request;
  session= [[next transaction] session];
  if ([[[next transaction] urlQueryParameters] objectForKey:@"recipient"]) {
    allowedRecipients= [session allowedRecipients];
    if (!allowedRecipients) {
      request= [[session client] allowedApplicationUrnsForAuthenticable:[session senderURN]];
      [request addHandler:_recipientURNCallback context:next];}
    else {
      _recipientURNCheck(next, allowedRecipients);}}
  else {
    [session setRecipientURN:[session senderURN]];
    [next nextMiddleware];}
}
static BOOL _recipientURNCallback(MSHttpClientResponse *response, NSString *error, void *arg)
{
  _recipientURNCheck((id)arg, [(id)response msteDecodedObject]);
  return NO;
}
static void _recipientURNCheck(id <MSHttpNextMiddleware> next, id allowedRecipients)
{
  id recipient= [[[next transaction] urlQueryParameters] objectForKey:@"recipient"];
  if (![allowedRecipients isKindOfClass:[NSArray class]] || ![allowedRecipients containsObject:recipient]) {
    [[next transaction] write:MSHttpCodeUnauthorized]; }
  else {
    [[[next transaction] session] setRecipientURN:recipient];
    [next nextMiddleware];}
}
@end

@interface MHMessengerMessageCleaner : NSObject <MSHttpMiddleware> {
  NSUInteger _counter;
  id _messengerDBAccessor;
}
- (instancetype)initWithMessengeDB:(id)db;
- (void)onTransaction:(MSHttpTransaction *)tr next:(id <MSHttpNextMiddleware>)next;
@end

@implementation MHMessengerMessageCleaner
- (instancetype)initWithMessengeDB:(id)db {
  _messengerDBAccessor= [db retain];
  return self;
}
- (void)dealloc 
{
  [_messengerDBAccessor release];
  [super dealloc];
}
- (void)onTransaction:(MSHttpTransaction *)tr next:(id <MSHttpNextMiddleware>)next
{
  if (++_counter == 100) {
    _counter= 0;
    [_messengerDBAccessor cleanObsoleteMessages];}
  [next nextMiddleware];
}
@end

//mutex for base increments
@implementation MHMessengerApplication

- (instancetype)initWithParameters:(NSDictionary *)parameters withPath:(NSString *)path error:(NSString **)perror
{
  id error= nil, dbParams, db, dbPath;
  dbParams= [MSDictionary mutableDictionaryWithDictionary:[parameters objectForKey:@"database"]];
  if (!dbParams) {
    error= @"missing 'database' parameter";}
  if (!error && (dbPath= [dbParams objectForKey:@"path"]) && ![dbPath isAbsolutePath]) {
    dbPath= [path stringByAppendingPathComponent:dbPath];
    [dbParams setObject:dbPath forKey:@"path"];}
  if (!error && !(db= [MHMessengerDBAccessor messengerDBWithConnectionDictionary:dbParams])) {
    error= FMT(@"unable to connect to the database: %@", dbParams);}
  if (error) {
    if (perror)
      *perror= error;
    DESTROY(self);}
  if (self && (self= [super initWithParameters:parameters withPath:path error:perror])) {
    MSHttpSessionMiddleware *sessionMiddleware;

    ASSIGN(_messengerDBAccessor, db);
    sessionMiddleware= [ALLOC(MSHttpSessionMiddleware) initWithCookieName:@"MASHSESSION" sessionClass:[MHMessengerSession class]];
    [sessionMiddleware setAuthenticator:self];
    [self addRouteToMiddleware:[MSHttpCookieMiddleware cookieMiddleware]];
    [self addRouteToMiddleware:sessionMiddleware]; // All routes after this one are authenticated
    [self addRouteToMiddleware:AUTORELEASE([ALLOC(MHMessengerMessageCleaner) initWithMessengeDB:db])]; //< Clean obsolete message every 1000 request
    [self addRouteToMiddleware:AUTORELEASE([MHMessengerMessageURNMiddleware new])]; //< Update senderURN and recipientURN

    [self addRoute:@"/auth" method:MSHttpMethodGET toTarget:self selector:@selector(GET_auth:)];
    [self addRoute:@"/findMessages" method:MSHttpMethodGET toTarget:self selector:@selector(GET_findMessages:)];
    [self addRoute:@"/getMessage" method:MSHttpMethodGET toTarget:self selector:@selector(GET_getMessage:)];
    [self addRoute:@"/getMessageStatus" method:MSHttpMethodGET toTarget:self selector:@selector(GET_getMessageStatus:)];
    [self addRoute:@"/setMessageStatus" method:MSHttpMethodGET toTarget:self selector:@selector(GET_setMessageStatus:)];
    [self addRoute:@"/deleteMessage" method:MSHttpMethodGET toTarget:self selector:@selector(GET_deleteMessage:)];

    [self addRoute:@"/sendMessage" method:MSHttpMethodPOST toMiddleware:[MHMessengerMessageMiddleware messengerMessageMiddleware]];
    [self addRoute:@"/sendMessage" method:MSHttpMethodPOST toTarget:self selector:@selector(POST_sendMessage:)];
    [sessionMiddleware release];
    [_messengerDBAccessor cleanObsoleteMessages];
  }
  return self;
}

/*
- (BOOL)_databaseInitialisationAtPath:(NSString *)dbPath
{
    BOOL isDir ;
    NSString *scriptPath ;
    NSString *dbDirectoryPath = [dbPath stringByDeletingLastPathComponent] ;
    MSInt dbVersion ;

    //-1 Create and initialise database file
    if(!MSFileExistsAtPath(dbPath, &isDir)) //check if file exist
    {
        BOOL runOK ;
        if(!MSFileExistsAtPath(dbDirectoryPath, &isDir)) { //check if directory exist
            
            if(!MSCreateRecursiveDirectory(dbDirectoryPath))
            {
                //[self logWithLevel:MHAppError log:@"Failed to create database directory"] ;
                return NO ;
            }
        }
        
        scriptPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"1" ofType:@"sql"] ;
        
        runOK = [_messengerDBAccessor runSQLScript:scriptPath] ; //run creation script
        if(!runOK) { //db init script
            //[self logWithLevel:MHAppError log:@"Failed to run sql create script : %@",scriptPath] ;
            return NO ;
        }

    }
    
    //-2 database exist, check if need to run update scripts
    dbVersion = [_messengerDBAccessor getDBVersion] ;
    scriptPath = [[NSBundle bundleForClass:[self class]] pathForResource:[NSString stringWithFormat:@"%d",++dbVersion] ofType:@"sql"] ;
    if(scriptPath) { //update script exist, backup current db
        NSString *backupFileName = [NSString stringWithFormat:@"messengerDB_%@.bak",[[NSDate date] description]] ;
        MSBuffer *dbBuf = [MSBuffer bufferWithContentsOfFile:dbPath] ;
        [dbBuf writeToFile:[dbDirectoryPath stringByAppendingPathComponent:backupFileName] atomically:YES] ;
    }
    
    while(scriptPath)
    {
        if(![_messengerDBAccessor runSQLScript:scriptPath])
        {
            //[self logWithLevel:MHAppError log:@"Failed to run sql update script : %@",scriptPath] ;
            return NO ;
        }
        scriptPath = [[NSBundle bundleForClass:[self class]] pathForResource:[NSString stringWithFormat:@"%d",++dbVersion] ofType:@"sql"] ;
    }
    

    return YES ;
}*/

- (void)authenticate:(MSHttpTransaction *)tr next:(id <MSHttpNextMiddleware>)next
{
  if (!MHNetRepositoryAuthenticateDistantSession(tr, next, [[self parameters] objectForKey:@"repository"], [self path])) {
    [[tr session] kill];
    [tr write:MSHttpCodeUnauthorized];
  }
}
- (void)dealloc
{
  [_messengerDBAccessor release];
  [super dealloc];
}

- (void)GET_auth:(MSHttpTransaction *)tr
{
  [tr write:MSHttpCodeOk];
}

- (void)POST_sendMessage:(MSHttpTransaction *)tr
{
  id error= nil;
  MHMessengerMessage *message= [tr messengerMessage];
  if (![[message sender] isEqual:[[tr session] senderURN]])
    error= @"sender is not valid";
  else if(![message checkConsistency:&error] && !error)
    error= @"unknown consitency error";
  if (!error) {
    id messageIDs= [_messengerDBAccessor createIDAndstoreMessage:message];
    if(![messageIDs count]) {
      [tr write:MSHttpCodeInternalServerError];}
    else {
      [tr write:MSHttpCodeOk mste:messageIDs];}}
  else {
    [tr write:MSHttpCodeBadRequest string:error];}
}

// /findMessages?tid=GVeMIFsTours&status=1&xid=42=max=3&recipient=urn
- (void)GET_findMessages:(MSHttpTransaction *)tr
{
  NSDictionary *queryParams= [tr urlQueryParameters];
  NSArray *messageID= [[queryParams objectForKey:MESSENGER_QUERY_PARAM_MESSAGE_ID] componentsSeparatedByString:MESSENGER_QUERY_PARAM_OR_SEPARATOR] ;
  NSArray *thread= [[queryParams objectForKey:MESSENGER_QUERY_PARAM_THREAD_ID] componentsSeparatedByString:MESSENGER_QUERY_PARAM_OR_SEPARATOR] ;
  NSNumber *max= [NSNumber numberWithInt:[[queryParams objectForKey:MESSENGER_QUERY_PARAM_MAX] intValue]] ;
  
  if (![messageID count] && !([thread count] && [max intValue]>0)) {
    //[self logWithLevel:MHAppError log:@"/%@ : no thread and limit>0 or message ID specified in query string '%@'", MESSENGER_SUB_URL_FIND_MSG, queryParams];
    [tr write:MSHttpCodeBadRequest];} 
  else {
    NSDictionary *messages= [_messengerDBAccessor findMessagesForURN:[[tr session] recipientURN] andParameters:queryParams];
    if (!messages) {
      //[self logWithLevel:MHAppError log:@"/%@ : failed to fetch message list", MESSENGER_SUB_URL_FIND_MSG] ;
      [tr write:MSHttpCodeInternalServerError]; }
    else {
      [tr write:MSHttpCodeOk mste:messages]; }}
}

// /getMessage?mid=UID&recipient=urn
- (void)GET_getMessage:(MSHttpTransaction *)tr
{
  NSDictionary *queryParams= [tr urlQueryParameters];
  NSString *messageID = [queryParams objectForKey:MESSENGER_QUERY_PARAM_MESSAGE_ID] ;
  
  if(![messageID length]) {
    //[self logWithLevel:MHAppError log:@"/%@ : no message ID or wrong envelope type specified in query string", MESSENGER_SUB_URL_GET_MSG] ;
    [tr write:MSHttpCodeBadRequest];}
  else {
    MHMessengerMessage *message ;
    message= [_messengerDBAccessor getMessageForURN:[[tr session] recipientURN] andMessageID:messageID] ;
    if(!message) {
      //[self logWithLevel:MHAppError log:@"/%@ : failed to fetch message", MESSENGER_SUB_URL_GET_MSG] ;
      [tr write:MSHttpCodeInternalServerError]; }
    else {
      [tr write:MSHttpCodeOk messengerMessage:message]; }}
}

// /getMessageStatus?mid=UID&recipient=urn
- (void)GET_getMessageStatus:(MSHttpTransaction *)tr
{
  NSString *messageID= [[tr urlQueryParameters] objectForKey:MESSENGER_QUERY_PARAM_MESSAGE_ID] ;   
  if(![messageID length]) {
    //[self logWithLevel:MHAppError log:@"/%@ : no message ID or no enveloppe type specified in query string", MESSENGER_SUB_URL_GET_MSG_STATUS] ;
    [tr write:MSHttpCodeBadRequest];} 
  else {
    NSDictionary *messageStatus= [_messengerDBAccessor getMessageStatusForURN:[[tr session] recipientURN] andMessageID:messageID] ;
    if(!messageStatus) {
      //[self logWithLevel:MHAppError log:@"/%@ : failed to fetch message", MESSENGER_SUB_URL_GET_MSG_STATUS] ;
      [tr write:MSHttpCodeInternalServerError]; }
    else {
      [tr write:MSHttpCodeOk mste:messageStatus]; }}
}

// /setMessageStatus?mid=42&status=2
- (void)GET_setMessageStatus:(MSHttpTransaction *)tr
{
  NSDictionary *queryParams= [tr urlQueryParameters];
  NSString *messageID= [queryParams objectForKey:MESSENGER_QUERY_PARAM_MESSAGE_ID] ;
  id status= [queryParams objectForKey:MESSENGER_QUERY_PARAM_STATUS];
      
  if(![messageID length] || !status) {
    //[self logWithLevel:MHAppError log:@"/%@ : no message ID or status specified in query string, or status is nul", MESSENGER_SUB_URL_SET_MSG_STATUS] ;
    [tr write:MSHttpCodeBadRequest];}
  else {
    BOOL statusChanged ;
    statusChanged= [_messengerDBAccessor setMessageStatusForURN:[[tr session] senderURN] andMessageID:messageID newStatus:[status intValue]] ;
    [tr write:statusChanged ? MSHttpCodeOk : MSHttpCodeInternalServerError];}
}

// /deleteMessage?mid=UID
- (void)GET_deleteMessage:(MSHttpTransaction *)tr
{
  NSString *messageID; BOOL messageDeleted;

  messageID= [[tr urlQueryParameters] objectForKey:MESSENGER_QUERY_PARAM_MESSAGE_ID];
  if(![messageID length]) {
    //[self logWithLevel:MHAppError log:@"/%@ : no message ID specified in query string", MESSENGER_SUB_URL_DEL_MSG] ;
    [tr write:MSHttpCodeBadRequest];}
  else {
    messageDeleted = [_messengerDBAccessor deleteMessageForURN:[[tr session] senderURN] andMessageID:messageID] ;
    [tr write:messageDeleted ? MSHttpCodeOk : MSHttpCodeInternalServerError];}
}

@end
