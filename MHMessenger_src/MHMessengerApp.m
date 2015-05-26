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

//#import <MASH/MASH.h>
//#import "DBMessengerMessage.h"
//#import "MHMessengerDBAccessor.h"
//#import "MHMessenger.h"

#import "MHMessenger_Private.h"
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

//mutex for base increments
@implementation MHMessengerApplication

+ (NSString *)applicationName { return @"Messenger" ; }
- (NSString *)applicationFullName { return @"MASH Messenger" ; }

+ (MSUInt)defaultAuthenticationMethods
{
    return MHAuthChallengedPasswordLogin | MHAuthPKChallengeAndURN ;
}

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
                [self logWithLevel:MHAppError log:@"Failed to create database directory"] ;
                return NO ;
            }
        }
        
        scriptPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"1" ofType:@"sql"] ;
        
        runOK = [_messengerDBAccessor runSQLScript:scriptPath] ; //run creation script
        if(!runOK) { //db init script
            [self logWithLevel:MHAppError log:@"Failed to run sql create script : %@",scriptPath] ;
            return NO ;
        }

    }
    
    //-2 database exist, check if need to run update scripts
    dbVersion = [_messengerDBAccessor getDBVersion] ;
    scriptPath = [[NSBundle bundleForClass:[self class]] pathForResource:[NSString stringWithFormat:@"%d",++dbVersion] ofType:@"sql"] ;
    if(scriptPath) { //update script exist, backup current db
        NSString *backupFileName = [NSString stringWithFormat:@"messengerDB_%@.bak",[[NSCalendarDate date] descriptionWithCalendarFormat:@"%Y%m%d%H%M%S"]] ;
        MSBuffer *dbBuf = [MSBuffer bufferWithContentsOfFile:dbPath] ;
        [dbBuf writeToFile:[dbDirectoryPath stringByAppendingPathComponent:backupFileName] atomically:YES] ;
    }
    
    while(scriptPath)
    {
        if(![_messengerDBAccessor runSQLScript:scriptPath])
        {
            [self logWithLevel:MHAppError log:@"Failed to run sql update script : %@",scriptPath] ;
            return NO ;
        }
        scriptPath = [[NSBundle bundleForClass:[self class]] pathForResource:[NSString stringWithFormat:@"%d",++dbVersion] ofType:@"sql"] ;
    }
    

    return YES ;
}

- (BOOL)_initDatabaseWithParameters:(NSDictionary *)parameters
{
    if(![self parameterNamed:@"node"])
    {
        [self logWithLevel:MHAppError log:@"Cannot find messenger node name in config file (application parameters)"] ;
        return NO ;
    }
    ASSIGN(_node, [self parameterNamed:@"node"]) ;
    
    if(![self parameterNamed:@"database"])
    {
        [self logWithLevel:MHAppError log:@"Cannot find database connection dictionary in config file (application parameters)"] ;
        return NO ;
    }
  
    if(![parameters objectForKey:@"key"]) {
        char cstring[40]; NSString *key = nil;
        NSLog(@"Database password ?");
        scanf("%s", cstring);
        key= [NSString stringWithCString:cstring encoding:NSUTF8StringEncoding];
        if([key length] < 8)
        {
            [self logWithLevel:MHAppError log:@"Bad password proposal, at least 8 chars are required"] ;
            return NO ;
        }
        parameters = [MSDictionary mutableDictionaryWithDictionary:parameters];
        [(MSDictionary*)parameters setObject:key forKey:@"key"];
    }
    
    ASSIGN(_messengerDBAccessor, [MHMessengerDBAccessor messengerDBWithconnectionDictionary:parameters messengerApplication:self]) ;
    
    if(![self _databaseInitialisationAtPath:[parameters objectForKey:@"path"]]) {
        [self logWithLevel:MHAppError log:@"Failed to create database query tool could not find path parameter"] ;
        return NO ;
    }
    return YES ;
}

