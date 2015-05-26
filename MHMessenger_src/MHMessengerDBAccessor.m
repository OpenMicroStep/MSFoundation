/*
 
 MHMessengerDBAccessor.m
 
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
//#import "MHMessenger.h"
//#import "MHMessengerDBAccessor.h"

#import "MHMessenger_Private.h"

@implementation MHMessengerDBAccessor

+ (id)messengerDBWithconnectionDictionary:(NSDictionary *)connectionDictionary messengerApplication:(MHMessenger *)application
{
    return [[[self alloc] initWithconnectionDictionary:connectionDictionary messengerApplication:application] autorelease] ;
}

- (id)initWithconnectionDictionary:(NSDictionary *)connectionDictionary messengerApplication:(MHMessenger *)application
{
    if([connectionDictionary isKindOfClass:[NSDictionary class]])
        connectionDictionary= [MSDictionary dictionaryWithDictionary:connectionDictionary];
    ASSIGN(_connectionPool, [MSDBConnectionPool connectionPoolWithDictionnary:(MSDictionary *)connectionDictionary]) ;
    ASSIGN(_messenger, application) ;
    mutex_init(_messageGroupMutex) ;
    
    return self ;
}

- (void)dealloc
{
    DESTROY(_messenger) ;
    DESTROY(_connectionPool) ;
    mutex_delete(_messageGroupMutex) ;
    [super dealloc] ;
}

- (DBMessengerMessage *)_messageFromDatabaseRow:(MSRow *)row
{
    DBMessengerMessage *message = nil ;
    MSBuffer *content = nil ;
    char *utf8Str ;

    utf8Str = (char *)[[row objectForKey:DB_TABLE_MESSAGE_COL_CONTENT] UTF8String] ;
    content = AUTORELEASE(MSCreateBufferWithBytes(utf8Str, strlen(utf8Str))) ;
    
    message = [DBMessengerMessage messageFrom:[row objectForKey:DB_TABLE_MESSAGE_COL_SENDER]
                                           to:[row objectForKey:DB_TABLE_MESSAGE_COL_RECIPIENT]
                                       thread:[row objectForKey:DB_TABLE_MESSAGE_COL_THREAD]
                                  contentType:[row objectForKey:DB_TABLE_MESSAGE_COL_CONTENT_TYPE]
                                base64Content:content] ;
    
    [message setMessageID:[row objectForKey:DB_TABLE_MESSAGE_COL_MESSAGE_ID]] ;
    [message setCreationDate:[(NSNumber *)[row objectForKey:DB_TABLE_MESSAGE_COL_CREATION_DATE] longLongValue]] ;
    [message setReceivingDate:[(NSNumber *)[row objectForKey:DB_TABLE_MESSAGE_COL_RECEIVING_DATE] longLongValue]] ;
    [message setValidity:[(NSNumber *)[row objectForKey:DB_TABLE_MESSAGE_COL_VALIDITY] intValue]] ;
    [message setPriority:[(NSNumber *)[row objectForKey:DB_TABLE_MESSAGE_COL_PRIORITY] intValue]] ;
    [message setRoute:[row objectForKey:DB_TABLE_MESSAGE_COL_ROUTE]] ;
    [message setStatus:[(NSNumber *)[row objectForKey:DB_TABLE_MESSAGE_COL_STATUS] intValue]] ;
    [message setExternalReference:[row objectForKey:DB_TABLE_MESSAGE_COL_EXTERNAL_REF]] ;
    
    return message ;
}

- (MSDBConnection *)_connectDatabase
{
    MSDBConnection *conn = [_connectionPool requireConnection] ;
    if(![conn connect]) { MSRaise(NSInternalInconsistencyException, @"Could not connect to database") ; }
    return conn ;
}

- (void)_disconnectDatabase:(MSDBConnection *)conn
{
    [_connectionPool releaseConnection:conn];
}

-(MSDBConnection*)_databaseBeginTransaction
{
    MSDBConnection *conn = [self _connectDatabase] ;
    if(![conn beginTransaction])
        conn= nil;
    return conn;
}

-(BOOL)_databaseEndTransactionOn:(MSDBConnection*)conn byCommit:(BOOL)commit withMessage:(NSString *)msg withReason:(NSString *)reason
{
    BOOL ret= NO;
    if(!conn) {
        [_messenger logWithLevel:MHAppError log:@"%@ failed : unable to connect or to enter transaction", msg];
    }
    else if (commit) {
        if(![conn commit])
            [_messenger logWithLevel:MHAppError log:@"%@ failed : unable to commit changes", msg];
        else
            ret= YES;
    }
    else {
        [_messenger logWithLevel:MHAppError log:@"%@ failed : %@", msg, reason ? reason : [conn lastError]];
        if(![conn rollback])
            [_messenger logWithLevel:MHAppError log:@"%@ failed : unable to rollback changes", msg];
    }
    [self _disconnectDatabase:conn];
    return ret;
}

-(BOOL)_databaseEndTransactionOn:(MSDBConnection*)conn byCommit:(BOOL)commit withMessage:(NSString *)msg
{
    return [self _databaseEndTransactionOn:conn byCommit:commit withMessage:msg withReason:nil];
}

- (BOOL)_checkMessageSenderConformity:(DBMessengerMessage *)message forURN:(NSString *)urn
{
    BOOL isConform;
    if (!(isConform= [urn isEqualToString:[message sender]]))
        [_messenger logWithLevel:MHAppError log:@"message not conform : connected user with urn '%@' is not the message sender", urn] ;
    return isConform ;
}

- (BOOL)_deleteOldPersistentMessagesLike:(DBMessengerMessage *)message connection:(MSDBConnection *)conn
{
    BOOL ret= YES;
    MSDBResultSet *result = nil ;
    
    result = [conn select:[NSArray arrayWithObject:DB_TABLE_MESSAGE_COL_MESSAGE_ID]
                     from:DB_TABLE_MESSAGE
                    where:[NSString stringWithFormat:@"%@=? AND %@=? AND %@=? AND %@=0", DB_TABLE_MESSAGE_COL_SENDER, DB_TABLE_MESSAGE_COL_RECIPIENT, DB_TABLE_MESSAGE_COL_THREAD, DB_TABLE_MESSAGE_COL_VALIDITY]
             withBindings:[NSArray arrayWithObjects:[message sender], [[message recipients] componentsJoinedByString:@","], [message thread], nil]] ;
    
    while(ret && [result nextRow]) {
        id mid= [result objectAtColumn:0];
        [_messenger logWithLevel:MHAppDebug log:@"Deleting old persistent message '%@'...", mid] ;
        ret = [conn deleteFrom:DB_TABLE_MESSAGE
                         where:[NSString stringWithFormat:@"%@=?", DB_TABLE_MESSAGE_COL_MESSAGE_ID]
                  withBindings:[NSArray arrayWithObject:mid]] != -1;
    }
    
    return ret;
}

- (NSArray *)createIDAndstoreMessage:(DBMessengerMessage *)message forURN:(NSString *)urn
{
    BOOL res = YES ;
    MSArray *uuids = nil ;

    if ((res = [self _checkMessageSenderConformity:message forURN:urn]))
    {
        MSDBConnection *conn = [self _databaseBeginTransaction] ;
        NSEnumerator *recipients = [[message recipients] objectEnumerator] ;
        NSString *recipient ;
        uuids = [MSArray mutableArray] ;
        
        //set messageGroup
        [message setMessageGroup:[self nextMessageGroup]] ;
        
        while(res && (recipient = [recipients nextObject]))
        {
            NSString *UUID = [_messenger makeUUID] ;
            [uuids addObject:UUID] ;
            [message setRecipients:[MSArray arrayWithObject:recipient]] ;
            [message setMessageID:UUID] ;
            if ([message isPersistent]) //persistent message, must destroy former messages with same (thread, sender and single recipient).
                res = [self _deleteOldPersistentMessagesLike:message connection:conn] ;
            if(res)
                res = [conn insert:[message databaseDictionary] into:DB_TABLE_MESSAGE] ;
        }
        
        res= [self _databaseEndTransactionOn:conn byCommit:res withMessage:@"Message creation"];
    }
    
    return res ? uuids : nil;
}

- (NSString *)_makeFindMessagesQueryForURN:(NSString *)urn andParameters:(NSDictionary *)parameters countRows:(BOOL)countRows connection:(MSDBConnection *)conn
{
    NSString *additionalWhere = @"" ;
    NSArray *values ;
    NSString *param, *value ;
    NSString *column = nil ;
    NSEnumerator *queryParamsEnum = [parameters keyEnumerator] ;
    NSString *max = nil ;
    NSString *pos = nil ;
    NSString *query = nil ;
    NSString *escapedURN = [conn escapeString:urn withQuotes:YES] ;
    
    
    while ((param = [queryParamsEnum nextObject])) {
        values = [[parameters objectForKey:param] componentsSeparatedByString:MESSENGER_QUERY_PARAM_OR_SEPARATOR] ;
        if([values count])
        {
            NSEnumerator *valueEnum ;
            BOOL first = YES ;
            NSString *where = @"" ;
            
            if([param isEqualToString:MESSENGER_QUERY_PARAM_MESSAGE_ID]) { column = DB_TABLE_MESSAGE_COL_MESSAGE_ID ; }
            else if([param isEqualToString:MESSENGER_QUERY_PARAM_THREAD_ID]) { column = DB_TABLE_MESSAGE_COL_THREAD ; }
            else if([param isEqualToString:MESSENGER_QUERY_PARAM_EXTERNAL_REF]) { column = DB_TABLE_MESSAGE_COL_EXTERNAL_REF ; }
            else if([param isEqualToString:MESSENGER_QUERY_PARAM_STATUS]) { column = DB_TABLE_MESSAGE_COL_STATUS ; }
            else if([param isEqualToString:MESSENGER_QUERY_PARAM_MAX]) { if(!countRows) { max = [values objectAtIndex:0] ; } continue ; } //add limit parameter to the query : not a real database column, beak.
            else if([param isEqualToString:MESSENGER_QUERY_PARAM_POS]) { if(!countRows) { pos = [values objectAtIndex:0] ; } continue ; }
            else { continue; }
            valueEnum = [values objectEnumerator] ;
            
            while((value = [valueEnum nextObject]))
            {
                if(![param isEqualToString:MESSENGER_QUERY_PARAM_STATUS])
                {
                    value = [conn escapeString:value withQuotes:YES] ;
                }
                
                where = [where stringByAppendingString:[NSString stringWithFormat:(first) ? @"%@=%@" : @" OR %@=%@",column,value]] ;
                
                if(first) first = NO ;
            }
            
            additionalWhere = [additionalWhere stringByAppendingString:[NSString stringWithFormat:@" AND (%@)",where]] ;
        }
    }
    
    query = [NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE ((%@=%@) OR (%@=%@ AND %@=0))%@%@;",
             countRows ? [NSString stringWithFormat:@"COUNT(%@)",DB_TABLE_MESSAGE_COL_MESSAGE_ID] : DB_TABLE_MESSAGE_COL_MESSAGE_ID,
             DB_TABLE_MESSAGE,
             DB_TABLE_MESSAGE_COL_RECIPIENT,
             escapedURN,
             DB_TABLE_MESSAGE_COL_SENDER,
             escapedURN,
             DB_TABLE_MESSAGE_COL_VALIDITY,
             additionalWhere,
             max ? (pos ? [NSString stringWithFormat:@" LIMIT %@, %@", pos, max] : [NSString stringWithFormat:@" LIMIT %@", max]) : @""] ;
    
    return query ;
}

- (NSNumber *)_countMessagesFoundForURN:(NSString *)urn andParameters:(NSDictionary *)parameters countRows:(BOOL)countRows connection:(MSDBConnection *)conn
{
    NSString *countQuery = nil ;
    MSDBResultSet *result = nil ;
    NSNumber *count = [NSNumber numberWithInt:0] ;
    
    countQuery = [self _makeFindMessagesQueryForURN:urn andParameters:parameters countRows:YES connection:conn] ;
    result = [conn fetchWithRequest:countQuery] ;
    
    if([result nextRow]) { count = [result objectAtColumn:0] ; }
    
    return count ;
}

- (NSArray *)_messagesFoundForURN:(NSString *)urn andParameters:(NSDictionary *)parameters countRows:(BOOL)countRows connection:(MSDBConnection *)conn
{
    NSMutableArray *messageIDs = [NSMutableArray array] ;
    NSString *select = [self _makeFindMessagesQueryForURN:urn andParameters:parameters countRows:NO connection:conn] ;
    MSDBResultSet *result = [conn fetchWithRequest:select] ;
    
    while ([result nextRow]) {
        [messageIDs addObject:[[result rowDictionary] objectForKey:DB_TABLE_MESSAGE_COL_MESSAGE_ID]] ;
    }
    
    return messageIDs ;
}

- (NSDictionary *)findMessagesForURN:(NSString *)urn andParameters:(NSDictionary *)parameters
{
    MSDBConnection *conn = nil ;
    NSNumber *messagesCount = nil ;
    NSArray *messageIDs ;
    BOOL hasMore ;
    
    conn = [self _connectDatabase] ;
    NSLog(@"findMessagesForURN:%@ andParameters:%@", urn, parameters);
    messagesCount = [self _countMessagesFoundForURN:urn andParameters:parameters countRows:YES connection:conn] ;
    messageIDs = [self _messagesFoundForURN:urn andParameters:parameters countRows:NO connection:conn] ;
    hasMore= ([messagesCount longValue] - [messageIDs count] > 0);
    [self _disconnectDatabase:conn] ;
            
    return [NSDictionary dictionaryWithObjectsAndKeys:messageIDs, MESSENGER_RESPONSE_FIND_MESSAGES, [NSNumber numberWithBool:hasMore], MESSENGER_RESPONSE_FIND_HAS_MORE, nil] ;
}

- (MHMessengerMessage *)getMessageForURN:(NSString *)urn andMessageID:(NSString *)messageID
{
    MSDBResultSet *result = nil ;
    MSDBConnection *conn = nil ;
    NSString *select = nil ;
    DBMessengerMessage *message = nil ;
    
    //perform query
    conn = [self _connectDatabase] ;
    
    select = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%@ AND %@=%@;",
              DB_TABLE_MESSAGE,
              DB_TABLE_MESSAGE_COL_RECIPIENT,
              [conn escapeString:urn withQuotes:YES],
              DB_TABLE_MESSAGE_COL_MESSAGE_ID,
              [conn escapeString:messageID withQuotes:YES]] ;
    
    result = [conn fetchWithRequest:select] ;
    
    //get data
    if([result nextRow])
    {
        message = [self _messageFromDatabaseRow:[result rowDictionary]] ;
    }
    
    [self _disconnectDatabase:conn] ;
    
    return message ;
}

- (NSDictionary *)getMessageStatusForURN:(NSString *)urn andMessageID:(NSString *)messageID
{
    NSDictionary *responseDic = nil ;
    MSInt status = 0 ;
    MSDBResultSet *result = nil ;
    MSDBConnection *conn = nil ;
    NSString *select = nil ;
    
    conn = [self _connectDatabase] ;
    
    select = [NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@=%@ AND %@=%@;",
              DB_TABLE_MESSAGE_COL_STATUS,
              DB_TABLE_MESSAGE,
              DB_TABLE_MESSAGE_COL_RECIPIENT,
              [conn escapeString:urn withQuotes:YES],
              DB_TABLE_MESSAGE_COL_MESSAGE_ID,
              [conn escapeString:messageID withQuotes:YES]] ;
    
    //perform query
    result = [conn fetchWithRequest:select] ;
    
    //get data
    if([result nextRow])
    {
        status =  [(NSNumber *)[[result rowDictionary] objectForKey:DB_TABLE_MESSAGE_COL_STATUS] intValue] ;
    }
    
    [self _disconnectDatabase:conn] ;
    
    if (status) { responseDic = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:status] forKey:MESSENGER_RESPONSE_GET_STATUS] ; }
    
    return responseDic ;
}

- (BOOL)setMessageStatusForURN:(NSString *)urn andMessageID:(NSString *)messageID newStatus:(MSInt)status
{
    BOOL res = YES ;
    MSDBConnection *conn = [self _databaseBeginTransaction] ;
    
    res = [conn update:DB_TABLE_MESSAGE
                   set:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d",status] forKey:DB_TABLE_MESSAGE_COL_STATUS]
                 where:[NSString stringWithFormat:@"%@=? AND %@=?", DB_TABLE_MESSAGE_COL_RECIPIENT, DB_TABLE_MESSAGE_COL_MESSAGE_ID]
          withBindings:[NSArray arrayWithObjects:urn, messageID, nil]] != -1;
    
    return [self _databaseEndTransactionOn:conn byCommit:res withMessage:@"Message status change"];
}

- (MSRow *)_selectMessageForDeletetion:(MSDBConnection *)conn andMessageID:(NSString *)messageID
{
    MSRow *ret= nil;
    MSDBResultSet *result ;
    
    result = [conn select:[NSArray arrayWithObjects:DB_TABLE_MESSAGE_COL_MESSAGE_ID, DB_TABLE_MESSAGE_COL_RECIPIENT, DB_TABLE_MESSAGE_COL_SENDER, DB_TABLE_MESSAGE_COL_VALIDITY, nil]
                     from:DB_TABLE_MESSAGE
                    where:[NSString stringWithFormat:@"%@=?", DB_TABLE_MESSAGE_COL_MESSAGE_ID]
             withBindings:[NSArray arrayWithObject:messageID]] ;
    
    if([result nextRow])
        ret= [result rowDictionary] ;
    return ret ;
}

- (BOOL)deleteMessageForURN:(NSString *)urn andMessageID:messageID
{
    BOOL res = NO ;
    MSDBConnection *conn = [self _databaseBeginTransaction] ;
    NSString *reason= nil;
    MSRow *deletable ;
    
    //retrieve message by URN
    deletable = [self _selectMessageForDeletetion:conn andMessageID:messageID] ;
    if(deletable) {
        MSTimeInterval validity = [[deletable objectForKey:DB_TABLE_MESSAGE_COL_VALIDITY] unsignedLongLongValue] ;

        //test if UID can delete this message
        if(validity) {
            res= [urn isEqualToString:[deletable objectForKey:DB_TABLE_MESSAGE_COL_RECIPIENT]]; //non permanent message, recipient can delete
        }
        else {
            res= [urn isEqualToString:[deletable objectForKey:DB_TABLE_MESSAGE_COL_SENDER]]; //permanent message, sender can delete
        }
        
        if(res) {
            [_messenger logWithLevel:MHAppDebug log:@"Deleting message '%@'...",messageID] ;
            res= [conn deleteFrom:DB_TABLE_MESSAGE
                            where:[NSString stringWithFormat:@"%@=?", DB_TABLE_MESSAGE_COL_MESSAGE_ID]
                     withBindings:[NSArray arrayWithObject:messageID]];
        }
        else {
            reason= [NSString stringWithFormat:@"User '%@' not allowed to delete message '%@'",messageID] ;
        }
    }
    else {
        reason= [NSString stringWithFormat:@"'%@' not found", messageID] ;
    }
    
    return [self _databaseEndTransactionOn:conn byCommit:res withMessage:@"Message deletion" withReason:reason];
}

- (MSArray *)_obsoleteDeletableMessagesForConnection:(MSDBConnection *)conn date:(MSTimeInterval)stampDateNow
{

}

- (BOOL)cleanObsoleteMessages
{
    BOOL res = YES ;
    MSDBConnection *conn = [self _databaseBeginTransaction] ;
    MSTimeInterval stampDateNow = [[MSDate date] timeIntervalSince1970] ;
    MSDBResultSet *result ;
    NSString *where ;
    
    where= [NSString stringWithFormat:@"%@>0 AND (%@ + %@ < ?)", DB_TABLE_MESSAGE_COL_VALIDITY, DB_TABLE_MESSAGE_COL_RECEIVING_DATE, DB_TABLE_MESSAGE_COL_VALIDITY];
    result = [conn select:[NSArray arrayWithObject:DB_TABLE_MESSAGE_COL_MESSAGE_ID]
                     from:DB_TABLE_MESSAGE
                    where:where
             withBindings:[NSArray arrayWithObject:[NSNumber numberWithLongLong:stampDateNow]]];
    
    while(res && [result nextRow])
    {
        id messageID= [result objectAtColumn:0];
        [_messenger logWithLevel:MHAppDebug log:@"Deleting message '%@'...",messageID] ;
        res= [conn deleteFrom:DB_TABLE_MESSAGE
                        where:[NSString stringWithFormat:@"%@=?", DB_TABLE_MESSAGE_COL_MESSAGE_ID]
                 withBindings:[NSArray arrayWithObject:messageID]];
    }
    return [self _databaseEndTransactionOn:conn byCommit:res withMessage:@"Obsolete messages clean"];
}

- (MSULong)_nextMessageGroup
{
    MSULong nextID = 0 ;
    MSDBResultSet *result = nil ;
    MSDBConnection *conn = [self _connectDatabase] ;

    result = [conn select:[NSArray arrayWithObject:DB_TABLE_INDEXES_COL_VALUE]
                     from:DB_TABLE_INDEXES
                    where:[NSString stringWithFormat:@"%@=?", DB_TABLE_INDEXES_COL_NAME]
             withBindings:[NSArray arrayWithObject:MESSAGE_GROUP_INDEX]];
    if([result nextRow])
    {
        nextID =  [(NSNumber *)[[result rowDictionary] objectForKey:DB_TABLE_INDEXES_COL_VALUE] unsignedLongLongValue] ;
    }
    
    [self _disconnectDatabase:conn] ;
    return nextID ;
}

- (BOOL)_setNextMessageGroup:(MSULong)nextMessageGroup
{
    BOOL ret = NO ;
    MSDBConnection *conn = [self _databaseBeginTransaction] ;
    if(conn) {
        ret= [conn update:DB_TABLE_INDEXES
                      set:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedLongLong:nextMessageGroup], DB_TABLE_INDEXES_COL_VALUE, nil]
                    where:[NSString stringWithFormat:@"%@=?", DB_TABLE_INDEXES_COL_NAME]
             withBindings:[NSArray arrayWithObject:MESSAGE_GROUP_INDEX]] != -1;
    }
    return [self _databaseEndTransactionOn:conn byCommit:ret withMessage:@"MessageGroup index update"];
}

- (MSULong)nextMessageGroup
{
    MSULong nextID = 0 ;
    
    mutex_lock(_messageGroupMutex) ;
    nextID = [self _nextMessageGroup] ;
    if(!nextID)
    {
        MSRaise(NSInternalInconsistencyException, @"Could not get messageGroup index") ;
    }
    
    if(nextID == MSULongMax) { nextID = 0 ; }
    
    if(![self _setNextMessageGroup:nextID+1])
    {
        MSRaise(NSInternalInconsistencyException, @"Could not increment messageGroup index") ;
    }
    
    mutex_unlock(_messageGroupMutex) ;
    
    return nextID ;
}

- (MSInt)getDBVersion
{
    MSInt dbVersion = 0 ;
    MSDBResultSet *result = nil ;
    MSDBConnection *conn = nil ;
    NSString *select = nil ;
    
    select = [NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@='%@';",
              DB_TABLE_PARAMETERS_COL_VALUE1,
              DB_TABLE_PARAMETERS,
              DB_TABLE_PARAMETERS_COL_NAME,
              DB_VERSION_PARAM] ;
    
    conn = [self _connectDatabase] ;
    
    result = [conn fetchWithRequest:select] ;
    
    if([result nextRow])
    {
      id v = [[result rowDictionary] objectForKey:DB_TABLE_PARAMETERS_COL_VALUE1];
        dbVersion =  [(NSNumber *)[[result rowDictionary] objectForKey:DB_TABLE_PARAMETERS_COL_VALUE1] intValue] ;
    }
    
    [self _disconnectDatabase:conn] ;
    return dbVersion ;
}

- (BOOL)runSQLScript:(NSString *)scriptPath
{
    if (scriptPath) {
        BOOL res = YES ;
        MSInt error = 0 ;
        MSDBConnection *conn = [self _connectDatabase] ;
        MSDBTransaction *transaction ;
        NSString *query ;
        
        //open file and get script lines
        NSData *fileData = [NSData dataWithContentsOfFile:scriptPath] ;
        NSString *fileStringContent = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding] ;
        NSEnumerator *linesEnum = [[fileStringContent componentsSeparatedByString:@"\n"] objectEnumerator] ;
        
        [_messenger logWithLevel:MHAppInfo log:@"runSQLScript : '%@'",scriptPath] ;
        
        transaction = [conn openTransaction] ;
        
        while(res && (query = [linesEnum nextObject]))
        {
            if([query length] && ![query containsString:@"--"]) {
                res = [transaction appendSQLCommand:query error:&error] ;
            }
        }
        
        if(res){ [transaction save] ; }
        else
        {
            [_messenger logWithLevel:MHAppError log:@"SQL script failed : %@", [conn lastError]] ;
            [transaction cancel] ;
        }
        
        [self _disconnectDatabase:conn] ;
        return res ;
    }
    else {
        return NO ;
    }
}


@end