- (BOOL)_checkNetRepositoryAuthenticationParameters:(NSDictionary *)authenticationParameters
{
    NSString *urn = [authenticationParameters objectForKey:@"urn"] ;
    NSString *privateKey = [authenticationParameters objectForKey:@"privateKey"] ;
    BOOL isDir = NO ;
    
    if (![urn length])
    {
        [self logWithLevel:MHAppError log:@"Parameter not found : 'urn'"] ;
        return NO ;
    }
    
    if (![privateKey length])
    {
        [self logWithLevel:MHAppError log:@"Parameter not found : 'privateKey'"] ;
        return NO ;
    }
    
    if (! MSFileExistsAtPath(privateKey, &isDir) && !isDir)
    {
        [self logWithLevel:MHAppError log:@"PrivateKey file not found at path %@", privateKey] ;
        return NO ;
    }
    
    ASSIGN(_urn, urn) ;
    ASSIGN(_skPath, privateKey) ;
    
    return YES ;
}

- (BOOL)_performFirstAuthenticationOnNetRepository
{
    MSBuffer *skData = [MSBuffer bufferWithContentsOfFile:_skPath] ;
    MHNetRepositoryClient *client = [MHNetRepositoryClient clientWithServerParameters:[self netRepositoryConnectionDictionary]
                                                                                  urn:_urn
                                                                            secretKey:skData] ;
    _netRepositoryClient = [client retain] ;
    
    return [client authenticate] ;
}

- (BOOL)_performNetRepositoryConnectionWithAuthenticationParameters:(NSDictionary *)authenticationParameters
{
    return [self _checkNetRepositoryAuthenticationParameters:authenticationParameters]
        && [self _performFirstAuthenticationOnNetRepository];
}

- (id)initOnBaseURL:(NSString *)url instanceName:(NSString *)instanceName withLogger:(id)logger parameters:(NSDictionary *)parameters
{
    if((self = [super initOnBaseURL:url instanceName:instanceName withLogger:logger parameters:parameters]))
    {
        NSDictionary *dbParams = [self parameterNamed:@"database"] ;
        NSDictionary *netRepositoryAuthentication = [self netRepositoryParameters] ;
        
        // check if parameters dictionaries are present
        if (! dbParams)
        {
            [self logWithLevel:MHAppError log:@"parameter dictionary missing : 'database'"] ;
            return nil ;
        }
        
        // TODO: This code doesn't do what it should
        if (! netRepositoryAuthentication)
        {
            [self logWithLevel:MHAppError log:@"parameter dictionary missing net repository configuration 'repositoryName'"] ;
            return nil ;
        }
        
        if (! netRepositoryAuthentication)
        {
            [self logWithLevel:MHAppError log:@"parameter dictionary missing : 'netRepository'"] ;
            return nil ;
        }
        
        // init database
        if (![self _initDatabaseWithParameters:dbParams]) {
            [self logWithLevel:MHAppError log:@"Failed to create database query tool"] ;
            return nil ;
        }
        
        // init repository connection
        mutex_init(self->_netRepositoryClientMutex) ;
        if (! [self _performNetRepositoryConnectionWithAuthenticationParameters:netRepositoryAuthentication])
        {
            [self logWithLevel:MHAppError log:@"Failed to initialise net repository connection"] ;
            return nil ;
        }
        
        return self ;
    }
    return nil ;
}

- (void)dealloc
{
    DESTROY(_node) ;
    DESTROY(_messengerDBAccessor) ;

    DESTROY(_skPath) ;
    DESTROY(_urn) ;
    
    DESTROY(_netRepositoryClient) ;
    mutex_delete(_netRepositoryClientMutex) ;
    
    [super dealloc] ;
}

- (void)clean {
    [_messengerDBAccessor cleanObsoleteMessages] ;
}

- (NSString *)makeUUID
{
    return [[NSProcessInfo processInfo] globallyUniqueString] ;
}

//session duration is short and never updated
+ (MSUInt)authentifiedSessionTimeout { return 600 ; }
- (BOOL)mustUpdateLastActivity { return NO ; }

- (DBMessengerMessage *)_parseMessage:(MHHTTPMessage *)httpMessage withEnvelopeType:(MHMessengerEnvelopeType)envelopeType envelopeLength:(MSULong)envelopeLength
{
    DBMessengerMessage *message = nil ;
    MSTimeInterval stampDateNow = [[MSDate date] timeIntervalSince1970] ;
    MSBuffer *httpMessageBufferObj = [httpMessage getCompleteBody] ;
    NSString *error = nil ;
    message = [DBMessengerMessage messageWithBuffer:httpMessageBufferObj envelopeType:envelopeType envelopeLength:envelopeLength error:&error] ;
    
    if(error) { [self logWithLevel:MHAppDebug log:error] ; }
    
    if (message)
    {
        if(! [message receivingDate]) { [message setReceivingDate:stampDateNow] ; }
        [message addRouteComponent:[self parameterNamed:@"node"]] ;
    }
    
    return message ;
}

- (DBMessengerMessage *)_parseMessageFromMessage:(MHHTTPMessage *)httpMessage
{
    DBMessengerMessage *message = nil ;
    //envelope
    NSString *envelopeTypeHeader = [httpMessage getHeader:MHHTTPEnvelopeType] ;
    MSULong envelopeLength = [[httpMessage getHeader:MHHTTPEnvelopeLength] longLongValue] ;
    MHMessengerEnvelopeType envelopeType = 0 ;
    
    if([MESSENGER_ENV_TYPE_PLAIN isEqualToString:envelopeTypeHeader]) { envelopeType = MHMEnvelopeTypePlain ; }
    else if([MESSENGER_ENV_TYPE_MSTE isEqualToString:envelopeTypeHeader]) { envelopeType = MHMEnvelopeTypeMSTE ; }
    
    //test mandatory headers
    if(!envelopeType || !envelopeLength) {
        if(!envelopeLength) { [self logWithLevel:MHAppDebug log:@"message parsing error : no envelopeLength"] ; }
        if(!envelopeType) { [self logWithLevel:MHAppDebug log:@"message parsing error : no envelopeType"] ; }
        return nil ;
    }
    
    switch (envelopeType) {
        case MHMEnvelopeTypePlain:
            message = [self _parseMessage:httpMessage withEnvelopeType:MHMEnvelopeTypePlain envelopeLength:envelopeLength] ;
            break;
        case MHMEnvelopeTypeMSTE :
            message = [self _parseMessage:httpMessage withEnvelopeType:MHMEnvelopeTypeMSTE envelopeLength:envelopeLength] ;
            break ;
        default:
            break;
    }
    
    return message ;
}

- (MSBuffer *)_encodeResponse:(id)response forAcceptedMimeTypes:(NSArray *)acceptedMimeTypes contentType:(NSString **)contentType responseFormat:(NSString **)responseFormat
{
    MSBuffer *encodedResponse = nil ;
    
    if (response && contentType && responseFormat)
    {
        if ([acceptedMimeTypes count] && [acceptedMimeTypes containsObject:MIMETYPE_JSON])
        {
            NSString *reponseStr = nil ;
            *contentType = MESSENGER_MESSAGE_FORMAT_JSON ;
            *responseFormat = MESSENGER_RESPONSE_FORMAT_JSON ;
#warning Pourquoi json et pas MSTE ?
            reponseStr = [response jsonString] ;
            encodedResponse = [MSBuffer bufferWithData:[reponseStr dataUsingEncoding:NSUTF8StringEncoding]] ;
            
        } else {
            *contentType = MESSENGER_MESSAGE_FORMAT_MSTE ;
            *responseFormat = MESSENGER_RESPONSE_FORMAT_MSTE ;
            encodedResponse = [response MSTEncodedBuffer] ;
        }
    }
    else MSRaise(NSInternalInconsistencyException, @"_encodeResponse : response, contentType or responseFormat not specified") ;
    
    return encodedResponse ;
}

- (void)POST_sendMessage:(MHNotification *)notification
{
    DBMessengerMessage *message ;
    NSArray *messageIDs ;
    
    message = [self _parseMessageFromMessage:[notification message]] ;
    
    if(!message)
    {
        [self logWithLevel:MHAppError log:@"/%@ : Message parsing failed", MESSENGER_SUB_URL_SEND_MSG] ;
        MHRESPOND_TO_CLIENT(nil, HTTPBadRequest, nil) ;
    } else
    {
        messageIDs = [_messengerDBAccessor createIDAndstoreMessage:message forURN:GET_SESSION_MEMBER(SESSION_PARAM_URN)] ;
        if(![messageIDs count])
        {
            [self logWithLevel:MHAppError log:@"/%@ : Message not saved in database", MESSENGER_SUB_URL_SEND_MSG] ;
            MHRESPOND_TO_CLIENT(nil, HTTPInternalError, nil) ;
        } else {
            MSBuffer *buf = [messageIDs MSTEncodedBuffer] ;
            [self logWithLevel:MHAppDebug log:@"/%@ : Message saved in database", MESSENGER_SUB_URL_SEND_MSG] ;
            MHRESPOND_TO_CLIENT(buf, HTTPOK, nil) ;
        }
    }
}

// /findMessages?tid=GVeMIFsTours&status=1&xid=42=max=3&recipient=urn
- (void)GET_findMessages:(MHNotification *)notification
{
    NSDictionary *queryParams = [[notification message]  parameters] ;
    NSArray *messageID = [[queryParams objectForKey:MESSENGER_QUERY_PARAM_MESSAGE_ID] componentsSeparatedByString:MESSENGER_QUERY_PARAM_OR_SEPARATOR] ;
    NSArray *thread = [[queryParams objectForKey:MESSENGER_QUERY_PARAM_THREAD_ID] componentsSeparatedByString:MESSENGER_QUERY_PARAM_OR_SEPARATOR] ;
    NSNumber *max = [NSNumber numberWithInt:[[queryParams objectForKey:MESSENGER_QUERY_PARAM_MAX] intValue]] ;
    NSString *recipient = [queryParams objectForKey:MESSENGER_QUERY_PARAM_RECIPIENT];
    
    if(![messageID count] && !([thread count] && [max intValue]>0)) {
        [self logWithLevel:MHAppError log:@"/%@ : no thread and limit>0 or message ID specified in query string '%@'", MESSENGER_SUB_URL_FIND_MSG, queryParams] ;
        MHRESPOND_TO_CLIENT(nil, HTTPBadRequest, nil) ;
    } else if(recipient && ![self _hasRightsToAccessMessagesOf:recipient withNotification:notification]) {
        [self logWithLevel:MHAppError log:@"/%@ : you don't have access to '%@' messages", MESSENGER_SUB_URL_FIND_MSG, recipient] ;
        MHRESPOND_TO_CLIENT(nil, HTTPBadRequest, nil) ;
    } else {
        NSDictionary *messages = nil ;
        
        if(!recipient)
            recipient = GET_SESSION_MEMBER(SESSION_PARAM_URN);
        messages = [_messengerDBAccessor findMessagesForURN:recipient andParameters:queryParams] ;
        if(! [messages objectForKey:@"messages"])
        {
            [self logWithLevel:MHAppError log:@"/%@ : failed to fetch message list", MESSENGER_SUB_URL_FIND_MSG] ;
            MHRESPOND_TO_CLIENT(nil, HTTPInternalError, nil) ;
        } else {
            NSString *contentType = nil ;
            NSString *responseFormat = nil ;
            NSArray *acceptedMimeTypes = [[[notification message] getHeader:MHHTTPClientTypes] componentsSeparatedByString:@","] ;
            
            MSBuffer *encodedResponse = [self _encodeResponse:messages forAcceptedMimeTypes:acceptedMimeTypes contentType:&contentType responseFormat:&responseFormat] ;

            NSDictionary *additionalHeaders = [NSDictionary dictionaryWithObjectsAndKeys:contentType, @"Content-Type",
                                                                                        responseFormat, MESSENGER_HEAD_RESPONSE_FORMAT, nil] ;
            
            
            [self logWithLevel:MHAppDebug log:@"/%@ : query succeeded", MESSENGER_SUB_URL_FIND_MSG] ;
            MHRESPOND_TO_CLIENT(encodedResponse, HTTPOK, additionalHeaders) ;
        }
    }
}

- (BOOL)_hasRightsToAccessMessagesOf:(NSString*)recipientUrn withNotification:(MHNotification *)notification
{
    id allowedRecipients ;
    
    allowedRecipients = GET_SESSION_MEMBER(SESSION_PARAM_ALLOWED_RECIPIENTS);
    if(allowedRecipients == nil) {
        mutex_lock(_netRepositoryClientMutex);
        allowedRecipients = [_netRepositoryClient allowedApplicationUrnsForAuthenticable:GET_SESSION_MEMBER(SESSION_PARAM_URN)] ;
        mutex_unlock(_netRepositoryClientMutex);
        allowedRecipients = allowedRecipients ? [NSSet setWithArray:allowedRecipients] : [NSSet set];
        SET_SESSION_MEMBER(allowedRecipients, SESSION_PARAM_ALLOWED_RECIPIENTS);
    }
    return [allowedRecipients containsObject:recipientUrn];
}

- (MHMessengerEnvelopeType)_envelopeTypeForString:(NSString *)queryParam
{
    MHMessengerEnvelopeType envelopeType = MHMEnvelopeTypeMSTE ;
    
    if ([MESSENGER_ENV_TYPE_PLAIN isEqualToString:queryParam])
    {
        envelopeType = MHMEnvelopeTypePlain ;
    }

    return envelopeType ;
}

// /getMessage?mid=UID
- (void)GET_getMessage:(MHNotification *)notification
{
    NSDictionary *queryParams = [[notification message] parameters] ;
    NSString *messageID = [queryParams objectForKey:MESSENGER_QUERY_PARAM_MESSAGE_ID] ;
    NSString *recipient = [queryParams objectForKey:MESSENGER_QUERY_PARAM_RECIPIENT];
    NSString *envelopeTypeStr = [queryParams objectForKey:MESSENGER_QUERY_PARAM_MESSAGE_ENV] ;
    MHMessengerEnvelopeType envelopeType = [self _envelopeTypeForString:envelopeTypeStr] ;
    
    if(![messageID length] || !envelopeType)
    {
        [self logWithLevel:MHAppError log:@"/%@ : no message ID or wrong envelope type specified in query string", MESSENGER_SUB_URL_GET_MSG] ;
        MHRESPOND_TO_CLIENT(nil, HTTPBadRequest, nil) ;
    } else if(recipient && ![self _hasRightsToAccessMessagesOf:recipient withNotification:notification]) {
        [self logWithLevel:MHAppError log:@"/%@ : you don't have access to '%@' messages", MESSENGER_SUB_URL_FIND_MSG, recipient] ;
        MHRESPOND_TO_CLIENT(nil, HTTPBadRequest, nil) ;
    }
    else {
        MHMessengerMessage *message ;
        MSULong envelopeLength = 0 ;
        
        if(!recipient)
            recipient = GET_SESSION_MEMBER(SESSION_PARAM_URN);
        message = [_messengerDBAccessor getMessageForURN:recipient andMessageID:messageID] ;
        if(!message)
        {
            [self logWithLevel:MHAppError log:@"/%@ : failed to fetch message", MESSENGER_SUB_URL_GET_MSG] ;
            MHRESPOND_TO_CLIENT(nil, HTTPInternalError, nil) ;
        } else {
            NSString *contentType = nil ;
            MSBuffer *messageBuffer = [message dataWithEnvelopeType:envelopeType envelopeLength:&envelopeLength contentType:&contentType] ;
            NSDictionary *additionalHeaders = [NSDictionary dictionaryWithObjectsAndKeys:
                                               contentType, @"Content-Type",
                                               envelopeTypeStr, MESSENGER_HEAD_ENVELOPPE_TYPE,
                                               [NSNumber numberWithLong:envelopeLength], MESSENGER_HEAD_ENVELOPPE_LENGTH,
                                               nil] ;

            MHRESPOND_TO_CLIENT(messageBuffer, HTTPOK, additionalHeaders) ;
        }
    }
}

// /getMessageStatus?mid=UID
- (void)GET_getMessageStatus:(MHNotification *)notification
{
    NSDictionary *queryParams = [[notification message]  parameters] ;
    NSString *messageID = [queryParams objectForKey:MESSENGER_QUERY_PARAM_MESSAGE_ID] ;
        
    if(![messageID length])
    {
        [self logWithLevel:MHAppError log:@"/%@ : no message ID or no enveloppe type specified in query string", MESSENGER_SUB_URL_GET_MSG_STATUS] ;
        MHRESPOND_TO_CLIENT(nil, HTTPBadRequest, nil) ;
    } else {
        NSDictionary *messageStatus = [_messengerDBAccessor getMessageStatusForURN:GET_SESSION_MEMBER(SESSION_PARAM_URN) andMessageID:messageID] ;
        
        if(!messageStatus)
        {
            [self logWithLevel:MHAppError log:@"/%@ : failed to fetch message", MESSENGER_SUB_URL_GET_MSG_STATUS] ;
            MHRESPOND_TO_CLIENT(nil, HTTPInternalError, nil) ;
        } else {
            NSString *contentType = nil ;
            NSString *responseFormat = nil ;
            NSArray *acceptedMimeTypes = [[[notification message] getHeader:MHHTTPClientTypes] componentsSeparatedByString:@","] ;

            MSBuffer *encodedResponse = [self _encodeResponse:messageStatus forAcceptedMimeTypes:acceptedMimeTypes contentType:&contentType responseFormat:&responseFormat] ;

            NSDictionary *additionalHeaders = [NSDictionary dictionaryWithObjectsAndKeys:contentType, @"Content-Type",
                                               responseFormat, MESSENGER_HEAD_RESPONSE_FORMAT, nil] ;
            
            MHRESPOND_TO_CLIENT(encodedResponse, HTTPOK, additionalHeaders) ;
        }
    }
}

// /setMessageStatus?mid=42&status=2
- (void)GET_setMessageStatus:(MHNotification *)notification
{
    NSDictionary *queryParams = [[notification message]  parameters] ;
    NSString *messageID = [queryParams objectForKey:MESSENGER_QUERY_PARAM_MESSAGE_ID] ;
    NSString *urn = [queryParams objectForKey:MESSENGER_QUERY_PARAM_URN];
    id status = [queryParams objectForKey:MESSENGER_QUERY_PARAM_STATUS];
        
    if(![messageID length] || !status)
    {
        [self logWithLevel:MHAppError log:@"/%@ : no message ID or status specified in query string, or status is nul", MESSENGER_SUB_URL_SET_MSG_STATUS] ;
        MHRESPOND_TO_CLIENT(nil, HTTPBadRequest, nil) ;
    } else if(urn && ![self _hasRightsToAccessMessagesOf:urn withNotification:notification]) {
        [self logWithLevel:MHAppError log:@"/%@ : you don't have access to '%@' messages", MESSENGER_SUB_URL_FIND_MSG, urn] ;
        MHRESPOND_TO_CLIENT(nil, HTTPBadRequest, nil) ;
    } else {
        BOOL statusChanged ;
        if(!urn) urn=GET_SESSION_MEMBER(SESSION_PARAM_URN);
        statusChanged = [_messengerDBAccessor setMessageStatusForURN:GET_SESSION_MEMBER(SESSION_PARAM_URN) andMessageID:messageID newStatus:[status intValue]] ;
        
        if(!statusChanged)
        {
            [self logWithLevel:MHAppError log:@"/%@ : failed", MESSENGER_SUB_URL_SET_MSG_STATUS] ;
            MHRESPOND_TO_CLIENT(nil, HTTPInternalError, nil) ;
        } else {
            MHRESPOND_TO_CLIENT(nil, HTTPOK, nil) ;
        }
    }
}

// /deleteMessage?mid=UID
- (void)GET_deleteMessage:(MHNotification *)notification
{
    NSDictionary *queryParams = [[notification message]  parameters] ;
    NSString *urn = [queryParams objectForKey:MESSENGER_QUERY_PARAM_URN];
    NSString *messageID = [queryParams objectForKey:MESSENGER_QUERY_PARAM_MESSAGE_ID] ;
        
    if(![messageID length])
    {
        [self logWithLevel:MHAppError log:@"/%@ : no message ID specified in query string", MESSENGER_SUB_URL_DEL_MSG] ;
        MHRESPOND_TO_CLIENT(nil, HTTPBadRequest, nil) ;
    } else if(urn && ![self _hasRightsToAccessMessagesOf:urn withNotification:notification]) {
        [self logWithLevel:MHAppError log:@"/%@ : you don't have access to '%@' messages", MESSENGER_SUB_URL_FIND_MSG, urn] ;
        MHRESPOND_TO_CLIENT(nil, HTTPBadRequest, nil) ;
    } else {
        BOOL messageDeleted ;
        if(!urn) urn=GET_SESSION_MEMBER(SESSION_PARAM_URN);
        messageDeleted = [_messengerDBAccessor deleteMessageForURN:urn andMessageID:messageID] ;
        
        if(!messageDeleted)
        {
            [self logWithLevel:MHAppError log:@"/%@ : failed", MESSENGER_SUB_URL_DEL_MSG] ;
            MHRESPOND_TO_CLIENT(nil, HTTPInternalError, nil) ;
        } else {
            MHRESPOND_TO_CLIENT(nil, HTTPOK, nil) ;
        }
    }
}

// user connection with login/password on messenger
- (void)validateAuthentication:(MHNotification *)notification
                         login:(NSString *)login
            challengedPassword:(NSString *)challengedPassword
              sessionChallenge:(NSString *)storedChallenge
                   certificate:(MSCertificate *)certificate
{
    BOOL auth;
    NSString *urn;
    
    mutex_lock(_netRepositoryClientMutex);
    auth = [_netRepositoryClient verifyChallengedPassword:challengedPassword forLogin:login andChallenge:storedChallenge] ;
    urn = auth ? [_netRepositoryClient urnForLogin:login] : nil;
    mutex_unlock(_netRepositoryClientMutex);
    
    if(urn)
        SET_SESSION_MEMBER(urn, SESSION_PARAM_URN);
    
    if ([_logger logLevel] <= MHAppDebug)
    {
        if (auth) {
            [self logWithLevel:MHAppDebug log:@"Challenge Authentication success for login '%@'", login] ;
        } else {
            [self logWithLevel:MHAppDebug log:@"Challenge Authentication failure for login '%@'", login] ;
        }
    }
    
    MHVALIDATE_AUTHENTICATION(auth, nil) ;
}

// public key challenge authentication init
- (NSString *)publicKeyForURN:(NSString *)urn
{
    NSString *pk ;
    mutex_lock(_netRepositoryClientMutex);
    pk = [_netRepositoryClient publicKeyForURN:urn] ;
    mutex_unlock(_netRepositoryClientMutex);
    return pk;
}

- (NSString *)generateChallengeInfoForLogin:(NSString *)login withSession:(MHSession*)session
{
    NSString *challengeInfo ;
    mutex_lock(_netRepositoryClientMutex);
    challengeInfo = [_netRepositoryClient challengeInfoForLogin:login] ;
    mutex_unlock(_netRepositoryClientMutex);
    return challengeInfo;
}

@end
